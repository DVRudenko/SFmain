@isTest
private class CreditFactoryReportControllerTestAT {
    public static CreditFactoryReportController controller;


    /*******************************************************************************
    *  Name            : createDataForAllTests()
    *  Summary         : Create data for all test methods
    *  CreatedDate     : 11/05/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup 
    static void createDataForAllTests() {
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryUtils.createLexisNexisSettings();
        insert lexisNexisSettings;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Fuel_Price__c fuelPrice = new Fuel_Price__c();
        fuelPrice.Name = 'Austria';
        fuelPrice.Index__c = 1.15;
        insert fuelPrice;
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityParameter()
    *  Summary         : Leave empty opportunity id parameter.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityParameter() {
        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid opportunityId parameter.Please contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCompanyNumberParameter()
    *  Summary         : Leave empty credit system id parameter. 
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCompanyNumberParameter() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid creditSystemCompanyNumber parameter.' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystem()
    *  Summary         : Don't create Credit System custom setting.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Select Credit System Settings failed. Please check Billing Country or contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystemName()
    *  Summary         : Create Credit System custom setting not with "CreditreformAT" name.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        creditSystem.Name = 'test';
        insert creditSystem;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "CreditreformAT" name.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        creditFactoryAccount.Name = 'test';
        insert creditFactoryAccount;

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "CreditreformAT" name.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        creditFactoryOpportunity.Name = 'test';
        insert creditFactoryOpportunity;

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testAddressValidation()
    *  Summary         : Put in Account address different from Creditreform company name value                   
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testAddressValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
            controller.doUpdateWithAdditionalAddress();
            controller.doUpdateWithPostalAddress();
            controller.doUpdateWithRegisteredAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as Crefo address', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testLegalFormValidation()
    *  Summary         : Check valid legal form                       
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLegalFormValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportPublicEntityMockAT());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Customer is a public entity.', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testContactValidation()
    *  Summary         : Put Last name in Contact different from Creditreform contact Last name value.                    
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testContactValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Crefo Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testCompanyNameValidation()
    *  Summary         : Put name in Account different from Creditreform company name value
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testCompanyNameValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.companyNameType = 'Registered Name';
            controller.doUpdateCompanyName();
            controller.doUpdateWithAdditionalCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Crefo Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTaxIdValidation()
    *  Summary         : Put Tax Id in Account different from Creditreform company value.                      
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTaxIdValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
            controller.doUpdateTradeRegisterNumber();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (Creditreform to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testVatNumberValidation()
    *  Summary         : Put in Account VAT Number different from Coface company value.                      
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (Creditreform to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }
    
    
    /******************************************************************************
    *  Name            : testSwiftBicValidation()
    *  Summary         : Check case with different SWIFT BIC numbers from sales and web service                       
    *  CreatedDate     : 31/10/2019
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSwiftBicValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.SWIFT_BIC__c = 'test';
        opportunity.Requested_SWIFT_BIC__c = 'SPIHAT22XXX';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateSwiftBic();
        Test.stopTest();

        System.assertEquals('Entered BIC is invalid. Please note that your Customer will need to re- confirm SEPA form with correct bank details', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Opportunity SWIFT BIC has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testEmailRiskValidation()
    *  Summary         : Set mock response with high risk and check that error exists            
    *  CreatedDate     : 14/05/2019
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testEmailRiskValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        OpportunityContactRole contactRole = CreditFactoryUtils.createCreditreformOpportunityContactRoleAT(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
        lexisNexisSettings.Active__c = true;
        update lexisNexisSettings;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformLexisNexisMockAT());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Contact Person has a high email risk. Please refer to Credit', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testLostOpportunitiesValidation()
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testDoOrder()
    *  Summary         : Test do order in case of report is not available.
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testDoOrder() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformOrderMockAT());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('40374221', opportunitiesList.get(0).CF_Order_Reference_Number__c);
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }


    /*******************************************************************************
    *  Name            : testBlackListValidation()
    *  Summary         : Create Credit_Black_List_Company__c and Opportunity objects with the same fields.  
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.createCreditreformBlackListAT(account.Name);
        insert blackList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            Boolean isValid = controller.reportService.validateBlackList();
        Test.stopTest();

        System.assertEquals(false, isValid);
    }
 

    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.getBuffer();
            controller.reportService.getRiskCategory();
            controller.reportService.getSecurityLevel();
            controller.reportService.getCreditLimitWeeklyPlus7();
            controller.reportService.getMaxCreditLimitWeeklyPlus7();
            controller.reportService.getDepositWeeklyPlus7();
            controller.reportService.getMaxValueWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus7();
            controller.reportService.getDepositBiWeeklyPlus7();
            controller.reportService.getMaxValueBiWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getMaxValueMonthlyPlus7();
            controller.reportService.getCreditLimitMonthlyPlus14();
            controller.reportService.getMaxCreditLimitMonthlyPlus14();
            controller.reportService.getDepositMonthlyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus21();
            controller.reportService.getMaxCreditLimitMonthlyPlus21();
            controller.reportService.getDepositMonthlyPlus21();
            controller.reportService.getCreditLimitMonthlyPlus27();
            controller.reportService.getMaxCreditLimitMonthlyPlus27();
            controller.reportService.getDepositMonthlyPlus27();
            controller.reportService.getMaxValueMonthlyPlus27();
            controller.reportService.getPaymentTerms();
            controller.reportService.getCreditLimit();
            controller.reportService.getMaxCreditLimit();
            controller.reportService.getMaxValue();
            controller.reportService.getDeposit();
            controller.reportService.getDecision();
            controller.changeToClosedWon();
            controller.changeToContractCheck();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '1', 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testDuplicatesCheck()
    *  Summary         : Test duplicate case
    *  CreatedDate     : 31/05/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testDuplicatesCheck() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        Account account2 = CreditFactoryUtils.createCreditReformAccountAT();
        accountsList.add(account);
        account2.Steuernummer__c = '123412341234';
        accountsList.add(account2);
        insert accountsList;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
        Test.stopTest();

        List<Opportunity> opportunitiesToCheckList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('CreditCheck', opportunitiesToCheckList.get(0).StageName);
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating2()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 4500;
        // for warnings check
        opportunity.Rechnungsperiode_2__c = '10';
        opportunity.Zahlungsziel_2__c = '10';
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating2MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '2', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales - SEPA Confirmation', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating3() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating3MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '3', 1, company);
            controller.changeBillingPeriodBySales();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : ClassRating = 4.
    *  CreatedDate     : 03/10/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4() {
         Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 6000;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating4MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '4', 1, company);
            controller.backToOpportunity();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(4, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }

    
    /*******************************************************************************
    *  Summary         : ClassRating = 5
    *  CreatedDate     : 03/10/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating5() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Anzahl_der_Karten__c = 3;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating5MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '5', 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating6()
    *  Summary         : ClassRating = 6.
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating6() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating6MockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '6';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '6', 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Summary         : ClassRating = null, no exceptions
    *  CreatedDate     : 03/10/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodNoRating() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 1000;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportNoRatingMockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
        
        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }
    
    
    /*******************************************************************************
    *  Summary         : ClassRating = null, no exceptions
    *  CreatedDate     : 03/10/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodNoRating() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 800;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportNoRatingMockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = null;
            controller.reportService.resetDeposit(company, 15, 7, 900, 1800, 800, 1100, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, null, null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodNoRatingDeposit()
    *  Summary         : ClassRating = null with deposit
    *  CreatedDate     : 03/10/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodNoRatingDeposit() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportNoRatingMockAT());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = null;
            controller.reportService.resetDeposit(company, 15, 7, 2200, 4400, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, null, 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testExistingCompanyCreditreform()
    *  Summary         : Check success search company
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompanyCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        contact.LastName = contact.LastName + 'ÄäÖöÜüß';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportAT(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        creditReportEmployee.Name = creditReportEmployee.Name + 'AEaeOEoeUEuess';
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.setUserSource('test');
            controller.reportService.getUserSource();
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.saveReports();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testNewBusinessExceptionRating1()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 07/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testNewBusinessExceptionRating1() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 200;
        opportunity.Anzahl_der_Karten__c = 1;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportAT(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Date_of_Foundation__c = String.valueOf(Date.today());
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testNewBusinessExceptionRating2()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 07/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testNewBusinessExceptionRating2() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 200;
        opportunity.Anzahl_der_Karten__c = 1;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportAT(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Date_of_Foundation__c = String.valueOf(Date.today());
        creditReport.Class_Rating__c = '2';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testNewBusinessExceptionRating3()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 07/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testNewBusinessExceptionRating3() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 200;
        opportunity.Anzahl_der_Karten__c = 1;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportAT(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Date_of_Foundation__c = String.valueOf(Date.today());
        creditReport.Class_Rating__c = '3';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testNewBusinessExceptionRating4()
    *  Summary         : ClassRating = 4
    *  CreatedDate     : 07/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testNewBusinessExceptionRating4() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 400;
        opportunity.Anzahl_der_Karten__c = 1;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportAT(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Date_of_Foundation__c = String.valueOf(Date.today());
        creditReport.Class_Rating__c = '4';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testNewBusinessExceptionRating5()
    *  Summary         : ClassRating = 5
    *  CreatedDate     : 07/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testNewBusinessExceptionRating5() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 300;
        opportunity.Anzahl_der_Karten__c = 1;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportAT(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Date_of_Foundation__c = String.valueOf(Date.today());
        creditReport.Class_Rating__c = '5';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testNewBusinessExceptionRatingNull()
    *  Summary         : ClassRating = null
    *  CreatedDate     : 07/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testNewBusinessExceptionRatingNull() {
        Account account = CreditFactoryUtils.createCreditReformAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityAT(account.Id);
        opportunity.Total_consumption_l_month__c = 200;
        opportunity.Anzahl_der_Karten__c = 1;
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactAT(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportAT(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Date_of_Foundation__c = String.valueOf(Date.today());
        creditReport.Class_Rating__c = null;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeAT(creditReport.Id);
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }
}