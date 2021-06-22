@isTest
private class CreditFactoryFinderControllerTestLU {
    public static CreditFactoryFinderController controller;
    
    
    /*******************************************************************************
    *  Name            : createDataForAllTests()
    *  Summary         : Create data for all test methods
    *  CreatedDate     : 11/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup
    static void createDataForAllTests() {
        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryUtils.createCreditFactoryUserProfile();
        insert cfUserProfile;
    }


    /*******************************************************************************
	*  Name            : testInvalidOpportunityId()
	*  Summary         : Leave opportunity id as null in vf page.
	*  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testInvalidOpportunityId() {
        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

        System.assertEquals('Invalid record id.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCountry()
    *  Summary         : Leave country field as empty.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : 25/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testInvalidCountry() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        account.BillingCountry = '';
        account.BillingCountryCode = '';
        update account;

    	Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

        System.assertEquals('Please add Billing Country to Account.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystem()
    *  Summary         : Don't create Credit System custom setting.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testInvalidCreditSystem() {
    	Account account = CreditFactoryUtils.createCreditReformAccountLU();
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

    	System.assertEquals('Select Credit System Settings failed. Please check Billing Country or contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystemName()
    *  Summary         : Create Credit System custom setting not with "CreditreformServiceLU" name.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        creditSystem.Name = 'test';
        insert creditSystem;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "CreditreformServiceLU" name.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "CreditreformServiceLU" name.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'CreditreformLU');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testInvalidAccountMapping()
    *  Summary         : Leave empty Account mapping field.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -  
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    static void testInvalidAccountMapping() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testInvalidOpportunityMapping()
    *  Summary         : Leave empty Opportunity mapping field.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    static void testInvalidOpportunityMapping() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        creditFactoryOpportunity.Credit_System_Limit__c = '';
        insert creditFactoryOpportunity;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /******************************************************************************
    *  Name            : testProfileValidation()
    *  Summary         : Check that current user has access to CF
    *  CreatedDate     : 11/11/2019
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testProfileValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;
        
        List<Credit_Factory_User_Profile__c> cfUsersProfilesList = [SELECT Id FROM Credit_Factory_User_Profile__c];
        delete cfUsersProfilesList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Your profile doesn\'t have access to Credit Factory.', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testClosedOpportunity()
    *  Summary         : Try to launch Credit Factory for Closed Opportunity.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    static void testClosedOpportunity() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity was already closed.', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testBlackListValidation()
    *  Summary         : Create sObjects which data exists in Black List
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        account.Name = 'Test Black List';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.createCreditreformBlackListLU(account.Name);
        insert blackList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Company found in black list. Please refer to credit.'));
    }


    /*******************************************************************************
    *  Name            : testProcessedOpportunityValidation()
    *  Summary         : Fill Processed by field.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : 14/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testProcessedOpportunityValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.bearbeitet_von__c = 'test';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Your Opportunity has already received a Credit Decision or is in the ongoing Manual Review with the Credit Team.', ApexPages.getMessages().get(0).getSummary());
    }
    

	/*******************************************************************************
    *  Name            : testRequiredFieldsValidation()
    *  Summary         : Check Opportunity (or Account) required fields for on null pointer.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testRequiredFieldsValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.Anzahl_der_Karten__c = null;
        opportunity.StageName = 'Pending Sales – Information';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Please fill required fields: Opportunity: Number of Cards*');
    }
    
    
    /******************************************************************************
    *  Summary         : Test Desired Payment Details validation
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    static void testPaymentTermsValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.Zahlungsziel_2__c = '30';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testDuplicatesCheck()
    *  Summary         : Test duplicates check in opportunities, accounts and contacts.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testDuplicatesCheck() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        accountsList.add(account);
        Account duplicateAccount = CreditFactoryUtils.createCreditReformAccountLU();
        duplicateAccount.Steuernummer__c = '123123123';
        accountsList.add(duplicateAccount);
        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunitiesList.add(opportunity);
        Opportunity duplicateOpportunity = CreditFactoryUtils.createCreditreformOpportunityLU(duplicateAccount.Id);
        opportunitiesList.add(duplicateOpportunity);
        insert opportunitiesList;

        List<Contact> contactsList = new List<Contact>();
        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        contactsList.add(contact);
        Contact duplicateContact = CreditFactoryUtils.createCreditreformContactLU(duplicateAccount.Id);
        contactsList.add(duplicateContact);
        insert contactsList;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        OpportunityContactRole opportunityContactRole = CreditFactoryUtils.createCreditreformOpportunityContactRoleLU(contact.Id, opportunity.Id);
        insert opportunityContactRole;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Accounts found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Opportunities found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Contacts found'));
    }


    /*******************************************************************************
    *  Name            : testOrderRequest()
    *  Summary         : Test company search when there are no found companies    
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testOrderRequest() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformOrderMockLU());
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Party_Id__c, CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('40374221', opportunitiesList.get(0).CF_Order_Reference_Number__c);
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }


    /*******************************************************************************
    *  Name            : testValidCompanySearch()
    *  Summary         : Test successful company search.
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    static void testValidCompanySearch() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformSearchMockLU());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.selectCompanyForReport();
            controller.backToOpporutnity();
            controller.setInvalidSearch();
        Test.stopTest();

        System.assertEquals(false, controller.companiesList.isEmpty());
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check success search company
    *  CreatedDate     : 16/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportLU(opportunity.Id);
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.currentPage().getRedirect());
    }
}