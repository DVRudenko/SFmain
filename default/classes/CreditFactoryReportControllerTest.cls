@isTest
private class CreditFactoryReportControllerTest {
    public static CreditFactoryReportController controller; 


    /*******************************************************************************
    *  Summary         : Create data for all test methods
    *  CreatedDate     : 11/05/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @testSetup 
    static void createDataForAllTests() {
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryUtils.createLexisNexisSettings();
        insert lexisNexisSettings;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;
        
        List<Fuel_Price__c> fuelPricesList = new List<Fuel_Price__c>();
        Fuel_Price__c fuelPriceNL = new Fuel_Price__c(Name = 'Netherlands', Index__c = 1.6);
        fuelPricesList.add(fuelPriceNL);
        Fuel_Price__c fuelPriceBENL = new Fuel_Price__c(Name = 'Belgium-NL', Index__c = 1.6);
        fuelPricesList.add(fuelPriceBENL);
        Fuel_Price__c fuelPriceBEFR = new Fuel_Price__c(Name = 'Belgium-FR', Index__c = 1.6);
        fuelPricesList.add(fuelPriceBEFR);
        Fuel_Price__c fuelPriceFR = new Fuel_Price__c(Name = 'France', Index__c = 1.6);
        fuelPricesList.add(fuelPriceFR);
        insert fuelPricesList;
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunity()
    *  Summary         : Check not existing opportunity id 
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunity() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        controller = new CreditfactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Invalid opportunityId parameter.Please contact your administrator.');
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Invalid creditSystemCompanyNumber parameter.' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*******************************************************************************
    *  Name            : testInvalidSelected()
    *  Summary         : Chek empty field Supported_Countries__c for CreditSystem
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSelected() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Credit System Settings failed. Please check Billing Country or contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testInvalidReportService()
    *  Summary         : Check invalid name for CreditSystem__c
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidReportService() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Test';
        insert creditSystem;
        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    } 


    /******************************************************************************
    *  Name            : testTradeRegisterNumberValidationCreditsafe()
    *  Summary         : Put in Account Trade Register Number different from Creditsafe company value.                      
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTradeRegisterNumberValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'France';
        account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTradeRegisterNumber();
        Test.stopTest();

        System.assertEquals('Account Trade Register Number mismatch (' + CreditSafeWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Trade Register Number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Trade Register Number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidMappingCreditSafe()
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
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditsafe';
        insert accountMapping;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*****************************************************************************
    *  Name            : testInvalidCurrentOpportunityCreditsafe()
    *  Summary         : Check selecting opportunity with fields from mapping
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void 
    ****************************************************************************/
    @isTest
    public static void testInvalidCurrentOpportunityCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditsafe';
        accountMapping.Number_of_employees__c = 'test';
        insert accountMapping;
        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        opportunityMapping.Name = 'Creditsafe';
        insert opportunityMapping;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Opportunity failed. Please contact your administrator.');
    }
    

    /*******************************************************************************
    *  Name            : testCreatingAttachmentCreditsafe()
    *  Summary         : Test pdf creation
    *  CreatedDate     : 25/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCreatingAttachmentCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            Set<String> companyIdsSet = new Set<String>{'NL-X-502603400000', 'NL-X-502603400001', 'NL-X-502603400002'};
            ReportCreditsafeService.PDFReportCreation pdfCreation = new ReportCreditsafeService.PDFReportCreation(companyIdsSet, opportunity, 'NL-X-502603400001');
            QueueableContext context;
            pdfCreation.execute(context);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE ParentId = :opportunity.Id AND (Name = 'CreditsafeReport.pdf' OR Name = 'CreditsafeReportParent.pdf')];

        System.assertEquals(2, attachmentsList.size());
    }


    /*******************************************************************************
    *  Name            : testCompanyInfoContacts()
    *  Summary         : Check contacts from company info                  
    *  CreatedDate     : 06/03/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCompanyInfoContacts() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        CreditSystem__c creditSystemCompanyInfo = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert creditSystemCompanyInfo;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Credit_Factory_Report_Employee__c> listToTest = [
                SELECT Name
                FROM Credit_Factory_Report_Employee__c
                WHERE Name LIKE '%Hakan%'
                LIMIT 1000];
        System.assert( ! listToTest.isEmpty() );
    }


    /*******************************************************************************
    *  Name            : testValidateAddressCreditSafe()
    *  Summary         : Check valid address   
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateAddressCreditSafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', 'NL007/X/200340990002');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
            controller.doUpdateWithAdditionalAddress();
            controller.doUpdateWithPostalAddress();
            controller.doUpdateWithRegisteredAddress();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account Billing and Shipping Addresses should be the same as Creditsafe address');
    }


    /*******************************************************************************
    *  Name            : testValidateEmptyAddressCreditSafe()
    *  Summary         : Check valid address
    *  CreatedDate     : 02/10/2020
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateEmptyAddressCreditSafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', 'NL007/X/200340990002');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Credit_Factory_Report__c newReport = CreditFactoryUtils.createCreditsafeReport();
        newReport.Opportunity__c = opportunity.Id;
        newReport.City__c = null;
        insert newReport;

        Credit_Factory_Report_Employee__c employee = CreditFactoryUtils.createCreditsafeReportEmployee();
        employee.Credit_Factory_Report__c = newReport.Id;
        insert employee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Company has no known address.', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testValidateContactCreditsafe()
    *  Summary         : Check valid contact             
    *  CreatedDate     : 22/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateContactCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', 'NL007/X/200340990002');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;
    
        Credit_Factory_Report__c newReport = CreditFactoryUtils.createCreditsafeReport();
        newReport.Opportunity__c = opportunity.Id;
        insert newReport;

        Credit_Factory_Report_Employee__c employee = CreditFactoryUtils.createCreditsafeReportEmployee();
        employee.Credit_Factory_Report__c = newReport.Id;
        employee.Name = 'Freyja Fence B.V.';
        insert employee;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeOwnedByCompanyMock());
            controller = new CreditFactoryReportController();
            controller.init();
            System.assertEquals('NL001-X-634214960000', controller.parentCompanyId);
            controller.doParentCompanyRequest();
            controller.continueValidation();
            controller.changeToPendingDeposit();
        Test.stopTest();

        System.assertEquals('Creditsafe Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opList.get(0).Security_level_H_he_der_Sicherheit__c);

        List<Credit_Factory_Report_Employee__c> testEmployees = [
                SELECT Reported__c
                FROM Credit_Factory_Report_Employee__c
                WHERE Id = :employee.Id];

        System.assertEquals(true, testEmployees.get(0).Reported__c);
    }



    /******************************************************************************
    *  Name            : testValidateCompanyNameCreditsafe()
    *  Summary         : Check valid company name
    *  CreatedDate     : 22/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateCompanyNameCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.doCreateContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
            controller.doUpdateWithAdditionalCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Creditsafe Name mismatch', (ApexPages.getMessages().get(0).getSummary()));
    }


    /****************************************************************************
    *  Name            : testTaxIdValidationCreditsafe()
    *  Summary         : Put in Account Tax Id different from Creditsafe company name value.                      
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ***************************************************************************/
    @isTest
    public static void testTaxIdValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (' + CreditsafeWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testVatNumberValidationCreditsafe()
    *  Summary         : Put in Account Vat Number different from Creditsafe company name value.                      
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (' + CreditsafeWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testEmailRiskValidationCreditsafe()
    *  Summary         : Set mock response with high risk and check that error exists                      
    *  CreatedDate     : 13/05/2019
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testEmailRiskValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        OpportunityContactRole contactRole = CreditFactoryUtils.createCreditsafeOpportunityContactRole(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
        lexisNexisSettings.Active__c = true;
        update lexisNexisSettings;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeLexisNexisMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Contact Person has a high email risk. Please refer to Credit', ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /******************************************************************************
    *  Name            : testSwiftBicValidationCreditsafe()
    *  Summary         : Check case with different SWIFT BIC numbers from sales and web service                       
    *  CreatedDate     : 31/10/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSwiftBicValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.SWIFT_BIC__c = 'test';
        opportunity.Requested_SWIFT_BIC__c = 'INGBNL2A';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateSwiftBic();
        Test.stopTest();

        System.assertEquals('Entered BIC is invalid. Please note that your Customer will need to re- confirm SEPA form with correct bank details', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Opportunity SWIFT BIC has been updated.', ApexPages.getMessages().get(2).getSummary());
    }
    
    
    /******************************************************************************
    *  Summary         : Check case with risky business code                
    *  CreatedDate     : 21/04/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testBusinessCodeValidation() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;
        
        CF_Risky_Business_Code__c businessCode = new CF_Risky_Business_Code__c(Name = '6420', Countries__c = 'NL,BEFR,BENL,FR');
        insert businessCode;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('High risk industry. Please refer to Credit', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testLostOpportunitiesValidationCreditsafe()
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testPaymentMethodValidation()
    *  Summary         : Create Opportunity with "Bank Transfer" payment method    
    *  CreatedDate     : 25/04/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testPaymentMethodValidation() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Zahlungsart__c = 'Banküberweisung';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity cannot be closed automatically with Payment Method Bank Transfer.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testCalculateCreditLimitCreditsafe()
    *  Summary         : Check calculation Weekly+7, BiWeekly+7, Monthly+7 CreditLimit
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCalculateCreditLimitCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        opportunityMapping.Monthly_Volume_Currency__c = 'test';
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Limit Weekly + 7 calculation failed. Please contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1Creditsafe()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.SEPA_Request_Approved__c = true;
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
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
            controller.changeToClosedWon();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 7, 7, 900, 900, 1000, 600, opportunity.Id);
            company.dateOfFoundation = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 900, 900, 1000, 600, opportunity.Id);
            company.dateOfLastChangeOfDirector = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 900, 900, 1000, 600, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '1', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testDuplicatesCheckCreditsafe()
    *  Summary         : Test duplicate case
    *  CreatedDate     : 10/06/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testDuplicatesCheckCreditsafe() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        Account account2 = CreditFactoryUtils.createCreditsafeAccount();
        accountsList.add(account);
        account2.Steuernummer__c = '123412341234';
        accountsList.add(account2);
        insert accountsList;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
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


    /*******************************************************************************
    *  Name            : test2SetBillingPeriodRating1Creditsafe()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating1Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'Belgium-FR';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.SEPA_Request_Approved__c = true;
        opportunity.Total_consumption_l_month__c = 1000;
        opportunity.Zahlungsziel_2__c = '30';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 30, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 1500, '1', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : test3SetBillingPeriodRating1Creditsafe()
    *  Summary         : Test company with rating 1 and invalid contact
    *  CreatedDate     : 17/04/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test3SetBillingPeriodRating1Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        contact.LastName = 'test';
        contact.Phone = '+49123123123';
        contact.Email = 'test@test.com';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 30, 7, 1000, 0, 2000, 600, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 1000, '1', 1, company);
        Test.stopTest();

        System.assertEquals('Creditsafe Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating2Creditsafe()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 7, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            company.dateOfFoundation = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            company.dateOfLastChangeOfDirector = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 1500, '2', null, company);
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Billing Period can be set to 7');
    }


    /*****************************************************************************
    *  Name            : test2SetBillingPeriodRating2Creditsafe()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating2Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 1000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 7, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 1500, '2', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : test3SetBillingPeriodRating2Creditsafe()
    *  Summary         : Test company with rating 2 and invalid contact
    *  CreatedDate     : 17/04/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test3SetBillingPeriodRating2Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        contact.LastName = 'test';
        contact.Phone = '+49123123123';
        contact.Email = 'test@test.com';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 30, 7, 1000, 0, 2000, 600, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 1000, '2', 1, company);
        Test.stopTest();

        System.assertEquals('Creditsafe Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3Creditsafe()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating3Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Kraftstoffverbrauch_Liter_Monat__c = 23;
        opportunity.Total_consumption_l_month__c = 6000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            company.dateOfFoundation = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            company.dateOfLastChangeOfDirector = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 3000, '3', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating3Creditsafe()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating3Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating3Mock2());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 7, 7, 1000, 1000, 800, 600, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 1000, '3', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : test3SetBillingPeriodRating3Creditsafe()
    *  Summary         : Test company with rating 3 and invalid contact
    *  CreatedDate     : 17/04/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test3SetBillingPeriodRating3Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        contact.LastName = 'test';
        contact.Phone = '+49123123123';
        contact.Email = 'test@test.com';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 30, 7, 1000, 0, 2000, 600, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 1000, '3', 1, company);
        Test.stopTest();

        System.assertEquals('Creditsafe Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4Creditsafe()
    *  Summary         : ClassRating = 4 
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        opportunity.Anzahl_der_Karten__c = 2;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating4Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            company.dateOfFoundation = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            company.dateOfLastChangeOfDirector = '2010-10-10';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 3000, '4', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : test2SetBillingPeriodRating4Creditsafe()
    *  Summary         : Test company with rating 4 and invalid contact
    *  CreatedDate     : 17/04/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating4Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        contact.LastName = 'test';
        contact.Phone = '+49123123123';
        contact.Email = 'test@test.com';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating4Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 30, 7, 1000, 0, 2000, 600, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 1000, '4', 1, company);
        Test.stopTest();

        System.assertEquals('Creditsafe Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating5Creditsafe()
    *  Summary         : ClassRating = 5 
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating5Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating5Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            controller.changeBillingPeriodBySales();
            controller.backToOpportunity();
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 3000, '5', null, null);
            controller.reportService.setUserSource('E2E Long Form');
            controller.doValidate();
            // cover update of report from E2E
            controller = new CreditFactoryReportController();
            CreditSystem creditService = new CreditSystemService(); 
            creditService.setCreditSystemSource(opportunity.Id);
            controller.reportService = controller.returnReportService(creditService.getCreditSystemName(), opportunity.Id);
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.setMapping();
            controller.reportService.setSourceObject(opportunity.Id);
            controller.reportService.setExistingCreditReports();
            controller.reportService.setCompany(controller.creditService, null);
            controller.company = (CreditCompany)controller.reportService.getCompany();
            controller.reportService.setEmployees();
            controller.reportService.setAdditionalCompany(null);
            controller.reportService.setAdditionalCompanyEmployees(null);
            controller.calculateBillingPeriod();
            controller.reportService.getDecision();
            controller.reportService.saveReports();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodCompanyInfo()
    *  Summary         : There is no Creditsafe report, but 
    *  CreatedDate     : 19/08/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSetBillingPeriodCompanyInfo() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');
        ApexPages.currentPage().getParameters().put('isCompanyAdditional', 'true');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating5Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
        Test.stopTest();

        System.assertEquals('Credit Report for your Company is not available in Creditsafe. ' + 
            'You can close the customer with Deposit decision or refer to Credit.', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testExistingCompanyCreditsafe()
    *  Summary         : Check CF launch with existing Credit_Factory_Report__C
    *  CreatedDate     : 27/06/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompanyCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'France';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        contact.LastName = contact.LastName + 'ÇçÉéÂâÊêÎîÔôÛûÀàÈèÙùËëÏïÜü';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<Credit_Factory_Report__c> creditReportsList = new List<Credit_Factory_Report__c>();
        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditsafeReport();
        creditReport.Opportunity__c = opportunity.Id;
        creditReportsList.add(creditReport);
        Credit_Factory_Report__c creditReport2 = CreditFactoryUtils.createCreditsafeReport();
        creditReport2.Opportunity__c = opportunity.Id;
        creditReport2.RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', 'Company Info');
        creditReportsList.add(creditReport2);
        insert creditReportsList;

        List<Credit_Factory_Report_Employee__c> creditReportsEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditsafeReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        creditReportEmployee.Name = creditReportEmployee.Name + 'CcEeAaEeIiOoUuAaEeUuEeIiUu';
        creditReportsEmployeesList.add(creditReportEmployee);
        Credit_Factory_Report_Employee__c creditReportEmployee2 = CreditFactoryUtils.createCreditsafeReportEmployee();
        creditReportEmployee2.Credit_Factory_Report__c = creditReport2.Id;
        creditReportEmployee2.Name = creditReportEmployee2.Name + 'CcEeAaEeIiOoUuAaEeUuEeIiUu';
        creditReportEmployee2.RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Company Info');
        creditReportsEmployeesList.add(creditReportEmployee2);
        insert creditReportsEmployeesList;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : test2ExistingCompanyCreditsafe()
    *  Summary         : Check CF launch with existing Credit_Factory_Report__c (rating 1)
    *  CreatedDate     : 17/04/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void test2ExistingCompanyCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'France';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditsafeReport();
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Class_Rating__c = '1';
        creditReport.Legal_Form__c = 'Artisans';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditsafeReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : test3ExistingCompanyCreditsafe()
    *  Summary         : Check CF launch with existing Credit_Factory_Report__c (rating 2)
    *  CreatedDate     : 17/04/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void test3ExistingCompanyCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'France';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditsafeReport();
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Class_Rating__c = '2';
        creditReport.Legal_Form__c = 'Artisans';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditsafeReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testBranchCompany()
    *  Summary         : Test case "no rating - branch, refer to head office report."
    *  CreatedDate     : 22/08/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testBranchCompany() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', 'NL001-X-705755090001');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;
        
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.creditsafe.com/v1/authenticate', authMock);
            SingleRequestMock branchReportMock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-705755090001","dateOfOrder": "2019-08-22T11:29:44.317Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-705755090001","language": "EN","companySummary": {"businessName": "Testgear B.V.","country": "NL","companyNumber": "NL04949273","companyRegistrationNumber": "50260340","mainActivity": {"code": "45205","description": "Other specialised repair; washing and towing of motor vehicles","classification": "SBI 2008"},"companyStatus": {"status": "Other","description": "-"},"creditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - branch, refer to head office report."}},"companyIdentification": {"basicInformation": {"businessName": "Testgear B.V.","registeredCompanyName": "Carwash De kade","companyRegistrationNumber": "50260340","country": "NL","companyRegistrationDate": "2018-11-13T00:00:00Z","operationsStartDate": "2018-11-13T00:00:00Z","legalForm": {"providerCode": "1","description": "Sole trader with one owner"},"companyStatus": {"status": "Other","description": "-"},"principalActivity": {"code": "45205","description": "Other specialised repair; washing and towing of motor vehicles","classification": "SBI 2008"},"contactAddress": {"simpleValue": "119 A Aelbrechtskade, ROTTERDAM 3023JE","street": "Aelbrechtskade","houseNumber": "119 A","city": "ROTTERDAM","postalCode": "3023JE","province": "Zuid-Holland","telephone": "0685770814","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "45205","description": "Other specialised repair; washing and towing of motor vehicles"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - branch, refer to head office report."}},"contactInformation": {"mainAddress": {"simpleValue": "119 A Aelbrechtskade, ROTTERDAM 3023JE","street": "Molensingel","houseNumber": "10","city": "DELFT","postalCode": "2614LB","province": "Zuid-Holland","telephone": "0685770814","country": "NL"},"otherAddresses": [{"simpleValue": "119 Aelbrechtskade, ROTTERDAM 3023JE","street": "Aelbrechtskade","houseNumber": "119","city": "ROTTERDAM","postalCode": "3023JE","telephone": "0685770814","country": "NL"}]},"additionalInformation": {"misc": {"exporter": "No","importer": "No","negativeRating": -992,"kvkStatus": "C-Changed","branchNumber": "000041161084"},"industryQuartileAnalysis": {"paymentExpectationDays": {"paymentExpectationsLower": 31.19,"paymentExpectationsMedian": 47.08,"paymentExpectationsUpper": 47.08},"daySalesOutstanding": {"daySalesOutstandingLower": 16.98,"daySalesOutstandingMedian": 16.98,"daySalesOutstandingUpper": 16.98}},"industryComparison": {"industryAverageCreditRating": 51.29,"industryAverageCreditLimit": 12480.85},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","industryAveragePaymentExpectationDays": 13.67,"industryAverageDaySalesOutstanding": 41.38},"companyHistory": [{"date": "2018-12-20T22:54:50Z","description": "Company name changed.","previousValue": "Gouden Wasstraat","currentValue": "Carwash De kade"},{"date": "2018-12-20T23:01:04Z","description": "TRADING NAME CHANGE","previousValue": "Gouden Wasstraat","currentValue": "Carwash De kade"}],"tradingStyles": [{"tradingName": "Carwash De kade"}]}}}', null);
            mocksMap.put('https://connect.creditsafe.com/v1/companies/NL001-X-705755090001', branchReportMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"totalSize": 1,"companies": [{"id": "NL001-X-705755090000","country": "NL","regNo": "705755090000","safeNo": "NL04703830","name": "Gold Entertainment","tradingNames": ["Gold Entertainment"],"address": {"simpleValue": "149 C, Hilledijk, 3072RJ, ROTTERDAM","street": "Hilledijk","city": "ROTTERDAM","postCode": "3072RJ","houseNo": "149 C"},"status": "active","officeType": "headOffice","dateOfLatestChange": "2019-08-09T23:20:43.000Z","activityCode": "5920","statusDescription": "ACTIVE"}]}', null);
            mocksMap.put('https://connect.creditsafe.com/v1/companies?countries=NL&regNo=50260340&officeType=headOffice', searchMock);
            SingleRequestMock headOfficeReportMock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-705755090000","dateOfOrder": "2019-08-22T13:42:03.066Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-705755090000","language": "EN","companySummary": {"businessName": "Gold Entertainment","country": "NL","companyNumber": "NL04703830","companyRegistrationNumber": "70575509","mainActivity": {"code": "5920","description": "Sound recording and music publishing","classification": "SBI 2008"},"companyStatus": {"status": "Active","description": "ACTIVE"},"creditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "6500"},"providerValue": {"maxValue": "100","minValue": "0","value": "64"},"providerDescription": "Very low chance of financial calamity"}},"companyIdentification": {"basicInformation": {"businessName": "Gold Entertainment","registeredCompanyName": "Gold Entertainment","companyRegistrationNumber": "70575509","country": "NL","companyRegistrationDate": "2018-01-09T00:00:00Z","operationsStartDate": "2018-01-09T00:00:00Z","legalForm": {"providerCode": "1","description": "Sole trader with one owner"},"companyStatus": {"status": "Active","description": "ACTIVE"},"principalActivity": {"code": "5920","description": "Sound recording and music publishing","classification": "SBI 2008"},"contactAddress": {"simpleValue": "149 C Hilledijk, ROTTERDAM 3072RJ","street": "Hilledijk","houseNumber": "149 C","city": "ROTTERDAM","postalCode": "3072RJ","province": "Zuid-Holland","telephone": "0687861726","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "5920","description": "Sound recording and music publishing"},{"code": "77111","description": "Renting of passenger cars and light motor vehicles (no operational lease)"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "6500"},"providerValue": {"maxValue": "100","minValue": "0","value": "64"},"providerDescription": "Very low chance of financial calamity"},"previousCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "6500"},"providerValue": {"value": "60"},"providerDescription": "Very low chance of financial calamity"},"latestRatingChangeDate": "2018-08-31T18:59:27Z"},"contactInformation": {"mainAddress": {"simpleValue": "149 C Hilledijk, ROTTERDAM 3072RJ","street": "Hilledijk","houseNumber": "149 C","city": "ROTTERDAM","postalCode": "3072RJ","province": "Zuid-Holland","telephone": "0687861726","country": "NL"},"otherAddresses": [{"simpleValue": "149 Hilledijk, ROTTERDAM 3072RJ","street": "Hilledijk","houseNumber": "149","city": "ROTTERDAM","postalCode": "3072RJ","telephone": "0687861726","country": "NL"}]},"additionalInformation": {"misc": {"exporter": "No","importer": "No","kvkStatus": "A-New in the register","branchNumber": "000038829835","employeeNumber": "1","employeeClass": "02"},"industryComparison": {"industryAverageCreditRating": 62.82,"industryAverageCreditLimit": 9702.56},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","industryAveragePaymentExpectationDays": 9.33,"industryAverageDaySalesOutstanding": 26.54},"ratingHistory": [{"commonValue": "B","commonDescription": "Low Risk","providerValue": {"value": "60"},"date": "2018-08-31T18:59:27Z"},{"commonValue": "D","commonDescription": "High Risk","providerValue": {"value": "21"},"date": "2018-01-22T09:56:09Z"}],"limitHistory": [{"date": "2018-08-31T18:59:27Z","companyValue": 6500},{"date": "2018-01-22T09:56:09Z","companyValue": 0}],"commentaries": [{"commentaryText": "The business was established over 19 months ago.","positiveOrNegative": "Neutral"},{"commentaryText": "Newly established businesses are proven to be more of an insolvency risk than more established businesses.","positiveOrNegative": "Negative"},{"commentaryText": "The business has 1 employees.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has been at the address for over 19 months.","positiveOrNegative": "Neutral"},{"commentaryText": "There has been no significant change in the business\'s credit limit.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit rating for this business has increased from 60 to 64 on 10-08-2019.","positiveOrNegative": "Positive"}],"tradingStyles": [{"tradingName": "Gold Entertainment"}]}}}', null);
            mocksMap.put('https://connect.creditsafe.com/v1/companies/NL001-X-705755090000', headOfficeReportMock);

            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);

            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        Credit_Factory_Report__c report = [
               SELECT Class_Rating__c
               FROM Credit_Factory_Report__c
               WHERE Opportunity__c = :opportunity.Id];
        
        System.assertEquals('2', report.Class_Rating__c);// rating of head office company
    }


    /******************************************************************************
    *  Name            : test403Statement()
    *  Summary         : Test case "no rating - 403 statement filed, check parent company."
    *  CreatedDate     : 26/08/2019
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void test403Statement() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', 'NL001-X-705755090001');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;
        
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.creditsafe.com/v1/authenticate', authMock);
            SingleRequestMock report403Mock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-050364190000","dateOfOrder": "2019-08-26T14:40:45.387Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-050364190000","language": "EN","companySummary": {"businessName": "Royal Huisman Shipyard B.V.","country": "NL","companyNumber": "NL00209533","companyRegistrationNumber": "05036419","mainActivity": {"code": "3012","description": "Building of pleasure and sporting boats","classification": "SBI 2008"},"companyStatus": {"status": "Other","description": "ACTIVE"},"creditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - 403 statement filed, check parent company."}},"companyIdentification": {"basicInformation": {"businessName": "Royal Huisman Shipyard B.V.","registeredCompanyName": "Royal Huisman Shipyard B.V.","companyRegistrationNumber": "05036419","country": "NL","companyRegistrationDate": "1983-07-29T00:00:00Z","operationsStartDate": "1930-06-05T00:00:00Z","legalForm": {"providerCode": "41","description": "Private limited liability company (BV) with ordinary structure"},"companyStatus": {"status": "Other","description": "ACTIVE"},"principalActivity": {"code": "3012","description": "Building of pleasure and sporting boats","classification": "SBI 2008"},"contactAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "3012","description": "Building of pleasure and sporting boats"},{"code": "Jachtwerf, bouwen, verbouwen en repareren van,zeilboten en motorjachten. De export van,zeilboten en motorjachten."}]}]},"creditScore": {"currentCreditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - 403 statement filed, check parent company."},"previousCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "1750000"},"providerValue": {"value": "60"},"providerDescription": "Very low chance of financial calamity"},"latestRatingChangeDate": "2019-01-02T23:30:37Z"},"contactInformation": {"mainAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"},"otherAddresses": [{"simpleValue": "23 Postbus, VOLLENHOVE 8325ZG","street": "Postbus","houseNumber": "23","city": "VOLLENHOVE","postalCode": "8325ZG","telephone": "0527243131","country": "NL"}],"websites": ["www.royalhuisman.com"]},"shareCapitalStructure": {"issuedShareCapital": {"value": 19000},"shareHolders": [{"name": "Huisman Beheer B.V.","address": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","country": "NL"},"shareholderType": "Other","percentSharesHeld": 100}]},"directors": {"currentDirectors": [{"id": "05036419","name": "Jan Timmerman","firstNames": "Jan","surname": "Timmerman","gender": "Unknown","dateOfBirth": "1966-05-02T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2018-08-01T00:00:00Z","positionName": "Algemeen directeur","authority": "Alleen/zelfstandig bevoegd"}]},{"id": "05036419","name": "Huisman Beheer B.V.","firstNames": "Huisman Beheer B.V.","gender": "Unknown","directorType": "Company","positions": [{"dateAppointed": "1994-06-30T00:00:00Z","positionName": "Enig aandeelhouder"}]}]},"groupStructure": {"ultimateParent": {"country": "NL","id": "NL-X-615652610000","safeNumber": "NL03798589","name": "Doeksen Shipyard Holding B.V.","type": "NotSet","status": "Active","registrationNumber": "615652610000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}},"immediateParent": {"country": "NL","id": "NL-X-050542680000","safeNumber": "NL00214803","name": "Huisman Beheer B.V.","type": "NotSet","status": "Active","registrationNumber": "050542680000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}},"affiliatedCompanies": [{"country": "NL","id": "NL-X-050277620000","safeNumber": "NL00208110","name": "Rondal B.V.","type": "NotSet","status": "Other","registrationNumber": "050277620000","address": {"simpleValue": "Flevoweg 1 DVOLLENHOVE 8325PA","street": "Flevoweg 1 D","city": "VOLLENHOVE","postalCode": "8325PA"}}]},"extendedGroupStructure": [{"id": "NL-X-615652610000","country": "NL","safeNumber": "NL03798589","companyName": "Doeksen Shipyard Holding B.V.","registeredNumber": "615652610000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 0,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050542680000","country": "NL","safeNumber": "NL00214803","companyName": "Huisman Beheer B.V.","registeredNumber": "050542680000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 1,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050277620000","country": "NL","safeNumber": "NL00208110","companyName": "Rondal B.V.","registeredNumber": "050277620000","level": 2,"status": "Other","commonRatingBand": "E"},{"id": "NL-X-050364190000","country": "NL","safeNumber": "NL00209533","companyName": "Royal Huisman Shipyard B.V.","registeredNumber": "050364190000","level": 2,"status": "Other","commonRatingBand": "E"}],"additionalInformation": {"misc": {"exporter": "Yes","negativeRating": -994,"rsinNumber": "006429300","continuanceDate": "1983-07-29T00:00:00Z","companyAge": 89,"numberOfSearchesL12": 96,"kvkStatus": "C-Changed","branchNumber": "000016608410","statutaireSeal": "Vollenhove (gemeente Steenwijkerland)","employeeNumber": "342","employeeClass": "09"},"industryComparison": {"industryAverageCreditRating": 54.38,"industryAverageCreditLimit": 13762.5},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","industryAveragePaymentExpectationDays": 18.19,"industryAverageDaySalesOutstanding": 318.32},"ratingHistory": [{"commonValue": "B","commonDescription": "Low Risk","providerValue": {"value": "60"},"date": "2019-01-02T23:30:37Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "54"},"date": "2018-12-20T23:30:45Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "51"},"date": "2018-09-06T15:47:46Z"}],"limitHistory": [{"date": "2019-01-02T23:30:37Z","companyValue": 1750000},{"date": "2018-12-20T23:30:45Z","companyValue": 1150000},{"date": "2018-09-06T15:47:46Z","companyValue": 1150000}],"lettersOfLiablilityInformation403": [{"financialYear": "2017","companyName": "Huisman Beheer B.V.","companyNumber": "050542680000","dateSubmited": "2018-10-26T00:00:00Z","letterOfLiability1StartDate": "1996-07-01T00:00:00Z","letterOfLiability1SubmittedDate": "1999-02-15T00:00:00Z"}],"companyHistory": [{"date": "2010-11-16T10:20:29Z","description": "403 / 404 statement updated"},{"date": "2011-08-19T08:28:06Z","description": "403 / 404 statement updated"},{"date": "2011-10-27T12:34:09Z","description": "FOUNDING DEED DATE CHANGE","previousValue": "05/06/1930","currentValue": "29/07/1983"},{"date": "2011-10-27T13:03:34Z","description": "PHONE NUMBER CHANGE","previousValue": "243131","currentValue": "0527 243131"},{"date": "2012-09-25T22:33:15Z","description": "403 / 404 statement updated"},{"date": "2013-09-17T22:36:48Z","description": "403 / 404 statement updated"},{"date": "2013-11-21T22:39:27Z","description": "Number of employees changed.","previousValue": "450","currentValue": "345"},{"date": "2014-12-30T22:32:10Z","description": "403 / 404 statement updated"},{"date": "2015-07-09T23:04:48Z","description": "EXECUTIVE GENDER CHANGE","previousValue": "V","currentValue": "M"},{"date": "2015-07-09T23:05:01Z","description": "Executive name change","previousValue": "Hofsteenge-Huisman","currentValue": "Boogaard"},{"date": "2016-03-21T22:32:13Z","description": "403 / 404 statement updated"},{"date": "2016-07-08T18:44:18Z","description": "403 / 404 statement updated"},{"date": "2016-07-08T19:28:22Z","description": "403 / 404 statement updated"},{"date": "2016-12-05T22:01:11Z","description": "403 / 404 statement updated"},{"date": "2017-12-14T23:01:50Z","description": "Executive name change","previousValue": "Boogaard","currentValue": "Peters"},{"date": "2017-12-27T22:00:48Z","description": "403 / 404 statement updated"},{"date": "2018-11-01T22:33:25Z","description": "Executive name change","previousValue": "Peters","currentValue": "Timmerman"},{"date": "2018-11-06T22:00:12Z","description": "403 / 404 statement updated"},{"date": "2018-11-07T22:00:12Z","description": "403 / 404 statement updated"},{"date": "2018-11-08T22:00:33Z","description": "403 / 404 statement updated"}],"kvkFilings": [{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-10-24T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2019-08-23T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-02-12T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-10-24T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2019-06-06T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2017-09-26T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-01-31T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2013-09-11T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2018-10-29T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2017-12-18T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2016-03-16T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2016-12-01T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2014-12-16T00:00:00Z","filedEvent": "Declaration of comfort letter"}],"tradingStyles": [{"tradingName": "Royal Huisman Shipyard B.V."}]}}}', null);
            mocksMap.put('https://connect.creditsafe.com/v1/companies/NL001-X-705755090001', report403Mock);
            SingleRequestMock parentReportMock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-050542680000","dateOfOrder": "2019-08-26T14:42:15.337Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-050542680000","language": "EN","companySummary": {"businessName": "Huisman Beheer B.V.","country": "NL","companyNumber": "NL00214803","companyRegistrationNumber": "05054268","mainActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"companyStatus": {"status": "Active","description": "ACTIVE"},"latestTurnoverFigure": {"value": 139517048},"creditRating": {"commonValue": "C","commonDescription": "Moderate Risk","creditLimit": {"value": "1900000"},"providerValue": {"maxValue": "100","minValue": "0","value": "57"},"providerDescription": "Low chance of financial calamity"}},"companyIdentification": {"basicInformation": {"businessName": "Huisman Beheer B.V.","registeredCompanyName": "Huisman Beheer B.V.","companyRegistrationNumber": "05054268","country": "NL","companyRegistrationDate": "1994-06-30T00:00:00Z","operationsStartDate": "1994-06-30T00:00:00Z","legalForm": {"providerCode": "41","description": "Private limited liability company (BV) with ordinary structure"},"companyStatus": {"status": "Active","description": "ACTIVE"},"principalActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"contactAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "6420","description": "Financial holdings"},{"code": "Houdstermaatschappij."}]}]},"creditScore": {"currentCreditRating": {"commonValue": "C","commonDescription": "Moderate Risk","creditLimit": {"value": "1900000"},"providerValue": {"maxValue": "100","minValue": "0","value": "57"},"providerDescription": "Low chance of financial calamity"},"currentContractLimit": {"value": 20900000},"previousCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "1750000"},"providerValue": {"value": "60"},"providerDescription": "Very low chance of financial calamity"},"latestRatingChangeDate": "2019-01-02T23:30:37Z"},"contactInformation": {"mainAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"},"otherAddresses": [{"simpleValue": "23 Postbus, VOLLENHOVE 8325ZG","street": "Postbus","houseNumber": "23","city": "VOLLENHOVE","postalCode": "8325ZG","telephone": "0527243131","country": "NL"}]},"shareCapitalStructure": {"issuedShareCapital": {"value": 40860},"shareHolders": [{"name": "Doeksen Shipyard Holding B.V.","address": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","country": "NL"},"shareholderType": "Other","percentSharesHeld": 100}]},"directors": {"currentDirectors": [{"id": "05054268","name": "Jan Willem Jisse Doeksen","firstNames": "Jan Willem Jisse","surname": "Doeksen","gender": "Unknown","dateOfBirth": "1964-01-15T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2014-11-28T00:00:00Z","positionName": "Commissarissen"}]},{"id": "05054268","name": "Harmen Jozef Peters","firstNames": "Harmen Jozef","surname": "Peters","gender": "Unknown","dateOfBirth": "1960-09-07T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2015-06-01T00:00:00Z","positionName": "Financieel directeur","authority": "Beperkte volmacht tot EUR 750.000,00."}]},{"id": "05054268","name": "Roemer Alexander Boogaard","firstNames": "Roemer Alexander","surname": "Boogaard","gender": "Unknown","dateOfBirth": "1962-08-10T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2015-06-01T00:00:00Z","positionName": "Algemeen directeur","authority": "Alleen/zelfstandig bevoegd"}]},{"id": "05054268","name": "Doeksen Shipyard Holding B.V.","firstNames": "Doeksen Shipyard Holding B.V.","gender": "Unknown","directorType": "Company","positions": [{"dateAppointed": "2017-03-01T00:00:00Z","positionName": "Enig aandeelhouder"}]},{"id": "05054268","name": "Piet-Hein Christoph de Jager","firstNames": "Piet-Hein Christoph","surname": "de Jager","gender": "Unknown","dateOfBirth": "1970-08-20T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2015-06-01T00:00:00Z","positionName": "Commissarissen"}]}]},"otherInformation": {"advisors": [{"auditorName": "Ernst & Young LLP"},{"auditorName": "Ernst & Young LLP"},{"auditorName": "Ernst & Young LLP"},{"auditorName": "PricewaterhouseCoopers N.V."},{"auditorName": "PricewaterhouseCoopers N.V."}],"employeesInformation": [{"year": 2017,"numberOfEmployees": "0"},{"year": 2016,"numberOfEmployees": "0"},{"year": 2015,"numberOfEmployees": "0"},{"year": 2014,"numberOfEmployees": "325"},{"year": 2013,"numberOfEmployees": "326"}]},"groupStructure": {"ultimateParent": {"country": "NL","id": "NL-X-615652610000","safeNumber": "NL03798589","name": "Doeksen Shipyard Holding B.V.","type": "NotSet","status": "Active","registrationNumber": "615652610000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}},"subsidiaryCompanies": [{"country": "NL","id": "NL-X-050277620000","safeNumber": "NL00208110","name": "Rondal B.V.","type": "NotSet","status": "Other","registrationNumber": "050277620000","address": {"simpleValue": "Flevoweg 1 DVOLLENHOVE 8325PA","street": "Flevoweg 1 D","city": "VOLLENHOVE","postalCode": "8325PA"}},{"country": "NL","id": "NL-X-050364190000","safeNumber": "NL00209533","name": "Royal Huisman Shipyard B.V.","type": "NotSet","status": "Other","registrationNumber": "050364190000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}}]},"extendedGroupStructure": [{"id": "NL-X-615652610000","country": "NL","safeNumber": "NL03798589","companyName": "Doeksen Shipyard Holding B.V.","registeredNumber": "615652610000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 0,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050542680000","country": "NL","safeNumber": "NL00214803","companyName": "Huisman Beheer B.V.","registeredNumber": "050542680000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 1,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050277620000","country": "NL","safeNumber": "NL00208110","companyName": "Rondal B.V.","registeredNumber": "050277620000","level": 2,"status": "Other","commonRatingBand": "E"},{"id": "NL-X-050364190000","country": "NL","safeNumber": "NL00209533","companyName": "Royal Huisman Shipyard B.V.","registeredNumber": "050364190000","level": 2,"status": "Other","commonRatingBand": "E"}],"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 70901517,"operatingCosts": 72528858,"operatingProfit": -1627341,"financialIncome": 59603,"financialExpenses": 154299,"profitBeforeTax": -1722037,"tax": -406524,"profitAfterTax": -1315513,"minorityInterests": -1969,"retainedProfit": -1317482},"balanceSheet": {"totalTangibleAssets": 24505804,"totalIntangibleAssets": 362542,"investments": 503034,"totalFixedAssets": 25371380,"totalInventories": 2349456,"tradeReceivables": 4162569,"miscellaneousReceivables": 2426976,"totalReceivables": 6589545,"cash": 64365933,"totalCurrentAssets": 73304934,"totalAssets": 98676314,"miscellaneousLiabilities": 89402724,"totalCurrentLiabilities": 89402724,"miscellaneousLiabilitiesDueAfter1Year": 4826500,"totalLongTermLiabilities": 4826500,"totalLiabilities": 94229224,"otherReserves": 4447090,"totalShareholdersEquity": 4447090},"otherFinancials": {"workingCapital": -16097790,"netWorth": 4084548},"ratios": {"preTaxProfitMargin": -2.43,"returnOnCapitalEmployed": -18.57,"returnOnTotalAssetsEmployed": -1.75,"returnOnNetAssetsEmployed": -38.72,"salesOrNetWorkingCapital": -4.4,"stockTurnoverRatio": 3.31,"debtorDays": 21.43,"currentRatio": 0.82,"liquidityRatioOrAcidTest": 0.79,"currentDebtRatio": 20.1,"gearing": 108.53,"equityInPercentage": 4.52,"totalDebtRatio": 21.19}},{"type": "GlobalFinancialsGGS","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 78816781,"operatingCosts": 77000228,"operatingProfit": 1816553,"financialIncome": 79125,"financialExpenses": 412884,"profitBeforeTax": 1482794,"tax": 320746,"profitAfterTax": 1162048,"retainedProfit": 1162048},"balanceSheet": {"totalTangibleAssets": 24887612,"totalIntangibleAssets": 453178,"investments": 154095,"totalFixedAssets": 25494885,"totalInventories": 2557749,"tradeReceivables": 6520743,"miscellaneousReceivables": 1650226,"totalReceivables": 8170969,"cash": 24392395,"totalCurrentAssets": 35121113,"totalAssets": 60615998,"miscellaneousLiabilities": 51172610,"totalCurrentLiabilities": 51172610,"miscellaneousLiabilitiesDueAfter1Year": 3624006,"totalLongTermLiabilities": 3624006,"totalLiabilities": 54796616,"otherReserves": 5819382,"totalShareholdersEquity": 5819382},"otherFinancials": {"workingCapital": -16051497,"netWorth": 5366204},"ratios": {"preTaxProfitMargin": 1.88,"returnOnCapitalEmployed": 15.7,"returnOnTotalAssetsEmployed": 2.45,"returnOnNetAssetsEmployed": 25.48,"salesOrNetWorkingCapital": -4.91,"stockTurnoverRatio": 3.25,"debtorDays": 30.2,"currentRatio": 0.69,"liquidityRatioOrAcidTest": 0.64,"currentDebtRatio": 8.79,"gearing": 62.27,"equityInPercentage": 9.67,"totalDebtRatio": 9.42}},{"type": "GlobalFinancialsGGS","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 65730087,"operatingCosts": 68428550,"operatingProfit": -2698463,"financialIncome": 75000,"financialExpenses": 371016,"profitBeforeTax": -2994479,"tax": -726680,"profitAfterTax": -2267799,"retainedProfit": -2267799},"balanceSheet": {"totalTangibleAssets": 25066982,"investments": 1745585,"totalFixedAssets": 26812567,"totalInventories": 2775634,"miscellaneousReceivables": 13593970,"totalReceivables": 13593970,"cash": 7264262,"totalCurrentAssets": 23633866,"totalAssets": 50446433,"miscellaneousLiabilities": 37691560,"totalCurrentLiabilities": 37691560,"miscellaneousLiabilitiesDueAfter1Year": 8097538,"totalLongTermLiabilities": 8097538,"totalLiabilities": 45789098,"otherReserves": 4657335,"totalShareholdersEquity": 4657335},"otherFinancials": {"workingCapital": -14057694,"netWorth": 4657335},"ratios": {"preTaxProfitMargin": -4.56,"returnOnCapitalEmployed": -23.48,"returnOnTotalAssetsEmployed": -5.94,"returnOnNetAssetsEmployed": -64.3,"salesOrNetWorkingCapital": -4.68,"stockTurnoverRatio": 4.22,"currentRatio": 0.63,"liquidityRatioOrAcidTest": 0.55,"currentDebtRatio": 8.09,"gearing": 173.87,"equityInPercentage": 9.23,"totalDebtRatio": 9.83}},{"type": "GlobalFinancialsGGS","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 76540598,"operatingCosts": 74970698,"operatingProfit": 1569900,"financialIncome": 155195,"financialExpenses": 400701,"extraordinaryCosts": -175000,"profitBeforeTax": 1324394,"tax": 387494,"profitAfterTax": 936900,"retainedProfit": 1111900},"balanceSheet": {"totalTangibleAssets": 25046866,"investments": 1096820,"totalFixedAssets": 26143686,"totalInventories": 3194764,"tradeReceivables": 7568575,"miscellaneousReceivables": 2461051,"totalReceivables": 10029626,"cash": 15379677,"totalCurrentAssets": 28604067,"totalAssets": 54747753,"tradePayables": 4954516,"miscellaneousLiabilities": 34553919,"totalCurrentLiabilities": 39508435,"miscellaneousLiabilitiesDueAfter1Year": 8314184,"totalLongTermLiabilities": 8314184,"totalLiabilities": 47822619,"otherReserves": 6925134,"totalShareholdersEquity": 6925134},"otherFinancials": {"workingCapital": -10904368,"netWorth": 6925134},"ratios": {"preTaxProfitMargin": 1.73,"returnOnCapitalEmployed": 8.69,"returnOnTotalAssetsEmployed": 2.42,"returnOnNetAssetsEmployed": 19.12,"salesOrNetWorkingCapital": -7.02,"stockTurnoverRatio": 4.17,"debtorDays": 36.09,"creditorDays": 23.63,"currentRatio": 0.72,"liquidityRatioOrAcidTest": 0.64,"currentDebtRatio": 5.71,"gearing": 120.06,"equityInPercentage": 12.65,"totalDebtRatio": 6.91}},{"type": "GlobalFinancialsGGS","yearEndDate": "2013-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"operatingProfit": -5413896,"wagesAndSalaries": 18362558,"depreciation": 8673655,"financialIncome": 44183,"financialExpenses": 425626,"profitBeforeTax": -5795339,"tax": -1480411,"profitAfterTax": -4314928,"retainedProfit": -4314928},"balanceSheet": {"totalTangibleAssets": 25767358,"totalFixedAssets": 25767358,"totalInventories": 3733168,"miscellaneousReceivables": 6545733,"totalReceivables": 6545733,"cash": 6709290,"totalCurrentAssets": 16988191,"totalAssets": 42755549,"miscellaneousLiabilities": 27851378,"totalCurrentLiabilities": 27851378,"otherLoansOrFinanceDueAfter1Year": 500000,"miscellaneousLiabilitiesDueAfter1Year": 8590937,"totalLongTermLiabilities": 9090937,"totalLiabilities": 36942315,"otherReserves": 5813234,"totalShareholdersEquity": 5813234},"otherFinancials": {"workingCapital": -10863187,"netWorth": 5813234},"ratios": {"returnOnCapitalEmployed": -38.88,"returnOnTotalAssetsEmployed": -13.55,"returnOnNetAssetsEmployed": -99.69,"currentRatio": 0.61,"liquidityRatioOrAcidTest": 0.48,"currentDebtRatio": 4.79,"gearing": 156.38,"equityInPercentage": 13.6,"totalDebtRatio": 6.35}}],"localFinancialStatements": [{"type": "LocalFinancialStatement","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 139517048,"otherOperatingIncome": -68615531,"totalOperatingExpenses": 72528858,"operatingResult": -1627341,"totalFinancialIncome": 59603,"totalFinancialExpenses": 154299,"resultOnOrdOpsBeforeTax": -1722037,"pandlTax": -406524,"minorityInterestsPandl": -1969,"netResult": -1317482},"balanceSheet": {"intangibleAsset": 362542,"tangibleAssets": 24505804,"financialFixedAssets": 503034,"fixedAssets": 25371380,"inventories": 2349456,"receivables": 4162569,"otherReceivables": 2426976,"cash": 64365933,"miscCurrentAssets": 0,"currentAssetsTotal": 73304934,"totalAssets": 98676314,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 4447090,"totalEquity": 4447090,"provisions": 2389000,"otherLongTermLiabilities": 2437500,"totalLongTermDebts": 4826500,"miscCurrentLiabilities": 89402724,"totalCurrentLiabilities": 89402724},"otherFinancials": {"workingCapital": -16097790,"netWorth": 4084548},"ratios": {"pretaxProfitMargin": -1.23,"returnOnCapitalEmployed": -18.57,"returnOnTotalAssetsEmp": -1.75,"returnOnNetAssetsEmp": -38.72,"stockTurnoverRatio": 1.68,"debtorDays": 10.89,"currentRatio": 0.82,"liquidityRatio": 0.79,"currentDebtRatio": 20.1,"gearing": 108.53,"equityInPercentage": 4.52,"totalDebtRatio": 21.19}},{"type": "LocalFinancialStatement","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 41437916,"otherOperatingIncome": 37378865,"totalOperatingExpenses": 77000228,"operatingResult": 1816553,"totalFinancialIncome": 79125,"totalFinancialExpenses": 412884,"resultOnOrdOpsBeforeTax": 1482794,"pandlTax": 320746,"netResult": 1162048},"balanceSheet": {"intangibleAsset": 453178,"tangibleAssets": 24887612,"financialFixedAssets": 154095,"fixedAssets": 25494885,"inventories": 2557749,"receivables": 6520743,"otherReceivables": 1650226,"cash": 24392395,"miscCurrentAssets": 0,"currentAssetsTotal": 35121113,"totalAssets": 60615998,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 5819382,"totalEquity": 5819382,"provisions": 936506,"otherLongTermLiabilities": 2687500,"totalLongTermDebts": 3624006,"miscCurrentLiabilities": 51172610,"totalCurrentLiabilities": 51172610},"otherFinancials": {"workingCapital": -16051497,"netWorth": 5366204},"ratios": {"pretaxProfitMargin": 3.58,"returnOnCapitalEmployed": 15.7,"returnOnTotalAssetsEmp": 2.45,"returnOnNetAssetsEmp": 25.48,"stockTurnoverRatio": 6.17,"debtorDays": 57.44,"currentRatio": 0.69,"liquidityRatio": 0.64,"currentDebtRatio": 8.79,"gearing": 62.27,"equityInPercentage": 9.67,"totalDebtRatio": 9.42}},{"type": "LocalFinancialStatement","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 68637326,"otherOperatingIncome": -2907239,"totalOperatingExpenses": 68428550,"operatingResult": -2698463,"totalFinancialIncome": 75000,"totalFinancialExpenses": 371016,"resultOnOrdOpsBeforeTax": -2994479,"pandlTax": -726680,"netResult": -2267799},"balanceSheet": {"tangibleAssets": 25066982,"financialFixedAssets": 1745585,"fixedAssets": 26812567,"inventories": 2775634,"otherReceivables": 13593970,"cash": 7264262,"miscCurrentAssets": 0,"currentAssetsTotal": 23633866,"totalAssets": 50446433,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 4657335,"totalEquity": 4657335,"provisions": 2585411,"otherLongTermLiabilities": 5512127,"totalLongTermDebts": 8097538,"miscCurrentLiabilities": 37691560,"totalCurrentLiabilities": 37691560},"otherFinancials": {"workingCapital": -14057694,"netWorth": 4657335},"ratios": {"pretaxProfitMargin": -4.36,"returnOnCapitalEmployed": -23.48,"returnOnTotalAssetsEmp": -5.94,"returnOnNetAssetsEmp": -64.3,"stockTurnoverRatio": 4.04,"currentRatio": 0.63,"liquidityRatio": 0.55,"currentDebtRatio": 8.09,"gearing": 173.87,"equityInPercentage": 9.23,"totalDebtRatio": 9.83}},{"type": "LocalFinancialStatement","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 77084822,"otherOperatingIncome": -544224,"totalOperatingExpenses": 74970698,"operatingResult": 1569900,"totalFinancialIncome": 155195,"totalFinancialExpenses": 400701,"resultOnOrdOpsBeforeTax": 1324394,"pandlTax": 387494,"extraordinaryItems": -175000,"netResult": 1111900},"balanceSheet": {"tangibleAssets": 25046866,"financialFixedAssets": 1096820,"fixedAssets": 26143686,"inventories": 3194764,"receivables": 7568575,"otherReceivables": 2461051,"cash": 15379677,"miscCurrentAssets": 0,"currentAssetsTotal": 28604067,"totalAssets": 54747753,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 6925134,"totalEquity": 6925134,"provisions": 2552057,"otherLongTermLiabilities": 5762127,"totalLongTermDebts": 8314184,"tradeCreditors": 4954516,"miscCurrentLiabilities": 34553919,"totalCurrentLiabilities": 39508435},"otherFinancials": {"workingCapital": -10904368,"netWorth": 6925134},"ratios": {"pretaxProfitMargin": 1.72,"returnOnCapitalEmployed": 8.69,"returnOnTotalAssetsEmp": 2.42,"returnOnNetAssetsEmp": 19.12,"stockTurnoverRatio": 4.14,"debtorDays": 35.84,"creditorDays": 24.12,"currentRatio": 0.72,"liquidityRatio": 0.64,"currentDebtRatio": 5.71,"gearing": 120.06,"equityInPercentage": 12.65,"totalDebtRatio": 6.91}},{"type": "LocalFinancialStatement","yearEndDate": "2013-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"operatingResult": -5413896,"totalFinancialIncome": 44183,"totalFinancialExpenses": 425626,"resultOnOrdOpsBeforeTax": -5795339,"pandlTax": -1480411,"netResult": -4314928},"balanceSheet": {"tangibleAssets": 25767358,"financialFixedAssets": 0,"fixedAssets": 25767358,"inventories": 3733168,"otherReceivables": 6545733,"cash": 6709290,"miscCurrentAssets": 0,"currentAssetsTotal": 16988191,"totalAssets": 42755549,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 5813234,"totalEquity": 5813234,"provisions": 2403810,"subordinatedLoans": 500000,"otherLongTermLiabilities": 6187127,"totalLongTermDebts": 9090937,"miscCurrentLiabilities": 27851378,"totalCurrentLiabilities": 27851378},"otherFinancials": {"workingCapital": -10863187,"netWorth": 5813234,"payrollCosts": 18362558,"amortizationDepreciation": 8673655},"ratios": {"returnOnCapitalEmployed": -38.88,"returnOnTotalAssetsEmp": -13.55,"returnOnNetAssetsEmp": -99.69,"currentRatio": 0.61,"liquidityRatio": 0.48,"currentDebtRatio": 4.79,"gearing": 156.38,"equityInPercentage": 13.6,"totalDebtRatio": 6.35}}],"additionalInformation": {"misc": {"rsinNumber": "803003948","companyAge": 25,"latestAccountsDate": "2017-12-31T00:00:00Z","numberOfSearchesL12": 68,"kvkStatus": "C-Changed","branchNumber": "000020066457","statutaireSeal": "Vollenhove","employeeNumber": "3","employeeClass": "03"},"industryQuartileAnalysis": {"paymentExpectationDays": {"paymentExpectationsLower": 22.09,"paymentExpectationsMedian": 43.14,"paymentExpectationsUpper": 62.52},"daySalesOutstanding": {"daySalesOutstandingLower": 12.17,"daySalesOutstandingMedian": 26.19,"daySalesOutstandingUpper": 46.9}},"industryComparison": {"industryAverageCreditRating": 76.19,"industryAverageCreditLimit": 112529.48},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","daySalesOutstanding": "10.89","industryAveragePaymentExpectationDays": 60.47,"industryAverageDaySalesOutstanding": 49.72},"ratingHistory": [{"commonValue": "B","commonDescription": "Low Risk","providerValue": {"value": "60"},"date": "2019-01-02T23:30:37Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "54"},"date": "2018-12-20T23:30:45Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "51"},"date": "2018-09-06T15:47:46Z"}],"limitHistory": [{"date": "2019-01-02T23:30:37Z","companyValue": 1750000},{"date": "2018-12-20T23:30:45Z","companyValue": 1150000},{"date": "2018-09-06T15:47:46Z","companyValue": 1150000}],"lettersOfLiablilityInformation403": [{"financialYear": "2019","companyName": "Doeksen Shipyard Holding B.V.","companyNumber": "615652610000","letterOfLiability1StartDate": "2019-06-13T00:00:00Z","letterOfLiability1SubmittedDate": "2019-06-13T00:00:00Z"}],"commentaries": [{"commentaryText": "The business was established over 25 years ago.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has 3 employees.","positiveOrNegative": "Neutral"},{"commentaryText": "The business is part of a group.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has been at the address for over 10 years.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit rating for this business has decreased from 60 to 57 on 25-06-2019.","positiveOrNegative": "Negative"},{"commentaryText": "The credit limit for this business has increased from €1750000 to €1900000 on 25-06-2019.","positiveOrNegative": "Positive"},{"commentaryText": "The financial statements on file are 19 months old.","positiveOrNegative": "Neutral"},{"commentaryText": "Net Worth decreased by 23% during the latest trading period.","positiveOrNegative": "Negative"},{"commentaryText": "A 62% growth in Total Assets occurred during the latest trading period.","positiveOrNegative": "Positive"},{"commentaryText": "Pre-tax profits decreased by 216% compared to the previous trading period.","positiveOrNegative": "Negative"},{"commentaryText": "The business saw an increase in their Cash Balance of 163% during the latest trading period.","positiveOrNegative": "Positive"},{"commentaryText": "Working Capital is a negative amount during the latest trading period.","positiveOrNegative": "Negative"}],"companyHistory": [{"date": "2010-11-19T09:03:53Z","description": "New accounts filed.","currentValue": "31/12/2009"},{"date": "2011-08-18T09:12:51Z","description": "New accounts filed.","currentValue": "31/12/2010"},{"date": "2011-10-27T13:03:34Z","description": "PHONE NUMBER CHANGE","previousValue": "243131","currentValue": "0527 243131"},{"date": "2012-09-29T00:11:10Z","description": "New accounts filed.","currentValue": "31/12/2011"},{"date": "2013-09-25T01:27:42Z","description": "New accounts filed.","currentValue": "31/12/2012"},{"date": "2015-01-15T01:47:09Z","description": "New accounts filed.","currentValue": "31/12/2013"},{"date": "2015-05-29T00:19:51Z","description": "New accounts filed.","currentValue": "31/12/2014"},{"date": "2015-07-09T23:04:48Z","description": "EXECUTIVE GENDER CHANGE","previousValue": "V","currentValue": "M"},{"date": "2015-07-09T23:05:01Z","description": "Executive name change","previousValue": "Hofsteenge-Huisman","currentValue": "Boogaard"},{"date": "2016-12-15T00:28:03Z","description": "New accounts filed.","currentValue": "31/12/2015"},{"date": "2017-08-11T13:37:31Z","description": "New accounts filed.","currentValue": "31/12/2016"},{"date": "2017-12-14T23:01:50Z","description": "Executive name change","previousValue": "Boogaard","currentValue": "Peters"},{"date": "2018-08-06T23:49:27Z","description": "New accounts filed.","currentValue": "31/12/2017"},{"date": "2018-08-30T22:59:18Z","description": "Executive name change","previousValue": "Peters","currentValue": "Timmerman"},{"date": "2019-06-24T23:00:37Z","description": "403 / 404 statement updated"},{"date": "2019-06-25T23:00:30Z","description": "403 / 404 statement updated"},{"date": "2019-06-26T23:00:31Z","description": "403 / 404 statement updated"}],"kvkFilings": [{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-08-23T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2017-09-26T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2013-06-13T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-11-09T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-01-07T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2019-08-23T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2014-12-01T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-09-24T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2016-04-05T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-12-01T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-12-01T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2016-12-02T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2016-04-05T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-08-23T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-09-25T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2016-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-07-12T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-07-12T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-07-26T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2015-05-19T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2013-09-11T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2016-12-01T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2015-01-02T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2017-05-19T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2019-06-18T00:00:00Z","filedEvent": "Declaration of liability statement"},{"filingDate": "2019-06-18T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2014-12-02T00:00:00Z","filedEvent": "Amendment of the statutes"}],"tradingStyles": [{"tradingName": "Huisman Beheer B.V."}]}}}', null);
            mocksMap.put('https://connect.creditsafe.com/v1/companies/NL001-X-050542680000', parentReportMock);

            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);

            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        Credit_Factory_Report__c report = [
               SELECT Class_Rating__c
               FROM Credit_Factory_Report__c
               WHERE Opportunity__c = :opportunity.Id];
        
        System.assertEquals('3', report.Class_Rating__c);// rating of head office company
    }
    
    
    /*******************************************************************************
    *  Summary         : Test api error from Creditsafe
    *  CreatedDate     : 19/02/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testAPIErrorsCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(400, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            Test.setMock(HttpCalloutMock.class, authMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Creditsafe API error.'));
    }
    
    
    /*******************************************************************************
    *  Summary         : Test unknown exception from Creditsafe
    *  CreatedDate     : 19/02/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testUnknownExceptionCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', null, null);
            Test.setMock(HttpCalloutMock.class, authMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Set company error. Please contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /*******************************************************************************
    *  Summary         : Test api error from Company.info           
    *  CreatedDate     : 19/02/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testAPIErrorsCompanyInfo() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');
        ApexPages.currentPage().getParameters().put('isCompanyAdditional', 'true');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        CreditSystem__c creditSystemCompanyInfo = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert creditSystemCompanyInfo;

        Test.startTest();
            SingleRequestMock reportMock = new SingleRequestMock(400, 'Complete', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessGetDossierV3Response xmlns="http://www.webservices.nl/soap/"><out><update_info><dossier_number>64184382</dossier_number><establishment_number>000033032157</establishment_number><update_types><item>New</item></update_types><date_last_update>2015-10-01</date_last_update></update_info><dossier_number>64184382</dossier_number><establishment_number>000033032157</establishment_number><main_establishment_number>000033032157</main_establishment_number><indication_main_establishment>true</indication_main_establishment><chamber_number>17</chamber_number><legal_form_code>1</legal_form_code><legal_form_text>Eenmanszaak</legal_form_text><indication_organisation_code>O</indication_organisation_code><legal_name/><trade_name_45>Ucar Bouw</trade_name_45><trade_name_full>Ucar Bouw</trade_name_full><trade_names/><establishment_address><original><postcode>5224GB</postcode><city>\'S-HERTOGENBOSCH</city><street>Aert van Nesstraat</street><house_number>2</house_number><house_number_addition/></original><official><postcode>5224GB</postcode><city>\'s-Hertogenbosch</city><street>Aert van Nesstraat</street><house_number>2</house_number><house_number_addition/></official><formatted><postcode>5224GB</postcode><city>\'s-Hertogenbosch</city><street>Aert van Nesstraat</street><house_number>2</house_number><house_number_addition/></formatted></establishment_address><correspondence_address><original><postcode>5224GB</postcode><city>\'S-HERTOGENBOSCH</city><street>Aert van Nesstraat</street><house_number>2</house_number><house_number_addition/><country>NLD</country></original><official><postcode>5224GB</postcode><city>\'s-Hertogenbosch</city><street>Aert van Nesstraat</street><house_number>2</house_number><house_number_addition/><country>Nederland</country></official><formatted><postcode>5224GB</postcode><city>\'s-Hertogenbosch</city><street>Aert van Nesstraat</street><house_number>2</house_number><house_number_addition/><country>NLD</country></formatted></correspondence_address><telephone_number/><mobile_number>06 46213838</mobile_number><domain_name/><contact_title1/><contact_title2/><contact_initials>S.</contact_initials><contact_prefix/><contact_surname>Uçar</contact_surname><contact_gender>m</contact_gender><primary_sbi_code>4332</primary_sbi_code><secondary_sbi_code1>43221</secondary_sbi_code1><secondary_sbi_code2/><primary_sbi_code_text>Bouwtimmeren</primary_sbi_code_text><secondary_sbi_code1_text>Loodgieters- en fitterswerk; installatie van sanitair</secondary_sbi_code1_text><secondary_sbi_code2_text/><personnel>1</personnel><class_personnel>2</class_personnel><personnel_fulltime>1</personnel_fulltime><class_personnel_fulltime>2</class_personnel_fulltime><personnel_reference_date><year>2015</year><month>9</month><day>24</day></personnel_reference_date><personnel_ci>0</personnel_ci><class_personnel_ci>1</class_personnel_ci><personnel_ci_reference_date><year>0</year><month>0</month><day>0</day></personnel_ci_reference_date><indication_import>false</indication_import><indication_export>false</indication_export><indication_economically_active>true</indication_economically_active><indication_non_mailing>true</indication_non_mailing><indication_bankruptcy>false</indication_bankruptcy><indication_dip>false</indication_dip><establishment_date><year>2015</year><month>10</month><day>1</day></establishment_date><sbi_collection><original><item><sbi_code>4332</sbi_code><description>Bouwtimmeren</description></item><item><sbi_code>43221</sbi_code><description>Loodgieters- en fitterswerk; installatie van sanitair</description></item></original><company_info/></sbi_collection></out></dutchBusinessGetDossierV3Response></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, reportMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Company.info API error'));
    }
}