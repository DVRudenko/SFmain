@IsTest
public class CreditFactoryTestHU {


    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountHU();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityHU();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactHU();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Hungary');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Hungary');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c creditSafeSettings = CreditFactoryTestUtils.generateCofaceSetting();
        customSettingsList.add(creditSafeSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Hungary', Index__c = 350);
        customSettingsList.add(fuelPrice);
        CF_Order_Notifications__c orderNotification = CreditFactoryTestUtils.createOrderNotificationHU();
        customSettingsList.add(orderNotification);
        insert customSettingsList;

        dsfs__DocuSign_Status__c docuSignStatus = CreditFactoryTestUtils.generateDocuSignStatusHU();
        docuSignStatus.dsfs__Opportunity__c = opportunity.Id;
        insert docuSignStatus;

        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = CreditFactoryTestUtils.generateDocuSignRecipientHU();
        docuSignRecipient.dsfs__Parent_Status_Record__c = docuSignStatus.Id;
        insert docuSignRecipient;

        Tankkarten__c card = CreditFactoryTestUtils.generateTankkarten();
        card.Opportunity__c = opportunity.Id;
        insert card;

        Product2 product2 = CreditFactoryTestUtils.generateProduct2();
        insert product2;

        PricebookEntry pricebookEntry = CreditFactoryTestUtils.generatePricebookEntry();
        pricebookEntry.Product2Id = product2.Id;
        pricebookEntry.CurrencyIsoCode = 'HUF';
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

        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'HU');
        insert riskyBusinessCode;

        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsHU();
        insert calculations;
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplHU);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

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

        System.assertEquals('HILD INGATLANBEFEKTETŐ KFT.', company.name);
    }


    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        creditFactorySettings.returnSearchValidations();
    }


    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

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
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyHU();
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

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
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

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
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

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
    *  Summary         : test number of cards
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateUnavailableReport() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'UnavailableReport'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('cfStage', 'Credit Report not available');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'UnavailableReport'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test number of cards
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateOrder() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Order'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('cfStage', 'Pending Credit Report - Order was sent');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Order'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test searching duplicates
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountHU();
        dupAccount.Steuernummer__c = '12344312';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityHU();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactHU();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplHU);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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

        System.assertEquals('HILD INGATLANBEFEKTETŐ KFT.', company.name);
    }


    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByTax() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><searchByIdentifierResponse xmlns="http://www.iconx.biz/webservices"><searchByIdentifierResult><ResponseCode>OK</ResponseCode><ResponseText>OK</ResponseText><SearchResults><SearchResult><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><Identifiers><CompanyIdentifier><Type>0</Type><Description>NationalID</Description><Identifier>13373344</Identifier></CompanyIdentifier><CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier></CompanyIdentifier><CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier></CompanyIdentifier><CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier></CompanyIdentifier></Identifiers><RegistrationCountry>HU</RegistrationCountry><Address><Country>HU</Country><ZipCode>1054</ZipCode><City>Budapest</City><AddressItem1>Széchenyi utca 1</AddressItem1></Address><RegisteredAddress/></SearchResult></SearchResults></searchByIdentifierResult></searchByIdentifierResponse></soap:Body></soap:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company by all parameters
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByAllParameters() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><searchByIdentifierResponse xmlns="http://www.iconx.biz/webservices"><searchByIdentifierResult><ResponseCode>NotFound</ResponseCode><ResponseText>No company found</ResponseText></searchByIdentifierResult></searchByIdentifierResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<web:searchByIdentifier>', searchMock);
            SingleRequestMock searchMock2 = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><searchByNameAndAddressResponse xmlns="http://www.iconx.biz/webservices"><searchByNameAndAddressResult><ResponseCode>TooManyResults</ResponseCode><ResponseText>2 companies found</ResponseText><SearchResults><SearchResult><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><Identifiers><CompanyIdentifier><Type>0</Type><Description>NationalID</Description><Identifier>13373344</Identifier></CompanyIdentifier><CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier></CompanyIdentifier><CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier></CompanyIdentifier><CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier></CompanyIdentifier></Identifiers><RegistrationCountry>HU</RegistrationCountry><Address><Country>HU</Country><ZipCode>1054</ZipCode><City>Budapest</City><AddressItem1>Széchenyi utca 1</AddressItem1></Address><RegisteredAddress/></SearchResult></SearchResults></searchByNameAndAddressResult></searchByNameAndAddressResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<web:searchByNameAndAddress>', searchMock2);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for ordering report
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestOrder() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);

        System.assertEquals('13373344', orderItem.orderReferenceNumber);
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
            SingleRequestMock cofaceAvailabilityMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><getCompanyDetailsResponse xmlns="http://www.iconx.biz/webservices"><getCompanyDetailsResult><ResponseCode>OK</ResponseCode><ResponseText>OK</ResponseText><CompanyDetails><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress><Country>HU</Country><ZipCode>1036</ZipCode><City>Budapest</City><AddressItem1>Lajos utca 74-76.</AddressItem1><Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number></Telephone><Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number></Fax></PrincipalAddress><RegisteredAddress/><LegalForm><LegalFormCode>300</LegalFormCode><LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers><CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier></CompanyIdentifier><CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier></CompanyIdentifier><CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier></CompanyIdentifier><CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier></CompanyIdentifier></Identifiers><Activities><Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription></Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><AvailableProducts><Product><Code>12</Code><Description>Credit Analysis Report</Description><Availability>AvailableImmediately</Availability></Product><Product><Code>761</Code><Description>AUTOMATIC CREDIT REPORT</Description><Availability>AvailableImmediately</Availability></Product><Product><Code>5000</Code><Description>Portfolio Watch</Description><Availability>AvailableImmediately</Availability></Product></AvailableProducts></CompanyDetails></getCompanyDetailsResult></getCompanyDetailsResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<web:getCompanyDetails>', cofaceAvailabilityMock);
            SingleRequestMock cofaceReportMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body> <immediateOrderResponse xmlns="http://www.iconx.biz/webservices"><immediateOrderResult> <ResponseCode>OK</ResponseCode> <ResponseText>OK</ResponseText> <OrderStatus><ProviderOrderReference>2771334</ProviderOrderReference><ProductCode>761</ProductCode><Provider><PartyID>CIC_HU</PartyID><Name>Coface Hungary Credit Management Services Kft.</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><Email>orders-hungary@coface.com</Email><WebAddress>http://www.coface.hu</WebAddress></Provider><Consumer><Name>FleetCor Hungary Korlátolt Felelősségű Társaság</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><WebAddress>fleetcor.hu</WebAddress></Consumer><OriginalRequest><Name></Name><PrincipalAddress> <ZipCode></ZipCode> <AddressItem1></AddressItem1></PrincipalAddress><DateOfValidity>0001-01-01T00:00:00.0+01:00</DateOfValidity><DateOfLastUpdate>0001-01-01T00:00:00.0+01:00</DateOfLastUpdate><DateOfLastBalanceSheet>0001-01-01T00:00:00.0+01:00</DateOfLastBalanceSheet></OriginalRequest><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress> <Country>HU</Country> <ZipCode>1036</ZipCode> <City>Budapest</City> <AddressItem1>Lajos utca 74-76.</AddressItem1> <Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number> </Telephone> <Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number> </Fax></PrincipalAddress><RegisteredAddress></RegisteredAddress><LegalForm> <LegalFormCode>300</LegalFormCode> <LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers> <CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier> </CompanyIdentifier></Identifiers><Activities> <Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription> </Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><ReportLanguage>EN</ReportLanguage><StatusCode>Finished</StatusCode><Ordered>2018-03-07T14:46:16.000+01:00</Ordered><RequestedDelivery>2018-03-07T15:46:00.000+01:00</RequestedDelivery><Delivered>2018-03-07T14:46:17.000+01:00</Delivered><MaximumCreditRecommendationAmount>-1.0</MaximumCreditRecommendationAmount><CompanyRegistrationDate>0001-01-01T00:00:00.0+01:00</CompanyRegistrationDate><ReportMimeType>text/xml</ReportMimeType> </OrderStatus> <Report><ProviderOrderReference>2771334</ProviderOrderReference><ProductCode>761</ProductCode><Provider><PartyID>CIC_HU</PartyID><Name>Coface Hungary Credit Management Services Kft.</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><Email>orders-hungary@coface.com</Email><WebAddress>http://www.coface.hu</WebAddress></Provider><Consumer><Name>FleetCor Hungary Korlátolt Felelősségű Társaság</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><WebAddress>fleetcor.hu</WebAddress></Consumer><OriginalRequest><Name></Name><PrincipalAddress> <ZipCode></ZipCode> <AddressItem1></AddressItem1></PrincipalAddress><DateOfValidity>0001-01-01T00:00:00.0+01:00</DateOfValidity><DateOfLastUpdate>0001-01-01T00:00:00.0+01:00</DateOfLastUpdate><DateOfLastBalanceSheet>0001-01-01T00:00:00.0+01:00</DateOfLastBalanceSheet></OriginalRequest><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress> <Country>HU</Country> <ZipCode>1036</ZipCode> <City>Budapest</City> <AddressItem1>Lajos utca 74-76.</AddressItem1> <Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number> </Telephone> <Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number> </Fax></PrincipalAddress><RegisteredAddress></RegisteredAddress><LegalForm> <LegalFormCode>300</LegalFormCode> <LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers> <CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier> </CompanyIdentifier></Identifiers><Activities> <Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription> </Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><ReportLanguage>EN</ReportLanguage><StatusCode>Finished</StatusCode><Ordered>2018-03-07T14:46:16.000+01:00</Ordered><RequestedDelivery>2018-03-07T15:46:00.000+01:00</RequestedDelivery><Delivered>2018-03-07T14:46:17.000+01:00</Delivered><MaximumCreditRecommendationAmount>-1.0</MaximumCreditRecommendationAmount><CompanyRegistrationDate>0001-01-01T00:00:00.0+01:00</CompanyRegistrationDate><ReportMimeType>text/xml</ReportMimeType><ReportXML><ICON VERSION="2.0.0" xmlns:ns2="http://www.iconx.biz/webservices"> <ORDERSTATUS><INTERCREDITORDERNUMBER>2771334</INTERCREDITORDERNUMBER><PROVIDER> <PROVIDERID>2</PROVIDERID> <NAME>Coface Hungary Credit Management Services Kft.</NAME> <SENDERID>IC02</SENDERID> <CITY>Budapest</CITY> <COUNTRY VALUE="HU">Hungary</COUNTRY> <STREET>Váci út</STREET> <HOUSENUMBER>45. H. ép. 7.</HOUSENUMBER> <ZIPCODE>1134</ZIPCODE></PROVIDER><CUSTOMER> <CUSTOMERID>106157832</CUSTOMERID> <NAME>FleetCor Hungary Korlátolt Felelősségű Társaság</NAME> <RECIPIENTID></RECIPIENTID> <CITY>Budapest</CITY> <COUNTRY VALUE="HU">Hungary</COUNTRY> <STREET>Andrássy út</STREET> <HOUSENUMBER>100.</HOUSENUMBER> <ZIPCODE>1062</ZIPCODE></CUSTOMER><CUSTOMERSREFERENCE></CUSTOMERSREFERENCE><PURCHASEORDERNUMBER></PURCHASEORDERNUMBER><LANGUAGE VALUE="2">English</LANGUAGE><PRODUCT VALUE="9997">AUTOMATIC CREDIT REPORT</PRODUCT><REPORTMIMETYPE>TEXT/XML</REPORTMIMETYPE><BALANCESHEETLAYOUT VALUE="31">Full BS Hungary</BALANCESHEETLAYOUT><TIMESTAMP>20180307144616</TIMESTAMP><STATUS VALUE="10">Finished</STATUS><REQUIREDBY>20180307154600</REQUIREDBY><GIVENCOMPANYNAME></GIVENCOMPANYNAME><REQUESTEDCOMPANYINFORMATION> <COMPANYNAME></COMPANYNAME> <REGISTRATIONCOUNTRY></REGISTRATIONCOUNTRY> <ZIPCODE></ZIPCODE> <CITY></CITY> <STREET></STREET> <HOUSENUMBER></HOUSENUMBER> <ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE> <COUNTRY></COUNTRY> <TELEPHONAREACODE></TELEPHONAREACODE> <TELEPHONENUMBER></TELEPHONENUMBER> <NATIONALNUMBER></NATIONALNUMBER></REQUESTEDCOMPANYINFORMATION><QUESTION></QUESTION><ANSWER></ANSWER> </ORDERSTATUS> <CREDITREPORT><COMPANY> <COPYRIGHT>Coface Hungary Credit Management Services Kft.</COPYRIGHT> <INTERCREDITNUMBER>69590780</INTERCREDITNUMBER> <NATIONALID>13373344</NATIONALID> <STATUS VALUE="0">Active</STATUS> <COMPANYNAME>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</COMPANYNAME> <SORTNAME>Hild Ingatlanbefektető Kft.</SORTNAME> <INTERNATIONALNAME>Hild Real Estate Investments Limited Liability Company</INTERNATIONALNAME> <EASYNUMBER>00003123942472</EASYNUMBER> <SHORTNAME></SHORTNAME> <LEGALFORM VALUE="300">Limited Liability Company</LEGALFORM> <REGISTRATION><NUMBER>0109731931</NUMBER><CITY>Budapest</CITY><COUNTRY>HU</COUNTRY><COUNTRYREGION></COUNTRYREGION><DATE>20041215</DATE> </REGISTRATION> <COMPANYCOMMENT></COMPANYCOMMENT> <HISTORY></HISTORY> <TAXNUMBER>123123123</TAXNUMBER> <STATISTICALNUMBER></STATISTICALNUMBER> <VATNUMBER><TYPE VALUE="120">VAT number</TYPE><VALUE>13373344-2-41</VALUE> </VATNUMBER> <VALIDITYDATE>20170117</VALIDITYDATE> <LASTMAJORUPDATE>' + Date.today().year() + '0619</LASTMAJORUPDATE> <ESTABLISHED>20040927</ESTABLISHED> <CAPITAL><INDICATOR><TYPE VALUE="5305">Subscribed capital</TYPE><DATE>20041215</DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>3000000.0000</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY VALUE="HUF">Hungarian Forint</CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE></INDICATOR> </CAPITAL> <NATIONALCURRENCY VALUE="HUF">Hungarian Forint</NATIONALCURRENCY> <ALIASES><ALIAS>Hild Ingatlanbefektető Kft.</ALIAS> </ALIASES> <ADDRESSES><ADDRESS><ADDRESSTYPE VALUE="1">Principal Address</ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Lajos utca</STREET><HOUSENUMBER>74-76.</HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>1036</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><COUNTRYREGION VALUE="HU-BU">Budapest</COUNTRYREGION><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA>1</AREA> <NUMBER>8875600</NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA>1</AREA> <NUMBER>8875601</NUMBER></FAX><EMAIL>info@hild.hu</EMAIL><INTERNET>www.hild.hu</INTERNET></ADDRESS><ADDRESS><ADDRESSTYPE VALUE="50">Former Principal Address</ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Kelenhegyi út 29/b</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE>15.12.2004 - 12.12.2005</ADDITIONALADDRESSLINE><ZIPCODE>1118</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><COMMENT></COMMENT> </ADDRESSES></COMPANY><MANAGEMENT> <MANAGER><TYPE VALUE="200">Managing director</TYPE><NAME>BIRÓ Balázs Tibor</NAME><ADDRESS><ADDRESSTYPE VALUE="40"></ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Dayka Gábor utca 92.</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>1112</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><ACTIVESINCE>20150301</ACTIVESINCE><ACTIVEUNTIL></ACTIVEUNTIL><EQUITYAMOUNT></EQUITYAMOUNT><EQUITYCURRENCY></EQUITYCURRENCY><EQUITYDIMENSION></EQUITYDIMENSION><COMMENT>Önálló képviselet/Individual signature</COMMENT> </MANAGER> <MANAGER><TYPE VALUE="409">Auditor</TYPE><NAME>BDO Magyarország Könyvvizsgáló Korlátolt Felelősségű Társaság</NAME><ADDRESS><ADDRESSTYPE VALUE="1">Principal Address</ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Kőér utca 2/A. C. ép.</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>1103</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><COUNTRYREGION VALUE="HU-BU">Budapest</COUNTRYREGION><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><ACTIVESINCE>20130111</ACTIVESINCE><ACTIVEUNTIL></ACTIVEUNTIL><EQUITYAMOUNT></EQUITYAMOUNT><EQUITYCURRENCY></EQUITYCURRENCY><EQUITYDIMENSION></EQUITYDIMENSION><INTERCREDITNUMBER>73579100</INTERCREDITNUMBER><REGISTRATIONCOUNTRY VALUE="HU">Hungary</REGISTRATIONCOUNTRY><REGISTRATIONPLACE>Budapest</REGISTRATIONPLACE><REGISTRATIONDATE>20060413</REGISTRATIONDATE><REGISTRATIONNUMBER>0109867785</REGISTRATIONNUMBER><COMPANYSTATUS><TYPE VALUE="1">Registration status</TYPE><STATUS VALUE="20">Registered company</STATUS><VALIDSINCE>20060209</VALIDSINCE><COMMENT></COMMENT></COMPANYSTATUS> </MANAGER> <MANAGER><TYPE VALUE="409">Auditor</TYPE><NAME>NAGYNÉ Zagyva Zsuzsanna</NAME><ADDRESS><ADDRESSTYPE VALUE="40"></ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Fenyőfa utca 77.</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>2030</ZIPCODE><CITY>Érd</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><ACTIVESINCE>20130111</ACTIVESINCE><ACTIVEUNTIL></ACTIVEUNTIL><EQUITYAMOUNT></EQUITYAMOUNT><EQUITYCURRENCY></EQUITYCURRENCY><EQUITYDIMENSION></EQUITYDIMENSION> </MANAGER> <COMMENTS></COMMENTS></MANAGEMENT><AUTHORITY></AUTHORITY><ACTIVITIES> <ACTIVITY><PRIORITY>2</PRIORITY><NACECODE>7022</NACECODE><NACETEXT>Business and other management consultancy activities</NACETEXT><LOCALACTIVITYCODE></LOCALACTIVITYCODE><LOCALACTIVITYTEXT></LOCALACTIVITYTEXT> </ACTIVITY> <COMMENT></COMMENT></ACTIVITIES><ADDITIONALBALANCESHEETS> <ADDITIONALBALANCESHEET NAME="Key Financial Data" TYPE="638"><BALANCESHEETITEM><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>111.6874</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>105.1162</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>170.8787</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>221.3836</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>51.09</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>0.4663</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>0.8384</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>37.5703</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>110.6585</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>110.7786</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>103.7505</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>106.8135</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-0.8681</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>6.4416</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>3.036</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-8.2146</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-0.6591</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>13.9851</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>3.8521</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-10.5722</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR></BALANCESHEETITEM> </ADDITIONALBALANCESHEET></ADDITIONALBALANCESHEETS><WORKFORCE> <INDICATOR><TYPE VALUE="11">Total workforce</TYPE><DATE>20171006</DATE><FROMDATE>20171006</FROMDATE><TODATE>20171006</TODATE><FROMAMOUNT>2</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY></CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE> </INDICATOR> <INDICATOR><TYPE VALUE="11">Total workforce</TYPE><DATE>20120000</DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>3</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY></CURRENCY><DIMENSION VALUE="0">Blank</DIMENSION><MEASURE></MEASURE> </INDICATOR> <INDICATOR><TYPE VALUE="11">Total workforce</TYPE><DATE>20110000</DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>4</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY></CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE> </INDICATOR></WORKFORCE><MAXIMUMCREDIT> <INDICATOR><TYPE VALUE="20">Maximum credit</TYPE><DATE></DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>782000</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY VALUE="HUF">Hungarian Forint</CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE><COMMENT>Due to the company’s limited scope of activities, an amount of EUR 2.500 is considered as the Maximum Credit.</COMMENT> </INDICATOR> <COMMENT></COMMENT></MAXIMUMCREDIT><CCEATRATING><SCORE VALUE="1"></SCORE><DATE></DATE><COMMENT/></CCEATRATING><CUSTOMERSPECIFICMAXCREDITS> <CUSTOMERSPECIFICMAXCREDIT><TYPE VALUE="50">Quick Rate</TYPE><CSMAXCREDITVALUE>1</CSMAXCREDITVALUE><CSMAXCREDITCURRENCY></CSMAXCREDITCURRENCY><CSMAXCREDITCODE VALUE="2">Medium High Risk</CSMAXCREDITCODE> </CUSTOMERSPECIFICMAXCREDIT></CUSTOMERSPECIFICMAXCREDITS><STATUSLIST> <COMPANYSTATUS><TYPE VALUE="1">Registration status</TYPE><STATUS VALUE="20">Registered company</STATUS><VALIDSINCE>20041215</VALIDSINCE><COMMENT></COMMENT> </COMPANYSTATUS> <COMPANYSTATUS><TYPE VALUE="2">Activity status</TYPE><STATUS VALUE="10">Active company</STATUS><VALIDSINCE>20040927</VALIDSINCE><COMMENT></COMMENT> </COMPANYSTATUS></STATUSLIST><COUNTRYINDICATORS></COUNTRYINDICATORS><UNSTRUCTURED>AUTOMATIC CREDIT REPORT \n\n-------------------------------------------------------------------------------\n (c) Coface Hungary Credit Management Services Kft.\n email: orders-hungary@coface.com\n 07.03.2018 14:46()\n\n-------------------------------------------------------------------------------\n\n\n\nORDER DETAILS\n\n-------------------------------------------------------------------------------\nOrder Details: Customer: FleetCor Hungary Korlatolt Felelossegu Tarsasag\n\n \nOrder number: 2771334\nDelivery speed: Immediate\nLanguage: English\n\n\n-------------------------------------------------------------------------------\n\n\n\nCOMPANY\n\n-------------------------------------------------------------------------------\nHILD INGATLANBEFEKTETO KORLATOLT FELELOSSEGU TARSASAG\nInternational Name: Hild Real Estate Investments Limited\nLiability Company\nAliases: Hild Ingatlanbefekteto Kft.\n\nPrincipal Address:\nLajos utca 74-76\n1036 Budapest\nBudapest\nHungary\nTelephone: +36-1-8875600\nFax: +36-1-8875601\nEmail: info@hild.hu\nWeb: www.hild.hu\n\n-------------------------------------------------------------------------------\n\nICON number: 69590780\nEasy number: 00003123942472\nNational ID: 13373344\nInternational VAT number: HU13373344\nVAT number: 13373344-2-41\n\n-------------------------------------------------------------------------------\n\nStatus: Registration status: 15.12.2004 - Registered company\nActivity status: 27.09.2004 - Active company\n\n\n-------------------------------------------------------------------------------\n\nDate of Last17.01.2017\nResearch:\n\n-------------------------------------------------------------------------------\n\nDate of Last Major19.06.2017\nUpdate: \n\n-------------------------------------------------------------------------------\n\n\n\nCREDIT INFORMATION\n\n-------------------------------------------------------------------------------\nRecommended Maximum EUR 2.500 (HUF 782.000)\nCredit: Due to the company’s limited scope of activities, an\namount of EUR 2.500 is considered as the Maximum Credit.\n\nMaximum Credit is to be understood as the highest\npossible engagement for a supplier delivering goods or\nrendering services on open terms with an average of 60\ndays. The calculation is based on the assumption that, on\nthe average, the company in question has 5 suppliers\nwhich deliver goods or render services at the same time.\n\n-------------------------------------------------------------------------------\n\nQuick Rate: Quick Rate: Medium High Risk\n\n-------------------------------------------------------------------------------\n\n\n\nKEY DATA ON OPERATIONS\n\n-------------------------------------------------------------------------------\nActivity status: 27.09.2004 - Active company\n\n-------------------------------------------------------------------------------\n\nActivities: NACE\n 7022 Business and other management consultancy\nactivities\n\n\n\nThe company is active in the Coface sector \'Business and\npersonal services\'.\n\n-------------------------------------------------------------------------------\n\nWorkforce: 06.10.2017\nTotal workforce: 2\n\n2012\nTotal workforce: 3\n\n2011\nTotal workforce: 4\n\n\n-------------------------------------------------------------------------------\n\n\n\nCOMPANY DETAILS\n\n-------------------------------------------------------------------------------\nRegistration: No. 0109731931\n\n15.12.2004\nBudapest, Hungary\n\n-------------------------------------------------------------------------------\n\nLegal Form: 15.12.2004\nLimited Liability Company\n\n-------------------------------------------------------------------------------\n\nManagement: BIRO Balazs Tibor - Managing director (signature right)\nNationality: HU\nDayka Gabor utca 92\n1112 Budapest\nHungary\n\n\nsince 01.03.2015\n\nOEnallo kepviselet/Individual signature\nBDO Magyarorszag Koenyvvizsgalo Korlatolt Felelossegu\nTarsasag - Auditor\nRegistration: No. 0109867785, 13.04.2006, Budapest,\nHungary\n1103 Budapest, Koer utca 2/A. C. ep. \nsince 11.01.2013\n\nNAGYNE Zagyva Zsuzsanna - Auditor\nNationality: HU\nFenyofa utca 77\n2030 Erd\nHungary\n\n\nsince 11.01.2013\n\n\n-------------------------------------------------------------------------------\n\n\n\n\nFINANCIAL INFORMATION\n\n-------------------------------------------------------------------------------\nKey Financial Data:\nAmounts shown in Euro (EUR) Thousand\n ' + Date.today().addYears(-1).year() + Date.today().addYears(-2).year() + Date.today().addYears(-3).year() + '\nNet sales revenue 100,00 100,00 100,00\nFixed assets 51,09 0,47 0,84\nOwner\'s equity 110,66 110,78 103,75\nNet result of the year-0,87 6,44 3,04\nOperating result 100,00 100,00 100,00\n The bookkeeping period of this company is not different from the Hungarian\nstandard\n\n\n \n-------------------------------------------------------------------------------\n\nApproximate 2017: 310,14 HUF = 1 EUR\nExchange Rates:2016: 311,02 HUF = 1 EUR\n2015: 313,12 HUF = 1 EUR\n2014: 314,89 HUF = 1 EUR\n2013: 296,91 HUF = 1 EUR\n2012: 291,29 HUF = 1 EUR\n2011: 311,13 HUF = 1 EUR\n2017: 258,82 HUF = 1 USD\n2016: 293,69 HUF = 1 USD\n2015: 286,63 HUF = 1 USD\n2014: 259,13 HUF = 1 USD\n2013: 215,67 HUF = 1 USD\n2012: 220,93 HUF = 1 USD\n2011: 240,68 HUF = 1 USD\n\n-------------------------------------------------------------------------------\n\nFinancial Comments: The bookkeeping period of this company is not different\nfrom the Hungarian standard\n\n-------------------------------------------------------------------------------\n\nThe information and/or data provided are subject to the general terms and\nconditions or individual contract terms and may be used only for the purpose\nthey have been requested for.\nThe above shown figures was stipulated accordingly to the official Companies\nGazette (Cegkoezloeny) or any other accessed official sources.\n\nCoface Hungary \nCredit Management Services Kft.\nH-1094 Budapest, \nTuezolto utca 57.\nHungary\nwww.coface.hu\n\n*** End of document ***</UNSTRUCTURED> </CREDITREPORT></ICON></ReportXML> </Report></immediateOrderResult> </immediateOrderResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<web:immediateOrder>', cofaceReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportsItem = creditFactory.requestCompanyReports('69590780');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Hild Ingatlanbefektető Korlátolt Felelősségű Társaság', reportsItem.companiesList.get(0).name);
        System.assertEquals('1', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportFieldsToUpdate();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('Hild Ingatlanbefektető Korlátolt Felelősségű Társaság', reportsList.get(0).Name);
        System.assertEquals(3, reportEmployeesList.size());
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Opportunity'));
        System.assertEquals('1', ((Map<String, Object>) fieldsToUpdateMap.get('Opportunity')).get('Credit_System_Rating__c'));
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Account'));
    }


    /*******************************************************************************
    *  Summary         : test response from Coface with API error
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCofaceApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
            SingleRequestMock creditSafeReportMock = new SingleRequestMock(500, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><soap:Fault><faultcode>soap:Client</faultcode><faultstring>Company not found</faultstring></soap:Fault></soap:Body></soap:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, creditSafeReportMock);
            try {
                creditFactory.requestCompanyReports('8283231');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Coface API error. Please contact your administrator. Company not found. Company Id: 8283231', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
             SingleRequestMock cofaceAvailabilityMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><getCompanyDetailsResponse xmlns="http://www.iconx.biz/webservices"><getCompanyDetailsResult><ResponseCode>OK</ResponseCode><ResponseText>OK</ResponseText><CompanyDetails><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress><Country>HU</Country><ZipCode>1036</ZipCode><City>Budapest</City><AddressItem1>Lajos utca 74-76.</AddressItem1><Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number></Telephone><Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number></Fax></PrincipalAddress><RegisteredAddress/><LegalForm><LegalFormCode>300</LegalFormCode><LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers><CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier></CompanyIdentifier><CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier></CompanyIdentifier><CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier></CompanyIdentifier><CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier></CompanyIdentifier></Identifiers><Activities><Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription></Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><AvailableProducts><Product><Code>12</Code><Description>Credit Analysis Report</Description><Availability>AvailableImmediately</Availability></Product><Product><Code>761</Code><Description>AUTOMATIC CREDIT REPORT</Description><Availability>AvailableImmediately</Availability></Product><Product><Code>5000</Code><Description>Portfolio Watch</Description><Availability>AvailableImmediately</Availability></Product></AvailableProducts></CompanyDetails></getCompanyDetailsResult></getCompanyDetailsResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<web:getCompanyDetails>', cofaceAvailabilityMock);
            SingleRequestMock cofaceReportMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body> <immediateOrderResponse xmlns="http://www.iconx.biz/webservices"><immediateOrderResult> <ResponseCode>OK</ResponseCode> <ResponseText>OK</ResponseText> <OrderStatus><ProviderOrderReference>2771334</ProviderOrderReference><ProductCode>761</ProductCode><Provider><PartyID>CIC_HU</PartyID><Name>Coface Hungary Credit Management Services Kft.</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><Email>orders-hungary@coface.com</Email><WebAddress>http://www.coface.hu</WebAddress></Provider><Consumer><Name>FleetCor Hungary Korlátolt Felelősségű Társaság</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><WebAddress>fleetcor.hu</WebAddress></Consumer><OriginalRequest><Name></Name><PrincipalAddress> <ZipCode></ZipCode> <AddressItem1></AddressItem1></PrincipalAddress><DateOfValidity>0001-01-01T00:00:00.0+01:00</DateOfValidity><DateOfLastUpdate>0001-01-01T00:00:00.0+01:00</DateOfLastUpdate><DateOfLastBalanceSheet>0001-01-01T00:00:00.0+01:00</DateOfLastBalanceSheet></OriginalRequest><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress> <Country>HU</Country> <ZipCode>1036</ZipCode> <City>Budapest</City> <AddressItem1>Lajos utca 74-76.</AddressItem1> <Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number> </Telephone> <Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number> </Fax></PrincipalAddress><RegisteredAddress></RegisteredAddress><LegalForm> <LegalFormCode>300</LegalFormCode> <LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers> <CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier> </CompanyIdentifier></Identifiers><Activities> <Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription> </Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><ReportLanguage>EN</ReportLanguage><StatusCode>Finished</StatusCode><Ordered>2018-03-07T14:46:16.000+01:00</Ordered><RequestedDelivery>2018-03-07T15:46:00.000+01:00</RequestedDelivery><Delivered>2018-03-07T14:46:17.000+01:00</Delivered><MaximumCreditRecommendationAmount>-1.0</MaximumCreditRecommendationAmount><CompanyRegistrationDate>0001-01-01T00:00:00.0+01:00</CompanyRegistrationDate><ReportMimeType>text/xml</ReportMimeType> </OrderStatus> <Report><ProviderOrderReference>2771334</ProviderOrderReference><ProductCode>761</ProductCode><Provider><PartyID>CIC_HU</PartyID><Name>Coface Hungary Credit Management Services Kft.</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><Email>orders-hungary@coface.com</Email><WebAddress>http://www.coface.hu</WebAddress></Provider><Consumer><Name>FleetCor Hungary Korlátolt Felelősségű Társaság</Name><ContactInformation> <Country>HU</Country> <City>Budapest</City></ContactInformation><WebAddress>fleetcor.hu</WebAddress></Consumer><OriginalRequest><Name></Name><PrincipalAddress> <ZipCode></ZipCode> <AddressItem1></AddressItem1></PrincipalAddress><DateOfValidity>0001-01-01T00:00:00.0+01:00</DateOfValidity><DateOfLastUpdate>0001-01-01T00:00:00.0+01:00</DateOfLastUpdate><DateOfLastBalanceSheet>0001-01-01T00:00:00.0+01:00</DateOfLastBalanceSheet></OriginalRequest><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress> <Country>HU</Country> <ZipCode>1036</ZipCode> <City>Budapest</City> <AddressItem1>Lajos utca 74-76.</AddressItem1> <Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number> </Telephone> <Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number> </Fax></PrincipalAddress><RegisteredAddress></RegisteredAddress><LegalForm> <LegalFormCode>300</LegalFormCode> <LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers> <CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier> </CompanyIdentifier> <CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier> </CompanyIdentifier></Identifiers><Activities> <Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription> </Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><ReportLanguage>EN</ReportLanguage><StatusCode>Finished</StatusCode><Ordered>2018-03-07T14:46:16.000+01:00</Ordered><RequestedDelivery>2018-03-07T15:46:00.000+01:00</RequestedDelivery><Delivered>2018-03-07T14:46:17.000+01:00</Delivered><MaximumCreditRecommendationAmount>-1.0</MaximumCreditRecommendationAmount><CompanyRegistrationDate>0001-01-01T00:00:00.0+01:00</CompanyRegistrationDate><ReportMimeType>text/xml</ReportMimeType><ReportXML><ICON VERSION="2.0.0" xmlns:ns2="http://www.iconx.biz/webservices"> <ORDERSTATUS><INTERCREDITORDERNUMBER>2771334</INTERCREDITORDERNUMBER><PROVIDER> <PROVIDERID>2</PROVIDERID> <NAME>Coface Hungary Credit Management Services Kft.</NAME> <SENDERID>IC02</SENDERID> <CITY>Budapest</CITY> <COUNTRY VALUE="HU">Hungary</COUNTRY> <STREET>Váci út</STREET> <HOUSENUMBER>45. H. ép. 7.</HOUSENUMBER> <ZIPCODE>1134</ZIPCODE></PROVIDER><CUSTOMER> <CUSTOMERID>106157832</CUSTOMERID> <NAME>FleetCor Hungary Korlátolt Felelősségű Társaság</NAME> <RECIPIENTID></RECIPIENTID> <CITY>Budapest</CITY> <COUNTRY VALUE="HU">Hungary</COUNTRY> <STREET>Andrássy út</STREET> <HOUSENUMBER>100.</HOUSENUMBER> <ZIPCODE>1062</ZIPCODE></CUSTOMER><CUSTOMERSREFERENCE></CUSTOMERSREFERENCE><PURCHASEORDERNUMBER></PURCHASEORDERNUMBER><LANGUAGE VALUE="2">English</LANGUAGE><PRODUCT VALUE="9997">AUTOMATIC CREDIT REPORT</PRODUCT><REPORTMIMETYPE>TEXT/XML</REPORTMIMETYPE><BALANCESHEETLAYOUT VALUE="31">Full BS Hungary</BALANCESHEETLAYOUT><TIMESTAMP>20180307144616</TIMESTAMP><STATUS VALUE="10">Finished</STATUS><REQUIREDBY>20180307154600</REQUIREDBY><GIVENCOMPANYNAME></GIVENCOMPANYNAME><REQUESTEDCOMPANYINFORMATION> <COMPANYNAME></COMPANYNAME> <REGISTRATIONCOUNTRY></REGISTRATIONCOUNTRY> <ZIPCODE></ZIPCODE> <CITY></CITY> <STREET></STREET> <HOUSENUMBER></HOUSENUMBER> <ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE> <COUNTRY></COUNTRY> <TELEPHONAREACODE></TELEPHONAREACODE> <TELEPHONENUMBER></TELEPHONENUMBER> <NATIONALNUMBER></NATIONALNUMBER></REQUESTEDCOMPANYINFORMATION><QUESTION></QUESTION><ANSWER></ANSWER> </ORDERSTATUS> <CREDITREPORT><COMPANY> <COPYRIGHT>Coface Hungary Credit Management Services Kft.</COPYRIGHT> <INTERCREDITNUMBER>69590780</INTERCREDITNUMBER> <NATIONALID>13373344</NATIONALID> <STATUS VALUE="0">Active</STATUS> <COMPANYNAME>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</COMPANYNAME> <SORTNAME>Hild Ingatlanbefektető Kft.</SORTNAME> <INTERNATIONALNAME>Hild Real Estate Investments Limited Liability Company</INTERNATIONALNAME> <EASYNUMBER>00003123942472</EASYNUMBER> <SHORTNAME></SHORTNAME> <LEGALFORM VALUE="300">Limited Liability Company</LEGALFORM> <REGISTRATION><NUMBER>0109731931</NUMBER><CITY>Budapest</CITY><COUNTRY>HU</COUNTRY><COUNTRYREGION></COUNTRYREGION><DATE>20041215</DATE> </REGISTRATION> <COMPANYCOMMENT></COMPANYCOMMENT> <HISTORY></HISTORY> <TAXNUMBER>123123123</TAXNUMBER> <STATISTICALNUMBER></STATISTICALNUMBER> <VATNUMBER><TYPE VALUE="120">VAT number</TYPE><VALUE>13373344-2-41</VALUE> </VATNUMBER> <VALIDITYDATE>20170117</VALIDITYDATE> <LASTMAJORUPDATE>' + Date.today().year() + '0619</LASTMAJORUPDATE> <ESTABLISHED>20040927</ESTABLISHED> <CAPITAL><INDICATOR><TYPE VALUE="5305">Subscribed capital</TYPE><DATE>20041215</DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>3000000.0000</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY VALUE="HUF">Hungarian Forint</CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE></INDICATOR> </CAPITAL> <NATIONALCURRENCY VALUE="HUF">Hungarian Forint</NATIONALCURRENCY> <ALIASES><ALIAS>Hild Ingatlanbefektető Kft.</ALIAS> </ALIASES> <ADDRESSES><ADDRESS><ADDRESSTYPE VALUE="1">Principal Address</ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Lajos utca</STREET><HOUSENUMBER>74-76.</HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>1036</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><COUNTRYREGION VALUE="HU-BU">Budapest</COUNTRYREGION><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA>1</AREA> <NUMBER>8875600</NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA>1</AREA> <NUMBER>8875601</NUMBER></FAX><EMAIL>info@hild.hu</EMAIL><INTERNET>www.hild.hu</INTERNET></ADDRESS><ADDRESS><ADDRESSTYPE VALUE="50">Former Principal Address</ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Kelenhegyi út 29/b</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE>15.12.2004 - 12.12.2005</ADDITIONALADDRESSLINE><ZIPCODE>1118</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><COMMENT></COMMENT> </ADDRESSES></COMPANY><MANAGEMENT> <MANAGER><TYPE VALUE="200">Managing director</TYPE><NAME>BIRÓ Balázs Tibor</NAME><ADDRESS><ADDRESSTYPE VALUE="40"></ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Dayka Gábor utca 92.</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>1112</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><ACTIVESINCE>20150301</ACTIVESINCE><ACTIVEUNTIL></ACTIVEUNTIL><EQUITYAMOUNT></EQUITYAMOUNT><EQUITYCURRENCY></EQUITYCURRENCY><EQUITYDIMENSION></EQUITYDIMENSION><COMMENT>Önálló képviselet/Individual signature</COMMENT> </MANAGER> <MANAGER><TYPE VALUE="409">Auditor</TYPE><NAME>BDO Magyarország Könyvvizsgáló Korlátolt Felelősségű Társaság</NAME><ADDRESS><ADDRESSTYPE VALUE="1">Principal Address</ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Kőér utca 2/A. C. ép.</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>1103</ZIPCODE><CITY>Budapest</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><COUNTRYREGION VALUE="HU-BU">Budapest</COUNTRYREGION><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><ACTIVESINCE>20130111</ACTIVESINCE><ACTIVEUNTIL></ACTIVEUNTIL><EQUITYAMOUNT></EQUITYAMOUNT><EQUITYCURRENCY></EQUITYCURRENCY><EQUITYDIMENSION></EQUITYDIMENSION><INTERCREDITNUMBER>73579100</INTERCREDITNUMBER><REGISTRATIONCOUNTRY VALUE="HU">Hungary</REGISTRATIONCOUNTRY><REGISTRATIONPLACE>Budapest</REGISTRATIONPLACE><REGISTRATIONDATE>20060413</REGISTRATIONDATE><REGISTRATIONNUMBER>0109867785</REGISTRATIONNUMBER><COMPANYSTATUS><TYPE VALUE="1">Registration status</TYPE><STATUS VALUE="20">Registered company</STATUS><VALIDSINCE>20060209</VALIDSINCE><COMMENT></COMMENT></COMPANYSTATUS> </MANAGER> <MANAGER><TYPE VALUE="409">Auditor</TYPE><NAME>NAGYNÉ Zagyva Zsuzsanna</NAME><ADDRESS><ADDRESSTYPE VALUE="40"></ADDRESSTYPE><RUNNINGNUMBER>0</RUNNINGNUMBER><NAME></NAME><STREET>Fenyőfa utca 77.</STREET><HOUSENUMBER></HOUSENUMBER><ADDITIONALADDRESSLINE></ADDITIONALADDRESSLINE><ZIPCODE>2030</ZIPCODE><CITY>Érd</CITY><COUNTRY VALUE="HU">Hungary</COUNTRY><TELEPHONE> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></TELEPHONE><FAX> <INTERNATIONAL>36</INTERNATIONAL> <AREA></AREA> <NUMBER></NUMBER></FAX><EMAIL></EMAIL><INTERNET></INTERNET></ADDRESS><ACTIVESINCE>20130111</ACTIVESINCE><ACTIVEUNTIL></ACTIVEUNTIL><EQUITYAMOUNT></EQUITYAMOUNT><EQUITYCURRENCY></EQUITYCURRENCY><EQUITYDIMENSION></EQUITYDIMENSION> </MANAGER> <COMMENTS></COMMENTS></MANAGEMENT><AUTHORITY></AUTHORITY><ACTIVITIES> <ACTIVITY><PRIORITY>2</PRIORITY><NACECODE>7022</NACECODE><NACETEXT>Business and other management consultancy activities</NACETEXT><LOCALACTIVITYCODE></LOCALACTIVITYCODE><LOCALACTIVITYTEXT></LOCALACTIVITYTEXT> </ACTIVITY> <COMMENT></COMMENT></ACTIVITIES><ADDITIONALBALANCESHEETS> <ADDITIONALBALANCESHEET NAME="Key Financial Data" TYPE="638"><BALANCESHEETITEM><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>111.6874</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>105.1162</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>170.8787</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="7">Net sales revenue</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>221.3836</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>3</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>51.09</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>0.4663</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>0.8384</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="2">Fixed assets</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>37.5703</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>110.6585</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>110.7786</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>103.7505</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="21">Owner\'s equity</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>106.8135</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE>2</LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-0.8681</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>6.4416</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>3.036</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="941">Net result of the year</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-8.2146</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20160000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-0.6591</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20150000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>13.9851</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20140000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>3.8521</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR><INDICATOR> <TYPE VALUE="5919">Operating result</TYPE> <DATE>20130000</DATE> <FROMDATE></FROMDATE> <TODATE></TODATE> <FROMAMOUNT>-10.5722</FROMAMOUNT> <TOAMOUNT></TOAMOUNT> <CURRENCY VALUE="EUR">Euro</CURRENCY> <DIMENSION VALUE="1">Thousand</DIMENSION> <MEASURE></MEASURE> <LABELTYPE></LABELTYPE></INDICATOR></BALANCESHEETITEM> </ADDITIONALBALANCESHEET></ADDITIONALBALANCESHEETS><WORKFORCE> <INDICATOR><TYPE VALUE="11">Total workforce</TYPE><DATE>20171006</DATE><FROMDATE>20171006</FROMDATE><TODATE>20171006</TODATE><FROMAMOUNT>2</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY></CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE> </INDICATOR> <INDICATOR><TYPE VALUE="11">Total workforce</TYPE><DATE>20120000</DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>3</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY></CURRENCY><DIMENSION VALUE="0">Blank</DIMENSION><MEASURE></MEASURE> </INDICATOR> <INDICATOR><TYPE VALUE="11">Total workforce</TYPE><DATE>20110000</DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>4</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY></CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE> </INDICATOR></WORKFORCE><MAXIMUMCREDIT> <INDICATOR><TYPE VALUE="20">Maximum credit</TYPE><DATE></DATE><FROMDATE></FROMDATE><TODATE></TODATE><FROMAMOUNT>782000</FROMAMOUNT><TOAMOUNT></TOAMOUNT><CURRENCY VALUE="HUF">Hungarian Forint</CURRENCY><DIMENSION></DIMENSION><MEASURE></MEASURE><COMMENT>Due to the company’s limited scope of activities, an amount of EUR 2.500 is considered as the Maximum Credit.</COMMENT> </INDICATOR> <COMMENT></COMMENT></MAXIMUMCREDIT><CCEATRATING><SCORE VALUE="1"></SCORE><DATE></DATE><COMMENT/></CCEATRATING><CUSTOMERSPECIFICMAXCREDITS> <CUSTOMERSPECIFICMAXCREDIT><TYPE VALUE="50">Quick Rate</TYPE><CSMAXCREDITVALUE>1</CSMAXCREDITVALUE><CSMAXCREDITCURRENCY></CSMAXCREDITCURRENCY><CSMAXCREDITCODE VALUE="2">Medium High Risk</CSMAXCREDITCODE> </CUSTOMERSPECIFICMAXCREDIT></CUSTOMERSPECIFICMAXCREDITS><STATUSLIST> <COMPANYSTATUS><TYPE VALUE="1">Registration status</TYPE><STATUS VALUE="20">Registered company</STATUS><VALIDSINCE>20041215</VALIDSINCE><COMMENT></COMMENT> </COMPANYSTATUS> <COMPANYSTATUS><TYPE VALUE="2">Activity status</TYPE><STATUS VALUE="10">Active company</STATUS><VALIDSINCE>20040927</VALIDSINCE><COMMENT></COMMENT> </COMPANYSTATUS></STATUSLIST><COUNTRYINDICATORS></COUNTRYINDICATORS><UNSTRUCTURED>AUTOMATIC CREDIT REPORT \n\n-------------------------------------------------------------------------------\n (c) Coface Hungary Credit Management Services Kft.\n email: orders-hungary@coface.com\n 07.03.2018 14:46()\n\n-------------------------------------------------------------------------------\n\n\n\nORDER DETAILS\n\n-------------------------------------------------------------------------------\nOrder Details: Customer: FleetCor Hungary Korlatolt Felelossegu Tarsasag\n\n \nOrder number: 2771334\nDelivery speed: Immediate\nLanguage: English\n\n\n-------------------------------------------------------------------------------\n\n\n\nCOMPANY\n\n-------------------------------------------------------------------------------\nHILD INGATLANBEFEKTETO KORLATOLT FELELOSSEGU TARSASAG\nInternational Name: Hild Real Estate Investments Limited\nLiability Company\nAliases: Hild Ingatlanbefekteto Kft.\n\nPrincipal Address:\nLajos utca 74-76\n1036 Budapest\nBudapest\nHungary\nTelephone: +36-1-8875600\nFax: +36-1-8875601\nEmail: info@hild.hu\nWeb: www.hild.hu\n\n-------------------------------------------------------------------------------\n\nICON number: 69590780\nEasy number: 00003123942472\nNational ID: 13373344\nInternational VAT number: HU13373344\nVAT number: 13373344-2-41\n\n-------------------------------------------------------------------------------\n\nStatus: Registration status: 15.12.2004 - Registered company\nActivity status: 27.09.2004 - Active company\n\n\n-------------------------------------------------------------------------------\n\nDate of Last17.01.2017\nResearch:\n\n-------------------------------------------------------------------------------\n\nDate of Last Major19.06.2017\nUpdate: \n\n-------------------------------------------------------------------------------\n\n\n\nCREDIT INFORMATION\n\n-------------------------------------------------------------------------------\nRecommended Maximum EUR 2.500 (HUF 782.000)\nCredit: Due to the company’s limited scope of activities, an\namount of EUR 2.500 is considered as the Maximum Credit.\n\nMaximum Credit is to be understood as the highest\npossible engagement for a supplier delivering goods or\nrendering services on open terms with an average of 60\ndays. The calculation is based on the assumption that, on\nthe average, the company in question has 5 suppliers\nwhich deliver goods or render services at the same time.\n\n-------------------------------------------------------------------------------\n\nQuick Rate: Quick Rate: Medium High Risk\n\n-------------------------------------------------------------------------------\n\n\n\nKEY DATA ON OPERATIONS\n\n-------------------------------------------------------------------------------\nActivity status: 27.09.2004 - Active company\n\n-------------------------------------------------------------------------------\n\nActivities: NACE\n 7022 Business and other management consultancy\nactivities\n\n\n\nThe company is active in the Coface sector \'Business and\npersonal services\'.\n\n-------------------------------------------------------------------------------\n\nWorkforce: 06.10.2017\nTotal workforce: 2\n\n2012\nTotal workforce: 3\n\n2011\nTotal workforce: 4\n\n\n-------------------------------------------------------------------------------\n\n\n\nCOMPANY DETAILS\n\n-------------------------------------------------------------------------------\nRegistration: No. 0109731931\n\n15.12.2004\nBudapest, Hungary\n\n-------------------------------------------------------------------------------\n\nLegal Form: 15.12.2004\nLimited Liability Company\n\n-------------------------------------------------------------------------------\n\nManagement: BIRO Balazs Tibor - Managing director (signature right)\nNationality: HU\nDayka Gabor utca 92\n1112 Budapest\nHungary\n\n\nsince 01.03.2015\n\nOEnallo kepviselet/Individual signature\nBDO Magyarorszag Koenyvvizsgalo Korlatolt Felelossegu\nTarsasag - Auditor\nRegistration: No. 0109867785, 13.04.2006, Budapest,\nHungary\n1103 Budapest, Koer utca 2/A. C. ep. \nsince 11.01.2013\n\nNAGYNE Zagyva Zsuzsanna - Auditor\nNationality: HU\nFenyofa utca 77\n2030 Erd\nHungary\n\n\nsince 11.01.2013\n\n\n-------------------------------------------------------------------------------\n\n\n\n\nFINANCIAL INFORMATION\n\n-------------------------------------------------------------------------------\nKey Financial Data:\nAmounts shown in Euro (EUR) Thousand\n ' + Date.today().addYears(-1).year() + Date.today().addYears(-2).year() + Date.today().addYears(-3).year() + '\nNet sales revenue 100,00 100,00 100,00\nFixed assets 51,09 0,47 0,84\nOwner\'s equity 110,66 110,78 103,75\nNet result of the year-0,87 6,44 3,04\nOperating result 100,00 100,00 100,00\n The bookkeeping period of this company is not different from the Hungarian\nstandard\n\n\n \n-------------------------------------------------------------------------------\n\nApproximate 2017: 310,14 HUF = 1 EUR\nExchange Rates:2016: 311,02 HUF = 1 EUR\n2015: 313,12 HUF = 1 EUR\n2014: 314,89 HUF = 1 EUR\n2013: 296,91 HUF = 1 EUR\n2012: 291,29 HUF = 1 EUR\n2011: 311,13 HUF = 1 EUR\n2017: 258,82 HUF = 1 USD\n2016: 293,69 HUF = 1 USD\n2015: 286,63 HUF = 1 USD\n2014: 259,13 HUF = 1 USD\n2013: 215,67 HUF = 1 USD\n2012: 220,93 HUF = 1 USD\n2011: 240,68 HUF = 1 USD\n\n-------------------------------------------------------------------------------\n\nFinancial Comments: The bookkeeping period of this company is not different\nfrom the Hungarian standard\n\n-------------------------------------------------------------------------------\n\nThe information and/or data provided are subject to the general terms and\nconditions or individual contract terms and may be used only for the purpose\nthey have been requested for.\nThe above shown figures was stipulated accordingly to the official Companies\nGazette (Cegkoezloeny) or any other accessed official sources.\n\nCoface Hungary \nCredit Management Services Kft.\nH-1094 Budapest, \nTuezolto utca 57.\nHungary\nwww.coface.hu\n\n*** End of document ***</UNSTRUCTURED> </CREDITREPORT></ICON></ReportXML> </Report></immediateOrderResult> </immediateOrderResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<web:immediateOrder>', cofaceReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('82832310');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: 82832310', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();

        System.assertEquals('Update Name', addressUpdateData.get('header'));

        Map<String, Object> nameFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, nameFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Hild Ingatlanbefektető Kft.', ((Map<String, Object>) nameFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Budapest', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

        creditFactoryDataMap.put('street', 'test');
        creditFactoryDataMap.put('postalStreet', 'test');
        creditFactoryDataMap.put('registeredStreet', 'test');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test tax id validation
    *  Created         : 27/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTaxId() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TaxId'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        CreditFactoryCompany externalCompany = cfItem.companiesList.get(0);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnTaxIdUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Tax Id', addressUpdateData.get('header'));

        Map<String, Object> taxIdFieldsToUpdate = creditFactory.returnTaxIdFieldsToUpdate();
        System.assertEquals(true, taxIdFieldsToUpdate.containsKey('Account'));
        System.assertEquals('13373344-2-41', ((Map<String, Object>) taxIdFieldsToUpdate.get('Account')).get('Steuernummer__c'));

        creditFactoryDataMap.put('taxId', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TaxId'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test vat number validation
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('HU13373344', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test trade register number validation
    *  Created         : 27/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTradeRegisterNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TradeRegisterNumber'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        CreditFactoryCompany externalCompany = cfItem.companiesList.get(0);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> tradeRegisterNumberFieldsToUpdate = creditFactory.returnTradeRegisterNumberFieldsToUpdate();
        System.assertEquals(true, tradeRegisterNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('0109731931', ((Map<String, Object>) tradeRegisterNumberFieldsToUpdate.get('Account')).get('HR_Abteilung_HRA_HRB_und_HR_Nummer__c'));

        creditFactoryDataMap.put('tradeRegisterNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'tradeRegisterNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test contact validation
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
    *  Created         : 21/10/2020 by Anton
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Hungary');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 21/10/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating0_3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('14', cfResult.paymentTerms);
        System.assertEquals(110, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 15', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 14', cfResult.messagesList.get(1).text);

        Map<String, Object> updateOpportunityFieldsMap = creditFactory.returnUpdateOpportunityFieldsToUpdate();
        System.assertEquals(true, updateOpportunityFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) updateOpportunityFieldsMap.get('Opportunity')).get('Credit_check_date__c'));

        Map<String, Object> closedWonFieldsMap = creditFactory.returnClosedWonFieldsToUpdate();
        System.assertEquals(true, closedWonFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) closedWonFieldsMap.get('Opportunity')).get('CloseDate'));
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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
        List<dsfs__DocuSign_Status__c> docuSignStatusesList = CreditFactoryService.selectDocuSignStatusesList(opportunityId);
        sobjectsList.addAll(docuSignStatusesList);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 4
    *  Created         : 02/02/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '4';
        report.Profit_Loss_Last_Year__c = null;
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<dsfs__DocuSign_Status__c> docuSignStatusesList = CreditFactoryService.selectDocuSignStatusesList(opportunityId);
        sobjectsList.addAll(docuSignStatusesList);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals('Low/no profitability', cfResult.depositReason);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 26/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '5';
        report.Year_of_Last_Financial_Information__c = String.valueOf(Date.today().year() - 3);
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Missing financials', cfResult.depositReason);
        System.assertEquals(50, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 5
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '5';
        report.Credit_Limit__c = '1000';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('14', cfResult.paymentTerms);
        System.assertEquals('Low Recommended CL', cfResult.depositReason);
        System.assertEquals(4, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 5
    *  Created         : 17/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '5';
        String dateOfFoundation = '01.01.' + Date.today().year();
        report.Date_of_Foundation__c = dateOfFoundation;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 6-10
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating6_10() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '7';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating99() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '99';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 99)', cfResult.depositReason);
        System.assertEquals(100, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Hungary');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Hungary');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}