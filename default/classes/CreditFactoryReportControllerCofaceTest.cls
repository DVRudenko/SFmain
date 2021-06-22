@isTest
private class CreditFactoryReportControllerCofaceTest {
    public static CreditfactoryReportController controller;


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
        
        CF_Order_Notifications__c notification = CreditFactoryUtils.createOrderNotificationHU();
        insert notification;

        Fuel_Price__c fuelPrice = new Fuel_Price__c();
        fuelPrice.Name = 'Hungary';
        fuelPrice.Index__c = 350;
        insert fuelPrice;
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityParameter()
    *  Summary         : Leave empty opportunity id parameter.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
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
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCompanyNumberParameter() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
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
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Credit System Settings failed. Please check Billing Country or contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystemName()
    *  Summary         : Create Credit System custom setting not with "Coface" name.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        creditSystem.Name = 'test';
        insert creditSystem;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    } 


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "Coface" name.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "Coface" name.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Coface');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testAddressValidation()
    *  Summary         : Put in Account address different from Coface company name value                   
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testAddressValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as Coface address', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testContactValidation()
    *  Summary         : Put in Contact Last name different from Coface contact Last name value                       
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testContactValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Coface Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testCompanyNameValidation()
    *  Summary         : Put in Account name different from Coface company name value
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testCompanyNameValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Coface Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTaxIdValidation()
    *  Summary         : Put in Account Tax Id different from Coface company value.                      
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTaxIdValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testVatNumberValidation()
    *  Summary         : Put in Account VAT Number different from Coface company value.                      
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTradeRegisterNumberValidation()
    *  Summary         : Put in Account Trade Register Number different from Coface company value.                      
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTradeRegisterNumberValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTradeRegisterNumber();
        Test.stopTest();

        System.assertEquals('Account Trade Register Number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Trade Register Number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Trade Register Number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testEmailRiskValidation()
    *  Summary         : Set mock response with high risk and check that error exists            
    *  CreatedDate     : 13/05/2019
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testEmailRiskValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        OpportunityContactRole contactRole = CreditFactoryUtils.createCofaceOpportunityContactRole(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
        lexisNexisSettings.Active__c = true;
        update lexisNexisSettings;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceLexisNexisMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Contact Person has a high email risk. Please refer to Credit', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testLostOpportunitiesValidation()
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testBlackListValidation()
    *  Summary         : Create Credit_Black_List_Company__c and Opportunity objects with
                         the same fields   
    *  CreatedDate     : 18/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.doCreateCreditBlackListCompany(account.Name);
        blackList.Customer_Id__c = 'HU';
        insert blackList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            Boolean isCompanyNotInBlackList = controller.reportService.validateBlackList();
        Test.stopTest();

        System.assertEquals(false, isCompanyNotInBlackList);
    }


    /*******************************************************************************
    *  Name            : testOrderRequest()
    *  Summary         : Test company search when COFACE SELECT PREMIUM is not available 
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testOrderRequest() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceOrderMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Party_Id__c, CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        
        System.assertEquals('14066436', opportunitiesList.get(0).CF_Order_Reference_Number__c);
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }


    /*******************************************************************************
    *  Name            : testOrderRequest2()
    *  Summary         : Test company select when date of last major update is too old 
    *  CreatedDate     : 13/07/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testOrderRequest2() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceOrderMock2());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Party_Id__c, CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        
        System.assertEquals('14066436', opportunitiesList.get(0).CF_Order_Reference_Number__c);
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }
 

    /*******************************************************************************
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 08/03/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating0_3() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        // for warnings check
        opportunity.Rechnungsperiode_2__c = '7';
        opportunity.Zahlungsziel_2__c = '7';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            controller.reportService.setUserSource(null);
            controller.reportService.getUserSource();
            controller.reportService.getBuffer();
            controller.reportService.getRiskCategory();
            controller.reportService.getSecurityLevel();
            controller.reportService.getCreditLimitWeeklyPlus7();
            controller.reportService.getMaxCreditLimitWeeklyPlus7();
            controller.reportService.getMaxValueWeeklyPlus7();
            controller.reportService.getDepositWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxValueBiWeeklyPlus7();
            controller.reportService.getDepositBiWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxValueBiWeeklyPlus14();
            controller.reportService.getDepositBiWeeklyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getMaxValueMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getMaxValueMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getCreditLimitMonthlyPlus14();
            controller.reportService.getMaxCreditLimitMonthlyPlus14();
            controller.reportService.getDepositMonthlyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus21();
            controller.reportService.getMaxCreditLimitMonthlyPlus21();
            controller.reportService.getDepositMonthlyPlus21();
            controller.reportService.getCreditLimitMonthlyPlus27();
            controller.reportService.getMaxCreditLimitMonthlyPlus27();
            controller.reportService.getMaxValueMonthlyPlus27();
            controller.reportService.getDepositMonthlyPlus27();
            controller.reportService.getPaymentTerms();
            controller.reportService.getCreditLimit();
            controller.reportService.getMaxCreditLimit();
            controller.reportService.getMaxValue();
            controller.reportService.getDeposit();
            controller.reportService.getDecision();
            controller.reportService.validateBlackList();
            controller.reportService.getInternalId();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 7, 7, 20000, 30000, 3500, 100, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '1', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Summary         : ClassRating = 4
    *  CreatedDate     : 08/03/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating4Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 15, 7, 40000, 70000, 3500, 100, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '4', 1, null);
            controller.changeBillingPeriodBySales();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : ClassRating = 6
    *  CreatedDate     : 08/03/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating6() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.DocuSign_Status__c = 'Completed';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        dsStatus.dsfs__Opportunity__c = opportunity.Id;
        insert dsStatus;

        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus = new dsfs__DocuSign_Recipient_Status__c();
        dsRecipientStatus.dsfs__Parent_Status_Record__c = dsStatus.Id;
        dsRecipientStatus.Name = 'Tibor BIRÓ Balázs';
        dsRecipientStatus.dsfs__DocuSign_Recipient_Id__c = '1234567890';
        insert dsRecipientStatus;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating6Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
            CreditCompany company = new CreditCompany();
            company.classRating = '6';
            company.legalform = 'Limited Liability Company';
            company.creditLimit = '180000';
            company.turnOverLastYear = '3500000';
            company.profitLossLastYear = '10000';
            company.profitLossYearBeforeLast = '100000';
            controller.reportService.resetDeposit(company, 7, 7, 30000, 70000, 3500, 100, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '6', 1, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 7', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals(0, controller.reportService.getDeposit());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check success search company
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        contact.LastName = 'ÁáÉéÍíÓóÖöŐőÚúÜüŰű';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCofaceReport();
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Class_Rating__c = '5';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCofaceReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        creditReportEmployee.Name = creditReportEmployee.Name + 'AaEeIiOoOoOoUuUuUu';
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            company.legalform = 'Sole proprietorship';
            company.creditLimit = '180000';
            company.turnOverLastYear = '3500000';
            company.profitLossLastYear = '-10000';
            company.profitLossYearBeforeLast = '100000';
            controller.reportService.resetDeposit(company, 15, 14, 240000, 440000, 3500, 600, opportunity.Id);
            controller.reportService.resetDecision(15, 14, 0, '5', 1, null);
            controller.changeToContractCheck();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : ClassRating = 99
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testOrderedReportRating99() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCofaceReport();
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Class_Rating__c = '99';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCofaceReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '99';
            controller.reportService.resetDeposit(company, 15, 7, 30000, 70000, 3500, 100, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 30000, '0', 1, null);
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT StageName, Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales – Deposit', opportunitiesList.get(0).StageName);
        System.assertEquals(100, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }
}