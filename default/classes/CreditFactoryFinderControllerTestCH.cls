@isTest
private class CreditFactoryFinderControllerTestCH {
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
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidOpportunityId() {
        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid record id.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCountry()
    *  Summary         : Leave country field as empty.
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidCountry() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        account.BillingCountry = '';
        account.BillingCountryCode = '';
        update account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
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
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidCreditSystem() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
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
    *  Summary         : Create Credit System custom setting not with "CrediconnectCH" name.
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
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
    *  Summary         : Create Account mapping not with "CrediconnectCH" name.
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
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
    *  Summary         : Create Opportunity mapping not with "CrediconnectCH" name.
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'CrediconnectCH');
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
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : -  
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testInvalidAccountMapping() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
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
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testInvalidOpportunityMapping() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
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
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testProfileValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
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
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testClosedOpportunity() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
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
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest 
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        account.Name = 'Test Black List';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.createCrediconnectBlackListCH(account.Name);
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
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : 14/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testProcessedOpportunityValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.bearbeitet_von__c = 'test';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
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
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testRequiredFieldsValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.Anzahl_der_Karten__c = null;
        opportunity.StageName = 'Pending Sales – Information';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Please fill required fields: Opportunity: Number of Cards*');
    }


    /*******************************************************************************
    *  Name            : testDuplicatesCheck()
    *  Summary         : Test duplicates check in opportunities, accounts and contacts.
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testDuplicatesCheck() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        accountsList.add(account);
        Account duplicateAccount = CreditFactoryUtils.createCrediconnectAccountCH();
        duplicateAccount.Steuernummer__c = 'CH17030143615';
        accountsList.add(duplicateAccount);
        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunitiesList.add(opportunity);
        Opportunity duplicateOpportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(duplicateAccount.Id);
        opportunitiesList.add(duplicateOpportunity);
        insert opportunitiesList;

        List<Contact> contactsList = new List<Contact>();
        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        contactsList.add(contact);
        Contact duplicateContact = CreditFactoryUtils.createCrediconnectContactCH(duplicateAccount.Id);
        contactsList.add(duplicateContact);
        insert contactsList;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        OpportunityContactRole opportunityContactRole = CreditFactoryUtils.createCrediconnectContactRoleCH(contact.Id, opportunity.Id);
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
    *  Name            : testValidCompanySearchByVatNumber()
    *  Summary         : Test successful company search by Vat Number.
    *  CreatedDate     : 15/10/2018
	*  ModifiedDate    : 29/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testValidCompanySearchByVatNumber() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectSearchMockCH());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.selectCompanyForReport();
            controller.backToOpporutnity();
            controller.setInvalidSearch();
        Test.stopTest();

        System.assertEquals(false, controller.companiesList.isEmpty());
    }


    /*******************************************************************************
    *  Name            : testValidCompanySearchByName()
    *  Summary         : Test successful company search by Name.
    *  CreatedDate     : 29/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testValidCompanySearchByName() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        account.Umsatzsteuer_ID__c = null;
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectSearchMockCH());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.finderService.setUserSource(null);
            controller.finderService.getUserSource();
        Test.stopTest();

        System.assertEquals(false, controller.companiesList.isEmpty());
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check success search company
    *  CreatedDate     : 02/10/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCrediconnectReportCH(opportunity.Id);
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCrediconnectReportEmployeeCH(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.currentPage().getRedirect());
    }
}