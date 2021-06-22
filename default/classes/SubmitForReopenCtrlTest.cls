@isTest
private class SubmitForReopenCtrlTest {
	public Static User u;
	public Static Opportunity newOpp;
	public Static Notifications_for_reopening_Opportunity__c customSettings;

	@isTest
    static void testSubmitForManualReopen() {
        Test.startTest();
			createUser();
		Test.stopTest();

		System.runAs(u) {
			createOpp();
			createCustomSettings();
					
			SubmitForReopenCtrl controller = new SubmitForReopenCtrl();
			ApexPages.currentPage().getParameters().put('Id', newOpp.Id);
			controller.init();

			List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id = :newOpp.Id];
			System.assertEquals(true, Approval.isLocked(oppList.get(0).Id));
		}
    }


    /*******************************************************************************
    *  Name            : testSubmitForReopenAutomatically()
    *  Summary         : Test automatic reopen without sending opportunity to credits
    *  CreatedDate     : 09/07/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testSubmitForReopenAutomatically() {
        Test.startTest();
			createUser();
		Test.stopTest();

		System.runAs(u) {
			createOpp2();
			createCustomSettings();
					
			SubmitForReopenCtrl controller = new SubmitForReopenCtrl();
			ApexPages.currentPage().getParameters().put('Id', newOpp.Id);
			controller.init();

			List<Opportunity> oppList = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
			System.assertEquals('Prospecting', oppList.get(0).StageName);

			controller.backToOpportunity();
		}
    }

    @future
	private static void createUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'API Only'];
		
		u = new User(
			ProfileId = p.Id,
			isActive = TRUE,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'kam',
			Email = 'manager.test@test.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'test',
			Lastname = 'test',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago');

		Database.insert(u);	   
	}

	private static void createOpp() {
		newOpp = new Opportunity(
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Anzahl_der_Karten__c = 5,
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Angebotsdauer__c = 'test',
			StageName = 'Closed Lost',
			Gruende_verloren__c = 'Refused Credit',
			Name = 'test opp',
			Product__c = 'None',
			Disable_for_KPI__c = FALSE,
			Credit_check_date__c = Date.today().addDays(-30),
			Last_Owner_Change_Date__c = Date.newinstance(2017, 12, 21),
			CloseDate = Date.newinstance(2017, 12, 28)
		);
		insert newOpp;
	}

	private static void createOpp2() {
		newOpp = new Opportunity(
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Anzahl_der_Karten__c = 5,
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Angebotsdauer__c = 'test',
			StageName = 'Closed Lost',
			Gruende_verloren__c = 'test',
			Name = 'test opp',
			Product__c = 'None',
			Disable_for_KPI__c = FALSE,
			Credit_check_date__c = Date.today().addDays(-30),
			Last_Owner_Change_Date__c = Date.newinstance(2017, 12, 21),
			CloseDate = Date.newinstance(2017, 12, 28)
		);
		insert newOpp;
	}

	private static void createCustomSettings() {
		customSettings = new Notifications_for_reopening_Opportunity__c(
            Name = 'Petr Cermak',
            Email__c = 'test@test.com',
            Active__c = true);
        insert customSettings;

        Submit_for_reopen_profiles__c reopenProfiles = new Submit_for_reopen_profiles__c(
        	Name = 'API Only');
        insert reopenProfiles;
	}
}