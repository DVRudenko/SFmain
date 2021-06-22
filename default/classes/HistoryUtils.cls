public class HistoryUtils {

	/*******************************************************************************
	*  Name            : returnFieldLabel()
	*  Summary         : return field Label by FieldName
	*  CreatedDate     : 11/12/2017
	*  Parameters      : fieldName - field name, objectFieldMap - Map SObjectField,
						historyFieldPicklistValues - List pick entity
	*  Returns         : String
	******************************************************************************/
	private String returnFieldLabel(String fieldName,
										  Map<String, Schema.SObjectField> objectFieldMap,
										  List<Schema.PicklistEntry> historyFieldPicklistValues) {
		if (objectFieldMap.containsKey(fieldName)) {
			return objectFieldMap.get(fieldName).getDescribe().getLabel();
		} else {
			for (Schema.PicklistEntry pickList : historyFieldPicklistValues) {
				if (pickList.getValue() == fieldName) {
					if (pickList.getLabel() != null) {
						return pickList.getLabel();
					} else {
						return pickList.getValue();
					}
				}
			}
		}
		return '';
	}

	/*******************************************************************************
	*  Name            : getMetaDateObject()
	*  Summary         : return meta date for object by object Id
	*  CreatedDate     : 11/12/2017
	*  Parameters      : objectId - Id object
	*  Returns         : ObjectMetaData
	******************************************************************************/
	private ObjectMetaData getMetaDateObject(Id objectId) {
		List<ObjectHistoryLine> objectHistoryLinesList = new List<ObjectHistoryLine>();
		Map<String, Schema.SObjectField> objectFieldMap = new Map<String, Schema.SObjectField>();

		Schema.DescribeSObjectResult objectDescription = objectId.getSObjectType().getDescribe();

		//Get the name of thew history table
		String objectHistoryTableName = objectDescription.getName();
		objectFieldMap = objectDescription.fields.getMap();

		String objectIdName ;
		if (objectDescription.isCustom()) {
			objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length() - 1);
			objectIdName = 'ParentId';
		} else {
			objectIdName = objectHistoryTableName + 'Id';
		}

		if (objectDescription.getName() == 'Opportunity') {
			objectHistoryTableName = objectHistoryTableName + 'FieldHistory';
		} else  {
			objectHistoryTableName = objectHistoryTableName + 'History';
		}

		Schema.DescribeFieldResult objectHistoryFieldField =
				Schema.getGlobalDescribe().get(objectHistoryTableName).getDescribe().fields.getMap().get(
						'Field').getDescribe();
		List<Schema.PicklistEntry> historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();

		String query = 'SELECT CreatedDate, ' +
				'CreatedById, ' +
				'Field, ' +
				'NewValue, ' +
				'OldValue ' +
				'FROM ' + objectHistoryTableName + ' ' +
				'WHERE ' + objectIdName + '=\'' + objectId + '\' ' +
				'ORDER BY CreatedDate DESC, Field ';

		// add LIMIT to soql query
		if (! Test.isRunningTest() ) {
			query += 'LIMIT 100';
		} else {
			query += 'LIMIT 3';
		}

		List<sObject> historyList = Database.query(query);

		ObjectMetaData metaData = new ObjectMetaData();
		metaData.objectName = objectDescription.getName();
		metaData.objectFieldMap = objectFieldMap;
		metaData.historyFieldPicklistValues = historyFieldPicklistValues;
		metaData.historyList = historyList;
		return metaData;
	}

	public static void translatePicklist(String objectName, HistoryRecord historyRecord) {
		String fieldName = String.valueOf(historyRecord.get('Field'));
		Schema.SObjectField objectField =
				Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
		if(objectField == null) {
			return;
		}

		Schema.DescribeFieldResult describeFieldResult = objectField.getDescribe();
		Schema.DisplayType fieldDataType = describeFieldResult.getType();
		List<Schema.PicklistEntry> pickList = describeFieldResult.getPicklistValues();

		if(fieldDataType == Schema.DisplayType.Picklist) {
			for(Schema.PicklistEntry item : pickList) {
				if(item.getValue() == String.ValueOf(historyRecord.get('oldValue'))) {
					historyRecord.put('oldValue', (Object)item.getLabel());
				}

				if(item.getValue() == String.ValueOf(historyRecord.get('newValue'))) {
					historyRecord.put('newValue', (Object)item.getLabel());
				}
			}
		}
	}

	/*******************************************************************************
	*  Name            : getObjectHistory()
	*  Summary         : return List ObjectHistoryLine for object by Id
	*  CreatedDate     : 11/12/2017
	*  Parameters      : objectId - Id object
	*  Returns         : List<ObjectHistoryLine>
	******************************************************************************/
	public List<ObjectHistoryLine> getObjectHistory(Id objectId) {
		ObjectMetaData metaData = getMetaDateObject(objectId);

		List<ObjectHistoryLine> objectHistory = new List<ObjectHistoryLine>();
		for (Integer i = 0; i < metaData.historyList.size(); i++) {
			HistoryRecord historyRecord = new HistoryRecord(metaData.historyList.get(i));
			sObject historyLine = metaData.historyList.get(i);

			if (((historyRecord.get('newValue') == null && historyRecord.get('oldValue') == null) ||
					historyRecord.get('newValue') != null &&
							!(String.valueOf(historyRecord.get('newValue')).startsWith('005') ||
									String.valueOf(historyRecord.get('newValue')).startsWith('00G') ||
									String.valueOf(historyRecord.get('newValue')).startsWith('012'))) ||
					(historyRecord.get('oldValue') != null &&
							!(String.valueOf(historyRecord.get('oldValue')).startsWith('005') ||
									String.valueOf(historyRecord.get('oldValue')).startsWith('00G') ||
									String.valueOf(historyRecord.get('oldValue')).startsWith('012')
							))
			) {

				ObjectHistoryLine tempHistory = new ObjectHistoryLine();

				tempHistory.theDate = Datetime.valueOf(historyRecord.get('CreatedDate')).format('dd/MM/yyyy HH:mm');
				tempHistory.userId = String.valueOf(historyRecord.get('CreatedById'));
				tempHistory.who = String.valueOf(historyRecord.get('CreatedById'));

				String fieldLabel = returnFieldLabel(String.valueOf(historyRecord.get('Field')), metaData.objectFieldMap,
						metaData.historyFieldPicklistValues);

				translatePicklist(metaData.objectName, historyRecord);

				if (getCreatedAction(historyRecord, tempHistory)) {

				} else if (getDeletedAction(fieldLabel, historyRecord, tempHistory)) {

				} else {
					getActionForOtherScenarios(fieldLabel, historyRecord, tempHistory);
				}
				objectHistory.add(tempHistory);
			}
		}

		List<Id> userIdList = new List<Id>();
		for (ObjectHistoryLine historyItem : objectHistory) {
			userIdList.add(historyItem.userId);
		}
		Map<Id, User> userIdMap = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :userIdList]);
		for (objectHistoryLine historyItem : objectHistory) {
			if (userIdMap.containsKey(historyItem.userId) & (historyItem.who != '')) {
				historyItem.who = userIdMap.get(historyItem.who).Name;
			}
		}
		return objectHistory;
	}

	/*******************************************************************************
	*  Name            : getCreatedAction()
	*  Summary         : shaping created and converted from Lead  history for Object(Lead, Account, Contact, Opportunity),
						if exists - box to tempHistory and return true
	*  CreatedDate     : 11/12/2017
	*  Parameters      : historyLine - sObject, tempHistory - ObjectHistoryLine
	*  Returns         : Boolean
	******************************************************************************/
	private Boolean getCreatedAction(HistoryRecord historyLine, ObjectHistoryLine tempHistory) {
		if (String.valueOf(historyLine.get('Field')) == 'created') { // on Creation
			tempHistory.action = Label.RU_0032_ActionHistory_Created + '.';
			return true;
		} else {
			if (String.valueOf(historyLine.get('Field')) == 'leadConverted') {
				tempHistory.action = Label.RU_0035_ActionHistory_Converted + '.';
				return true;
			}else if (String.valueOf(historyLine.get('Field')) == 'accountCreatedFromLead') {
				tempHistory.action = Label.RU_0036_ActionHistory_CreatedByLeadConvert + '.';
				return true;
			}else if (String.valueOf(historyLine.get('Field')) == 'opportunityCreatedFromLead') {
				tempHistory.action = Label.RU_0036_ActionHistory_CreatedByLeadConvert + '.';
				return true;
			} else if (String.valueOf(historyLine.get('Field')) == 'contactCreatedFromLead') {
				tempHistory.action = Label.RU_0036_ActionHistory_CreatedByLeadConvert + '.';
				return true;
			}
		}
		return false;
	}

	/*******************************************************************************
	*  Name            : getDeletedAction()
	*  Summary         : shaping delete history action if it's exists
	*  CreatedDate     : 11/12/2017
	*  Parameters      : fieldLabel - field label, historyLine - sObject, tempHistory - temp history line
	*  Returns         : Boolean
	******************************************************************************/
	private Boolean getDeletedAction(String fieldLabel, HistoryRecord historyLine, ObjectHistoryLine tempHistory) {
		if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null) {
			if (historyLine.get('oldValue') instanceof Date) {
				tempHistory.action =
						Label.RU_0037_ActionHistory_Deleted + ' "' + Date.valueOf(historyLine.get('oldValue')).format() + '" ' + Label.RU_0038_ActionHistory_In + ' "<b>' + fieldLabel + '</b>".';
			} else {
				tempHistory.action =
						Label.RU_0037_ActionHistory_Deleted + ' "' + String.valueOf(historyLine.get('oldValue')) + '" ' + Label.RU_0038_ActionHistory_In + ' "<b>' + fieldLabel + '</b>".';
			}
			return true;
		}
		return false;
	}

	/*******************************************************************************
	*  Name            : getActionForOtherScenarios()
	*  Summary         : shaping  other scenarios history action if it's exists
	*  CreatedDate     : 11/12/2017
	*  Parameters      : fieldLabel - field label, historyLine - sObject, tempHistory - temp history line
	*  Returns         : Boolean
	******************************************************************************/
	private void getActionForOtherScenarios(String fieldLabel, HistoryRecord historyLine,
												   ObjectHistoryLine tempHistory) {
		String fromText = '';
		if (historyLine.get('oldValue') != null) {
			if (historyLine.get('oldValue') instanceof Date) {
				fromText = ' ' + Label.RU_0033_ActionHistory_From + ' "' + Date.valueOf(historyLine.get('oldValue')).format() + '"';
			} else {
				fromText = ' ' + Label.RU_0033_ActionHistory_From + ' "' + String.valueOf(historyLine.get('oldValue')) + '"';
			}
		}
		String toText = '';
		if (historyLine.get('newValue') != null) {
			if (historyLine.get('oldValue') instanceof Date) {
				toText = Date.valueOf(historyLine.get('newValue')).format();
			} else {
				toText = String.valueOf(historyLine.get('newValue'));
			}
		}
		if (toText != '') {
			tempHistory.action = Label.RU_0031_ActionHistory_Change + ' "<b>' + fieldLabel + '</b>" ' + fromText + ' ' + Label.RU_0034_ActionHistory_To + ' "<b>' + toText + '</b>".';
		} else {
			tempHistory.action = Label.RU_0031_ActionHistory_Change + ' "<b>' + fieldLabel + '</b>"';
		}
	}

	// Class wich consist meta date for object(Lead, Opportunity, Account, Contact)
	public class ObjectMetaData {
		public String objectName{ get; set; }
		public List<sObject> historyList{ get; set; }
		public List<Schema.PicklistEntry> historyFieldPicklistValues{ get; set; }
		public Map<String, Schema.SObjectField> objectFieldMap{ get; set; }
	}

	public class ObjectHistoryLine {
		public String theDate { get; set; }
		public String who { get; set; }
		public Id userId { get; set; }
		public String action { get; set; }
	}

	public class HistoryRecord {
		private Map<String, Object> fields = new Map<String, Object>();
		public HistoryRecord(sObject obj) {
			fields.put('Field', obj.get('Field'));
			fields.put('oldValue', obj.get('oldValue'));
			fields.put('newValue', obj.get('newValue'));
			fields.put('CreatedDate', obj.get('CreatedDate'));
			fields.put('CreatedById', obj.get('CreatedById'));
		}
		public Object get(String fieldName) {
			if(!fields.containsKey(fieldName)) {
				return null;
			}
			return fields.get(fieldName);
		}

		public void put(String fieldName, Object value) {
			fields.put(fieldName, value);
		}
	}
}