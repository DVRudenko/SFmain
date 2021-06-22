@IsTest
public class CreditFactoryTestCZ {


    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountCZ();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityCZ();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactCZ();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Czech Republic');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Czech Republic');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        CreditSystem__c cribisSettings = CreditFactoryTestUtils.generateCribisSetting();
        insert cribisSettings;

        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        insert lexisNexisSettings;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Czech Republic', Index__c = 29);
        insert fuelPrice;

        Tankkarten__c card = CreditFactoryTestUtils.generateTankkarten();
        card.Opportunity__c = opportunity.Id;
        insert card;

        Product2 product2 = CreditFactoryTestUtils.generateProduct2();
        insert product2;

        PricebookEntry pricebookEntry = CreditFactoryTestUtils.generatePricebookEntry();
        pricebookEntry.Product2Id = product2.Id;
        pricebookEntry.CurrencyIsoCode = 'CZK';
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

        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'CZ');
        insert riskyBusinessCode;
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplCZ);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

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

        System.assertEquals('PAVEL DZIURA', company.name);
    }


    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        creditFactorySettings.returnSearchValidations();
    }


    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

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
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyCZ();
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'DesiredPaymentDetails'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('desiredBillingPeriod', '30');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'DesiredPaymentDetails'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

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
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

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
    *  Summary         : test validate process opportunity
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountCZ();
        dupAccount.Steuernummer__c = '12344312';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityCZ();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactCZ();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplCZ);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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

        System.assertEquals('PAVEL DZIURA', company.name);
    }


    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
    *  Summary         : test request for searching company
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><URPlusGetCandidatesResponse xmlns="https://ws.urplus.sk"><URPlusGetCandidatesResult><Status><Code>101</Code><Description>OK</Description></Status><Data><SubjectsFound>1</SubjectsFound><Subject><EntId>1512491</EntId><IC>41909941</IC><Name>Pavel Dziura</Name><Addres>Bejblíkova 199, Planá nad Lužnicí, 39111, Česká republika</Addres><AddressComplex><Street>Bejblíkova 199</Street><StreetNumber>199</StreetNumber><City>Planá nad Lužnicí</City><Zip>391 11</Zip><Country>Czech Republic</Country><FullAddress>Bejblíkova 199, Planá nad Lužnicí, 39111, Česká republika</FullAddress></AddressComplex><ActiveSubject>true</ActiveSubject><HistoricalNames><Name>Pavel Dziura - AUTO-D</Name><StartDate>2012-12-06</StartDate><EndDate>2012-12-06</EndDate></HistoricalNames></Subject></Data></URPlusGetCandidatesResult></URPlusGetCandidatesResponse></soap:Body></soap:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);
            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock cribisReportMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><CribisGetGlobalReportResponse xmlns="https://ws.urplus.sk"><CribisGetGlobalReportResult><Status><Code>101</Code><Description>OK</Description></Status><Data><CompanyGlobalReport xmlns="urn:crif-cribiscz-GetGlobalReport:2013-05-03"><CompanyIdentification><EntId>1512491</EntId><Name>Pavel Dziura</Name><NameSourceCode>RP</NameSourceCode><HistoricalNames><HistoricalName><Name>Pavel Dziura - AUTO-D</Name><SourceCode>01</SourceCode><StartDate>2012-12-06</StartDate><EndDate>2012-12-06</EndDate></HistoricalName></HistoricalNames><District>Tábor</District><NutsID>CZ030107</NutsID><Region>Jihočeský kraj</Region><Seat><Street>Bejblíkova 199</Street><StreetNumber>199</StreetNumber><City>Planá nad Lužnicí</City><Zip>391 11</Zip><Country>Czech Republic</Country><CountryAlpha2>CZ</CountryAlpha2><FullAddress>Bejblíkova 199, Planá nad Lužnicí, 39111, Česká republika</FullAddress><SourceCode>RP</SourceCode></Seat><PhoneNumbers><PhoneNumber><Number>+420 725 393 467</Number><DateUpdated>2017-06-30</DateUpdated></PhoneNumber></PhoneNumbers><Website>www.paveldziura.webmium.com</Website><Email>p.dziura@seznam.cz</Email><ReportDate>2020-10-29T07:48:56.1507873+01:00</ReportDate><LegalFormCd>101</LegalFormCd><LegalForm>Entrepreneur-physical person-not entered in Business Register</LegalForm><Ico>41909941</Ico><MainOkec><Code>521200</Code><Description>Other retail sale in non-specialized stores</Description></MainOkec><MainNACE><Code>43.91</Code><Description>Roofing activities</Description><StartDate>2012-12-06</StartDate></MainNACE><ArrayOfSecondaryNace><Nace><Code>43.91</Code><Description>Roofing activities</Description><StartDate>2014-02-01</StartDate></Nace><Nace><Code>G</Code><Description>G - WHOLESALE AND RETAIL TRADE; REPAIR OF MOTOR VEHICLES AND MOTORCYCLES</Description><StartDate>2012-12-06</StartDate><EndDate>2014-02-01</EndDate></Nace><Nace><Code>46.1</Code><Description>Wholesale on a fee or contract basis</Description><StartDate>1991-09-26</StartDate><EndDate>2014-02-01</EndDate></Nace><Nace><Code>G</Code><Description>G - WHOLESALE AND RETAIL TRADE; REPAIR OF MOTOR VEHICLES AND MOTORCYCLES</Description><StartDate>2013-06-21</StartDate></Nace><Nace><Code>46.1</Code><Description>Wholesale on a fee or contract basis</Description><StartDate>2013-06-21</StartDate><EndDate>2019-02-13</EndDate></Nace><Nace><Code>16.23</Code><Description>Manufacture of other builders\' carpentry and joinery</Description><StartDate>1991-09-26</StartDate><EndDate>2012-12-06</EndDate></Nace></ArrayOfSecondaryNace><SubjectType>P</SubjectType><Semafor>1</Semafor><SemaforHistory><Item><StartDate>2018-01-09</StartDate><EndDate>2018-04-08</EndDate><Semafor>2</Semafor></Item><Item><StartDate>2017-01-12</StartDate><EndDate>2017-03-26</EndDate><Semafor>2</Semafor></Item><Item><StartDate>2019-01-08</StartDate><EndDate>2019-03-24</EndDate><Semafor>2</Semafor></Item><Item><StartDate>2018-04-08</StartDate><EndDate>2019-01-08</EndDate><Semafor>1</Semafor></Item><Item><StartDate>2013-02-18</StartDate><EndDate>2015-01-19</EndDate><Semafor>1</Semafor></Item><Item><StartDate>2015-01-19</StartDate><EndDate>2015-05-01</EndDate><Semafor>2</Semafor></Item><Item><StartDate>2015-05-01</StartDate><EndDate>2017-01-12</EndDate><Semafor>1</Semafor></Item><Item><StartDate>2017-03-26</StartDate><EndDate>2018-01-09</EndDate><Semafor>1</Semafor></Item></SemaforHistory><DateOfCreation>1991-09-26</DateOfCreation><BusinessCreation>1991-09-26</BusinessCreation><ScopeOfActivities><Activity><Description>Pokrývačství, tesařství</Description><StartDate>1993-01-01</StartDate><SourceID>RP</SourceID><Interruptions><Interruption><StartDate>2001-07-09</StartDate><EndDate>2003-07-08</EndDate></Interruption><Interruption><StartDate>2013-02-15</StartDate><EndDate>2013-04-30</EndDate></Interruption><Interruption><StartDate>2012-12-01</StartDate><EndDate>2013-02-03</EndDate></Interruption><Interruption><StartDate>2015-01-05</StartDate><EndDate>2015-03-31</EndDate></Interruption><Interruption><StartDate>2015-04-01</StartDate><EndDate>2015-04-30</EndDate></Interruption><Interruption><StartDate>2017-01-09</StartDate><EndDate>2017-03-31</EndDate></Interruption><Interruption><StartDate>2018-12-28</StartDate><EndDate>2019-03-31</EndDate></Interruption><Interruption><StartDate>2017-12-28</StartDate><EndDate>2018-04-15</EndDate></Interruption></Interruptions><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Výroba, obchod a služby neuvedené v přílohách 1 až 3 živnostenského zákona</Description><StartDate>1992-05-11</StartDate><SourceID>RP</SourceID><Interruptions><Interruption><StartDate>2012-12-01</StartDate><EndDate>2013-02-03</EndDate></Interruption><Interruption><StartDate>2013-02-15</StartDate><EndDate>2013-04-30</EndDate></Interruption><Interruption><StartDate>2015-01-05</StartDate><EndDate>2015-03-31</EndDate></Interruption><Interruption><StartDate>2015-04-01</StartDate><EndDate>2015-04-30</EndDate></Interruption><Interruption><StartDate>2017-01-09</StartDate><EndDate>2017-03-31</EndDate></Interruption><Interruption><StartDate>2018-12-28</StartDate><EndDate>2019-03-31</EndDate></Interruption><Interruption><StartDate>2017-12-28</StartDate><EndDate>2018-04-15</EndDate></Interruption></Interruptions><PersonResponsibleList/><BusinessPremisesList/></Activity></ScopeOfActivities><ScopeOfActivitiesHistory><Activity><Description>obchodní činnost</Description><StartDate>1992-05-11</StartDate><EndDate>2008-06-30</EndDate><SourceID>RP</SourceID><Interruptions><Interruption><StartDate>1996-03-10</StartDate><EndDate>1996-12-31</EndDate></Interruption></Interruptions><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Zprostředkování obchodu a služeb</Description><StartDate>2006-09-18</StartDate><EndDate>2008-06-30</EndDate><SourceID>RP</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity></ScopeOfActivitiesHistory><InstitutionalSubsector>Self-employed persons</InstitutionalSubsector><InstitutionalSubsectorCode>14200</InstitutionalSubsectorCode></CompanyIdentification><KeyInformation><TurnoverRangeList><TurnoverRange><Year>2018</Year><ValueCd>03</ValueCd><Value>500 000 - 999 999 Kč</Value></TurnoverRange><TurnoverRange><Year>2017</Year><ValueCd>02</ValueCd><Value>200 000 - 499 999 Kč</Value></TurnoverRange><TurnoverRange><Year>2016</Year><ValueCd>02</ValueCd><Value>200 000 - 499 999 Kč</Value></TurnoverRange></TurnoverRangeList><EmployeesRangeList><EmployeesRange><Year>2019</Year><ValueCd>02</ValueCd><Value>0 employees</Value></EmployeesRange><EmployeesRange><Year>2018</Year><ValueCd>02</ValueCd><Value>0 employees</Value></EmployeesRange><EmployeesRange><Year>2017</Year><ValueCd>02</ValueCd><Value>0 employees</Value></EmployeesRange></EmployeesRangeList></KeyInformation><OtherCompanyInformation><OtherRelationsList><OtherRelation><Name>Pavel</Name><Surname>Dziura</Surname><Address><Street>Bejblíkova 199</Street><StreetNumber>199</StreetNumber><City>Planá nad Lužnicí</City><Zip>391 11</Zip><Country>Czech Republic</Country><CountryAlpha2>CZ</CountryAlpha2><FullAddress>Bejblíkova 199, Planá nad Lužnicí, 39111, Česká republika</FullAddress><SourceCode>RP</SourceCode></Address><DateOfBirth>1971-04-28</DateOfBirth><EntId>15081068</EntId><Position>Entrepreneur-physical person and n.p. entrepreneur: name, address and date of birth match</Position><PositionID>AF05</PositionID><StartDate>1995-12-05</StartDate></OtherRelation></OtherRelationsList></OtherCompanyInformation><CompanyRatingCalculationResponse><IndexCribisLevel>3</IndexCribisLevel><IndexCribis10Level>5</IndexCribis10Level><IndexCribis10NefiLevel>5</IndexCribis10NefiLevel><IndexCribis10LevelHistory><Item><StartDate>2017-09-21</StartDate><EndDate>2018-02-14</EndDate><IndexCribis10Level>5</IndexCribis10Level><IndexCribis10NefiLevel>5</IndexCribis10NefiLevel></Item><Item><StartDate>2018-04-08</StartDate><EndDate>2019-01-08</EndDate><IndexCribis10Level>5</IndexCribis10Level><IndexCribis10NefiLevel>5</IndexCribis10NefiLevel></Item></IndexCribis10LevelHistory><DateOfLastRequest>2019-03-24</DateOfLastRequest><FinancialSituation>Not specified</FinancialSituation><EconomicGroup>Not yet rated</EconomicGroup><ProbabilityOfDefault>0.48</ProbabilityOfDefault><ProbabilityUnit>%</ProbabilityUnit><CreditCapacity>13</CreditCapacity><CreditUsed>13</CreditUsed><CreditCurrency>CZK</CreditCurrency><CreditUnit>1000</CreditUnit></CompanyRatingCalculationResponse><KeyResultsWarning><ArrayOfWarning><Warning><Code>I80302</Code><Text>COVID19 - Entity in an endangered sector</Text><Historical>0</Historical><Date>2020-04-26</Date><Abbreviation>c</Abbreviation><SourceCode>C0</SourceCode><Source>CRIF CZ</Source></Warning></ArrayOfWarning></KeyResultsWarning><SourcesList><Source><SourceCode>01</SourceCode><SourceShortening>RES ČR</SourceShortening></Source><Source><SourceCode>C0</SourceCode><SourceShortening>CRIF CZ</SourceShortening></Source><Source><SourceCode>RP</SourceCode><SourceShortening>RŽP ČR</SourceShortening></Source></SourcesList></CompanyGlobalReport><DocumentTicket xmlns="urn:crif-cribiscz-GetGlobalReport:2013-05-03">7350cbcf-b219-eb11-80f9-005056b2243d</DocumentTicket></Data></CribisGetGlobalReportResult></CribisGetGlobalReportResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<ws:CribisGetGlobalReport>', cribisReportMock);
            SingleRequestMock cribisExecuteMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><CribisExekuceGetResponse xmlns="https://ws.urplus.sk"><CribisExekuceGetResult><Status><Code>101</Code><Description>OK</Description></Status><Data><SearchResults xmlns="urn:crif-cribiscz-ExekuceGet:2013-01-10"/><Info ObtainedRequests="101" RemainingRequests="950" xmlns="urn:crif-cribiscz-ExekuceGet:2013-01-10"/></Data></CribisExekuceGetResult></CribisExekuceGetResponse></soap:Body></soap:Envelope>', null);
            mocksMap.put('<ws:CribisExekuceGet>', cribisExecuteMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportsItem = creditFactory.requestCompanyReports('50521969');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Pavel Dziura', reportsItem.companiesList.get(0).name);
        System.assertEquals('3', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('200 000 - 499 999 Kč', reportsItem.companiesList.get(0).turnOver);
        System.assertEquals('13000', reportsItem.companiesList.get(0).creditLimit);
        System.assertEquals('2', reportsItem.companiesList.get(0).solvencyIndex);
        System.assertEquals('Verified', reportsItem.companiesList.get(0).emailStatus);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportFieldsToUpdate();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('Pavel Dziura', reportsList.get(0).Name);
        System.assertEquals(1, reportEmployeesList.size());
        System.assertEquals('Pavel Dziura', reportEmployeesList.get(0).Name);
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Opportunity'));
        System.assertEquals('3', ((Map<String, Object>) fieldsToUpdateMap.get('Opportunity')).get('Credit_System_Rating__c'));
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Account'));
        System.assertEquals('4391', ((Map<String, Object>) fieldsToUpdateMap.get('Account')).get('Branchencode__c'));
    }


    /*******************************************************************************
    *  Summary         : test response from Crif with API error
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCribisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
            SingleRequestMock cribisReportMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><CribisGetGlobalReportResponse xmlns="https://ws.urplus.sk"><CribisGetGlobalReportResult><Status><Code>401</Code><Description>Wrong input</Description></Status></CribisGetGlobalReportResult></CribisGetGlobalReportResponse></soap:Body></soap:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, cribisReportMock);
            try {
                creditFactory.requestCompanyReports('1234512345');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Cribis API error. Please contact your administrator. Bad request. Company Id: 1234512345', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        SingleRequestMock cribisReportMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body>  <CribisGetGlobalReportResponse xmlns="https://ws.urplus.sk"> <CribisGetGlobalReportResult><Status><Code>101</Code><Description>OK</Description></Status><Data><CompanyGlobalReport xmlns="urn:crif-cribiscz-GetGlobalReport:2013-05-03">  <CompanyIdentification> <EntId>47473299</EntId> <Name>Pavel Dziura</Name> <NameSourceCode>08</NameSourceCode> <District>Košice III</District> <NutsID>SK040204</NutsID> <Region>Košický</Region> <Seat><Street>Povstania českého ľudu 738/7</Street><StreetNumber>738</StreetNumber><City>Košice - Dargovských hrdinov</City><Zip>040 22</Zip><Country>Slovak Republic</Country><CountryAlpha2>SK</CountryAlpha2><FullAddress>Povstania českého ľudu 738/7, Košice - Dargovských hrdinov, 04022, Slovensko</FullAddress><SourceCode>08</SourceCode> </Seat> <ReportDate>2020-10-12T14:26:29.3238882+02:00</ReportDate> <LegalFormCd>101</LegalFormCd> <LegalForm>Entrepreneur-physical person-not entered in Business Register</LegalForm> <Ico>50521969</Ico> <TAXID>1048346145</TAXID> <VATID>SK1048346145</VATID> <MainNACE><Code>82.19</Code><Description>Photocopying, document preparation and other specialised office support activities</Description><StartDate>2020-05-31</StartDate> </MainNACE> <ArrayOfSecondaryNace><Nace><Code>46.19</Code><Description>Agents involved in the sale of a variety of goods</Description><StartDate>2018-09-30</StartDate><EndDate>2020-05-31</EndDate></Nace><Nace><Code>73.11</Code><Description>Advertising agencies</Description><StartDate>2018-09-30</StartDate><EndDate>2020-05-31</EndDate></Nace><Nace><Code>52.10</Code><Description>Warehousing and storage</Description><StartDate>2020-05-31</StartDate></Nace><Nace><Code>53.20</Code><Description>Other postal and courier activities</Description><StartDate>2020-05-31</StartDate></Nace><Nace><Code>49.39</Code><Description>Other passenger land transport n.e.c.</Description><StartDate>2018-09-30</StartDate><EndDate>2020-05-31</EndDate></Nace> </ArrayOfSecondaryNace> <SubjectType>P</SubjectType> <Semafor>2</Semafor> <SemaforHistory><Item><StartDate>2017-05-27</StartDate><EndDate>2019-08-17</EndDate><Semafor>2</Semafor></Item><Item><StartDate>2016-10-14</StartDate><EndDate>2017-01-12</EndDate><Semafor>1</Semafor></Item><Item><StartDate>2017-03-18</StartDate><EndDate>2017-05-27</EndDate><Semafor>3</Semafor></Item><Item><StartDate>2017-01-12</StartDate><EndDate>2017-03-18</EndDate><Semafor>2</Semafor></Item><Item><StartDate>2019-08-17</StartDate><EndDate>2020-05-17</EndDate><Semafor>3</Semafor></Item> </SemaforHistory> <PaymentDisciplineIndex>1</PaymentDisciplineIndex> <PaymentDisciplineIndexDescription>C-</PaymentDisciplineIndexDescription> <PaymentDisciplineTrend>0</PaymentDisciplineTrend> <PaymentDisciplineHistory><Item><PDIDate>2020-09-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-09-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-08-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-08-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-07-16</PDIDate><PDIValue>1.05</PDIValue></Item><Item><PDIDate>2020-07-01</PDIDate><PDIValue>1.22</PDIValue></Item><Item><PDIDate>2020-06-16</PDIDate><PDIValue>1.07</PDIValue></Item><Item><PDIDate>2020-06-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-05-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-05-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-04-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-04-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-03-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-03-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-02-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-02-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-01-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2020-01-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-12-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-12-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-11-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-11-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-10-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-10-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-09-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-09-01</PDIDate><PDIValue>0</PDIValue></Item><Item><PDIDate>2019-08-16</PDIDate><PDIValue>0</PDIValue></Item><Item><PDIDate>2019-08-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-07-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-07-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-06-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-06-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-05-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-05-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-04-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-04-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-03-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-03-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-02-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-02-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-01-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2019-01-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2018-12-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2018-12-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2018-11-16</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2018-11-01</PDIDate><PDIValue>1</PDIValue></Item><Item><PDIDate>2018-10-16</PDIDate><PDIValue>1.22</PDIValue></Item><Item><PDIDate>2018-10-01</PDIDate><PDIValue>1.595</PDIValue></Item><Item><PDIDate>2018-09-16</PDIDate><PDIValue>1.97</PDIValue></Item><Item><PDIDate>2018-09-01</PDIDate><PDIValue>2.345</PDIValue></Item><Item><PDIDate>2018-08-16</PDIDate><PDIValue>2.745</PDIValue></Item><Item><PDIDate>2018-08-01</PDIDate><PDIValue>3.12</PDIValue></Item><Item><PDIDate>2018-07-16</PDIDate><PDIValue>3.52</PDIValue></Item><Item><PDIDate>2018-07-01</PDIDate><PDIValue>3.895</PDIValue></Item><Item><PDIDate>2018-06-16</PDIDate><PDIValue>4.27</PDIValue></Item><Item><PDIDate>2018-06-01</PDIDate><PDIValue>4.645</PDIValue></Item><Item><PDIDate>2018-05-16</PDIDate><PDIValue>5.045</PDIValue></Item><Item><PDIDate>2018-05-01</PDIDate><PDIValue>5.42</PDIValue></Item><Item><PDIDate>2018-04-16</PDIDate><PDIValue>5.795</PDIValue></Item><Item><PDIDate>2018-04-01</PDIDate><PDIValue>6.17</PDIValue></Item><Item><PDIDate>2018-03-16</PDIDate><PDIValue>6.57</PDIValue></Item><Item><PDIDate>2018-03-01</PDIDate><PDIValue>6.945</PDIValue></Item><Item><PDIDate>2018-02-16</PDIDate><PDIValue>7.27</PDIValue></Item><Item><PDIDate>2018-02-01</PDIDate><PDIValue>7.645</PDIValue></Item><Item><PDIDate>2018-01-16</PDIDate><PDIValue>8.045</PDIValue></Item><Item><PDIDate>2018-01-01</PDIDate><PDIValue>8.42</PDIValue></Item><Item><PDIDate>2017-12-16</PDIDate><PDIValue>8.82</PDIValue></Item><Item><PDIDate>2017-12-01</PDIDate><PDIValue>9.195</PDIValue></Item><Item><PDIDate>2017-11-16</PDIDate><PDIValue>9.57</PDIValue></Item><Item><PDIDate>2017-11-01</PDIDate><PDIValue>9.945</PDIValue></Item><Item><PDIDate>2017-10-16</PDIDate><PDIValue>10.345</PDIValue></Item><Item><PDIDate>2017-10-01</PDIDate><PDIValue>10.72</PDIValue></Item><Item><PDIDate>2017-09-16</PDIDate><PDIValue>11.095</PDIValue></Item><Item><PDIDate>2017-09-01</PDIDate><PDIValue>11.47</PDIValue></Item><Item><PDIDate>2017-08-16</PDIDate><PDIValue>11.87</PDIValue></Item><Item><PDIDate>2017-08-01</PDIDate><PDIValue>12.245</PDIValue></Item><Item><PDIDate>2017-07-16</PDIDate><PDIValue>12.645</PDIValue></Item><Item><PDIDate>2017-07-01</PDIDate><PDIValue>13.02</PDIValue></Item><Item><PDIDate>2017-06-16</PDIDate><PDIValue>13.395</PDIValue></Item><Item><PDIDate>2017-06-01</PDIDate><PDIValue>13.77</PDIValue></Item><Item><PDIDate>2017-05-16</PDIDate><PDIValue>14.17</PDIValue></Item><Item><PDIDate>2017-05-01</PDIDate><PDIValue>14.545</PDIValue></Item><Item><PDIDate>2017-04-16</PDIDate><PDIValue>14.92</PDIValue></Item><Item><PDIDate>2017-04-01</PDIDate><PDIValue>15.295</PDIValue></Item> </PaymentDisciplineHistory> <DateOfCreation>2016-09-21</DateOfCreation> <BusinessCreation>2016-09-21</BusinessCreation> <VATRegistrationDate>2017-07-03</VATRegistrationDate> <VATCancelDate>2020-03-01</VATCancelDate> <ScopeOfActivities><Activity><Description>Administratívne služby</Description><StartDate>2020-05-14</StartDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Kuriérske služby</Description><StartDate>2020-05-14</StartDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Skladovanie a pomocné činnosti v doprave</Description><StartDate>2020-05-14</StartDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity> </ScopeOfActivities> <ScopeOfActivitiesHistory><Activity><Description>Poskytovanie služby vedenia cudzieho motorového vozidla</Description><StartDate>2016-09-21</StartDate><EndDate>2017-02-28</EndDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Poskytovanie služby vedenia cudzieho motorového vozidla</Description><StartDate>2017-05-22</StartDate><EndDate>2019-08-14</EndDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Kúpa tovaru na účely jeho predaja konečnému spotrebiteľovi (maloobchod) alebo iným prevádzkovateľom živnosti (veľkoobchod)</Description><StartDate>2017-07-10</StartDate><EndDate>2019-08-14</EndDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Sprostredkovateľská činnosť v oblasti obchodu, služieb, výroby</Description><StartDate>2017-07-10</StartDate><EndDate>2019-08-14</EndDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity><Activity><Description>Reklamné a marketingové služby, prieskum trhu a verejnej mienky</Description><StartDate>2017-07-10</StartDate><EndDate>2019-08-14</EndDate><SourceID>08</SourceID><Interruptions/><PersonResponsibleList/><BusinessPremisesList/></Activity> </ScopeOfActivitiesHistory> <Registration><Item><Type>RP</Type><Number>820-81812</Number><Registrar>The District Authority of Košice</Registrar></Item> </Registration> <OwnershipType>Private inland</OwnershipType> <InstitutionalSubsector>Self-employed persons</InstitutionalSubsector> <InstitutionalSubsectorCode>14200</InstitutionalSubsectorCode>  </CompanyIdentification>  <KeyInformation> <TurnoverRangeList><TurnoverRange><Year>2017</Year><ValueCd>E1</ValueCd><Value>0 - 999,999 Thous. EUR</Value></TurnoverRange> </TurnoverRangeList>  </KeyInformation>  <OtherCompanyInformation> <OtherRelationsList><OtherRelation><Name>Štefan</Name><Surname>Sinčák</Surname><Address>  <Street>Povstania českého ľudu 738/7</Street>  <StreetNumber>738</StreetNumber>  <City>Košice - Dargovských hrdinov</City>  <Zip>040 22</Zip>  <Country>Slovak Republic</Country>  <CountryAlpha2>SK</CountryAlpha2>  <FullAddress>Povstania českého ľudu 738/7, Košice - Dargovských hrdinov, 04022, Slovensko</FullAddress>  <SourceCode>08</SourceCode></Address><EntId>47675252</EntId><Position>FOP a osoba: shoda přes jméno a adresu</Position><PositionID>AF03</PositionID><StartDate>2016-09-21</StartDate></OtherRelation> </OtherRelationsList>  </OtherCompanyInformation>  <CompanyRatingCalculationResponse> <IndexCribisLevel>4</IndexCribisLevel> <IndexCribis10Level>3</IndexCribis10Level> <IndexCribis10NefiLevel>3</IndexCribis10NefiLevel> <DateOfLastRequest>2020-09-04</DateOfLastRequest> <FinancialSituation>Not specified</FinancialSituation> <EconomicGroup>Not yet rated</EconomicGroup> <ProbabilityOfDefault>2.27</ProbabilityOfDefault> <ProbabilityUnit>%</ProbabilityUnit> <CreditCapacity>450</CreditCapacity> <CreditUsed>450</CreditUsed> <CreditCurrency>EUR</CreditCurrency> <CreditUnit>1</CreditUnit> <CreditCapacityProtrade>450</CreditCapacityProtrade> <CreditUsedProtrade>450</CreditUsedProtrade>  </CompanyRatingCalculationResponse>  <KeyResultsWarning> <ArrayOfWarning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>0</Historical><Date>2020-09-21</Date><Amount>601.0900</Amount><Currency>EUR</Currency><Abbreviation>D</Abbreviation><SourceCode>DDSR0B02</SourceCode><Source>SP SR</Source></Warning><Warning><Code>I80302</Code><Text>COVID19 - Entity in an endangered sector</Text><Historical>0</Historical><Date>2020-09-10</Date><Abbreviation>c</Abbreviation><SourceCode>SC</SourceCode><Source>CRIF SK</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>0</Historical><Date>2020-09-10</Date><Amount>2281.3100</Amount><Currency>EUR</Currency><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2020-08-17</Date><Amount>433.2000</Amount><Currency>EUR</Currency><EndDate>2020-09-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0B02</SourceCode><Source>SP SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2020-08-13</Date><Amount>2210.4000</Amount><Currency>EUR</Currency><EndDate>2020-09-09</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2020-07-20</Date><Amount>265.3100</Amount><Currency>EUR</Currency><EndDate>2020-08-16</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0B02</SourceCode><Source>SP SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2020-07-11</Date><Amount>2139.4900</Amount><Currency>EUR</Currency><EndDate>2020-08-12</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2020-06-09</Date><Amount>2068.5800</Amount><Currency>EUR</Currency><EndDate>2020-07-10</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>I80303</Code><Text>COVID19 - Entity in the secondary affected sector</Text><Historical>1</Historical><Date>2020-05-06</Date><EndDate>2020-09-10</EndDate><Abbreviation>c</Abbreviation><SourceCode>SC</SourceCode><Source>CRIF SK</Source></Warning><Warning><Code>I80301</Code><Text>COVID19 - Entity in a sector directly affected by decisions of public authorities</Text><Historical>1</Historical><Date>2020-04-26</Date><EndDate>2020-05-05</EndDate><Abbreviation>c</Abbreviation><SourceCode>SC</SourceCode><Source>CRIF SK</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2020-04-14</Date><Amount>2027.4100</Amount><Currency>EUR</Currency><EndDate>2020-06-08</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>ND</Code><Text>Unreliable VAT payer</Text><Historical>1</Historical><Date>2020-02-27</Date><EndDate>2020-03-02</EndDate><Note>2019</Note><Abbreviation>UV</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2020-01-10</Date><Amount>2027.4100</Amount><Currency>EUR</Currency><EndDate>2020-08-12</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-09-07</Date><Amount>2027.4100</Amount><Currency>EUR</Currency><EndDate>2020-01-09</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-08-22</Date><Amount>1999.4100</Amount><Currency>EUR</Currency><EndDate>2019-09-06</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-07-21</Date><Amount>1999.4100</Amount><Currency>EUR</Currency><EndDate>2019-08-21</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-06-21</Date><Amount>1932.6300</Amount><Currency>EUR</Currency><EndDate>2019-07-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>IB00</Code><Text>VAT - Excessive</Text><Historical>1</Historical><Date>2019-06-01</Date><Amount>9.3300</Amount><Currency>EUR</Currency><EndDate>2019-06-30</EndDate><Note>17.12.2019</Note><Abbreviation>VATE</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-05-21</Date><Amount>1865.8500</Amount><Currency>EUR</Currency><EndDate>2019-06-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-04-21</Date><Amount>1799.0700</Amount><Currency>EUR</Currency><EndDate>2019-05-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-04-01</Date><Amount>198.8300</Amount><Currency>EUR</Currency><EndDate>2019-04-30</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0C05</SourceCode><Source>FR SR</Source></Warning><Warning><Code>IB01</Code><Text>VAT - Own tax liability</Text><Historical>1</Historical><Date>2019-04-01</Date><Amount>193.2800</Amount><Currency>EUR</Currency><EndDate>2019-04-30</EndDate><Note>26.09.2019</Note><Abbreviation>VATL</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-03-21</Date><Amount>1732.2900</Amount><Currency>EUR</Currency><EndDate>2019-04-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-03-01</Date><Amount>198.8300</Amount><Currency>EUR</Currency><EndDate>2019-03-31</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0C05</SourceCode><Source>FR SR</Source></Warning><Warning><Code>IB00</Code><Text>VAT - Excessive</Text><Historical>1</Historical><Date>2019-03-01</Date><Amount>1688.0200</Amount><Currency>EUR</Currency><EndDate>2019-03-31</EndDate><Note>26.09.2019</Note><Abbreviation>VATE</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-02-21</Date><Amount>1665.5100</Amount><Currency>EUR</Currency><EndDate>2019-03-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2019-01-21</Date><Amount>1598.7300</Amount><Currency>EUR</Currency><EndDate>2019-02-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>IB01</Code><Text>VAT - Own tax liability</Text><Historical>1</Historical><Date>2019-01-01</Date><Amount>125.8600</Amount><Currency>EUR</Currency><EndDate>2019-01-31</EndDate><Note>28.06.2019</Note><Abbreviation>VATL</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-12-21</Date><Amount>1468.1100</Amount><Currency>EUR</Currency><EndDate>2019-01-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>IB00</Code><Text>VAT - Excessive</Text><Historical>1</Historical><Date>2018-12-01</Date><Amount>30.2800</Amount><Currency>EUR</Currency><EndDate>2018-12-31</EndDate><Note>28.06.2019</Note><Abbreviation>VATE</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-11-21</Date><Amount>1334.0800</Amount><Currency>EUR</Currency><EndDate>2018-12-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-10-21</Date><Amount>1334.0800</Amount><Currency>EUR</Currency><EndDate>2018-11-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-09-21</Date><Amount>1270.2400</Amount><Currency>EUR</Currency><EndDate>2018-10-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>IB01</Code><Text>VAT - Own tax liability</Text><Historical>1</Historical><Date>2018-09-01</Date><Amount>99.6100</Amount><Currency>EUR</Currency><EndDate>2018-09-30</EndDate><Note>29.03.2019</Note><Abbreviation>VATL</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-08-21</Date><Amount>1018.3600</Amount><Currency>EUR</Currency><EndDate>2018-09-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>IB00</Code><Text>VAT - Excessive</Text><Historical>1</Historical><Date>2018-08-01</Date><Amount>257.8900</Amount><Currency>EUR</Currency><EndDate>2018-08-31</EndDate><Note>21.12.2018</Note><Abbreviation>VATE</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-07-21</Date><Amount>1043.6600</Amount><Currency>EUR</Currency><EndDate>2018-08-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>IB00</Code><Text>VAT - Excessive</Text><Historical>1</Historical><Date>2018-07-01</Date><Amount>617.6900</Amount><Currency>EUR</Currency><EndDate>2018-07-31</EndDate><Note>21.12.2018</Note><Abbreviation>VATE</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-06-21</Date><Amount>1107.5000</Amount><Currency>EUR</Currency><EndDate>2018-07-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>IB01</Code><Text>VAT - Own tax liability</Text><Historical>1</Historical><Date>2018-06-01</Date><Amount>74.6600</Amount><Currency>EUR</Currency><EndDate>2018-06-30</EndDate><Note>21.12.2018</Note><Abbreviation>VATL</Abbreviation><SourceCode>DU</SourceCode><Source>DR SR</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-05-21</Date><Amount>1043.6600</Amount><Currency>EUR</Currency><EndDate>2018-06-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-04-21</Date><Amount>979.8200</Amount><Currency>EUR</Currency><EndDate>2018-05-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-03-21</Date><Amount>915.9800</Amount><Currency>EUR</Currency><EndDate>2018-04-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-02-21</Date><Amount>852.1400</Amount><Currency>EUR</Currency><EndDate>2018-03-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2018-01-21</Date><Amount>788.3000</Amount><Currency>EUR</Currency><EndDate>2018-02-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-12-21</Date><Amount>724.4600</Amount><Currency>EUR</Currency><EndDate>2018-01-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-11-21</Date><Amount>662.6500</Amount><Currency>EUR</Currency><EndDate>2017-12-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-10-21</Date><Currency>EUR</Currency><EndDate>2017-11-20</EndDate><Note>Without debts</Note><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-09-21</Date><Amount>338.7900</Amount><Currency>EUR</Currency><EndDate>2017-10-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-08-21</Date><Amount>276.9800</Amount><Currency>EUR</Currency><EndDate>2017-09-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-07-21</Date><Amount>215.1700</Amount><Currency>EUR</Currency><EndDate>2017-08-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-06-21</Date><Amount>153.3600</Amount><Currency>EUR</Currency><EndDate>2017-07-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-05-21</Date><Amount>271.8200</Amount><Currency>EUR</Currency><EndDate>2017-06-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-04-21</Date><Amount>271.8200</Amount><Currency>EUR</Currency><EndDate>2017-05-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-03-21</Date><Amount>271.8200</Amount><Currency>EUR</Currency><EndDate>2017-04-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-02-21</Date><Amount>271.8200</Amount><Currency>EUR</Currency><EndDate>2017-03-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2017-01-21</Date><Amount>272.2800</Amount><Currency>EUR</Currency><EndDate>2017-02-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2016-12-21</Date><Amount>210.4700</Amount><Currency>EUR</Currency><EndDate>2017-01-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning><Warning><Code>PODS</Code><Text>State debt</Text><Historical>1</Historical><Date>2016-11-21</Date><Amount>150.4100</Amount><Currency>EUR</Currency><EndDate>2016-12-20</EndDate><Abbreviation>D</Abbreviation><SourceCode>DDSR0933</SourceCode><Source>Union zdravotná poisťovňa a.s.</Source></Warning> </ArrayOfWarning>  </KeyResultsWarning>  <SourcesList> <Source><SourceCode>08</SourceCode><SourceShortening>ŽR SR</SourceShortening> </Source> <Source><SourceCode>DDSR0933</SourceCode><SourceShortening>Union zdravotná poisťovňa a.s.</SourceShortening> </Source> <Source><SourceCode>DDSR0B02</SourceCode><SourceShortening>SP SR</SourceShortening> </Source> <Source><SourceCode>DDSR0C05</SourceCode><SourceShortening>FR SR</SourceShortening> </Source> <Source><SourceCode>DU</SourceCode><SourceShortening>DR SR</SourceShortening> </Source> <Source><SourceCode>SC</SourceCode><SourceShortening>CRIF SK</SourceShortening> </Source>  </SourcesList></CompanyGlobalReport><DocumentTicket xmlns="urn:crif-cribiscz-GetGlobalReport:2013-05-03">d1679422-860c-eb11-80f9-005056b2243d</DocumentTicket></Data> </CribisGetGlobalReportResult>  </CribisGetGlobalReportResponse></soap:Body></soap:Envelope>', null);
        mocksMap.put('<ws:CribisGetGlobalReport>', cribisReportMock);
        SingleRequestMock cribisExecuteMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><CribisExekuceGetResponse xmlns="https://ws.urplus.sk"><CribisExekuceGetResult><Status><Code>101</Code><Description>OK</Description></Status><Data><SearchResults xmlns="urn:crif-cribiscz-ExekuceGet:2013-01-10"/><Info ObtainedRequests="101" RemainingRequests="950" xmlns="urn:crif-cribiscz-ExekuceGet:2013-01-10"/></Data></CribisExekuceGetResult></CribisExekuceGetResponse></soap:Body></soap:Envelope>', null);
        mocksMap.put('<ws:CribisExekuceGet>', cribisExecuteMock);
        SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
        mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            try {
                creditFactory.requestCompanyReports('1234512345');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: 1234512345', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();

        System.assertEquals('Update Name', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Pavel Dziura', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Planá nad Lužnicí', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

        creditFactoryDataMap.put('street', 'test');
        creditFactoryDataMap.put('postalStreet', 'test');
        creditFactoryDataMap.put('registeredStreet', 'test');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }



    /*******************************************************************************
    *  Summary         : test tax id validation
    *  Created         : 30/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTaxId() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnTaxIdUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Tax Id', addressUpdateData.get('header'));

        Map<String, Object> taxIdFieldsToUpdate = creditFactory.returnTaxIdFieldsToUpdate();
        System.assertEquals(true, taxIdFieldsToUpdate.containsKey('Account'));
        System.assertEquals('41909941', ((Map<String, Object>) taxIdFieldsToUpdate.get('Account')).get('Steuernummer__c'));

        creditFactoryDataMap.put('taxId', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TaxId'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test vat number validation
    *  Created         : 27/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('CZ1048346145', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test trader register number validation
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTradeRegisterNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnTradeRegisterNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Trade Register Number', addressUpdateData.get('header'));

        Map<String, Object> tradeRegisterFieldsToUpdate = creditFactory.returnTradeRegisterNumberFieldsToUpdate();
        System.assertEquals(true, tradeRegisterFieldsToUpdate.containsKey('Account'));
        System.assertEquals('A 77353', ((Map<String, Object>) tradeRegisterFieldsToUpdate.get('Account')).get('HR_Abteilung_HRA_HRB_und_HR_Nummer__c'));
        System.assertEquals('Městský soud v Praze', ((Map<String, Object>) tradeRegisterFieldsToUpdate.get('Account')).get('Ort_der_Registrierung_Handelsregisterort__c'));

        creditFactoryDataMap.put('tradeRegisterNumber', '123412341234');
        creditFactoryDataMap.put('countyCourt', 'Test City');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TradeRegisterNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test contact validation
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
    *  Summary         : test obligation overdue validation
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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

        Opportunity lostOpportunity = CreditFactoryTestUtils.generateOpportunityCZ();
        lostOpportunity.AccountId = account.Id;
        lostOpportunity.StageName = 'Closed Lost';
        lostOpportunity.Gruende_verloren__c = 'Refused Credit';
        insert lostOpportunity;

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'LostOpportunities'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test obligation overdue validation
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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

        cfItem.companiesList.get(0).emailRisk = 'High';
        cfItem.companiesList.get(0).emailExists = 'No';
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmailRisk'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }


    /*******************************************************************************
    *  Summary         : test payment method
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidatePaymentMethod() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);
        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'PaymentMethod'}, true);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        creditFactoryDataMap.put('paymentMethod', 'Banküberweisung');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'PaymentMethod'}, true);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test payment method
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNegativeInformation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Czech Republic');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);
        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'NegativeInformation'}, true);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);

        cfItem.companiesList.get(0).negativeInformation = 'State debt';
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'NegativeInformation'}, true);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '30');
        creditFactoryDataMap.put('desiredPaymentTerms', '14');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('10', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 15', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 10', cfResult.messagesList.get(1).text);
        System.assertEquals('If you want to close your Opportunity with ' +
            'desired billing period and desired payment terms, please refer to Credit.', cfResult.messagesList.get(2).text);
        System.assertEquals('Desired payment terms (14) cannot be provided.', cfResult.messagesList.get(3).text);
        System.assertEquals('Desired billing period (30) cannot be provided.', cfResult.messagesList.get(4).text);

        Map<String, Object> contractCheckFieldsMap = creditFactory.returnContractCheckFieldsToUpdate();
        System.assertEquals(true, contractCheckFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) contractCheckFieldsMap.get('Opportunity')).get('CloseDate'));

        Map<String, Object> updateOpportunityFieldsMap = creditFactory.returnUpdateOpportunityFieldsToUpdate();
        System.assertEquals(true, updateOpportunityFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) updateOpportunityFieldsMap.get('Opportunity')).get('Credit_check_date__c'));

        Map<String, Object> closedWonFieldsMap = creditFactory.returnClosedWonFieldsToUpdate();
        System.assertEquals(true, closedWonFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) closedWonFieldsMap.get('Opportunity')).get('CloseDate'));
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        creditFactoryDataMap.put('desiredBillingPeriod', '7');
        creditFactoryDataMap.put('desiredPaymentTerms', '7');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 02/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 2000;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '2';
        report.Financial_Evaluation__c = false;
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '7');
        creditFactoryDataMap.put('desiredPaymentTerms', '7');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(50, cfResult.securityLevel);
        System.assertEquals('Missing financials', cfResult.depositReason);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('10', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('10', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 4)', cfResult.depositReason);
        System.assertEquals(70, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 4
    *  Created         : 20/01/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '4';
        report.Date_of_Foundation__c = String.valueOf(Date.today());
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('10', cfResult.paymentTerms);
        System.assertEquals(110, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for no rating
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringNoRating() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = null;
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('10', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for no rating
    *  Created         : 20/01/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringNoRating() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = null;
        report.Date_of_Foundation__c = String.valueOf(Date.today());
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring (invalid contact)
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringInvalidContact() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

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
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        Map<String, CreditFactoryValidationItem> reportValidationMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem passedItem = new CreditFactoryValidationItem();
        passedItem.passed = false;
        reportValidationMap.put('Contact', passedItem);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), reportValidationMap);

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('10', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);

        Map<String, Object> pendingDepositFieldsMap = creditFactory.returnPendingDepositFieldsToUpdate();
        System.assertEquals(true, pendingDepositFieldsMap.containsKey('Opportunity'));
        System.assertEquals('Pending deposit', ((Map<String, Object>) pendingDepositFieldsMap.get('Opportunity')).get('CF_Stage__c'));
    }



    /*******************************************************************************
    *  Summary         : test credit scoring (negative info)
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringNegativeInformation() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 1100;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '1';
        report.Number_of_executions__c = 1;
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        Map<String, CreditFactoryValidationItem> reportValidationMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), reportValidationMap);
        System.assertEquals('014', cfResult.statusCode);
    }



    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Czech Republic');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 20000;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Czech Republic');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}