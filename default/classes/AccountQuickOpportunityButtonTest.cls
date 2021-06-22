/**
 * Created by marekhaken on 14.04.2021.
 */

@IsTest
private class AccountQuickOpportunityButtonTest {
    @IsTest
    static void testBehavior() {
        Account acc = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert acc;
        String userId = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1].Id;

        String accRecName = [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id = :acc.Id].RecordType.DeveloperName;
        RecordType rec = [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1];

        List<Config_for_Account_Quick_Opportunity__c> config = new List<Config_for_Account_Quick_Opportunity__c>();

        Config_for_Account_Quick_Opportunity__c c1 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'Name',
                Opp_Field_Value_Acc_Field_Mapping__c = 'Name+" CARNET 2021"',
                Scenario_Description__c = 'Popis scénáře',
                Name = 'a1'
        );
        config.add(c1);

        Config_for_Account_Quick_Opportunity__c c2 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'StageName',
                Opp_Field_Value_Acc_Field_Mapping__c = '"CreditCheck"',
                Name = 'a2'
        );
        config.add(c2);

        Config_for_Account_Quick_Opportunity__c c3 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'CloseDate',
                Opp_Field_Value_Acc_Field_Mapping__c = '+88',
                Name = 'a3'
        );
        config.add(c3);

        Config_for_Account_Quick_Opportunity__c c4 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'Angebotsdauer__c',
                Opp_Field_Value_Acc_Field_Mapping__c = '"3 Monate"',
                Name = 'a4'
        );
        config.add(c4);

        Config_for_Account_Quick_Opportunity__c c5 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'Product__c',
                Opp_Field_Value_Acc_Field_Mapping__c = '"None"',
                Name = 'a5'
        );
        config.add(c5);

        Config_for_Account_Quick_Opportunity__c c6 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'Zahlungsziel__c',
                Opp_Field_Value_Acc_Field_Mapping__c = '"7"',
                Name = 'a6'
        );
        config.add(c6);

        Config_for_Account_Quick_Opportunity__c c7 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'Anzahl_der_Karten__c',
                Opp_Field_Value_Acc_Field_Mapping__c = '"5"',
                Name = 'a7'
        );
        config.add(c7);


        Config_for_Account_Quick_Opportunity__c c8 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'Zahlungsart__c',
                Opp_Field_Value_Acc_Field_Mapping__c = '"Lastschrift"',
                Name = 'a8'
        );
        config.add(c8);

        Config_for_Account_Quick_Opportunity__c c9 = new Config_for_Account_Quick_Opportunity__c(
                Scenario_Name__c = 'Scénář 1',
                Active__c = true,
                Opportunity_Record_Type_Developer_Name__c = rec.DeveloperName,
                Account_Record_Type_Developer_Name__c = accRecName,
                Opportunity_Field_API_Name__c = 'OwnerId',
                Opp_Field_Value_Acc_Field_Mapping__c = '"'+userId+'"',
                Name = 'a9'
        );
        config.add(c9);

        insert config;


        List<AccountQuickOpportunityButtonController.FieldInfo> fif = new List<AccountQuickOpportunityButtonController.FieldInfo>();
        AccountQuickOpportunityButtonController.FieldInfo f = new AccountQuickOpportunityButtonController.FieldInfo();
        f.value = rec.Id;
        f.fieldName = 'RecordTypeId';
        fif.add(f);

        AccountQuickOpportunityButtonController.FieldInfo f1 = new AccountQuickOpportunityButtonController.FieldInfo();
        f1.value = acc.Id;
        f1.fieldName = 'AccountId';
        fif.add(f1);

        AccountQuickOpportunityButtonController.FieldInfo f2 = new AccountQuickOpportunityButtonController.FieldInfo();
        f2.value = String.valueOf(Date.today()+88);
        f2.fieldName = 'CloseDate';
        fif.add(f2);

        AccountQuickOpportunityButtonController.FieldInfo f3 = new AccountQuickOpportunityButtonController.FieldInfo();
        f3.value = '3 Monate';
        f3.fieldName = 'Angebotsdauer__c';
        fif.add(f3);

        AccountQuickOpportunityButtonController.FieldInfo f4 = new AccountQuickOpportunityButtonController.FieldInfo();
        f4.value = 'Test Opportunity';
        f4.fieldName = 'Name';
        fif.add(f4);

        AccountQuickOpportunityButtonController.FieldInfo f5 = new AccountQuickOpportunityButtonController.FieldInfo();
        f5.value = 'None';
        f5.fieldName = 'Product__c';
        fif.add(f5);

        AccountQuickOpportunityButtonController.FieldInfo f6 = new AccountQuickOpportunityButtonController.FieldInfo();
        f6.value = 'CreditCheck';
        f6.fieldName = 'StageName';
        fif.add(f6);

        AccountQuickOpportunityButtonController.FieldInfo f7 = new AccountQuickOpportunityButtonController.FieldInfo();
        f7.value = '7';
        f7.fieldName = 'Zahlungsziel__c';
        fif.add(f7);

        AccountQuickOpportunityButtonController.FieldInfo f8 = new AccountQuickOpportunityButtonController.FieldInfo();
        f8.value = 'Lastschrift';
        f8.fieldName = 'Zahlungsart__c';
        fif.add(f8);

        AccountQuickOpportunityButtonController.getAvailableOptions(acc.Id, userId);
        String oppId = AccountQuickOpportunityButtonController.insertOpportunity(JSON.serialize(fif), 'Scénář 1');
    }
}