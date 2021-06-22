@isTest
private class LeadConversionCtrlTest {
    public static EmailTemplate emailTeamplate;
    public static Lead newlead;
    public static User u;
    public static Lead duplicateLead;
    public static Account duplicateAccount;
    public static Opportunity duplicateOpportnunity;
    public static Contact duplicateContact;

	/*******************************************************************************
	*  Name            : testConvertLead()
	*  Summary         : test lead conversion if all required fields are filled, assigns tasks
    					from lead to opportunity
	*  CreatedDate     : 14/04/2017
    *  ModifiedDate    : 02/04/2018
	*  Parameters      :
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testConvertLead() {
        createUser();

        System.runAs(u) {
            createLead();
            createEmailTemplate();

        	Task task = new Task(
        		WhoId = newlead.Id);
        	insert task;
            User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(usr) {
                Test.startTest();
                    ApexPages.CurrentPage().getparameters().put('id', newlead.Id);
                    LeadConversionCtrl controller = new LeadConversionCtrl();
                    controller.init();
                    newlead.Beschaeftigte__c = '1-4';
                	update newlead;
                    controller.continueConvert();
                    controller.backToLeadWithSavingFields();
                    controller.backToLeadWithoutSavingFields();
                Test.stopTest();
            	List<Account> accountList = [
            			SELECT ShippingStreet, BillingStreet
            			FROM Account];
            	System.assertEquals(accountList.size(), 1);
                System.assertEquals(accountList.get(0).BillingStreet, accountList.get(0).ShippingStreet);

            	Task testTask = [
            			SELECT WhoId, WhatId
            			FROM Task];
            	System.assertNotEquals(null, testTask.WhatId);
            	System.assertNotEquals(null, testTask.WhoId);
            }
        }
    }


    @isTest
    static void testConvertJITBLead() {
        createUser();

        System.runAs(u) {
            createJITBLead();
            createEmailTemplate();

            Task task = new Task(
                WhoId = newlead.Id);
            insert task;
            User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(usr) {
                Test.startTest();
                    ApexPages.CurrentPage().getparameters().put('id', newlead.Id);
                    LeadConversionCtrl controller = new LeadConversionCtrl();
                    controller.init();
                    controller.backToLeadWithoutSavingFields();
                Test.stopTest();
                List<Account> accountList = [
                        SELECT ShippingStreet, BillingStreet
                        FROM Account];
                System.assertEquals(accountList.size(), 1);
                System.assertEquals(accountList.get(0).BillingStreet, accountList.get(0).ShippingStreet);

                Task testTask = [
                        SELECT WhoId, WhatId
                        FROM Task];
                System.assertNotEquals(null, testTask.WhatId);
                System.assertNotEquals(null, testTask.WhoId);
            }
        }
    }



    private static void createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];

        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_23423_test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(u);
    }

    private static void createLead() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Endkunde' AND sObjectType = 'Lead' LIMIT 1];
        newlead = new Lead(
            LastName = 'Test',
            FirstName = 'testName',
            RecordTypeId = rt.Id,
            OwnerId = u.Id,
            Company = 'Test',
            Country = 'Germany',
            Street = 'test',
            City = 'test',
            PostalCode = '223141',
            Salutation = 'Herr',
            Email = 'test@test.com',
            Anzahl_der_Fahrzeuge__c = 2,
            Beschaeftigte__c = '1-4',
            Send_SEPA_approval_link__c = true,
            Branche_NACE__c = 'Apotheken - 4773');
        insert newlead;

        Attachment attachment = new Attachment();
        attachment.Name = 'test';
        attachment.Body = Blob.valueOf('test');
        attachment.ParentId = newlead.Id;
        insert attachment;

        Note note =  new Note();
        note.Title = 'test';
        note.Body = 'test';
        note.ParentId = newlead.Id;
        insert note;

        Emarsys_Log__c log = new Emarsys_Log__c();
        log.Lead__c = newlead.Id;
        insert log;
    }

    private static void createJITBLead() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Endkunde' AND sObjectType = 'Lead' LIMIT 1];
        newlead = new Lead(
            LastName = 'Test',
            FirstName = 'testName',
            RecordTypeId = rt.Id,
            OwnerId = u.Id,
            Company = 'Test',
            Country = 'Germany',
            Street = 'test',
            City = 'test',
            PostalCode = '223141',
            Salutation = 'Herr',
            Email = 'test@test.com',
            Anzahl_der_Fahrzeuge__c = 2,
            Sec_Channel__c = 'JITB',
            Channel__c = 'Fax',
            Beschaeftigte__c = '1-4',
            Send_SEPA_approval_link__c = true,
            Branche_NACE__c = 'Apotheken - 4773');
        insert newlead;

        Attachment attachment = new Attachment();
        attachment.Name = 'test';
        attachment.Body = Blob.valueOf('test');
        attachment.ParentId = newlead.Id;
        insert attachment;

        Note note =  new Note();
        note.Title = 'test';
        note.Body = 'test';
        note.ParentId = newlead.Id;
        insert note;

        Emarsys_Log__c log = new Emarsys_Log__c();
        log.Lead__c = newlead.Id;
        insert log;
    }

    private static void createEmailTemplate() {
        emailTeamplate = new EmailTemplate(
            Name = 'SEPA Approval Link for contact',
            DeveloperName = 'SEPA_Approval_Link_for_contact_DE',
            Subject = 'SEPA Data approval',
            Body = 'test',
            TemplateType = 'Text',
            FolderId = UserInfo.getUserId()
        );
        insert emailTeamplate;
    }


    /*******************************************************************************
    *  Name            : testFindDuplicates()
    *  Summary         : test finding duplicates
    *  CreatedDate     : 7/12/2017
    *  ModifiedDate    : 7/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testFindDuplicates() {
        createDuplicateLead();
        createDuplicateAccount();
        createDuplicateOpportunity();
        createDuplicateContact();
        ApexPages.CurrentPage().getparameters().put('id', newlead.Id);
        LeadConversionCtrl controller = new LeadConversionCtrl();
        Test.startTest();
            controller.init();
        Test.stopTest();
        System.assert(true, ApexPages.getMessages().get(0).getSummary().contains('Duplicates found in Account'));
        System.assert(true, ApexPages.getMessages().get(0).getSummary().contains('Duplicates found in Opportunity'));
        System.assert(true, ApexPages.getMessages().get(0).getSummary().contains('Duplicates found in Contact'));
    }

    /*******************************************************************************
    *  Name            : testFindDuplicates()
    *  Summary         : test finding duplicates
    *  CreatedDate     : 7/12/2017
    *  ModifiedDate    : 7/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testFindDuplicatesShell() {
        createDuplicateLeadShell();
        createDuplicateAccount();
        createDuplicateOpportunity();
        createDuplicateContact();
        ApexPages.CurrentPage().getparameters().put('id', newlead.Id);
        LeadConversionCtrl controller = new LeadConversionCtrl();
        Test.startTest();
        controller.init();
        Test.stopTest();
        System.assert(true, ApexPages.getMessages().get(0).getSummary().contains('Duplicates found in Account'));
        System.assert(true, ApexPages.getMessages().get(0).getSummary().contains('Duplicates found in Opportunity'));
        System.assert(true, ApexPages.getMessages().get(0).getSummary().contains('Duplicates found in Contact'));
    }


    /*******************************************************************************
    *  Name            : createDuplicateLead()
    *  Summary         : create Lead to find duplicates in Account, Opportunity, Contact
    *  CreatedDate     : 07/12/2017
    *  ModifiedDate    : 07/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createDuplicateLead() {
        newlead = new Lead(
            LastName = 'Test',
            Company = 'Test',
            Country = 'Germany',
            Anzahl_der_Fahrzeuge__c = 2,
            Beschaeftigte__c = '1-4',
            Salutation = 'Herr',
            Branche_NACE__c = 'Apotheken - 4773',
            IBAN__c = 'test IBAN',
            Steuernummer__c = 'test tax',
            Umsatzsteuer_ID__c = 'test VAT',
            Email = 'test@test.com',
            Phone = '+123123123');
        insert newlead;

        Attachment attachment = new Attachment();
        attachment.Name = 'test';
        attachment.Body = Blob.valueOf('test');
        attachment.ParentId = newlead.Id;
        insert attachment;

        Note note =  new Note();
        note.Title = 'test';
        note.Body = 'test';
        note.ParentId = newlead.Id;
        insert note;

        Emarsys_Log__c log = new Emarsys_Log__c();
        log.Lead__c = newlead.Id;
        insert log;
    }

    /*******************************************************************************
    *  Name            : createDuplicateLead()
    *  Summary         : create Lead to find duplicates in Account, Opportunity, Contact
    *  CreatedDate     : 07/12/2017
    *  ModifiedDate    : 07/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createDuplicateLeadShell() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name = 'Shell Universal Card' AND SobjectType ='Lead'];
        newlead = new Lead(
                LastName = 'Test',
                Company = 'Test',
                Country = 'Germany',
                Anzahl_der_Fahrzeuge__c = 2,
                Beschaeftigte__c = '1-4',
                Salutation = 'Herr',
                Branche_NACE__c = 'Apotheken - 4773',
                IBAN__c = 'test IBAN',
                Steuernummer__c = 'test tax',
                Umsatzsteuer_ID__c = 'test VAT',
                Email = 'test@test.com',
                RecordTypeId = recordTypes.get(0).Id,
                Phone = '+123123123');
        insert newlead;

        Attachment attachment = new Attachment();
        attachment.Name = 'test';
        attachment.Body = Blob.valueOf('test');
        attachment.ParentId = newlead.Id;
        insert attachment;

        Note note =  new Note();
        note.Title = 'test';
        note.Body = 'test';
        note.ParentId = newlead.Id;
        insert note;

        Emarsys_Log__c log = new Emarsys_Log__c();
        log.Lead__c = newlead.Id;
        insert log;
    }

    /*******************************************************************************
    *  Name            : createDuplicateAccount()
    *  Summary         : create Account with Duplicate field values
    *  CreatedDate     : 7/12/2017
    *  ModifiedDate    : 7/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createDuplicateAccount() {
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1];
        duplicateAccount = new Account(
            Name = 'test',
            Steuernummer__c = 'test tax',
            BillingCountry = 'Germany',
            Umsatzsteuer_ID__c = 'test VAT',
            BillingCity = 'test',
            BillingStreet = 'test',
            RecordTypeId = accountRecordTypeList.get(0).Id);
        insert duplicateAccount;
    }


    /*******************************************************************************
    *  Name            : createDuplicateOpportunity()
    *  Summary         : create Opportunity with Duplicate field values
    *  CreatedDate     : 07/12/2017
    *  ModifiedDate    : 07/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createDuplicateOpportunity() {
        duplicateOpportnunity = new Opportunity(
            Name = 'test',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            IBAN__c = 'test IBAN');
        insert duplicateOpportnunity;
    }


    /*******************************************************************************
    *  Name            : createDuplicateContact()
    *  Summary         : create Contact with Duplicate field values
    *  CreatedDate     : 07/12/2017
    *  ModifiedDate    : 07/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createDuplicateContact() {
        duplicateContact = new Contact(
            LastName = 'test',
            Phone = '+123123123',
            Salutation = 'Herr',
            Email = 'test@test.com',
            AccountId = duplicateAccount.Id);
        insert duplicateContact;
    }
}