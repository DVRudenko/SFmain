@isTest
private class Naumen_SupervisorPanelCtrlTest {
    @TestSetup
    static void makeData(){
        List <Naumen_Projects__c> naumenProjectSettings = new List <Naumen_Projects__c> {
            new Naumen_Projects__c(Name='testName1', Project_Label__c='testFullName1', Project_UUID__c='testUUID1'),
            new Naumen_Projects__c(Name='testName2', Project_Label__c='testFullName2', Project_UUID__c='testUUID2'),
            new Naumen_Projects__c(Name='testName3', Project_Label__c='testFullName3', Project_UUID__c='testUUID3'),
            new Naumen_Projects__c(Name='testName4', Project_Label__c='testFullName4', Project_UUID__c='testUUID4'),
            new Naumen_Projects__c(Name='testName5', Project_Label__c='testFullName5', Project_UUID__c='testUUID5')
        };
        insert naumenProjectSettings;
        List <Promo_Codes_Ru__c> naumenPromoCodesRu = new List <Promo_Codes_Ru__c> {
            new Promo_Codes_Ru__c(Name='001test')
        };
        insert naumenPromoCodesRu;
    }
    @isTest
    private static void testSearchRecords_Lead() {
        String naumenProjectUUID = 'testUUID1';
        String promocode = '001test';
        String statusName = 'Disqualified';
        String disqualReason = 'Other';
        String leadSource = 'Сайт Petrolplus.ru';
        String orgType = 'Education';
        Integer expectedVolume = 2;
        Double ratingFSNew = 1;
        Double ratingFS = 0.9;
        Lead lead = new Lead(
                LastName = 'testLead1', 
                Phone = '+79851110001', 
                Naumen_Autocall_Case_UUID__c = 'ocpcas00000000000n2m8r5hv5a2p7mk',
                Company = 'testLeadCompany1', 
                Email = 'testlead1@test.ru', 
                INN__C = '454545547888',
                Status = statusName,
                Lead_Status_Specific__c = disqualReason,
                Promo_Code1__c = promocode,
                Source_of_lead__c = leadSource,
                Organization_Type__c = orgType,
                Projected_Liters_month__c = expectedVolume,
                Rating_FS_New__c = ratingFSNew,
                Rating_FS__c = ratingFS,
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()
        );
        insert lead;

        Test.startTest();
            Naumen_SupervisorPanelCtrl ctrl = new Naumen_SupervisorPanelCtrl ();
            system.assert(ctrl.lead != null);
            system.assert(ctrl.opp != null);
            system.assert(ctrl.acc != null);
            system.assert(ctrl.sObjTypes != null);
            // get setup data
            system.assert(ctrl.lead != null);
            String optionsParamsJSON = '{"showLeadsData":true,"showOppsData":true}';
            Map<String,Object> result_setupData = Naumen_SupervisorPanelCtrl.getSetupData(optionsParamsJSON);
            Naumen_SupervisorPanelCtrl.SetupData setupData = (Naumen_SupervisorPanelCtrl.SetupData) result_setupData.get('setupData');
            system.assert(setupData.naumenProjects != null);
            system.assert(setupData.promocodes != null);
            system.assert(setupData.statuses != null);
            system.assert(setupData.regions != null);
            system.assert(setupData.leadSourses != null);
            // search leads by promocode
            String filtersJSON = '{"sObjTypes":["Lead"],"excludedNaumenProjects":[],"promocodes":["'+promocode+'"],"statuses":["'+statusName+'"],"disqualReasons":["'+disqualReason+'"],"leadSourses":["'+leadSource+'"],"orgTypes":["'+orgType+'"],"regions":[],"industries":[],"expectedVolume":'+expectedVolume+',"ratingFSNew":'+ratingFSNew+',"ratingFS":'+ratingFS+',"expectedVolume_from":null,"expectedVolume_to":null,"ratingFSNew_from":null,"ratingFSNew_to":null,"ratingFS_from":null,"ratingFS_to":null,"checkRecordAccess":false,"projectUUID":["'+naumenProjectUUID+'"]}';
            Map<String,Object> result0 = Naumen_SupervisorPanelCtrl.getPreviewData(filtersJSON);
            Map<String,Object> result1 = Naumen_SupervisorPanelCtrl.uploadToExcel(filtersJSON);
            Map<String,Object> result2 = Naumen_SupervisorPanelCtrl.uploadToNaumen(filtersJSON);
            system.assertEquals('ok', result0.get('status'));
            String tablesHTML = String.valueOf(result0.get('tablesHTML'));
            Integer numberOfRecords = tablesHTML.countMatches('<tr><td>');
            system.assertEquals(1, numberOfRecords); // 1 lead
            system.assertEquals('ok', result1.get('status'));
            system.assertEquals('ok', result2.get('status'));
        Test.stopTest();
    }

    @isTest
    private static void testSearchRecords_Opportunity() {
        String naumenProjectUUID = 'testUUID1';
        String stageName = 'Qualified Lead';
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account acc = new Account(
                Name = 'testAcc1', 
                BillingCountry = 'Russia',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        insert acc;
        Opportunity opp = new Opportunity (
                Name = 'testOpp1',
                AccountId = acc.Id,
                Naumen_Autocall_Case_UUID__c = 'ocpcas00000000000n2m8r5hv5a2p000',
                Number_of_Vehicles__c = 1,
                StageName = stageName,
                CloseDate = Date.today().addDays(10),
                Most_Important_Feature__c = 'Reporting',
                Area_Traveled__c = 'Regional',
                The_region__c = 'г. Санкт-Петербург',
                Travel_Pattern__c = 'Regular Route',
                Primary_Fueling_Method__c = 'Coupons',
                PPR_First_Contact_Inbound_Outbound__c = 'Inbound call',
                Source_of_Lead_o__c = 'Выставка',
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()
        );
        insert opp;
        Contact con = new Contact(
                LastName='testCon1', 
                AccountId = acc.Id,
                Phone = '+79873334445',
                MobilePhone = '+79017770002',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        Contact con_primary = new Contact(
                LastName='testCon1', 
                AccountId = acc.Id,
                Phone = '+79017770001',
                MobilePhone = '+79017770002',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        insert new List <Contact> {con, con_primary};

        OpportunityContactRole oppContactRole_primary = new OpportunityContactRole (
            ContactId = con_primary.Id,
            OpportunityId = opp.Id,
            Role = 'Decision Maker',
            IsPrimary = true
        );
        insert oppContactRole_primary;

        Test.startTest();
            Naumen_SupervisorPanelCtrl ctrl = new Naumen_SupervisorPanelCtrl ();
            system.assert(ctrl.lead != null);
            system.assert(ctrl.opp != null);
            system.assert(ctrl.acc != null);
            system.assert(ctrl.sObjTypes != null);
            // get setup data
            String optionsParamsJSON = '{"showLeadsData":true,"showOppsData":true}';
            Map<String,Object> result_setupData = Naumen_SupervisorPanelCtrl.getSetupData(optionsParamsJSON);
            Naumen_SupervisorPanelCtrl.SetupData setupData = (Naumen_SupervisorPanelCtrl.SetupData) result_setupData.get('setupData');
            system.assert(setupData.naumenProjects != null);
            system.assert(setupData.promocodes != null);
            system.assert(setupData.statuses != null);
            system.assert(setupData.regions != null);
            system.assert(setupData.leadSourses != null);
            // search opportunities by stageName
            String filtersJSON = '{"sObjTypes":["Opportunity"],"excludedNaumenProjects":[],"promocodes":[],"statuses":["'+stageName+'"],"disqualReasons":[],"leadSourses":[],"orgTypes":[],"regions":[],"industries":[],"expectedVolume":null,"ratingFSNew":null,"ratingFS":null,"expectedVolume_from":null,"expectedVolume_to":null,"ratingFSNew_from":null,"ratingFSNew_to":null,"ratingFS_from":null,"ratingFS_to":null,"checkRecordAccess":false,"projectUUID":["'+naumenProjectUUID+'"]}';
            Map<String,Object> result0 = Naumen_SupervisorPanelCtrl.getPreviewData(filtersJSON);
            Map<String,Object> result1 = Naumen_SupervisorPanelCtrl.uploadToExcel(filtersJSON);
            Map<String,Object> result2 = Naumen_SupervisorPanelCtrl.uploadToNaumen(filtersJSON);
            system.assertEquals('ok', result0.get('status'));
            String tablesHTML = String.valueOf(result0.get('tablesHTML'));
            Integer numberOfRecords = tablesHTML.countMatches('<tr><td>');
            system.assertEquals(1, numberOfRecords); // 1 opportunity
            system.assertEquals('ok', result1.get('status'));
            system.assertEquals('ok', result2.get('status'));
        Test.stopTest();
    }
    @isTest
    private static void testSearchRecords_LeadAndOpportunity() {
        String naumenProjectUUID = 'testUUID1';
        String industryName = 'Consulting';
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Lead lead = new Lead(
                LastName = 'testLead1', 
                Phone = '+79851110001', 
                Naumen_Autocall_Case_UUID__c = 'ocpcas00000000000n2m8r5hv5a2p7mk',
                Company = 'testLeadCompany1', 
                Email = 'testlead1@test.ru', 
                INN__C = '1234567899999',
                Source_of_lead__c = 'Сайт Petrolplus.ru',
                Industry = industryName,
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()
        );
        insert lead;
        Account acc = new Account(
                Name = 'testAcc1', 
                BillingCountry = 'Russia',
                Industry = industryName,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        insert acc;
        Opportunity opp = new Opportunity (
                Name = 'testOpp1',
                AccountId = acc.Id,
                Naumen_Autocall_Case_UUID__c = 'ocpcas00000000000n2m8r5hv5a2p000',
                Number_of_Vehicles__c = 1,
                StageName = 'Qualified Lead',
                CloseDate = Date.today().addDays(10),
                Most_Important_Feature__c = 'Reporting',
                Area_Traveled__c = 'Regional',
                The_region__c = 'г. Санкт-Петербург',
                Travel_Pattern__c = 'Regular Route',
                Primary_Fueling_Method__c = 'Coupons',
                PPR_First_Contact_Inbound_Outbound__c = 'Inbound call',
                Source_of_Lead_o__c = 'Выставка',
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()
        );
        insert opp;
        Contact con = new Contact(
                LastName='testCon1', 
                AccountId = acc.Id,
                Phone = '+79873334445',
                MobilePhone = '+79017770002',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        Contact con_primary = new Contact(
                LastName='testCon1', 
                AccountId = acc.Id,
                Phone = '+79017770001',
                MobilePhone = '+79017770002',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        insert new List <Contact> {con, con_primary};

        OpportunityContactRole oppContactRole_primary = new OpportunityContactRole (
            ContactId = con_primary.Id,
            OpportunityId = opp.Id,
            Role = 'Decision Maker',
            IsPrimary = true
        );
        insert oppContactRole_primary;

        Test.startTest();
            Naumen_SupervisorPanelCtrl ctrl = new Naumen_SupervisorPanelCtrl ();
            system.assert(ctrl.sObjTypes != null);
            // get setup data
            String optionsParamsJSON = '{"showLeadsData":true,"showOppsData":true}';
            Map<String,Object> result_setupData = Naumen_SupervisorPanelCtrl.getSetupData(optionsParamsJSON);
            Naumen_SupervisorPanelCtrl.SetupData setupData = (Naumen_SupervisorPanelCtrl.SetupData) result_setupData.get('setupData');
            system.assert(setupData.naumenProjects != null);
            system.assert(setupData.promocodes != null);
            system.assert(setupData.statuses != null);
            system.assert(setupData.regions != null);
            system.assert(setupData.leadSourses != null);
            // search leads and opportunities by Industry
            String filtersJSON = '{"sObjTypes":["Lead","Opportunity"],"excludedNaumenProjects":[],"promocodes":[],"statuses":[],"disqualReasons":[],"leadSourses":[],"orgTypes":[],"regions":[],"industries":["'+industryName+'"],"expectedVolume":null,"ratingFSNew":null,"ratingFS":null,"checkRecordAccess":false,"projectUUID":["'+naumenProjectUUID+'"]}';
            Map<String,Object> result0 = Naumen_SupervisorPanelCtrl.getPreviewData(filtersJSON);
            Map<String,Object> result1 = Naumen_SupervisorPanelCtrl.uploadToExcel(filtersJSON);
            Map<String,Object> result2 = Naumen_SupervisorPanelCtrl.uploadToNaumen(filtersJSON);
            system.assertEquals('ok', result0.get('status'));
            String tablesHTML = String.valueOf(result0.get('tablesHTML'));
            Integer numberOfRecords = tablesHTML.countMatches('<tr><td>');
            system.assertEquals(2, numberOfRecords); // 1 lead + 1 opportunity
            system.assertEquals('ok', result1.get('status'));
            system.assertEquals('ok', result2.get('status'));
        Test.stopTest();
    }
    @isTest
    private static void testSearchRecords_NoRecords() {
        String naumenProjectUUID = 'testUUID1';
        String industryName = 'Consulting';
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Lead lead = new Lead(
                LastName = 'testLead1', 
                Phone = '+79851110001', 
                Naumen_Autocall_Case_UUID__c = 'ocpcas00000000000n2m8r5hv5a2p7mk',
                Company = 'testLeadCompany1', 
                Email = 'testlead1@test.ru', 
                INN__C = '1234567899999',
                Source_of_lead__c = 'Сайт Petrolplus.ru',
                Industry = 'Banking',
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()
        );
        insert lead;
        Account acc = new Account(
                Name = 'testAcc1', 
                BillingCountry = 'Russia',
                Industry = 'Banking',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        insert acc;
        Opportunity opp = new Opportunity (
                Name = 'testOpp1',
                AccountId = acc.Id,
                Naumen_Autocall_Case_UUID__c = 'ocpcas00000000000n2m8r5hv5a2p000',
                Number_of_Vehicles__c = 1,
                StageName = 'Qualified Lead',
                CloseDate = Date.today().addDays(10),
                Most_Important_Feature__c = 'Reporting',
                Area_Traveled__c = 'Regional',
                The_region__c = 'г. Санкт-Петербург',
                Travel_Pattern__c = 'Regular Route',
                Primary_Fueling_Method__c = 'Coupons',
                PPR_First_Contact_Inbound_Outbound__c = 'Inbound call',
                Source_of_Lead_o__c = 'Выставка',
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()
        );
        insert opp;
        Contact con = new Contact(
                LastName='testCon1', 
                AccountId = acc.Id,
                Phone = '+79873334445',
                MobilePhone = '+79017770002',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        Contact con_primary = new Contact(
                LastName='testCon1', 
                AccountId = acc.Id,
                Phone = '+79017770001',
                MobilePhone = '+79017770002',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        insert new List <Contact> {con, con_primary};

        OpportunityContactRole oppContactRole_primary = new OpportunityContactRole (
            ContactId = con_primary.Id,
            OpportunityId = opp.Id,
            Role = 'Decision Maker',
            IsPrimary = true
        );
        insert oppContactRole_primary;

        Test.startTest();
            Naumen_SupervisorPanelCtrl ctrl = new Naumen_SupervisorPanelCtrl ();
            system.assert(ctrl.sObjTypes != null);
            // get setup data
            String optionsParamsJSON = '{"showLeadsData":true,"showOppsData":true}';
            Map<String,Object> result_setupData = Naumen_SupervisorPanelCtrl.getSetupData(optionsParamsJSON);
            Naumen_SupervisorPanelCtrl.SetupData setupData = (Naumen_SupervisorPanelCtrl.SetupData) result_setupData.get('setupData');
            system.assert(setupData.naumenProjects != null);
            system.assert(setupData.promocodes != null);
            system.assert(setupData.statuses != null);
            system.assert(setupData.regions != null);
            system.assert(setupData.leadSourses != null);
            // search leads and opportunities by Industry - no records found
            String filtersJSON = '{"sObjTypes":["Lead","Opportunity"],"excludedNaumenProjects":[],"promocodes":[],"statuses":[],"disqualReasons":[],"leadSourses":[],"orgTypes":[],"regions":[],"industries":["'+industryName+'"],"expectedVolume":null,"ratingFSNew":null,"ratingFS":null,"expectedVolume_from":null,"expectedVolume_to":null,"ratingFSNew_from":null,"ratingFSNew_to":null,"ratingFS_from":null,"ratingFS_to":null,"checkRecordAccess":false,"projectUUID":["'+naumenProjectUUID+'"]}';
            Map<String,Object> result0 = Naumen_SupervisorPanelCtrl.getPreviewData(filtersJSON);
            Map<String,Object> result1 = Naumen_SupervisorPanelCtrl.uploadToExcel(filtersJSON);
            Map<String,Object> result2 = Naumen_SupervisorPanelCtrl.uploadToNaumen(filtersJSON);
            system.assertEquals('ok', result0.get('status'));
            String tablesHTML = String.valueOf(result0.get('tablesHTML'));
            Integer numberOfRecords = tablesHTML.countMatches('<tr><td>');
            system.assertEquals(0, numberOfRecords); // no records
            system.assertEquals('error', result1.get('status'));
            system.assertEquals('ok', result2.get('status')); // we run batch when there are no records found because we don't know the number of records before running it
        Test.stopTest();
    }
}