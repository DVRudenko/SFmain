@isTest
private class CCSOrderTriggerHandlerTest {
    /*******************************************************************************
    *  Name            : testCheckOzNumberUpdateOwner()
    *  Summary         : test Check OZ number with data in custom settings Oz_number_checker__c .
    *  CreatedDate     : 23/03/2020
    *  ModifiedDate    : 07/07/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckOzNumberUpdateOwner() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];
        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_CZ' LIMIT 1][0].Id;
        String templateId2 = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_SK' LIMIT 1][0].Id;

        Oz_number_checker__c OZ = new Oz_number_checker__c(
                Name = 'TEST',
                OZ_Number__c = '123456789',
                UserId__c = User.get(0).Id);
        insert OZ;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today());
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = opportunity.id,
                RecordTypeId = LimitRecId,
                Update_from_Opportunity__c = 0,
                OZ_Number__c = '');
        insert ccsOrder;

        System.runAs(User.get(0)) {
            ccsOrder.OZ_Number__c = '123456789';
            ccsOrder.Additional_Order__c = true;
            update ccsOrder;

            opportunity.StageName = 'Closed Won';
            update opportunity;
        }

        System.runAs(User.get(0)) {
            ccsOrder.OZ_Number__c = '';
            update ccsOrder;
        }
    }

    /*******************************************************************************
    *  Name            : testUpdateLeadId()
    *  Summary         : Test update Lead__c on CCS_Order before insert.
    *  CreatedDate     : 01/07/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testUpdateLeadId() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        Oz_number_checker__c OZ = new Oz_number_checker__c(
                Name = 'TEST',
                OZ_Number__c = '123456789',
                UserId__c = User.get(0).Id);
        insert OZ;

        Lead lead = new Lead(
                Company = 'TEST INTERCODEC',
                FirstName = 'Test',
                LastName = 'Testuje',
                Status = 'Open',
                Phone = '+420123456789',
                Email = 'info@intercodec.cz',
                CCS_MerlinID__c = '12345',
                Agree_to_telephone_contact__c = true,
                Agree_to_receive_comm_info_by_email__c = true,
                Agree_to_process_pers_data_for_marketing__c = false,
                Produkt__c = 'CCS Limit',
                LeadSource = 'Web CCS (objednávka CCS Limit)',
                Sec_Channel__c = 'Inbound',
                Country = 'Czech Republic',
                Channel__c = 'web');
        insert lead;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                OZ_Number__c = '');
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                CCS_MerlinID__c = '12345',
                Opportunity__c = opportunity.id,
                RecordTypeId = LimitRecId,
                OZ_Number__c = '123456789',
                Update_from_Opportunity__c = 0,
                Additional_Order__c = true);
        insert ccsOrder;
    }


    /*******************************************************************************
    *  Name            : testSendOrderStageToMerlin()
    *  Summary         :
    *  CreatedDate     : 17/07/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSendOrderStageToMerlinSuccess() {


        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS System Administrator' AND UserRole.Name = 'Role Up' AND IsActive = true LIMIT 1];

        Oz_number_checker__c OZ = new Oz_number_checker__c(
                Name = 'TEST',
                OZ_Number__c = '123456789',
                UserId__c = User.get(0).Id);
        insert OZ;

        Merlin_Salesforce_Settings__c merlinCST = new Merlin_Salesforce_Settings__c(
                Name = 'Connection Settings',
                Hash__c = 'LNFCwoPtJXDmjKs0P%^Q!XsyohXJKVAScz7',
                Sandbox_Endpoint__c = 'https://develop-ccs.pixman.cz/sfApi/update',
                Production_Endpoint__c = 'https://ccs.cz/sfApi/update'
        );
        insert merlinCST;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                OZ_Number__c = '');
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                CCS_MerlinID__c = '12345',
                Opportunity__c = opportunity.id,
                RecordTypeId = LimitRecId,
                Update_from_Opportunity__c = 0,
                OZ_Number__c = '123456789');
        insert ccsOrder;
        Test.startTest();
        MerlinOrderStageHttpMockImpl mock = new MerlinOrderStageHttpMockImpl(200, 'Success', 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        CCS_Order__c orderToUpdate = [SELECT Id FROM CCS_Order__c WHERE Id = :ccsOrder.Id];
        orderToUpdate.Order_Stage__c = 'Nová';
        update orderToUpdate;

        String asd = CCSOrderTriggerHandler.getRandom();
        CCSOrderTriggerHandler.sendDataToMerlin('endpoint', 'merlinId', 'stage', 'status', 'email', 'datetime', 'digest');
        Test.stopTest();
    }

    /*******************************************************************************
    *  Name            : testUpdateOpportunityFromCCSOrder()
    *  Summary         : Test update Opportunity fields from CCS Order based on Custom Settings mapping.
    *  CreatedDate     : 21/07/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testUpdateOpportunityFromCCSOrder() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS System Administrator' AND UserRole.Name = 'Role Up' AND IsActive = true LIMIT 1];
        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_CZ' LIMIT 1][0].Id;
        String templateId2 = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_SK' LIMIT 1][0].Id;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Accident Insurance',
                CCS_Order_Field__c = 'Accident_Insurance__c	',
                Opportunity_Field__c = 'CCS_Accident_Insurance__c',
                Description__c = 'Mapping for Accident Insurance field.'
        );
        insert fieldMapping;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping2 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Additional Order',
                CCS_Order_Field__c = 'Additional_Order__c',
                Opportunity_Field__c = 'CCS_priobjednavka__c'
        );
        insert fieldMapping2;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping3 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Cribis',
                CCS_Order_Field__c = 'Cribis__c',
                Opportunity_Field__c = 'CCS_Cribis__c'
        );
        insert fieldMapping3;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping4 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Cribis Offer',
                CCS_Order_Field__c = 'Cribis_Offer__c',
                Opportunity_Field__c = 'Cribis_Offer__c'
        );
        insert fieldMapping4;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping5 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'GFN Number',
                CCS_Order_Field__c = 'GFN_Customer_Number__c',
                Opportunity_Field__c = 'CCS_GFN_number__c'
        );
        insert fieldMapping5;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping6 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Merlin ID',
                CCS_Order_Field__c = 'CCS_MerlinID__c',
                Opportunity_Field__c = 'CCS_MerlinID__c'
        );
        insert fieldMapping6;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping7 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Merlin Last Modified By',
                CCS_Order_Field__c = 'Merlin_Last_Modified_By__c',
                Opportunity_Field__c = 'Merlin_Last_Modified_By__c'
        );
        insert fieldMapping7;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping8 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Merlin License',
                CCS_Order_Field__c = 'Merlin_License__c',
                Opportunity_Field__c = 'Merlin_License__c'
        );
        insert fieldMapping8;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping9 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Merlin Partner',
                CCS_Order_Field__c = 'Merlin_Partner__c',
                Opportunity_Field__c = 'Merlin_Partner__c'
        );
        insert fieldMapping9;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping10 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Number of Cards',
                CCS_Order_Field__c = 'Number_of_Cards__c',
                Opportunity_Field__c = 'Anzahl_der_Karten__c'
        );
        insert fieldMapping10;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping11 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'Number of Vehicles',
                CCS_Order_Field__c = 'Number_of_Vehicles__c',
                Opportunity_Field__c = 'Number_of_Vehicles__c'
        );
        insert fieldMapping11;

        CCS_Order_Opportunity_Field_Mapping__c fieldMapping12 = new CCS_Order_Opportunity_Field_Mapping__c(
                Name = 'OZ Number',
                CCS_Order_Field__c = 'OZ_Number__c',
                Opportunity_Field__c = 'OZ_Number__c'
        );
        insert fieldMapping12;

        Merlin_Salesforce_Settings__c merlinCST = new Merlin_Salesforce_Settings__c(
                Name = 'Connection Settings',
                Hash__c = 'LNFCwoPtJXDmjKs0P%^Q!XsyohXJKVAScz7',
                Sandbox_Endpoint__c = 'https://develop-ccs.pixman.cz/sfApi/update',
                Production_Endpoint__c = 'https://ccs.cz/sfApi/update'
        );
        insert merlinCST;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                CCS_Cribis__c = '',
                CCS_Accident_Insurance__c = false,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                Welcome_Email_Sent_CCS__c = false,
                CloseDate = date.today());
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Account administrator');
        insert ocr;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = opportunity.id,
                Cribis__c = 'A',
                Accident_Insurance__c = false,
                RecordTypeId = LimitRecId,
                Order_Status__c = 'Objednáno',
                Order_Stage__c = 'Zadáno do systému',
                Additional_Order__c = false,
                Product__c = 'CCS Limit',
                Update_from_Opportunity__c = 0,
                Product_Country__c = 'CZ');
        insert ccsOrder;

        System.runAs(User.get(0)) {
            ccsOrder.Additional_Order__c = true;
            update ccsOrder;
        }

        Test.startTest();
        MerlinOrderStageHttpMockImpl mock = new MerlinOrderStageHttpMockImpl(200, 'Success', 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        CCS_Order__c orderToUpdate = [SELECT Id FROM CCS_Order__c WHERE Id = :ccsOrder.Id];
        orderToUpdate.Cribis__c = 'B';
        orderToUpdate.Accident_Insurance__c = true;
        update orderToUpdate;

        String asd = CCSOrderTriggerHandler.getRandom();
        CCSOrderTriggerHandler.sendDataToMerlin('endpoint', 'merlinId', 'stage', 'status', 'email', 'datetime', 'digest');
        Test.stopTest();
    }

    /*******************************************************************************
    *  Name            : testUpdateOpportunityStage()
    *  Summary         : Test update Opportunity Stage + other related fields from CCS Order based on Custom Settings mapping.
    *  CreatedDate     : 21/07/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testUpdateOpportunityStage() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS System Administrator' AND UserRole.Name = 'Role Up' AND IsActive = true LIMIT 1];

        CCS_Order_Opportunity_Stage_Mapping__c Stages = new CCS_Order_Opportunity_Stage_Mapping__c(
                Name = 'Nová',
                Order_Stage__c = 'Nová',
                StageName__c = 'Order entered');
        insert Stages;

        CCS_Order_Opportunity_Stage_Mapping__c Stages2 = new CCS_Order_Opportunity_Stage_Mapping__c(
                Name = 'Neschváleno-depozit-nedá',
                Order_Stage__c = 'Neschváleno-depozit-nedá',
                StageName__c = 'Closed Lost',
                Sub_Stage__c = 'Financial/Credit',
                Sub_Stage_Detail__c = 'Security/Deposit');
        insert Stages2;

        Merlin_Salesforce_Settings__c merlinCST = new Merlin_Salesforce_Settings__c(
                Name = 'Connection Settings',
                Hash__c = 'LNFCwoPtJXDmjKs0P%^Q!XsyohXJKVAScz7',
                Sandbox_Endpoint__c = 'https://develop-ccs.pixman.cz/sfApi/update',
                Production_Endpoint__c = 'https://ccs.cz/sfApi/update'
        );
        insert merlinCST;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                Welcome_Email_Sent_CCS__c = false,
                CloseDate = date.today());
        insert opportunity;

        Opportunity opportunity2 = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                Welcome_Email_Sent_CCS__c = false,
                CloseDate = date.today());
        insert opportunity2;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Account administrator');
        insert ocr;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = opportunity.id,
                RecordTypeId = LimitRecId,
                Order_Status__c = 'Objednáno',
                Order_Stage__c = 'Zadáno do systému',
                Additional_Order__c = false,
                Product__c = 'CCS Limit SK',
                Update_from_Opportunity__c = 0,
                Product_Country__c = 'SK');
        insert ccsOrder;

        CCS_Order__c ccsOrder2 = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = opportunity2.id,
                RecordTypeId = LimitRecId,
                Order_Status__c = 'Objednáno',
                Order_Stage__c = 'Zadáno do systému',
                Additional_Order__c = true,
                Product__c = 'CCS Limit SK',
                Update_from_Opportunity__c = 0,
                Product_Country__c = 'SK');
        insert ccsOrder2;

        Test.startTest();
        MerlinOrderStageHttpMockImpl mock = new MerlinOrderStageHttpMockImpl(200, 'Success', 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        CCS_Order__c orderToUpdate = [SELECT Id FROM CCS_Order__c WHERE Id = :ccsOrder.Id];
        orderToUpdate.Order_Stage__c = 'Neschváleno-depozit-nedá';
        update orderToUpdate;

        String asd = CCSOrderTriggerHandler.getRandom();
        CCSOrderTriggerHandler.sendDataToMerlin('endpoint', 'merlinId', 'stage', 'status', 'email', 'datetime', 'digest');
        Test.stopTest();
    }
}