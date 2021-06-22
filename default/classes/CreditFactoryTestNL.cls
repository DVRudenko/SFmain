@IsTest
public class CreditFactoryTestNL {
    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountNL();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityNL();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactNL();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        List<Credit_Factory_Report__c> reportsList = new List<Credit_Factory_Report__c>();
        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Netherlands');
        report.Opportunity__c = opportunity.Id;
        reportsList.add(report);

        Credit_Factory_Report__c additionalReport = CreditFactoryTestUtils.generateCreditFactoryAdditionalReportNL();
        additionalReport.Opportunity__c = opportunity.Id;
        reportsList.add(additionalReport);
        insert reportsList;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Netherlands');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c creditSafeSettings = CreditFactoryTestUtils.generateCreditsafeSetting();
        customSettingsList.add(creditSafeSettings);
        CreditSystem__c companyInfoSettings = CreditFactoryTestUtils.generateCompanyInfoSetting();
        customSettingsList.add(companyInfoSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Netherlands', Index__c = 1.45);
        customSettingsList.add(fuelPrice);
        insert customSettingsList;

        Tankkarten__c card = CreditFactoryTestUtils.generateTankkarten();
        card.Opportunity__c = opportunity.Id;
        insert card;

        Product2 product2 = CreditFactoryTestUtils.generateProduct2();
        insert product2;

        PricebookEntry pricebookEntry = CreditFactoryTestUtils.generatePricebookEntry();
        pricebookEntry.Product2Id = product2.Id;
        pricebookEntry.CurrencyIsoCode = 'EUR';
        insert pricebookEntry;

        OpportunityLineItem lineItem = CreditFactoryTestUtils.generateLineItem();
        lineItem.OpportunityId = opportunity.Id;
        lineItem.PricebookEntryId = pricebookEntry.Id;
        insert lineItem;

        Offer_Item_Type__c offerItemType = CreditFactoryTestUtils.generateOfferItemType();
        insert offerItemType;

        Offer_Item__c offerItem = CreditFactoryTestUtils.generateOfferItem();
        offerItem.Opportunity_Product_Id__c = lineItem.Id;
        offerItem.Offer_Item_Type__c = offerItemType.Id;
        insert offerItem;

        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'NL');
        insert riskyBusinessCode;

        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsNL();
        insert calculations;
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplNL);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Contact> contactsList = CreditFactoryService.selectAccountContacts(opportunity.AccountId);
        sobjectsList.addAll(contactsList);
        List<AccountContactRelation> accountContactRelationsList = CreditFactoryService.selectAccountContactRelations(opportunity.AccountId);
        sobjectsList.addAll(accountContactRelationsList);
        List<OpportunityContactRole> opportunityContactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(opportunityContactRolesList);
        List<dsfs__DocuSign_Status__c> docuSignStatusesList = CreditFactoryService.selectDocuSignStatusesList(opportunityId);
        sobjectsList.addAll(docuSignStatusesList);
        List<Tankkarten__c> tankkartensList = CreditFactoryService.selectTankkartens(opportunityId);
        sobjectsList.addAll(tankkartensList);
        List<OpportunityLineItem> lineItemsList = CreditFactoryService.selectLineItems(opportunityId);
        sobjectsList.addAll(lineItemsList);
        List<Offer_Item__c> offerItemsList = CreditFactoryService.selectOfferItems((new Map<Id, OpportunityLineItem>(lineItemsList)).keySet());
        sobjectsList.addAll(offerItemsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryCompany company = creditFactoryValidation.getInternalCFCompany();

        System.assertEquals('TESTGEAR B.V.', company.name);
    }


    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);
        
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        creditFactorySettings.returnSearchValidations();
    }


    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'ClosedOpportunity'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('stage', 'Closed Won');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'ClosedOpportunity'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate black list
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Contact> contactsList = CreditFactoryService.selectAccountContacts(opportunity.AccountId);
        sobjectsList.addAll(contactsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Credit_Black_List_Company__c blackListCompany = new Credit_Black_List_Company__c();
        insert blackListCompany;

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyNL();
        blackListCompany2.Customer_Id__c = 'NL';
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'DesiredPaymentDetails'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('desiredPaymentTerms', '27');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'DesiredPaymentDetails'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'ProcessedOpportunity'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('processedBy', 'Autoprocessed by Sales');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'ProcessedOpportunity'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test number of cards
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        List<OpportunityLineItem> lineItemsList = CreditFactoryService.selectLineItems(opportunityId);
        sobjectsList.addAll(lineItemsList);
        List<Offer_Item__c> offerItemsList = CreditFactoryService.selectOfferItems((new Map<Id, OpportunityLineItem>(lineItemsList)).keySet());
        sobjectsList.addAll(offerItemsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'NumberOfCards'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('numberOfCards', '2');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'NumberOfCards'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test sepa attachment
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSepaAttachments() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'SepaAttachment'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('directDebitFormAvailable', true);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'SepaAttachment'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test payment method
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidatePaymentMethod() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'PaymentMethod'}, true);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('paymentMethod', 'Banküberweisung');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'PaymentMethod'}, true);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<OpportunityContactRole> opportunityContactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(opportunityContactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        Account dupAccount = CreditFactoryTestUtils.generateAccountNL();
        dupAccount.Steuernummer__c = '12344312';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityNL();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactNL();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplNL);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryCompany company = creditFactory.getInternalCFCompany();

        System.assertEquals('TESTGEAR B.V.', company.name);
    }


    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        Boolean areReportsExist = creditFactory.areReportsExist(opportunity.Id);

        System.assertEquals(true, areReportsExist);
    }


    /*******************************************************************************
    *  Summary         : test select reports from database
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunity.Id);

        System.assertEquals(2, cfItem.companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company by tax id
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByTax() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        List<CreditFactoryCompany> companiesList = new List<CreditFactoryCompany>();
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "92afef90-f40c-11ea-82e6-0260e6fc8b9d","totalSize": 1,"companies": [{"id": "NL-X-502603400000","country": "NL","regNo": "502603400000","vatNo": ["822640065"],"safeNo": "NL02613772","name": "Testgear B.V.","tradingNames": ["Testgear B.V."],"address": {"simpleValue": "10, Molensingel, 2614LB, DELFT","street": "Molensingel","city": "DELFT","postCode": "2614LB","houseNo": "10"},"status": "active","officeType": "headOffice","dateOfLatestAccounts": "2018-12-31T00:00:00.000000Z","dateOfLatestChange": "2019-11-30T03:06:10.000Z","phoneNumbers": ["0614246817"],"activityCode": "6420","statusDescription": "ACTIVE"}]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=NL&regNo=5026034', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company by all parameters
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByAllParameters() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        List<CreditFactoryCompany> companiesList = new List<CreditFactoryCompany>();
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{  "correlationId": "a6c457a0-f439-11ea-82e6-0260e6fc8b9d",  "totalSize": 0,  "companies": [],  "messages": [ {"type": "Information","code": "NoResults","text": "No companies matching specified search criteria found." }  ]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=NL&regNo=5026034', searchMock);
            SingleRequestMock searchMock2 = new SingleRequestMock(200, 'Complete', '{"correlationId": "92afef90-f40c-11ea-82e6-0260e6fc8b9d","totalSize": 1,"companies": [{"id": "NL-X-502603400000","country": "NL","regNo": "502603400000","vatNo": ["822640065"],"safeNo": "NL02613772","name": "Testgear B.V.","tradingNames": ["Testgear B.V."],"address": {"simpleValue": "10, Molensingel, 2614LB, DELFT","street": "Molensingel","city": "DELFT","postCode": "2614LB","houseNo": "10"},"status": "active","officeType": "headOffice","dateOfLatestAccounts": "2018-12-31T00:00:00.000000Z","dateOfLatestChange": "2019-11-30T03:06:10.000Z","phoneNumbers": ["0614246817"],"activityCode": "6420","statusDescription": "ACTIVE"}]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=NL&name=TESTGEAR%2520B.V.&city=DELFT&street=MOLENSINGEL', searchMock2);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchAdditionalCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        List<CreditFactoryCompany> companiesList = new List<CreditFactoryCompany>();
        Test.startTest();

            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{  "correlationId": "a6c457a0-f439-11ea-82e6-0260e6fc8b9d",  "totalSize": 0,  "companies": [],  "messages": [ {"type": "Information","code": "NoResults","text": "No companies matching specified search criteria found." }  ]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=NL&regNo=5026034', searchMock);
            SingleRequestMock searchMock2 = new SingleRequestMock(200, 'Complete', '{  "correlationId": "a6c457a0-f439-11ea-82e6-0260e6fc8b9d",  "totalSize": 0,  "companies": [],  "messages": [ {"type": "Information","code": "NoResults","text": "No companies matching specified search criteria found." }  ]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=NL&name=TESTGEAR%2520B.V.&city=DELFT&street=MOLENSINGEL', searchMock2);
            SingleRequestMock additionalSearchMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessSearchResponse xmlns="http://www.webservices.nl/soap/"><out><paging><curpage>1</curpage><perpage>20</perpage><numpages>1</numpages><numresults>1</numresults><maxresults>500</maxresults></paging><results><item><dossier_number>63197391</dossier_number><establishment_number>000032137567</establishment_number><trade_name>TESTED</trade_name><match_type>undetermined</match_type><establishment_city>LEIDEN</establishment_city><establishment_street>Wasstraat</establishment_street><correspondence_city>LEIDEN</correspondence_city><correspondence_street>Wasstraat</correspondence_street><indication_main_establishment>true</indication_main_establishment></item></results></out></dutchBusinessSearchResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://ws1.webservices.nl:443/soap_doclit.php', additionalSearchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<OpportunityContactRole> contactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(contactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('totalConsumption', 500);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryReportsItem reportsItem;
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock creditSafeAuthMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', creditSafeAuthMock);
            SingleRequestMock creditsafeReportMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "26137850-f42c-11ea-82e6-0260e6fc8b9d","orderId": "N/A","companyId": "NL-X-502603400000","dateOfOrder": "2020-09-11T12:41:45.381Z","language": "en","userId": "101495027","report": {"companyId": "NL-X-502603400000","language": "EN","companySummary": {"businessName": "Testgear B.V.","country": "NL","companyNumber": "NL02613772","companyRegistrationNumber": "50260340","mainActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"companyStatus": {"status": "Active","description": "Active"},"latestShareholdersEquityFigure": {"currency": "EUR","value": 47264.000},"creditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "17500"},"providerValue": {"maxValue": "100","minValue": "0","value": "74"},"providerDescription": "Lowest chance of financial calamity"}},"companyIdentification": {"basicInformation": {"businessName": "Testgear B.V.","registeredCompanyName": "Testgear B.V.","companyRegistrationNumber": "50260340","country": "NL","companyRegistrationDate": "2007-05-26T00:00:00Z","operationsStartDate": "2010-06-16T00:00:00Z","legalForm": {"commonCode": "Other","providerCode": "41","description": "Private limited liability company (BV) with ordinary structure"},"companyStatus": {"status": "Active","description": "Active"},"principalActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"contactAddress": {"type": "Registered Address","simpleValue": "Mercuriusweg 121, 2624BC DELFT","street": "Mercuriusweg","houseNumber": "121","city": "DELFT","postalCode": "2624BC","province": "ZUID-HOLLAND","telephone": "0614246817","directMarketingOptOut": true,"country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "6420","description": "Financial holdings"}]},{"classification": "NACE Rev 2","activities": [{"code": "6420","description": "Activities of holding companies"}]},{"classification": "ISIC Rev 4","activities": [{"code": "6420","description": "Activities of holding companies"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "17500"},"providerValue": {"value": "74"},"providerDescription": "Lowest chance of financial calamity","pod": 0.10700},"previousCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "28500"},"providerValue": {"value": "80"},"providerDescription": "Lowest chance of financial calamity"},"latestRatingChangeDate": "2019-11-30T02:29:09Z"},"contactInformation": {"mainAddress": {"type": "Registered Address","simpleValue": "Mercuriusweg 121, 2624BC DELFT","street": "Mercuriusweg","houseNumber": "121","city": "DELFT","postalCode": "2624BC","province": "ZUID-HOLLAND","telephone": "0614246817","directMarketingOptOut": true,"country": "NL"},"otherAddresses": [{"type": "Postal Address","simpleValue": "Mercuriusweg 121, 2624BC DELFT","street": "Mercuriusweg","houseNumber": "121","city": "DELFT","postalCode": "2624BC","province": "ZUID-HOLLAND","telephone": "0614246817","country": "NL"}]},"shareCapitalStructure": {"issuedShareCapital": {"currency": "EUR","value": 180.0}},"directors": {"currentDirectors": [{"name": "Eamon Petrus Trompert","firstNames": "Eamon Petrus","surname": "Trompert","gender": "Unknown","dateOfBirth": "1972-02-17T00:00:00Z","directorType": "Person","positions": [{"dateAppointed": "2010-06-16T00:00:00Z","positionName": "Algemeen Directeur","authority": "Alleen/zelfstandig bevoegd"}],"additionalData": {"presentAppointments": 2,"previousAppointments": 0,"directorTypeDescription": "Natural Person","activeCompanies": 2,"dissolvedCompanies": 0}},{"name": "Eamon Petrus Trompert","firstNames": "Eamon Petrus","surname": "Trompert","gender": "Unknown","dateOfBirth": "1972-02-17T00:00:00Z","directorType": "Person","positions": [{"dateAppointed": "2010-06-16T00:00:00Z","positionName": "Enig Aandeelhouder"}],"additionalData": {"presentAppointments": 2,"previousAppointments": 0,"directorTypeDescription": "Natural Person","activeCompanies": 2,"dissolvedCompanies": 0}}]},"otherInformation": {"employeesInformation": [{"year": 2018,"numberOfEmployees": "0"},{"year": 2017,"numberOfEmployees": "0"}]},"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2018-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"investments": 18510.0,"totalFixedAssets": 18510.0,"otherCurrentAssets": 120609.0,"totalCurrentAssets": 120609.0,"totalAssets": 139119.0,"miscellaneousLiabilitiesDueAfter1Year": 91854.0,"totalLongTermLiabilities": 91854.0,"totalLiabilities": 91854.0,"otherReserves": 47264.0,"totalShareholdersEquity": 47264.0},"otherFinancials": {"workingCapital": 120609.0,"netWorth": 47264.0},"ratios": {"gearing": 194.34,"equityInPercentage": 33.97,"totalDebtRatio": 1.94}},{"type": "GlobalFinancialsGGS","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"investments": 25656.0,"totalFixedAssets": 25656.0,"otherCurrentAssets": 185813.0,"totalCurrentAssets": 185813.0,"totalAssets": 211469.0,"miscellaneousLiabilitiesDueAfter1Year": 96392.0,"totalLongTermLiabilities": 96392.0,"totalLiabilities": 96392.0,"otherReserves": 115077.0,"totalShareholdersEquity": 115077.0},"otherFinancials": {"workingCapital": 185813.0,"netWorth": 115077.0},"ratios": {"gearing": 83.76,"equityInPercentage": 54.42,"totalDebtRatio": 0.84}},{"type": "GlobalFinancialsGGS","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 33444.0,"investments": 90.0,"totalFixedAssets": 33534.0,"miscellaneousReceivables": 130827.0,"totalReceivables": 130827.0,"cash": 36578.0,"totalCurrentAssets": 167405.0,"totalAssets": 200939.0,"miscellaneousLiabilities": 33065.0,"totalCurrentLiabilities": 33065.0,"miscellaneousLiabilitiesDueAfter1Year": 78314.0,"totalLongTermLiabilities": 78314.0,"totalLiabilities": 111379.0,"calledUpShareCapital": 180.0,"otherReserves": 89380.0,"totalShareholdersEquity": 89560.0},"otherFinancials": {"workingCapital": 134340.0,"netWorth": 89560.0},"ratios": {"currentRatio": 5.06,"liquidityRatioOrAcidTest": 5.06,"currentDebtRatio": 0.37,"gearing": 87.44,"equityInPercentage": 44.57,"totalDebtRatio": 1.24}},{"type": "GlobalFinancialsGGS","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 41322.0,"investments": 90.0,"totalFixedAssets": 41412.0,"miscellaneousReceivables": 84401.0,"totalReceivables": 84401.0,"cash": 36200.0,"totalCurrentAssets": 120601.0,"totalAssets": 162013.0,"miscellaneousLiabilities": 33155.0,"totalCurrentLiabilities": 33155.0,"miscellaneousLiabilitiesDueAfter1Year": 84929.0,"totalLongTermLiabilities": 84929.0,"totalLiabilities": 118084.0,"calledUpShareCapital": 180.0,"otherReserves": 43749.0,"totalShareholdersEquity": 43929.0},"otherFinancials": {"workingCapital": 87446.0,"netWorth": 43929.0},"ratios": {"currentRatio": 3.64,"liquidityRatioOrAcidTest": 3.64,"currentDebtRatio": 0.75,"gearing": 193.33,"equityInPercentage": 27.11,"totalDebtRatio": 2.69}},{"type": "GlobalFinancialsGGS","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 4509.0,"investments": 90.0,"totalFixedAssets": 4599.0,"miscellaneousReceivables": 120844.0,"totalReceivables": 120844.0,"cash": 3378.0,"totalCurrentAssets": 124222.0,"totalAssets": 128821.0,"miscellaneousLiabilities": 6855.0,"totalCurrentLiabilities": 6855.0,"miscellaneousLiabilitiesDueAfter1Year": 51563.0,"totalLongTermLiabilities": 51563.0,"totalLiabilities": 58418.0,"calledUpShareCapital": 180.0,"otherReserves": 70223.0,"totalShareholdersEquity": 70403.0},"otherFinancials": {"workingCapital": 117367.0,"netWorth": 70403.0},"ratios": {"currentRatio": 18.12,"liquidityRatioOrAcidTest": 18.12,"currentDebtRatio": 0.10,"gearing": 73.24,"equityInPercentage": 54.65,"totalDebtRatio": 0.83}}],"localFinancialStatements": [{"type": "LocalFinancialsCSNL","yearEndDate": "2018-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 0,"originalCurrency": "EUR","yearStartDate": "2017-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"miscellaneousFixedAssets": 18510.000,"totalFixedAssets": 18510.000,"miscellaneousCurrentAssets": 120609.000,"totalCurrentAssets": 120609.000,"totalAssets": 139119.000,"retainedEarnings": 47264.000,"totalEquity": 47264.000,"provisions": 35050.000,"miscellaneousLiabilities": 56804.000,"totalLiabilities": 139118.000},"otherFinancials": {"workingCapital": 120609.000,"netWorth": 47264.000},"ratios": {"gearing": 194.34,"equityInPercentage": 33.97,"totalDebtRatio": 1.94}},{"type": "LocalFinancialsCSNL","yearEndDate": "2017-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 0,"originalCurrency": "EUR","yearStartDate": "2016-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"miscellaneousFixedAssets": 25656.000,"totalFixedAssets": 25656.000,"miscellaneousCurrentAssets": 185813.000,"totalCurrentAssets": 185813.000,"totalAssets": 211469.000,"retainedEarnings": 115077.000,"totalEquity": 115077.000,"provisions": 34782.000,"miscellaneousLiabilities": 61610.000,"totalLiabilities": 211469.000},"otherFinancials": {"workingCapital": 185813.000,"netWorth": 115077.000},"ratios": {"gearing": 83.76,"equityInPercentage": 54.42,"totalDebtRatio": 0.84}},{"type": "LocalFinancialsCSNL","yearEndDate": "2016-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 0,"originalCurrency": "EUR","yearStartDate": "2015-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"tangibleFixedAssets": 33444.000,"financialFixedAssets": 90.000,"totalFixedAssets": 33534.000,"receivables": 130827.000,"cash": 36578.000,"totalCurrentAssets": 167405.000,"totalAssets": 200939.000,"issuedShareCapital": 180.000,"sharePremium": 788.000,"retainedEarnings": 88592.000,"totalEquity": 89560.000,"provisions": 53918.000,"longTermLiabilities": 24396.000,"shortTermLiabilities": 33065.000,"totalCurrentLiabilities": 33065.000,"totalLiabilities": 200939.000},"otherFinancials": {"workingCapital": 134340.000,"netWorth": 89560.000},"ratios": {"currentRatio": 5.06,"liquidityRatio": 5.06,"currentDebtRatio": 0.37,"gearing": 87.44,"equityInPercentage": 44.57,"totalDebtRatio": 1.24}},{"type": "LocalFinancialsCSNL","yearEndDate": "2015-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 1,"originalCurrency": "EUR","yearStartDate": "2014-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"tangibleFixedAssets": 41322.000,"financialFixedAssets": 90.000,"totalFixedAssets": 41412.000,"receivables": 84401.000,"cash": 36200.000,"totalCurrentAssets": 120601.000,"totalAssets": 162013.000,"issuedShareCapital": 180.000,"sharePremium": 788.000,"retainedEarnings": 42961.000,"totalEquity": 43929.000,"provisions": 52750.000,"longTermLiabilities": 32179.000,"shortTermLiabilities": 33155.000,"totalCurrentLiabilities": 33155.000,"totalLiabilities": 162013.000},"otherFinancials": {"workingCapital": 87446.000,"netWorth": 43929.000},"ratios": {"currentRatio": 3.64,"liquidityRatio": 3.64,"currentDebtRatio": 0.75,"gearing": 193.33,"equityInPercentage": 27.11,"totalDebtRatio": 2.69}},{"type": "LocalFinancialsCSNL","yearEndDate": "2014-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 1,"numberOfEmployees": 1,"originalCurrency": "EUR","yearStartDate": "2013-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"tangibleFixedAssets": 4509.000,"financialFixedAssets": 90.000,"totalFixedAssets": 4599.000,"receivables": 120844.000,"cash": 3378.000,"totalCurrentAssets": 124222.000,"totalAssets": 128821.000,"issuedShareCapital": 180.000,"sharePremium": 788.000,"retainedEarnings": 69435.000,"totalEquity": 70403.000,"provisions": 51563.000,"shortTermLiabilities": 6855.000,"totalCurrentLiabilities": 6855.000,"totalLiabilities": 128821.000},"otherFinancials": {"workingCapital": 117367.000,"netWorth": 70403.000},"ratios": {"currentRatio": 18.12,"liquidityRatio": 18.12,"currentDebtRatio": 0.1,"gearing": 73.24,"equityInPercentage": 54.65,"totalDebtRatio": 0.83}}],"additionalInformation": {"misc": {"exporter": false,"importer": false,"rsinNumber": "822640065","continuanceDate": "2010-06-16T00:00:00Z","companyAge": 13,"numberOfSearchesL12": 1,"kvkStatus": "C-Changed","kvkEconomicallyActive": false,"branchNumber": "000004968859","employeeNumber": "0","employeeClass": "01","businessGroup": {"code": "O","description": "Company"},"registrationType": {"code": "31","description": "Continuation"},"depositedCapital": {"value": 180.0},"oddsOfFailure": "934:1","primarySection": {"code": "K","description": "Financial institutions"},"mainOfficeIndicator": {"code": "H","description": "Main Office"},"firstTradingName": "Testgear B.V.","firstTradingNameDate": "2019-11-12T20:00:53Z","foundingDeedDate": "2010-06-16T00:00:00Z","statutaireSeal": "GEMEENTE DELFT","statutaireSealUpdateDate": "2019-11-12T20:00:53Z","registeredAddressUpdate": "2020-05-14T22:30:39Z","vsi": {"code": "C","description": "Changed"},"registeredCountry": "NL"},"ratingHistory": [{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "74"},"providerDescription": "Lowest chance of financial calamity","date": "2019-11-30T02:29:09Z"},{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "80"},"providerDescription": "Lowest chance of financial calamity","date": "2018-12-27T23:30:48Z"},{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "89"},"providerDescription": "Lowest chance of financial calamity","date": "2018-08-31T18:59:27Z"},{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "89"},"providerDescription": "Lowest chance of financial calamity","date": "2018-08-31T11:17:57Z"}],"limitHistory": [{"date": "2019-11-30T02:29:09Z","companyValue": 17500.0},{"date": "2018-12-27T23:30:48Z","companyValue": 28500.0},{"date": "2018-08-31T18:59:27Z","companyValue": 21000.0},{"date": "2018-08-31T11:17:57Z","companyValue": 21000.0}],"commentaries": [{"commentaryText": "The business has changed address 2 times in the last year.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has been at the address for less than 6 months.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has 0 employees.","positiveOrNegative": "Neutral"},{"commentaryText": "The business was established over 13 years ago.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit limit for this business has decreased from €28500 to €17500 on 30-11-2019.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit rating for this business has decreased from 80 to 74 on 30-11-2019.","positiveOrNegative": "Neutral"},{"commentaryText": "The financial statements on file are 19 months old.","positiveOrNegative": "Neutral"},{"commentaryText": "Net Worth decreased by 58% during the latest trading period.","positiveOrNegative": "Neutral"},{"commentaryText": "A 34% decline in Total Assets occurred during the latest trading period.","positiveOrNegative": "Neutral"}],"companyHistory": [{"date": "2020-05-14T22:46:09Z","description": "Address changed.","previousValue": "Molensingel","currentValue": "Mercuriusweg"},{"date": "2020-05-14T22:46:07Z","description": "Address changed.","previousValue": "10","currentValue": "121"},{"date": "2020-05-14T22:45:55Z","description": "Address changed.","previousValue": "2614LB","currentValue": "2624BC"},{"date": "2020-05-14T22:45:39Z","description": "MAIL STREET NAME CHANGE","previousValue": "Molensingel","currentValue": "Mercuriusweg"},{"date": "2020-05-14T22:45:31Z","description": "MAIL POSTAL CODE CHANGE","previousValue": "2614LB","currentValue": "2624BC"},{"date": "2020-05-14T22:45:23Z","description": "MAIL HOUSE NO CHANGE","previousValue": "10","currentValue": "121"},{"date": "2020-05-14T22:44:06Z","description": "EXECUTIVE GENDER CHANGE","previousValue": "M"},{"date": "2020-02-11T23:11:47Z","description": "New accounts filed.","previousValue": "2017-12-31","currentValue": "2018-12-31"},{"date": "2018-12-27T23:12:10Z","description": "New accounts filed.","previousValue": "2016-12-31","currentValue": "2017-12-31"},{"date": "2017-12-12T23:30:08Z","description": "New accounts filed.","previousValue": "2015-12-31","currentValue": "2016-12-31"},{"date": "2017-08-10T08:09:00Z","description": "New accounts filed.","previousValue": "2014-12-31","currentValue": "2015-12-31"},{"date": "2016-01-23T00:53:25Z","description": "New accounts filed.","previousValue": "2013-12-31","currentValue": "2014-12-31"}],"kvkFilings": [{"filingDate": "2019-11-21T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2018-12-20T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2017-12-03T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2017-01-25T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2016-01-12T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2014-12-10T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2013-07-23T00:00:00Z","filedEvent": "New financial accounts filed"}],"tradingStyles": [{"tradingName": "Testgear B.V."}],"keyPerformanceIndicators": {"annualAverages": [{"year": 2020,"salesOrNetWorkingCapital": 4.44,"currentRatio": 2.04,"currentDebtRatio": 0.16},{"year": 2019,"salesOrNetWorkingCapital": 5.22,"currentRatio": 2.35,"currentDebtRatio": 0.13},{"year": 2018,"salesOrNetWorkingCapital": 4.89,"currentRatio": 1.95,"currentDebtRatio": 0.16},{"year": 2017,"salesOrNetWorkingCapital": 4.68,"currentRatio": 1.92,"currentDebtRatio": 0.15},{"year": 2016,"salesOrNetWorkingCapital": 4.05,"currentRatio": 2.01,"currentDebtRatio": 0.12}],"industrialAverages": [{"year": 2020,"industryCode": "642","salesOrNetWorkingCapital": 5.29,"currentRatio": 3.24,"currentDebtRatio": 0.02},{"year": 2019,"industryCode": "642","salesOrNetWorkingCapital": 4.86,"currentRatio": 3.68,"currentDebtRatio": 0.06},{"year": 2018,"industryCode": "642","salesOrNetWorkingCapital": 4.87,"currentRatio": 2.8,"currentDebtRatio": 0.06},{"year": 2017,"industryCode": "642","salesOrNetWorkingCapital": 4.64,"currentRatio": 2.7,"currentDebtRatio": 0.06},{"year": 2016,"industryCode": "642","salesOrNetWorkingCapital": 4.04,"currentRatio": 3.07,"currentDebtRatio": 0.06}],"regionalAverages": [{"year": 2020,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 5.26,"currentRatio": 2.25,"currentDebtRatio": 0.23},{"year": 2019,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 5.94,"currentRatio": 2.41,"currentDebtRatio": 0.14},{"year": 2018,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 4.98,"currentRatio": 1.97,"currentDebtRatio": 0.17},{"year": 2017,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 4.8,"currentRatio": 1.95,"currentDebtRatio": 0.16},{"year": 2016,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 4.17,"currentRatio": 2.02,"currentDebtRatio": 0.13}]},"ratingPercentiles": {"maxScore": 100.00,"tier4": 61.00,"tier3": 41.00,"tier2": 20.00,"tier1": 19.00,"activityCode": 64.0,"numberOfActivityCode": 411698},"enquiriesTrend": {"latestEnquiryDate": "2019-11-11T13:23:37Z","month1": 0,"month2": 0,"month3": 0,"month4": 0,"month5": 0,"month6": 0,"month7": 0,"month8": 0,"month9": 0,"month10": 0,"month11": 1,"month12": 0,"months1to3": 0,"months4to6": 0,"months7to9": 0,"months10to12": 1}}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL-X-502603400000', creditsafeReportMock);
            SingleRequestMock companyInfoReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessGetDossierV3Response xmlns="http://www.webservices.nl/soap/"><out><update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><update_types><item>Tradenames</item></update_types><date_last_update>2020-08-08</date_last_update></update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><main_establishment_number>000042396913</main_establishment_number><indication_main_establishment>true</indication_main_establishment><chamber_number>30</chamber_number><legal_form_code>1</legal_form_code><legal_form_text>Eenmanszaak</legal_form_text><indication_organisation_code>O</indication_organisation_code><legal_name/><trade_name_45>Swipe Products</trade_name_45><trade_name_full>Swipe Products</trade_name_full><trade_names><item>Swipe Products</item></trade_names><establishment_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></formatted></establishment_address><correspondence_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>Nederland</country></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></formatted></correspondence_address><telephone_number/><mobile_number>06 52433408</mobile_number><domain_name>www.jrshandelsmaatschappij.nl</domain_name><contact_title1/><contact_title2/><contact_initials>J.W.</contact_initials><contact_prefix/><contact_surname>Bakar</contact_surname><contact_gender/><primary_sbi_code>47919</primary_sbi_code><secondary_sbi_code1/><secondary_sbi_code2/><primary_sbi_code_text>Detailhandel via internet in een algemeen assortiment non-food</primary_sbi_code_text><secondary_sbi_code1_text/><secondary_sbi_code2_text/><personnel>1</personnel><class_personnel>2</class_personnel><personnel_fulltime>0</personnel_fulltime><class_personnel_fulltime>1</class_personnel_fulltime><personnel_reference_date><year>2019</year><month>3</month><day>29</day></personnel_reference_date><personnel_ci>0</personnel_ci><class_personnel_ci>0</class_personnel_ci><indication_import>true</indication_import><indication_export>false</indication_export><indication_economically_active>true</indication_economically_active><indication_non_mailing>true</indication_non_mailing><indication_bankruptcy>false</indication_bankruptcy><indication_dip>false</indication_dip><establishment_date><year>2019</year><month>4</month><day>1</day></establishment_date><sbi_collection><original><item><sbi_code>47919</sbi_code><description>Detailhandel via internet in een algemeen assortiment non-food</description></item></original><company_info/></sbi_collection></out></dutchBusinessGetDossierV3Response></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://ws1.webservices.nl:443/soap_doclit.php', companyInfoReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            creditFactory.requestStartReportsCheck('NL-X-502603400000');
            reportsItem = creditFactory.requestCompanyReports('NL-X-502603400000');
        Test.stopTest();

        System.assertEquals(2, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Testgear B.V.', reportsItem.companiesList.get(0).name);
        System.assertEquals('1', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('74', reportsItem.companiesList.get(0).solvencyIndex);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), reportsItem.companiesList.get(1));

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(2, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportFieldsToUpdate();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(2, reportsList.size());
        System.assertEquals('Testgear B.V.', reportsList.get(0).Name);
        System.assertEquals(1, reportEmployeesList.size());
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Opportunity'));
        System.assertEquals('1', ((Map<String, Object>) fieldsToUpdateMap.get('Opportunity')).get('Credit_System_Rating__c'));
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Account'));
        System.assertEquals('6420', ((Map<String, Object>) fieldsToUpdateMap.get('Account')).get('Branchencode__c'));
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReportsBranch() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<OpportunityContactRole> contactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(contactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryReportsItem reportsItem;
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', authMock);
            SingleRequestMock branchReportMock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-705755090001","dateOfOrder": "2019-08-22T11:29:44.317Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-705755090001","language": "EN","companySummary": {"businessName": "Testgear B.V.","country": "NL","companyNumber": "NL04949273","companyRegistrationNumber": "50260340","mainActivity": {"code": "45205","description": "Other specialised repair; washing and towing of motor vehicles","classification": "SBI 2008"},"companyStatus": {"status": "Other","description": "-"},"creditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - branch, refer to head office report."}},"companyIdentification": {"basicInformation": {"businessName": "Testgear B.V.","registeredCompanyName": "Carwash De kade","companyRegistrationNumber": "50260340","country": "NL","companyRegistrationDate": "2018-11-13T00:00:00Z","operationsStartDate": "2018-11-13T00:00:00Z","legalForm": {"providerCode": "1","description": "Sole trader with one owner"},"companyStatus": {"status": "Other","description": "-"},"principalActivity": {"code": "45205","description": "Other specialised repair; washing and towing of motor vehicles","classification": "SBI 2008"},"contactAddress": {"simpleValue": "119 A Aelbrechtskade, ROTTERDAM 3023JE","street": "Aelbrechtskade","houseNumber": "119 A","city": "ROTTERDAM","postalCode": "3023JE","province": "Zuid-Holland","telephone": "0685770814","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "45205","description": "Other specialised repair; washing and towing of motor vehicles"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - branch, refer to head office report."}},"contactInformation": {"mainAddress": {"simpleValue": "119 A Aelbrechtskade, ROTTERDAM 3023JE","street": "Molensingel","houseNumber": "10","city": "DELFT","postalCode": "2614LB","province": "Zuid-Holland","telephone": "0685770814","country": "NL"},"otherAddresses": [{"simpleValue": "119 Aelbrechtskade, ROTTERDAM 3023JE","street": "Aelbrechtskade","houseNumber": "119","city": "ROTTERDAM","postalCode": "3023JE","telephone": "0685770814","country": "NL"}]},"additionalInformation": {"misc": {"exporter": "No","importer": "No","negativeRating": -992,"kvkStatus": "C-Changed","branchNumber": "000041161084"},"industryQuartileAnalysis": {"paymentExpectationDays": {"paymentExpectationsLower": 31.19,"paymentExpectationsMedian": 47.08,"paymentExpectationsUpper": 47.08},"daySalesOutstanding": {"daySalesOutstandingLower": 16.98,"daySalesOutstandingMedian": 16.98,"daySalesOutstandingUpper": 16.98}},"industryComparison": {"industryAverageCreditRating": 51.29,"industryAverageCreditLimit": 12480.85},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","industryAveragePaymentExpectationDays": 13.67,"industryAverageDaySalesOutstanding": 41.38},"companyHistory": [{"date": "2018-12-20T22:54:50Z","description": "Company name changed.","previousValue": "Gouden Wasstraat","currentValue": "Carwash De kade"},{"date": "2018-12-20T23:01:04Z","description": "TRADING NAME CHANGE","previousValue": "Gouden Wasstraat","currentValue": "Carwash De kade"}],"tradingStyles": [{"tradingName": "Carwash De kade"}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL-X-705755090001', branchReportMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"totalSize": 1,"companies": [{"id": "NL001-X-705755090000","country": "NL","regNo": "705755090000","safeNo": "NL04703830","name": "Gold Entertainment","tradingNames": ["Gold Entertainment"],"address": {"simpleValue": "149 C, Hilledijk, 3072RJ, ROTTERDAM","street": "Hilledijk","city": "ROTTERDAM","postCode": "3072RJ","houseNo": "149 C"},"status": "active","officeType": "headOffice","dateOfLatestChange": "2019-08-09T23:20:43.000Z","activityCode": "5920","statusDescription": "ACTIVE"}]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=NL&regNo=50260340&officeType=headOffice', searchMock);
            SingleRequestMock headOfficeReportMock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-705755090000","dateOfOrder": "2019-08-22T13:42:03.066Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-705755090000","language": "EN","companySummary": {"businessName": "Gold Entertainment","country": "NL","companyNumber": "NL04703830","companyRegistrationNumber": "70575509","mainActivity": {"code": "5920","description": "Sound recording and music publishing","classification": "SBI 2008"},"companyStatus": {"status": "Active","description": "ACTIVE"},"creditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "6500"},"providerValue": {"maxValue": "100","minValue": "0","value": "64"},"providerDescription": "Very low chance of financial calamity"}},"companyIdentification": {"basicInformation": {"businessName": "Gold Entertainment","registeredCompanyName": "Gold Entertainment","companyRegistrationNumber": "70575509","country": "NL","companyRegistrationDate": "2018-01-09T00:00:00Z","operationsStartDate": "2018-01-09T00:00:00Z","legalForm": {"providerCode": "1","description": "Sole trader with one owner"},"companyStatus": {"status": "Active","description": "ACTIVE"},"principalActivity": {"code": "5920","description": "Sound recording and music publishing","classification": "SBI 2008"},"contactAddress": {"simpleValue": "149 C Hilledijk, ROTTERDAM 3072RJ","street": "Hilledijk","houseNumber": "149 C","city": "ROTTERDAM","postalCode": "3072RJ","province": "Zuid-Holland","telephone": "0687861726","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "5920","description": "Sound recording and music publishing"},{"code": "77111","description": "Renting of passenger cars and light motor vehicles (no operational lease)"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "6500"},"providerValue": {"maxValue": "100","minValue": "0","value": "64"},"providerDescription": "Very low chance of financial calamity"},"previousCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "6500"},"providerValue": {"value": "60"},"providerDescription": "Very low chance of financial calamity"},"latestRatingChangeDate": "2018-08-31T18:59:27Z"},"contactInformation": {"mainAddress": {"simpleValue": "149 C Hilledijk, ROTTERDAM 3072RJ","street": "Hilledijk","houseNumber": "149 C","city": "ROTTERDAM","postalCode": "3072RJ","province": "Zuid-Holland","telephone": "0687861726","country": "NL"},"otherAddresses": [{"simpleValue": "149 Hilledijk, ROTTERDAM 3072RJ","street": "Hilledijk","houseNumber": "149","city": "ROTTERDAM","postalCode": "3072RJ","telephone": "0687861726","country": "NL"}]},"additionalInformation": {"misc": {"exporter": "No","importer": "No","kvkStatus": "A-New in the register","branchNumber": "000038829835","employeeNumber": "1","employeeClass": "02"},"industryComparison": {"industryAverageCreditRating": 62.82,"industryAverageCreditLimit": 9702.56},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","industryAveragePaymentExpectationDays": 9.33,"industryAverageDaySalesOutstanding": 26.54},"ratingHistory": [{"commonValue": "B","commonDescription": "Low Risk","providerValue": {"value": "60"},"date": "2018-08-31T18:59:27Z"},{"commonValue": "D","commonDescription": "High Risk","providerValue": {"value": "21"},"date": "2018-01-22T09:56:09Z"}],"limitHistory": [{"date": "2018-08-31T18:59:27Z","companyValue": 6500},{"date": "2018-01-22T09:56:09Z","companyValue": 0}],"commentaries": [{"commentaryText": "The business was established over 19 months ago.","positiveOrNegative": "Neutral"},{"commentaryText": "Newly established businesses are proven to be more of an insolvency risk than more established businesses.","positiveOrNegative": "Negative"},{"commentaryText": "The business has 1 employees.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has been at the address for over 19 months.","positiveOrNegative": "Neutral"},{"commentaryText": "There has been no significant change in the business\'s credit limit.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit rating for this business has increased from 60 to 64 on 10-08-2019.","positiveOrNegative": "Positive"}],"tradingStyles": [{"tradingName": "Gold Entertainment"}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL001-X-705755090000', headOfficeReportMock);
            SingleRequestMock companyInfoReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessGetDossierV3Response xmlns="http://www.webservices.nl/soap/"><out><update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><update_types><item>Tradenames</item></update_types><date_last_update>2020-08-08</date_last_update></update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><main_establishment_number>000042396913</main_establishment_number><indication_main_establishment>true</indication_main_establishment><chamber_number>30</chamber_number><legal_form_code>1</legal_form_code><legal_form_text>Eenmanszaak</legal_form_text><indication_organisation_code>O</indication_organisation_code><legal_name/><trade_name_45>Swipe Products</trade_name_45><trade_name_full>Swipe Products</trade_name_full><trade_names><item>Swipe Products</item></trade_names><establishment_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></formatted></establishment_address><correspondence_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>Nederland</country></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></formatted></correspondence_address><telephone_number/><mobile_number>06 52433408</mobile_number><domain_name>www.jrshandelsmaatschappij.nl</domain_name><contact_title1/><contact_title2/><contact_initials>J.W.</contact_initials><contact_prefix/><contact_surname>Bakar</contact_surname><contact_gender/><primary_sbi_code>47919</primary_sbi_code><secondary_sbi_code1/><secondary_sbi_code2/><primary_sbi_code_text>Detailhandel via internet in een algemeen assortiment non-food</primary_sbi_code_text><secondary_sbi_code1_text/><secondary_sbi_code2_text/><personnel>1</personnel><class_personnel>2</class_personnel><personnel_fulltime>0</personnel_fulltime><class_personnel_fulltime>1</class_personnel_fulltime><personnel_reference_date><year>2019</year><month>3</month><day>29</day></personnel_reference_date><personnel_ci>0</personnel_ci><class_personnel_ci>0</class_personnel_ci><indication_import>true</indication_import><indication_export>false</indication_export><indication_economically_active>true</indication_economically_active><indication_non_mailing>true</indication_non_mailing><indication_bankruptcy>false</indication_bankruptcy><indication_dip>false</indication_dip><establishment_date><year>2019</year><month>4</month><day>1</day></establishment_date><sbi_collection><original><item><sbi_code>47919</sbi_code><description>Detailhandel via internet in een algemeen assortiment non-food</description></item></original><company_info/></sbi_collection></out></dutchBusinessGetDossierV3Response></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://ws1.webservices.nl:443/soap_doclit.php', companyInfoReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            creditFactory.requestStartReportsCheck('NL-X-705755090001');
            reportsItem = creditFactory.requestCompanyReports('NL-X-705755090001');
        Test.stopTest();

        System.assertEquals(2, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Carwash De kade', reportsItem.companiesList.get(0).name);
        System.assertEquals('2', reportsItem.companiesList.get(0).classRating);
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports403Statement() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<OpportunityContactRole> contactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(contactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryReportsItem reportsItem;
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', authMock);
            SingleRequestMock report403Mock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-050364190000","dateOfOrder": "2019-08-26T14:40:45.387Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-050364190000","language": "EN","companySummary": {"businessName": "Royal Huisman Shipyard B.V.","country": "NL","companyNumber": "NL00209533","companyRegistrationNumber": "05036419","mainActivity": {"code": "3012","description": "Building of pleasure and sporting boats","classification": "SBI 2008"},"companyStatus": {"status": "Other","description": "ACTIVE"},"creditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - 403 statement filed, check parent company."}},"companyIdentification": {"basicInformation": {"businessName": "Royal Huisman Shipyard B.V.","registeredCompanyName": "Royal Huisman Shipyard B.V.","companyRegistrationNumber": "05036419","country": "NL","companyRegistrationDate": "1983-07-29T00:00:00Z","operationsStartDate": "1930-06-05T00:00:00Z","legalForm": {"providerCode": "41","description": "Private limited liability company (BV) with ordinary structure"},"companyStatus": {"status": "Other","description": "ACTIVE"},"principalActivity": {"code": "3012","description": "Building of pleasure and sporting boats","classification": "SBI 2008"},"contactAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "3012","description": "Building of pleasure and sporting boats"},{"code": "Jachtwerf, bouwen, verbouwen en repareren van,zeilboten en motorjachten. De export van,zeilboten en motorjachten."}]}]},"creditScore": {"currentCreditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - 403 statement filed, check parent company."},"previousCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "1750000"},"providerValue": {"value": "60"},"providerDescription": "Very low chance of financial calamity"},"latestRatingChangeDate": "2019-01-02T23:30:37Z"},"contactInformation": {"mainAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"},"otherAddresses": [{"simpleValue": "23 Postbus, VOLLENHOVE 8325ZG","street": "Postbus","houseNumber": "23","city": "VOLLENHOVE","postalCode": "8325ZG","telephone": "0527243131","country": "NL"}],"websites": ["www.royalhuisman.com"]},"shareCapitalStructure": {"issuedShareCapital": {"value": 19000},"shareHolders": [{"name": "Huisman Beheer B.V.","address": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","country": "NL"},"shareholderType": "Other","percentSharesHeld": 100}]},"directors": {"currentDirectors": [{"id": "05036419","name": "Jan Timmerman","firstNames": "Jan","surname": "Timmerman","gender": "Unknown","dateOfBirth": "1966-05-02T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2018-08-01T00:00:00Z","positionName": "Algemeen directeur","authority": "Alleen/zelfstandig bevoegd"}]},{"id": "05036419","name": "Huisman Beheer B.V.","firstNames": "Huisman Beheer B.V.","gender": "Unknown","directorType": "Company","positions": [{"dateAppointed": "1994-06-30T00:00:00Z","positionName": "Enig aandeelhouder"}]}]},"groupStructure": {"ultimateParent": {"country": "NL","id": "NL-X-615652610000","safeNumber": "NL03798589","name": "Doeksen Shipyard Holding B.V.","type": "NotSet","status": "Active","registrationNumber": "615652610000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}},"immediateParent": {"country": "NL","id": "NL-X-050542680000","safeNumber": "NL00214803","name": "Huisman Beheer B.V.","type": "NotSet","status": "Active","registrationNumber": "050542680000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}},"affiliatedCompanies": [{"country": "NL","id": "NL-X-050277620000","safeNumber": "NL00208110","name": "Rondal B.V.","type": "NotSet","status": "Other","registrationNumber": "050277620000","address": {"simpleValue": "Flevoweg 1 DVOLLENHOVE 8325PA","street": "Flevoweg 1 D","city": "VOLLENHOVE","postalCode": "8325PA"}}]},"extendedGroupStructure": [{"id": "NL-X-615652610000","country": "NL","safeNumber": "NL03798589","companyName": "Doeksen Shipyard Holding B.V.","registeredNumber": "615652610000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 0,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050542680000","country": "NL","safeNumber": "NL00214803","companyName": "Huisman Beheer B.V.","registeredNumber": "050542680000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 1,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050277620000","country": "NL","safeNumber": "NL00208110","companyName": "Rondal B.V.","registeredNumber": "050277620000","level": 2,"status": "Other","commonRatingBand": "E"},{"id": "NL-X-050364190000","country": "NL","safeNumber": "NL00209533","companyName": "Royal Huisman Shipyard B.V.","registeredNumber": "050364190000","level": 2,"status": "Other","commonRatingBand": "E"}],"additionalInformation": {"misc": {"exporter": "Yes","negativeRating": -994,"rsinNumber": "006429300","continuanceDate": "1983-07-29T00:00:00Z","companyAge": 89,"numberOfSearchesL12": 96,"kvkStatus": "C-Changed","branchNumber": "000016608410","statutaireSeal": "Vollenhove (gemeente Steenwijkerland)","employeeNumber": "342","employeeClass": "09"},"industryComparison": {"industryAverageCreditRating": 54.38,"industryAverageCreditLimit": 13762.5},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","industryAveragePaymentExpectationDays": 18.19,"industryAverageDaySalesOutstanding": 318.32},"ratingHistory": [{"commonValue": "B","commonDescription": "Low Risk","providerValue": {"value": "60"},"date": "2019-01-02T23:30:37Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "54"},"date": "2018-12-20T23:30:45Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "51"},"date": "2018-09-06T15:47:46Z"}],"limitHistory": [{"date": "2019-01-02T23:30:37Z","companyValue": 1750000},{"date": "2018-12-20T23:30:45Z","companyValue": 1150000},{"date": "2018-09-06T15:47:46Z","companyValue": 1150000}],"lettersOfLiablilityInformation403": [{"financialYear": "2017","companyName": "Huisman Beheer B.V.","companyNumber": "050542680000","dateSubmited": "2018-10-26T00:00:00Z","letterOfLiability1StartDate": "1996-07-01T00:00:00Z","letterOfLiability1SubmittedDate": "1999-02-15T00:00:00Z"}],"companyHistory": [{"date": "2010-11-16T10:20:29Z","description": "403 / 404 statement updated"},{"date": "2011-08-19T08:28:06Z","description": "403 / 404 statement updated"},{"date": "2011-10-27T12:34:09Z","description": "FOUNDING DEED DATE CHANGE","previousValue": "05/06/1930","currentValue": "29/07/1983"},{"date": "2011-10-27T13:03:34Z","description": "PHONE NUMBER CHANGE","previousValue": "243131","currentValue": "0527 243131"},{"date": "2012-09-25T22:33:15Z","description": "403 / 404 statement updated"},{"date": "2013-09-17T22:36:48Z","description": "403 / 404 statement updated"},{"date": "2013-11-21T22:39:27Z","description": "Number of employees changed.","previousValue": "450","currentValue": "345"},{"date": "2014-12-30T22:32:10Z","description": "403 / 404 statement updated"},{"date": "2015-07-09T23:04:48Z","description": "EXECUTIVE GENDER CHANGE","previousValue": "V","currentValue": "M"},{"date": "2015-07-09T23:05:01Z","description": "Executive name change","previousValue": "Hofsteenge-Huisman","currentValue": "Boogaard"},{"date": "2016-03-21T22:32:13Z","description": "403 / 404 statement updated"},{"date": "2016-07-08T18:44:18Z","description": "403 / 404 statement updated"},{"date": "2016-07-08T19:28:22Z","description": "403 / 404 statement updated"},{"date": "2016-12-05T22:01:11Z","description": "403 / 404 statement updated"},{"date": "2017-12-14T23:01:50Z","description": "Executive name change","previousValue": "Boogaard","currentValue": "Peters"},{"date": "2017-12-27T22:00:48Z","description": "403 / 404 statement updated"},{"date": "2018-11-01T22:33:25Z","description": "Executive name change","previousValue": "Peters","currentValue": "Timmerman"},{"date": "2018-11-06T22:00:12Z","description": "403 / 404 statement updated"},{"date": "2018-11-07T22:00:12Z","description": "403 / 404 statement updated"},{"date": "2018-11-08T22:00:33Z","description": "403 / 404 statement updated"}],"kvkFilings": [{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-10-24T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2019-08-23T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-02-12T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-10-24T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2019-06-06T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2017-09-26T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-01-31T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2013-09-11T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2018-10-29T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2017-12-18T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2016-03-16T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2016-12-01T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2014-12-16T00:00:00Z","filedEvent": "Declaration of comfort letter"}],"tradingStyles": [{"tradingName": "Royal Huisman Shipyard B.V."}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL-X-705755090001', report403Mock);
            SingleRequestMock parentReportMock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-050542680000","dateOfOrder": "2019-08-26T14:42:15.337Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-050542680000","language": "EN","companySummary": {"businessName": "Huisman Beheer B.V.","country": "NL","companyNumber": "NL00214803","companyRegistrationNumber": "05054268","mainActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"companyStatus": {"status": "Active","description": "ACTIVE"},"latestTurnoverFigure": {"value": 139517048},"creditRating": {"commonValue": "C","commonDescription": "Moderate Risk","creditLimit": {"value": "1900000"},"providerValue": {"maxValue": "100","minValue": "0","value": "57"},"providerDescription": "Low chance of financial calamity"}},"companyIdentification": {"basicInformation": {"businessName": "Huisman Beheer B.V.","registeredCompanyName": "Huisman Beheer B.V.","companyRegistrationNumber": "05054268","country": "NL","companyRegistrationDate": "1994-06-30T00:00:00Z","operationsStartDate": "1994-06-30T00:00:00Z","legalForm": {"providerCode": "41","description": "Private limited liability company (BV) with ordinary structure"},"companyStatus": {"status": "Active","description": "ACTIVE"},"principalActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"contactAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "6420","description": "Financial holdings"},{"code": "Houdstermaatschappij."}]}]},"creditScore": {"currentCreditRating": {"commonValue": "C","commonDescription": "Moderate Risk","creditLimit": {"value": "1900000"},"providerValue": {"maxValue": "100","minValue": "0","value": "57"},"providerDescription": "Low chance of financial calamity"},"currentContractLimit": {"value": 20900000},"previousCreditRating": {"commonValue": "B","commonDescription": "Low Risk","creditLimit": {"value": "1750000"},"providerValue": {"value": "60"},"providerDescription": "Very low chance of financial calamity"},"latestRatingChangeDate": "2019-01-02T23:30:37Z"},"contactInformation": {"mainAddress": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","province": "Overijssel","telephone": "0527243131","country": "NL"},"otherAddresses": [{"simpleValue": "23 Postbus, VOLLENHOVE 8325ZG","street": "Postbus","houseNumber": "23","city": "VOLLENHOVE","postalCode": "8325ZG","telephone": "0527243131","country": "NL"}]},"shareCapitalStructure": {"issuedShareCapital": {"value": 40860},"shareHolders": [{"name": "Doeksen Shipyard Holding B.V.","address": {"simpleValue": "1 Flevoweg, VOLLENHOVE 8325PA","street": "Flevoweg","houseNumber": "1","city": "VOLLENHOVE","postalCode": "8325PA","country": "NL"},"shareholderType": "Other","percentSharesHeld": 100}]},"directors": {"currentDirectors": [{"id": "05054268","name": "Jan Willem Jisse Doeksen","firstNames": "Jan Willem Jisse","surname": "Doeksen","gender": "Unknown","dateOfBirth": "1964-01-15T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2014-11-28T00:00:00Z","positionName": "Commissarissen"}]},{"id": "05054268","name": "Harmen Jozef Peters","firstNames": "Harmen Jozef","surname": "Peters","gender": "Unknown","dateOfBirth": "1960-09-07T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2015-06-01T00:00:00Z","positionName": "Financieel directeur","authority": "Beperkte volmacht tot EUR 750.000,00."}]},{"id": "05054268","name": "Roemer Alexander Boogaard","firstNames": "Roemer Alexander","surname": "Boogaard","gender": "Unknown","dateOfBirth": "1962-08-10T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2015-06-01T00:00:00Z","positionName": "Algemeen directeur","authority": "Alleen/zelfstandig bevoegd"}]},{"id": "05054268","name": "Doeksen Shipyard Holding B.V.","firstNames": "Doeksen Shipyard Holding B.V.","gender": "Unknown","directorType": "Company","positions": [{"dateAppointed": "2017-03-01T00:00:00Z","positionName": "Enig aandeelhouder"}]},{"id": "05054268","name": "Piet-Hein Christoph de Jager","firstNames": "Piet-Hein Christoph","surname": "de Jager","gender": "Unknown","dateOfBirth": "1970-08-20T00:00:00Z","directorType": "Company","positions": [{"dateAppointed": "2015-06-01T00:00:00Z","positionName": "Commissarissen"}]}]},"otherInformation": {"advisors": [{"auditorName": "Ernst & Young LLP"},{"auditorName": "Ernst & Young LLP"},{"auditorName": "Ernst & Young LLP"},{"auditorName": "PricewaterhouseCoopers N.V."},{"auditorName": "PricewaterhouseCoopers N.V."}],"employeesInformation": [{"year": 2017,"numberOfEmployees": "0"},{"year": 2016,"numberOfEmployees": "0"},{"year": 2015,"numberOfEmployees": "0"},{"year": 2014,"numberOfEmployees": "325"},{"year": 2013,"numberOfEmployees": "326"}]},"groupStructure": {"ultimateParent": {"country": "NL","id": "NL-X-615652610000","safeNumber": "NL03798589","name": "Doeksen Shipyard Holding B.V.","type": "NotSet","status": "Active","registrationNumber": "615652610000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}},"subsidiaryCompanies": [{"country": "NL","id": "NL-X-050277620000","safeNumber": "NL00208110","name": "Rondal B.V.","type": "NotSet","status": "Other","registrationNumber": "050277620000","address": {"simpleValue": "Flevoweg 1 DVOLLENHOVE 8325PA","street": "Flevoweg 1 D","city": "VOLLENHOVE","postalCode": "8325PA"}},{"country": "NL","id": "NL-X-050364190000","safeNumber": "NL00209533","name": "Royal Huisman Shipyard B.V.","type": "NotSet","status": "Other","registrationNumber": "050364190000","address": {"simpleValue": "Flevoweg 1 VOLLENHOVE 8325PA","street": "Flevoweg 1","city": "VOLLENHOVE","postalCode": "8325PA"}}]},"extendedGroupStructure": [{"id": "NL-X-615652610000","country": "NL","safeNumber": "NL03798589","companyName": "Doeksen Shipyard Holding B.V.","registeredNumber": "615652610000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 0,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050542680000","country": "NL","safeNumber": "NL00214803","companyName": "Huisman Beheer B.V.","registeredNumber": "050542680000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 1,"status": "Active","commonRatingBand": "C"},{"id": "NL-X-050277620000","country": "NL","safeNumber": "NL00208110","companyName": "Rondal B.V.","registeredNumber": "050277620000","level": 2,"status": "Other","commonRatingBand": "E"},{"id": "NL-X-050364190000","country": "NL","safeNumber": "NL00209533","companyName": "Royal Huisman Shipyard B.V.","registeredNumber": "050364190000","level": 2,"status": "Other","commonRatingBand": "E"}],"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 70901517,"operatingCosts": 72528858,"operatingProfit": -1627341,"financialIncome": 59603,"financialExpenses": 154299,"profitBeforeTax": -1722037,"tax": -406524,"profitAfterTax": -1315513,"minorityInterests": -1969,"retainedProfit": -1317482},"balanceSheet": {"totalTangibleAssets": 24505804,"totalIntangibleAssets": 362542,"investments": 503034,"totalFixedAssets": 25371380,"totalInventories": 2349456,"tradeReceivables": 4162569,"miscellaneousReceivables": 2426976,"totalReceivables": 6589545,"cash": 64365933,"totalCurrentAssets": 73304934,"totalAssets": 98676314,"miscellaneousLiabilities": 89402724,"totalCurrentLiabilities": 89402724,"miscellaneousLiabilitiesDueAfter1Year": 4826500,"totalLongTermLiabilities": 4826500,"totalLiabilities": 94229224,"otherReserves": 4447090,"totalShareholdersEquity": 4447090},"otherFinancials": {"workingCapital": -16097790,"netWorth": 4084548},"ratios": {"preTaxProfitMargin": -2.43,"returnOnCapitalEmployed": -18.57,"returnOnTotalAssetsEmployed": -1.75,"returnOnNetAssetsEmployed": -38.72,"salesOrNetWorkingCapital": -4.4,"stockTurnoverRatio": 3.31,"debtorDays": 21.43,"currentRatio": 0.82,"liquidityRatioOrAcidTest": 0.79,"currentDebtRatio": 20.1,"gearing": 108.53,"equityInPercentage": 4.52,"totalDebtRatio": 21.19}},{"type": "GlobalFinancialsGGS","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 78816781,"operatingCosts": 77000228,"operatingProfit": 1816553,"financialIncome": 79125,"financialExpenses": 412884,"profitBeforeTax": 1482794,"tax": 320746,"profitAfterTax": 1162048,"retainedProfit": 1162048},"balanceSheet": {"totalTangibleAssets": 24887612,"totalIntangibleAssets": 453178,"investments": 154095,"totalFixedAssets": 25494885,"totalInventories": 2557749,"tradeReceivables": 6520743,"miscellaneousReceivables": 1650226,"totalReceivables": 8170969,"cash": 24392395,"totalCurrentAssets": 35121113,"totalAssets": 60615998,"miscellaneousLiabilities": 51172610,"totalCurrentLiabilities": 51172610,"miscellaneousLiabilitiesDueAfter1Year": 3624006,"totalLongTermLiabilities": 3624006,"totalLiabilities": 54796616,"otherReserves": 5819382,"totalShareholdersEquity": 5819382},"otherFinancials": {"workingCapital": -16051497,"netWorth": 5366204},"ratios": {"preTaxProfitMargin": 1.88,"returnOnCapitalEmployed": 15.7,"returnOnTotalAssetsEmployed": 2.45,"returnOnNetAssetsEmployed": 25.48,"salesOrNetWorkingCapital": -4.91,"stockTurnoverRatio": 3.25,"debtorDays": 30.2,"currentRatio": 0.69,"liquidityRatioOrAcidTest": 0.64,"currentDebtRatio": 8.79,"gearing": 62.27,"equityInPercentage": 9.67,"totalDebtRatio": 9.42}},{"type": "GlobalFinancialsGGS","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 65730087,"operatingCosts": 68428550,"operatingProfit": -2698463,"financialIncome": 75000,"financialExpenses": 371016,"profitBeforeTax": -2994479,"tax": -726680,"profitAfterTax": -2267799,"retainedProfit": -2267799},"balanceSheet": {"totalTangibleAssets": 25066982,"investments": 1745585,"totalFixedAssets": 26812567,"totalInventories": 2775634,"miscellaneousReceivables": 13593970,"totalReceivables": 13593970,"cash": 7264262,"totalCurrentAssets": 23633866,"totalAssets": 50446433,"miscellaneousLiabilities": 37691560,"totalCurrentLiabilities": 37691560,"miscellaneousLiabilitiesDueAfter1Year": 8097538,"totalLongTermLiabilities": 8097538,"totalLiabilities": 45789098,"otherReserves": 4657335,"totalShareholdersEquity": 4657335},"otherFinancials": {"workingCapital": -14057694,"netWorth": 4657335},"ratios": {"preTaxProfitMargin": -4.56,"returnOnCapitalEmployed": -23.48,"returnOnTotalAssetsEmployed": -5.94,"returnOnNetAssetsEmployed": -64.3,"salesOrNetWorkingCapital": -4.68,"stockTurnoverRatio": 4.22,"currentRatio": 0.63,"liquidityRatioOrAcidTest": 0.55,"currentDebtRatio": 8.09,"gearing": 173.87,"equityInPercentage": 9.23,"totalDebtRatio": 9.83}},{"type": "GlobalFinancialsGGS","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"revenue": 76540598,"operatingCosts": 74970698,"operatingProfit": 1569900,"financialIncome": 155195,"financialExpenses": 400701,"extraordinaryCosts": -175000,"profitBeforeTax": 1324394,"tax": 387494,"profitAfterTax": 936900,"retainedProfit": 1111900},"balanceSheet": {"totalTangibleAssets": 25046866,"investments": 1096820,"totalFixedAssets": 26143686,"totalInventories": 3194764,"tradeReceivables": 7568575,"miscellaneousReceivables": 2461051,"totalReceivables": 10029626,"cash": 15379677,"totalCurrentAssets": 28604067,"totalAssets": 54747753,"tradePayables": 4954516,"miscellaneousLiabilities": 34553919,"totalCurrentLiabilities": 39508435,"miscellaneousLiabilitiesDueAfter1Year": 8314184,"totalLongTermLiabilities": 8314184,"totalLiabilities": 47822619,"otherReserves": 6925134,"totalShareholdersEquity": 6925134},"otherFinancials": {"workingCapital": -10904368,"netWorth": 6925134},"ratios": {"preTaxProfitMargin": 1.73,"returnOnCapitalEmployed": 8.69,"returnOnTotalAssetsEmployed": 2.42,"returnOnNetAssetsEmployed": 19.12,"salesOrNetWorkingCapital": -7.02,"stockTurnoverRatio": 4.17,"debtorDays": 36.09,"creditorDays": 23.63,"currentRatio": 0.72,"liquidityRatioOrAcidTest": 0.64,"currentDebtRatio": 5.71,"gearing": 120.06,"equityInPercentage": 12.65,"totalDebtRatio": 6.91}},{"type": "GlobalFinancialsGGS","yearEndDate": "2013-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"operatingProfit": -5413896,"wagesAndSalaries": 18362558,"depreciation": 8673655,"financialIncome": 44183,"financialExpenses": 425626,"profitBeforeTax": -5795339,"tax": -1480411,"profitAfterTax": -4314928,"retainedProfit": -4314928},"balanceSheet": {"totalTangibleAssets": 25767358,"totalFixedAssets": 25767358,"totalInventories": 3733168,"miscellaneousReceivables": 6545733,"totalReceivables": 6545733,"cash": 6709290,"totalCurrentAssets": 16988191,"totalAssets": 42755549,"miscellaneousLiabilities": 27851378,"totalCurrentLiabilities": 27851378,"otherLoansOrFinanceDueAfter1Year": 500000,"miscellaneousLiabilitiesDueAfter1Year": 8590937,"totalLongTermLiabilities": 9090937,"totalLiabilities": 36942315,"otherReserves": 5813234,"totalShareholdersEquity": 5813234},"otherFinancials": {"workingCapital": -10863187,"netWorth": 5813234},"ratios": {"returnOnCapitalEmployed": -38.88,"returnOnTotalAssetsEmployed": -13.55,"returnOnNetAssetsEmployed": -99.69,"currentRatio": 0.61,"liquidityRatioOrAcidTest": 0.48,"currentDebtRatio": 4.79,"gearing": 156.38,"equityInPercentage": 13.6,"totalDebtRatio": 6.35}}],"localFinancialStatements": [{"type": "LocalFinancialStatement","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 139517048,"otherOperatingIncome": -68615531,"totalOperatingExpenses": 72528858,"operatingResult": -1627341,"totalFinancialIncome": 59603,"totalFinancialExpenses": 154299,"resultOnOrdOpsBeforeTax": -1722037,"pandlTax": -406524,"minorityInterestsPandl": -1969,"netResult": -1317482},"balanceSheet": {"intangibleAsset": 362542,"tangibleAssets": 24505804,"financialFixedAssets": 503034,"fixedAssets": 25371380,"inventories": 2349456,"receivables": 4162569,"otherReceivables": 2426976,"cash": 64365933,"miscCurrentAssets": 0,"currentAssetsTotal": 73304934,"totalAssets": 98676314,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 4447090,"totalEquity": 4447090,"provisions": 2389000,"otherLongTermLiabilities": 2437500,"totalLongTermDebts": 4826500,"miscCurrentLiabilities": 89402724,"totalCurrentLiabilities": 89402724},"otherFinancials": {"workingCapital": -16097790,"netWorth": 4084548},"ratios": {"pretaxProfitMargin": -1.23,"returnOnCapitalEmployed": -18.57,"returnOnTotalAssetsEmp": -1.75,"returnOnNetAssetsEmp": -38.72,"stockTurnoverRatio": 1.68,"debtorDays": 10.89,"currentRatio": 0.82,"liquidityRatio": 0.79,"currentDebtRatio": 20.1,"gearing": 108.53,"equityInPercentage": 4.52,"totalDebtRatio": 21.19}},{"type": "LocalFinancialStatement","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 41437916,"otherOperatingIncome": 37378865,"totalOperatingExpenses": 77000228,"operatingResult": 1816553,"totalFinancialIncome": 79125,"totalFinancialExpenses": 412884,"resultOnOrdOpsBeforeTax": 1482794,"pandlTax": 320746,"netResult": 1162048},"balanceSheet": {"intangibleAsset": 453178,"tangibleAssets": 24887612,"financialFixedAssets": 154095,"fixedAssets": 25494885,"inventories": 2557749,"receivables": 6520743,"otherReceivables": 1650226,"cash": 24392395,"miscCurrentAssets": 0,"currentAssetsTotal": 35121113,"totalAssets": 60615998,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 5819382,"totalEquity": 5819382,"provisions": 936506,"otherLongTermLiabilities": 2687500,"totalLongTermDebts": 3624006,"miscCurrentLiabilities": 51172610,"totalCurrentLiabilities": 51172610},"otherFinancials": {"workingCapital": -16051497,"netWorth": 5366204},"ratios": {"pretaxProfitMargin": 3.58,"returnOnCapitalEmployed": 15.7,"returnOnTotalAssetsEmp": 2.45,"returnOnNetAssetsEmp": 25.48,"stockTurnoverRatio": 6.17,"debtorDays": 57.44,"currentRatio": 0.69,"liquidityRatio": 0.64,"currentDebtRatio": 8.79,"gearing": 62.27,"equityInPercentage": 9.67,"totalDebtRatio": 9.42}},{"type": "LocalFinancialStatement","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 68637326,"otherOperatingIncome": -2907239,"totalOperatingExpenses": 68428550,"operatingResult": -2698463,"totalFinancialIncome": 75000,"totalFinancialExpenses": 371016,"resultOnOrdOpsBeforeTax": -2994479,"pandlTax": -726680,"netResult": -2267799},"balanceSheet": {"tangibleAssets": 25066982,"financialFixedAssets": 1745585,"fixedAssets": 26812567,"inventories": 2775634,"otherReceivables": 13593970,"cash": 7264262,"miscCurrentAssets": 0,"currentAssetsTotal": 23633866,"totalAssets": 50446433,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 4657335,"totalEquity": 4657335,"provisions": 2585411,"otherLongTermLiabilities": 5512127,"totalLongTermDebts": 8097538,"miscCurrentLiabilities": 37691560,"totalCurrentLiabilities": 37691560},"otherFinancials": {"workingCapital": -14057694,"netWorth": 4657335},"ratios": {"pretaxProfitMargin": -4.36,"returnOnCapitalEmployed": -23.48,"returnOnTotalAssetsEmp": -5.94,"returnOnNetAssetsEmp": -64.3,"stockTurnoverRatio": 4.04,"currentRatio": 0.63,"liquidityRatio": 0.55,"currentDebtRatio": 8.09,"gearing": 173.87,"equityInPercentage": 9.23,"totalDebtRatio": 9.83}},{"type": "LocalFinancialStatement","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"turnover": 77084822,"otherOperatingIncome": -544224,"totalOperatingExpenses": 74970698,"operatingResult": 1569900,"totalFinancialIncome": 155195,"totalFinancialExpenses": 400701,"resultOnOrdOpsBeforeTax": 1324394,"pandlTax": 387494,"extraordinaryItems": -175000,"netResult": 1111900},"balanceSheet": {"tangibleAssets": 25046866,"financialFixedAssets": 1096820,"fixedAssets": 26143686,"inventories": 3194764,"receivables": 7568575,"otherReceivables": 2461051,"cash": 15379677,"miscCurrentAssets": 0,"currentAssetsTotal": 28604067,"totalAssets": 54747753,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 6925134,"totalEquity": 6925134,"provisions": 2552057,"otherLongTermLiabilities": 5762127,"totalLongTermDebts": 8314184,"tradeCreditors": 4954516,"miscCurrentLiabilities": 34553919,"totalCurrentLiabilities": 39508435},"otherFinancials": {"workingCapital": -10904368,"netWorth": 6925134},"ratios": {"pretaxProfitMargin": 1.72,"returnOnCapitalEmployed": 8.69,"returnOnTotalAssetsEmp": 2.42,"returnOnNetAssetsEmp": 19.12,"stockTurnoverRatio": 4.14,"debtorDays": 35.84,"creditorDays": 24.12,"currentRatio": 0.72,"liquidityRatio": 0.64,"currentDebtRatio": 5.71,"gearing": 120.06,"equityInPercentage": 12.65,"totalDebtRatio": 6.91}},{"type": "LocalFinancialStatement","yearEndDate": "2013-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": true,"profitAndLoss": {"operatingResult": -5413896,"totalFinancialIncome": 44183,"totalFinancialExpenses": 425626,"resultOnOrdOpsBeforeTax": -5795339,"pandlTax": -1480411,"netResult": -4314928},"balanceSheet": {"tangibleAssets": 25767358,"financialFixedAssets": 0,"fixedAssets": 25767358,"inventories": 3733168,"otherReceivables": 6545733,"cash": 6709290,"miscCurrentAssets": 0,"currentAssetsTotal": 16988191,"totalAssets": 42755549,"retainedEarnings": 0,"otherReserves": 0,"groupNetWorth": 5813234,"totalEquity": 5813234,"provisions": 2403810,"subordinatedLoans": 500000,"otherLongTermLiabilities": 6187127,"totalLongTermDebts": 9090937,"miscCurrentLiabilities": 27851378,"totalCurrentLiabilities": 27851378},"otherFinancials": {"workingCapital": -10863187,"netWorth": 5813234,"payrollCosts": 18362558,"amortizationDepreciation": 8673655},"ratios": {"returnOnCapitalEmployed": -38.88,"returnOnTotalAssetsEmp": -13.55,"returnOnNetAssetsEmp": -99.69,"currentRatio": 0.61,"liquidityRatio": 0.48,"currentDebtRatio": 4.79,"gearing": 156.38,"equityInPercentage": 13.6,"totalDebtRatio": 6.35}}],"additionalInformation": {"misc": {"rsinNumber": "803003948","companyAge": 25,"latestAccountsDate": "2017-12-31T00:00:00Z","numberOfSearchesL12": 68,"kvkStatus": "C-Changed","branchNumber": "000020066457","statutaireSeal": "Vollenhove","employeeNumber": "3","employeeClass": "03"},"industryQuartileAnalysis": {"paymentExpectationDays": {"paymentExpectationsLower": 22.09,"paymentExpectationsMedian": 43.14,"paymentExpectationsUpper": 62.52},"daySalesOutstanding": {"daySalesOutstandingLower": 12.17,"daySalesOutstandingMedian": 26.19,"daySalesOutstandingUpper": 46.9}},"industryComparison": {"industryAverageCreditRating": 76.19,"industryAverageCreditLimit": 112529.48},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","daySalesOutstanding": "10.89","industryAveragePaymentExpectationDays": 60.47,"industryAverageDaySalesOutstanding": 49.72},"ratingHistory": [{"commonValue": "B","commonDescription": "Low Risk","providerValue": {"value": "60"},"date": "2019-01-02T23:30:37Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "54"},"date": "2018-12-20T23:30:45Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "51"},"date": "2018-09-06T15:47:46Z"}],"limitHistory": [{"date": "2019-01-02T23:30:37Z","companyValue": 1750000},{"date": "2018-12-20T23:30:45Z","companyValue": 1150000},{"date": "2018-09-06T15:47:46Z","companyValue": 1150000}],"lettersOfLiablilityInformation403": [{"financialYear": "2019","companyName": "Doeksen Shipyard Holding B.V.","companyNumber": "615652610000","letterOfLiability1StartDate": "2019-06-13T00:00:00Z","letterOfLiability1SubmittedDate": "2019-06-13T00:00:00Z"}],"commentaries": [{"commentaryText": "The business was established over 25 years ago.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has 3 employees.","positiveOrNegative": "Neutral"},{"commentaryText": "The business is part of a group.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has been at the address for over 10 years.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit rating for this business has decreased from 60 to 57 on 25-06-2019.","positiveOrNegative": "Negative"},{"commentaryText": "The credit limit for this business has increased from €1750000 to €1900000 on 25-06-2019.","positiveOrNegative": "Positive"},{"commentaryText": "The financial statements on file are 19 months old.","positiveOrNegative": "Neutral"},{"commentaryText": "Net Worth decreased by 23% during the latest trading period.","positiveOrNegative": "Negative"},{"commentaryText": "A 62% growth in Total Assets occurred during the latest trading period.","positiveOrNegative": "Positive"},{"commentaryText": "Pre-tax profits decreased by 216% compared to the previous trading period.","positiveOrNegative": "Negative"},{"commentaryText": "The business saw an increase in their Cash Balance of 163% during the latest trading period.","positiveOrNegative": "Positive"},{"commentaryText": "Working Capital is a negative amount during the latest trading period.","positiveOrNegative": "Negative"}],"companyHistory": [{"date": "2010-11-19T09:03:53Z","description": "New accounts filed.","currentValue": "31/12/2009"},{"date": "2011-08-18T09:12:51Z","description": "New accounts filed.","currentValue": "31/12/2010"},{"date": "2011-10-27T13:03:34Z","description": "PHONE NUMBER CHANGE","previousValue": "243131","currentValue": "0527 243131"},{"date": "2012-09-29T00:11:10Z","description": "New accounts filed.","currentValue": "31/12/2011"},{"date": "2013-09-25T01:27:42Z","description": "New accounts filed.","currentValue": "31/12/2012"},{"date": "2015-01-15T01:47:09Z","description": "New accounts filed.","currentValue": "31/12/2013"},{"date": "2015-05-29T00:19:51Z","description": "New accounts filed.","currentValue": "31/12/2014"},{"date": "2015-07-09T23:04:48Z","description": "EXECUTIVE GENDER CHANGE","previousValue": "V","currentValue": "M"},{"date": "2015-07-09T23:05:01Z","description": "Executive name change","previousValue": "Hofsteenge-Huisman","currentValue": "Boogaard"},{"date": "2016-12-15T00:28:03Z","description": "New accounts filed.","currentValue": "31/12/2015"},{"date": "2017-08-11T13:37:31Z","description": "New accounts filed.","currentValue": "31/12/2016"},{"date": "2017-12-14T23:01:50Z","description": "Executive name change","previousValue": "Boogaard","currentValue": "Peters"},{"date": "2018-08-06T23:49:27Z","description": "New accounts filed.","currentValue": "31/12/2017"},{"date": "2018-08-30T22:59:18Z","description": "Executive name change","previousValue": "Peters","currentValue": "Timmerman"},{"date": "2019-06-24T23:00:37Z","description": "403 / 404 statement updated"},{"date": "2019-06-25T23:00:30Z","description": "403 / 404 statement updated"},{"date": "2019-06-26T23:00:31Z","description": "403 / 404 statement updated"}],"kvkFilings": [{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-08-23T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2017-09-26T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2013-06-13T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-11-09T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-01-07T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2019-08-23T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2014-12-01T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2018-09-24T00:00:00Z","filedEvent": "New appointment of director"},{"filingDate": "2016-04-05T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-12-01T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2014-12-01T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2016-12-02T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2015-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2016-04-05T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-08-23T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-09-25T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2017-12-07T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2016-06-30T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-07-12T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-07-12T00:00:00Z","filedEvent": "Ending appointment of director"},{"filingDate": "2018-07-26T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2015-05-19T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2013-09-11T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2016-12-01T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2015-01-02T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2017-05-19T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2019-06-18T00:00:00Z","filedEvent": "Declaration of liability statement"},{"filingDate": "2019-06-18T00:00:00Z","filedEvent": "Declaration of comfort letter"},{"filingDate": "2014-12-02T00:00:00Z","filedEvent": "Amendment of the statutes"}],"tradingStyles": [{"tradingName": "Huisman Beheer B.V."}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL001-X-050542680000', parentReportMock);
            SingleRequestMock companyInfoReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessGetDossierV3Response xmlns="http://www.webservices.nl/soap/"><out><update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><update_types><item>Tradenames</item></update_types><date_last_update>2020-08-08</date_last_update></update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><main_establishment_number>000042396913</main_establishment_number><indication_main_establishment>true</indication_main_establishment><chamber_number>30</chamber_number><legal_form_code>1</legal_form_code><legal_form_text>Eenmanszaak</legal_form_text><indication_organisation_code>O</indication_organisation_code><legal_name/><trade_name_45>Swipe Products</trade_name_45><trade_name_full>Swipe Products</trade_name_full><trade_names><item>Swipe Products</item></trade_names><establishment_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></formatted></establishment_address><correspondence_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>Nederland</country></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></formatted></correspondence_address><telephone_number/><mobile_number>06 52433408</mobile_number><domain_name>www.jrshandelsmaatschappij.nl</domain_name><contact_title1/><contact_title2/><contact_initials>J.W.</contact_initials><contact_prefix/><contact_surname>Bakar</contact_surname><contact_gender/><primary_sbi_code>47919</primary_sbi_code><secondary_sbi_code1/><secondary_sbi_code2/><primary_sbi_code_text>Detailhandel via internet in een algemeen assortiment non-food</primary_sbi_code_text><secondary_sbi_code1_text/><secondary_sbi_code2_text/><personnel>1</personnel><class_personnel>2</class_personnel><personnel_fulltime>0</personnel_fulltime><class_personnel_fulltime>1</class_personnel_fulltime><personnel_reference_date><year>2019</year><month>3</month><day>29</day></personnel_reference_date><personnel_ci>0</personnel_ci><class_personnel_ci>0</class_personnel_ci><indication_import>true</indication_import><indication_export>false</indication_export><indication_economically_active>true</indication_economically_active><indication_non_mailing>true</indication_non_mailing><indication_bankruptcy>false</indication_bankruptcy><indication_dip>false</indication_dip><establishment_date><year>2019</year><month>4</month><day>1</day></establishment_date><sbi_collection><original><item><sbi_code>47919</sbi_code><description>Detailhandel via internet in een algemeen assortiment non-food</description></item></original><company_info/></sbi_collection></out></dutchBusinessGetDossierV3Response></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://ws1.webservices.nl:443/soap_doclit.php', companyInfoReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            creditFactory.requestStartReportsCheck('NL-X-705755090001');
            reportsItem = creditFactory.requestCompanyReports('NL-X-705755090001');
        Test.stopTest();

        System.assertEquals(2, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Royal Huisman Shipyard B.V.', reportsItem.companiesList.get(0).name);
        System.assertEquals('3', reportsItem.companiesList.get(0).classRating);
    }


    /*******************************************************************************
    *  Summary         : test response from Creditsafe with API error
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditsafeApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<OpportunityContactRole> contactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(contactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        String errorMessage;
        Test.startTest();
            SingleRequestMock creditSafeReportMock = new SingleRequestMock(400, 'Complete', '{"code": 400,"message": "Invalid or missing company id"}', null);
            Test.setMock(HttpCalloutMock.class, creditSafeReportMock);
            try {
                creditFactory.requestCompanyReports('1234512345');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Creditsafe API error. Please contact your administrator. Bad request. Company Id: 1234512345', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<OpportunityContactRole> contactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(contactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        String errorMessage;
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock creditSafeAuthMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', creditSafeAuthMock);
            SingleRequestMock creditsafeReportMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "26137850-f42c-11ea-82e6-0260e6fc8b9d","orderId": "N/A","companyId": "NL-X-502603400000","dateOfOrder": "2020-09-11T12:41:45.381Z","language": "en","userId": "101495027","report": {"companyId": "NL-X-502603400000","language": "EN","companySummary": {"businessName": "Testgear B.V.","country": "NL","companyNumber": "NL02613772","companyRegistrationNumber": "50260340","mainActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"companyStatus": {"status": "Active","description": "Active"},"latestShareholdersEquityFigure": {"currency": "EUR","value": 47264.000},"creditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "17500"},"providerValue": {"maxValue": "100","minValue": "0","value": "74"},"providerDescription": "Lowest chance of financial calamity"}},"companyIdentification": {"basicInformation": {"businessName": "Testgear B.V.","registeredCompanyName": "Testgear B.V.","companyRegistrationNumber": "50260340","country": "NL","companyRegistrationDate": "2007-05-26T00:00:00Z","operationsStartDate": "2010-06-16T00:00:00Z","legalForm": {"commonCode": "Other","providerCode": "41","description": "Private limited liability company (BV) with ordinary structure"},"companyStatus": {"status": "Active","description": "Active"},"principalActivity": {"code": "6420","description": "Financial holdings","classification": "SBI 2008"},"contactAddress": {"type": "Registered Address","simpleValue": "Mercuriusweg 121, 2624BC DELFT","street": "Mercuriusweg","houseNumber": "121","city": "DELFT","postalCode": "2624BC","province": "ZUID-HOLLAND","telephone": "0614246817","directMarketingOptOut": true,"country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "6420","description": "Financial holdings"}]},{"classification": "NACE Rev 2","activities": [{"code": "6420","description": "Activities of holding companies"}]},{"classification": "ISIC Rev 4","activities": [{"code": "6420","description": "Activities of holding companies"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "17500"},"providerValue": {"value": "74"},"providerDescription": "Lowest chance of financial calamity","pod": 0.10700},"previousCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "28500"},"providerValue": {"value": "80"},"providerDescription": "Lowest chance of financial calamity"},"latestRatingChangeDate": "2019-11-30T02:29:09Z"},"contactInformation": {"mainAddress": {"type": "Registered Address","simpleValue": "Mercuriusweg 121, 2624BC DELFT","street": "Mercuriusweg","houseNumber": "121","city": "DELFT","postalCode": "2624BC","province": "ZUID-HOLLAND","telephone": "0614246817","directMarketingOptOut": true,"country": "NL"},"otherAddresses": [{"type": "Postal Address","simpleValue": "Mercuriusweg 121, 2624BC DELFT","street": "Mercuriusweg","houseNumber": "121","city": "DELFT","postalCode": "2624BC","province": "ZUID-HOLLAND","telephone": "0614246817","country": "NL"}]},"shareCapitalStructure": {"issuedShareCapital": {"currency": "EUR","value": 180.0}},"directors": {"currentDirectors": [{"name": "Eamon Petrus Trompert","firstNames": "Eamon Petrus","surname": "Trompert","gender": "Unknown","dateOfBirth": "1972-02-17T00:00:00Z","directorType": "Person","positions": [{"dateAppointed": "2010-06-16T00:00:00Z","positionName": "Algemeen Directeur","authority": "Alleen/zelfstandig bevoegd"}],"additionalData": {"presentAppointments": 2,"previousAppointments": 0,"directorTypeDescription": "Natural Person","activeCompanies": 2,"dissolvedCompanies": 0}},{"name": "Eamon Petrus Trompert","firstNames": "Eamon Petrus","surname": "Trompert","gender": "Unknown","dateOfBirth": "1972-02-17T00:00:00Z","directorType": "Person","positions": [{"dateAppointed": "2010-06-16T00:00:00Z","positionName": "Enig Aandeelhouder"}],"additionalData": {"presentAppointments": 2,"previousAppointments": 0,"directorTypeDescription": "Natural Person","activeCompanies": 2,"dissolvedCompanies": 0}}]},"otherInformation": {"employeesInformation": [{"year": 2018,"numberOfEmployees": "0"},{"year": 2017,"numberOfEmployees": "0"}]},"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2018-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"investments": 18510.0,"totalFixedAssets": 18510.0,"otherCurrentAssets": 120609.0,"totalCurrentAssets": 120609.0,"totalAssets": 139119.0,"miscellaneousLiabilitiesDueAfter1Year": 91854.0,"totalLongTermLiabilities": 91854.0,"totalLiabilities": 91854.0,"otherReserves": 47264.0,"totalShareholdersEquity": 47264.0},"otherFinancials": {"workingCapital": 120609.0,"netWorth": 47264.0},"ratios": {"gearing": 194.34,"equityInPercentage": 33.97,"totalDebtRatio": 1.94}},{"type": "GlobalFinancialsGGS","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"investments": 25656.0,"totalFixedAssets": 25656.0,"otherCurrentAssets": 185813.0,"totalCurrentAssets": 185813.0,"totalAssets": 211469.0,"miscellaneousLiabilitiesDueAfter1Year": 96392.0,"totalLongTermLiabilities": 96392.0,"totalLiabilities": 96392.0,"otherReserves": 115077.0,"totalShareholdersEquity": 115077.0},"otherFinancials": {"workingCapital": 185813.0,"netWorth": 115077.0},"ratios": {"gearing": 83.76,"equityInPercentage": 54.42,"totalDebtRatio": 0.84}},{"type": "GlobalFinancialsGGS","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 33444.0,"investments": 90.0,"totalFixedAssets": 33534.0,"miscellaneousReceivables": 130827.0,"totalReceivables": 130827.0,"cash": 36578.0,"totalCurrentAssets": 167405.0,"totalAssets": 200939.0,"miscellaneousLiabilities": 33065.0,"totalCurrentLiabilities": 33065.0,"miscellaneousLiabilitiesDueAfter1Year": 78314.0,"totalLongTermLiabilities": 78314.0,"totalLiabilities": 111379.0,"calledUpShareCapital": 180.0,"otherReserves": 89380.0,"totalShareholdersEquity": 89560.0},"otherFinancials": {"workingCapital": 134340.0,"netWorth": 89560.0},"ratios": {"currentRatio": 5.06,"liquidityRatioOrAcidTest": 5.06,"currentDebtRatio": 0.37,"gearing": 87.44,"equityInPercentage": 44.57,"totalDebtRatio": 1.24}},{"type": "GlobalFinancialsGGS","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 41322.0,"investments": 90.0,"totalFixedAssets": 41412.0,"miscellaneousReceivables": 84401.0,"totalReceivables": 84401.0,"cash": 36200.0,"totalCurrentAssets": 120601.0,"totalAssets": 162013.0,"miscellaneousLiabilities": 33155.0,"totalCurrentLiabilities": 33155.0,"miscellaneousLiabilitiesDueAfter1Year": 84929.0,"totalLongTermLiabilities": 84929.0,"totalLiabilities": 118084.0,"calledUpShareCapital": 180.0,"otherReserves": 43749.0,"totalShareholdersEquity": 43929.0},"otherFinancials": {"workingCapital": 87446.0,"netWorth": 43929.0},"ratios": {"currentRatio": 3.64,"liquidityRatioOrAcidTest": 3.64,"currentDebtRatio": 0.75,"gearing": 193.33,"equityInPercentage": 27.11,"totalDebtRatio": 2.69}},{"type": "GlobalFinancialsGGS","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 4509.0,"investments": 90.0,"totalFixedAssets": 4599.0,"miscellaneousReceivables": 120844.0,"totalReceivables": 120844.0,"cash": 3378.0,"totalCurrentAssets": 124222.0,"totalAssets": 128821.0,"miscellaneousLiabilities": 6855.0,"totalCurrentLiabilities": 6855.0,"miscellaneousLiabilitiesDueAfter1Year": 51563.0,"totalLongTermLiabilities": 51563.0,"totalLiabilities": 58418.0,"calledUpShareCapital": 180.0,"otherReserves": 70223.0,"totalShareholdersEquity": 70403.0},"otherFinancials": {"workingCapital": 117367.0,"netWorth": 70403.0},"ratios": {"currentRatio": 18.12,"liquidityRatioOrAcidTest": 18.12,"currentDebtRatio": 0.10,"gearing": 73.24,"equityInPercentage": 54.65,"totalDebtRatio": 0.83}}],"localFinancialStatements": [{"type": "LocalFinancialsCSNL","yearEndDate": "2018-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 0,"originalCurrency": "EUR","yearStartDate": "2017-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"miscellaneousFixedAssets": 18510.000,"totalFixedAssets": 18510.000,"miscellaneousCurrentAssets": 120609.000,"totalCurrentAssets": 120609.000,"totalAssets": 139119.000,"retainedEarnings": 47264.000,"totalEquity": 47264.000,"provisions": 35050.000,"miscellaneousLiabilities": 56804.000,"totalLiabilities": 139118.000},"otherFinancials": {"workingCapital": 120609.000,"netWorth": 47264.000},"ratios": {"gearing": 194.34,"equityInPercentage": 33.97,"totalDebtRatio": 1.94}},{"type": "LocalFinancialsCSNL","yearEndDate": "2017-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 0,"originalCurrency": "EUR","yearStartDate": "2016-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"miscellaneousFixedAssets": 25656.000,"totalFixedAssets": 25656.000,"miscellaneousCurrentAssets": 185813.000,"totalCurrentAssets": 185813.000,"totalAssets": 211469.000,"retainedEarnings": 115077.000,"totalEquity": 115077.000,"provisions": 34782.000,"miscellaneousLiabilities": 61610.000,"totalLiabilities": 211469.000},"otherFinancials": {"workingCapital": 185813.000,"netWorth": 115077.000},"ratios": {"gearing": 83.76,"equityInPercentage": 54.42,"totalDebtRatio": 0.84}},{"type": "LocalFinancialsCSNL","yearEndDate": "2016-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 0,"originalCurrency": "EUR","yearStartDate": "2015-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"tangibleFixedAssets": 33444.000,"financialFixedAssets": 90.000,"totalFixedAssets": 33534.000,"receivables": 130827.000,"cash": 36578.000,"totalCurrentAssets": 167405.000,"totalAssets": 200939.000,"issuedShareCapital": 180.000,"sharePremium": 788.000,"retainedEarnings": 88592.000,"totalEquity": 89560.000,"provisions": 53918.000,"longTermLiabilities": 24396.000,"shortTermLiabilities": 33065.000,"totalCurrentLiabilities": 33065.000,"totalLiabilities": 200939.000},"otherFinancials": {"workingCapital": 134340.000,"netWorth": 89560.000},"ratios": {"currentRatio": 5.06,"liquidityRatio": 5.06,"currentDebtRatio": 0.37,"gearing": 87.44,"equityInPercentage": 44.57,"totalDebtRatio": 1.24}},{"type": "LocalFinancialsCSNL","yearEndDate": "2015-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 0,"numberOfEmployees": 1,"originalCurrency": "EUR","yearStartDate": "2014-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"tangibleFixedAssets": 41322.000,"financialFixedAssets": 90.000,"totalFixedAssets": 41412.000,"receivables": 84401.000,"cash": 36200.000,"totalCurrentAssets": 120601.000,"totalAssets": 162013.000,"issuedShareCapital": 180.000,"sharePremium": 788.000,"retainedEarnings": 42961.000,"totalEquity": 43929.000,"provisions": 52750.000,"longTermLiabilities": 32179.000,"shortTermLiabilities": 33155.000,"totalCurrentLiabilities": 33155.000,"totalLiabilities": 162013.000},"otherFinancials": {"workingCapital": 87446.000,"netWorth": 43929.000},"ratios": {"currentRatio": 3.64,"liquidityRatio": 3.64,"currentDebtRatio": 0.75,"gearing": 193.33,"equityInPercentage": 27.11,"totalDebtRatio": 2.69}},{"type": "LocalFinancialsCSNL","yearEndDate": "2014-12-31T00:00:00Z","currency": "EUR","consolidatedAccounts": false,"numberOfMonths": 12,"numberOfConsolidated": 0,"numberOfSubsidiaries": 0,"numberOfParticipatingInterests": 1,"numberOfEmployees": 1,"originalCurrency": "EUR","yearStartDate": "2013-12-31T00:00:00Z","profitAppropriation": {"code": "N"},"balanceSheet": {"tangibleFixedAssets": 4509.000,"financialFixedAssets": 90.000,"totalFixedAssets": 4599.000,"receivables": 120844.000,"cash": 3378.000,"totalCurrentAssets": 124222.000,"totalAssets": 128821.000,"issuedShareCapital": 180.000,"sharePremium": 788.000,"retainedEarnings": 69435.000,"totalEquity": 70403.000,"provisions": 51563.000,"shortTermLiabilities": 6855.000,"totalCurrentLiabilities": 6855.000,"totalLiabilities": 128821.000},"otherFinancials": {"workingCapital": 117367.000,"netWorth": 70403.000},"ratios": {"currentRatio": 18.12,"liquidityRatio": 18.12,"currentDebtRatio": 0.1,"gearing": 73.24,"equityInPercentage": 54.65,"totalDebtRatio": 0.83}}],"additionalInformation": {"misc": {"exporter": false,"importer": false,"rsinNumber": "822640065","continuanceDate": "2010-06-16T00:00:00Z","companyAge": 13,"numberOfSearchesL12": 1,"kvkStatus": "C-Changed","kvkEconomicallyActive": false,"branchNumber": "000004968859","employeeNumber": "0","employeeClass": "01","businessGroup": {"code": "O","description": "Company"},"registrationType": {"code": "31","description": "Continuation"},"depositedCapital": {"value": 180.0},"oddsOfFailure": "934:1","primarySection": {"code": "K","description": "Financial institutions"},"mainOfficeIndicator": {"code": "H","description": "Main Office"},"firstTradingName": "Testgear B.V.","firstTradingNameDate": "2019-11-12T20:00:53Z","foundingDeedDate": "2010-06-16T00:00:00Z","statutaireSeal": "GEMEENTE DELFT","statutaireSealUpdateDate": "2019-11-12T20:00:53Z","registeredAddressUpdate": "2020-05-14T22:30:39Z","vsi": {"code": "C","description": "Changed"},"registeredCountry": "NL"},"ratingHistory": [{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "74"},"providerDescription": "Lowest chance of financial calamity","date": "2019-11-30T02:29:09Z"},{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "80"},"providerDescription": "Lowest chance of financial calamity","date": "2018-12-27T23:30:48Z"},{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "89"},"providerDescription": "Lowest chance of financial calamity","date": "2018-08-31T18:59:27Z"},{"commonValue": "A","commonDescription": "Very Low Risk","providerValue": {"value": "89"},"providerDescription": "Lowest chance of financial calamity","date": "2018-08-31T11:17:57Z"}],"limitHistory": [{"date": "2019-11-30T02:29:09Z","companyValue": 17500.0},{"date": "2018-12-27T23:30:48Z","companyValue": 28500.0},{"date": "2018-08-31T18:59:27Z","companyValue": 21000.0},{"date": "2018-08-31T11:17:57Z","companyValue": 21000.0}],"commentaries": [{"commentaryText": "The business has changed address 2 times in the last year.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has been at the address for less than 6 months.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has 0 employees.","positiveOrNegative": "Neutral"},{"commentaryText": "The business was established over 13 years ago.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit limit for this business has decreased from €28500 to €17500 on 30-11-2019.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit rating for this business has decreased from 80 to 74 on 30-11-2019.","positiveOrNegative": "Neutral"},{"commentaryText": "The financial statements on file are 19 months old.","positiveOrNegative": "Neutral"},{"commentaryText": "Net Worth decreased by 58% during the latest trading period.","positiveOrNegative": "Neutral"},{"commentaryText": "A 34% decline in Total Assets occurred during the latest trading period.","positiveOrNegative": "Neutral"}],"companyHistory": [{"date": "2020-05-14T22:46:09Z","description": "Address changed.","previousValue": "Molensingel","currentValue": "Mercuriusweg"},{"date": "2020-05-14T22:46:07Z","description": "Address changed.","previousValue": "10","currentValue": "121"},{"date": "2020-05-14T22:45:55Z","description": "Address changed.","previousValue": "2614LB","currentValue": "2624BC"},{"date": "2020-05-14T22:45:39Z","description": "MAIL STREET NAME CHANGE","previousValue": "Molensingel","currentValue": "Mercuriusweg"},{"date": "2020-05-14T22:45:31Z","description": "MAIL POSTAL CODE CHANGE","previousValue": "2614LB","currentValue": "2624BC"},{"date": "2020-05-14T22:45:23Z","description": "MAIL HOUSE NO CHANGE","previousValue": "10","currentValue": "121"},{"date": "2020-05-14T22:44:06Z","description": "EXECUTIVE GENDER CHANGE","previousValue": "M"},{"date": "2020-02-11T23:11:47Z","description": "New accounts filed.","previousValue": "2017-12-31","currentValue": "2018-12-31"},{"date": "2018-12-27T23:12:10Z","description": "New accounts filed.","previousValue": "2016-12-31","currentValue": "2017-12-31"},{"date": "2017-12-12T23:30:08Z","description": "New accounts filed.","previousValue": "2015-12-31","currentValue": "2016-12-31"},{"date": "2017-08-10T08:09:00Z","description": "New accounts filed.","previousValue": "2014-12-31","currentValue": "2015-12-31"},{"date": "2016-01-23T00:53:25Z","description": "New accounts filed.","previousValue": "2013-12-31","currentValue": "2014-12-31"}],"kvkFilings": [{"filingDate": "2019-11-21T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2018-12-20T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2017-12-03T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2017-01-25T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2016-01-12T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2014-12-10T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2013-07-23T00:00:00Z","filedEvent": "New financial accounts filed"}],"tradingStyles": [{"tradingName": "Testgear B.V."}],"keyPerformanceIndicators": {"annualAverages": [{"year": 2020,"salesOrNetWorkingCapital": 4.44,"currentRatio": 2.04,"currentDebtRatio": 0.16},{"year": 2019,"salesOrNetWorkingCapital": 5.22,"currentRatio": 2.35,"currentDebtRatio": 0.13},{"year": 2018,"salesOrNetWorkingCapital": 4.89,"currentRatio": 1.95,"currentDebtRatio": 0.16},{"year": 2017,"salesOrNetWorkingCapital": 4.68,"currentRatio": 1.92,"currentDebtRatio": 0.15},{"year": 2016,"salesOrNetWorkingCapital": 4.05,"currentRatio": 2.01,"currentDebtRatio": 0.12}],"industrialAverages": [{"year": 2020,"industryCode": "642","salesOrNetWorkingCapital": 5.29,"currentRatio": 3.24,"currentDebtRatio": 0.02},{"year": 2019,"industryCode": "642","salesOrNetWorkingCapital": 4.86,"currentRatio": 3.68,"currentDebtRatio": 0.06},{"year": 2018,"industryCode": "642","salesOrNetWorkingCapital": 4.87,"currentRatio": 2.8,"currentDebtRatio": 0.06},{"year": 2017,"industryCode": "642","salesOrNetWorkingCapital": 4.64,"currentRatio": 2.7,"currentDebtRatio": 0.06},{"year": 2016,"industryCode": "642","salesOrNetWorkingCapital": 4.04,"currentRatio": 3.07,"currentDebtRatio": 0.06}],"regionalAverages": [{"year": 2020,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 5.26,"currentRatio": 2.25,"currentDebtRatio": 0.23},{"year": 2019,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 5.94,"currentRatio": 2.41,"currentDebtRatio": 0.14},{"year": 2018,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 4.98,"currentRatio": 1.97,"currentDebtRatio": 0.17},{"year": 2017,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 4.8,"currentRatio": 1.95,"currentDebtRatio": 0.16},{"year": 2016,"province": "ZUID-HOLLAND","salesOrNetWorkingCapital": 4.17,"currentRatio": 2.02,"currentDebtRatio": 0.13}]},"ratingPercentiles": {"maxScore": 100.00,"tier4": 61.00,"tier3": 41.00,"tier2": 20.00,"tier1": 19.00,"activityCode": 64.0,"numberOfActivityCode": 411698},"enquiriesTrend": {"latestEnquiryDate": "2019-11-11T13:23:37Z","month1": 0,"month2": 0,"month3": 0,"month4": 0,"month5": 0,"month6": 0,"month7": 0,"month8": 0,"month9": 0,"month10": 0,"month11": 1,"month12": 0,"months1to3": 0,"months4to6": 0,"months7to9": 0,"months10to12": 1}}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL-X-502603400000', creditsafeReportMock);
            SingleRequestMock companyInfoReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessGetDossierV3Response xmlns="http://www.webservices.nl/soap/"><out><update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><update_types><item>Tradenames</item></update_types><date_last_update>2020-08-08</date_last_update></update_info><dossier_number>74438379</dossier_number><establishment_number>000042396913</establishment_number><main_establishment_number>000042396913</main_establishment_number><indication_main_establishment>true</indication_main_establishment><chamber_number>30</chamber_number><legal_form_code>1</legal_form_code><legal_form_text>Eenmanszaak</legal_form_text><indication_organisation_code>O</indication_organisation_code><legal_name/><trade_name_45>Swipe Products</trade_name_45><trade_name_full>Swipe Products</trade_name_full><trade_names><item>Swipe Products</item></trade_names><establishment_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/></formatted></establishment_address><correspondence_address><original><postcode>4205ZV</postcode><city>GORINCHEM</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></original><official><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>Nederland</country></official><formatted><postcode>4205ZV</postcode><city>Gorinchem</city><street>Valkeniersweg</street><house_number>75</house_number><house_number_addition/><country>NLD</country></formatted></correspondence_address><telephone_number/><mobile_number>06 52433408</mobile_number><domain_name>www.jrshandelsmaatschappij.nl</domain_name><contact_title1/><contact_title2/><contact_initials>J.W.</contact_initials><contact_prefix/><contact_surname>Bakar</contact_surname><contact_gender/><primary_sbi_code>47919</primary_sbi_code><secondary_sbi_code1/><secondary_sbi_code2/><primary_sbi_code_text>Detailhandel via internet in een algemeen assortiment non-food</primary_sbi_code_text><secondary_sbi_code1_text/><secondary_sbi_code2_text/><personnel>1</personnel><class_personnel>2</class_personnel><personnel_fulltime>0</personnel_fulltime><class_personnel_fulltime>1</class_personnel_fulltime><personnel_reference_date><year>2019</year><month>3</month><day>29</day></personnel_reference_date><personnel_ci>0</personnel_ci><class_personnel_ci>0</class_personnel_ci><indication_import>true</indication_import><indication_export>false</indication_export><indication_economically_active>true</indication_economically_active><indication_non_mailing>true</indication_non_mailing><indication_bankruptcy>false</indication_bankruptcy><indication_dip>false</indication_dip><establishment_date><year>2019</year><month>4</month><day>1</day></establishment_date><sbi_collection><original><item><sbi_code>47919</sbi_code><description>Detailhandel via internet in een algemeen assortiment non-food</description></item></original><company_info/></sbi_collection></out></dutchBusinessGetDossierV3Response></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://ws1.webservices.nl:443/soap_doclit.php', companyInfoReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('NL-X-502603400000');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: NL-X-502603400000', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        CreditFactoryCompany externalCompany = cfItem.companiesList.get(0);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();
        
        System.assertEquals('Update Name', addressUpdateData.get('header'));
        
        Map<String, Object> addressFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Testgear B.V.', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        CreditFactoryCompany externalCompany = cfItem.companiesList.get(0);
        CreditFactoryCompany additionalExternalCompany = cfItem.companiesList.get(1);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, additionalExternalCompany);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('DELFT', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

        creditFactoryDataMap.put('street', 'test');
        creditFactoryDataMap.put('postalStreet', 'test');
        creditFactoryDataMap.put('registeredStreet', 'test');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test empty address validation
    *  Created         : 02/10/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmptyAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        for (CreditFactoryCompany company : cfItem.companiesList) {
            if (company.recordType == 'Default') {
                company.street = null;
            }
        }

        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);
        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmptyAddress'}, true);
        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test vat number validation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        CreditFactoryCompany externalCompany = cfItem.companiesList.get(0);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('123123123', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test swift bic validation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSwiftBic() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'SwiftBic'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        Map<String, Object> swiftBicUpdateData = creditFactorySettings.returnSwiftBicUpdateData(internalCompany);

        System.assertEquals('Update SWIFT BIC', swiftBicUpdateData.get('header'));

        Map<String, Object> swiftBicFieldsToUpdate = creditFactory.returnSwiftBicFieldsToUpdate();
        System.assertEquals(true, swiftBicFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('AA12341234', ((Map<String, Object>) swiftBicFieldsToUpdate.get('Opportunity')).get('SWIFT_BIC__c'));

        creditFactoryDataMap.put('requestedSwiftBic', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'SwiftBic'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test mandate type validation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateMandateType() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '3';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'MandateType'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('totalConsumption', 3000);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'MandateType'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test contact validation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<AccountContactRelation> accountContactRelationsList = CreditFactoryService.selectAccountContactRelations(opportunity.AccountId);
        sobjectsList.addAll(accountContactRelationsList);
        List<OpportunityContactRole> opportunityContactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(opportunityContactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Contact'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        Map<String, Object> contactRoleFieldsToUpdate = creditFactory.returnCallFieldsToUpdate('12341234');
        System.assertEquals(true, contactRoleFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals(true, ((Map<String, Object>) contactRoleFieldsToUpdate.get('Opportunity')).get('Contact_Role_Confirmation_Call__c') != null);

        for (Map<String, Object> contact : (List<Map<String, Object>>) creditFactoryDataMap.get('creditFactoryContacts')) {
            if (contact.get('relation') == 'AccountContactRelation') {
                contact.put('firstName', 'test');
                contact.put('lastName', 'test');
                break;
            }
        }

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Contact'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test contact validation
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestParentCompanyContacts() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<AccountContactRelation> accountContactRelationsList = CreditFactoryService.selectAccountContactRelations(opportunity.AccountId);
        sobjectsList.addAll(accountContactRelationsList);
        List<OpportunityContactRole> opportunityContactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(opportunityContactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        List<Credit_Factory_Report_Employee__c> employeesList = new List<Credit_Factory_Report_Employee__c>();
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock creditSafeAuthMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', creditSafeAuthMock);
            SingleRequestMock creditsafeReportMock = new SingleRequestMock(200, 'Complete', '{"orderId": "N/A","companyId": "NL-X-634214960000","dateOfOrder": "2019-08-08T14:27:56.770Z","language": "en","userId": "1000461520","chargeRef": null,"report": {"companyId": "NL001-X-634214960000","language": "EN","companySummary": {"businessName": "Freyja Fence B.V.","country": "NL","companyNumber": "NL03987521","companyRegistrationNumber": "63421496","mainActivity": {"code": "46699","description": "Wholesale of other machines, equipment and supplies for manufacturing and trade n.e.c.","classification": "SBI 2008"},"companyStatus": {"status": "Active","description": "ACTIVE"},"latestShareholdersEquityFigure": {"currency": "EUR","value": 133641},"creditRating": {"commonValue": "C","commonDescription": "Moderate Risk","creditLimit": {"value": "7500"},"providerValue": {"maxValue": "100","minValue": "0","value": "49"},"providerDescription": "Low chance of financial calamity"}},"companyIdentification": {"basicInformation": {"businessName": "Freyja Fence B.V.","registeredCompanyName": "Freyja Fence B.V.","companyRegistrationNumber": "63421496","country": "NL","companyRegistrationDate": "2015-05-29T00:00:00Z","operationsStartDate": "2015-05-29T00:00:00Z","legalForm": {"providerCode": "41","description": "Private limited liability company (BV) with ordinary structure"},"companyStatus": {"status": "Active","description": "ACTIVE"},"principalActivity": {"code": "46699","description": "Wholesale of other machines, equipment and supplies for manufacturing and trade n.e.c.","classification": "SBI 2008"},"contactAddress": {"simpleValue": "32 De Huufkes, NUENEN 5674TM","street": "De Huufkes","houseNumber": "32","city": "NUENEN","postalCode": "5674TM","province": "Brabant","telephone": "0621572525","country": "NL"}},"activityClassifications": [{"classification": "SBI 2008","activities": [{"code": "46699","description": "Wholesale of other machines, equipment and supplies for manufacturing and trade n.e.c."},{"code": "77299","description": "Renting of other consumer goods n.e.c."},{"code": "De in- en verkoop en verhuur van hekwerken en toebehoren.,Full service leverancier gericht op de evenementenbranche, het geven van adviezen aan, het begeleiden van evenementenorganisaties alsmede het verhuren of verkopen van evenementenvoorzieningen.,Het verrichten van activiteiten in de algehele bouwhekbranche inclusief verhuur, verkoop en dienstverlening."}]}]},"creditScore": {"currentCreditRating": {"commonValue": "C","commonDescription": "Moderate Risk","creditLimit": {"value": "7500"},"providerValue": {"maxValue": "100","minValue": "0","value": "49"},"providerDescription": "Low chance of financial calamity"},"previousCreditRating": {"commonValue": "C","commonDescription": "Moderate Risk","creditLimit": {"value": "7500"},"providerValue": {"value": "55"},"providerDescription": "Low chance of financial calamity"},"latestRatingChangeDate": "2019-04-07T23:30:40Z"},"contactInformation": {"mainAddress": {"simpleValue": "32 De Huufkes, NUENEN 5674TM","street": "De Huufkes","houseNumber": "32","city": "NUENEN","postalCode": "5674TM","province": "Brabant","telephone": "0621572525","country": "NL"},"otherAddresses": [{"simpleValue": "32 De Huufkes, NUENEN 5674TM","street": "De Huufkes","houseNumber": "32","city": "NUENEN","postalCode": "5674TM","country": "NL"}]},"shareCapitalStructure": {"issuedShareCapital": {"value": 10},"shareHolders": [{"name": "Heblo B.V.","address": {"simpleValue": "32 De Huufkes, NUENEN 5674TM","street": "De Huufkes","houseNumber": "32","city": "NUENEN","postalCode": "5674TM","country": "NL"},"percentSharesHeld": 100}]},"directors": {"currentDirectors": [{"id": "63421496","name": "Heblo B.V.","firstNames": "Heblo B.V.","gender": "Unknown","directorType": "Company","positions": [{"dateAppointed": "2015-05-29T00:00:00Z","positionName": "Enig aandeelhouder"}]},{"id": "63421496","name": "Heblo B.V.","firstNames": "Heblo B.V.","gender": "Unknown","directorType": "Company","positions": [{"dateAppointed": "2015-05-29T00:00:00Z","positionName": "Algemeen directeur","authority": "Alleen/zelfstandig bevoegd"}]}]},"otherInformation": {"employeesInformation": [{"year": 2017,"numberOfEmployees": "5"},{"year": 2016,"numberOfEmployees": "5"},{"year": 2015,"numberOfEmployees": "5"}]},"groupStructure": {},"extendedGroupStructure": [{"id": "NL-X-171932870000","country": "NL","safeNumber": "NL00869697","companyName": "Heblo B.V.","registeredNumber": "171932870000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 0,"status": "Active","commonRatingBand": "B"},{"id": "NL-X-634214960000","country": "NL","safeNumber": "NL03987521","companyName": "Freyja Fence B.V.","registeredNumber": "634214960000","latestAnnualAccounts": "2017-12-31T00:00:00Z","level": 1,"status": "Active","commonRatingBand": "C"}],"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 13904,"totalIntangibleAssets": 77000,"investments": 1300,"totalFixedAssets": 92204,"miscellaneousReceivables": 189762,"totalReceivables": 189762,"cash": 34668,"totalCurrentAssets": 224430,"totalAssets": 316634,"miscellaneousLiabilities": 171443,"totalCurrentLiabilities": 171443,"miscellaneousLiabilitiesDueAfter1Year": 11550,"totalLongTermLiabilities": 11550,"totalLiabilities": 182993,"calledUpShareCapital": 10,"otherReserves": 133631,"totalShareholdersEquity": 133641},"otherFinancials": {"workingCapital": 52987,"netWorth": 56641},"ratios": {"currentRatio": 1.31,"liquidityRatioOrAcidTest": 1.31,"currentDebtRatio": 1.28,"gearing": 8.64,"equityInPercentage": 55.77,"totalDebtRatio": 1.37}},{"type": "GlobalFinancialsGGS","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 10921,"totalIntangibleAssets": 88000,"investments": 1300,"totalFixedAssets": 100221,"miscellaneousReceivables": 232190,"totalReceivables": 232190,"cash": 9429,"totalCurrentAssets": 241619,"totalAssets": 341840,"miscellaneousLiabilities": 244044,"totalCurrentLiabilities": 244044,"miscellaneousLiabilitiesDueAfter1Year": 13200,"totalLongTermLiabilities": 13200,"totalLiabilities": 257244,"calledUpShareCapital": 10,"otherReserves": 84586,"totalShareholdersEquity": 84596},"otherFinancials": {"workingCapital": -2425,"netWorth": -3404},"ratios": {"currentRatio": 0.99,"liquidityRatioOrAcidTest": 0.99,"currentDebtRatio": 2.88,"gearing": 15.6,"equityInPercentage": 33.33,"totalDebtRatio": 3.04}},{"type": "GlobalFinancialsGGS","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"totalTangibleAssets": 5966,"totalIntangibleAssets": 99000,"totalFixedAssets": 104966,"totalInventories": 13882,"miscellaneousReceivables": 194084,"totalReceivables": 194084,"cash": 12965,"totalCurrentAssets": 220931,"totalAssets": 325897,"miscellaneousLiabilities": 228904,"totalCurrentLiabilities": 228904,"miscellaneousLiabilitiesDueAfter1Year": 14850,"totalLongTermLiabilities": 14850,"totalLiabilities": 243754,"calledUpShareCapital": 10,"otherReserves": 82133,"totalShareholdersEquity": 82143},"otherFinancials": {"workingCapital": -7973,"netWorth": -16857},"ratios": {"currentRatio": 0.97,"liquidityRatioOrAcidTest": 0.9,"currentDebtRatio": 2.79,"gearing": 18.08,"equityInPercentage": 36.2,"totalDebtRatio": 2.97}}],"localFinancialStatements": [{"type": "LocalFinancialStatement","yearEndDate": "2017-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"intangibleAsset": 77000,"tangibleAssets": 13904,"financialFixedAssets": 1300,"fixedAssets": 92204,"otherReceivables": 189762,"cash": 34668,"miscCurrentAssets": 0,"currentAssetsTotal": 224430,"totalAssets": 316634,"issuedShareCapital": 10,"retainedEarnings": 0,"otherReserves": 133631,"groupNetWorth": 0,"totalEquity": 133641,"provisions": 11550,"otherLongTermLiabilities": 0,"totalLongTermDebts": 11550,"miscCurrentLiabilities": 171443,"totalCurrentLiabilities": 171443},"otherFinancials": {"workingCapital": 52987,"netWorth": 56641},"ratios": {"currentRatio": 1.31,"liquidityRatio": 1.31,"currentDebtRatio": 1.28,"gearing": 8.64,"equityInPercentage": 55.77,"totalDebtRatio": 1.37}},{"type": "LocalFinancialStatement","yearEndDate": "2016-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"intangibleAsset": 88000,"tangibleAssets": 10921,"financialFixedAssets": 1300,"fixedAssets": 100221,"otherReceivables": 232190,"cash": 9429,"miscCurrentAssets": 0,"currentAssetsTotal": 241619,"totalAssets": 341840,"issuedShareCapital": 10,"retainedEarnings": 0,"otherReserves": 84586,"groupNetWorth": 0,"totalEquity": 84596,"provisions": 13200,"otherLongTermLiabilities": 0,"totalLongTermDebts": 13200,"miscCurrentLiabilities": 244044,"totalCurrentLiabilities": 244044},"otherFinancials": {"workingCapital": -2425,"netWorth": -3404},"ratios": {"currentRatio": 0.99,"liquidityRatio": 0.99,"currentDebtRatio": 2.88,"gearing": 15.6,"equityInPercentage": 33.33,"totalDebtRatio": 3.04}},{"type": "LocalFinancialStatement","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","consolidatedAccounts": false,"balanceSheet": {"intangibleAsset": 99000,"tangibleAssets": 5966,"financialFixedAssets": 0,"fixedAssets": 104966,"inventories": 13882,"otherReceivables": 194084,"cash": 12965,"miscCurrentAssets": 0,"currentAssetsTotal": 220931,"totalAssets": 325897,"issuedShareCapital": 10,"retainedEarnings": 0,"otherReserves": 82133,"groupNetWorth": 0,"totalEquity": 82143,"provisions": 14850,"otherLongTermLiabilities": 0,"totalLongTermDebts": 14850,"miscCurrentLiabilities": 228904,"totalCurrentLiabilities": 228904},"otherFinancials": {"workingCapital": -7973,"netWorth": -16857},"ratios": {"currentRatio": 0.97,"liquidityRatio": 0.9,"currentDebtRatio": 2.79,"gearing": 18.08,"equityInPercentage": 36.2,"totalDebtRatio": 2.97}}],"additionalInformation": {"misc": {"exporter": "No","importer": "No","rsinNumber": "855228660","companyAge": 4,"latestAccountsDate": "2017-12-31T00:00:00Z","numberOfSearchesL12": 7,"kvkStatus": "C-Changed","branchNumber": "000032339453","statutaireSeal": "Nuenen, Gerwen en Nederwetten","employeeNumber": "5","employeeClass": "04"},"industryQuartileAnalysis": {"paymentExpectationDays": {"paymentExpectationsLower": 38.47,"paymentExpectationsMedian": 49.04,"paymentExpectationsUpper": 63.28},"daySalesOutstanding": {"daySalesOutstandingLower": 11.4,"daySalesOutstandingMedian": 29.41,"daySalesOutstandingUpper": 55.02}},"industryComparison": {"industryAverageCreditRating": 57.1,"industryAverageCreditLimit": 56845.63},"paymentExpectationsSummary": {"suspensionOfPaymentsMora": "No","industryAveragePaymentExpectationDays": 52.78,"industryAverageDaySalesOutstanding": 60.29},"ratingHistory": [{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "55"},"date": "2019-04-07T23:30:40Z"},{"commonValue": "B","commonDescription": "Low Risk","providerValue": {"value": "64"},"date": "2019-03-07T23:30:37Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "49"},"date": "2018-08-31T18:59:27Z"},{"commonValue": "C","commonDescription": "Moderate Risk","providerValue": {"value": "38"},"date": "2018-05-03T23:10:00Z"}],"limitHistory": [{"date": "2019-04-07T23:30:40Z","companyValue": 7500},{"date": "2019-03-07T23:30:37Z","companyValue": 9500},{"date": "2018-08-31T18:59:27Z","companyValue": 7500},{"date": "2018-05-03T23:10:00Z","companyValue": 5500}],"commentaries": [{"commentaryText": "The business was established over 4 years ago.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has 4 employees.","positiveOrNegative": "Neutral"},{"commentaryText": "The business is part of a group.","positiveOrNegative": "Neutral"},{"commentaryText": "The business has been at the address for over 3 years.","positiveOrNegative": "Neutral"},{"commentaryText": "There has been no significant change in the business\'s credit limit.","positiveOrNegative": "Neutral"},{"commentaryText": "The credit rating for this business has decreased from 55 to 49 on 08-06-2019.","positiveOrNegative": "Negative"},{"commentaryText": "The financial statements on file are 19 months old.","positiveOrNegative": "Neutral"},{"commentaryText": "The business saw an increase in their Cash Balance of 267% during the latest trading period.","positiveOrNegative": "Positive"}],"companyHistory": [{"date": "2016-03-17T22:39:30Z","description": "MAIL HOUSE NO CHANGE","previousValue": "40","currentValue": "32"},{"date": "2016-03-17T22:39:33Z","description": "MAIL POSTAL CODE CHANGE","previousValue": "5674CD","currentValue": "5674TM"},{"date": "2016-03-17T22:39:44Z","description": "MAIL STREET NAME CHANGE","previousValue": "Spegelt","currentValue": "De Huufkes"},{"date": "2016-03-17T22:40:05Z","description": "Address changed.","previousValue": "5674CD","currentValue": "5674TM"},{"date": "2016-03-17T22:40:13Z","description": "Address changed.","previousValue": "40","currentValue": "32"},{"date": "2016-03-17T22:40:16Z","description": "Address changed.","previousValue": "Spegelt","currentValue": "De Huufkes"},{"date": "2016-07-14T00:37:32Z","description": "New accounts filed.","currentValue": "31/12/2015"},{"date": "2017-08-10T19:29:30Z","description": "New accounts filed.","currentValue": "31/12/2016"},{"date": "2018-05-03T23:58:55Z","description": "New accounts filed.","currentValue": "31/12/2017"}],"kvkFilings": [{"filingDate": "2015-06-01T00:00:00Z","filedEvent": "Director in/out of appointement"},{"filingDate": "2016-06-29T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2018-04-18T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2017-03-10T00:00:00Z","filedEvent": "New financial accounts filed"},{"filingDate": "2015-06-01T00:00:00Z","filedEvent": "New establishment"}],"tradingStyles": [{"tradingName": "Freyja Fence B.V."}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL001-X-634214960000', creditsafeReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            employeesList = creditFactory.requestParentCompanyContacts('NL001-X-634214960000');
        Test.stopTest();

        System.assertEquals(1, employeesList.size());
    }


    /*******************************************************************************
    *  Summary         : test lost opportunities
    *  Created         : 11/09/2020 by Anton
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<AccountContactRelation> accountContactRelationsList = CreditFactoryService.selectAccountContactRelations(opportunity.AccountId);
        sobjectsList.addAll(accountContactRelationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'LostOpportunities'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        Opportunity lostOpportunity = CreditFactoryTestUtils.generateOpportunityPL();
        lostOpportunity.AccountId = account.Id;
        lostOpportunity.StageName = 'Closed Lost';
        lostOpportunity.Gruende_verloren__c = 'Refused Credit';
        insert lostOpportunity;

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'LostOpportunities'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test email risk validation
    *  Created         : 23/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Netherlands');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmailRisk'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        for (CreditFactoryCompany company : cfItem.companiesList) {
            if (company.recordType == 'Default') {
                company.emailRisk = 'High';
                company.emailExists = 'No';
                break;
            }
        }

        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmailRisk'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '30');
        creditFactoryDataMap.put('desiredPaymentTerms', '14');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 7', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 7', cfResult.messagesList.get(1).text);
        System.assertEquals('If you want to close your Opportunity with ' +
            'desired billing period and desired payment terms, please refer to Credit.', cfResult.messagesList.get(2).text);
        System.assertEquals('Desired payment terms (14) cannot be provided.', cfResult.messagesList.get(3).text);

        Map<String, Object> updateOpportunityFieldsMap = creditFactory.returnUpdateOpportunityFieldsToUpdate();
        System.assertEquals(true, updateOpportunityFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) updateOpportunityFieldsMap.get('Opportunity')).get('Credit_check_date__c'));

        Map<String, Object> closedWonFieldsMap = creditFactory.returnClosedWonFieldsToUpdate();
        System.assertEquals(true, closedWonFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) closedWonFieldsMap.get('Opportunity')).get('CloseDate'));
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '2';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '2';
        report.Credit_Limit__c = null;
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '15');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(3, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 2
    *  Created         : 19/01/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '2';
        report.Date_of_Foundation__c = String.valueOf(Date.today());
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '3';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 3
    *  Created         : 21/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Zahlungsziel_2__c = '30';
        testOpportunity.Rechnungsperiode_2__c = '7';
        testOpportunity.Total_consumption_l_month__c = 1000;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '3';
        report.Credit_Limit__c = '100';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(3, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '4';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 4)', cfResult.depositReason);
        System.assertEquals(100, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '5';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 5)', cfResult.depositReason);
        System.assertEquals(110, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 11/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Netherlands');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 20000;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Netherlands');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}