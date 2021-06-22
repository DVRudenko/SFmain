@isTest
public with sharing class E2EMoveToStartServiceTest {
    @TestSetup
    static void makeData() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;
        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        report.Name = 'teste2e';
        insert report;
    }

    @isTest
    private static void testCheckForRMDApproval_BlankParams() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        CompanyVerificationScoring verificationDecision = null;
        E2E_business_settings__c setting = null;
        Boolean terminateProcess = service.checkForRMDApproval(verificationDecision, null, setting);

        System.assertEquals(false, terminateProcess);

        verificationDecision = new CompanyVerificationScoring();
        terminateProcess = service.checkForRMDApproval(verificationDecision, null, setting);

        System.assertEquals(false, terminateProcess);

        verificationDecision.decision = 1;
        terminateProcess = service.checkForRMDApproval(verificationDecision, null, setting);

        System.assertEquals(false, terminateProcess);

        setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        setting.Approval_Process_Name__c = null;
        insert setting;
        terminateProcess = service.checkForRMDApproval(verificationDecision, null, setting);

        System.assertEquals(false, terminateProcess);

        setting.Approval_Process_Name__c = 'ApprovalName';
        update setting;
        terminateProcess = service.checkForRMDApproval(verificationDecision, null, setting);

        System.assertEquals(false, terminateProcess);

        Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opp;
        terminateProcess = service.checkForRMDApproval(verificationDecision, opp.Id, setting);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(System.Label.SendingToRMDFailed, messages[0].getSummary());
        System.assertEquals(true, terminateProcess);

        Approval.lock(opp.Id);
        terminateProcess = service.checkForRMDApproval(verificationDecision, opp.Id, setting);

        messages = ApexPages.getMessages();
        Boolean hasMessage = false;
        for (ApexPages.Message message : messages) {
            if (message.getSummary() == System.Label.RMDApprovalSide) {
                hasMessage = true;
            }
        }
        System.assertEquals(true, hasMessage);
        System.assertEquals(true, terminateProcess);
    }

    @isTest
    private static void testCheckForRMDApproval_RunProcess() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);

        CompanyVerificationScoring verificationDecision = new CompanyVerificationScoring();
        verificationDecision.decision = 1;
        Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opp;

        Boolean terminateProcess = service.checkForRMDApproval(verificationDecision, opp.Id, setting);

        System.assertEquals(true, terminateProcess);

        verificationDecision.decision = 4;
        terminateProcess = service.checkForRMDApproval(verificationDecision, opp.Id, setting);

        System.assertEquals(true, terminateProcess);

        verificationDecision.decision = 3;
        terminateProcess = service.checkForRMDApproval(verificationDecision, opp.Id, setting);

        System.assertEquals(true, terminateProcess);

        Approval.unlock(opp.Id);
        terminateProcess = service.checkForRMDApproval(verificationDecision, opp.Id, setting);

        System.assertEquals(false, terminateProcess);
    }

    @isTest
    private static void testCheckRMDRecordLock_BlankParams() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        Boolean recordLocked = service.checkRMDRecordLock(null);

        System.assertEquals(false, recordLocked);
    }

    @isTest
    private static void testCheckRMDRecordLock_BlockVariants() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opp;

        Boolean recordLocked = service.checkRMDRecordLock(opp.Id);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(true, messages.isEmpty());
        System.assertEquals(false, recordLocked);

        Approval.lock(opp.Id);
        recordLocked = service.checkRMDRecordLock(opp.Id);

        messages = ApexPages.getMessages();
        System.assertEquals(System.Label.RMDApprovalSide, messages[0].getSummary());
        System.assertEquals(true, recordLocked);
    }

    @isTest
    private static void testCheckStartAvailability_BlankParams() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        Boolean startAllowed = service.checkStartAvailability(null, null);

        System.assertEquals(true, startAllowed);

        startAllowed = service.checkStartAvailability(null, false);

        System.assertEquals(true, startAllowed);

        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        startAllowed = service.checkStartAvailability(setting, null);

        System.assertEquals(true, startAllowed);
    }

    @isTest
    private static void testCheckStartAvailability_ChangeBlock() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);

        Boolean startAllowed = service.checkStartAvailability(setting, false);
        System.assertEquals(true, startAllowed);

        setting.Block_start_button__c = true;
        startAllowed = service.checkStartAvailability(setting, false);
        System.assertEquals(false, startAllowed);

        startAllowed = service.checkStartAvailability(setting, true);
        System.assertEquals(false, startAllowed);

        setting.Block_start_button__c = false;
        startAllowed = service.checkStartAvailability(setting, true);
        System.assertEquals(false, startAllowed);
    }

    @isTest
    private static void testSendApprovalToService() {
        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        setting.Approval_Process_Service_Name__c = 'Test_Blank';
        insert setting;
        Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opp;
        E2EMoveToStartService.SendApprovalToService(opp.id, setting);

        ApexPages.Message[] messages2 = ApexPages.getMessages();
        System.assertEquals(System.Label.SendToServiceFailed, messages2[0].getSummary());

        E2E_business_settings__c setting_test = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        E2EMoveToStartService.SendApprovalToService(opp.id, setting_test);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(System.Label.SendToService, messages[1].getSummary());
    }

    @isTest
    private static void testSendApprovalToAdmin() {
        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        setting.Approval_Process_Service_Name__c = 'Test_Blank';
        insert setting;
        Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opp;
        E2EMoveToStartService.sendApprovalToAdmin(opp.id, setting);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(System.Label.SendToAdmin, messages[0].getSummary());

        E2E_business_settings__c setting_test2 = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        E2EMoveToStartService.sendApprovalToAdmin(opp.id, setting_test2);

        ApexPages.Message[] messagesAdmin = ApexPages.getMessages();
        System.assertEquals(System.Label.SendToAdminFailed, messagesAdmin[1].getSummary());
    }

    @IsTest
    private static void testCheckApprovalStatus() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        insert setting;

        Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opp;

        service.checkApprovalStatus(opp.id, setting);
    }

    @IsTest
    private static void testFilterProducts() {
        E2EMoveToStartService service = new E2EMoveToStartService();
        List<SelectOption> filteredProducts = service.filterProducts(null);

        System.assertEquals(0, filteredProducts.size());

        List<SelectOption> notFilteredProducts = new List<SelectOption>();
        notFilteredProducts.add(new SelectOption('test', 'test'));
        notFilteredProducts.add(new SelectOption('test' + E2EMoveToStartService.SHELL_SITE_DF, 'test1'));
        notFilteredProducts.add(new SelectOption('test' + E2EMoveToStartService.SHELL_SITE_PETROL, 'test2'));
        notFilteredProducts.add(new SelectOption('test' + E2EMoveToStartService.TARIF_PART_2020, 'test3'));

        filteredProducts = service.filterProducts(notFilteredProducts);

        System.assertEquals(3, filteredProducts.size());
    }

    @IsTest
    private static void testSetCreditDecisions() {
        Credit_Factory_Report__c report = [SELECT Name FROM Credit_Factory_Report__c WHERE Name = 'teste2e'];
        E2EMoveToStartService service = new E2EMoveToStartService();
        List<Credit_Factory_Report__c> actualCfrs = new List<Credit_Factory_Report__c>();
        Id currentUserProfileId = UserInfo.getProfileId();
        Id currentUserRoleId = UserInfo.getUserRoleId();
        List<Profile> profiles = [SELECT Name FROM Profile WHERE Id != :currentUserProfileId];
        List<UserRole> userRoles = [SELECT Name FROM UserRole WHERE Id != :currentUserRoleId];
        User decisionUser = E2EMoveToStartDataTestFactory.createUser('decision', profiles[0].Id, userRoles[0].Id);
        insert decisionUser;
        E2EFormData__c formData = new E2EFormData__c();

        List<SelectOption> creditDecisionList = service.setCreditDecisions(null, formData, 'test');
        System.assertEquals(1, creditDecisionList.size());

        System.runAs(decisionUser) {
            E2EBusiness_Free_Overdraft_Permission__c freeOverdraftPermissionSetting = E2EMoveToStartDataTestFactory.createFreeOverdraftPermissionSetting(
                profiles[0].Name,
                userRoles[0].Name
            );
            insert freeOverdraftPermissionSetting;
            E2E_business_settings__c businessSetting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
            businessSetting.Company_age__c = 0;
            insert businessSetting;
            service = new E2EMoveToStartService();

            creditDecisionList = service.setCreditDecisions(null, formData, 'test');
            System.assertEquals(1, creditDecisionList.size());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getLabel());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getValue());

            creditDecisionList = service.setCreditDecisions(null, null, 'test');
            System.assertEquals(1, creditDecisionList.size());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getLabel());

            creditDecisionList = service.setCreditDecisions(null, null, 'test');
            System.assertEquals(1, creditDecisionList.size());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getLabel());

            actualCfrs.add(report);
            formData.E2E_Reg_Date__c = Datetime.now().addMonths(-1).format('dd.MM.yyyy');
            creditDecisionList = service.setCreditDecisions(actualCfrs, formData, 'test');
            System.assertEquals(3, creditDecisionList.size());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getLabel());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getValue());
            System.assertEquals(E2EMoveToStartService.FREE_OVERDRAFT, creditDecisionList.get(1).getLabel());
            System.assertEquals(E2EMoveToStartService.FREE_OVERDRAFT, creditDecisionList.get(1).getValue());
            
            creditDecisionList = service.setCreditDecisions(actualCfrs, formData, 'wrongPPsource');
            System.assertEquals(2, creditDecisionList.size());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getLabel());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getValue());
         
            freeOverdraftPermissionSetting.Profile_Name__c = null;
            update freeOverdraftPermissionSetting;
            creditDecisionList = service.setCreditDecisions(actualCfrs, formData, 'test');
            System.assertEquals(2, creditDecisionList.size());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getLabel());
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, creditDecisionList.get(0).getValue());
        }
    }

    @IsTest
    private static void testSetPreselectedCreditDecision() {
        Credit_Factory_Report__c report = [SELECT RU_Client_Choice__c FROM Credit_Factory_Report__c WHERE Name = 'teste2e'];
        List<Credit_Factory_Report__c> actualCfrs = new List<Credit_Factory_Report__c>();
        E2EFormData__c formData = new E2EFormData__c();
        E2EFormParams formParams = new E2EFormParams();
        E2EMoveToStartService service = new E2EMoveToStartService();

        // check null validation
        service.setPreselectedCreditDecision(null, null, null);

        service.setPreselectedCreditDecision(actualCfrs, formData, formParams);
        System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, formParams.creditDecision);

        formParams.creditDecision = '';
        actualCfrs.add(report);
        service.setPreselectedCreditDecision(actualCfrs, formData, formParams);
        System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, formParams.creditDecision);

        formParams.creditDecision = '';
        formData.Free_overdraft__c = true;
        service.setPreselectedCreditDecision(actualCfrs, formData, formParams);
        System.assertEquals(E2EMoveToStartService.FREE_OVERDRAFT, formParams.creditDecision);

        formParams.creditDecision = '';
        report.RU_Client_Choice__c = true;
        service.setPreselectedCreditDecision(actualCfrs, formData, formParams);
        System.assertEquals(String.valueOf(report.Id), formParams.creditDecision);
    }

    @isTest
    private static void testProcessContactUpsertion_noContactsBefore() {
        Account testAccount = E2EFormRuTestUtils.createDefaultAccount();
        insert testAccount;
        Opportunity testOpportuniy = E2EFormRuTestUtils.createOpportunity(testAccount.Id);
        insert testOpportuniy;
        E2EFormParams testFormParams = new E2EFormParams();
        testFormParams.contactFullName = 'Володина Татьяна Игорьевна';
        testFormParams.mainContactPhone = '+7 916 222 33 22';
        testFormParams.mainContactEmail = 'test@test.com';
        E2EMoveToStartService service = new E2EMoveToStartService();
        E2EMoveToStartService.processContactUpsertion(testFormParams, testOpportuniy, testAccount.Id);
        OpportunityContactRole updatedContactWithRole = [
            SELECT IsPrimary, Contact.Email, Contact.Additional_Emails__c, Contact.Phone
            FROM OpportunityContactRole
            WHERE Contact.LastName = 'Володина' AND OpportunityId = :testOpportuniy.Id
            LIMIT 1
        ];
        system.assertEquals(true, updatedContactWithRole.IsPrimary);
        system.assertEquals(testFormParams.mainContactPhone, updatedContactWithRole.Contact.Phone);
        system.assertEquals(testFormParams.mainContactEmail, updatedContactWithRole.Contact.Email);
        system.assertEquals(null, updatedContactWithRole.Contact.Additional_Emails__c);
    }

    @isTest
    private static void testProcessContactUpsertion_withMainContactBefore() {
        Account testAccount = E2EFormRuTestUtils.createDefaultAccount();
        insert testAccount;
        Opportunity testOpportuniy = E2EFormRuTestUtils.createOpportunity(testAccount.Id);
        insert testOpportuniy;
        Contact testContact = E2EFormRuTestUtils.createContact(testAccount.Id, '+7 916 222 33 33', 'test@test1.com');
        testContact.LastName = 'Елизавета Игорьевна';
        testContact.FirstName = null;
        testContact.RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian');
        insert testContact;
        E2EFormRuDaoImpl daoService = new E2EFormRuDaoImpl();
        Opportunity formOpportunity = daoService.getOpportunityById(testOpportuniy.Id);
        formOpportunity.OpportunityContactRoles[0].IsPrimary = true;
        E2EFormParams testFormParams = new E2EFormParams();
        testFormParams.contactFullName = 'Володина Татьяна Игорьевна';
        testFormParams.mainContactPhone = '+7 916 222 33 22';
        testFormParams.mainContactEmail = 'test@test.com';

        E2EMoveToStartService.processContactUpsertion(testFormParams, formOpportunity, testAccount.Id);

        OpportunityContactRole updatedContactWithRole = [
            SELECT IsPrimary, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Additional_Emails__c, Contact.Phone
            FROM OpportunityContactRole
            WHERE Contact.FirstName = 'Татьяна Игорьевна' AND OpportunityId = :testOpportuniy.Id
            LIMIT 1
        ];
        OpportunityContactRole oldContactRole = [
            SELECT IsPrimary
            FROM OpportunityContactRole
            WHERE Contact.LastName = 'Елизавета Игорьевна' AND OpportunityId = :testOpportuniy.Id
            LIMIT 1
        ];

        system.assertEquals(true, updatedContactWithRole.IsPrimary);
        system.assertEquals(false, oldContactRole.IsPrimary);
        system.assertEquals('Володина', updatedContactWithRole.Contact.LastName);
        system.assertEquals(testFormParams.mainContactPhone, updatedContactWithRole.Contact.Phone);
        system.assertEquals(testFormParams.mainContactEmail, updatedContactWithRole.Contact.Email);
        system.assertEquals('test@test1.com', updatedContactWithRole.Contact.Additional_Emails__c);
    }

    @isTest
    private static void testProcessContactUpsertion_withSamePrimaryContactBefore() {
        Account testAccount = E2EFormRuTestUtils.createDefaultAccount();
        insert testAccount;
        Opportunity testOpportuniy = E2EFormRuTestUtils.createOpportunity(testAccount.Id);
        insert testOpportuniy;
        Contact testContact = E2EFormRuTestUtils.createContact(testAccount.Id, '+7 916 222 33 33', 'test@test1.com');
        testContact.LastName = 'Елизавета';
        testContact.FirstName = 'Игорьевна';
        testContact.RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian');
        insert testContact;
        E2EFormRuDaoImpl daoService = new E2EFormRuDaoImpl();
        Opportunity formOpportunity = daoService.getOpportunityById(testOpportuniy.Id);
        formOpportunity.OpportunityContactRoles[0].IsPrimary = true;

        E2EFormParams testFormParams = new E2EFormParams();
        testFormParams.contactFullName = 'Елизавета Игорьевна';
        testFormParams.mainContactPhone = '+7 916 222 33 22';
        testFormParams.mainContactEmail = 'test@test.com';

        E2EMoveToStartService.processContactUpsertion(testFormParams, formOpportunity, testAccount.Id);
        ContactTriggerHandler.disableContactRolesInsertion = true;

        OpportunityContactRole updatedContactWithRole = [
            SELECT IsPrimary, Contact.Email, Contact.Additional_Emails__c, Contact.Phone, Contact.FirstName, Contact.LastName
            FROM OpportunityContactRole
            WHERE Contact.LastName = 'Елизавета' AND OpportunityId = :testOpportuniy.Id
            LIMIT 1
        ];
        OpportunityContactRole updatedContactWithRole1 = [SELECT IsPrimary FROM OpportunityContactRole WHERE OpportunityId = :testOpportuniy.Id];

        system.assertEquals('Игорьевна', updatedContactWithRole.Contact.FirstName);
        system.assertEquals(testFormParams.mainContactPhone, updatedContactWithRole.Contact.Phone);
        system.assertEquals(testFormParams.mainContactEmail, updatedContactWithRole.Contact.Email);
        system.assertEquals('test@test1.com', updatedContactWithRole.Contact.Additional_Emails__c);
    }

    @isTest
    private static void testProcessContactUpsertion_withSameNotPrimaryContactBefore2() {
        Account testAccount = E2EFormRuTestUtils.createDefaultAccount();
        insert testAccount;
        Opportunity testOpportuniy = E2EFormRuTestUtils.createOpportunity(testAccount.Id);
        insert testOpportuniy;
        List<Contact> testContacts = new List<Contact>();
        Contact testContact1 = E2EFormRuTestUtils.createContact(testAccount.Id, '+7 916 222 33 33', 'test@test1.com');
        testContact1.LastName = 'Владислав';
        testContact1.FirstName = null;
        testContact1.RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian');
        testContacts.add(testContact1);

        Contact testContact2 = E2EFormRuTestUtils.createContact(testAccount.Id, '+7 916 222 33 35', 'test@test2.com');
        testContact2.LastName = 'Елизавета';
        testContact2.FirstName = null;
        testContact2.RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian');
        testContacts.add(testContact2);
        insert testContacts;

        E2EFormRuDaoImpl daoService = new E2EFormRuDaoImpl();
        Opportunity formOpportunity = daoService.getOpportunityById(testOpportuniy.Id);
        formOpportunity.OpportunityContactRoles[1].IsPrimary = true;

        E2EFormParams testFormParams = new E2EFormParams();
        testFormParams.contactFullName = 'Владислав';
        testFormParams.mainContactPhone = '+7 916 222 33 22';
        testFormParams.mainContactEmail = 'test@test.com';

        E2EMoveToStartService.processContactUpsertion(testFormParams, formOpportunity, testAccount.Id);

        OpportunityContactRole updatedContactWithRole = [
            SELECT IsPrimary, Contact.Email, Contact.Additional_Emails__c, Contact.clicktocallPPRPhone__c, Contact.Phone
            FROM OpportunityContactRole
            WHERE Contact.LastName = 'Владислав' AND OpportunityId = :testOpportuniy.Id
            LIMIT 1
        ];

        OpportunityContactRole oldContactRole = [
            SELECT IsPrimary
            FROM OpportunityContactRole
            WHERE Contact.LastName = 'Елизавета' AND OpportunityId = :testOpportuniy.Id
            LIMIT 1
        ];

        system.assertEquals(false, oldContactRole.IsPrimary);
        system.assertEquals(true, updatedContactWithRole.IsPrimary);
        system.assertEquals(testFormParams.mainContactPhone, updatedContactWithRole.Contact.Phone);
        system.assertEquals(testFormParams.mainContactEmail, updatedContactWithRole.Contact.Email);
        system.assertEquals('test@test2.com;test@test1.com', updatedContactWithRole.Contact.Additional_Emails__c);
    }

    @isTest
    private static void testAddValueToAdditionalFieldOnMainFieldChange() {
        String oldAdditionalEmails = 'test@test.com:test@test1.com';
        String currentFormEmail = 'test@test1.com';
        String oldEmail = 'test@test2.com';
        String currentAdditionalEmail = E2EMoveToStartService.addValueToAdditionalFieldOnMainFieldChange(
            oldAdditionalEmails,
            currentFormEmail,
            oldEmail,
            ':',
            100
        );
        system.assertEquals('test@test2.com:test@test.com', currentAdditionalEmail);
    }
    @isTest
    private static void testAddValueToAdditionalFieldOnMainFieldChange_ValueBiggerThenField() {
        String oldAdditionalEmails = 'test@test.com:test@test1.com:test@test2.com';
        String currentFormEmail = 'test@test4.com';
        String oldEmail = 'test@test3.com';
        String currentAdditionalEmail = E2EMoveToStartService.addValueToAdditionalFieldOnMainFieldChange(
            oldAdditionalEmails,
            currentFormEmail,
            oldEmail,
            ':',
            45
        );
        system.assertEquals('test@test3.com:test@test.com:test@test1.com', currentAdditionalEmail);
    }

    @isTest
    private static void testAddValueToAdditionalFieldOnMainFieldChange_NullEntry() {
        String currentAdditionalEmail = E2EMoveToStartService.addValueToAdditionalFieldOnMainFieldChange(null, null, null, null, null);
        system.assertEquals(null, currentAdditionalEmail);
    }
}