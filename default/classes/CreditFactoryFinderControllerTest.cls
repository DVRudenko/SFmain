@isTest
private class CreditFactoryFinderControllerTest {
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
        
        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;
    }


    //Credireform
    /*******************************************************************************
    *  Name            : testOpportunityId()
    *  Summary         : Put null id in opportunity
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testOpportunityId() {
        CreditFactoryException creditFactoryException = new CreditFactoryException();
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        ApexPages.currentPage().getParameters().put('id', account.Id);
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Invalid record id.');
    }


    /*******************************************************************************
    *  Name            : testInvalidSelectedOpportunity()
    *  Summary         : Leave country field is empty
    *  CreatedDate     : 11/11/2016
    *  ModifiedDate    : 25/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSelectedOpportunity() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        account.BillingCountry = '';
        account.BillingCountryCode = '';
        update account;
        
        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        controller = new CreditFactoryFinderController();
        controller.init();
        
        System.assertEquals('Please add Billing Country to Account.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidSelectedCreditSystem()
    *  Summary         : Chek field Supported_Countries__c of CreditSystem empty or not
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSelectedCreditSystem() {
        //No credit system
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Credit System Settings failed. Please check Billing Country or contact your administrator.');

        //Credit system exist. Credit system name not equals to CreditReformWebService.CREDIT_SYSTEM_NAME
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Test';
        insert creditSystem;
        controller.init();
        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(1).getSummary());
    }


    //CreditSafe
    /*******************************************************************************
    *  Name            : testInvalidMappingCreditsafe()
    *  Summary         : Check if Account and Opportunity mapping exist or not
    *  CreatedDate     : 22/11/2016 
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidMappingCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        creditFactoryAccount.Name = 'Creditsafe';
        update creditFactoryAccount;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*******************************************************************************
    *  Name            : testValidateMappingCreditsafe()
    *  Summary         : Check filling Credit_Factory_Account__c and Credit_Factory__c fileds   
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateMappingCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        creditFactoryOpportunity.Product__c = '';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        creditFactoryAccount.Company_Form__c = 'test';
        update creditFactoryAccount;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /***************************************************************************
    *  Name            : testInvalidCurrentOpportunityCreditsafe()
    *  Summary         : Check selecting opportunity with fields from mapping
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void 
    **************************************************************************/
    @isTest
    public static void testInvalidCurrentOpportunityCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        creditFactoryAccount.Company_Form__c = 'test';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }
    
    
    /******************************************************************************
    *  Name            : testProfileValidationCreditsafe()
    *  Summary         : Check that current user has access to CF
    *  CreatedDate     : 11/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testProfileValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;
        
        List<Credit_Factory_User_Profile__c> cfProfilesList = [SELECT Id FROM Credit_Factory_User_Profile__c];
        delete cfProfilesList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Your profile doesn\'t have access to Credit Factory.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testOpportunityForClosedCreditsafe()
    *  Summary         : Check Opportunity Status for Closed Won/Lost
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testOpportunityForClosedCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Opportunity was already closed.');
    }


    /******************************************************************************
    *  Summary         : Test black list validation
    *  CreatedDate     : 25/11/2016
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testValidateBlackListCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.doCreateContact(opportunity.accountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.doCreateCreditBlackListCompany(account.Name);
        blackList.Customer_Id__c = 'NL';
        insert blackList;

        Test.startTest();
        controller = new CreditFactoryFinderController();
        controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Company found in black list. Please refer to credit.'));
    }


    /*******************************************************************************
    *  Name            : testProcessedOpportunityValidationCreditsafe()
    *  Summary         : Fill Processed by field.
    *  CreatedDate     : 19/01/2017
    *  ModifiedDate    : 14/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testProcessedOpportunityValidationCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Netherlands';
        account.BillingCountryCode = 'NL';
        account.BillingState = 'South Holland';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.bearbeitet_von__c = 'test';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Netherlands';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Your Opportunity has already received a Credit Decision or is in the ongoing Manual Review with the Credit Team.', ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /******************************************************************************
    *  Summary         : Test Desired Payment Details validation
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testValidateDesiredPaymentDetails() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'Belgium-NL';
        account.BillingCountryCode = 'BENL';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Zahlungsziel_2__c = null;
        insert opportunity;

        Contact contact = CreditFactoryUtils.doCreateContact(opportunity.accountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+7, 30+7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testValidSearchCompanyCreditsafe
    *  Summary         : Check success search company
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testValidSearchCompanyCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;
        
        Test.startTest();
        controller = new CreditFactoryFinderController();
        Test.setMock(HttpCalloutMock.class, new CreditsafeSearchMock());
        controller.init();
        Test.stopTest();
        controller.selectCompanyForReport();
        controller.backToOpporutnity();
        controller.setInvalidSearch();
    }
    
    
    /*******************************************************************************
    *  Summary         : Check success search company by name
    *  CreatedDate     : 19/02/2020
    *  Parameters      : -
    *  Returns         : 0
    ******************************************************************************/
    @isTest 
    public static void testSearhByNameCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.Steuernummer__c = null;
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;
        
        Test.startTest();
            controller = new CreditFactoryFinderController();
            Test.setMock(HttpCalloutMock.class, new CreditsafeSearchMock());
            controller.init();
        Test.stopTest();
        
        System.assert(! controller.companiesList.isEmpty());
    }


    /*******************************************************************************
    *  Name            : testValidSearchCompanyInfo()
    *  Summary         : Check success company search in Company.info
    *  CreatedDate     : 21/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidSearchCompanyInfo() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CompanyInfoSearchMock());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.selectCompanyForReport();
        Test.stopTest();
    }
}