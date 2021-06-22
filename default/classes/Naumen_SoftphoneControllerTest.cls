@isTest
private class Naumen_SoftphoneControllerTest {

    @isTest
    private static void mainTest_Lead() {
        Lead lead = new Lead(
                LastName = 'testLead1', 
                Phone = '+79851110001', 
                Naumen_Autocall_Case_UUID__c = 'ocpcas00000000000n2m8r5hv5a2p7mk',
                Company = 'testLeadCompany1', 
                Email = 'testlead1@test.ru', 
                INN__C = '1234567899999',
                Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()
        );
        insert lead;

        Test.startTest();
            Map <String, Object> result;
            String recordId;
            String recordNaumenUUID;
            String phoneNumber;
            String callDataJSON;
        // test lead
            recordId = lead.Id;
            recordNaumenUUID = lead.Naumen_Autocall_Case_UUID__c;
            phoneNumber = lead.Phone;
            // get record
            result = Naumen_SoftphoneController.getRecord (recordNaumenUUID, phoneNumber);
            system.assertEquals('ok', String.valueOf(result.get('status')));
            Naumen_RecordsHelper.LeadWrap recordResult = (Naumen_RecordsHelper.LeadWrap) result.get('record');
            system.assertEquals(recordId, recordResult.recordId);
            system.assertEquals(recordId, recordResult.callCustomerId);
           /* not used now since we use naumen softphone on ccspeedup page only 
            // save call data
            callDataJSON = '{"recordId":"' + recordId + '","phoneNumber":"' + phoneNumber + '"}';
            result = Naumen_SoftphoneController.saveCallData (callDataJSON);
            system.assertEquals('ok', String.valueOf(result.get('status')));
            */
        Test.stopTest();
    }

    @isTest
    private static void mainTest_Opportunity() {
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
        String con_extensionNumber = '4445';
        Contact con = new Contact(
                LastName='testCon1', 
                AccountId = acc.Id,
                Phone = '+7987 3334 445' + '# ' + con_extensionNumber,
                MobilePhone = '+79017770002',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
        );
        Contact con_primary = new Contact(
                LastName='testConPrimary', 
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
            Map <String, Object> result;
            String recordId;
            String mainContactId;
            String callContactId;
            String recordNaumenUUID;
            String phoneNumber;
            String callDataJSON;
        // 1) test contact without contact role
            recordId = opp.Id;
            mainContactId = con_primary.Id;
            callContactId = con.Id;
            recordNaumenUUID = opp.Naumen_Autocall_Case_UUID__c;
            phoneNumber = con.Phone;     
            // get record
            result = Naumen_SoftphoneController.getRecord (recordNaumenUUID, phoneNumber);
            system.assertEquals('ok', String.valueOf(result.get('status')));
            Naumen_RecordsHelper.OpportunityWrap recordResult = (Naumen_RecordsHelper.OpportunityWrap) result.get('record');
            system.assertEquals(recordId, recordResult.recordId);
            system.assertEquals(mainContactId, recordResult.mainContactId);
            system.assertEquals(callContactId, recordResult.callCustomerId);
            system.assertEquals(con_extensionNumber, recordResult.extensionNumber);
            /* not used now since we use naumen softphone on ccspeedup page only
            // save call data
            callDataJSON = '{"recordId":"' + recordId + '","phoneNumber":"' + phoneNumber + '"}';
            result = Naumen_SoftphoneController.saveCallData (callDataJSON);
            system.assertEquals('ok', String.valueOf(result.get('status')));
            */

        // 2) test contact with primary contact role
            recordId = opp.Id;
            mainContactId = con_primary.Id;
            callContactId = con_primary.Id;
            recordNaumenUUID = opp.Naumen_Autocall_Case_UUID__c;
            phoneNumber = con_primary.MobilePhone;
            // get record
            result = Naumen_SoftphoneController.getRecord (recordNaumenUUID, phoneNumber);
            system.assertEquals('ok', String.valueOf(result.get('status')));
            Naumen_RecordsHelper.OpportunityWrap recordResult_primaryCon = (Naumen_RecordsHelper.OpportunityWrap) result.get('record');
            system.assertEquals(recordId, recordResult_primaryCon.recordId);
            system.assertEquals(mainContactId, recordResult_primaryCon.mainContactId);
            system.assertEquals(callContactId, recordResult_primaryCon.callCustomerId);
            system.assertEquals('', recordResult_primaryCon.extensionNumber);
            // set contact as a call customer
            Map<String,Object> setCallCustomerResult = Naumen_SoftphoneController.setCallCustomer(con.Id, con.Phone);
            system.assertEquals('ok', setCallCustomerResult.get('status'));
            Naumen_RecordsHelper.ContactWrap callCustomerWrap = (Naumen_RecordsHelper.ContactWrap) setCallCustomerResult.get('callCustomer');
            system.assertEquals('Phone', callCustomerWrap.phoneFieldAPI);
            system.assertEquals(con_extensionNumber, callCustomerWrap.extensionNumber);
            /* not used now since we use naumen softphone on ccspeedup page only
            // save call data
            callDataJSON = '{"recordId":"' + recordId + '","phoneNumber":"' + phoneNumber + '"}';
            result = Naumen_SoftphoneController.saveCallData (callDataJSON);
            system.assertEquals('ok', String.valueOf(result.get('status')));
            */
        Test.stopTest();
    }
}