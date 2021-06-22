@isTest
public with sharing class CreditFactoryReportTriggerHandlerTest {
    private static Id RUSSIAN_CREDIT_CHEK_RT_ID = Schema.SObjectType.Credit_Factory_Report__c.getRecordTypeInfosByDeveloperName()
        .get('Russian_credit_check')
        .getRecordTypeId();
    private static Id MASTER_RT_ID = Schema.SObjectType.Credit_Factory_Report__c.getRecordTypeInfosByDeveloperName()
        .get('Default')
        .getRecordTypeId();    
    private static final string TEST_ACC_NAME = 'CFR_Accoiunt';
    private static final string TEST_OPP_ONE_NAME = 'CFR_Oppotunity';
    private static final string TEST_OPP_SECOND_NAME = 'CFR_Oppotunity2';

    @TestSetup
    static void makeData() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.Name = TEST_ACC_NAME;
        insert account;

        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.Name = TEST_OPP_ONE_NAME;
        Opportunity opportunitySecond = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunitySecond.Name = TEST_OPP_SECOND_NAME;
        insert new List<Opportunity>{ opportunity, opportunitySecond };
    }

    @IsTest
    static void testSetClientChoice_MissEntryLogic() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name =: TEST_OPP_ONE_NAME];
        Credit_Factory_Report__c cfrRecordSelected = fillCfrRecord(opportunity.Id, MASTER_RT_ID, true);
        Credit_Factory_Report__c cfrRecordSelectedToo = fillCfrRecord(opportunity.Id, MASTER_RT_ID, true);
        insert new List<Credit_Factory_Report__c>{ cfrRecordSelected, cfrRecordSelectedToo };

        List<Credit_Factory_Report__c> insertedRecords = [
            SELECT RU_Client_choice__c
            FROM Credit_Factory_Report__c
            WHERE Id = :cfrRecordSelected.Id OR Id = :cfrRecordSelectedToo.Id
        ];

        for (Credit_Factory_Report__c cfrRecord : insertedRecords) {
            System.assert(cfrRecord.RU_Client_choice__c);
        }
    }

    @IsTest
    static void testSetClientChoice_DifferentOpps() {
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Name =: TEST_OPP_ONE_NAME OR Name =: TEST_OPP_SECOND_NAME];
        Credit_Factory_Report__c cfrRecordSelected = fillCfrRecord(opportunities.get(0).Id, RUSSIAN_CREDIT_CHEK_RT_ID, true);
        Credit_Factory_Report__c cfrRecordSelectedOpp2 = fillCfrRecord(opportunities.get(1).Id, RUSSIAN_CREDIT_CHEK_RT_ID, true);
        insert new List<Credit_Factory_Report__c>{ cfrRecordSelected, cfrRecordSelectedOpp2 };

        List<Credit_Factory_Report__c> insertedRecords = [
            SELECT RU_Client_choice__c
            FROM Credit_Factory_Report__c
            WHERE Id = :cfrRecordSelectedOpp2.Id
        ];

        System.assert(insertedRecords.get(0).RU_Client_choice__c);
    }

    @IsTest
    static void testSetClientChoice_SameOpps() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name =: TEST_OPP_ONE_NAME];
        Credit_Factory_Report__c cfrRecordSelected = fillCfrRecord(opportunity.Id, RUSSIAN_CREDIT_CHEK_RT_ID, true);
        Credit_Factory_Report__c cfrRecordSelected2 = fillCfrRecord(opportunity.Id, RUSSIAN_CREDIT_CHEK_RT_ID, false);
        insert new List<Credit_Factory_Report__c>{ cfrRecordSelected, cfrRecordSelected2 };

        cfrRecordSelected2.RU_Client_choice__c = true;
        update cfrRecordSelected2;

        cfrRecordSelected = [SELECT RU_Client_choice__c FROM Credit_Factory_Report__c WHERE Id = :cfrRecordSelected.Id];
        System.assertEquals(false, cfrRecordSelected.RU_Client_choice__c);

        Credit_Factory_Report__c cfrRecordSelected3 = fillCfrRecord(opportunity.Id, RUSSIAN_CREDIT_CHEK_RT_ID, false);
        insert cfrRecordSelected3;

        cfrRecordSelected2 = [SELECT RU_Client_choice__c FROM Credit_Factory_Report__c WHERE Id = :cfrRecordSelected2.Id];
        System.assertEquals(true, cfrRecordSelected2.RU_Client_choice__c);
    }

    @IsTest
    static void testSetClientChoice_Undelete() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name =: TEST_OPP_ONE_NAME];
        Credit_Factory_Report__c cfrRecordSelected = fillCfrRecord(opportunity.Id, RUSSIAN_CREDIT_CHEK_RT_ID, true); 
        Credit_Factory_Report__c cfrRecordSelected2 = fillCfrRecord(opportunity.Id, RUSSIAN_CREDIT_CHEK_RT_ID, true);
        insert new List<Credit_Factory_Report__c>{ cfrRecordSelected, cfrRecordSelected2 };
        delete cfrRecordSelected2;
        undelete cfrRecordSelected2;

        cfrRecordSelected = [SELECT RU_Client_choice__c FROM Credit_Factory_Report__c WHERE Id = :cfrRecordSelected.Id];

        System.assertEquals(false, cfrRecordSelected.RU_Client_choice__c);
    }

    @IsTest
    static void testSetClientChoice_DisableCheck() {
        CreditFactoryReportTriggerHandler.triggerEnabled = false;
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name =: TEST_OPP_ONE_NAME];
        Credit_Factory_Report__c cfrRecordSelected = fillCfrRecord(opportunity.Id, RUSSIAN_CREDIT_CHEK_RT_ID, true); 
        Credit_Factory_Report__c cfrRecordSelected2 = fillCfrRecord(opportunity.Id, RUSSIAN_CREDIT_CHEK_RT_ID, true);
        insert new List<Credit_Factory_Report__c>{ cfrRecordSelected, cfrRecordSelected2 };
        delete cfrRecordSelected2;
        undelete cfrRecordSelected2;

        cfrRecordSelected = [SELECT RU_Client_choice__c FROM Credit_Factory_Report__c WHERE Id = :cfrRecordSelected.Id];

        System.assert(cfrRecordSelected.RU_Client_choice__c);
    }

    @IsTest
    static void testSetClientChoice_SkipNullOppId() {
        Credit_Factory_Report__c cfrRecordSelected = fillCfrRecord(null, RUSSIAN_CREDIT_CHEK_RT_ID, true); 
        Credit_Factory_Report__c cfrRecordSelected2 = fillCfrRecord(null, RUSSIAN_CREDIT_CHEK_RT_ID, true);
        insert cfrRecordSelected;
        // separate insert for checking trigger choice logic
        insert cfrRecordSelected2;

        cfrRecordSelected = [SELECT RU_Client_choice__c FROM Credit_Factory_Report__c WHERE Id = :cfrRecordSelected.Id];

        System.assert(cfrRecordSelected.RU_Client_choice__c);
    }

    private static Credit_Factory_Report__c fillCfrRecord(Id opportunityId, Id recordTypeId, Boolean clientChoise) {
        Credit_Factory_Report__c cfrRecord = CreditFactoryUtils.createCreditsafeReport();
        cfrRecord.RecordTypeId = recordTypeId;
        cfrRecord.Opportunity__c = opportunityId;
        cfrRecord.RU_Client_choice__c = clientChoise;

        return cfrRecord;
    }
}