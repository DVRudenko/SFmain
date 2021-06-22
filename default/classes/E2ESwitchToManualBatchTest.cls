@isTest
private class E2ESwitchToManualBatchTest {
    @testSetup
    static void createData() {
        Opportunity opportunity = createOpportunity();
        insert opportunity;

        Emarsys_Log__c emarsysLog = createEmarsysLog('E2E Abandonment Email DE 3', opportunity.Id);
        insert emarsysLog;

        E2E_Switched_to_Manual_Templates__c settings = createCustomSettings('E2E Abandonment Email DE 3');
        insert settings;
    }

	@isTest
    static void switchToManualAbandonmentEmailTest() {
	    Test.startTest();
	        E2ESwitchToManualBatch batch = new E2ESwitchToManualBatch();
	    	Database.executeBatch(batch);
    	Test.stopTest();

    	List<Opportunity> oppList = [SELECT E2E_Sub_Status__c, E2E_Sales_Type__c FROM Opportunity];
    	System.assertEquals('Switched to manual', oppList.get(0).E2E_Sub_Status__c);
    	System.assertEquals('E2E downgraded to manual', oppList.get(0).E2E_Sales_Type__c);
    }
    

    @isTest
    static void switchToManualSaveContinueTest() {
        List<Emarsys_Log__c> oppToUpdateList = [SELECT Email_Name__c FROM Emarsys_Log__c];
        oppToUpdateList.get(0).Email_Name__c = 'E2E Save And Continue 3';
        update oppToUpdateList;

        List<E2E_Switched_to_Manual_Templates__c> settingsList = [SELECT Name FROM E2E_Switched_to_Manual_Templates__c];
        settingsList.get(0).Name = 'E2E Save And Continue 3';
        update settingsList;

        Test.startTest();
            E2ESwitchToManualBatch batch = new E2ESwitchToManualBatch();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Opportunity> oppList = [SELECT E2E_Sub_Status__c, E2E_Sales_Type__c FROM Opportunity];
        System.assertEquals('Switched to manual', oppList.get(0).E2E_Sub_Status__c);
        System.assertEquals('E2E downgraded to manual', oppList.get(0).E2E_Sales_Type__c);
    }


    @isTest
    static void switchToManualProcessedOpportunityTest() {
        List<Opportunity> oppToUpdateList = [SELECT StageName, Number_of_open_tasks__c FROM Opportunity];
        oppToUpdateList.get(0).StageName = 'Follow up';
        oppToUpdateList.get(0).Number_of_open_tasks__c = 1;
        update oppToUpdateList;

        List<E2E_Switched_to_Manual_Templates__c> settingsList = [SELECT Name FROM E2E_Switched_to_Manual_Templates__c];
        settingsList.get(0).Name = 'E2E Abandonment Email DE 1';
        update settingsList;

        Test.startTest();
            E2ESwitchToManualBatch batch = new E2ESwitchToManualBatch();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Opportunity> oppList = [SELECT E2E_Sub_Status__c, E2E_Sales_Type__c FROM Opportunity];
        System.assertEquals('Switched to manual', oppList.get(0).E2E_Sub_Status__c);
        System.assertEquals('E2E downgraded to manual', oppList.get(0).E2E_Sales_Type__c);
    }


	private static Opportunity createOpportunity() {
		Opportunity newOpp = new Opportunity(
            StageName = 'Prospecting',
            Name = 'test opp',
            E2E__c = true,
            E2E_Status__c = 'Abandoned (hard)',
            E2E_Sub_Status__c = 'Marketing automation',
            CloseDate = Date.today()
		);
		return newOpp;
	}


    private static Emarsys_Log__c createEmarsysLog(String emarsysLogName, String opportunityId) {
        Emarsys_Log__c testLog = new Emarsys_Log__c(
            Email_Name__c = emarsysLogName,
            Opportunity__c = opportunityId
        );
        return testLog;
    }


    private static E2E_Switched_to_Manual_Templates__c createCustomSettings(String abandonmentEmailName) {
        E2E_Switched_to_Manual_Templates__c setting = new E2E_Switched_to_Manual_Templates__c(
            Name = abandonmentEmailName
        );
        return setting;
    }
}