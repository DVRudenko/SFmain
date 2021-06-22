public with sharing class LeadHistoryViewController {
	public String opptyId {get; set;}
	public List<ObjectHistoryLine> leadHistoryLinesList {get; set;}
	private Map<String, Schema.SObjectField> myObjectFieldMap;
	private List<Schema.PicklistEntry> historyFieldPicklistValues;

    public LeadHistoryViewController() {  
    }

    public void init() {
		String opptyId = ApexPages.CurrentPage().getparameters().get('id');
		List<Lead> convertedLeadList = [SELECT Id FROM Lead WHERE ConvertedOpportunityId = :opptyId LIMIT 1];
		this.leadHistoryLinesList = new List<ObjectHistoryLine>();
		if (! convertedLeadList.isEmpty()) {
			this.leadHistoryLinesList = objectHistoryLines(convertedLeadList.get(0).Id);
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'This opportunity was created manually. <a href="/' + opptyId + '">back to Opportunity</a>'));
		}
    }


    /*******************************************************************************
    *  Name            : objectHistoryLines(Id objectId)
    *  Summary         : getting field history lines of sObject   
    *  CreatedDate     : 01/12/2017
    *  ModifiedDate    : -
    *  Parameters      : Id objectId
    *  Returns         : return field history lines list
    ******************************************************************************/
    public List<ObjectHistoryLine> objectHistoryLines(Id objectId) {
    	Schema.DescribeSObjectResult objectDescription = objectId.getSObjectType().getDescribe();

    	//Get the name of thew history table
		String objectHistoryTableName = objectDescription.getName();
		this.myObjectFieldMap = objectDescription.fields.getMap();

		//if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
		String objectIdName ;
		if (objectDescription.isCustom()) {
			objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
			objectIdName = 'ParentId';
		} else {
			objectIdName = objectHistoryTableName + 'Id';
		}
		objectHistoryTableName = objectHistoryTableName + 'History';

		Schema.DescribeFieldResult objectHistoryFieldField = Schema.getGlobalDescribe().get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
		this.historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();

		List<sObject> historyList = Database.query( 'SELECT CreatedDate, ' +
			'CreatedById, ' +
			'Field, ' +
			'NewValue, ' +
			'OldValue ' +
			'FROM ' + objectHistoryTableName + ' ' +
			'WHERE ' + objectIdName + '=\'' + objectId + '\' ' +
			'ORDER BY CreatedDate DESC, Field ' +
			'LIMIT 100'
		);

		String prevDate = '';
		List<ObjectHistoryLine> objectHistory = new List<ObjectHistoryLine>();
		for(Integer i = 0; i < historyList.size(); i++) {
			sObject historyLine = historyList.get(i);
			ObjectHistoryLine tempHistory = new ObjectHistoryLine();
			if ((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) || 
				(historyLine.get('newValue') != null && !(String.valueOf(historyLine.get('newValue')).startsWith('005') || String.valueOf(historyLine.get('newValue')).startsWith('00G'))) || 
				(historyLine.get('oldValue') != null && !(String.valueOf(historyLine.get('oldValue')).startsWith('005') || String.valueOf(historyLine.get('oldValue')).startsWith('00G')))) {
				// Set the Date and who performed the action
				if (String.valueOf(historyLine.get('CreatedDate')) != prevDate) {
					String timeZone = UserInfo.getTimeZone().getID();
					Datetime dateGMT = Datetime.valueOf(historyLine.get('CreatedDate'));
					Datetime createdDateLine = Datetime.valueOf(dateGMT);
					tempHistory.theDate = createdDateLine.format('dd/MM/yyyy HH:mm', timeZone);
					tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
					tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
				} else {
					tempHistory.theDate = '';
					tempHistory.who = '';
					tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
				}
				prevDate = String.valueOf(historyLine.get('CreatedDate'));

				// Get the field label
				String fieldLabel = returnFieldLabel(String.valueOf(historyLine.get('Field')));

				// Set the Action value
				if (String.valueOf(historyLine.get('Field')) == 'created') { // on Creation
					tempHistory.action = 'Created.';
				} else if (String.valueOf(historyLine.get('Field')) == 'leadConverted') {
					tempHistory.action = 'Lead Converted.';
				} else if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null) { // when deleting a value from a field
				// Format the Date and if there's an error, catch it and re
					try {
						tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.get('oldValue')).format() + ' in <b>' + fieldLabel + '</b>.';
					} catch (Exception e) {
						tempHistory.action = 'Deleted ' + String.valueOf(historyLine.get('oldValue')) + ' in <b>' + fieldLabel + '</b>.';
					}
				} else { // all other scenarios
					String fromText = '';
					if (historyLine.get('oldValue') != null) {
						try {
							fromText = ' from ' + Date.valueOf(historyLine.get('oldValue')).format();
						} catch (Exception e) {
							fromText = ' from ' + String.valueOf(historyLine.get('oldValue'));
						}
					}
					String toText = '';
					if (historyLine.get('newValue') != null) {
						try {
							toText = Date.valueOf(historyLine.get('newValue')).format();
						} catch (Exception e) {
							toText = String.valueOf(historyLine.get('newValue'));
						}
					}
					if (toText != '') {
						tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
					} else {
						tempHistory.action = 'Changed <b>' + fieldLabel;
					}
				}
				// Add to the list
				objectHistory.add(tempHistory);		
	   		}	   		
   		}

   		List<Id> userIdList = new List<Id>();
   		for (ObjectHistoryLine myHistory : objectHistory) {
			userIdList.add(myHistory.userId);
		}
		Map<Id, User> userIdMap = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :userIdList]);
		for (objectHistoryLine myHistory : objectHistory) {
			if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ) {
				myHistory.who = userIdMap.get(myHistory.who).Name;
			}
		}
		return objectHistory;
	}


	/*******************************************************************************
	*  Name            : returnFieldLabel(String fieldName)
	*  Summary         : function to return Field Label of a object field given a Field API name    
	*  CreatedDate     : 01/12/2017
	*  ModifiedDate    : -
	*  Parameters      : String fieldName
	*  Returns         : return Field Label
	******************************************************************************/
	public String returnFieldLabel(String fieldName){
		if (this.myObjectFieldMap.containsKey(fieldName)) {
			return this.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
		} else {
			for(Schema.PicklistEntry pickList : this.historyFieldPicklistValues) {
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

    // Inner Class to store the detail of the object history lines 
	public class ObjectHistoryLine {
		public String theDate {get; set;}
		public String who {get; set;}
		public Id userId {get; set;} 
		public String action {get; set;}
	}
}