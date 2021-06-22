@IsTest
public class CreditFactoryTestBE {


    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountBE();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityBE();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactBE();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Belgium-NL');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Belgium-NL');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c creditSafeSettings = CreditFactoryTestUtils.generateCreditsafeSetting();
        customSettingsList.add(creditSafeSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Belgium-NL', Index__c = 1.3);
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

        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'BENL');
        insert riskyBusinessCode;

        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsBE();
        insert calculations;
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplBE);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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

        System.assertEquals('TEST SA', company.name);
    }


    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        creditFactorySettings.returnSearchValidations();
    }


    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyBE();
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSepaAttachments() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidatePaymentMethod() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountBE();
        dupAccount.Steuernummer__c = '12344312';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityBE();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactBE();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplBE);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        System.assertEquals('TEST SA', company.name);
    }


    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByTax() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "bc4cd350-fcd0-11ea-82e6-0260e6fc8b9d","totalSize": 1,"companies": [{"id": "BE-X-428089605","country": "BE","regNo": 428089605,"vatNo": ["BE0428089605"],"safeNo": "BE00154869","name": "TEST SA","address": {"simpleValue": "9B , RUE LOUIS RENARD, 4367, CRISNÉE","street": "RUE LOUIS RENARD","city": "CRISNÉE","postCode": "4367","houseNo": "9B"},"status": "active","officeType": "headOffice","dateOfLatestAccounts": "2009-12-31T00:00:00.000000Z","phoneNumbers": ["3219677569"],"activityCode": "46699"}]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=BE&regNo=428089605', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company by all parameters
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByAllParameters() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=BE&regNo=428089605', searchMock);
            SingleRequestMock searchMock2 = new SingleRequestMock(200, 'Complete', '{"correlationId": "bc4cd350-fcd0-11ea-82e6-0260e6fc8b9d","totalSize": 1,"companies": [{"id": "BE-X-428089605","country": "BE","regNo": 428089605,"vatNo": ["BE0428089605"],"safeNo": "BE00154869","name": "TEST SA","address": {"simpleValue": "9B , RUE LOUIS RENARD, 4367, CRISNÉE","street": "RUE LOUIS RENARD","city": "CRISNÉE","postCode": "4367","houseNo": "9B"},"status": "active","officeType": "headOffice","dateOfLatestAccounts": "2009-12-31T00:00:00.000000Z","phoneNumbers": ["3219677569"],"activityCode": "46699"}]}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies?countries=BE&name=TEST%2520SA&city=CRISNÉE&street=RUE%20LOUIS%20RENARD', searchMock2);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
            SingleRequestMock creditsafeReportMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "08639e00-fc9e-11ea-82e6-0260e6fc8b9d","orderId": "N/A","companyId": "BE-X-428089605","dateOfOrder": "2020-09-22T06:37:19.499Z","language": "en","userId": "101495027","report": {"companyId": "BE-X-428089605","language": "EN","companySummary": {"businessName": "TEST SA","country": "BE","companyNumber": "BE00154869","companyRegistrationNumber": "428089605","mainActivity": {"code": "46699","description": "Wholesale of other machines and tools, n.e.c.","classification": "NACEBEL 08"},"companyStatus": {"status": "Pending","description": "COURT ACTION"},"latestShareholdersEquityFigure": {"currency": "EUR","value": 344497.0},"creditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"currency": "EUR","value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - legal event"}},"companyIdentification": {"basicInformation": {"businessName": "TEST SA","registeredCompanyName": "TEST SA","companyRegistrationNumber": "428089605","country": "BE","vatRegistrationNumber": "BE.0428.089.605","companyRegistrationDate": "1985-12-09T00:00:00Z","operationsStartDate": "1985-12-09T00:00:00Z","legalForm": {"description": "Public limited company"},"companyStatus": {"status": "Pending","description": "COURT ACTION"},"principalActivity": {"code": "46699","description": "Wholesale of other machines and tools, n.e.c.","classification": "NACEBEL 08"},"contactAddress": {"simpleValue": "RUE LOUIS RENARD 9B , 4367 CRISNÉE","street": "RUE LOUIS RENARD","houseNumber": "9B","city": "CRISNÉE","postalCode": "4367","telephone": "+3219677569"}},"activityClassifications": [{"classification": "NACEBEL 08","activities": [{"code": "46699","description": "Wholesale of other machines and tools, n.e.c."}]}]},"creditScore": {"currentCreditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"currency": "EUR","value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - legal event"}},"contactInformation": {"mainAddress": {"simpleValue": "RUE LOUIS RENARD 9B , 4367 CRISNÉE","street": "RUE LOUIS RENARD","houseNumber": "9B","city": "CRISNÉE","postalCode": "4367","telephone": "+3219677569","country": "BE"},"otherAddresses": [{"simpleValue": "49 Rue Louis Happart, Crisnée 4367","street": "Rue Louis Happart","houseNumber": "49","city": "Crisnée","postalCode": "4367","country": "BE"}]},"shareCapitalStructure": {"issuedShareCapital": {"value": 80000.0},"shareCapitalCurrency": "EUR","shareHolders": [{"name": "Ghislaine Cerfontaine","address": {"street": "Rue Louis Happart","houseNumber": "49","city": "Crisnée","postalCode": "4367"},"shareholderType": "Other","percentSharesHeld": 70.0},{"name": "Camille Lenaerts","address": {"street": "Rue Louis Happart","houseNumber": "49","city": "Crisnée","postalCode": "4367"},"shareholderType": "Other","percentSharesHeld": 30.0}]},"directors": {"currentDirectors": [{"id": "BE-BE428089605_5","name": "RomanAydogdu","gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2011-05-04T00:00:00Z","positionName": "Trustee (appointed by the courts)","additionalData": {"functionType": "DIRECTOR"}}]},{"id": "BE-BE428089605_4","name": "YvesGodfroid","gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2011-04-29T00:00:00Z","positionName": "Trustee (appointed by the courts)","additionalData": {"functionType": "DIRECTOR"}}]},{"id": "BE-BE428089605_1","name": "GhislaineCerfontaine","address": {"simpleValue": "49 RUE LOUIS HAPPART CRISNÉE, Belgium","street": "49 RUE LOUIS HAPPART CRISNÉE","postalCode": "4367","country": "BE"},"gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2009-12-14T00:00:00Z","positionName": "Director","additionalData": {"functionType": "DIRECTOR"}}]},{"id": "BE-BE428089605_2","name": "GhislaineCerfontaine","address": {"simpleValue": "49 RUE LOUIS HAPPART CRISNÉE, Belgium","street": "49 RUE LOUIS HAPPART CRISNÉE","postalCode": "4367","country": "BE"},"gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2009-12-14T00:00:00Z","positionName": "Person responsible for day-to-day management","additionalData": {"functionType": "DIRECTOR"}}]}],"previousDirectors": [{"resignationDate": "2010-10-05T00:00:00Z","id": "BE-BE428089605_3","name": "SarahLenaerts","address": {"simpleValue": "49 RUE LOUIS HAPPART CRISNÉE, Belgium","street": "49 RUE LOUIS HAPPART CRISNÉE","postalCode": "4367","country": "BE"},"gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2010-01-01T00:00:00Z","positionName": "Director","additionalData": {"functionType": "DIRECTOR"}}]}]},"otherInformation": {"employeesInformation": [{"year": 2009,"numberOfEmployees": "5"},{"year": 2008,"numberOfEmployees": "3"},{"year": 2007,"numberOfEmployees": "3"}]},"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2009-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"operatingProfit": -15180.0,"wagesAndSalaries": 164998.0,"depreciation": 1289.0,"financialIncome": 6217.0,"financialExpenses": 35598.0,"profitBeforeTax": -44561.0,"tax": -30021.0,"profitAfterTax": -14540.0,"otherAppropriations": 0.0,"retainedProfit": -14540.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 3744.0,"totalTangibleAssets": 3744.0,"otherIntangibleAssets": 1480.0,"totalIntangibleAssets": 1480.0,"miscellaneousFixedAssets": 0.0,"totalOtherFixedAssets": 0.0,"totalFixedAssets": 5224.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 296252.0,"totalInventories": 296252.0,"tradeReceivables": 802010.0,"miscellaneousReceivables": 21164.0,"totalReceivables": 823174.0,"cash": 2411.0,"otherCurrentAssets": 790.0,"totalCurrentAssets": 1122627.0,"totalAssets": 1127851.0,"tradePayables": 723239.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 60115.0,"totalCurrentLiabilities": 783354.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 783354.0,"calledUpShareCapital": 80000.0,"sharePremium": 0.0,"revenueReserves": 264497.0,"otherReserves": 0.0,"totalShareholdersEquity": 344497.0},"otherFinancials": {"workingCapital": 339273.0,"netWorth": 343017.0},"ratios": {"returnOnCapitalEmployed": -12.94,"returnOnTotalAssetsEmployed": -3.95,"returnOnNetAssetsEmployed": -12.94,"currentRatio": 1.43,"liquidityRatioOrAcidTest": 1.05,"currentDebtRatio": 2.27,"gearing": 0.0,"equityInPercentage": 30.58,"totalDebtRatio": 2.27}},{"type": "GlobalFinancialsGGS","yearEndDate": "2008-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"operatingProfit": 63859.0,"wagesAndSalaries": 92601.0,"depreciation": 402.0,"financialIncome": 12347.0,"financialExpenses": 37795.0,"profitBeforeTax": 38411.0,"tax": 11404.0,"profitAfterTax": 27007.0,"otherAppropriations": 0.0,"retainedProfit": 27007.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 352.0,"totalTangibleAssets": 352.0,"otherIntangibleAssets": 0.0,"totalIntangibleAssets": 0.0,"miscellaneousFixedAssets": 3859.0,"totalOtherFixedAssets": 3859.0,"totalFixedAssets": 4211.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 231056.0,"totalInventories": 231056.0,"tradeReceivables": 971436.0,"miscellaneousReceivables": 90383.0,"totalReceivables": 1061819.0,"cash": 2190.0,"otherCurrentAssets": 774.0,"totalCurrentAssets": 1295839.0,"totalAssets": 1300050.0,"tradePayables": 827891.0,"otherLoansOrFinance": 85485.0,"miscellaneousLiabilities": 27637.0,"totalCurrentLiabilities": 941013.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": -1.0,"totalLongTermLiabilities": -1.0,"totalLiabilities": 941012.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 309459.0,"otherReserves": 0.0,"totalShareholdersEquity": 359038.0},"otherFinancials": {"workingCapital": 354826.0,"netWorth": 359038.0},"ratios": {"returnOnCapitalEmployed": 10.70,"returnOnTotalAssetsEmployed": 2.95,"returnOnNetAssetsEmployed": 10.70,"currentRatio": 1.38,"liquidityRatioOrAcidTest": 1.13,"currentDebtRatio": 2.62,"gearing": 0.00,"equityInPercentage": 27.62,"totalDebtRatio": 2.62}},{"type": "GlobalFinancialsGGS","yearEndDate": "2007-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"operatingProfit": 70813.0,"wagesAndSalaries": 76237.0,"depreciation": 553.0,"financialIncome": 10059.0,"financialExpenses": 33913.0,"profitBeforeTax": 46959.0,"tax": 148417.0,"profitAfterTax": -101458.0,"otherAppropriations": -3123.0,"retainedProfit": -104581.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 0.0,"totalTangibleAssets": 0.0,"otherIntangibleAssets": 0.0,"totalIntangibleAssets": 0.0,"miscellaneousFixedAssets": 0.0,"totalOtherFixedAssets": 0.0,"totalFixedAssets": 0.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 241592.0,"totalInventories": 241592.0,"tradeReceivables": 758132.0,"miscellaneousReceivables": 81261.0,"totalReceivables": 839393.0,"cash": 39238.0,"otherCurrentAssets": 762.0,"totalCurrentAssets": 1120985.0,"totalAssets": 1120985.0,"tradePayables": 706647.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 82307.0,"totalCurrentLiabilities": 788954.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 788954.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 282452.0,"otherReserves": 0.0,"totalShareholdersEquity": 332031.0},"otherFinancials": {"workingCapital": 332031.0,"netWorth": 332031.0},"ratios": {"returnOnCapitalEmployed": 14.14,"returnOnTotalAssetsEmployed": 4.19,"returnOnNetAssetsEmployed": 14.14,"currentRatio": 1.42,"liquidityRatioOrAcidTest": 1.11,"currentDebtRatio": 2.38,"gearing": 0.0,"equityInPercentage": 29.62,"totalDebtRatio": 2.38}},{"type": "GlobalFinancialsGGS","yearEndDate": "2005-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 1201137.0,"operatingCosts": 1174995.0,"operatingProfit": 26142.0,"wagesAndSalaries": 54273.0,"depreciation": 851.0,"financialIncome": 4265.0,"financialExpenses": -14554.0,"profitBeforeTax": 15853.0,"tax": -17615.0,"profitAfterTax": 33468.0,"otherAppropriations": 0.0,"retainedProfit": 1762.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 0.0,"totalTangibleAssets": 0.0,"otherIntangibleAssets": 1107.0,"totalIntangibleAssets": 1107.0,"miscellaneousFixedAssets": 4283.0,"totalOtherFixedAssets": 4283.0,"totalFixedAssets": 5390.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 21026.0,"totalInventories": 21026.0,"tradeReceivables": 491158.0,"miscellaneousReceivables": 98797.0,"totalReceivables": 589955.0,"cash": 163613.0,"otherCurrentAssets": 200042.0,"totalCurrentAssets": 974636.0,"totalAssets": 980026.0,"tradePayables": 545212.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 21087.0,"totalCurrentLiabilities": 566299.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 566299.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 364148.0,"otherReserves": 0.0,"totalShareholdersEquity": 413727.0},"otherFinancials": {"workingCapital": 408337.0,"netWorth": 412620.0},"ratios": {"preTaxProfitMargin": 1.32,"returnOnCapitalEmployed": 3.83,"returnOnTotalAssetsEmployed": 1.62,"returnOnNetAssetsEmployed": 3.83,"salesOrNetWorkingCapital": 2.94,"stockTurnoverRatio": 1.75,"debtorDays": 149.25,"creditorDays": 165.68,"currentRatio": 1.72,"liquidityRatioOrAcidTest": 1.68,"currentDebtRatio": 1.37,"gearing": 0.0,"equityInPercentage": 42.26,"totalDebtRatio": 1.37}},{"type": "GlobalFinancialsGGS","yearEndDate": "2004-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 1849689.0,"operatingCosts": 1771436.0,"operatingProfit": 78253.0,"wagesAndSalaries": 48295.0,"depreciation": 4508.0,"financialIncome": 8035.0,"financialExpenses": -25032.0,"profitBeforeTax": 61256.0,"tax": -21287.0,"profitAfterTax": 82543.0,"otherAppropriations": 0.0,"retainedProfit": 39969.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 297.0,"totalTangibleAssets": 297.0,"otherIntangibleAssets": 0.0,"totalIntangibleAssets": 0.0,"miscellaneousFixedAssets": 4283.0,"totalOtherFixedAssets": 4283.0,"totalFixedAssets": 4580.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 26057.0,"totalInventories": 26057.0,"tradeReceivables": 712845.0,"miscellaneousReceivables": 129390.0,"totalReceivables": 842235.0,"cash": 74299.0,"otherCurrentAssets": 200042.0,"totalCurrentAssets": 1142633.0,"totalAssets": 1147213.0,"tradePayables": 716310.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 15414.0,"totalCurrentLiabilities": 731724.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 731724.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 365910.0,"otherReserves": 0.0,"totalShareholdersEquity": 415489.0},"otherFinancials": {"workingCapital": 410909.0,"netWorth": 415489.0},"ratios": {"preTaxProfitMargin": 3.31,"returnOnCapitalEmployed": 14.74,"returnOnTotalAssetsEmployed": 5.34,"returnOnNetAssetsEmployed": 14.74,"salesOrNetWorkingCapital": 4.50,"stockTurnoverRatio": 1.41,"debtorDays": 140.67,"creditorDays": 141.35,"currentRatio": 1.56,"liquidityRatioOrAcidTest": 1.53,"currentDebtRatio": 1.76,"gearing": 0.0,"equityInPercentage": 36.22,"totalDebtRatio": 1.76}}],"localFinancialStatements": [{"type": "LocalFinancialsCSBE","yearEndDate": "2009-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"grossOperatingMargin": 210375.0,"employeeCosts": 213281.0,"wagesSalary": 164998.0,"socialSecurityContributions": 35411.0,"otherEmployeeCosts": 12873.0,"amortizationDepreciation": 1289.0,"operatingResult": -15180.0,"financialIncome": 6217.0,"financialCharges": 35598.0,"resultsOnOrdOpBefTax": -44561.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": -44561.0,"taxation": -30021.0,"resultsOnOrdOpAftTax": -14540.0,"netResult": -14540.0,"profitYearAppropriated": -14540.0},"balanceSheet": {"totalFixedAssets": 5224.0,"intangibleFixedAssets": 1480.0,"tangibleFixedAssets": 3744.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 3744.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 0.0,"totalCurrentAssets": 1122627.0,"inventories": 296252.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 296252.0,"tradeDebtors": 802010.0,"otherAmountsReceivable": 21164.0,"cash": 2411.0,"miscellaneousCurrentAssets": 790.0,"totalAssets": 1127851.0,"totalShareholdersEquity": 344497.0,"issuedShareCapital": 80000.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 264497.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 783354.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 723239.0,"taxesRemunAndSocialSecurity": 55614.0,"miscellaneousCurrentLiabilities": 4501.0,"totalCurrentLiabilities": 783354.0,"totalLiabilities": 1127851.0},"otherFinancials": {"cashflow": -13252.0,"netWorth": 343017.0,"workingCapital": 339273.0},"ratios": {"returnonCapitalEmployed": -12.94,"returnonTotalAssetsEmployed": -3.95,"returnonNetAssetsEmployed": -12.94,"currentRatio": 1.43,"liquidityRatioAcidTest": 1.05,"currentDebtRatio": 2.27,"equityinPercentage": 30.58,"totalDebtRatio": 2.27}},{"type": "LocalFinancialsCSBE","yearEndDate": "2008-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"grossOperatingMargin": 187257.0,"employeeCosts": 116866.0,"wagesSalary": 92601.0,"socialSecurityContributions": 20495.0,"otherEmployeeCosts": 3770.0,"amortizationDepreciation": 402.0,"operatingResult": 63859.0,"financialIncome": 12347.0,"financialCharges": 37795.0,"resultsOnOrdOpBefTax": 38411.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": 38411.0,"taxation": 11404.0,"resultsOnOrdOpAftTax": 27007.0,"netResult": 27007.0,"profitYearAppropriated": 27007.0},"balanceSheet": {"totalFixedAssets": 4211.0,"intangibleFixedAssets": 0.0,"tangibleFixedAssets": 352.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 352.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 3859.0,"totalCurrentAssets": 1295839.0,"inventories": 231056.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 231056.0,"tradeDebtors": 971436.0,"otherAmountsReceivable": 90383.0,"cash": 2190.0,"miscellaneousCurrentAssets": 774.0,"totalAssets": 1300050.0,"totalShareholdersEquity": 359038.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 309459.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 941013.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": -1.0,"totalLongTermDebts": -1.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 85485.0,"tradeCreditors": 827891.0,"taxesRemunAndSocialSecurity": 27637.0,"miscellaneousCurrentLiabilities": 0.0,"totalCurrentLiabilities": 941013.0,"totalLiabilities": 1300050.0},"otherFinancials": {"cashflow": 27409.0,"netWorth": 359038.0,"workingCapital": 354826.0},"ratios": {"returnonCapitalEmployed": 10.70,"returnonTotalAssetsEmployed": 2.95,"returnonNetAssetsEmployed": 10.70,"currentRatio": 1.38,"liquidityRatioAcidTest": 1.13,"currentDebtRatio": 2.62,"gearing": 23.81,"equityinPercentage": 27.62,"totalDebtRatio": 2.62}},{"type": "LocalFinancialsCSBE","yearEndDate": "2007-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"grossOperatingMargin": 168057.0,"employeeCosts": 93927.0,"wagesSalary": 76237.0,"socialSecurityContributions": 14714.0,"otherEmployeeCosts": 2976.0,"amortizationDepreciation": 553.0,"operatingResult": 70813.0,"financialIncome": 10059.0,"financialCharges": 33913.0,"resultsOnOrdOpBefTax": 46959.0,"extraordinaryCharges": 3123.0,"extraordinaryItems": -3123.0,"resultsYearBeforeTax": 43836.0,"taxation": 148417.0,"resultsOnOrdOpAftTax": -101458.0,"netResult": -104581.0,"profitYearAppropriated": -104581.0},"balanceSheet": {"totalFixedAssets": 0.0,"intangibleFixedAssets": 0.0,"tangibleFixedAssets": 0.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 0.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 0.0,"totalCurrentAssets": 1120985.0,"inventories": 241592.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 241592.0,"tradeDebtors": 758132.0,"otherAmountsReceivable": 81261.0,"cash": 39238.0,"miscellaneousCurrentAssets": 762.0,"totalAssets": 1120985.0,"totalShareholdersEquity": 332031.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 282452.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 788954.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 706647.0,"taxesRemunAndSocialSecurity": 78588.0,"miscellaneousCurrentLiabilities": 3719.0,"totalCurrentLiabilities": 788954.0,"totalLiabilities": 1120985.0},"otherFinancials": {"cashflow": -104028.0,"netWorth": 332031.0,"workingCapital": 332031.0},"ratios": {"returnonCapitalEmployed": 14.14,"returnonTotalAssetsEmployed": 4.19,"returnonNetAssetsEmployed": 14.14,"currentRatio": 1.42,"liquidityRatioAcidTest": 1.11,"currentDebtRatio": 2.38,"equityinPercentage": 29.62,"totalDebtRatio": 2.38}},{"type": "LocalFinancialsCSBE","yearEndDate": "2005-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"turnover": 1201137.0,"totalOperatingExpenses": 1174995.0,"grossOperatingMargin": 93900.0,"employeeCosts": 63941.0,"wagesSalary": 54273.0,"socialSecurityContributions": 7944.0,"otherEmployeeCosts": 1724.0,"amortizationDepreciation": 851.0,"operatingResult": 26142.0,"financialIncome": 4265.0,"financialCharges": -14554.0,"resultsOnOrdOpBefTax": 15853.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": 15853.0,"taxation": -17615.0,"resultsOnOrdOpAftTax": 33468.0,"netResult": 1762.0},"balanceSheet": {"totalFixedAssets": 5390.0,"intangibleFixedAssets": 1107.0,"tangibleFixedAssets": 0.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 0.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 4283.0,"totalCurrentAssets": 974636.0,"inventories": 21026.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 21026.0,"tradeDebtors": 491158.0,"otherAmountsReceivable": 98797.0,"cash": 163613.0,"miscellaneousCurrentAssets": 200042.0,"totalAssets": 980026.0,"totalShareholdersEquity": 413727.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 364148.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 566299.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 545212.0,"taxesRemunAndSocialSecurity": 21087.0,"miscellaneousCurrentLiabilities": 0.0,"totalCurrentLiabilities": 566299.0,"totalLiabilities": 980026.0},"otherFinancials": {"cashflow": 2613.0,"netWorth": 412620.0,"workingCapital": 408337.0},"ratios": {"preTaxProfitMargin": 1.32,"returnonCapitalEmployed": 3.83,"returnonTotalAssetsEmployed": 1.62,"returnonNetAssetsEmployed": 3.83,"salesNetWorkingCapital": 2.94,"stockTurnoverRatio": 1.75,"creditorDays": 169.36,"debtorDays": 149.25,"currentRatio": 1.72,"liquidityRatioAcidTest": 1.68,"currentDebtRatio": 1.37,"equityinPercentage": 42.26,"totalDebtRatio": 1.37}},{"type": "LocalFinancialsCSBE","yearEndDate": "2004-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"turnover": 1849689.0,"totalOperatingExpenses": 1771436.0,"grossOperatingMargin": 145351.0,"employeeCosts": 58041.0,"wagesSalary": 48295.0,"socialSecurityContributions": 5393.0,"otherEmployeeCosts": 4353.0,"amortizationDepreciation": 4508.0,"operatingResult": 78253.0,"financialIncome": 8035.0,"financialCharges": -25032.0,"resultsOnOrdOpBefTax": 61256.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": 61256.0,"taxation": -21287.0,"resultsOnOrdOpAftTax": 82543.0,"netResult": 39969.0,"profitYearAppropriated": 39969.0},"balanceSheet": {"totalFixedAssets": 4580.0,"intangibleFixedAssets": 0.0,"tangibleFixedAssets": 297.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 0.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 297.0,"financialFixedAssets": 4283.0,"totalCurrentAssets": 1142633.0,"inventories": 26057.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 26057.0,"tradeDebtors": 712845.0,"otherAmountsReceivable": 129390.0,"cash": 74299.0,"miscellaneousCurrentAssets": 200042.0,"totalAssets": 1147213.0,"totalShareholdersEquity": 415489.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 365910.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 731724.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 716310.0,"taxesRemunAndSocialSecurity": 15414.0,"miscellaneousCurrentLiabilities": 0.0,"totalCurrentLiabilities": 731724.0,"totalLiabilities": 1147213.0},"otherFinancials": {"cashflow": 44477.0,"netWorth": 415489.0,"workingCapital": 410909.0},"ratios": {"preTaxProfitMargin": 3.31,"returnonCapitalEmployed": 14.74,"returnonTotalAssetsEmployed": 5.34,"returnonNetAssetsEmployed": 14.74,"salesNetWorkingCapital": 4.50,"stockTurnoverRatio": 1.41,"creditorDays": 147.59,"debtorDays": 140.67,"currentRatio": 1.56,"liquidityRatioAcidTest": 1.53,"currentDebtRatio": 1.76,"equityinPercentage": 36.22,"totalDebtRatio": 1.76}}],"negativeInformation": {"companyLegalEvents": [{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","thirdPartyName": "Godfroid","thirdPartyAddress": "Rue Charles Morren 4 Liège 4000","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","thirdPartyName": "Test","thirdPartyAddress": "Rue Louis Renard 9B CrisnÚe 4367","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyName": "Test","thirdPartyAddress": "Rue Louis Renard, 9 B Thys 4367","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyName": "Godfroid, Yves","thirdPartyAddress": "Rue des Augustins, 32 Liège 4000","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","legalEventSubType": "Verification of Claims","eventDate": "2011-04-29T00:00:00","secondaryEventDate": "2011-06-09T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","legalEventSubType": "Production of Claims","eventDate": "2011-04-29T00:00:00","secondaryEventDate": "2011-06-09T00:00:00","courtType": "Commercial Court","courtName": "Luik","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","legalEventSubType": "Production of Claims","eventDate": "2011-04-29T00:00:00","secondaryEventDate": "2011-05-29T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyType": "Receiver"}]},"additionalInformation": {"misc": {"faxNumber": "019/678551","mobileNumber": "+32477721253","liableForVat": "true","negativeRating": "-997","courtDataFlag": 1,"summonsFlag": 0,"protestedBillsFlag": 0,"branchUnitNumber": 2028323844,"nssoPersonnelClassification": "FROM 5 TO 9 EMPLOYEES"},"industryQuartileAnalysis": {"paymentExpectationDays": {"paymentExpectationsLower": "88.91","paymentExpectationsMedian": "48.93","paymentExpectationsUpper": "26.81"},"daySalesOutstanding": {"daySalesOutstandingLower": "112.24","daySalesOutstandingMedian": "73.88","daySalesOutstandingUpper": "51.08"}},"industryComparison": {"activityCode": "46699","activityDescription": "Wholesale of other machines and tools, n.e.c.","industryAverageDaySalesOutstanding": "163.33","industryAveragePaymentExpectationDays": "154.54","industryAverageCreditRating": "70.84","industryAverageCreditLimit": "75132.01","industryAverageCreditLimitCurrency": "EUR"},"jointIndustrialCommittee": [{"jicCode": "218","description": "Additional national joint committee for the employees"}],"companySignificantEvents": [{"eventDate": "2013-01-23T00:00:00","eventDescription": "no longer subject to VAT tax"},{"eventDate": "2013-01-23T00:00:00","eventDescription": "no longer subject to VAT tax"},{"eventDate": "2011-05-25T00:00:00","eventDescription": "documents referred to VAT Office"},{"eventDate": "2011-05-25T00:00:00","eventDescription": "documents referred to VAT Office"},{"eventDate": "2011-04-29T00:00:00","eventDescription": "Initiation of bankruptcy proceedings"}],"socialBalanceSheet": {"reportingYearEnd": "2009-12-31T00:00:00Z","currency": "EUR","fullTimeEmployees": 5,"partTimeEmployees": 1,"totalFteEmployees": 5,"hoursWorkedFTEmployees": 7794,"hoursWorkedPTEmployees": 418,"hoursWorkedTotal": 8212,"personnelChargesFTEmployees": 202426,"personnelChargesPTEmployees": 10857,"personnelChargesTotal": 213282,"prevYearAverageNumberOfEmployees": 3,"prevYearActualWorkingHours": 4850,"prevYearPersonnelCharges": 116866,"unlimitedDurationContractsFT": 5,"unlimitedDurationContractsPT": 1,"unlimitedDurationContractsTotalFte": 6,"menSecondaryEducationFT": 3,"menSecondaryEducationTotalFte": 3,"womenSecondaryEducationFT": 2,"womenSecondaryEducationPT": 1,"womenSecondaryEducationTotalFte": 3,"whiteCollarWorkerFT": 5,"whiteCollarWorkerPT": 1,"whiteCollarWorkerTotalFte": 6,"newStartersFT": 2,"newStartersPT": 2,"leaversPT": 1,"newStartersTotalFte": 4,"leaversTotalFte": 1},"individualShareholders": [{"forename": "Ghislaine","surname": "Cerfontaine","startDate": "2010-10-21T00:00:00Z","percentageOwned": 70.0,"streetName": "Rue Louis Happart","postalTown": "Crisnée","postalCode": "4367","houseNumber": "49","country": "Belgium"},{"forename": "Camille","surname": "Lenaerts","startDate": "2010-10-21T00:00:00Z","percentageOwned": 30.0,"streetName": "Rue Louis Happart","postalTown": "Crisnée","postalCode": "4367","houseNumber": "49","country": "Belgium"}],"branches": [{"status": "Active","branchUnitNumber": "2028323844","startDate": "1985-12-01T00:00:00Z","address": "Rue Louis Happart 49 4367 Crisnée"}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/BE-X-428089605', creditsafeReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            creditFactory.requestStartReportsCheck('BE-X-428089605');
            reportsItem = creditFactory.requestCompanyReports('BE-X-428089605');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('TEST SA', reportsItem.companiesList.get(0).name);
        System.assertEquals('5', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('No credit rating', reportsItem.companiesList.get(0).solvencyIndex);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportFieldsToUpdate();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('TEST SA', reportsList.get(0).Name);
        System.assertEquals(5, reportEmployeesList.size());
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Opportunity'));
        System.assertEquals('5', ((Map<String, Object>) fieldsToUpdateMap.get('Opportunity')).get('Credit_System_Rating__c'));
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Account'));
        System.assertEquals('46699', ((Map<String, Object>) fieldsToUpdateMap.get('Account')).get('Branchencode__c'));
    }


    /*******************************************************************************
    *  Summary         : test response from Creditsafe with API error
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditsafeApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
            SingleRequestMock creditsafeReportMock = new SingleRequestMock(200, 'Complete', '{"correlationId": "08639e00-fc9e-11ea-82e6-0260e6fc8b9d","orderId": "N/A","companyId": "BE-X-428089605","dateOfOrder": "2020-09-22T06:37:19.499Z","language": "en","userId": "101495027","report": {"companyId": "BE-X-428089605","language": "EN","companySummary": {"businessName": "TEST SA","country": "BE","companyNumber": "BE00154869","companyRegistrationNumber": "428089605","mainActivity": {"code": "46699","description": "Wholesale of other machines and tools, n.e.c.","classification": "NACEBEL 08"},"companyStatus": {"status": "Pending","description": "COURT ACTION"},"latestShareholdersEquityFigure": {"currency": "EUR","value": 344497.0},"creditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"currency": "EUR","value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - legal event"}},"companyIdentification": {"basicInformation": {"businessName": "TEST SA","registeredCompanyName": "TEST SA","companyRegistrationNumber": "428089605","country": "BE","vatRegistrationNumber": "BE.0428.089.605","companyRegistrationDate": "1985-12-09T00:00:00Z","operationsStartDate": "1985-12-09T00:00:00Z","legalForm": {"description": "Public limited company"},"companyStatus": {"status": "Pending","description": "COURT ACTION"},"principalActivity": {"code": "46699","description": "Wholesale of other machines and tools, n.e.c.","classification": "NACEBEL 08"},"contactAddress": {"simpleValue": "RUE LOUIS RENARD 9B , 4367 CRISNÉE","street": "RUE LOUIS RENARD","houseNumber": "9B","city": "CRISNÉE","postalCode": "4367","telephone": "+3219677569"}},"activityClassifications": [{"classification": "NACEBEL 08","activities": [{"code": "46699","description": "Wholesale of other machines and tools, n.e.c."}]}]},"creditScore": {"currentCreditRating": {"commonValue": "E","commonDescription": "Not Rated","creditLimit": {"currency": "EUR","value": "No credit limit"},"providerValue": {"maxValue": "100","minValue": "0","value": "No credit rating"},"providerDescription": "no rating - legal event"}},"contactInformation": {"mainAddress": {"simpleValue": "RUE LOUIS RENARD 9B , 4367 CRISNÉE","street": "RUE LOUIS RENARD","houseNumber": "9B","city": "CRISNÉE","postalCode": "4367","telephone": "+3219677569","country": "BE"},"otherAddresses": [{"simpleValue": "49 Rue Louis Happart, Crisnée 4367","street": "Rue Louis Happart","houseNumber": "49","city": "Crisnée","postalCode": "4367","country": "BE"}]},"shareCapitalStructure": {"issuedShareCapital": {"value": 80000.0},"shareCapitalCurrency": "EUR","shareHolders": [{"name": "Ghislaine Cerfontaine","address": {"street": "Rue Louis Happart","houseNumber": "49","city": "Crisnée","postalCode": "4367"},"shareholderType": "Other","percentSharesHeld": 70.0},{"name": "Camille Lenaerts","address": {"street": "Rue Louis Happart","houseNumber": "49","city": "Crisnée","postalCode": "4367"},"shareholderType": "Other","percentSharesHeld": 30.0}]},"directors": {"currentDirectors": [{"id": "BE-BE428089605_5","name": "RomanAydogdu","gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2011-05-04T00:00:00Z","positionName": "Trustee (appointed by the courts)","additionalData": {"functionType": "DIRECTOR"}}]},{"id": "BE-BE428089605_4","name": "YvesGodfroid","gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2011-04-29T00:00:00Z","positionName": "Trustee (appointed by the courts)","additionalData": {"functionType": "DIRECTOR"}}]},{"id": "BE-BE428089605_1","name": "GhislaineCerfontaine","address": {"simpleValue": "49 RUE LOUIS HAPPART CRISNÉE, Belgium","street": "49 RUE LOUIS HAPPART CRISNÉE","postalCode": "4367","country": "BE"},"gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2009-12-14T00:00:00Z","positionName": "Director","additionalData": {"functionType": "DIRECTOR"}}]},{"id": "BE-BE428089605_2","name": "GhislaineCerfontaine","address": {"simpleValue": "49 RUE LOUIS HAPPART CRISNÉE, Belgium","street": "49 RUE LOUIS HAPPART CRISNÉE","postalCode": "4367","country": "BE"},"gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2009-12-14T00:00:00Z","positionName": "Person responsible for day-to-day management","additionalData": {"functionType": "DIRECTOR"}}]}],"previousDirectors": [{"resignationDate": "2010-10-05T00:00:00Z","id": "BE-BE428089605_3","name": "SarahLenaerts","address": {"simpleValue": "49 RUE LOUIS HAPPART CRISNÉE, Belgium","street": "49 RUE LOUIS HAPPART CRISNÉE","postalCode": "4367","country": "BE"},"gender": "Unknown","directorType": "Other","positions": [{"dateAppointed": "2010-01-01T00:00:00Z","positionName": "Director","additionalData": {"functionType": "DIRECTOR"}}]}]},"otherInformation": {"employeesInformation": [{"year": 2009,"numberOfEmployees": "5"},{"year": 2008,"numberOfEmployees": "3"},{"year": 2007,"numberOfEmployees": "3"}]},"financialStatements": [{"type": "GlobalFinancialsGGS","yearEndDate": "2009-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"operatingProfit": -15180.0,"wagesAndSalaries": 164998.0,"depreciation": 1289.0,"financialIncome": 6217.0,"financialExpenses": 35598.0,"profitBeforeTax": -44561.0,"tax": -30021.0,"profitAfterTax": -14540.0,"otherAppropriations": 0.0,"retainedProfit": -14540.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 3744.0,"totalTangibleAssets": 3744.0,"otherIntangibleAssets": 1480.0,"totalIntangibleAssets": 1480.0,"miscellaneousFixedAssets": 0.0,"totalOtherFixedAssets": 0.0,"totalFixedAssets": 5224.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 296252.0,"totalInventories": 296252.0,"tradeReceivables": 802010.0,"miscellaneousReceivables": 21164.0,"totalReceivables": 823174.0,"cash": 2411.0,"otherCurrentAssets": 790.0,"totalCurrentAssets": 1122627.0,"totalAssets": 1127851.0,"tradePayables": 723239.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 60115.0,"totalCurrentLiabilities": 783354.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 783354.0,"calledUpShareCapital": 80000.0,"sharePremium": 0.0,"revenueReserves": 264497.0,"otherReserves": 0.0,"totalShareholdersEquity": 344497.0},"otherFinancials": {"workingCapital": 339273.0,"netWorth": 343017.0},"ratios": {"returnOnCapitalEmployed": -12.94,"returnOnTotalAssetsEmployed": -3.95,"returnOnNetAssetsEmployed": -12.94,"currentRatio": 1.43,"liquidityRatioOrAcidTest": 1.05,"currentDebtRatio": 2.27,"gearing": 0.0,"equityInPercentage": 30.58,"totalDebtRatio": 2.27}},{"type": "GlobalFinancialsGGS","yearEndDate": "2008-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"operatingProfit": 63859.0,"wagesAndSalaries": 92601.0,"depreciation": 402.0,"financialIncome": 12347.0,"financialExpenses": 37795.0,"profitBeforeTax": 38411.0,"tax": 11404.0,"profitAfterTax": 27007.0,"otherAppropriations": 0.0,"retainedProfit": 27007.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 352.0,"totalTangibleAssets": 352.0,"otherIntangibleAssets": 0.0,"totalIntangibleAssets": 0.0,"miscellaneousFixedAssets": 3859.0,"totalOtherFixedAssets": 3859.0,"totalFixedAssets": 4211.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 231056.0,"totalInventories": 231056.0,"tradeReceivables": 971436.0,"miscellaneousReceivables": 90383.0,"totalReceivables": 1061819.0,"cash": 2190.0,"otherCurrentAssets": 774.0,"totalCurrentAssets": 1295839.0,"totalAssets": 1300050.0,"tradePayables": 827891.0,"otherLoansOrFinance": 85485.0,"miscellaneousLiabilities": 27637.0,"totalCurrentLiabilities": 941013.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": -1.0,"totalLongTermLiabilities": -1.0,"totalLiabilities": 941012.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 309459.0,"otherReserves": 0.0,"totalShareholdersEquity": 359038.0},"otherFinancials": {"workingCapital": 354826.0,"netWorth": 359038.0},"ratios": {"returnOnCapitalEmployed": 10.70,"returnOnTotalAssetsEmployed": 2.95,"returnOnNetAssetsEmployed": 10.70,"currentRatio": 1.38,"liquidityRatioOrAcidTest": 1.13,"currentDebtRatio": 2.62,"gearing": 0.00,"equityInPercentage": 27.62,"totalDebtRatio": 2.62}},{"type": "GlobalFinancialsGGS","yearEndDate": "2007-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"operatingProfit": 70813.0,"wagesAndSalaries": 76237.0,"depreciation": 553.0,"financialIncome": 10059.0,"financialExpenses": 33913.0,"profitBeforeTax": 46959.0,"tax": 148417.0,"profitAfterTax": -101458.0,"otherAppropriations": -3123.0,"retainedProfit": -104581.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 0.0,"totalTangibleAssets": 0.0,"otherIntangibleAssets": 0.0,"totalIntangibleAssets": 0.0,"miscellaneousFixedAssets": 0.0,"totalOtherFixedAssets": 0.0,"totalFixedAssets": 0.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 241592.0,"totalInventories": 241592.0,"tradeReceivables": 758132.0,"miscellaneousReceivables": 81261.0,"totalReceivables": 839393.0,"cash": 39238.0,"otherCurrentAssets": 762.0,"totalCurrentAssets": 1120985.0,"totalAssets": 1120985.0,"tradePayables": 706647.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 82307.0,"totalCurrentLiabilities": 788954.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 788954.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 282452.0,"otherReserves": 0.0,"totalShareholdersEquity": 332031.0},"otherFinancials": {"workingCapital": 332031.0,"netWorth": 332031.0},"ratios": {"returnOnCapitalEmployed": 14.14,"returnOnTotalAssetsEmployed": 4.19,"returnOnNetAssetsEmployed": 14.14,"currentRatio": 1.42,"liquidityRatioOrAcidTest": 1.11,"currentDebtRatio": 2.38,"gearing": 0.0,"equityInPercentage": 29.62,"totalDebtRatio": 2.38}},{"type": "GlobalFinancialsGGS","yearEndDate": "2005-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 1201137.0,"operatingCosts": 1174995.0,"operatingProfit": 26142.0,"wagesAndSalaries": 54273.0,"depreciation": 851.0,"financialIncome": 4265.0,"financialExpenses": -14554.0,"profitBeforeTax": 15853.0,"tax": -17615.0,"profitAfterTax": 33468.0,"otherAppropriations": 0.0,"retainedProfit": 1762.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 0.0,"totalTangibleAssets": 0.0,"otherIntangibleAssets": 1107.0,"totalIntangibleAssets": 1107.0,"miscellaneousFixedAssets": 4283.0,"totalOtherFixedAssets": 4283.0,"totalFixedAssets": 5390.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 21026.0,"totalInventories": 21026.0,"tradeReceivables": 491158.0,"miscellaneousReceivables": 98797.0,"totalReceivables": 589955.0,"cash": 163613.0,"otherCurrentAssets": 200042.0,"totalCurrentAssets": 974636.0,"totalAssets": 980026.0,"tradePayables": 545212.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 21087.0,"totalCurrentLiabilities": 566299.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 566299.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 364148.0,"otherReserves": 0.0,"totalShareholdersEquity": 413727.0},"otherFinancials": {"workingCapital": 408337.0,"netWorth": 412620.0},"ratios": {"preTaxProfitMargin": 1.32,"returnOnCapitalEmployed": 3.83,"returnOnTotalAssetsEmployed": 1.62,"returnOnNetAssetsEmployed": 3.83,"salesOrNetWorkingCapital": 2.94,"stockTurnoverRatio": 1.75,"debtorDays": 149.25,"creditorDays": 165.68,"currentRatio": 1.72,"liquidityRatioOrAcidTest": 1.68,"currentDebtRatio": 1.37,"gearing": 0.0,"equityInPercentage": 42.26,"totalDebtRatio": 1.37}},{"type": "GlobalFinancialsGGS","yearEndDate": "2004-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"revenue": 1849689.0,"operatingCosts": 1771436.0,"operatingProfit": 78253.0,"wagesAndSalaries": 48295.0,"depreciation": 4508.0,"financialIncome": 8035.0,"financialExpenses": -25032.0,"profitBeforeTax": 61256.0,"tax": -21287.0,"profitAfterTax": 82543.0,"otherAppropriations": 0.0,"retainedProfit": 39969.0},"balanceSheet": {"landAndBuildings": 0.0,"plantAndMachinery": 0.0,"otherTangibleAssets": 297.0,"totalTangibleAssets": 297.0,"otherIntangibleAssets": 0.0,"totalIntangibleAssets": 0.0,"miscellaneousFixedAssets": 4283.0,"totalOtherFixedAssets": 4283.0,"totalFixedAssets": 4580.0,"rawMaterials": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherInventories": 26057.0,"totalInventories": 26057.0,"tradeReceivables": 712845.0,"miscellaneousReceivables": 129390.0,"totalReceivables": 842235.0,"cash": 74299.0,"otherCurrentAssets": 200042.0,"totalCurrentAssets": 1142633.0,"totalAssets": 1147213.0,"tradePayables": 716310.0,"otherLoansOrFinance": 0.0,"miscellaneousLiabilities": 15414.0,"totalCurrentLiabilities": 731724.0,"otherLoansOrFinanceDueAfter1Year": 0.0,"miscellaneousLiabilitiesDueAfter1Year": 0.0,"totalLongTermLiabilities": 0.0,"totalLiabilities": 731724.0,"calledUpShareCapital": 49579.0,"sharePremium": 0.0,"revenueReserves": 365910.0,"otherReserves": 0.0,"totalShareholdersEquity": 415489.0},"otherFinancials": {"workingCapital": 410909.0,"netWorth": 415489.0},"ratios": {"preTaxProfitMargin": 3.31,"returnOnCapitalEmployed": 14.74,"returnOnTotalAssetsEmployed": 5.34,"returnOnNetAssetsEmployed": 14.74,"salesOrNetWorkingCapital": 4.50,"stockTurnoverRatio": 1.41,"debtorDays": 140.67,"creditorDays": 141.35,"currentRatio": 1.56,"liquidityRatioOrAcidTest": 1.53,"currentDebtRatio": 1.76,"gearing": 0.0,"equityInPercentage": 36.22,"totalDebtRatio": 1.76}}],"localFinancialStatements": [{"type": "LocalFinancialsCSBE","yearEndDate": "2009-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"grossOperatingMargin": 210375.0,"employeeCosts": 213281.0,"wagesSalary": 164998.0,"socialSecurityContributions": 35411.0,"otherEmployeeCosts": 12873.0,"amortizationDepreciation": 1289.0,"operatingResult": -15180.0,"financialIncome": 6217.0,"financialCharges": 35598.0,"resultsOnOrdOpBefTax": -44561.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": -44561.0,"taxation": -30021.0,"resultsOnOrdOpAftTax": -14540.0,"netResult": -14540.0,"profitYearAppropriated": -14540.0},"balanceSheet": {"totalFixedAssets": 5224.0,"intangibleFixedAssets": 1480.0,"tangibleFixedAssets": 3744.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 3744.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 0.0,"totalCurrentAssets": 1122627.0,"inventories": 296252.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 296252.0,"tradeDebtors": 802010.0,"otherAmountsReceivable": 21164.0,"cash": 2411.0,"miscellaneousCurrentAssets": 790.0,"totalAssets": 1127851.0,"totalShareholdersEquity": 344497.0,"issuedShareCapital": 80000.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 264497.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 783354.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 723239.0,"taxesRemunAndSocialSecurity": 55614.0,"miscellaneousCurrentLiabilities": 4501.0,"totalCurrentLiabilities": 783354.0,"totalLiabilities": 1127851.0},"otherFinancials": {"cashflow": -13252.0,"netWorth": 343017.0,"workingCapital": 339273.0},"ratios": {"returnonCapitalEmployed": -12.94,"returnonTotalAssetsEmployed": -3.95,"returnonNetAssetsEmployed": -12.94,"currentRatio": 1.43,"liquidityRatioAcidTest": 1.05,"currentDebtRatio": 2.27,"equityinPercentage": 30.58,"totalDebtRatio": 2.27}},{"type": "LocalFinancialsCSBE","yearEndDate": "2008-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"grossOperatingMargin": 187257.0,"employeeCosts": 116866.0,"wagesSalary": 92601.0,"socialSecurityContributions": 20495.0,"otherEmployeeCosts": 3770.0,"amortizationDepreciation": 402.0,"operatingResult": 63859.0,"financialIncome": 12347.0,"financialCharges": 37795.0,"resultsOnOrdOpBefTax": 38411.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": 38411.0,"taxation": 11404.0,"resultsOnOrdOpAftTax": 27007.0,"netResult": 27007.0,"profitYearAppropriated": 27007.0},"balanceSheet": {"totalFixedAssets": 4211.0,"intangibleFixedAssets": 0.0,"tangibleFixedAssets": 352.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 352.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 3859.0,"totalCurrentAssets": 1295839.0,"inventories": 231056.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 231056.0,"tradeDebtors": 971436.0,"otherAmountsReceivable": 90383.0,"cash": 2190.0,"miscellaneousCurrentAssets": 774.0,"totalAssets": 1300050.0,"totalShareholdersEquity": 359038.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 309459.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 941013.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": -1.0,"totalLongTermDebts": -1.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 85485.0,"tradeCreditors": 827891.0,"taxesRemunAndSocialSecurity": 27637.0,"miscellaneousCurrentLiabilities": 0.0,"totalCurrentLiabilities": 941013.0,"totalLiabilities": 1300050.0},"otherFinancials": {"cashflow": 27409.0,"netWorth": 359038.0,"workingCapital": 354826.0},"ratios": {"returnonCapitalEmployed": 10.70,"returnonTotalAssetsEmployed": 2.95,"returnonNetAssetsEmployed": 10.70,"currentRatio": 1.38,"liquidityRatioAcidTest": 1.13,"currentDebtRatio": 2.62,"gearing": 23.81,"equityinPercentage": 27.62,"totalDebtRatio": 2.62}},{"type": "LocalFinancialsCSBE","yearEndDate": "2007-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"grossOperatingMargin": 168057.0,"employeeCosts": 93927.0,"wagesSalary": 76237.0,"socialSecurityContributions": 14714.0,"otherEmployeeCosts": 2976.0,"amortizationDepreciation": 553.0,"operatingResult": 70813.0,"financialIncome": 10059.0,"financialCharges": 33913.0,"resultsOnOrdOpBefTax": 46959.0,"extraordinaryCharges": 3123.0,"extraordinaryItems": -3123.0,"resultsYearBeforeTax": 43836.0,"taxation": 148417.0,"resultsOnOrdOpAftTax": -101458.0,"netResult": -104581.0,"profitYearAppropriated": -104581.0},"balanceSheet": {"totalFixedAssets": 0.0,"intangibleFixedAssets": 0.0,"tangibleFixedAssets": 0.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 0.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 0.0,"totalCurrentAssets": 1120985.0,"inventories": 241592.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 241592.0,"tradeDebtors": 758132.0,"otherAmountsReceivable": 81261.0,"cash": 39238.0,"miscellaneousCurrentAssets": 762.0,"totalAssets": 1120985.0,"totalShareholdersEquity": 332031.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 282452.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 788954.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 706647.0,"taxesRemunAndSocialSecurity": 78588.0,"miscellaneousCurrentLiabilities": 3719.0,"totalCurrentLiabilities": 788954.0,"totalLiabilities": 1120985.0},"otherFinancials": {"cashflow": -104028.0,"netWorth": 332031.0,"workingCapital": 332031.0},"ratios": {"returnonCapitalEmployed": 14.14,"returnonTotalAssetsEmployed": 4.19,"returnonNetAssetsEmployed": 14.14,"currentRatio": 1.42,"liquidityRatioAcidTest": 1.11,"currentDebtRatio": 2.38,"equityinPercentage": 29.62,"totalDebtRatio": 2.38}},{"type": "LocalFinancialsCSBE","yearEndDate": "2005-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"turnover": 1201137.0,"totalOperatingExpenses": 1174995.0,"grossOperatingMargin": 93900.0,"employeeCosts": 63941.0,"wagesSalary": 54273.0,"socialSecurityContributions": 7944.0,"otherEmployeeCosts": 1724.0,"amortizationDepreciation": 851.0,"operatingResult": 26142.0,"financialIncome": 4265.0,"financialCharges": -14554.0,"resultsOnOrdOpBefTax": 15853.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": 15853.0,"taxation": -17615.0,"resultsOnOrdOpAftTax": 33468.0,"netResult": 1762.0},"balanceSheet": {"totalFixedAssets": 5390.0,"intangibleFixedAssets": 1107.0,"tangibleFixedAssets": 0.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 0.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 0.0,"financialFixedAssets": 4283.0,"totalCurrentAssets": 974636.0,"inventories": 21026.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 21026.0,"tradeDebtors": 491158.0,"otherAmountsReceivable": 98797.0,"cash": 163613.0,"miscellaneousCurrentAssets": 200042.0,"totalAssets": 980026.0,"totalShareholdersEquity": 413727.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 364148.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 566299.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 545212.0,"taxesRemunAndSocialSecurity": 21087.0,"miscellaneousCurrentLiabilities": 0.0,"totalCurrentLiabilities": 566299.0,"totalLiabilities": 980026.0},"otherFinancials": {"cashflow": 2613.0,"netWorth": 412620.0,"workingCapital": 408337.0},"ratios": {"preTaxProfitMargin": 1.32,"returnonCapitalEmployed": 3.83,"returnonTotalAssetsEmployed": 1.62,"returnonNetAssetsEmployed": 3.83,"salesNetWorkingCapital": 2.94,"stockTurnoverRatio": 1.75,"creditorDays": 169.36,"debtorDays": 149.25,"currentRatio": 1.72,"liquidityRatioAcidTest": 1.68,"currentDebtRatio": 1.37,"equityinPercentage": 42.26,"totalDebtRatio": 1.37}},{"type": "LocalFinancialsCSBE","yearEndDate": "2004-12-31T00:00:00Z","numberOfWeeks": 52,"currency": "EUR","profitAndLoss": {"turnover": 1849689.0,"totalOperatingExpenses": 1771436.0,"grossOperatingMargin": 145351.0,"employeeCosts": 58041.0,"wagesSalary": 48295.0,"socialSecurityContributions": 5393.0,"otherEmployeeCosts": 4353.0,"amortizationDepreciation": 4508.0,"operatingResult": 78253.0,"financialIncome": 8035.0,"financialCharges": -25032.0,"resultsOnOrdOpBefTax": 61256.0,"extraordinaryItems": 0.0,"resultsYearBeforeTax": 61256.0,"taxation": -21287.0,"resultsOnOrdOpAftTax": 82543.0,"netResult": 39969.0,"profitYearAppropriated": 39969.0},"balanceSheet": {"totalFixedAssets": 4580.0,"intangibleFixedAssets": 0.0,"tangibleFixedAssets": 297.0,"landAndBuilding": 0.0,"plantAndMachinery": 0.0,"furnitureAndVehicles": 0.0,"leasingAndOtherSimilarRights": 0.0,"otherTangibleAssets": 297.0,"financialFixedAssets": 4283.0,"totalCurrentAssets": 1142633.0,"inventories": 26057.0,"rawMaterialsAndConsumables": 0.0,"workInProgress": 0.0,"finishedGoods": 0.0,"otherStocks": 26057.0,"tradeDebtors": 712845.0,"otherAmountsReceivable": 129390.0,"cash": 74299.0,"miscellaneousCurrentAssets": 200042.0,"totalAssets": 1147213.0,"totalShareholdersEquity": 415489.0,"issuedShareCapital": 49579.0,"sharePremiumAccount": 0.0,"revaluationReserve": 0.0,"reserves": 365910.0,"provisionsForLiabsAndCharges": 0.0,"deferredTaxes": 0.0,"creditors": 731724.0,"otherLongTermLoans": 0.0,"otherLongTermLiabilities": 0.0,"totalLongTermDebts": 0.0,"currentPortionLongTermDebt": 0.0,"financialDebts": 0.0,"tradeCreditors": 716310.0,"taxesRemunAndSocialSecurity": 15414.0,"miscellaneousCurrentLiabilities": 0.0,"totalCurrentLiabilities": 731724.0,"totalLiabilities": 1147213.0},"otherFinancials": {"cashflow": 44477.0,"netWorth": 415489.0,"workingCapital": 410909.0},"ratios": {"preTaxProfitMargin": 3.31,"returnonCapitalEmployed": 14.74,"returnonTotalAssetsEmployed": 5.34,"returnonNetAssetsEmployed": 14.74,"salesNetWorkingCapital": 4.50,"stockTurnoverRatio": 1.41,"creditorDays": 147.59,"debtorDays": 140.67,"currentRatio": 1.56,"liquidityRatioAcidTest": 1.53,"currentDebtRatio": 1.76,"equityinPercentage": 36.22,"totalDebtRatio": 1.76}}],"negativeInformation": {"companyLegalEvents": [{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","thirdPartyName": "Godfroid","thirdPartyAddress": "Rue Charles Morren 4 Liège 4000","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","thirdPartyName": "Test","thirdPartyAddress": "Rue Louis Renard 9B CrisnÚe 4367","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyName": "Test","thirdPartyAddress": "Rue Louis Renard, 9 B Thys 4367","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","eventDate": "2011-04-29T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyName": "Godfroid, Yves","thirdPartyAddress": "Rue des Augustins, 32 Liège 4000","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","legalEventSubType": "Verification of Claims","eventDate": "2011-04-29T00:00:00","secondaryEventDate": "2011-06-09T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","legalEventSubType": "Production of Claims","eventDate": "2011-04-29T00:00:00","secondaryEventDate": "2011-06-09T00:00:00","courtType": "Commercial Court","courtName": "Luik","thirdPartyType": "Receiver"},{"legalEventType": "Initiation of bankruptcy proceedings","legalEventSubType": "Production of Claims","eventDate": "2011-04-29T00:00:00","secondaryEventDate": "2011-05-29T00:00:00","courtType": "Commercial Court","courtName": "Liège","registryBodyIdentifier": "136","thirdPartyType": "Receiver"}]},"additionalInformation": {"misc": {"faxNumber": "019/678551","mobileNumber": "+32477721253","liableForVat": "true","negativeRating": "-997","courtDataFlag": 1,"summonsFlag": 0,"protestedBillsFlag": 0,"branchUnitNumber": 2028323844,"nssoPersonnelClassification": "FROM 5 TO 9 EMPLOYEES"},"industryQuartileAnalysis": {"paymentExpectationDays": {"paymentExpectationsLower": "88.91","paymentExpectationsMedian": "48.93","paymentExpectationsUpper": "26.81"},"daySalesOutstanding": {"daySalesOutstandingLower": "112.24","daySalesOutstandingMedian": "73.88","daySalesOutstandingUpper": "51.08"}},"industryComparison": {"activityCode": "46699","activityDescription": "Wholesale of other machines and tools, n.e.c.","industryAverageDaySalesOutstanding": "163.33","industryAveragePaymentExpectationDays": "154.54","industryAverageCreditRating": "70.84","industryAverageCreditLimit": "75132.01","industryAverageCreditLimitCurrency": "EUR"},"jointIndustrialCommittee": [{"jicCode": "218","description": "Additional national joint committee for the employees"}],"companySignificantEvents": [{"eventDate": "2013-01-23T00:00:00","eventDescription": "no longer subject to VAT tax"},{"eventDate": "2013-01-23T00:00:00","eventDescription": "no longer subject to VAT tax"},{"eventDate": "2011-05-25T00:00:00","eventDescription": "documents referred to VAT Office"},{"eventDate": "2011-05-25T00:00:00","eventDescription": "documents referred to VAT Office"},{"eventDate": "2011-04-29T00:00:00","eventDescription": "Initiation of bankruptcy proceedings"}],"socialBalanceSheet": {"reportingYearEnd": "2009-12-31T00:00:00Z","currency": "EUR","fullTimeEmployees": 5,"partTimeEmployees": 1,"totalFteEmployees": 5,"hoursWorkedFTEmployees": 7794,"hoursWorkedPTEmployees": 418,"hoursWorkedTotal": 8212,"personnelChargesFTEmployees": 202426,"personnelChargesPTEmployees": 10857,"personnelChargesTotal": 213282,"prevYearAverageNumberOfEmployees": 3,"prevYearActualWorkingHours": 4850,"prevYearPersonnelCharges": 116866,"unlimitedDurationContractsFT": 5,"unlimitedDurationContractsPT": 1,"unlimitedDurationContractsTotalFte": 6,"menSecondaryEducationFT": 3,"menSecondaryEducationTotalFte": 3,"womenSecondaryEducationFT": 2,"womenSecondaryEducationPT": 1,"womenSecondaryEducationTotalFte": 3,"whiteCollarWorkerFT": 5,"whiteCollarWorkerPT": 1,"whiteCollarWorkerTotalFte": 6,"newStartersFT": 2,"newStartersPT": 2,"leaversPT": 1,"newStartersTotalFte": 4,"leaversTotalFte": 1},"individualShareholders": [{"forename": "Ghislaine","surname": "Cerfontaine","startDate": "2010-10-21T00:00:00Z","percentageOwned": 70.0,"streetName": "Rue Louis Happart","postalTown": "Crisnée","postalCode": "4367","houseNumber": "49","country": "Belgium"},{"forename": "Camille","surname": "Lenaerts","startDate": "2010-10-21T00:00:00Z","percentageOwned": 30.0,"streetName": "Rue Louis Happart","postalTown": "Crisnée","postalCode": "4367","houseNumber": "49","country": "Belgium"}],"branches": [{"status": "Active","branchUnitNumber": "2028323844","startDate": "1985-12-01T00:00:00Z","address": "Rue Louis Happart 49 4367 Crisnée"}]}}}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/BE-X-428089605', creditsafeReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('BE-X-428089605');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: BE-X-428089605', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();

        System.assertEquals('Update Name', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('TEST SA', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('CRISNÉE', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

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
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('BE.0428.089.605', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test swift bic validation
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSwiftBic() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateMandateType() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
        creditFactoryDataMap.put('totalConsumption', 999);
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
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
    *  Summary         : test lost opportunities
    *  Created         : 22/09/2020 by Anton
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Belgium-NL');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 22/09/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '1';
        update report;

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 7', cfResult.messagesList.get(1).text);

        Map<String, Object> updateOpportunityFieldsMap = creditFactory.returnUpdateOpportunityFieldsToUpdate();
        System.assertEquals(true, updateOpportunityFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) updateOpportunityFieldsMap.get('Opportunity')).get('Credit_check_date__c'));

        Map<String, Object> closedWonFieldsMap = creditFactory.returnClosedWonFieldsToUpdate();
        System.assertEquals(true, closedWonFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) closedWonFieldsMap.get('Opportunity')).get('CloseDate'));
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 22/09/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '1';
        report.Date_of_Foundation__c = String.valueOf(Date.today().year()) + '-01-01';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('totalConsumption', 300);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low Recommended CL', cfResult.depositReason);
        System.assertEquals(3, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 5)', cfResult.depositReason);
        System.assertEquals(110, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Belgium-NL');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Belgium-NL');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}