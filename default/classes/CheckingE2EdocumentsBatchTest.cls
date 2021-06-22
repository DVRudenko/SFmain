@isTest
private class CheckingE2EdocumentsBatchTest {
    @testSetup
    static void createE2Edata() {
    	String accRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1].Id;
    	String oppRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1].Id;
    	List<Account> accsToInsertList = new List<Account>();
    	List<Opportunity> oppsToInsertList = new List<Opportunity>();

    	Account accDE = new Account(
    		Name = 'test_acc_de',
            BillingCountry = 'Germany', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accDE);

		Account accAT = new Account(
    		Name = 'test_acc_at',
            BillingCountry = 'Austria', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accAT);

		Account accNL = new Account(
    		Name = 'test_acc_nl',
            BillingCountry = 'Netherlands', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accNL);

		Account accPL = new Account(
    		Name = 'test_acc_pl',
            BillingCountry = 'Poland', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accPL);

		Account accHU = new Account(
    		Name = 'test_acc_hu',
            BillingCountry = 'Hungary', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accHU);

		Account accFR = new Account(
    		Name = 'test_acc_fr',
            BillingCountry = 'France', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accFR);

		Account accBENL = new Account(
    		Name = 'test_acc_benl',
            BillingCountry = 'Belgium-NL', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accBENL);

		Account accBEFR = new Account(
    		Name = 'test_acc_befr',
            BillingCountry = 'Belgium-FR', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accBEFR);

		Account accCHDE = new Account(
    		Name = 'test_acc_chde',
            BillingCountry = 'Switzerland-DE', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accCHDE);

		Account accCHFR = new Account(
    		Name = 'test_acc_chfr',
            BillingCountry = 'Switzerland-FR', 
            RecordTypeId = accRecordTypeId, 
            Type = 'Customer', 
            E2E__c = true
		);
		accsToInsertList.add(accCHFR);
		insert accsToInsertList;


    	Opportunity opptyDE = new Opportunity(
            Name = 'test_opp_de',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accDE.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyDE);

		Opportunity opptyAT = new Opportunity(
            Name = 'test_opp_at',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accAT.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyAT);

		Opportunity opptyNL = new Opportunity(
            Name = 'test_opp_nl',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accNL.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyNL);

		Opportunity opptyPL = new Opportunity(
            Name = 'test_opp_pl',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accPL.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyPL);

		Opportunity opptyHU = new Opportunity(
            Name = 'test_opp_hu',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accHU.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyHU);

		Opportunity opptyFR = new Opportunity(
            Name = 'test_opp_fr',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accFR.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyFR);

		Opportunity opptyBENL = new Opportunity(
            Name = 'test_opp_benl',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accBENL.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyBENL);

		Opportunity opptyBEFR = new Opportunity(
            Name = 'test_opp_befr',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accBEFR.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyBEFR);

		Opportunity opptyCHDE = new Opportunity(
            Name = 'test_opp_chde',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accCHDE.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyCHDE);

		Opportunity opptyCHFR = new Opportunity(
            Name = 'test_opp_chfr',
            StageName = 'Prospecting',
            RecordTypeId = oppRecordTypeId,
            AccountId = accCHFR.Id,
            CloseDate = Date.today(),
            E2E__c = true,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Total_consumption_l_month__c = 1000,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Set total consumption'
		);
		oppsToInsertList.add(opptyCHFR);
		insert oppsToInsertList;
    }


    @isTest
    static void testCheckDocsOnFirstStep() {
    	Test.startTest();
            CheckingE2EdocumentsBatch batch = new CheckingE2EdocumentsBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }


    @isTest
    static void testCheckDocsOnSecondStep() {
    	Test.startTest();
            List<Opportunity> oppsList = [SELECT E2E_Active_Step__c, E2E_Active_Substep__c FROM Opportunity LIMIT 100];
            for (Opportunity opp : oppsList) {
            	opp.E2E_Active_Step__c = 2;
            	opp.E2E_Active_Substep__c = 'Card configuration';
            }
            update oppsList;
            CheckingE2EdocumentsBatch batch = new CheckingE2EdocumentsBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }


    @isTest
    static void testCheckDocsOnThirdStep() {
    	Test.startTest();
            List<Opportunity> oppsList = [SELECT Account.BillingCountry, E2E_Active_Step__c, E2E_Active_Substep__c FROM Opportunity LIMIT 100];
            for (Opportunity opp : oppsList) {
            	opp.E2E_Active_Step__c = 3;
            	if (opp.Account.BillingCountry == 'Germany' || opp.Account.BillingCountry == 'Austria' || opp.Account.BillingCountry == 'Netherlands' || 
            		opp.Account.BillingCountry == 'France' || opp.Account.BillingCountry == 'Belgium-NL' || opp.Account.BillingCountry == 'Belgium-FR' ||
            		opp.Account.BillingCountry == 'Switzerland-DE' || opp.Account.BillingCountry == 'Switzerland-FR') {
            		opp.E2E_Active_Substep__c = 'Additional services';
            	} else if (opp.Account.BillingCountry == 'Poland' || opp.Account.BillingCountry == 'Hungary') {
            		opp.E2E_Active_Substep__c = 'Documents';
            	}
            }
            update oppsList;
            CheckingE2EdocumentsBatch batch = new CheckingE2EdocumentsBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }


    @isTest
    static void testCheckDocsOnFourthStep() {
    	Test.startTest();
            List<Opportunity> oppsList = [SELECT E2E_Active_Step__c, E2E_Active_Substep__c FROM Opportunity LIMIT 100];
            for (Opportunity opp : oppsList) {
            	opp.E2E_Active_Step__c = 4;
            	opp.E2E_Active_Substep__c = 'DirectDebitDeposit';
            }
            update oppsList;
            CheckingE2EdocumentsBatch batch = new CheckingE2EdocumentsBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }


    @isTest
    static void testCheckDocsOnFifthStep() {
    	Test.startTest();
            List<Opportunity> oppsList = [SELECT E2E_Active_Step__c, E2E_Active_Substep__c FROM Opportunity LIMIT 100];
            for (Opportunity opp : oppsList) {
            	opp.E2E_Active_Step__c = 5;
            	opp.E2E_Active_Substep__c = 'Congratulations';
            }
            update oppsList;
            CheckingE2EdocumentsBatch batch = new CheckingE2EdocumentsBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }
}