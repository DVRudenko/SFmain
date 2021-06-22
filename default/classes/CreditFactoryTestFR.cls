@IsTest
public class CreditFactoryTestFR {

    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountFR();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityFR();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactFR();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('France');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('France');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c creditSafeSettings = CreditFactoryTestUtils.generateCreditsafeSetting();
        customSettingsList.add(creditSafeSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'France', Index__c = 1.35);
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

        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'FR');
        insert riskyBusinessCode;
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplFR);
    }


        /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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

        System.assertEquals('TESTS OPTIMUM', company.name);
    }


    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        creditFactorySettings.returnSearchValidations();
    }


    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyFR();
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSepaAttachments() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidatePaymentMethod() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountFR();
        dupAccount.Steuernummer__c = '537643966';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityFR();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactFR();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplFR);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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

        System.assertEquals('TESTS OPTIMUM', company.name);
    }


    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunity.Id);

        System.assertEquals(1, cfItem.companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company by tax id
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByTax() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"totalSize": 1, "correlationId": "bc4cd350-fcd0-11ea-82e6-0260e6fc8b9d", "companies": [{"address": {"city": "PERET", "simpleValue": "10 , RUE DE LA CLAIRETTE, 34800, PERET", "street": "RUE DE LA CLAIRETTE", "postCode": "34800", "houseNo": "10"}, "country": "FR", "safeNo": "FR00154869", "name": "TEST OPTIMUM", "vatNo": ["FR0537643967"], "id": "FR-X-537643967", "officeType": "headOffice", "phoneNumbers": ["3219677569"], "activityCode": "46699", "dateOfLatestAccounts": "2009-12-31T00:00:00.000000Z", "regNo": 537643967, "status": "active"}]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=FR&regNo=537643967', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company by all parameters
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByAllParameters() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "a6c457a0-f439-11ea-82e6-0260e6fc8b9d","totalSize": 0,"companies": [],"messages": [ {"type": "Information","code": "NoResults","text": "No companies matching specified search criteria found." }]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=FR&regNo=537643967', searchMock);
            SingleRequestMock searchMock2 = new SingleRequestMock(200, 'Complete', '{"totalSize": 1, "correlationId": "bc4cd350-fcd0-11ea-82e6-0260e6fc8b9d", "companies": [{"address": {"city": "PERET", "simpleValue": "10 , RUE DE LA CLAIRETTE, 34800, PERET", "street": "RUE DE LA CLAIRETTE", "postCode": "34800", "houseNo": "10"}, "country": "FR", "safeNo": "FR00154869", "name": "TEST OPTIMUM", "vatNo": ["FR0537643967"], "id": "FR-X-537643967", "officeType": "headOffice", "phoneNumbers": ["3219677569"], "activityCode": "46699", "dateOfLatestAccounts": "2009-12-31T00:00:00.000000Z", "regNo": 537643967, "status": "active"}]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=FR&name=TESTS%2520OPTIMUM&city=PERET&street=RUE%20DE%20LA%20CLAIRETTE', searchMock2);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
            SingleRequestMock creditsafeReportMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "6ff523c0-1e9c-11eb-9e62-026acd9cdfbf","orderId": "N/A","companyId": "FR-X-53764396700012","dateOfOrder": "2020-11-04T12:51:26.611Z","language": "en","userId": "101495027","report": {"companyId": "FR-X-53764396700012","language": "EN","companySummary": {"businessName": "TESTS OPTIMUM","country": "FR","companyNumber": "FR14237460","companyRegistrationNumber": "53764396700012","mainActivity": {"code": "7320Z","description": "Études de marché et sondages","classification": "NAF/APE"},"companyStatus": {"status": "Active","description": "Economically active"},"latestTurnoverFigure": {"currency": "EUR","value": 288534.0},"latestShareholdersEquityFigure": {"currency": "EUR","value": 64663.0},"creditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "10000"},"providerValue": {"maxValue": "100","minValue": "0","value": "80"},"providerDescription": "Very Good Credit Worthiness"}},"companyIdentification": {"basicInformation": {"businessName": "-","registeredCompanyName": "TESTS OPTIMUM","companyRegistrationNumber": "53764396700012","country": "FR","vatRegistrationNumber": "FR05537643967","companyRegistrationDate": "2011-11-01T00:00:00Z","operationsStartDate": "2011-10-01T00:00:00Z","commercialCourt": "RCS Beziers 1","legalForm": {"providerCode": "5499","description": "Limited Liability Company"},"companyStatus": {"status": "Active","description": "Economically active"},"principalActivity": {"code": "7320Z","description": "Études de marché et sondages","classification": "NAF/APE"},"contactAddress": {"simpleValue": "10 RUE DE LA CLAIRETTE 34800 PERET","street": "10 RUE DE LA CLAIRETTE","houseNumber": "10","city": "PERET","postalCode": "34800","telephone": "0467447010","country": "FR"}},"activityClassifications": [{"classification": "NAF/APE","activities": [{"code": "7320Z","description": "Études de marché et sondages"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "10000"},"providerValue": {"maxValue": "100","minValue": "0","value": "80"},"providerDescription": "Very Good Credit Worthiness"},"previousCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "7500"},"providerValue": {"maxValue": "100","minValue": "0","value": "79"},"providerDescription": "Very Good Credit Worthiness"},"latestRatingChangeDate": "2020-09-19T00:00:00Z"},"contactInformation": {"mainAddress": {"simpleValue": "10 RUE DE LA CLAIRETTE 34800 PERET","street": "RUE DE LA CLAIRETTE","houseNumber": "10","city": "PERET","postalCode": "34800","telephone": "04 67 44 70 10","country": "FR"}},"shareCapitalStructure": {"nominalShareCapital": {"value": 10000.0}},"directors": {"currentDirectors": [{"name": "M RUBINOCCI RENÉ","gender": "Male","dateOfBirth": "1961-08-22T00:00:00Z","placeOfBirth": "NANTERRE","directorType": "Other","positions": [{"positionName": "Manager"}]}],"previousDirectors": [{"name": "M RENÉ RUBINOCCI","gender": "Male","dateOfBirth": "1961-08-22T00:00:00Z","placeOfBirth": "NANTERRE à 22/08/1961","directorType": "Other","positions": [{"positionName": "Manager"}]},{"name": "M RENÉ RUBINOCCI","gender": "Male","dateOfBirth": "1961-08-22T00:00:00Z","placeOfBirth": "NANTERRE (92) à 22/08/1961","directorType": "Other","positions": [{"positionName": "Manager"}]}]},"otherInformation": {"employeesInformation": [{"year": 2015,"numberOfEmployees": "0"}]},"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 288535.0,"operatingCosts": 232152.0,"operatingProfit": 56383.0,"wagesAndSalaries": 49010.0,"depreciation": 230.0,"financialExpenses": 61.0,"extraordinaryIncome": 690.0,"profitBeforeTax": 56832.0,"tax": 11955.0,"profitAfterTax": 44877.0,"retainedProfit": 44877.0},"balanceSheet": {"otherTangibleAssets": 4027.0,"totalTangibleAssets": 4027.0,"totalFixedAssets": 4027.0,"rawMaterials": 656.0,"totalInventories": 656.0,"tradeReceivables": 110666.0,"miscellaneousReceivables": 23436.0,"totalReceivables": 134102.0,"cash": 104666.0,"otherCurrentAssets": 182.0,"totalCurrentAssets": 239606.0,"totalAssets": 243633.0,"tradePayables": 143786.0,"bankLiabilities": 2371.0,"miscellaneousLiabilities": 32813.0,"totalCurrentLiabilities": 178970.0,"totalLiabilities": 178970.0,"calledUpShareCapital": 10000.0,"revenueReserves": 44877.0,"otherReserves": 9786.0,"totalShareholdersEquity": 64663.0},"otherFinancials": {"workingCapital": 60636.0,"netWorth": 64663.0},"ratios": {"preTaxProfitMargin": 19.70,"returnOnCapitalEmployed": 87.89,"returnOnTotalAssetsEmployed": 23.33,"returnOnNetAssetsEmployed": 87.89,"salesOrNetWorkingCapital": 4.76,"stockTurnoverRatio": 0.23,"debtorDays": 139.99,"creditorDays": 181.89,"currentRatio": 1.34,"liquidityRatioOrAcidTest": 1.34,"currentDebtRatio": 2.77,"gearing": 3.67,"equityInPercentage": 26.54,"totalDebtRatio": 2.77}},{"type": "GlobalFinancialsGGS","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 146489.0,"operatingCosts": 142067.0,"operatingProfit": 4422.0,"wagesAndSalaries": 42477.0,"financialExpenses": 57.0,"extraordinaryIncome": 260.0,"extraordinaryCosts": 190.0,"profitBeforeTax": 4436.0,"tax": 665.0,"profitAfterTax": 3771.0,"retainedProfit": 3771.0},"balanceSheet": {"totalInventories": 129.0,"tradeReceivables": 102904.0,"miscellaneousReceivables": 23494.0,"totalReceivables": 126398.0,"cash": 12438.0,"totalCurrentAssets": 138966.0,"totalAssets": 138966.0,"tradePayables": 75088.0,"otherLoansOrFinance": 948.0,"miscellaneousLiabilities": 43144.0,"totalCurrentLiabilities": 119180.0,"calledUpShareCapital": 10000.0,"revenueReserves": 3771.0,"otherReserves": 6015.0,"totalShareholdersEquity": 19786.0},"otherFinancials": {"workingCapital": 19786.0,"netWorth": 19786.0},"ratios": {"preTaxProfitMargin": 3.03,"returnOnCapitalEmployed": 22.42,"returnOnTotalAssetsEmployed": 3.19,"returnOnNetAssetsEmployed": 3.19,"salesOrNetWorkingCapital": 7.40,"stockTurnoverRatio": 0.09,"debtorDays": 256.40,"creditorDays": 187.09,"currentRatio": 1.17,"liquidityRatioOrAcidTest": 1.16,"currentDebtRatio": 6.02,"equityInPercentage": 14.24,"totalDebtRatio": 6.02}},{"type": "GlobalFinancialsGGS","yearEndDate": "2013-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 80378.0,"operatingCosts": 76862.0,"operatingProfit": 3516.0,"wagesAndSalaries": 5576.0,"financialExpenses": 115.0,"extraordinaryIncome": 250.0,"profitBeforeTax": 3353.0,"tax": 419.0,"profitAfterTax": 2934.0,"retainedProfit": 2934.0},"balanceSheet": {"rawMaterials": 144.0,"totalInventories": 144.0,"tradeReceivables": 55122.0,"miscellaneousReceivables": 401.0,"totalReceivables": 55523.0,"cash": 6796.0,"totalCurrentAssets": 62463.0,"totalAssets": 62463.0,"tradePayables": 4816.0,"bankLiabilities": 3254.0,"miscellaneousLiabilities": 38378.0,"totalCurrentLiabilities": 46448.0,"totalLiabilities": 46448.0,"calledUpShareCapital": 10000.0,"revenueReserves": 2934.0,"otherReserves": 3081.0,"totalShareholdersEquity": 16015.0},"otherFinancials": {"workingCapital": 16015.0,"netWorth": 16015.0},"ratios": {"preTaxProfitMargin": 4.17,"returnOnCapitalEmployed": 20.94,"returnOnTotalAssetsEmployed": 5.37,"returnOnNetAssetsEmployed": 20.94,"salesOrNetWorkingCapital": 5.02,"stockTurnoverRatio": 0.18,"debtorDays": 250.31,"creditorDays": 21.87,"currentRatio": 1.34,"liquidityRatioOrAcidTest": 1.34,"currentDebtRatio": 2.90,"gearing": 20.32,"equityInPercentage": 25.64,"totalDebtRatio": 2.90}}],"localFinancialStatements": [{"type": "LocalFinancialsSynthesizedCSFR","yearEndDate": "2015-12-31T00:00:00Z","currency": "EUR","month": 12,"financialReportDescription": "Normal Account","numberOfEmployees": 0,"assets": {"capitalNotCalled": 0.0,"totalFixedAssets": 4027.0,"intangibleAssets": 0.0,"tangibleAssets": 4027.0,"financialAssets": 0.0,"netCurrentAssets": 239606.0,"stocks": 656.0,"advancedPayments": 0.0,"receivables": 134284.0,"tradeReceivables": 110666.0,"miscellaneousReceivables": 23436.0,"securitiesAndCash": 104666.0,"prepaidExpenses": 0.0,"accountsOfRegularization": 0.0,"totalAssets": 243633.0,"miscellaneousTotalAssets": 4027.0,"netWorth": 64663.0},"liabilities": {"shareholdersEquity": 64663.0,"shareCapital": 10000.0,"revaluationReserve": 0.0,"otherReserves": 54663.0,"otherCapitalResources": 0.0,"provisionsForRisksAndCharges": 0.0,"liabilities": 178970.0,"financialLiabilities": 2371.0,"advancedPaymentsReceived": 0.0,"tradeAccountPayables": 143786.0,"taxAndSocialLiabilities": 31973.0,"otherDebtsAndFixedAssetsLiabilities": 840.0,"accountRegularization": 0.0,"totalLiabilitiesAndEquity": 243633.0,"bankLoansAndLiabilities": 0.0,"sundryLoansAndLiabilities": 0.0,"miscellaneousLiabilities": 840.0},"profitAndLoss": {"salesOfGoods": 288535.0,"netTurnover": 288534.0,"netExportTurnover": 0.0,"operatingCharges": 232152.0,"operatingProfit": 56383.0,"financialIncome": 0.0,"financialCharges": 61.0,"financialProfitOrLoss": -61.0,"pretaxNetOperatingIncome": 56322.0,"extraordinaryIncome": 690.0,"extraordinaryCharges": 180.0,"extraordinaryProfitOrLoss": 510.0,"netResult": 44877.0}},{"type": "LocalFinancialsSynthesizedCSFR","yearEndDate": "2014-12-31T00:00:00Z","currency": "EUR","month": 12,"financialReportDescription": "Simple Account","numberOfEmployees": 0,"assets": {"capitalNotCalled": 0.0,"totalFixedAssets": 0.0,"intangibleAssets": 0.0,"tangibleAssets": 0.0,"financialAssets": 0.0,"netCurrentAssets": 138965.0,"stocks": 129.0,"advancedPayments": 0.0,"receivables": 126398.0,"securitiesAndCash": 12438.0,"prepaidExpenses": 0.0,"accountsOfRegularization": 0.0,"totalAssets": 138965.0,"miscellaneousTotalAssets": 0.0,"netWorth": 19786.0},"liabilities": {"shareholdersEquity": 19786.0,"shareCapital": 10000.0,"otherReserves": -10000.0,"otherCapitalResources": 0.0,"provisionsForRisksAndCharges": 0.0,"liabilities": 119181.0,"financialLiabilities": 948.0,"advancedPaymentsReceived": 0.0,"tradeAccountPayables": 75088.0,"taxAndSocialLiabilities": 0.0,"otherDebtsAndFixedAssetsLiabilities": 43145.0,"accountRegularization": 0.0,"totalLiabilitiesAndEquity": 138967.0},"profitAndLoss": {"salesOfGoods": 146489.0,"netTurnover": 146475.0,"netExportTurnover": 0.0,"operatingCharges": 142067.0,"operatingProfit": 4422.0,"financialIncome": 0.0,"financialCharges": 57.0,"financialProfitOrLoss": -57.0,"pretaxNetOperatingIncome": 4365.0,"extraordinaryIncome": 260.0,"extraordinaryCharges": 190.0,"extraordinaryProfitOrLoss": 70.0,"netResult": 3771.0}},{"type": "LocalFinancialsSynthesizedCSFR","yearEndDate": "2013-12-31T00:00:00Z","currency": "EUR","month": 12,"financialReportDescription": "Normal Account","numberOfEmployees": 0,"assets": {"capitalNotCalled": 0.0,"totalFixedAssets": 0.0,"intangibleAssets": 0.0,"tangibleAssets": 0.0,"financialAssets": 0.0,"netCurrentAssets": 62463.0,"stocks": 144.0,"advancedPayments": 0.0,"receivables": 55523.0,"tradeReceivables": 55122.0,"miscellaneousReceivables": 401.0,"securitiesAndCash": 6796.0,"prepaidExpenses": 0.0,"accountsOfRegularization": 0.0,"totalAssets": 62463.0,"miscellaneousTotalAssets": 0.0,"netWorth": 16015.0},"liabilities": {"shareholdersEquity": 16015.0,"shareCapital": 10000.0,"revaluationReserve": 0.0,"otherReserves": 6015.0,"otherCapitalResources": 0.0,"provisionsForRisksAndCharges": 0.0,"liabilities": 46448.0,"financialLiabilities": 3254.0,"advancedPaymentsReceived": 0.0,"tradeAccountPayables": 4816.0,"taxAndSocialLiabilities": 22576.0,"otherDebtsAndFixedAssetsLiabilities": 15802.0,"accountRegularization": 0.0,"totalLiabilitiesAndEquity": 62463.0,"bankLoansAndLiabilities": 0.0,"sundryLoansAndLiabilities": 0.0,"miscellaneousLiabilities": 15802.0},"profitAndLoss": {"salesOfGoods": 80378.0,"netTurnover": 80378.0,"netExportTurnover": 0.0,"operatingCharges": 76862.0,"operatingProfit": 3516.0,"financialIncome": 0.0,"financialCharges": 115.0,"financialProfitOrLoss": -115.0,"pretaxNetOperatingIncome": 3401.0,"extraordinaryIncome": 250.0,"extraordinaryCharges": 298.0,"extraordinaryProfitOrLoss": -48.0,"netResult": 2934.0}},{"type": "LocalFinancialsFullCSFR","yearEndDate": "2015-12-31T00:00:00Z","currency": "EUR","month": 12,"assets": {"grandTotalAssets": {"grandTotalNet": 243633.0,"grandTotalGross": 243863.0,"grandTotalAmortisation": 230.0},"capitalSubscribedNotCalled": {"capitalSubscribed": 0.0},"activeFixedAsset": {"total": 4027.0,"gross": 4257.0,"amortisation": 230.0},"activeIntangibleFixedAssets": {"startupCost": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"researchAndDevelopmentExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"distributorshipsPatents": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodwill": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherIntangibleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"prepaymentsAndDownpayments": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalIntangibleAsset": 0.0},"tangilbleFixedAssets": {"land": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"buildings": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"plant": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherTangibleFixedAssets": {"total": 4027.0,"gross": 4257.0,"amortisation": 230.0},"fixedAssetsInConstruction": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"advancesAndPaymentsOnAccount": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalTangibleAsset": 4027.0},"financialAssets": {"associatesAtEquity": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherParticipations": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"intercompanyReceivables": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherInvestmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"loans": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherFinancialAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalFinancialAssets": 0.0},"activeAssets": {"total": 239606.0,"gross": 239606.0,"amortisation": 0.0},"activeStocks": {"rawMaterials": {"total": 656.0,"gross": 656.0,"amortisation": 0.0},"workInProgressGoods": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"workInProgressServices": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"semiFinishedAndFinishedProducts": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodsForResale": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalStocks": 656.0},"advancePaymentsToSupplier": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"activeDebtors": {"tradeAccountsReceivable": {"total": 110666.0,"gross": 110666.0,"amortisation": 0.0},"otherDebtors": {"total": 23436.0,"gross": 23436.0,"amortisation": 0.0},"capitalSubscribedAndCalledUp": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalDebtors": 134102.0},"activeDivers": {"investmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"cashAndCashEquivalents": {"total": 104666.0,"gross": 104666.0,"amortisation": 0.0},"subTotalDivers": 104666.0},"accountPrepaidExpenses": {"total": 182.0,"gross": 182.0,"amortisation": 0.0},"equalizationAccounts": {"multiPeriodCharges": 0.0,"premiumsOnRedemptionOfBonds": 0.0,"currencyDifferentialGain": 0.0},"assetsReferences": {"dueWithinOneYear": 0.0,"dueAfterOneYear": 0.0}},"liabilities": {"grandTotal": 243633.0,"shareholderEquity": {"totalShareholdersEquity": 64663.0,"equityAndShareholdersEquity": 10000.0,"issueAndMergerPremiums": 0.0,"revaluationDifferentials": 0.0,"ofWhichEquityDiffeential": 0.0,"legalReserve": 1000.0,"statutoryOrContractualReserve": 0.0,"specialRegulatedReserves": 0.0,"ofWhichSpecialReserveOfProvisions": 0.0,"otherReservesOfLiabilities": 8786.0,"ofWhichReserveForBuyingOriginalsWorks": 0.0,"profitsOrLossesBroughtForward": 0.0,"profitOrLossForThePeriod": 44877.0,"investmentGrants": 0.0,"specialTaxAllowableReserves": 0.0},"otherCapitalResource": {"totalOtherCapitalResources": 0.0,"incomeFromParticipatingSecurities": 0.0,"conditionalLoans": 0.0},"provisionsForRisksAndCharge": {"totalProvisionsForRisksAndCharges": 0.0,"riskProvisions": 0.0,"reservesForCharges": 0.0},"liabilities": {"totalLiabilities": 178970.0,"convertibleDebentures": 0.0,"otherDebentures": 0.0,"bankLoansAndLiabilities": 2371.0,"sundryLoansAndFinancialLiabilities": 0.0,"ofWhichParticipatingLoans": 0.0,"advancePaymentsReceivedForCurrentOrders": 0.0,"tradeAccountsPayables": 143786.0,"taxAndSocialSecurityLiabilities": 31973.0,"fixedAssetLiabilities": 0.0,"otherDebts": 840.0},"passiveAccountReferences": {"ofWhichTaxAllowableReserve": 1000.0,"deferredIncomeAndLiabilities": 178970.0,"ofWhichCurrentBankFacilities": 2371.0},"extraInformation": {"passiveTranslationLoss": 0.0,"deferredIncome": 0.0}},"profitAndLoss": {"operatingResult": 56383.0,"financialResult": -61.0,"resultsOfPreTaxNetOperatingIncome": 56322.0,"extraordinaryResult": 510.0,"profitOrLoss": 44877.0,"totalIncome": 289225.0,"totalCharges": 244348.0,"employeeProfitSharing": 0.0,"taxOnProfits": 11955.0,"operatingIncome": {"totalOperatingIncome": 288535.0,"goodsForResaleTotal": 0.0,"goodsForResaleFrance": 0.0,"goodsForResaleExport": 0.0,"goodsProducedTotal": 0.0,"goodsProducedFrance": 0.0,"goodsProducedExport": 0.0,"saleOfServicesTotal": 288534.0,"saleOfServicesFrance": 288534.0,"saleOfServicesExport": 0.0,"netTurnoverTotal": 288534.0,"netTurnoverFrance": 288534.0,"netTurnoverExport": 0.0,"stockedProduction": 0.0,"selfConstructedAssets": 0.0,"operatingGrants": 0.0,"releaseOfReservesAndProvisions": 0.0,"otherIncome": 1.0},"totalOperatingCharge": {"totalOperatingCharges": 232152.0,"purchaseOfGoodsForResale": 0.0,"changeInStocksOfGoodsForResale": 0.0,"purchaseOfRawMaterials": 0.0,"changeInStocksOfRawMaterials": -527.0,"otherExternalPurchasesAndCharges": 183084.0,"taxDutyAndSimilarPayments": 349.0,"payroll": 49010.0,"socialSecurityCosts": 0.0},"depreciation": {"depreciationOfFixedAssets": 230.0,"amortisationOfFixedAssets": 0.0,"depreciationAmortisationOfCurrentAssets": 0.0,"provisionsForRisksAndChargesOfResults": 0.0},"otherCharge": {"otherCharges": 5.0,"shareOfJointVentureTransferredToOtherPartner": 0.0,"shareOfJointVentureTransferredFromOtherPartner": 0.0},"resultsFinancialIncome": {"totalFinancialIncome": 0.0,"shareFinancialIncome": 0.0,"otherInvestmentIncomeAndCapitalisedReceivables": 0.0,"otherInterestAndSimilarIncome": 0.0,"releasedProvisions": 0.0,"exchangeGains": 0.0,"netIncomeFromDisposalOfInvestmentSecurities": 0.0},"financialCharge": {"totalFinancialChargeTotal": 61.0,"financialReservesAndProvisions": 0.0,"interestAndSimilarCharges": 61.0,"exchangeLosses": 0.0,"netLossFromDisposalOfInvestmentSecurities": 0.0},"additionalFinancialCharge": {"totalExtraordinaryIncome": 690.0,"extraordinaryOperatingIncome": 690.0,"extraordinaryIncomeFromCapitalTransactions": 0.0,"releasedProvisionsCharges": 0.0},"extraordinaryCharge": {"totalExtraordinaryCharges": 180.0,"extraordinaryOperatingCharges": 180.0,"extraordinaryChargesFromCapitalTransactions": 0.0,"extraordinaryReservesAndProvisions": 0.0},"references": {"ofWhichEquipmentLeases": 0.0,"ofWhichPropertyLeases": 0.0,"ofWhichTransferredCharges": 0.0,"ofWhichTradersOwnContributions": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsIncome": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsCharges": 0.0}},"otherIncomes": {"grossGrandTotalFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossResearchAndDevelopmentChargeFixed": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherBudgetItemFromIntangibleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherTangilbleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherFinancialAsset": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"situationAndMovementOfReserveForDepreciationGrandTotal": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"researchAndDevelopmentChargeReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"otherIntangibleAssetsReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalFixedAssedAmotisationReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"netMovementsDuringPeriodAffectingChargeAllocatedOverSeveralPeriod": {"valueAtEndOfPeriod": 0.0},"netPremiumRefundOfObligations": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"grandTotals": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"includesTotalAllocations": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"includesTotalWithdrawal": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"totalRegulatedProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalRiskAndChargeProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalProvisionForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"stateClaims": {"stateClaimsGrossValue": 0.0,"stateClaimsWhenOneYearAtMost": 0.0,"stateClaimsWhenmoreThanOneYear": 0.0},"stateOfLoans": {"claimsRelatedToHoldingsGross": 0.0,"claimsRelatedToShareholdingsOneYearAtMost": 0.0,"grossOfLoans": 0.0,"loansOneYearAtMost": 0.0,"otherFinancialAssetsGross": 0.0,"otherFinancialAssetsOneYearAtMost": 0.0},"receivablesStatementOfAssets": {"customersDoubtfulOrDisputed": 0.0,"otherClaimsCustomer": 0.0,"receivablesRepresentLoanedSecurities": 0.0,"provisionForDepreciationPreviouslyEstablished": 0.0,"personnelAndAssociatedAccounts": 0.0,"socialSecurityAndOtherSocialOrganizations": 0.0,"incomeTaxes": 0.0,"valueAddedTax": 0.0,"otherTaxesAndPaymentsAssimilatedOfReceivables": 0.0,"stateAndOtherPublicMiscellaneous": 0.0,"groupAndAssociates": 0.0,"accountsReceivableIncOtherClaims": 0.0},"stateDebt": {"totalDebtGross": 178969.0,"debtOneYearAtMost": 178969.0,"debtMoreThanOneYearAndFiveYearsAtMost": 0.0,"debtMoreThanFiveYears": 0.0},"details": {"convertibleBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToOneYearMaximumAtTheOrigin": {"gross": 2370.0,"oneYearAtMost": 2370.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToMoreThanOneYearAtTheOrigin": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"financialLiabilities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"suppliersAssociatedAccounts": {"gross": 143786.0,"oneYearAtMost": 143786.0,"moreThanOneYearAndFiveYearsAtMost": 143786.0},"personnelAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherSocialOrganizations": {"gross": 31972.0,"oneYearAtMost": 31972.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"taxesOnProfits": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"vat": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"backedObligations": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherTaxesAssimilated": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"assetsAndLiabilitiesAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"groupsAndAssociates": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"otherLiabilities": {"gross": 840.0,"oneYearAtMost": 840.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"debtOfBorrowedSecurities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"productsInAdvance": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0}},"referencesOthers": {"loansMadeDuringThePeriod": 0.0,"debtRepaidDuringThePeriod": 0.0},"commitments": {"commitmentsLeasingFurniture": 0.0,"commitmentsRealEstateLeasing": 0.0,"effectsBroughtToTheDiscountAndUnmatured": 0.0},"otherChargesExternal": {"subContracting": 0.0,"rentalsRentalChargesAndCondominiums": 0.0,"staffOutsideTheCompany": 0.0,"remunerationIntermediariesAndFeesExcludingFees": 0.0,"feesCommissionsAndBrokerage": 0.0,"otherAccounts": 0.0,"totalOtherPurchasesAndExternal": 0.0},"taxesAndFees": {"businessTax": 0.0,"otherTaxesAndPaymentsAssimilated": 0.0,"totalTaxesAndFees": 0.0},"vat": {"amountVatCollected": 0.0,"totalVatOnGoodsAndServices": 0.0},"extraInformation": {"averageNumberOfEmployees": 0.0,"dividends": 0.0,"prepaid": 0.0}},"ratios": {"structureAndLiquidity": {"fixedAssetFinancing": 15.24,"globalDebt": 223.0,"workingCapitalFundOverallNet": 76.0,"financialIndependence": 2727.25,"solvability": 26.54,"capacityDebtFutures": 2728.4,"coverageOfCurrentAssets": 25.33,"generalLiquidity": 0.0,"restrictedLiquidity": 0.58},"managementOrRotation": {"needBackgroundInOperatingWorkingCapital": -80.0,"treasury": 128.0,"averageLengthOfCreditGrantedCoCustomers": 138.0,"averageLengthOfCreditObtainedSuppliers": 284.0},"profitabilityOfTheBusiness": {"marginTrading": 0.0,"profitabilityOfTheBusiness": 19.62,"netprofit": 15.55,"growthRateOfTurnover": 258.97,"ratesIntegration": 36.73,"rateLeasingFurniture": 0.0,"workFactor": 46.25,"weightInterests": 0.02},"returnOnCapital": {"cashFlowFromTheOverallProfitability": 15.63,"ratesOfEconomicProfitability": 84.0,"financialProfitability": 69.4,"returnOnInvestment": 0.02}},"sig": {"turnover": 288534.0,"saleOfGoods": 0.0,"purchaseOfGoods": 0.0,"stockOfGoodsVariation": 0.0,"tradingMarginOfSalesOfGoods": 0.0,"saleOfGoodsProduce": 288534.0,"valueOfStockedProduction": 0.0,"valueOfSelfConstructedAssets": 0.0,"periodProductionOfSaleOfGoodsProduce": 288534.0,"tradingMargin": 0.0,"periodProductionOfTradingMargin": 288534.0,"purchaseOfawMaterials": 0.0,"differenceInStocksOfRawMaterials": -527.0,"variousExternalPurchasesAndCharges": 183084.0,"addedValueOfTradingMargin": 105977.0,"addedValue": 105977.0,"opertingGrants": 0.0,"taxAndDutyAndSimilarPayments": 349.0,"personalCharges": 49010.0,"grossOperatingSurplusOfAddedValue": 56618.0,"grossOperatingSurplus": 56618.0,"grossOperatingSurplusDifference": 19.62,"changeInReleaseOfReservesAndProvisions": 0.0,"otherOperatingIncome": 1.0,"depreciationOrAmmortisation": 230.0,"changesInOtherCharges": 5.0,"operatingResultOfGrossOperatingSurplus": 56384.0,"resultOfJointVentureTransferredFromOrToOtherPartners": 0.0,"financialIncomeOfOperatingResult": 0.0,"financialChargesOfOperatingResult": 61.0,"preTaxResultOfOperatingResult": 56323.0,"extraodinaryIncome": 690.0,"extaordinaryCharges": 180.0,"extraordinaryResultOfExtraordinaryIncome": 510.0,"preTaxResult": 56323.0,"exceptionalIncomeResult": 510.0,"employeeProfitSharing": 0.0,"taxOnProfit": 11955.0,"netResultOfPreTaxResult": 44878.0}},{"type": "LocalFinancialsFullCSFR","yearEndDate": "2013-12-31T00:00:00Z","currency": "EUR","month": 12,"assets": {"grandTotalAssets": {"grandTotalNet": 62463.0,"grandTotalGross": 62463.0,"grandTotalAmortisation": 0.0},"capitalSubscribedNotCalled": {"capitalSubscribed": 0.0},"activeFixedAsset": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"activeIntangibleFixedAssets": {"startupCost": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"researchAndDevelopmentExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"distributorshipsPatents": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodwill": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherIntangibleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"prepaymentsAndDownpayments": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalIntangibleAsset": 0.0},"tangilbleFixedAssets": {"land": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"buildings": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"plant": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherTangibleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"fixedAssetsInConstruction": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"advancesAndPaymentsOnAccount": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalTangibleAsset": 0.0},"financialAssets": {"associatesAtEquity": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherParticipations": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"intercompanyReceivables": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherInvestmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"loans": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherFinancialAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalFinancialAssets": 0.0},"activeAssets": {"total": 62463.0,"gross": 62463.0,"amortisation": 0.0},"activeStocks": {"rawMaterials": {"total": 144.0,"gross": 144.0,"amortisation": 0.0},"workInProgressGoods": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"workInProgressServices": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"semiFinishedAndFinishedProducts": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodsForResale": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalStocks": 144.0},"advancePaymentsToSupplier": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"activeDebtors": {"tradeAccountsReceivable": {"total": 55122.0,"gross": 55122.0,"amortisation": 0.0},"otherDebtors": {"total": 401.0,"gross": 401.0,"amortisation": 0.0},"capitalSubscribedAndCalledUp": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalDebtors": 55523.0},"activeDivers": {"investmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"cashAndCashEquivalents": {"total": 6796.0,"gross": 6796.0,"amortisation": 0.0},"subTotalDivers": 6796.0},"accountPrepaidExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"equalizationAccounts": {"multiPeriodCharges": 0.0,"premiumsOnRedemptionOfBonds": 0.0,"currencyDifferentialGain": 0.0},"assetsReferences": {"dueWithinOneYear": 0.0,"dueAfterOneYear": 0.0}},"liabilities": {"grandTotal": 62463.0,"shareholderEquity": {"totalShareholdersEquity": 16015.0,"equityAndShareholdersEquity": 10000.0,"issueAndMergerPremiums": 0.0,"revaluationDifferentials": 0.0,"ofWhichEquityDiffeential": 0.0,"legalReserve": 1000.0,"statutoryOrContractualReserve": 0.0,"specialRegulatedReserves": 0.0,"ofWhichSpecialReserveOfProvisions": 0.0,"otherReservesOfLiabilities": 2081.0,"ofWhichReserveForBuyingOriginalsWorks": 0.0,"profitsOrLossesBroughtForward": 0.0,"profitOrLossForThePeriod": 2934.0,"investmentGrants": 0.0,"specialTaxAllowableReserves": 0.0},"otherCapitalResource": {"totalOtherCapitalResources": 0.0,"incomeFromParticipatingSecurities": 0.0,"conditionalLoans": 0.0},"provisionsForRisksAndCharge": {"totalProvisionsForRisksAndCharges": 0.0,"riskProvisions": 0.0,"reservesForCharges": 0.0},"liabilities": {"totalLiabilities": 46448.0,"convertibleDebentures": 0.0,"otherDebentures": 0.0,"bankLoansAndLiabilities": 3254.0,"sundryLoansAndFinancialLiabilities": 0.0,"ofWhichParticipatingLoans": 0.0,"advancePaymentsReceivedForCurrentOrders": 0.0,"tradeAccountsPayables": 4816.0,"taxAndSocialSecurityLiabilities": 22576.0,"fixedAssetLiabilities": 0.0,"otherDebts": 15802.0},"passiveAccountReferences": {"ofWhichTaxAllowableReserve": 1000.0,"deferredIncomeAndLiabilities": 46448.0,"ofWhichCurrentBankFacilities": 3254.0},"extraInformation": {"passiveTranslationLoss": 0.0,"deferredIncome": 0.0}},"profitAndLoss": {"operatingResult": 3516.0,"financialResult": -115.0,"resultsOfPreTaxNetOperatingIncome": 3401.0,"extraordinaryResult": -48.0,"profitOrLoss": 2934.0,"totalIncome": 80628.0,"totalCharges": 77694.0,"employeeProfitSharing": 0.0,"taxOnProfits": 419.0,"operatingIncome": {"totalOperatingIncome": 80378.0,"goodsForResaleTotal": 0.0,"goodsForResaleFrance": 0.0,"goodsForResaleExport": 0.0,"goodsProducedTotal": 0.0,"goodsProducedFrance": 0.0,"goodsProducedExport": 0.0,"saleOfServicesTotal": 80378.0,"saleOfServicesFrance": 80378.0,"saleOfServicesExport": 0.0,"netTurnoverTotal": 80378.0,"netTurnoverFrance": 80378.0,"netTurnoverExport": 0.0,"stockedProduction": 0.0,"selfConstructedAssets": 0.0,"operatingGrants": 0.0,"releaseOfReservesAndProvisions": 0.0,"otherIncome": 0.0},"totalOperatingCharge": {"totalOperatingCharges": 76862.0,"purchaseOfGoodsForResale": 0.0,"changeInStocksOfGoodsForResale": 0.0,"purchaseOfRawMaterials": 44.0,"changeInStocksOfRawMaterials": 21528.0,"otherExternalPurchasesAndCharges": 516.0,"taxDutyAndSimilarPayments": 49198.0,"payroll": 5576.0,"socialSecurityCosts": 0.0},"depreciation": {"depreciationOfFixedAssets": 0.0,"amortisationOfFixedAssets": 0.0,"depreciationAmortisationOfCurrentAssets": 0.0,"provisionsForRisksAndChargesOfResults": 0.0},"otherCharge": {"otherCharges": 0.0,"shareOfJointVentureTransferredToOtherPartner": 0.0,"shareOfJointVentureTransferredFromOtherPartner": 0.0},"resultsFinancialIncome": {"totalFinancialIncome": 0.0,"shareFinancialIncome": 0.0,"otherInvestmentIncomeAndCapitalisedReceivables": 0.0,"otherInterestAndSimilarIncome": 0.0,"releasedProvisions": 0.0,"exchangeGains": 0.0,"netIncomeFromDisposalOfInvestmentSecurities": 0.0},"financialCharge": {"totalFinancialChargeTotal": 115.0,"financialReservesAndProvisions": 0.0,"interestAndSimilarCharges": 115.0,"exchangeLosses": 0.0,"netLossFromDisposalOfInvestmentSecurities": 0.0},"additionalFinancialCharge": {"totalExtraordinaryIncome": 250.0,"extraordinaryOperatingIncome": 250.0,"extraordinaryIncomeFromCapitalTransactions": 0.0,"releasedProvisionsCharges": 0.0},"extraordinaryCharge": {"totalExtraordinaryCharges": 298.0,"extraordinaryOperatingCharges": 298.0,"extraordinaryChargesFromCapitalTransactions": 0.0,"extraordinaryReservesAndProvisions": 0.0},"references": {"ofWhichEquipmentLeases": 0.0,"ofWhichPropertyLeases": 0.0,"ofWhichTransferredCharges": 0.0,"ofWhichTradersOwnContributions": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsIncome": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsCharges": 0.0}},"otherIncomes": {"grossGrandTotalFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossResearchAndDevelopmentChargeFixed": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherBudgetItemFromIntangibleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherTangilbleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherFinancialAsset": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"situationAndMovementOfReserveForDepreciationGrandTotal": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"researchAndDevelopmentChargeReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"otherIntangibleAssetsReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalFixedAssedAmotisationReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"netMovementsDuringPeriodAffectingChargeAllocatedOverSeveralPeriod": {"valueAtEndOfPeriod": 0.0},"netPremiumRefundOfObligations": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"grandTotals": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"includesTotalAllocations": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"includesTotalWithdrawal": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"totalRegulatedProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalRiskAndChargeProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalProvisionForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"stateClaims": {"stateClaimsGrossValue": 55523.0,"stateClaimsWhenOneYearAtMost": 55523.0,"stateClaimsWhenmoreThanOneYear": 0.0},"stateOfLoans": {"claimsRelatedToHoldingsGross": 0.0,"claimsRelatedToShareholdingsOneYearAtMost": 0.0,"grossOfLoans": 0.0,"loansOneYearAtMost": 0.0,"otherFinancialAssetsGross": 0.0,"otherFinancialAssetsOneYearAtMost": 0.0},"receivablesStatementOfAssets": {"customersDoubtfulOrDisputed": 0.0,"otherClaimsCustomer": 0.0,"receivablesRepresentLoanedSecurities": 0.0,"provisionForDepreciationPreviouslyEstablished": 0.0,"personnelAndAssociatedAccounts": 0.0,"socialSecurityAndOtherSocialOrganizations": 0.0,"incomeTaxes": 0.0,"valueAddedTax": 0.0,"otherTaxesAndPaymentsAssimilatedOfReceivables": 0.0,"stateAndOtherPublicMiscellaneous": 0.0,"groupAndAssociates": 0.0,"accountsReceivableIncOtherClaims": 0.0},"stateDebt": {"totalDebtGross": 46448.0,"debtOneYearAtMost": 46448.0,"debtMoreThanOneYearAndFiveYearsAtMost": 0.0,"debtMoreThanFiveYears": 0.0},"details": {"convertibleBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToOneYearMaximumAtTheOrigin": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToMoreThanOneYearAtTheOrigin": {"gross": 3254.0,"oneYearAtMost": 3254.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"financialLiabilities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"suppliersAssociatedAccounts": {"gross": 4816.0,"oneYearAtMost": 4816.0,"moreThanOneYearAndFiveYearsAtMost": 4816.0},"personnelAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherSocialOrganizations": {"gross": 22576.0,"oneYearAtMost": 22576.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"taxesOnProfits": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"vat": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"backedObligations": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherTaxesAssimilated": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"assetsAndLiabilitiesAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"groupsAndAssociates": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"otherLiabilities": {"gross": 15802.0,"oneYearAtMost": 15802.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"debtOfBorrowedSecurities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"productsInAdvance": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0}},"referencesOthers": {"loansMadeDuringThePeriod": 0.0,"debtRepaidDuringThePeriod": 0.0},"commitments": {"commitmentsLeasingFurniture": 0.0,"commitmentsRealEstateLeasing": 0.0,"effectsBroughtToTheDiscountAndUnmatured": 0.0},"otherChargesExternal": {"subContracting": 0.0,"rentalsRentalChargesAndCondominiums": 0.0,"staffOutsideTheCompany": 0.0,"remunerationIntermediariesAndFeesExcludingFees": 0.0,"feesCommissionsAndBrokerage": 0.0,"otherAccounts": 0.0,"totalOtherPurchasesAndExternal": 0.0},"taxesAndFees": {"businessTax": 0.0,"otherTaxesAndPaymentsAssimilated": 0.0,"totalTaxesAndFees": 0.0},"vat": {"amountVatCollected": 0.0,"totalVatOnGoodsAndServices": 0.0},"extraInformation": {"averageNumberOfEmployees": 0.0,"dividends": 0.0,"prepaid": 55523.0}},"ratios": {"structureAndLiquidity": {"globalDebt": 208.0,"workingCapitalFundOverallNet": 72.0,"financialIndependence": 492.16,"solvability": 25.64,"capacityDebtFutures": 492.16,"coverageOfCurrentAssets": 25.64,"generalLiquidity": 1.2,"restrictedLiquidity": 1.34},"managementOrRotation": {"needBackgroundInOperatingWorkingCapital": 125.0,"treasury": 16.0,"averageLengthOfCreditGrantedCoCustomers": 247.0,"averageLengthOfCreditObtainedSuppliers": 78.0,"inventoryTurnoverOfRawMaterials": 1178.0},"profitabilityOfTheBusiness": {"marginTrading": 0.0,"profitabilityOfTheBusiness": 4.37,"netprofit": 3.65,"ratesIntegration": 72.52,"rateLeasingFurniture": 0.0,"workFactor": 9.57,"weightInterests": 0.14},"returnOnCapital": {"cashFlowFromTheOverallProfitability": 3.65,"ratesOfEconomicProfitability": 18.0,"financialProfitability": 18.32,"returnOnInvestment": 0.14}},"sig": {"turnover": 80378.0,"saleOfGoods": 0.0,"purchaseOfGoods": 0.0,"stockOfGoodsVariation": 0.0,"tradingMarginOfSalesOfGoods": 0.0,"saleOfGoodsProduce": 80378.0,"valueOfStockedProduction": 0.0,"valueOfSelfConstructedAssets": 0.0,"periodProductionOfSaleOfGoodsProduce": 80378.0,"tradingMargin": 0.0,"periodProductionOfTradingMargin": 80378.0,"purchaseOfawMaterials": 44.0,"differenceInStocksOfRawMaterials": 21528.0,"variousExternalPurchasesAndCharges": 516.0,"addedValueOfTradingMargin": 58290.0,"addedValue": 58290.0,"opertingGrants": 0.0,"taxAndDutyAndSimilarPayments": 49198.0,"personalCharges": 5576.0,"grossOperatingSurplusOfAddedValue": 3516.0,"grossOperatingSurplus": 3516.0,"grossOperatingSurplusDifference": 4.37,"changeInReleaseOfReservesAndProvisions": 0.0,"otherOperatingIncome": 0.0,"depreciationOrAmmortisation": 0.0,"changesInOtherCharges": 0.0,"operatingResultOfGrossOperatingSurplus": 3516.0,"resultOfJointVentureTransferredFromOrToOtherPartners": 0.0,"financialIncomeOfOperatingResult": 0.0,"financialChargesOfOperatingResult": 115.0,"preTaxResultOfOperatingResult": 3401.0,"extraodinaryIncome": 250.0,"extaordinaryCharges": 298.0,"extraordinaryResultOfExtraordinaryIncome": -48.0,"preTaxResult": 3401.0,"exceptionalIncomeResult": -48.0,"employeeProfitSharing": 0.0,"taxOnProfit": 419.0,"netResultOfPreTaxResult": 2934.0}},{"type": "LocalFinancialsSimpleCSFR","yearEndDate": "2014-12-31T00:00:00Z","currency": "EUR","month": 12,"assets": {"grandTotalAssets": {"total": 138966.0,"gross": 138966.0,"amortisation": 0.0},"activeFixedAsset": {"totalActiveFixedAsset": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"intangibleAssetGoodwill": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherIntangibleAsset": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"tangilbleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"financialAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0}},"assets": {"assets": {"total": 138966.0,"gross": 138966.0,"amortisation": 0.0},"rawMaterialsStockSupplyInProduction": {"total": 129.0,"gross": 129.0,"amortisation": 0.0},"goodsForResale": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"advancePaymentsToSuppliers": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"tradeAccountsReceivableDebtor": {"total": 102904.0,"gross": 102904.0,"amortisation": 0.0},"otherDebtors": {"total": 23494.0,"gross": 23494.0,"amortisation": 0.0},"investmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"cashAndCashEquivalents": {"total": 12438.0,"gross": 12438.0,"amortisation": 0.0,"cash": 0.0},"prepaidExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0}}},"liabilities": {"passiveGrandTotal": 138966.0,"provisionsForRisksAndCharges": 0.0,"shareholderEquity": {"totalShareholderEquity": 19786.0,"equityAndShareholdersEquity": 10000.0,"revaluationDifferentials": 0.0,"legalReserve": 1000.0,"specialRegulatedReserves": 0.0,"otherReserves": 5015.0,"profitsOrLossesBroughtForward": 0.0,"profitOrLossForThePeriod": 3771.0,"specialTaxAllowableReserves": 0.0},"liabilities": {"totalLiabilities": 119180.0,"loansAndDebtsAssimilated": 948.0,"advancePaymentsReceivedForCurrentOrders": 0.0,"tradeAccountsPayables": 75088.0,"otherDebts": 43145.0,"otherCreditorsWhoseAccountsOfAssociatesOfTheExerciseN": 0.0,"deferredIncome": 0.0},"references": {"includingFinancialAssetsWithinOneYear": 0.0,"includingDebtsAfterOneYear": 0.0,"includingCurrentAccountsReceivableAssociated": 0.0,"includingDebtsCurrentOneYear": 0.0,"costOfReturnOfCapitalAssetsAcquiredOrCreatedDuringTheYear": 0.0,"sellingPriceExcludingVatCapitalSurrenderedDuringTheYear": 0.0}},"profitAndLoss": {"operatingResults": {"operatingResult": 4422.0,"profitOrLoss": 3771.0},"operatingIncome": {"totalOperatingIncomeWithoutVat": 146489.0,"saleOfGoodsForResale": 0.0,"resaleGoodsExport": 0.0,"saleOfGoodsProduced": 0.0,"producedGoodsExport": 0.0,"saleOfServices": 146475.0,"servicesSoldExport": 0.0,"stockedProduction": 0.0,"selfConstructedAssets": 0.0,"operatingGrants": 0.0,"otherIncome": 14.0},"operatingCharges": {"totalOperatingChargesTotal": 142067.0,"purchaseOfGoodsForResaleIncludingCustomsDuties": 0.0,"changeInStocksOfGoodsForResale": 0.0,"purchaseOfRawMaterialsIncludingCustomsDuties": 0.0,"changeInStocksOfRawMaterials": 15.0,"otherExternalPurchasesAndCharges": 99218.0,"includesLeaseFurniture": 0.0,"includesLeaseRealEstate": 0.0,"taxDutyAndSimilarPayments": 345.0,"includingBusinessTax": 345.0,"payroll": 42477.0,"socialSecurityCosts": 0.0,"depreciation": 0.0,"provisions": 0.0,"otherCharges": 12.0,"includingProvisionsForTaxSettlementsAbroad": 0.0},"productsAndVariousCharges": {"financialProductsTotal": 0.0,"extraordinaryIncomeTotal": 260.0,"financialChargesTotal": 57.0,"extraordinaryChargesTotal": 190.0,"incomeTaxesTotal": 665.0,"compensationAndBenefitsNonDeductiblePersonal": 0.0,"amountVatCollected": 22805.0,"deductibleVatOnGoodsAndServices": 5729.0,"averageNumberOfEmployees": 0.0}},"otherIncomes": {"otherIncomeTaxReturnForms": {"grossAssetValueAtBeginningOfYear": 0.0,"increasess": 0.0,"decreasess": 0.0},"intangibleFixedAssets": {"goddwillIncreases": 0.0,"goddwillDecreases": 0.0,"othersIncreases": 0.0,"othersDecreases": 0.0},"tangilbleFixedAssetsIncreases": {"land": 0.0,"buildings": 0.0,"plantMachineryAndEquipmentIndustry": 0.0,"generalInstallationsVariousFixtures": 0.0,"transportationEquipment": 0.0,"otherFixedAssets": 0.0},"financialAsset": {"assetsIncreases": 0.0,"assetsDecreases": 0.0},"capitalGainsLosses": {"totalResidualValue": 0.0,"totalTransferPricing": 0.0,"totalPlusOrLossesInTheShortTerm": 0.0,"totalPlusOrLossesInTheLongTerm": 0.0},"summaryOfProvisionsDepreciationDerogatory": {"totalProvisionsIncreases": 0.0,"increasedProvisionsRegulatedDepreciation": 0.0,"increasedProvisionsRegulated": 0.0,"otherIncreasedProvisionsRegulated": 0.0,"increasedProvisionsForRisksAndCharges": 0.0,"increasedProvisionsForLossesOnCapital": 0.0,"increasedProvisionsForLossesAndCurrentStocks": 0.0,"increasedProvisionsForLossesClientsAndExtras": 0.0,"otherIncreasedProvisionsForLosses": 0.0,"totalProvisionsDecreases": 0.0,"decreasedProvisionsRegulatedDepreciation": 0.0,"decreasedProvisionsRegulated": 0.0,"otherDecreasedProvisionsRegulated": 0.0,"decreasedProvisionsForRisksAndCharges": 0.0,"decreasedProvisionsForLossesOnCapital": 0.0,"decreasedProvisionsForLossesAndCurrentStocks": 0.0,"decreasedProvisionsForLossesClientsAndExtras": 0.0,"otherDecreasedProvisionsForLosses": 0.0}}}],"paymentData": {"industryDbt": "4","paymentTrend": "TrendNotAvailable","averageMonthlyBalance": "0","balanceP1": "0","balanceP2": "0","balanceP3": "0","balanceP4": "0","balanceWithinTerms": "0","invoicesBetween3And12Monts": {"paidP1": "0","paidP2": "0","paidP3": "0","paidP4": "0","paidInTerms": "0","totalPaid": "0"},"invoicesLast3Monts": {"paidP1": "0","paidP2": "0","paidP3": "0","paidP4": "0","paidInTerms": "0","totalPaid": "0"},"recentHighBalance": "0","totalTradeLines": "0","totalTradeLinesOutstanding": "0"},"additionalInformation": {"misc": {"sizeOfUrbanArea": "Establishment in a rural municipality","reasonForFormation": "Formation","financialAccountsType": "F","statusCode": "A","officeType": "1","numberOfBranches": "1","numberOfEmployeesAtAddress": "1 or 2 employees","numberOfEmployeesAtCompany": "1 or 2 employees","activityClassification": "NAF/APE","inseeCode": "34197","streetAddress": "10 RUE DE LA CLAIRETTE","postalCode": "34800","postalDistributionCode": "34800","municipality": "PERET","subRegion": "Hérault","courtRegistryNumber": "537643967","registrationCourt": "Beziers (34)","nationality": "France","numberOfDirectors": 1,"rcsRegistration": "RCS Beziers 1  537643967"},"establishmentDetails": {"typeOfEstablishmentDescription": "Head office","formationDate": "2011-10-01T00:00:00Z","activityLocation": "Other","department": "Hérault 34","district": "1","area": "14"},"otherEstablishmentDetails": {"regionality": "Legal unit with all establishments in same area","monoActivityStatus": "Legal unit having all establishments with the same main activity"},"companyHistory": [{"date": "2020-06-02T00:00:00Z","description": "Update Rating"},{"date": "2019-11-29T00:00:00Z","description": "Consideration of a confidential balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2019-11-13T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2019-10-06T00:00:00Z","description": "Update Rating"},{"date": "2018-10-11T00:00:00Z","description": "Update Rating"},{"date": "2018-10-11T00:00:00Z","description": "Consideration of a confidential balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2018-09-25T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2018-03-18T00:00:00Z","description": "Update Limit"},{"date": "2018-03-18T00:00:00Z","description": "Update Rating"},{"date": "2017-10-25T00:00:00Z","description": "Invalid balance sheet"},{"date": "2017-08-07T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2016-04-29T00:00:00Z","description": "Update Limit"},{"date": "2016-04-29T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2016-04-27T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2016-04-08T00:00:00Z","description": "Bodacc B: Various editing or changing"},{"date": "2016-03-29T00:00:00Z","description": "Updated articles of association"},{"date": "2016-03-29T00:00:00Z","description": "Amendment"},{"date": "2016-03-29T00:00:00Z","description": "Appointment/resignation of company officers"},{"date": "2016-03-01T00:00:00Z","description": "Legal Gazette: Resignation / Revocation of the social representative"},{"date": "2016-02-19T00:00:00Z","description": "Update of Company Legal Form"},{"date": "2015-12-31T00:00:00Z","description": "New accounts available"},{"date": "2015-05-08T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2015-05-05T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2014-12-31T00:00:00Z","description": "New accounts available"},{"date": "2014-05-07T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2014-04-30T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2013-12-31T00:00:00Z","description": "New accounts available"},{"date": "2013-10-19T00:00:00Z","description": "Update Limit"},{"date": "2013-10-19T00:00:00Z","description": "Update Rating"},{"date": "2013-06-27T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2013-06-06T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2012-12-31T00:00:00Z","description": "New accounts available"},{"date": "2011-11-16T00:00:00Z","description": "Bodacc A : Establishment creation"},{"date": "2011-11-04T00:00:00Z","description": "Appointment/resignation of company officers"},{"date": "2011-11-04T00:00:00Z","description": "Fund deposit certificate"},{"date": "2011-11-04T00:00:00Z","description": "Company formation"},{"date": "2011-11-04T00:00:00Z","description": "Private document"},{"date": "2011-10-21T00:00:00Z","description": "Modification of Company Activity"},{"date": "2011-10-21T00:00:00Z","description": "Update of Company Activity"},{"date": "2011-10-21T00:00:00Z","description": "Formation of Company"}],"establishmentHistory": [{"date": "2017-06-07T00:00:00Z","description": "Update of phone numbers"},{"date": "2017-04-22T00:00:00Z","description": "Update Rating"},{"date": "2016-04-29T00:00:00Z","description": "Update Limit"},{"date": "2016-04-29T00:00:00Z","description": "Update Rating"},{"date": "2016-03-31T00:00:00Z","description": "Update Rating"},{"date": "2016-02-19T00:00:00Z","description": "Modification of Head office"},{"date": "2016-01-21T00:00:00Z","description": "Update Rating"},{"date": "2015-07-08T00:00:00Z","description": "Update of phone numbers"},{"date": "2015-05-08T00:00:00Z","description": "Update Rating"},{"date": "2015-05-08T00:00:00Z","description": "Update Limit"},{"date": "2014-07-20T00:00:00Z","description": "Update Rating"},{"date": "2014-04-30T00:00:00Z","description": "Update Limit"},{"date": "2014-04-30T00:00:00Z","description": "Update Rating"},{"date": "2014-04-17T00:00:00Z","description": "Update Rating"},{"date": "2013-08-24T00:00:00Z","description": "Update Rating"},{"date": "2013-06-06T00:00:00Z","description": "Update Rating"},{"date": "2013-06-06T00:00:00Z","description": "Update Limit"},{"date": "2012-10-24T00:00:00Z","description": "Update Limit"},{"date": "2012-10-24T00:00:00Z","description": "Update Rating"},{"date": "2011-10-21T00:00:00Z","description": "Modification of Head office Activity"},{"date": "2011-10-21T00:00:00Z","description": "Formation of Head office"},{"date": "2011-10-21T00:00:00Z","description": "Update of Establishment Activity"}],"gazettes": [{"publicationDate": "2019-11-13T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "2447 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2018."},{"publicationDate": "2018-09-25T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "2835 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2017."},{"publicationDate": "2017-08-07T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "1201 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2016."},{"publicationDate": "2016-04-27T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "3030 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2015."},{"publicationDate": "2016-04-08T00:00:00Z","type": "Bodacc B : Modification et mutation diverse","name": "B","description": "Modification et mutation diverse","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "659 - 537 643 967 RCS Béziers. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Administration : Gérant : RUBINOCCI René. Activité :  . Commentaires : Modification survenue sur l\'administration."},{"publicationDate": "2015-05-05T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "3198 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2014."},{"publicationDate": "2014-05-07T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "2961 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2013."},{"publicationDate": "2013-06-27T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "5223 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2012."},{"publicationDate": "2011-11-16T00:00:00Z","type": "Bodacc A : Création d\'établissement","name": "A_REG","description": "Création d\'établissement","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "238 - 537 643 967 RCS Béziers. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Administration : Co-Gérant : RUBINOCCI René Co-Gérant : LOPEZ Séverine né(e) VAN DAMME. Capital : 10000 EUR. Adresse : 10 rue de la Clairette, 34800 Péret. Origine du fonds : Création. Etablissement : Etablissement principal. Activité : Organisation et réalisation de recrutement de groupes de consommateurs pour les sociétés de marketing ainsi que l\'organisation et la réalisation de recrutement de groupes de consommateurs par tous moyens. Adresse : 10 rue de la Clairette, 34800 Péret. A dater du : 04/11/2011. Date de commencement de l’activité : 21/10/2011. Descriptif  : . Commentaires : Immatriculation d\'une personne morale (B, C, D) suite à création d\'un établissement principal."}],"jals": [{"eventDate": "2016-02-19T00:00:00Z","type": "Démission / Révocation du mandataire social","parutionDate": "2016-03-01T00:00:00Z","source": "JOURNAUX","detail": "<center><b>La Gazette économique </b></center><br /><i>Date de décision : </i>19/02/2016<br /><i>La société </i>537643967 - TESTS OPTIMUM, 10 RUE DE LA CLAIRETTE, 34800 PERET <br/><i>Fait l\'objet du départ de </i> Madame Séverine LOPEZ<br/>"}],"commentaries": [{"commentaryText": "Low risk workforce size","positiveOrNegative": "Positive"},{"commentaryText": "Industry code with low risk rating","positiveOrNegative": "Positive"},{"commentaryText": "The company is 8 years old","positiveOrNegative": "Positive"},{"commentaryText": "Region code with medium risk rating","positiveOrNegative": "Neutral"}],"ratingHistory": [{"date": "2020-03-01T00:00:00Z","localRating": "79","commonRating": {"commonValue": "A","commonDescription": "Very Low Risk"},"description2": "Very Good Credit Worthiness"},{"date": "2019-06-28T00:00:00Z","localRating": "78","commonRating": {"commonValue": "A","commonDescription": "Very Low Risk"},"description2": "Very Good Credit Worthiness"},{"date": "2018-09-21T00:00:00Z","localRating": "76","commonRating": {"commonValue": "A","commonDescription": "Very Low Risk"},"description2": "Very Good Credit Worthiness"},{"date": "2017-10-25T00:00:00Z","localRating": "65","commonRating": {"commonValue": "B","commonDescription": "Low Risk"},"description2": "Good Credit Worthiness"},{"date": "2013-07-03T00:00:00Z","localRating": "48","commonRating": {"commonValue": "C","commonDescription": "Moderate Risk"},"description2": "Credit Worthy"}],"branches": [{"companyNumber": "53764396700012","companyName": "TESTS OPTIMUM","lineOfBusiness": "Études de marché et sondages","status": "A","name": "TESTS OPTIMUM","address": {"simpleValue": "10 RUE DE LA CLAIRETTE PERET 34800","street": "10 RUE DE LA CLAIRETTE","city": "PERET","postalCode": "34800"},"distribution": "34800 PERET"}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/FR-X-537643967', creditsafeReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            creditFactory.requestStartReportsCheck('FR-X-537643967');
            reportsItem = creditFactory.requestCompanyReports('FR-X-537643967');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('TESTS OPTIMUM', reportsItem.companiesList.get(0).name);
        System.assertEquals('1', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('80', reportsItem.companiesList.get(0).solvencyIndex);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportFieldsToUpdate();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('TESTS OPTIMUM', reportsList.get(0).Name);
        System.assertEquals(1, reportEmployeesList.size());
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Opportunity'));
        System.assertEquals('1', ((Map<String, Object>) fieldsToUpdateMap.get('Opportunity')).get('Credit_System_Rating__c'));
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Account'));
        System.assertEquals('7320', ((Map<String, Object>) fieldsToUpdateMap.get('Account')).get('Branchencode__c'));
    }


    /*******************************************************************************
    *  Summary         : test response from Creditsafe with API error
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditsafeApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
                creditFactory.requestCompanyReports('1234554321');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Creditsafe API error. Please contact your administrator. Bad request. Company Id: 1234554321', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
            SingleRequestMock creditsafeReportMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "6ff523c0-1e9c-11eb-9e62-026acd9cdfbf","orderId": "N/A","companyId": "FR-X-53764396700012","dateOfOrder": "2020-11-04T12:51:26.611Z","language": "en","userId": "101495027","report": {"companyId": "FR-X-53764396700012","language": "EN","companySummary": {"businessName": "TESTS OPTIMUM","country": "FR","companyNumber": "FR14237460","companyRegistrationNumber": "53764396700012","mainActivity": {"code": "7320Z","description": "Études de marché et sondages","classification": "NAF/APE"},"companyStatus": {"status": "Active","description": "Economically active"},"latestTurnoverFigure": {"currency": "EUR","value": 288534.0},"latestShareholdersEquityFigure": {"currency": "EUR","value": 64663.0},"creditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "10000"},"providerValue": {"maxValue": "100","minValue": "0","value": "80"},"providerDescription": "Very Good Credit Worthiness"}},"companyIdentification": {"basicInformation": {"businessName": "-","registeredCompanyName": "TESTS OPTIMUM","companyRegistrationNumber": "53764396700012","country": "FR","vatRegistrationNumber": "FR05537643967","companyRegistrationDate": "2011-11-01T00:00:00Z","operationsStartDate": "2011-10-01T00:00:00Z","commercialCourt": "RCS Beziers 1","legalForm": {"providerCode": "5499","description": "Limited Liability Company"},"companyStatus": {"status": "Active","description": "Economically active"},"principalActivity": {"code": "7320Z","description": "Études de marché et sondages","classification": "NAF/APE"},"contactAddress": {"simpleValue": "10 RUE DE LA CLAIRETTE 34800 PERET","street": "10 RUE DE LA CLAIRETTE","houseNumber": "10","city": "PERET","postalCode": "34800","telephone": "0467447010","country": "FR"}},"activityClassifications": [{"classification": "NAF/APE","activities": [{"code": "7320Z","description": "Études de marché et sondages"}]}]},"creditScore": {"currentCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "10000"},"providerValue": {"maxValue": "100","minValue": "0","value": "80"},"providerDescription": "Very Good Credit Worthiness"},"previousCreditRating": {"commonValue": "A","commonDescription": "Very Low Risk","creditLimit": {"currency": "EUR","value": "7500"},"providerValue": {"maxValue": "100","minValue": "0","value": "79"},"providerDescription": "Very Good Credit Worthiness"},"latestRatingChangeDate": "2020-09-19T00:00:00Z"},"contactInformation": {"mainAddress": {"simpleValue": "10 RUE DE LA CLAIRETTE 34800 PERET","street": "RUE DE LA CLAIRETTE","houseNumber": "10","city": "PERET","postalCode": "34800","telephone": "04 67 44 70 10","country": "FR"}},"shareCapitalStructure": {"nominalShareCapital": {"value": 10000.0}},"directors": {"currentDirectors": [{"name": "M RUBINOCCI RENÉ","gender": "Male","dateOfBirth": "1961-08-22T00:00:00Z","placeOfBirth": "NANTERRE","directorType": "Other","positions": [{"positionName": "Manager"}]}],"previousDirectors": [{"name": "M RENÉ RUBINOCCI","gender": "Male","dateOfBirth": "1961-08-22T00:00:00Z","placeOfBirth": "NANTERRE à 22/08/1961","directorType": "Other","positions": [{"positionName": "Manager"}]},{"name": "M RENÉ RUBINOCCI","gender": "Male","dateOfBirth": "1961-08-22T00:00:00Z","placeOfBirth": "NANTERRE (92) à 22/08/1961","directorType": "Other","positions": [{"positionName": "Manager"}]}]},"otherInformation": {"employeesInformation": [{"year": 2015,"numberOfEmployees": "0"}]},"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2015-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 288535.0,"operatingCosts": 232152.0,"operatingProfit": 56383.0,"wagesAndSalaries": 49010.0,"depreciation": 230.0,"financialExpenses": 61.0,"extraordinaryIncome": 690.0,"profitBeforeTax": 56832.0,"tax": 11955.0,"profitAfterTax": 44877.0,"retainedProfit": 44877.0},"balanceSheet": {"otherTangibleAssets": 4027.0,"totalTangibleAssets": 4027.0,"totalFixedAssets": 4027.0,"rawMaterials": 656.0,"totalInventories": 656.0,"tradeReceivables": 110666.0,"miscellaneousReceivables": 23436.0,"totalReceivables": 134102.0,"cash": 104666.0,"otherCurrentAssets": 182.0,"totalCurrentAssets": 239606.0,"totalAssets": 243633.0,"tradePayables": 143786.0,"bankLiabilities": 2371.0,"miscellaneousLiabilities": 32813.0,"totalCurrentLiabilities": 178970.0,"totalLiabilities": 178970.0,"calledUpShareCapital": 10000.0,"revenueReserves": 44877.0,"otherReserves": 9786.0,"totalShareholdersEquity": 64663.0},"otherFinancials": {"workingCapital": 60636.0,"netWorth": 64663.0},"ratios": {"preTaxProfitMargin": 19.70,"returnOnCapitalEmployed": 87.89,"returnOnTotalAssetsEmployed": 23.33,"returnOnNetAssetsEmployed": 87.89,"salesOrNetWorkingCapital": 4.76,"stockTurnoverRatio": 0.23,"debtorDays": 139.99,"creditorDays": 181.89,"currentRatio": 1.34,"liquidityRatioOrAcidTest": 1.34,"currentDebtRatio": 2.77,"gearing": 3.67,"equityInPercentage": 26.54,"totalDebtRatio": 2.77}},{"type": "GlobalFinancialsGGS","yearEndDate": "2014-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 146489.0,"operatingCosts": 142067.0,"operatingProfit": 4422.0,"wagesAndSalaries": 42477.0,"financialExpenses": 57.0,"extraordinaryIncome": 260.0,"extraordinaryCosts": 190.0,"profitBeforeTax": 4436.0,"tax": 665.0,"profitAfterTax": 3771.0,"retainedProfit": 3771.0},"balanceSheet": {"totalInventories": 129.0,"tradeReceivables": 102904.0,"miscellaneousReceivables": 23494.0,"totalReceivables": 126398.0,"cash": 12438.0,"totalCurrentAssets": 138966.0,"totalAssets": 138966.0,"tradePayables": 75088.0,"otherLoansOrFinance": 948.0,"miscellaneousLiabilities": 43144.0,"totalCurrentLiabilities": 119180.0,"calledUpShareCapital": 10000.0,"revenueReserves": 3771.0,"otherReserves": 6015.0,"totalShareholdersEquity": 19786.0},"otherFinancials": {"workingCapital": 19786.0,"netWorth": 19786.0},"ratios": {"preTaxProfitMargin": 3.03,"returnOnCapitalEmployed": 22.42,"returnOnTotalAssetsEmployed": 3.19,"returnOnNetAssetsEmployed": 3.19,"salesOrNetWorkingCapital": 7.40,"stockTurnoverRatio": 0.09,"debtorDays": 256.40,"creditorDays": 187.09,"currentRatio": 1.17,"liquidityRatioOrAcidTest": 1.16,"currentDebtRatio": 6.02,"equityInPercentage": 14.24,"totalDebtRatio": 6.02}},{"type": "GlobalFinancialsGGS","yearEndDate": "2013-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 80378.0,"operatingCosts": 76862.0,"operatingProfit": 3516.0,"wagesAndSalaries": 5576.0,"financialExpenses": 115.0,"extraordinaryIncome": 250.0,"profitBeforeTax": 3353.0,"tax": 419.0,"profitAfterTax": 2934.0,"retainedProfit": 2934.0},"balanceSheet": {"rawMaterials": 144.0,"totalInventories": 144.0,"tradeReceivables": 55122.0,"miscellaneousReceivables": 401.0,"totalReceivables": 55523.0,"cash": 6796.0,"totalCurrentAssets": 62463.0,"totalAssets": 62463.0,"tradePayables": 4816.0,"bankLiabilities": 3254.0,"miscellaneousLiabilities": 38378.0,"totalCurrentLiabilities": 46448.0,"totalLiabilities": 46448.0,"calledUpShareCapital": 10000.0,"revenueReserves": 2934.0,"otherReserves": 3081.0,"totalShareholdersEquity": 16015.0},"otherFinancials": {"workingCapital": 16015.0,"netWorth": 16015.0},"ratios": {"preTaxProfitMargin": 4.17,"returnOnCapitalEmployed": 20.94,"returnOnTotalAssetsEmployed": 5.37,"returnOnNetAssetsEmployed": 20.94,"salesOrNetWorkingCapital": 5.02,"stockTurnoverRatio": 0.18,"debtorDays": 250.31,"creditorDays": 21.87,"currentRatio": 1.34,"liquidityRatioOrAcidTest": 1.34,"currentDebtRatio": 2.90,"gearing": 20.32,"equityInPercentage": 25.64,"totalDebtRatio": 2.90}}],"localFinancialStatements": [{"type": "LocalFinancialsSynthesizedCSFR","yearEndDate": "2015-12-31T00:00:00Z","currency": "EUR","month": 12,"financialReportDescription": "Normal Account","numberOfEmployees": 0,"assets": {"capitalNotCalled": 0.0,"totalFixedAssets": 4027.0,"intangibleAssets": 0.0,"tangibleAssets": 4027.0,"financialAssets": 0.0,"netCurrentAssets": 239606.0,"stocks": 656.0,"advancedPayments": 0.0,"receivables": 134284.0,"tradeReceivables": 110666.0,"miscellaneousReceivables": 23436.0,"securitiesAndCash": 104666.0,"prepaidExpenses": 0.0,"accountsOfRegularization": 0.0,"totalAssets": 243633.0,"miscellaneousTotalAssets": 4027.0,"netWorth": 64663.0},"liabilities": {"shareholdersEquity": 64663.0,"shareCapital": 10000.0,"revaluationReserve": 0.0,"otherReserves": 54663.0,"otherCapitalResources": 0.0,"provisionsForRisksAndCharges": 0.0,"liabilities": 178970.0,"financialLiabilities": 2371.0,"advancedPaymentsReceived": 0.0,"tradeAccountPayables": 143786.0,"taxAndSocialLiabilities": 31973.0,"otherDebtsAndFixedAssetsLiabilities": 840.0,"accountRegularization": 0.0,"totalLiabilitiesAndEquity": 243633.0,"bankLoansAndLiabilities": 0.0,"sundryLoansAndLiabilities": 0.0,"miscellaneousLiabilities": 840.0},"profitAndLoss": {"salesOfGoods": 288535.0,"netTurnover": 288534.0,"netExportTurnover": 0.0,"operatingCharges": 232152.0,"operatingProfit": 56383.0,"financialIncome": 0.0,"financialCharges": 61.0,"financialProfitOrLoss": -61.0,"pretaxNetOperatingIncome": 56322.0,"extraordinaryIncome": 690.0,"extraordinaryCharges": 180.0,"extraordinaryProfitOrLoss": 510.0,"netResult": 44877.0}},{"type": "LocalFinancialsSynthesizedCSFR","yearEndDate": "2014-12-31T00:00:00Z","currency": "EUR","month": 12,"financialReportDescription": "Simple Account","numberOfEmployees": 0,"assets": {"capitalNotCalled": 0.0,"totalFixedAssets": 0.0,"intangibleAssets": 0.0,"tangibleAssets": 0.0,"financialAssets": 0.0,"netCurrentAssets": 138965.0,"stocks": 129.0,"advancedPayments": 0.0,"receivables": 126398.0,"securitiesAndCash": 12438.0,"prepaidExpenses": 0.0,"accountsOfRegularization": 0.0,"totalAssets": 138965.0,"miscellaneousTotalAssets": 0.0,"netWorth": 19786.0},"liabilities": {"shareholdersEquity": 19786.0,"shareCapital": 10000.0,"otherReserves": -10000.0,"otherCapitalResources": 0.0,"provisionsForRisksAndCharges": 0.0,"liabilities": 119181.0,"financialLiabilities": 948.0,"advancedPaymentsReceived": 0.0,"tradeAccountPayables": 75088.0,"taxAndSocialLiabilities": 0.0,"otherDebtsAndFixedAssetsLiabilities": 43145.0,"accountRegularization": 0.0,"totalLiabilitiesAndEquity": 138967.0},"profitAndLoss": {"salesOfGoods": 146489.0,"netTurnover": 146475.0,"netExportTurnover": 0.0,"operatingCharges": 142067.0,"operatingProfit": 4422.0,"financialIncome": 0.0,"financialCharges": 57.0,"financialProfitOrLoss": -57.0,"pretaxNetOperatingIncome": 4365.0,"extraordinaryIncome": 260.0,"extraordinaryCharges": 190.0,"extraordinaryProfitOrLoss": 70.0,"netResult": 3771.0}},{"type": "LocalFinancialsSynthesizedCSFR","yearEndDate": "2013-12-31T00:00:00Z","currency": "EUR","month": 12,"financialReportDescription": "Normal Account","numberOfEmployees": 0,"assets": {"capitalNotCalled": 0.0,"totalFixedAssets": 0.0,"intangibleAssets": 0.0,"tangibleAssets": 0.0,"financialAssets": 0.0,"netCurrentAssets": 62463.0,"stocks": 144.0,"advancedPayments": 0.0,"receivables": 55523.0,"tradeReceivables": 55122.0,"miscellaneousReceivables": 401.0,"securitiesAndCash": 6796.0,"prepaidExpenses": 0.0,"accountsOfRegularization": 0.0,"totalAssets": 62463.0,"miscellaneousTotalAssets": 0.0,"netWorth": 16015.0},"liabilities": {"shareholdersEquity": 16015.0,"shareCapital": 10000.0,"revaluationReserve": 0.0,"otherReserves": 6015.0,"otherCapitalResources": 0.0,"provisionsForRisksAndCharges": 0.0,"liabilities": 46448.0,"financialLiabilities": 3254.0,"advancedPaymentsReceived": 0.0,"tradeAccountPayables": 4816.0,"taxAndSocialLiabilities": 22576.0,"otherDebtsAndFixedAssetsLiabilities": 15802.0,"accountRegularization": 0.0,"totalLiabilitiesAndEquity": 62463.0,"bankLoansAndLiabilities": 0.0,"sundryLoansAndLiabilities": 0.0,"miscellaneousLiabilities": 15802.0},"profitAndLoss": {"salesOfGoods": 80378.0,"netTurnover": 80378.0,"netExportTurnover": 0.0,"operatingCharges": 76862.0,"operatingProfit": 3516.0,"financialIncome": 0.0,"financialCharges": 115.0,"financialProfitOrLoss": -115.0,"pretaxNetOperatingIncome": 3401.0,"extraordinaryIncome": 250.0,"extraordinaryCharges": 298.0,"extraordinaryProfitOrLoss": -48.0,"netResult": 2934.0}},{"type": "LocalFinancialsFullCSFR","yearEndDate": "2015-12-31T00:00:00Z","currency": "EUR","month": 12,"assets": {"grandTotalAssets": {"grandTotalNet": 243633.0,"grandTotalGross": 243863.0,"grandTotalAmortisation": 230.0},"capitalSubscribedNotCalled": {"capitalSubscribed": 0.0},"activeFixedAsset": {"total": 4027.0,"gross": 4257.0,"amortisation": 230.0},"activeIntangibleFixedAssets": {"startupCost": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"researchAndDevelopmentExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"distributorshipsPatents": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodwill": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherIntangibleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"prepaymentsAndDownpayments": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalIntangibleAsset": 0.0},"tangilbleFixedAssets": {"land": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"buildings": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"plant": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherTangibleFixedAssets": {"total": 4027.0,"gross": 4257.0,"amortisation": 230.0},"fixedAssetsInConstruction": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"advancesAndPaymentsOnAccount": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalTangibleAsset": 4027.0},"financialAssets": {"associatesAtEquity": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherParticipations": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"intercompanyReceivables": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherInvestmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"loans": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherFinancialAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalFinancialAssets": 0.0},"activeAssets": {"total": 239606.0,"gross": 239606.0,"amortisation": 0.0},"activeStocks": {"rawMaterials": {"total": 656.0,"gross": 656.0,"amortisation": 0.0},"workInProgressGoods": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"workInProgressServices": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"semiFinishedAndFinishedProducts": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodsForResale": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalStocks": 656.0},"advancePaymentsToSupplier": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"activeDebtors": {"tradeAccountsReceivable": {"total": 110666.0,"gross": 110666.0,"amortisation": 0.0},"otherDebtors": {"total": 23436.0,"gross": 23436.0,"amortisation": 0.0},"capitalSubscribedAndCalledUp": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalDebtors": 134102.0},"activeDivers": {"investmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"cashAndCashEquivalents": {"total": 104666.0,"gross": 104666.0,"amortisation": 0.0},"subTotalDivers": 104666.0},"accountPrepaidExpenses": {"total": 182.0,"gross": 182.0,"amortisation": 0.0},"equalizationAccounts": {"multiPeriodCharges": 0.0,"premiumsOnRedemptionOfBonds": 0.0,"currencyDifferentialGain": 0.0},"assetsReferences": {"dueWithinOneYear": 0.0,"dueAfterOneYear": 0.0}},"liabilities": {"grandTotal": 243633.0,"shareholderEquity": {"totalShareholdersEquity": 64663.0,"equityAndShareholdersEquity": 10000.0,"issueAndMergerPremiums": 0.0,"revaluationDifferentials": 0.0,"ofWhichEquityDiffeential": 0.0,"legalReserve": 1000.0,"statutoryOrContractualReserve": 0.0,"specialRegulatedReserves": 0.0,"ofWhichSpecialReserveOfProvisions": 0.0,"otherReservesOfLiabilities": 8786.0,"ofWhichReserveForBuyingOriginalsWorks": 0.0,"profitsOrLossesBroughtForward": 0.0,"profitOrLossForThePeriod": 44877.0,"investmentGrants": 0.0,"specialTaxAllowableReserves": 0.0},"otherCapitalResource": {"totalOtherCapitalResources": 0.0,"incomeFromParticipatingSecurities": 0.0,"conditionalLoans": 0.0},"provisionsForRisksAndCharge": {"totalProvisionsForRisksAndCharges": 0.0,"riskProvisions": 0.0,"reservesForCharges": 0.0},"liabilities": {"totalLiabilities": 178970.0,"convertibleDebentures": 0.0,"otherDebentures": 0.0,"bankLoansAndLiabilities": 2371.0,"sundryLoansAndFinancialLiabilities": 0.0,"ofWhichParticipatingLoans": 0.0,"advancePaymentsReceivedForCurrentOrders": 0.0,"tradeAccountsPayables": 143786.0,"taxAndSocialSecurityLiabilities": 31973.0,"fixedAssetLiabilities": 0.0,"otherDebts": 840.0},"passiveAccountReferences": {"ofWhichTaxAllowableReserve": 1000.0,"deferredIncomeAndLiabilities": 178970.0,"ofWhichCurrentBankFacilities": 2371.0},"extraInformation": {"passiveTranslationLoss": 0.0,"deferredIncome": 0.0}},"profitAndLoss": {"operatingResult": 56383.0,"financialResult": -61.0,"resultsOfPreTaxNetOperatingIncome": 56322.0,"extraordinaryResult": 510.0,"profitOrLoss": 44877.0,"totalIncome": 289225.0,"totalCharges": 244348.0,"employeeProfitSharing": 0.0,"taxOnProfits": 11955.0,"operatingIncome": {"totalOperatingIncome": 288535.0,"goodsForResaleTotal": 0.0,"goodsForResaleFrance": 0.0,"goodsForResaleExport": 0.0,"goodsProducedTotal": 0.0,"goodsProducedFrance": 0.0,"goodsProducedExport": 0.0,"saleOfServicesTotal": 288534.0,"saleOfServicesFrance": 288534.0,"saleOfServicesExport": 0.0,"netTurnoverTotal": 288534.0,"netTurnoverFrance": 288534.0,"netTurnoverExport": 0.0,"stockedProduction": 0.0,"selfConstructedAssets": 0.0,"operatingGrants": 0.0,"releaseOfReservesAndProvisions": 0.0,"otherIncome": 1.0},"totalOperatingCharge": {"totalOperatingCharges": 232152.0,"purchaseOfGoodsForResale": 0.0,"changeInStocksOfGoodsForResale": 0.0,"purchaseOfRawMaterials": 0.0,"changeInStocksOfRawMaterials": -527.0,"otherExternalPurchasesAndCharges": 183084.0,"taxDutyAndSimilarPayments": 349.0,"payroll": 49010.0,"socialSecurityCosts": 0.0},"depreciation": {"depreciationOfFixedAssets": 230.0,"amortisationOfFixedAssets": 0.0,"depreciationAmortisationOfCurrentAssets": 0.0,"provisionsForRisksAndChargesOfResults": 0.0},"otherCharge": {"otherCharges": 5.0,"shareOfJointVentureTransferredToOtherPartner": 0.0,"shareOfJointVentureTransferredFromOtherPartner": 0.0},"resultsFinancialIncome": {"totalFinancialIncome": 0.0,"shareFinancialIncome": 0.0,"otherInvestmentIncomeAndCapitalisedReceivables": 0.0,"otherInterestAndSimilarIncome": 0.0,"releasedProvisions": 0.0,"exchangeGains": 0.0,"netIncomeFromDisposalOfInvestmentSecurities": 0.0},"financialCharge": {"totalFinancialChargeTotal": 61.0,"financialReservesAndProvisions": 0.0,"interestAndSimilarCharges": 61.0,"exchangeLosses": 0.0,"netLossFromDisposalOfInvestmentSecurities": 0.0},"additionalFinancialCharge": {"totalExtraordinaryIncome": 690.0,"extraordinaryOperatingIncome": 690.0,"extraordinaryIncomeFromCapitalTransactions": 0.0,"releasedProvisionsCharges": 0.0},"extraordinaryCharge": {"totalExtraordinaryCharges": 180.0,"extraordinaryOperatingCharges": 180.0,"extraordinaryChargesFromCapitalTransactions": 0.0,"extraordinaryReservesAndProvisions": 0.0},"references": {"ofWhichEquipmentLeases": 0.0,"ofWhichPropertyLeases": 0.0,"ofWhichTransferredCharges": 0.0,"ofWhichTradersOwnContributions": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsIncome": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsCharges": 0.0}},"otherIncomes": {"grossGrandTotalFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossResearchAndDevelopmentChargeFixed": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherBudgetItemFromIntangibleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherTangilbleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherFinancialAsset": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"situationAndMovementOfReserveForDepreciationGrandTotal": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"researchAndDevelopmentChargeReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"otherIntangibleAssetsReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalFixedAssedAmotisationReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"netMovementsDuringPeriodAffectingChargeAllocatedOverSeveralPeriod": {"valueAtEndOfPeriod": 0.0},"netPremiumRefundOfObligations": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"grandTotals": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"includesTotalAllocations": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"includesTotalWithdrawal": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"totalRegulatedProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalRiskAndChargeProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalProvisionForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"stateClaims": {"stateClaimsGrossValue": 0.0,"stateClaimsWhenOneYearAtMost": 0.0,"stateClaimsWhenmoreThanOneYear": 0.0},"stateOfLoans": {"claimsRelatedToHoldingsGross": 0.0,"claimsRelatedToShareholdingsOneYearAtMost": 0.0,"grossOfLoans": 0.0,"loansOneYearAtMost": 0.0,"otherFinancialAssetsGross": 0.0,"otherFinancialAssetsOneYearAtMost": 0.0},"receivablesStatementOfAssets": {"customersDoubtfulOrDisputed": 0.0,"otherClaimsCustomer": 0.0,"receivablesRepresentLoanedSecurities": 0.0,"provisionForDepreciationPreviouslyEstablished": 0.0,"personnelAndAssociatedAccounts": 0.0,"socialSecurityAndOtherSocialOrganizations": 0.0,"incomeTaxes": 0.0,"valueAddedTax": 0.0,"otherTaxesAndPaymentsAssimilatedOfReceivables": 0.0,"stateAndOtherPublicMiscellaneous": 0.0,"groupAndAssociates": 0.0,"accountsReceivableIncOtherClaims": 0.0},"stateDebt": {"totalDebtGross": 178969.0,"debtOneYearAtMost": 178969.0,"debtMoreThanOneYearAndFiveYearsAtMost": 0.0,"debtMoreThanFiveYears": 0.0},"details": {"convertibleBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToOneYearMaximumAtTheOrigin": {"gross": 2370.0,"oneYearAtMost": 2370.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToMoreThanOneYearAtTheOrigin": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"financialLiabilities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"suppliersAssociatedAccounts": {"gross": 143786.0,"oneYearAtMost": 143786.0,"moreThanOneYearAndFiveYearsAtMost": 143786.0},"personnelAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherSocialOrganizations": {"gross": 31972.0,"oneYearAtMost": 31972.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"taxesOnProfits": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"vat": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"backedObligations": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherTaxesAssimilated": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"assetsAndLiabilitiesAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"groupsAndAssociates": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"otherLiabilities": {"gross": 840.0,"oneYearAtMost": 840.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"debtOfBorrowedSecurities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"productsInAdvance": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0}},"referencesOthers": {"loansMadeDuringThePeriod": 0.0,"debtRepaidDuringThePeriod": 0.0},"commitments": {"commitmentsLeasingFurniture": 0.0,"commitmentsRealEstateLeasing": 0.0,"effectsBroughtToTheDiscountAndUnmatured": 0.0},"otherChargesExternal": {"subContracting": 0.0,"rentalsRentalChargesAndCondominiums": 0.0,"staffOutsideTheCompany": 0.0,"remunerationIntermediariesAndFeesExcludingFees": 0.0,"feesCommissionsAndBrokerage": 0.0,"otherAccounts": 0.0,"totalOtherPurchasesAndExternal": 0.0},"taxesAndFees": {"businessTax": 0.0,"otherTaxesAndPaymentsAssimilated": 0.0,"totalTaxesAndFees": 0.0},"vat": {"amountVatCollected": 0.0,"totalVatOnGoodsAndServices": 0.0},"extraInformation": {"averageNumberOfEmployees": 0.0,"dividends": 0.0,"prepaid": 0.0}},"ratios": {"structureAndLiquidity": {"fixedAssetFinancing": 15.24,"globalDebt": 223.0,"workingCapitalFundOverallNet": 76.0,"financialIndependence": 2727.25,"solvability": 26.54,"capacityDebtFutures": 2728.4,"coverageOfCurrentAssets": 25.33,"generalLiquidity": 0.0,"restrictedLiquidity": 0.58},"managementOrRotation": {"needBackgroundInOperatingWorkingCapital": -80.0,"treasury": 128.0,"averageLengthOfCreditGrantedCoCustomers": 138.0,"averageLengthOfCreditObtainedSuppliers": 284.0},"profitabilityOfTheBusiness": {"marginTrading": 0.0,"profitabilityOfTheBusiness": 19.62,"netprofit": 15.55,"growthRateOfTurnover": 258.97,"ratesIntegration": 36.73,"rateLeasingFurniture": 0.0,"workFactor": 46.25,"weightInterests": 0.02},"returnOnCapital": {"cashFlowFromTheOverallProfitability": 15.63,"ratesOfEconomicProfitability": 84.0,"financialProfitability": 69.4,"returnOnInvestment": 0.02}},"sig": {"turnover": 288534.0,"saleOfGoods": 0.0,"purchaseOfGoods": 0.0,"stockOfGoodsVariation": 0.0,"tradingMarginOfSalesOfGoods": 0.0,"saleOfGoodsProduce": 288534.0,"valueOfStockedProduction": 0.0,"valueOfSelfConstructedAssets": 0.0,"periodProductionOfSaleOfGoodsProduce": 288534.0,"tradingMargin": 0.0,"periodProductionOfTradingMargin": 288534.0,"purchaseOfawMaterials": 0.0,"differenceInStocksOfRawMaterials": -527.0,"variousExternalPurchasesAndCharges": 183084.0,"addedValueOfTradingMargin": 105977.0,"addedValue": 105977.0,"opertingGrants": 0.0,"taxAndDutyAndSimilarPayments": 349.0,"personalCharges": 49010.0,"grossOperatingSurplusOfAddedValue": 56618.0,"grossOperatingSurplus": 56618.0,"grossOperatingSurplusDifference": 19.62,"changeInReleaseOfReservesAndProvisions": 0.0,"otherOperatingIncome": 1.0,"depreciationOrAmmortisation": 230.0,"changesInOtherCharges": 5.0,"operatingResultOfGrossOperatingSurplus": 56384.0,"resultOfJointVentureTransferredFromOrToOtherPartners": 0.0,"financialIncomeOfOperatingResult": 0.0,"financialChargesOfOperatingResult": 61.0,"preTaxResultOfOperatingResult": 56323.0,"extraodinaryIncome": 690.0,"extaordinaryCharges": 180.0,"extraordinaryResultOfExtraordinaryIncome": 510.0,"preTaxResult": 56323.0,"exceptionalIncomeResult": 510.0,"employeeProfitSharing": 0.0,"taxOnProfit": 11955.0,"netResultOfPreTaxResult": 44878.0}},{"type": "LocalFinancialsFullCSFR","yearEndDate": "2013-12-31T00:00:00Z","currency": "EUR","month": 12,"assets": {"grandTotalAssets": {"grandTotalNet": 62463.0,"grandTotalGross": 62463.0,"grandTotalAmortisation": 0.0},"capitalSubscribedNotCalled": {"capitalSubscribed": 0.0},"activeFixedAsset": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"activeIntangibleFixedAssets": {"startupCost": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"researchAndDevelopmentExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"distributorshipsPatents": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodwill": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherIntangibleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"prepaymentsAndDownpayments": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalIntangibleAsset": 0.0},"tangilbleFixedAssets": {"land": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"buildings": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"plant": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherTangibleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"fixedAssetsInConstruction": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"advancesAndPaymentsOnAccount": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalTangibleAsset": 0.0},"financialAssets": {"associatesAtEquity": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherParticipations": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"intercompanyReceivables": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherInvestmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"loans": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherFinancialAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalFinancialAssets": 0.0},"activeAssets": {"total": 62463.0,"gross": 62463.0,"amortisation": 0.0},"activeStocks": {"rawMaterials": {"total": 144.0,"gross": 144.0,"amortisation": 0.0},"workInProgressGoods": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"workInProgressServices": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"semiFinishedAndFinishedProducts": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"goodsForResale": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalStocks": 144.0},"advancePaymentsToSupplier": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"activeDebtors": {"tradeAccountsReceivable": {"total": 55122.0,"gross": 55122.0,"amortisation": 0.0},"otherDebtors": {"total": 401.0,"gross": 401.0,"amortisation": 0.0},"capitalSubscribedAndCalledUp": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"subTotalDebtors": 55523.0},"activeDivers": {"investmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"cashAndCashEquivalents": {"total": 6796.0,"gross": 6796.0,"amortisation": 0.0},"subTotalDivers": 6796.0},"accountPrepaidExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"equalizationAccounts": {"multiPeriodCharges": 0.0,"premiumsOnRedemptionOfBonds": 0.0,"currencyDifferentialGain": 0.0},"assetsReferences": {"dueWithinOneYear": 0.0,"dueAfterOneYear": 0.0}},"liabilities": {"grandTotal": 62463.0,"shareholderEquity": {"totalShareholdersEquity": 16015.0,"equityAndShareholdersEquity": 10000.0,"issueAndMergerPremiums": 0.0,"revaluationDifferentials": 0.0,"ofWhichEquityDiffeential": 0.0,"legalReserve": 1000.0,"statutoryOrContractualReserve": 0.0,"specialRegulatedReserves": 0.0,"ofWhichSpecialReserveOfProvisions": 0.0,"otherReservesOfLiabilities": 2081.0,"ofWhichReserveForBuyingOriginalsWorks": 0.0,"profitsOrLossesBroughtForward": 0.0,"profitOrLossForThePeriod": 2934.0,"investmentGrants": 0.0,"specialTaxAllowableReserves": 0.0},"otherCapitalResource": {"totalOtherCapitalResources": 0.0,"incomeFromParticipatingSecurities": 0.0,"conditionalLoans": 0.0},"provisionsForRisksAndCharge": {"totalProvisionsForRisksAndCharges": 0.0,"riskProvisions": 0.0,"reservesForCharges": 0.0},"liabilities": {"totalLiabilities": 46448.0,"convertibleDebentures": 0.0,"otherDebentures": 0.0,"bankLoansAndLiabilities": 3254.0,"sundryLoansAndFinancialLiabilities": 0.0,"ofWhichParticipatingLoans": 0.0,"advancePaymentsReceivedForCurrentOrders": 0.0,"tradeAccountsPayables": 4816.0,"taxAndSocialSecurityLiabilities": 22576.0,"fixedAssetLiabilities": 0.0,"otherDebts": 15802.0},"passiveAccountReferences": {"ofWhichTaxAllowableReserve": 1000.0,"deferredIncomeAndLiabilities": 46448.0,"ofWhichCurrentBankFacilities": 3254.0},"extraInformation": {"passiveTranslationLoss": 0.0,"deferredIncome": 0.0}},"profitAndLoss": {"operatingResult": 3516.0,"financialResult": -115.0,"resultsOfPreTaxNetOperatingIncome": 3401.0,"extraordinaryResult": -48.0,"profitOrLoss": 2934.0,"totalIncome": 80628.0,"totalCharges": 77694.0,"employeeProfitSharing": 0.0,"taxOnProfits": 419.0,"operatingIncome": {"totalOperatingIncome": 80378.0,"goodsForResaleTotal": 0.0,"goodsForResaleFrance": 0.0,"goodsForResaleExport": 0.0,"goodsProducedTotal": 0.0,"goodsProducedFrance": 0.0,"goodsProducedExport": 0.0,"saleOfServicesTotal": 80378.0,"saleOfServicesFrance": 80378.0,"saleOfServicesExport": 0.0,"netTurnoverTotal": 80378.0,"netTurnoverFrance": 80378.0,"netTurnoverExport": 0.0,"stockedProduction": 0.0,"selfConstructedAssets": 0.0,"operatingGrants": 0.0,"releaseOfReservesAndProvisions": 0.0,"otherIncome": 0.0},"totalOperatingCharge": {"totalOperatingCharges": 76862.0,"purchaseOfGoodsForResale": 0.0,"changeInStocksOfGoodsForResale": 0.0,"purchaseOfRawMaterials": 44.0,"changeInStocksOfRawMaterials": 21528.0,"otherExternalPurchasesAndCharges": 516.0,"taxDutyAndSimilarPayments": 49198.0,"payroll": 5576.0,"socialSecurityCosts": 0.0},"depreciation": {"depreciationOfFixedAssets": 0.0,"amortisationOfFixedAssets": 0.0,"depreciationAmortisationOfCurrentAssets": 0.0,"provisionsForRisksAndChargesOfResults": 0.0},"otherCharge": {"otherCharges": 0.0,"shareOfJointVentureTransferredToOtherPartner": 0.0,"shareOfJointVentureTransferredFromOtherPartner": 0.0},"resultsFinancialIncome": {"totalFinancialIncome": 0.0,"shareFinancialIncome": 0.0,"otherInvestmentIncomeAndCapitalisedReceivables": 0.0,"otherInterestAndSimilarIncome": 0.0,"releasedProvisions": 0.0,"exchangeGains": 0.0,"netIncomeFromDisposalOfInvestmentSecurities": 0.0},"financialCharge": {"totalFinancialChargeTotal": 115.0,"financialReservesAndProvisions": 0.0,"interestAndSimilarCharges": 115.0,"exchangeLosses": 0.0,"netLossFromDisposalOfInvestmentSecurities": 0.0},"additionalFinancialCharge": {"totalExtraordinaryIncome": 250.0,"extraordinaryOperatingIncome": 250.0,"extraordinaryIncomeFromCapitalTransactions": 0.0,"releasedProvisionsCharges": 0.0},"extraordinaryCharge": {"totalExtraordinaryCharges": 298.0,"extraordinaryOperatingCharges": 298.0,"extraordinaryChargesFromCapitalTransactions": 0.0,"extraordinaryReservesAndProvisions": 0.0},"references": {"ofWhichEquipmentLeases": 0.0,"ofWhichPropertyLeases": 0.0,"ofWhichTransferredCharges": 0.0,"ofWhichTradersOwnContributions": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsIncome": 0.0,"ofWhichRoyaltiesOnLicencesAndPatentsCharges": 0.0}},"otherIncomes": {"grossGrandTotalFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossResearchAndDevelopmentChargeFixed": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherBudgetItemFromIntangibleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherTangilbleFixedAssets": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"grossOtherFinancialAsset": {"valueAtBeginOfPeriod": 0.0,"increasesDueToRevaluation": 0.0,"increasesOfAcquisitionsCreationsContributions": 0.0,"decreasesByBudgetItemTransfer": 0.0,"decreasesByTransfers": 0.0,"valueAtEndOfPeriod": 0.0},"situationAndMovementOfReserveForDepreciationGrandTotal": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"researchAndDevelopmentChargeReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"otherIntangibleAssetsReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalFixedAssedAmotisationReserveForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"netMovementsDuringPeriodAffectingChargeAllocatedOverSeveralPeriod": {"valueAtEndOfPeriod": 0.0},"netPremiumRefundOfObligations": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"grandTotals": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"includesTotalAllocations": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"includesTotalWithdrawal": {"operating": 0.0,"financial": 0.0,"exceptional": 0.0},"totalRegulatedProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalRiskAndChargeProvisions": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"totalProvisionForDepreciation": {"valueAtBeginOfPeriod": 0.0,"increases": 0.0,"decreases": 0.0,"valueAtEndOfPeriod": 0.0},"stateClaims": {"stateClaimsGrossValue": 55523.0,"stateClaimsWhenOneYearAtMost": 55523.0,"stateClaimsWhenmoreThanOneYear": 0.0},"stateOfLoans": {"claimsRelatedToHoldingsGross": 0.0,"claimsRelatedToShareholdingsOneYearAtMost": 0.0,"grossOfLoans": 0.0,"loansOneYearAtMost": 0.0,"otherFinancialAssetsGross": 0.0,"otherFinancialAssetsOneYearAtMost": 0.0},"receivablesStatementOfAssets": {"customersDoubtfulOrDisputed": 0.0,"otherClaimsCustomer": 0.0,"receivablesRepresentLoanedSecurities": 0.0,"provisionForDepreciationPreviouslyEstablished": 0.0,"personnelAndAssociatedAccounts": 0.0,"socialSecurityAndOtherSocialOrganizations": 0.0,"incomeTaxes": 0.0,"valueAddedTax": 0.0,"otherTaxesAndPaymentsAssimilatedOfReceivables": 0.0,"stateAndOtherPublicMiscellaneous": 0.0,"groupAndAssociates": 0.0,"accountsReceivableIncOtherClaims": 0.0},"stateDebt": {"totalDebtGross": 46448.0,"debtOneYearAtMost": 46448.0,"debtMoreThanOneYearAndFiveYearsAtMost": 0.0,"debtMoreThanFiveYears": 0.0},"details": {"convertibleBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherBonds": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToOneYearMaximumAtTheOrigin": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"borrowingDebtsToMoreThanOneYearAtTheOrigin": {"gross": 3254.0,"oneYearAtMost": 3254.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"financialLiabilities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"suppliersAssociatedAccounts": {"gross": 4816.0,"oneYearAtMost": 4816.0,"moreThanOneYearAndFiveYearsAtMost": 4816.0},"personnelAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherSocialOrganizations": {"gross": 22576.0,"oneYearAtMost": 22576.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"taxesOnProfits": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"vat": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"backedObligations": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"otherTaxesAssimilated": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"assetsAndLiabilitiesAssociatedAccounts": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"groupsAndAssociates": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0,"moreThanFiveYears": 0.0},"otherLiabilities": {"gross": 15802.0,"oneYearAtMost": 15802.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"debtOfBorrowedSecurities": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0},"productsInAdvance": {"gross": 0.0,"oneYearAtMost": 0.0,"moreThanOneYearAndFiveYearsAtMost": 0.0}},"referencesOthers": {"loansMadeDuringThePeriod": 0.0,"debtRepaidDuringThePeriod": 0.0},"commitments": {"commitmentsLeasingFurniture": 0.0,"commitmentsRealEstateLeasing": 0.0,"effectsBroughtToTheDiscountAndUnmatured": 0.0},"otherChargesExternal": {"subContracting": 0.0,"rentalsRentalChargesAndCondominiums": 0.0,"staffOutsideTheCompany": 0.0,"remunerationIntermediariesAndFeesExcludingFees": 0.0,"feesCommissionsAndBrokerage": 0.0,"otherAccounts": 0.0,"totalOtherPurchasesAndExternal": 0.0},"taxesAndFees": {"businessTax": 0.0,"otherTaxesAndPaymentsAssimilated": 0.0,"totalTaxesAndFees": 0.0},"vat": {"amountVatCollected": 0.0,"totalVatOnGoodsAndServices": 0.0},"extraInformation": {"averageNumberOfEmployees": 0.0,"dividends": 0.0,"prepaid": 55523.0}},"ratios": {"structureAndLiquidity": {"globalDebt": 208.0,"workingCapitalFundOverallNet": 72.0,"financialIndependence": 492.16,"solvability": 25.64,"capacityDebtFutures": 492.16,"coverageOfCurrentAssets": 25.64,"generalLiquidity": 1.2,"restrictedLiquidity": 1.34},"managementOrRotation": {"needBackgroundInOperatingWorkingCapital": 125.0,"treasury": 16.0,"averageLengthOfCreditGrantedCoCustomers": 247.0,"averageLengthOfCreditObtainedSuppliers": 78.0,"inventoryTurnoverOfRawMaterials": 1178.0},"profitabilityOfTheBusiness": {"marginTrading": 0.0,"profitabilityOfTheBusiness": 4.37,"netprofit": 3.65,"ratesIntegration": 72.52,"rateLeasingFurniture": 0.0,"workFactor": 9.57,"weightInterests": 0.14},"returnOnCapital": {"cashFlowFromTheOverallProfitability": 3.65,"ratesOfEconomicProfitability": 18.0,"financialProfitability": 18.32,"returnOnInvestment": 0.14}},"sig": {"turnover": 80378.0,"saleOfGoods": 0.0,"purchaseOfGoods": 0.0,"stockOfGoodsVariation": 0.0,"tradingMarginOfSalesOfGoods": 0.0,"saleOfGoodsProduce": 80378.0,"valueOfStockedProduction": 0.0,"valueOfSelfConstructedAssets": 0.0,"periodProductionOfSaleOfGoodsProduce": 80378.0,"tradingMargin": 0.0,"periodProductionOfTradingMargin": 80378.0,"purchaseOfawMaterials": 44.0,"differenceInStocksOfRawMaterials": 21528.0,"variousExternalPurchasesAndCharges": 516.0,"addedValueOfTradingMargin": 58290.0,"addedValue": 58290.0,"opertingGrants": 0.0,"taxAndDutyAndSimilarPayments": 49198.0,"personalCharges": 5576.0,"grossOperatingSurplusOfAddedValue": 3516.0,"grossOperatingSurplus": 3516.0,"grossOperatingSurplusDifference": 4.37,"changeInReleaseOfReservesAndProvisions": 0.0,"otherOperatingIncome": 0.0,"depreciationOrAmmortisation": 0.0,"changesInOtherCharges": 0.0,"operatingResultOfGrossOperatingSurplus": 3516.0,"resultOfJointVentureTransferredFromOrToOtherPartners": 0.0,"financialIncomeOfOperatingResult": 0.0,"financialChargesOfOperatingResult": 115.0,"preTaxResultOfOperatingResult": 3401.0,"extraodinaryIncome": 250.0,"extaordinaryCharges": 298.0,"extraordinaryResultOfExtraordinaryIncome": -48.0,"preTaxResult": 3401.0,"exceptionalIncomeResult": -48.0,"employeeProfitSharing": 0.0,"taxOnProfit": 419.0,"netResultOfPreTaxResult": 2934.0}},{"type": "LocalFinancialsSimpleCSFR","yearEndDate": "2014-12-31T00:00:00Z","currency": "EUR","month": 12,"assets": {"grandTotalAssets": {"total": 138966.0,"gross": 138966.0,"amortisation": 0.0},"activeFixedAsset": {"totalActiveFixedAsset": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"intangibleAssetGoodwill": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"otherIntangibleAsset": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"tangilbleFixedAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"financialAssets": {"total": 0.0,"gross": 0.0,"amortisation": 0.0}},"assets": {"assets": {"total": 138966.0,"gross": 138966.0,"amortisation": 0.0},"rawMaterialsStockSupplyInProduction": {"total": 129.0,"gross": 129.0,"amortisation": 0.0},"goodsForResale": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"advancePaymentsToSuppliers": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"tradeAccountsReceivableDebtor": {"total": 102904.0,"gross": 102904.0,"amortisation": 0.0},"otherDebtors": {"total": 23494.0,"gross": 23494.0,"amortisation": 0.0},"investmentSecurities": {"total": 0.0,"gross": 0.0,"amortisation": 0.0},"cashAndCashEquivalents": {"total": 12438.0,"gross": 12438.0,"amortisation": 0.0,"cash": 0.0},"prepaidExpenses": {"total": 0.0,"gross": 0.0,"amortisation": 0.0}}},"liabilities": {"passiveGrandTotal": 138966.0,"provisionsForRisksAndCharges": 0.0,"shareholderEquity": {"totalShareholderEquity": 19786.0,"equityAndShareholdersEquity": 10000.0,"revaluationDifferentials": 0.0,"legalReserve": 1000.0,"specialRegulatedReserves": 0.0,"otherReserves": 5015.0,"profitsOrLossesBroughtForward": 0.0,"profitOrLossForThePeriod": 3771.0,"specialTaxAllowableReserves": 0.0},"liabilities": {"totalLiabilities": 119180.0,"loansAndDebtsAssimilated": 948.0,"advancePaymentsReceivedForCurrentOrders": 0.0,"tradeAccountsPayables": 75088.0,"otherDebts": 43145.0,"otherCreditorsWhoseAccountsOfAssociatesOfTheExerciseN": 0.0,"deferredIncome": 0.0},"references": {"includingFinancialAssetsWithinOneYear": 0.0,"includingDebtsAfterOneYear": 0.0,"includingCurrentAccountsReceivableAssociated": 0.0,"includingDebtsCurrentOneYear": 0.0,"costOfReturnOfCapitalAssetsAcquiredOrCreatedDuringTheYear": 0.0,"sellingPriceExcludingVatCapitalSurrenderedDuringTheYear": 0.0}},"profitAndLoss": {"operatingResults": {"operatingResult": 4422.0,"profitOrLoss": 3771.0},"operatingIncome": {"totalOperatingIncomeWithoutVat": 146489.0,"saleOfGoodsForResale": 0.0,"resaleGoodsExport": 0.0,"saleOfGoodsProduced": 0.0,"producedGoodsExport": 0.0,"saleOfServices": 146475.0,"servicesSoldExport": 0.0,"stockedProduction": 0.0,"selfConstructedAssets": 0.0,"operatingGrants": 0.0,"otherIncome": 14.0},"operatingCharges": {"totalOperatingChargesTotal": 142067.0,"purchaseOfGoodsForResaleIncludingCustomsDuties": 0.0,"changeInStocksOfGoodsForResale": 0.0,"purchaseOfRawMaterialsIncludingCustomsDuties": 0.0,"changeInStocksOfRawMaterials": 15.0,"otherExternalPurchasesAndCharges": 99218.0,"includesLeaseFurniture": 0.0,"includesLeaseRealEstate": 0.0,"taxDutyAndSimilarPayments": 345.0,"includingBusinessTax": 345.0,"payroll": 42477.0,"socialSecurityCosts": 0.0,"depreciation": 0.0,"provisions": 0.0,"otherCharges": 12.0,"includingProvisionsForTaxSettlementsAbroad": 0.0},"productsAndVariousCharges": {"financialProductsTotal": 0.0,"extraordinaryIncomeTotal": 260.0,"financialChargesTotal": 57.0,"extraordinaryChargesTotal": 190.0,"incomeTaxesTotal": 665.0,"compensationAndBenefitsNonDeductiblePersonal": 0.0,"amountVatCollected": 22805.0,"deductibleVatOnGoodsAndServices": 5729.0,"averageNumberOfEmployees": 0.0}},"otherIncomes": {"otherIncomeTaxReturnForms": {"grossAssetValueAtBeginningOfYear": 0.0,"increasess": 0.0,"decreasess": 0.0},"intangibleFixedAssets": {"goddwillIncreases": 0.0,"goddwillDecreases": 0.0,"othersIncreases": 0.0,"othersDecreases": 0.0},"tangilbleFixedAssetsIncreases": {"land": 0.0,"buildings": 0.0,"plantMachineryAndEquipmentIndustry": 0.0,"generalInstallationsVariousFixtures": 0.0,"transportationEquipment": 0.0,"otherFixedAssets": 0.0},"financialAsset": {"assetsIncreases": 0.0,"assetsDecreases": 0.0},"capitalGainsLosses": {"totalResidualValue": 0.0,"totalTransferPricing": 0.0,"totalPlusOrLossesInTheShortTerm": 0.0,"totalPlusOrLossesInTheLongTerm": 0.0},"summaryOfProvisionsDepreciationDerogatory": {"totalProvisionsIncreases": 0.0,"increasedProvisionsRegulatedDepreciation": 0.0,"increasedProvisionsRegulated": 0.0,"otherIncreasedProvisionsRegulated": 0.0,"increasedProvisionsForRisksAndCharges": 0.0,"increasedProvisionsForLossesOnCapital": 0.0,"increasedProvisionsForLossesAndCurrentStocks": 0.0,"increasedProvisionsForLossesClientsAndExtras": 0.0,"otherIncreasedProvisionsForLosses": 0.0,"totalProvisionsDecreases": 0.0,"decreasedProvisionsRegulatedDepreciation": 0.0,"decreasedProvisionsRegulated": 0.0,"otherDecreasedProvisionsRegulated": 0.0,"decreasedProvisionsForRisksAndCharges": 0.0,"decreasedProvisionsForLossesOnCapital": 0.0,"decreasedProvisionsForLossesAndCurrentStocks": 0.0,"decreasedProvisionsForLossesClientsAndExtras": 0.0,"otherDecreasedProvisionsForLosses": 0.0}}}],"paymentData": {"industryDbt": "4","paymentTrend": "TrendNotAvailable","averageMonthlyBalance": "0","balanceP1": "0","balanceP2": "0","balanceP3": "0","balanceP4": "0","balanceWithinTerms": "0","invoicesBetween3And12Monts": {"paidP1": "0","paidP2": "0","paidP3": "0","paidP4": "0","paidInTerms": "0","totalPaid": "0"},"invoicesLast3Monts": {"paidP1": "0","paidP2": "0","paidP3": "0","paidP4": "0","paidInTerms": "0","totalPaid": "0"},"recentHighBalance": "0","totalTradeLines": "0","totalTradeLinesOutstanding": "0"},"additionalInformation": {"misc": {"sizeOfUrbanArea": "Establishment in a rural municipality","reasonForFormation": "Formation","financialAccountsType": "F","statusCode": "A","officeType": "1","numberOfBranches": "1","numberOfEmployeesAtAddress": "1 or 2 employees","numberOfEmployeesAtCompany": "1 or 2 employees","activityClassification": "NAF/APE","inseeCode": "34197","streetAddress": "10 RUE DE LA CLAIRETTE","postalCode": "34800","postalDistributionCode": "34800","municipality": "PERET","subRegion": "Hérault","courtRegistryNumber": "537643967","registrationCourt": "Beziers (34)","nationality": "France","numberOfDirectors": 1,"rcsRegistration": "RCS Beziers 1  537643967"},"establishmentDetails": {"typeOfEstablishmentDescription": "Head office","formationDate": "2011-10-01T00:00:00Z","activityLocation": "Other","department": "Hérault 34","district": "1","area": "14"},"otherEstablishmentDetails": {"regionality": "Legal unit with all establishments in same area","monoActivityStatus": "Legal unit having all establishments with the same main activity"},"companyHistory": [{"date": "2020-06-02T00:00:00Z","description": "Update Rating"},{"date": "2019-11-29T00:00:00Z","description": "Consideration of a confidential balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2019-11-13T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2019-10-06T00:00:00Z","description": "Update Rating"},{"date": "2018-10-11T00:00:00Z","description": "Update Rating"},{"date": "2018-10-11T00:00:00Z","description": "Consideration of a confidential balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2018-09-25T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2018-03-18T00:00:00Z","description": "Update Limit"},{"date": "2018-03-18T00:00:00Z","description": "Update Rating"},{"date": "2017-10-25T00:00:00Z","description": "Invalid balance sheet"},{"date": "2017-08-07T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2016-04-29T00:00:00Z","description": "Update Limit"},{"date": "2016-04-29T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2016-04-27T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2016-04-08T00:00:00Z","description": "Bodacc B: Various editing or changing"},{"date": "2016-03-29T00:00:00Z","description": "Updated articles of association"},{"date": "2016-03-29T00:00:00Z","description": "Amendment"},{"date": "2016-03-29T00:00:00Z","description": "Appointment/resignation of company officers"},{"date": "2016-03-01T00:00:00Z","description": "Legal Gazette: Resignation / Revocation of the social representative"},{"date": "2016-02-19T00:00:00Z","description": "Update of Company Legal Form"},{"date": "2015-12-31T00:00:00Z","description": "New accounts available"},{"date": "2015-05-08T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2015-05-05T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2014-12-31T00:00:00Z","description": "New accounts available"},{"date": "2014-05-07T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2014-04-30T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2013-12-31T00:00:00Z","description": "New accounts available"},{"date": "2013-10-19T00:00:00Z","description": "Update Limit"},{"date": "2013-10-19T00:00:00Z","description": "Update Rating"},{"date": "2013-06-27T00:00:00Z","description": "Bodacc C : Deposit accounts notice"},{"date": "2013-06-06T00:00:00Z","description": "Consideration of a balance sheet that has led to a reassessment of this company\'s creditworthiness"},{"date": "2012-12-31T00:00:00Z","description": "New accounts available"},{"date": "2011-11-16T00:00:00Z","description": "Bodacc A : Establishment creation"},{"date": "2011-11-04T00:00:00Z","description": "Appointment/resignation of company officers"},{"date": "2011-11-04T00:00:00Z","description": "Fund deposit certificate"},{"date": "2011-11-04T00:00:00Z","description": "Company formation"},{"date": "2011-11-04T00:00:00Z","description": "Private document"},{"date": "2011-10-21T00:00:00Z","description": "Modification of Company Activity"},{"date": "2011-10-21T00:00:00Z","description": "Update of Company Activity"},{"date": "2011-10-21T00:00:00Z","description": "Formation of Company"}],"establishmentHistory": [{"date": "2017-06-07T00:00:00Z","description": "Update of phone numbers"},{"date": "2017-04-22T00:00:00Z","description": "Update Rating"},{"date": "2016-04-29T00:00:00Z","description": "Update Limit"},{"date": "2016-04-29T00:00:00Z","description": "Update Rating"},{"date": "2016-03-31T00:00:00Z","description": "Update Rating"},{"date": "2016-02-19T00:00:00Z","description": "Modification of Head office"},{"date": "2016-01-21T00:00:00Z","description": "Update Rating"},{"date": "2015-07-08T00:00:00Z","description": "Update of phone numbers"},{"date": "2015-05-08T00:00:00Z","description": "Update Rating"},{"date": "2015-05-08T00:00:00Z","description": "Update Limit"},{"date": "2014-07-20T00:00:00Z","description": "Update Rating"},{"date": "2014-04-30T00:00:00Z","description": "Update Limit"},{"date": "2014-04-30T00:00:00Z","description": "Update Rating"},{"date": "2014-04-17T00:00:00Z","description": "Update Rating"},{"date": "2013-08-24T00:00:00Z","description": "Update Rating"},{"date": "2013-06-06T00:00:00Z","description": "Update Rating"},{"date": "2013-06-06T00:00:00Z","description": "Update Limit"},{"date": "2012-10-24T00:00:00Z","description": "Update Limit"},{"date": "2012-10-24T00:00:00Z","description": "Update Rating"},{"date": "2011-10-21T00:00:00Z","description": "Modification of Head office Activity"},{"date": "2011-10-21T00:00:00Z","description": "Formation of Head office"},{"date": "2011-10-21T00:00:00Z","description": "Update of Establishment Activity"}],"gazettes": [{"publicationDate": "2019-11-13T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "2447 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2018."},{"publicationDate": "2018-09-25T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "2835 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2017."},{"publicationDate": "2017-08-07T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "1201 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2016."},{"publicationDate": "2016-04-27T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "3030 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2015."},{"publicationDate": "2016-04-08T00:00:00Z","type": "Bodacc B : Modification et mutation diverse","name": "B","description": "Modification et mutation diverse","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "659 - 537 643 967 RCS Béziers. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Administration : Gérant : RUBINOCCI René. Activité :  . Commentaires : Modification survenue sur l\'administration."},{"publicationDate": "2015-05-05T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "3198 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2014."},{"publicationDate": "2014-05-07T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "2961 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette   34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2013."},{"publicationDate": "2013-06-27T00:00:00Z","type": "Bodacc C : Avis de dépôt des comptes","name": "C","description": "Comptes annuels et rapports","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "5223 - 537643967 RCS. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Adresse : 10 rue de la Clairette34800 Péret. Commentaires : Comptes annuels et rapports de l\'exercice clos le : 31/12/2012."},{"publicationDate": "2011-11-16T00:00:00Z","type": "Bodacc A : Création d\'établissement","name": "A_REG","description": "Création d\'établissement","publicationArea": "34 - HERAULT","court": "GREFFE DU TRIBUNAL DE COMMERCE DE BÉZIERS","detail": "238 - 537 643 967 RCS Béziers. TESTS OPTIMUM. Forme : Société à responsabilité limitée. Administration : Co-Gérant : RUBINOCCI René Co-Gérant : LOPEZ Séverine né(e) VAN DAMME. Capital : 10000 EUR. Adresse : 10 rue de la Clairette, 34800 Péret. Origine du fonds : Création. Etablissement : Etablissement principal. Activité : Organisation et réalisation de recrutement de groupes de consommateurs pour les sociétés de marketing ainsi que l\'organisation et la réalisation de recrutement de groupes de consommateurs par tous moyens. Adresse : 10 rue de la Clairette, 34800 Péret. A dater du : 04/11/2011. Date de commencement de l’activité : 21/10/2011. Descriptif  : . Commentaires : Immatriculation d\'une personne morale (B, C, D) suite à création d\'un établissement principal."}],"jals": [{"eventDate": "2016-02-19T00:00:00Z","type": "Démission / Révocation du mandataire social","parutionDate": "2016-03-01T00:00:00Z","source": "JOURNAUX","detail": "<center><b>La Gazette économique </b></center><br /><i>Date de décision : </i>19/02/2016<br /><i>La société </i>537643967 - TESTS OPTIMUM, 10 RUE DE LA CLAIRETTE, 34800 PERET <br/><i>Fait l\'objet du départ de </i> Madame Séverine LOPEZ<br/>"}],"commentaries": [{"commentaryText": "Low risk workforce size","positiveOrNegative": "Positive"},{"commentaryText": "Industry code with low risk rating","positiveOrNegative": "Positive"},{"commentaryText": "The company is 8 years old","positiveOrNegative": "Positive"},{"commentaryText": "Region code with medium risk rating","positiveOrNegative": "Neutral"}],"ratingHistory": [{"date": "2020-03-01T00:00:00Z","localRating": "79","commonRating": {"commonValue": "A","commonDescription": "Very Low Risk"},"description2": "Very Good Credit Worthiness"},{"date": "2019-06-28T00:00:00Z","localRating": "78","commonRating": {"commonValue": "A","commonDescription": "Very Low Risk"},"description2": "Very Good Credit Worthiness"},{"date": "2018-09-21T00:00:00Z","localRating": "76","commonRating": {"commonValue": "A","commonDescription": "Very Low Risk"},"description2": "Very Good Credit Worthiness"},{"date": "2017-10-25T00:00:00Z","localRating": "65","commonRating": {"commonValue": "B","commonDescription": "Low Risk"},"description2": "Good Credit Worthiness"},{"date": "2013-07-03T00:00:00Z","localRating": "48","commonRating": {"commonValue": "C","commonDescription": "Moderate Risk"},"description2": "Credit Worthy"}],"branches": [{"companyNumber": "53764396700012","companyName": "TESTS OPTIMUM","lineOfBusiness": "Études de marché et sondages","status": "A","name": "TESTS OPTIMUM","address": {"simpleValue": "10 RUE DE LA CLAIRETTE PERET 34800","street": "10 RUE DE LA CLAIRETTE","city": "PERET","postalCode": "34800"},"distribution": "34800 PERET"}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/FR-X-537643967', creditsafeReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('FR-X-537643967');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: FR-X-537643967', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();

        System.assertEquals('Update Name', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('TESTS OPTIMUM', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('PERET', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

        creditFactoryDataMap.put('street', 'test street');
        creditFactoryDataMap.put('postalStreet', 'test postal street');
        creditFactoryDataMap.put('registeredStreet', 'test registered street');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test empty address validation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmptyAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        cfItem.companiesList.get(0).street = null;

        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);
        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmptyAddress'}, true);
        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test vat number validation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('FR05537643967', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123456789012');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test swift bic validation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSwiftBic() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        Map<String, Object> swiftBicUpdateData = creditFactorySettings.returnSwiftBicUpdateData(internalCompany);

        System.assertEquals('Update SWIFT BIC', swiftBicUpdateData.get('header'));

        Map<String, Object> swiftBicFieldsToUpdate = creditFactory.returnSwiftBicFieldsToUpdate();
        System.assertEquals(true, swiftBicFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('AGRIFRPP', ((Map<String, Object>) swiftBicFieldsToUpdate.get('Opportunity')).get('SWIFT_BIC__c'));

        creditFactoryDataMap.put('requestedSwiftBic', '1234567890');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'SwiftBic'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test mandate type validation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateMandateType() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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

        Map<String, Object> contactRoleFieldsToUpdate = creditFactory.returnCallFieldsToUpdate('12345678');
        System.assertEquals(true, contactRoleFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals(true, ((Map<String, Object>) contactRoleFieldsToUpdate.get('Opportunity')).get('Contact_Role_Confirmation_Call__c') != null);

        for (Map<String, Object> contact : (List<Map<String, Object>>) creditFactoryDataMap.get('creditFactoryContacts')) {
            if (contact.get('relation') == 'AccountContactRelation') {
                contact.put('firstName', 'test first name');
                contact.put('lastName', 'test last name');
                break;
            }
        }

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Contact'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test lost opportunities
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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

        Opportunity lostOpportunity = CreditFactoryTestUtils.generateOpportunityFR();
        lostOpportunity.AccountId = account.Id;
        lostOpportunity.StageName = 'Closed Lost';
        lostOpportunity.Gruende_verloren__c = 'Refused Credit';
        insert lostOpportunity;

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'LostOpportunities'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test email risk validation
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('France');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '15');
        creditFactoryDataMap.put('desiredPaymentTerms', '7');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 7', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 7', cfResult.messagesList.get(1).text);

        Map<String, Object> updateOpportunityFieldsMap = creditFactory.returnUpdateOpportunityFieldsToUpdate();
        System.assertEquals(true, updateOpportunityFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) updateOpportunityFieldsMap.get('Opportunity')).get('Credit_check_date__c'));

        Map<String, Object> closedWonFieldsMap = creditFactory.returnClosedWonFieldsToUpdate();
        System.assertEquals(true, closedWonFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) closedWonFieldsMap.get('Opportunity')).get('CloseDate'));
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Credit_Limit__c = '100';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '15');
        creditFactoryDataMap.put('desiredPaymentTerms', '7');

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(3, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(3, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 3
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '3';
        report.Legal_Form__c = 'Auto entrepreneur';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(70, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 3
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 1200;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Credit_Limit__c = '100';
        report.Class_Rating__c = '3';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '30');
        creditFactoryDataMap.put('desiredPaymentTerms', '7');

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low Recommended CL', cfResult.depositReason);
        System.assertEquals(3, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 5)', cfResult.depositReason);
        System.assertEquals(110, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 04/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('France');

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
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('France');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}