public class E2E_RU_Internal_Notifications {
	private static E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
	private static E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');

	public static void abandonmentScenarioQueueable (List<Opportunity> listOpportunities,Map<Id, E2EFormData__c> opportunityFormDataRelateMap) {
		try {
			System.debug('E2E_RU_Internal_Notifications.abandonmentScenarioQueueable DEBUG START:');
			System.debug('ListOpportunities.size() === ' + listOpportunities.size());
			System.debug('ListOpportunities === ' + listOpportunities);
			System.debug('OpportunityFormDataRelateMap.size() === ' + opportunityFormDataRelateMap.size());
			System.debug('OpportunityFormDataRelateMap === ' + opportunityFormDataRelateMap);


			String notificationName = notifications.Abandonment_Scenario_Queueable.name();
			E2E_Form_Ru_Internal_Notifications__c settings = E2E_Form_Ru_Internal_Notifications__c.getValues(notificationName);
			List<String> listEmails = getRecipientsEmails( String.valueOf(settings.get('Recipients__c')) );
			List<Messaging.Email> messages = new List<Messaging.Email>();

			for (Opportunity nextOpp : listOpportunities) {

				Map<String, String> paramsMap = new Map<String, String>();
				paramsMap.put('#Id#', nextOpp.Id);
				paramsMap.put('#E2E_Sub_Status__c#', nextOpp.E2E_Sub_Status__c);
				paramsMap.put('#Name#', nextOpp.Name);
				paramsMap.put('#isManual#', '');

				if (opportunityFormDataRelateMap.containsKey(nextOpp.Id)) {
					E2EFormData__c formData = opportunityFormDataRelateMap.get(nextOpp.Id);
					if (formData.E2E_Manual_Entry__c == true || formData.E2E_Manual_Entry_Legal_Info__c == true) {
						paramsMap.put('#isManual#', '<p>Клиент выполнил ручную корректировку данных на форме</p>');
					}
				}

				messages.add( getSingleEmailMessage(settings, paramsMap, listEmails) );
			}

			if ( !Test.isRunningTest() && messages.size() != 0) {
				Messaging.sendEmail(messages);
			}
			System.debug('E2E_RU_Internal_Notifications.abandonmentScenarioQueueable DEBUG END:');
		} catch (Exception e) {
		    System.debug('abandonmentScenarioQueueable Exception = ' + e.getMessage());
		    System.debug('abandonmentScenarioQueueable Exception = ' + e.getStackTraceString());
		}
	}

	public static void forceUpdateOpportunity (String opportunityId) {
		try {
			System.debug('E2E_RU_Internal_Notifications.forceUpdateOpportunity DEBUG START:');
			System.debug('OpportunityId === ' + opportunityId);

			Opportunity opp = e2EFormRuDao.getOpportunityById(opportunityId);
			Map<String, String> paramsMap = new Map<String, String>();
			paramsMap.put('#Id#', opp.Id);
			paramsMap.put('#Name#', opp.Name);

			sendNotification(notifications.Warning_Notification_Call_Center.name(), paramsMap, null);
			System.debug('E2E_RU_Internal_Notifications.forceUpdateOpportunity DEBUG END:');
		} catch (Exception e) {
		    System.debug('forceUpdateOpportunity Exception = ' + e.getMessage());
		    System.debug('forceUpdateOpportunity Exception = ' + e.getStackTraceString());
		}
	}

	public static void duplicateLeadProcess (List<Lead> duplicateLeadsList) {
		try {
			System.debug('E2E_RU_Internal_Notifications.duplicateLeadProcess DEBUG START:');
			System.debug('DuplicateLeadsList.size() === ' + duplicateLeadsList.size());
			System.debug('DuplicateLeadsList === ' + duplicateLeadsList);
			System.debug('GeneralSettings.Domain_Url__c === ' + generalSettings.Domain_Url__c + '/');


			String notificationName = notifications.Disqualification_Lead.name();
			E2E_Form_Ru_Internal_Notifications__c settings = E2E_Form_Ru_Internal_Notifications__c.getValues(notificationName);
			List<String> listEmails = getRecipientsEmails( String.valueOf(settings.get('Recipients__c')) );
			List<Messaging.Email> messages = new List<Messaging.Email>();

			Set<Id> leadOwnerIds = getSetIdsFromListObjects(duplicateLeadsList, 'OwnerId');
			Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(leadOwnerIds);

			for (Lead lead : duplicateLeadsList) {

				List<String> listEmailsForCurrentLead = new List<String>(listEmails);
				if (lead.Owner.Type == 'User' && usersMap.containsKey(lead.OwnerId)) {
					List<String> additionalEmails = new List<String>();
					User ownerUser = usersMap.get(lead.OwnerId);
					Set<Id> usersIds = new Set<Id>();

					addIdToSet(usersIds, getStringFromObject(ownerUser, 'ManagerId'));
					addIdToSet(usersIds, getStringFromObject(ownerUser, 'Id'));

					if (usersIds.size() != 0) {
						List<User> listUsers = e2EFormRuDao.getUsersMapByIds(usersIds).values();
						additionalEmails = getListStringsFromListObjects( listUsers, 'Email' );
						listEmailsForCurrentLead.addAll( additionalEmails );
					}
				}

				Map<String, String> paramsMap = new Map<String, String>();
				paramsMap.put('#Id#', lead.Id);
				paramsMap.put('#Owner.Name#', lead.Owner.Name);
				paramsMap.put('#Name#', lead.Name);
				paramsMap.put('#INN__c#', lead.INN__c);
				paramsMap.put('#Phone#', lead.Phone);

				messages.add( getSingleEmailMessage(settings, paramsMap, listEmailsForCurrentLead) );
			}

			if ( !Test.isRunningTest() && messages.size() != 0) {
				Messaging.sendEmail(messages);
			}
			System.debug('E2E_RU_Internal_Notifications.duplicateLeadProcess DEBUG END:');
		} catch (Exception e) {
		    System.debug('duplicateLeadProcess Exception = ' + e.getMessage());
		    System.debug('duplicateLeadProcess Exception = ' + e.getStackTraceString());
		}
	}

	public static void goToCongratulations (E2EFormParams formParams, Id opportunityId) {
		try {
			System.debug('E2E_RU_Internal_Notifications.goToCongratulations DEBUG START:');
			System.debug('formParams.opportunityId === ' + opportunityId);
			System.debug('formParams.isNumberOfCardsLimit === ' + formParams.isNumberOfCardsLimit);
			System.debug('formParams.isManualEntry === ' + formParams.isManualEntry);
			System.debug('formParams === ' + formParams);

			Opportunity opp = e2EFormRuDao.getOpportunityById(opportunityId);

			Map<String, String> paramsMap = new Map<String, String>();
			paramsMap.put('#Id#', opp.Id);
			paramsMap.put('#Name#', opp.Name);
			paramsMap.put('#Number_of_Cards__c#', opp.Number_of_Cards__c != null ? String.valueOf(opp.Number_of_Cards__c) : 'None' );
			paramsMap.put('#isManualEntry#', formParams.isManualEntry ? 'Да' : 'Нет');

			if (formParams.isNumberOfCardsLimit) {
				sendNotification(notifications.Transfer_To_Ko_More_10_Cards.name(), paramsMap, null);
			} else if (formParams.isManualEntry) {
				sendNotification(notifications.Transfer_To_KO_Manual_Entry.name(), paramsMap, null);
			}
			System.debug('E2E_RU_Internal_Notifications.goToCongratulations DEBUG END:');
		} catch (Exception e) {
		    System.debug('goToCongratulations Exception = ' + e.getMessage());
		    System.debug('goToCongratulations Exception = ' + e.getStackTraceString());
		}
	}

	public static void goToLegalDetails (E2EFormParams formParams, Id opportunityId) {
		try {
			System.debug('E2E_RU_Internal_Notifications.goToLegalDetails DEBUG START:');
			System.debug('formParams.opportunityId === ' + opportunityId);
			System.debug('formParams.verifiedDecisionCode === ' + formParams.verifiedDecisionCode);
			System.debug('formParams === ' + formParams);


			Map<String, String> paramsMap = new Map<String, String>();
			paramsMap.put('#Id#', opportunityId);

			if (formParams.verifiedDecisionCode == '1') {
				sendNotification(notifications.Risk_Management.name(), paramsMap, null);
			} else if (formParams.verifiedDecisionCode == '4') {
				sendNotification(notifications.Reseller.name(), paramsMap, null);
			}
			System.debug('E2E_RU_Internal_Notifications.goToLegalDetails DEBUG END:');
		} catch (Exception e) {
		    System.debug('goToLegalDetails Exception = ' + e.getMessage());
		    System.debug('goToLegalDetails Exception = ' + e.getStackTraceString());
		}
	}

	public static void transferToE2E (List<Opportunity> refusingOpportunityList) {
		try {
			System.debug('E2E_RU_Internal_Notifications.transferToE2E DEBUG START:');
			System.debug('refusingOpportunityList.size === ' + refusingOpportunityList.size());
			System.debug('refusingOpportunityList === ' + refusingOpportunityList);


			String notificationName = notifications.Transfer_To_E2E.name();
			E2E_Form_Ru_Internal_Notifications__c settings = E2E_Form_Ru_Internal_Notifications__c.getValues(notificationName);
			List<String> listEmails = getRecipientsEmails( String.valueOf(settings.get('Recipients__c')) );
			List<Messaging.Email> messages = new List<Messaging.Email>();

			for (Opportunity nextOpp : refusingOpportunityList) {
				Set<Id> usersIds = new Set<Id>();
				List<String> listEmailsForCurrentOpp = new List<String>(listEmails);
				addIdToSet(usersIds, nextOpp.OwnerId);
				addIdToSet(usersIds, nextOpp.Owner.ManagerId);

				if (usersIds.size() != 0) {
					List<User> listUsers = e2EFormRuDao.getUsersMapByIds(usersIds).values();
					List<String> additionalEmails = getListStringsFromListObjects( listUsers, 'Email' );
					listEmailsForCurrentOpp.addAll( additionalEmails );
				}

				Map<String, String> paramsMap = new Map<String, String>();
				paramsMap.put('#Id#', nextOpp.Id);
				paramsMap.put('#Name#', nextOpp.Name);
				messages.add( getSingleEmailMessage(settings, paramsMap, listEmailsForCurrentOpp) );
			}

			if ( !Test.isRunningTest() && messages.size() != 0) {
				Messaging.sendEmail(messages);
			}
			System.debug('E2E_RU_Internal_Notifications.transferToE2E DEBUG END:');
		} catch (Exception e) {
		    System.debug('transferToE2E Exception = ' + e.getMessage());
		    System.debug('transferToE2E Exception = ' + e.getStackTraceString());
		}
	}

	public static void transferToKO (Account sfAccount, String e2eOpportunityId, Boolean innDuplication, Contact e2eContact, Account e2eAccount) {
		try {
			System.debug('E2E_RU_Internal_Notifications.transferToKO DEBUG START:');
			System.debug('E2eOpportunityId === ' + e2eOpportunityId);
			System.debug('InnDuplication === ' + innDuplication);
			System.debug('E2eContact === ' + e2eContact);
			System.debug('E2eAccount === ' + e2eAccount);
			System.debug('SfAccount === ' + sfAccount);
			System.debug('SfAccount.Opportunities.size === ' + sfAccount.Opportunities.size());
			System.debug('SfAccount.Opportunities === ' + sfAccount.Opportunities);


			Set<Id> userIdsForNotification = new Set<Id>();
			List<Opportunity> suitableOpportunities = new List<Opportunity>();

			for (Opportunity opportunity : sfAccount.Opportunities) {
				if (opportunity.Id != e2eOpportunityId) {
					suitableOpportunities.add(opportunity);
					addIdToSet(userIdsForNotification, opportunity.OwnerId);
					addIdToSet(userIdsForNotification, opportunity.Owner.ManagerId);
				}
			}

			if ( suitableOpportunities.size() != 0 ) {
				List<User> listUsers = e2EFormRuDao.getUsersMapByIds(userIdsForNotification).values();
				List<String> additionalEmails = getListStringsFromListObjects( listUsers, 'Email' );

				if (innDuplication == true) {
					Map<String, String> paramsMap = new Map<String, String>();//TODO
					paramsMap.put('#Id#', sfAccount.Id);
					paramsMap.put('#INN__c#', sfAccount.INN__c);
					paramsMap.put('#Name#', sfAccount.Name);
					paramsMap.put('#Phone#', e2eContact.MobilePhone);
					paramsMap.put('#Email#', e2eContact.Email);
					sendNotification(notifications.Transfer_To_Ko_With_INN.name(), paramsMap, additionalEmails);
				} else {
					Map<String, String> paramsMap = new Map<String, String>();
					String arr = '';
					arr += '#Id#=' + sfAccount.Id + ';';
					arr += '#Name#=' + sfAccount.Name + ';;';
					arr += '#Id#=' + e2eAccount.Id + ';';
					arr += '#Name#=' + e2eAccount.Name + ';';
					paramsMap.put('#arr#', arr);
					sendNotification( notifications.Transfer_To_Ko_With_Email.name(), paramsMap, additionalEmails );
				}
			}
			System.debug('suitableOpportunities.size() === ' + suitableOpportunities.size());
			System.debug('E2E_RU_Internal_Notifications.transferToKO DEBUG END:');
		} catch (Exception e) {
		    System.debug('transferToKO Exception = ' + e.getMessage());
		    System.debug('transferToKO Exception = ' + e.getStackTraceString());
		}
	}


	public static void transferToInbound (Account sfAccount, String e2eOpportunityId) {
		try {
			System.debug('E2E_RU_Internal_Notifications.transferToInbound DEBUG START:');
			System.debug('E2eOpportunityId === ' + e2eOpportunityId);
			System.debug('SfAccount === ' + sfAccount);
			System.debug('SfAccount.Opportunities.size === ' + sfAccount.Opportunities.size());
			System.debug('SfAccount.Opportunities === ' + sfAccount.Opportunities);


			Set<Id> userIdsForNotification = new Set<Id>();
			List<Opportunity> suitableOpportunities = new List<Opportunity>();
			Map<String, String> paramsMap = new Map<String, String>();
			paramsMap.put('#arr#', '');

			for (Opportunity opportunity : sfAccount.Opportunities) {
				if (opportunity.Probability > 0 && opportunity.Probability < 100 && opportunity.Id != e2eOpportunityId) {
					suitableOpportunities.add(opportunity);
					addIdToSet(userIdsForNotification, opportunity.Owner.ManagerId);
					String arrObj = '';
					arrObj += '#Id#=' + opportunity.Id + ';';
					arrObj += '#Name#=' + opportunity.Name + ';';
					arrObj += '#INN_Opp__c#=' + opportunity.INN_Opp__c + ';';
					arrObj += '#Owner.Id#=' + opportunity.Owner.Id + ';';
					arrObj += '#Owner.Name#=' + opportunity.Owner.Name + ';';
					arrObj += '#Owner.UserRole.Name#=' + opportunity.Owner.UserRole.Name + ';';
					arrObj += '#StageName#=' + opportunity.StageName + ';';
					arrObj += '#Day_transfer__c#=' + opportunity.Day_transfer__c + ';';
					arrObj += '#CloseDate#=' + opportunity.CloseDate + ';;';
					paramsMap.put('#arr#', paramsMap.get('#arr#') + arrObj);
				}
			}

			if ( suitableOpportunities.size() != 0 ) {
				List<User> listUsers = e2EFormRuDao.getUsersMapByIds(userIdsForNotification).values();
				List<String> additionalEmails = getListStringsFromListObjects( listUsers, 'Email' );

				sendNotification( notifications.Transfer_To_Inbound.name(), paramsMap, additionalEmails );
			}

			System.debug('SuitableOpportunities.size() === ' + suitableOpportunities.size());
			System.debug('E2E_RU_Internal_Notifications.transferToInbound DEBUG END:');
		} catch (Exception e) {
		    System.debug('transferToInbound Exception = ' + e.getMessage());
		    System.debug('transferToInbound Exception = ' + e.getStackTraceString());
		}
	}

	public static void transferToService (Account sfAccount, String e2eOpportunityId) {
		try {
			System.debug('E2E_RU_Internal_Notifications.transferToService DEBUG START:');
			System.debug('E2eOpportunityId === ' + e2eOpportunityId);
			System.debug('SfAccount === ' + sfAccount);
			System.debug('SfAccount.Opportunities.size === ' + sfAccount.Opportunities.size());
			System.debug('SfAccount.Opportunities === ' + sfAccount.Opportunities);


			Set<Id> userIdsForNotification = new Set<Id>();
			List<Opportunity> suitableOpportunities = new List<Opportunity>();
			Map<String, String> paramsMap = new Map<String, String>();
			paramsMap.put('#arr#', '');

			for (Opportunity opportunity : sfAccount.Opportunities) {
				Boolean condition1 = opportunity.Probability > 0 && opportunity.Probability < 100 && opportunity.Id != e2eOpportunityId;
				Boolean condition2 = opportunity.StageName == 'Moved to Start' && Date.today().monthsBetween(opportunity.CloseDate) >= -6;

				if (condition1 || condition2) {
					suitableOpportunities.add(opportunity);
					addIdToSet(userIdsForNotification, opportunity.Owner.ManagerId);
					String arrObj = '';
					arrObj += '#Id#=' + opportunity.Id + ';';
					arrObj += '#Name#=' + opportunity.Name + ';';
					arrObj += '#INN_Opp__c#=' + opportunity.INN_Opp__c + ';';
					arrObj += '#Owner.Id#=' + opportunity.Owner.Id + ';';
					arrObj += '#Owner.Name#=' + opportunity.Owner.Name + ';';
					arrObj += '#Owner.UserRole.Name#=' + opportunity.Owner.UserRole.Name + ';';
					arrObj += '#StageName#=' + opportunity.StageName + ';';
					arrObj += '#Day_transfer__c#=' + opportunity.Day_transfer__c + ';';
					arrObj += '#CloseDate#=' + opportunity.CloseDate + ';;';
					paramsMap.put('#arr#', paramsMap.get('#arr#') + arrObj);
				}
			}

			if ( suitableOpportunities.size() != 0 ) {
				List<User> listUsers = e2EFormRuDao.getUsersMapByIds(userIdsForNotification).values();
				List<String> additionalEmails = getListStringsFromListObjects( listUsers, 'Email' );

				sendNotification( notifications.Transfer_To_Service.name(), paramsMap, additionalEmails );
			}

			System.debug('SuitableOpportunities.size() === ' + suitableOpportunities.size());
			System.debug('E2E_RU_Internal_Notifications.transferToService DEBUG END:');
		} catch (Exception e) {
		    System.debug('transferToService Exception = ' + e.getMessage());
		    System.debug('transferToService Exception = ' + e.getStackTraceString());
		}
	}

	public static void sendNotification (String notificationName, Map<String, String> paramsMap, List<String> additionalEmails) {
		E2E_Form_Ru_Internal_Notifications__c notificationSettings = E2E_Form_Ru_Internal_Notifications__c.getValues(notificationName);
		if (notificationSettings == null) {
			return;
		}

		List<String> listEmails = getRecipientsEmails( String.valueOf(notificationSettings.get('Recipients__c')) );
		if (additionalEmails != null) {
			listEmails.addAll( additionalEmails );
		}

		Messaging.SingleEmailMessage mail = getSingleEmailMessage(notificationSettings, paramsMap, listEmails);
		if ( !Test.isRunningTest() ) {
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
		}
	}

	private static List<String> getRecipientsEmails (String recipientFields) {
		Set<String> setEmails = new Set<String>();
		Set<String> setUserNames = new Set<String>();
		Map<String, Object> settingsMap = generalSettings.getPopulatedFieldsAsMap();

		for (String nextFieldName : recipientFields.split(';')) {
			nextFieldName = nextFieldName.trim();
			if( settingsMap.containsKey(nextFieldName) && settingsMap.get(nextFieldName) != null ) {
				String nextFieldValue = String.valueOf( settingsMap.get(nextFieldName) );
				for (String nextValue : nextFieldValue.split(';')) {
					if ( nextValue.contains('@') && nextFieldValue.contains('.') ) {
						setEmails.add( nextValue.trim() );
					} else {
						setUserNames.add( nextValue.trim() );
					}
				}
			}
		}

		if ( setUserNames.size() != 0 ) {
			List<User> listUsers = e2eFormRuDao.getUsersByNames(setUserNames).values();
			setEmails.addAll( getSetStringsFromListObjects(listUsers, 'Email') );
		}

		return new List<String>(setEmails);
	}

	private static List<String> getListStringsFromListObjects (List<sObject> listObjects, String fieldName) {
		return new List<String>( getSetStringsFromListObjects(listObjects, fieldName) );
	}

	private static Set<String> getSetStringsFromListObjects (List<sObject> listObjects, String fieldName) {
		Set<String> resultSet = new Set<String>();
		for (sObject nextObj : listObjects) {
			Map<String, Object> mapObj = nextObj.getPopulatedFieldsAsMap();
			if (mapObj.containsKey(fieldName) && mapObj.get(fieldName) != null) {
				resultSet.add( String.valueOf(mapObj.get(fieldName)) );
		    }
		}
		return resultSet;
	}

	private static Set<Id> getSetIdsFromListObjects (List<sObject> listObjects, String fieldName) {
		Set<Id> resultSet = new Set<Id>();
		for (sObject nextObj : listObjects) {
			addIdToSet(resultSet, getStringFromObject(nextObj, fieldName));
		}
		return resultSet;
	}

	private static String getStringFromObject (sObject obj, String fieldName) {
		String result;
		Map<String, Object> mapObj = obj.getPopulatedFieldsAsMap();
		if (mapObj.containsKey(fieldName) && mapObj.get(fieldName) != null) {
			result = String.valueOf( mapObj.get(fieldName) );
		}
		return result;
	}

	public static String getPageAsString (String pageName, Map<String, String> paramsMap) {
		EmailTemplate testTemplate = new EmailTemplate(HtmlValue = 'test');
		EmailTemplate template = Test.isRunningTest() ? testTemplate : e2EFormRuDao.getEmailTemplateByDevName(pageName);

		if (paramsMap.containsKey('#arr#')) {
			replaceHtmlForArr(template, paramsMap.get('#arr#'));
		}

		for ( String nextKey : paramsMap.keySet() ) {
			String value = paramsMap.get(nextKey) == null ? '' : paramsMap.get(nextKey);
			template.HtmlValue = template.HtmlValue.replaceAll(nextKey, value);
		}

		template.HtmlValue = template.HtmlValue.replaceAll('#Domain_Url__c#', generalSettings.Domain_Url__c + '/');
		return template.HtmlValue;
	}

	public static void replaceHtmlForArr (EmailTemplate template, String arr) {
		String finishHtmlForArr = '';
		String startHtmlForArr = template.HtmlValue.substringBetween('#arrStart#', '#arrEnd#');

		for (String nextObj : arr.split(';;')) {
			String htmlForNextObj = startHtmlForArr;
			for (String nextField : nextObj.split(';')) {
				String label = nextField.substringBefore('=');
				String value = nextField.substringAfter('=');
				value = value == 'null' ? '' : value;
				htmlForNextObj = htmlForNextObj.replaceAll(label, value);
			}
			finishHtmlForArr += htmlForNextObj;
		}

		template.HtmlValue = template.HtmlValue.replace(startHtmlForArr, finishHtmlForArr);
		template.HtmlValue = template.HtmlValue.replace('#arrStart#', '');
		template.HtmlValue = template.HtmlValue.replace('#arrEnd#', '');
	}

	private static Messaging.SingleEmailMessage getSingleEmailMessage (E2E_Form_Ru_Internal_Notifications__c settings,
																	   Map<string, String> paramsMap,
																	   List<String> listEmails) {

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setHtmlBody( getPageAsString(settings.Email_Body__c, paramsMap) );
		mail.setToAddresses( listEmails );
		mail.setSubject( String.valueOf(settings.get('Email_Subject__c')) );
		return mail;
	}

	private static void addIdToSet (Set<Id> setIds, String value) {
		if (value != null && value instanceof Id) {
			setIds.add( Id.valueOf(value) );
		}
	}

	public Enum notifications {
		Transfer_To_Service,
		Transfer_To_Inbound,
		Transfer_To_Ko_With_INN,
		Transfer_To_Ko_With_Email,
		Transfer_To_E2E,
		Risk_Management,
		Reseller,
		Transfer_To_Ko_More_10_Cards,
		Transfer_To_Ko_Manual_Entry,
		Disqualification_Lead,
		Warning_Notification_Call_Center,
		Abandonment_Scenario_Queueable
	}
}