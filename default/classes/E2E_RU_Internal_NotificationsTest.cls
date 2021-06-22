@isTest
public class E2E_RU_Internal_NotificationsTest {

	@TestSetup
	public static void makeData () {

		List<E2E_Form_Ru_Internal_Notifications__c> listNotifications = new List<E2E_Form_Ru_Internal_Notifications__c>();
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Transfer_To_Ko_With_INN',
				Recipients__c = 'External_Main_Managers__c; Main_Managers__c',
				Email_Subject__c = 'Russia E2E Notification',
				Email_Body__c = 'E2E_RU_EMAIL_Transfer_To_KO_With_INN'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Transfer_To_Service',
				Recipients__c = 'External_Service_Managers__c; External_Main_Managers__c; Main_Managers__c',
				Email_Subject__c = 'Russia E2E Notification',
				Email_Body__c = 'E2E_RU_EMAIL_Transfer_To_Service'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Transfer_To_Inbound',
				Recipients__c = 'External_Service_Managers__c; External_Main_Managers__c; Main_Managers__c',
				Email_Subject__c = 'Russia E2E Notification',
				Email_Body__c = 'E2E_RU_EMAIL_Transfer_To_Inbound'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Transfer_To_Ko_With_Email',
				Recipients__c = 'External_Main_Managers__c; Main_Managers__c',
				Email_Subject__c = 'Russia E2E Notification',
				Email_Body__c = 'E2E_RU_EMAIL_Transfer_To_KO_With_Email'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Transfer_To_E2E',
				Recipients__c = 'External_Main_Managers__c; Main_Managers__c',
				Email_Subject__c = 'Russia E2E Отказ Возможности',
				Email_Body__c = 'E2E_RU_EMAIL_Transfer_To_E2E'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Transfer_To_Ko_More_10_Cards',
				Recipients__c = 'External_Main_Managers__c; Main_Managers__c; External_Service_Managers__c',
				Email_Subject__c = 'Russia E2E Перевод в KO',
				Email_Body__c = 'E2E_RU_EMAIL_More_10_Cards'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Transfer_To_Ko_Manual_Entry',
				Recipients__c = 'External_Main_Managers__c; Main_Managers__c; External_Service_Managers__c',
				Email_Subject__c = 'Russia E2E Перевод в KO',
				Email_Body__c = 'E2E_RU_EMAIL_Manual_Entry'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Risk_Management',
				Recipients__c = 'External_Main_Managers__c; Main_Managers__c; External_Service_Managers__c',
				Email_Subject__c = 'Russia E2E Дополнительное согласование',
				Email_Body__c = 'E2E_RU_EMAIL_Risk_Management'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Reseller',
				Recipients__c = 'External_Main_Managers__c; Main_Managers__c; External_Service_Managers__c',
				Email_Subject__c = 'Russia E2E Дополнительное согласование',
				Email_Body__c = 'E2E_RU_EMAIL_Reseller'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Disqualification_Lead',
				Recipients__c = 'External_Call_Center_Managers__c',
				Email_Subject__c = 'Russia E2E Disqualification Lead',
				Email_Body__c = 'E2E_RU_EMAIL_Disqualification_Lead'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Warning_Notification_Call_Center',
				Recipients__c = 'External_Call_Center_Managers__c',
				Email_Subject__c = 'Russia E2E System Error',
				Email_Body__c = 'E2E_RU_EMAIL_Warning_Notification_CC'
		));
		listNotifications.add(new E2E_Form_Ru_Internal_Notifications__c(
				Name = 'Abandonment_Scenario_Queueable',
				Recipients__c = 'Main_Managers__c; Call_Center_Managers__c',
				Email_Subject__c = 'E2E Возможность неактивна',
				Email_Body__c = 'E2E_RU_EMAIL_Abandonment_Scenario'
		));
		INSERT listNotifications;

		E2E_Form_Ru_General_Settings__c generalSettings = new E2E_Form_Ru_General_Settings__c(
				Name = 'E2EFormRu',
				Main_Managers__c = 'test',
				Call_Center_Managers__c = 'test',
				External_Call_Center_Managers__c = 'test'
		);
		INSERT generalSettings;

		Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
		INSERT opp;

		Lead testLead = E2EFormRuTestUtils.createDefaultLead();
		INSERT testLead;
	}



	@isTest
	static void forceUpdateOpportunity () {
		String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
		E2E_RU_Internal_Notifications.forceUpdateOpportunity(oppId);
	}

	@isTest
	static void goToCongratulations () {
		String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
		E2EFormParams formParams = new E2EFormParams();
		formParams.isManualEntry = true;
		E2E_RU_Internal_Notifications.goToCongratulations(formParams, oppId);
		formParams.isNumberOfCardsLimit = true;
		E2E_RU_Internal_Notifications.goToCongratulations(formParams, oppId);
	}

	@isTest
	static void goToLegalDetails () {
		String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
		E2EFormParams formParams = new E2EFormParams();
		formParams.verifiedDecisionCode = '4';
		E2E_RU_Internal_Notifications.goToLegalDetails(formParams, oppId);
		formParams.verifiedDecisionCode = '1';
		E2E_RU_Internal_Notifications.goToLegalDetails(formParams, oppId);
	}

	@isTest
	static void transferToE2E () {
		List<Opportunity> listOpp = [
		    SELECT 	E2E_Sub_Status__c,  Name, Number_of_Cards__c, OwnerId, Owner.ManagerId,
					Probability, INN_Opp__c, Owner.Id, Owner.Name, Owner.UserRole.Name,
					StageName, Day_transfer__c, CloseDate
		    FROM 	Opportunity
		    LIMIT 	10000
		];
		E2E_RU_Internal_Notifications.transferToE2E(listOpp);
	}

	@isTest
	static void abandonmentScenarioQueueable () {
		List<Opportunity> listOpp = [
				SELECT 	E2E_Sub_Status__c,  Name, Number_of_Cards__c, OwnerId, Owner.ManagerId,
						Probability, INN_Opp__c, Owner.Id, Owner.Name, Owner.UserRole.Name,
						StageName, Day_transfer__c, CloseDate
				FROM 	Opportunity
				LIMIT 	1
		];

		Map<Id, E2EFormData__c> opportunityFormDataRelateMap = new Map<Id, E2EFormData__c>();
		E2EFormData__c formData = new E2EFormData__c(E2E_Manual_Entry__c = true);
		opportunityFormDataRelateMap.put(listOpp[0].Id, formData);

		E2E_RU_Internal_Notifications.abandonmentScenarioQueueable(listOpp, opportunityFormDataRelateMap);
	}

	@isTest
	static void duplicateLeadProcess () {
		List<Lead> listLeads = [
		    SELECT OwnerId, Owner.Type, Owner.Name, Name, INN__c, Phone
		    FROM Lead
		    LIMIT 1
		];

		E2E_RU_Internal_Notifications.duplicateLeadProcess(listLeads);
	}

	@isTest
	static void transferToInbound () {
		Account acc = E2EFormRuTestUtils.createDefaultAccount();
		INSERT acc;

		String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

		Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
		opp.Probability = 10;
		opp.AccountId = acc.Id;
		INSERT opp;

		acc = [
		    SELECT (SELECT 	E2E_Sub_Status__c,  Name, Number_of_Cards__c, OwnerId, Owner.ManagerId,
							Probability, INN_Opp__c, Owner.Id, Owner.Name, Owner.UserRole.Name,
							StageName, Day_transfer__c, CloseDate
					FROM 	Opportunities),
					INN__c, Name
		    FROM Account
			WHERE id = :acc.Id
		];

		E2E_RU_Internal_Notifications.transferToInbound(acc, oppId);
	}

	@isTest
	static void transferToKO () {
		Account acc = E2EFormRuTestUtils.createDefaultAccount();
		INSERT acc;

		Contact cont = E2EFormRuTestUtils.createDefaultContact();
 		cont.MobilePhone = 'test phone';
 		cont.Email = 'test@test.com';

		String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

		Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
		opp.Probability = 10;
		opp.AccountId = acc.Id;
		INSERT opp;

		acc = [
				SELECT (SELECT 	E2E_Sub_Status__c,  Name, Number_of_Cards__c, OwnerId, Owner.ManagerId,
								Probability, INN_Opp__c, Owner.Id, Owner.Name, Owner.UserRole.Name,
								StageName, Day_transfer__c, CloseDate
				FROM 	Opportunities),
						INN__c, Name
				FROM Account
				WHERE id = :acc.Id
		];

		E2E_RU_Internal_Notifications.transferToKO(acc, oppId, true, cont, acc);
		E2E_RU_Internal_Notifications.transferToKO(acc, oppId, false, cont, acc);
	}

	@isTest
	static void transferToService () {
		Account acc = E2EFormRuTestUtils.createDefaultAccount();
		INSERT acc;

		String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

		Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
		opp.Probability = 10;
		opp.AccountId = acc.Id;
		INSERT opp;

		acc = [
				SELECT (SELECT 	E2E_Sub_Status__c,  Name, Number_of_Cards__c, OwnerId, Owner.ManagerId,
								Probability, INN_Opp__c, Owner.Id, Owner.Name, Owner.UserRole.Name,
								StageName, Day_transfer__c, CloseDate
				FROM 	Opportunities),
						INN__c, Name
				FROM Account
				WHERE id = :acc.Id
		];

		E2E_RU_Internal_Notifications.transferToService(acc, oppId);
	}
}