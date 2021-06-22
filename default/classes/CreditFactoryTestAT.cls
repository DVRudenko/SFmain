@IsTest
public class CreditFactoryTestAT {
    
    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityAT();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactAT();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Austria');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Austria');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c creditSafeSettings = CreditFactoryTestUtils.generateCreditreformSettings();
        customSettingsList.add(creditSafeSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Austria', Index__c = 1.15);
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

        Solvency__c solvency = CreditFactoryTestUtils.returnSolvencySettingsAT();
        insert solvency;
    }
    
    
    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplAT);
    }
    
    
    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

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

        System.assertEquals('AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN', company.name);
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        creditFactorySettings.returnSearchValidations();
    }

    
    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

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
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyAT();
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

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
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

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
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSepaAttachments() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

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
    *  Summary         : test validate process opportunity
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountAT();
        dupAccount.Steuernummer__c = 'AT1234568';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityAT();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactAT();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplAT);
    }
    
    
    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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

        System.assertEquals('AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN', company.name);
    }
    
    
    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <ns2:searchResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>en</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-15T12:11:07.636+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>6c0cfe52-30a5-45ac-a90d-a82e82771d3d</ns2:responseid> </ns2:header> <ns2:body> <ns2:hit> <ns2:identificationnumber>09119110000830</ns2:identificationnumber> <ns2:companyname>AT-Kundentestsystem GmbH &amp; Co KG - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:tradename>FLUX</ns2:tradename> <ns2:street>Handelskai</ns2:street> <ns2:housenumber>95</ns2:housenumber> <ns2:housenumberaffix>-101</ns2:housenumberaffix> <ns2:postcode>1200</ns2:postcode> <ns2:city>Wien</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Austria</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-AT-900</ns2:key> <ns2:designation>Ges.m.b.H. &amp; Co. KG</ns2:designation> <ns2:shortdesignation>Ges.m.b.H. &amp; Co. KG</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>true</ns2:additionalinformation> </ns2:hit> <ns2:hit> <ns2:identificationnumber>09159152001683</ns2:identificationnumber> <ns2:companyname>AT Kundentestsystem GMBH - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:tradename>AT-KTO-GMBH</ns2:tradename> <ns2:street>Neugasse</ns2:street> <ns2:housenumber>1</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Austria</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-AT-10</ns2:key> <ns2:designation>Private limited company</ns2:designation> <ns2:shortdesignation>Ges.m.b.H.</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>true</ns2:additionalinformation> </ns2:hit> <ns2:hit> <ns2:identificationnumber>09119110000868</ns2:identificationnumber> <ns2:companyname>AT - Kundentestsystem GMBH 2 - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:tradename>DIE NICHT-VORRÄTIGE GmbH aus A</ns2:tradename> <ns2:street>Kislingerplatz</ns2:street> <ns2:housenumber>1</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Austria</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-AT-10</ns2:key> <ns2:designation>Private limited company</ns2:designation> <ns2:shortdesignation>Ges.m.b.H.</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>true</ns2:additionalinformation> </ns2:hit> <ns2:morehits>false</ns2:morehits> </ns2:body> </ns2:searchResponse> </env:Body> </env:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(3, companiesList.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
            SingleRequestMock creditreformReportMock = new SingleRequestMock(200, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <ns2:reportResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>de</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-15T13:32:07.140+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>1eab22f6-4782-4cc8-9895-59e605d56a21</ns2:responseid> </ns2:header> <ns2:body> <ns2:referencenumber>40651269</ns2:referencenumber> <ns2:identificationnumber>09159152001683</ns2:identificationnumber> <ns2:creationtime>2020-12-15T13:32:06.883+01:00</ns2:creationtime> <ns2:producttype> <ns2:key>PRTY-5</ns2:key> <ns2:designation>Kurzauskunft</ns2:designation> </ns2:producttype> <ns2:reportlanguage>de</ns2:reportlanguage> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:negativereport>false</ns2:negativereport> <ns2:provider>Creditreform St. Pölten</ns2:provider> <ns2:reportdata> <ns2:companyidentification> <ns2:identificationnumber>09159152001683</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-1</ns2:key> <ns2:designation>aktiv</ns2:designation> </ns2:status> <ns2:companyname>AT Kundentestsystem GMBH - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:tradename>AT-KTO-GMBH</ns2:tradename> <ns2:street>Neugasse</ns2:street> <ns2:housenumber>1</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:phone> <ns2:countrycode>+43</ns2:countrycode> <ns2:diallingcode>1</ns2:diallingcode> <ns2:phonenumber>323450</ns2:phonenumber> </ns2:phone> <ns2:fax> <ns2:countrycode>+43</ns2:countrycode> <ns2:diallingcode>1</ns2:diallingcode> <ns2:phonenumber>234324</ns2:phonenumber> </ns2:fax> <ns2:email>info@AT-KTO-GmbH.at</ns2:email> <ns2:website>www.AT-KTO-GmbH.at</ns2:website> </ns2:companyidentification> <ns2:taxdata/> <ns2:legalform> <ns2:presentlegalform> <ns2:key>LEFO-AT-10</ns2:key> <ns2:designation>Gesellschaft mit beschränkter Haftung</ns2:designation> <ns2:shortdesignation>Ges.m.b.H.</ns2:shortdesignation> </ns2:presentlegalform> </ns2:legalform> <ns2:foundation> <ns2:dateoffirstlegalform>1953-08-15</ns2:dateoffirstlegalform> <ns2:ageofcompany>67</ns2:ageofcompany> <ns2:firstlegalform> <ns2:key>LEFO-AT-11</ns2:key> <ns2:designation>Aktiengesellschaft</ns2:designation> <ns2:shortdesignation>AG</ns2:shortdesignation> </ns2:firstlegalform> </ns2:foundation> <ns2:register> <ns2:chapterheading>Firmenbuch</ns2:chapterheading> <ns2:datelegalform>1953-08-15</ns2:datelegalform> <ns2:datelastregisterentry>2011-03-01</ns2:datelastregisterentry> <ns2:registertype> <ns2:key>RETY-AT-50</ns2:key> <ns2:designation>Firmenbuch</ns2:designation> <ns2:shortdesignation>FN</ns2:shortdesignation> </ns2:registertype> <ns2:registerid>54321</ns2:registerid> <ns2:register> <ns2:court>Handelsgericht</ns2:court> <ns2:shortdesignationcourt>HG</ns2:shortdesignationcourt> <ns2:city>Weiz</ns2:city> <ns2:postcode>8160</ns2:postcode> </ns2:register> <ns2:reasonofregister> <ns2:key>RERS-21</ns2:key> <ns2:designation>Prokuraänderung</ns2:designation> </ns2:reasonofregister> </ns2:register> <ns2:deputymanagement> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-200</ns2:key> <ns2:designation>Geschäftsführer</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09119110000829</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:title> <ns2:key>TI-621</ns2:key> <ns2:designation>Master of Arts in Cultural Studies (M.A.)</ns2:designation> <ns2:shortdesignation>M.A.</ns2:shortdesignation> </ns2:title> <ns2:surname>von Kitzewitz KTO</ns2:surname> <ns2:firstname>Kira</ns2:firstname> <ns2:dateofbirth>1958-06-11</ns2:dateofbirth> </ns2:privateperson> <ns2:powerofrepresentation> <ns2:key>PWRP-5</ns2:key> <ns2:designation>alleinvertretungsberechtigt</ns2:designation> </ns2:powerofrepresentation> <ns2:participatingsince>2003-03-04</ns2:participatingsince> <ns2:street>Mollardgasse</ns2:street> <ns2:housenumber>216</ns2:housenumber> <ns2:postcode>1060</ns2:postcode> <ns2:city>Wien</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>grün</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> <ns2:active> <ns2:identificationnumber>09159152001685</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:surname>Ludewig KTO</ns2:surname> <ns2:firstname>Lambert</ns2:firstname> <ns2:dateofbirth>1966-07-28</ns2:dateofbirth> </ns2:privateperson> <ns2:powerofrepresentation> <ns2:key>PWRP-6</ns2:key> <ns2:designation>gemeinsam vertretungsberechtigt</ns2:designation> </ns2:powerofrepresentation> <ns2:participatingsince>2003-03-04</ns2:participatingsince> <ns2:street>Mozartweg</ns2:street> <ns2:housenumber>77</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>grün</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> </ns2:participantcapacities> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-800</ns2:key> <ns2:designation>Prokurist</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09159152001686</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Herr</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Manteuffell KTO</ns2:surname> <ns2:firstname>Meander</ns2:firstname> <ns2:dateofbirth>1957-02-08</ns2:dateofbirth> </ns2:privateperson> <ns2:typeofpowerofattorney> <ns2:key>PWATTY-2</ns2:key> <ns2:designation>Gesamtprokura</ns2:designation> </ns2:typeofpowerofattorney> <ns2:participatingsince>2011-03-24</ns2:participatingsince> <ns2:street>Fürstenplatz</ns2:street> <ns2:housenumber>111</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Gesamtprokura</ns2:paragraph> </ns2:text> </ns2:active> <ns2:active> <ns2:identificationnumber>09159152001687</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Herr</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Nussbaum KTO</ns2:surname> <ns2:firstname>Norbert</ns2:firstname> <ns2:dateofbirth>1965-08-05</ns2:dateofbirth> </ns2:privateperson> <ns2:typeofpowerofattorney> <ns2:key>PWATTY-2</ns2:key> <ns2:designation>Gesamtprokura</ns2:designation> </ns2:typeofpowerofattorney> <ns2:participatingsince>2011-03-24</ns2:participatingsince> <ns2:street>Angerweg</ns2:street> <ns2:housenumber>57</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Gesamtprokura</ns2:paragraph> </ns2:text> </ns2:active> <ns2:active> <ns2:identificationnumber>09159152001688</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Herr</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Ochsenkott KTO</ns2:surname> <ns2:firstname>Oswald</ns2:firstname> <ns2:dateofbirth>1949-12-04</ns2:dateofbirth> </ns2:privateperson> <ns2:typeofpowerofattorney> <ns2:key>PWATTY-2</ns2:key> <ns2:designation>Gesamtprokura</ns2:designation> </ns2:typeofpowerofattorney> <ns2:participatingsince>2011-03-24</ns2:participatingsince> <ns2:street>Mondweg</ns2:street> <ns2:housenumber>12</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Gesamtprokura</ns2:paragraph> </ns2:text> </ns2:active> </ns2:participantcapacities> </ns2:deputymanagement> <ns2:paymentmode> <ns2:paymentmode> <ns2:key>PYMD-10071</ns2:key> <ns2:designation>- entfällt -</ns2:designation> <ns2:grade>0</ns2:grade> </ns2:paymentmode> </ns2:paymentmode> <ns2:creditopinion> <ns2:creditlimitstatement> <ns2:key>CROP-10074</ns2:key> <ns2:designation>- entfällt -</ns2:designation> <ns2:grade>0</ns2:grade> </ns2:creditlimitstatement> <ns2:typeofcreditopinion> <ns2:key>CROP-10074</ns2:key> <ns2:designation>- entfällt -</ns2:designation> <ns2:grade>0</ns2:grade> </ns2:typeofcreditopinion> </ns2:creditopinion> <ns2:negativefacts> <ns2:typeofnegativefacts> <ns2:key>NEFATY-1</ns2:key> <ns2:designation>Negativmerkmale</ns2:designation> </ns2:typeofnegativefacts> <ns2:evaluation> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>grün</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:evaluation> </ns2:negativefacts> <ns2:solvencyfinanceindustry> <ns2:classexplanation>Eine fundierte Bonitätsbewertung ist derzeit nicht möglich.</ns2:classexplanation> <ns2:pdaverage>0.95</ns2:pdaverage> <ns2:pdaveragedate>2020-09-30</ns2:pdaveragedate> <ns2:pdaverageexplanation>Die PD (Probability of Default / Ausfallwahrscheinlichkeit) gibt die Wahrscheinlichkeit an, dass ein Kreditnehmer innerhalb eines Jahres gemäß Basel-II-Kriterien ausfällt. Der Durchschnitt in Österreich liegt bei 0,95 %. (Stand: September 2020)</ns2:pdaverageexplanation> <ns2:assignments> <ns2:note> <ns2:subject>PD-Bereich</ns2:subject> <ns2:line>von (inkl.) bis (exkl.)</ns2:line> </ns2:note> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:assignment> </ns2:assignments> </ns2:solvencyfinanceindustry> <ns2:evaluationsfinanceindustry> <ns2:pdexplanation>Die PD (Probability of Default) gibt die Wahrscheinlichkeit an, dass ein Kreditnehmer innerhalb eines Jahres gemäß Basel II-Kriterien ausfällt. Übertragen auf Creditreform gelten der Bonitätsindex 500 und 600 als Ausfall. Angabe des PD-Bereichs von (inkl.) bis (exkl.)</ns2:pdexplanation> <ns2:evaluator> <ns2:name>Creditreform Bonitätsindex 2.0</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>100 - 262</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>263 - 281</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>282 - 303</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>304 - 354</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>355 - 405</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>406 - 600</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Creditreform Rating AG</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Commerzbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1,0 - 2,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2,4 - 3,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3,0 - 3,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>3,4 - 4,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>4,0 - 4,8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 4,8</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Deutsche Bank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>iAAA - iBBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>iBBB - iBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>iBB+ - iBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>iBB- - iB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>iB+ - iB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= iB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>HypoVereinsbank - UniCredit</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1+ - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2 - 3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>4 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 6-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>KFW Bankengruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>BK1 - BK2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BK2 - BK3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BK3 - BK4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BK4 - BK6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>BK6 - BK7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>BK7</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>CredaRate Solutions GmbH</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>5 - 7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>7 - 9</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>9 - 11</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>11 - 13</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>13 - 15</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Sparkassen Finanzgruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>4 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>6 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>8 - 10</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>10 - 12</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 12</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Postbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>pAAA - pBBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>pBBB+ - pBBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>pBBB- - pBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>pBB - pB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>pB+ - pB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= pB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Volksbanken Raiffeisenbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>0+ - 1d</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>1e - 2a</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>2b - 2c</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>2d - 2e</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>3a - 3b</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 3c</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Standard &amp; Poor\'s</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Verband deutscher Bürgschaftsbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>7 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>9 - 10</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:classvalue> <ns2:class>I</ns2:class> <ns2:classmeaning>Unternehmen mit sehr guter bis guter Bonität</ns2:classmeaning> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>II</ns2:class> <ns2:classmeaning>Unternehmen mit guter bis zufriedenstellender Bonität</ns2:classmeaning> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>III</ns2:class> <ns2:classmeaning>Unternehmen mit befriedigender bzw. noch guter Bonität</ns2:classmeaning> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>IV</ns2:class> <ns2:classmeaning>Unternehmen mit überdurchschnittlichem bis erhöhtem Risiko</ns2:classmeaning> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>V</ns2:class> <ns2:classmeaning>Unternehmen mit hohem Risiko</ns2:classmeaning> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>VI</ns2:class> <ns2:classmeaning>Unternehmen mit sehr hohem Risiko</ns2:classmeaning> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:classvalue> </ns2:evaluationsfinanceindustry> <ns2:turnovercompanyrange> <ns2:currency> <ns2:key>EUR</ns2:key> <ns2:designation>EUR</ns2:designation> </ns2:currency> <ns2:rangeminimum>25000000</ns2:rangeminimum> <ns2:rangemaximum>50000000</ns2:rangemaximum> <ns2:range>25 - 50 Mio. EUR</ns2:range> </ns2:turnovercompanyrange> <ns2:staffcompanyrange> <ns2:rangeminimum>200</ns2:rangeminimum> <ns2:rangemaximum>499</ns2:rangemaximum> <ns2:range>200 - 499 Mitarbeiter</ns2:range> </ns2:staffcompanyrange> <ns2:legaldisclaimer>Diese Auskunft ist nur für den Empfänger bestimmt. Für den Inhalt wird jede Haftung für einfache Fahrlässigkeit abgelehnt. Dies gilt auch für Erfüllungsgehilfen. Wer die Auskunft zur Kenntnis nimmt, unterwirft sich diesen Bedingungen. Der Empfänger darf die übermittelten Daten nur für den Zweck verarbeiten oder nutzen, zu dessen Erfüllung sie ihm übermittelt worden sind. Eine Nutzung für andere Zwecke ist nur unter der Voraussetzung von Art. 6 Abs. 1 f) i.V.m. Abs. 4 EU-DSGVO zulässig.</ns2:legaldisclaimer> <ns2:textreport> <xop:Include href="cid:89e2967d-5a24-4705-a6b0-3aa95f9c5f0b%40onlineservice.creditreform.de" xmlns:xop="http://www.w3.org/2004/08/xop/include"/> </ns2:textreport> </ns2:reportdata> </ns2:body> </ns2:reportResponse> </env:Body> </env:Envelope>', null);
            mocksMap.put('https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', creditreformReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportsItem = creditFactory.requestCompanyReports('09159152001683');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('AT Kundentestsystem GMBH - BITTE NICHT ÄNDERN', reportsItem.companiesList.get(0).name);
        System.assertEquals(null, reportsItem.companiesList.get(0).classRating);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('AT Kundentestsystem GMBH - BITTE NICHT ÄNDERN', reportsList.get(0).Name);
        System.assertEquals(5, reportEmployeesList.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : test request for ordering report
    *  Created         : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testUnavailableReport() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        
        CreditFactoryReportsItem reportsItem;
        Test.startTest();
            SingleRequestMock reportMock = new SingleRequestMock(500, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <env:Fault> <env:Code> <env:Value>env:Receiver</env:Value> </env:Code> <env:Reason> <env:Text xml:lang="en">FaultMsg</env:Text> </env:Reason> <env:Detail> <ns2:servicefault xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>de</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-15T13:57:43.380+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>66d783e5-2c72-4eca-9557-8dcdced00bee</ns2:responseid> </ns2:header> <ns2:body> <ns2:technicalerror>false</ns2:technicalerror> <ns2:errorkey> <ns2:key>ER-1</ns2:key> <ns2:designation>Es gibt detaillierte Fehlermeldungen.</ns2:designation> </ns2:errorkey> <ns2:fault> <ns2:errorkey> <ns2:key>ER-114</ns2:key> <ns2:designation>Das gewählte Produkt ist für das angefragte Unternehmen nicht verfügbar. Sie können eine Wirtschaftsauskunft abrufen oder bestellen.</ns2:designation> </ns2:errorkey> </ns2:fault> </ns2:body> </ns2:servicefault> </env:Detail> </env:Fault> </env:Body> </env:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, reportMock);
            reportsItem = creditFactory.requestCompanyReports('09119110000830');
        Test.stopTest();

        System.assertEquals(true, reportsItem.errorMessage.contains('ER-114'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
            SingleRequestMock creditreformReportMock = new SingleRequestMock(200, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <ns2:reportResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>de</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-15T13:32:07.140+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>1eab22f6-4782-4cc8-9895-59e605d56a21</ns2:responseid> </ns2:header> <ns2:body> <ns2:referencenumber>40651269</ns2:referencenumber> <ns2:identificationnumber>09159152001683</ns2:identificationnumber> <ns2:creationtime>2020-12-15T13:32:06.883+01:00</ns2:creationtime> <ns2:producttype> <ns2:key>PRTY-5</ns2:key> <ns2:designation>Kurzauskunft</ns2:designation> </ns2:producttype> <ns2:reportlanguage>de</ns2:reportlanguage> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:negativereport>false</ns2:negativereport> <ns2:provider>Creditreform St. Pölten</ns2:provider> <ns2:reportdata> <ns2:companyidentification> <ns2:identificationnumber>09159152001683</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-1</ns2:key> <ns2:designation>aktiv</ns2:designation> </ns2:status> <ns2:companyname>AT Kundentestsystem GMBH - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:tradename>AT-KTO-GMBH</ns2:tradename> <ns2:street>Neugasse</ns2:street> <ns2:housenumber>1</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:phone> <ns2:countrycode>+43</ns2:countrycode> <ns2:diallingcode>1</ns2:diallingcode> <ns2:phonenumber>323450</ns2:phonenumber> </ns2:phone> <ns2:fax> <ns2:countrycode>+43</ns2:countrycode> <ns2:diallingcode>1</ns2:diallingcode> <ns2:phonenumber>234324</ns2:phonenumber> </ns2:fax> <ns2:email>info@AT-KTO-GmbH.at</ns2:email> <ns2:website>www.AT-KTO-GmbH.at</ns2:website> </ns2:companyidentification> <ns2:taxdata/> <ns2:legalform> <ns2:presentlegalform> <ns2:key>LEFO-AT-10</ns2:key> <ns2:designation>Gesellschaft mit beschränkter Haftung</ns2:designation> <ns2:shortdesignation>Ges.m.b.H.</ns2:shortdesignation> </ns2:presentlegalform> </ns2:legalform> <ns2:foundation> <ns2:dateoffirstlegalform>1953-08-15</ns2:dateoffirstlegalform> <ns2:ageofcompany>67</ns2:ageofcompany> <ns2:firstlegalform> <ns2:key>LEFO-AT-11</ns2:key> <ns2:designation>Aktiengesellschaft</ns2:designation> <ns2:shortdesignation>AG</ns2:shortdesignation> </ns2:firstlegalform> </ns2:foundation> <ns2:register> <ns2:chapterheading>Firmenbuch</ns2:chapterheading> <ns2:datelegalform>1953-08-15</ns2:datelegalform> <ns2:datelastregisterentry>2011-03-01</ns2:datelastregisterentry> <ns2:registertype> <ns2:key>RETY-AT-50</ns2:key> <ns2:designation>Firmenbuch</ns2:designation> <ns2:shortdesignation>FN</ns2:shortdesignation> </ns2:registertype> <ns2:registerid>54321</ns2:registerid> <ns2:register> <ns2:court>Handelsgericht</ns2:court> <ns2:shortdesignationcourt>HG</ns2:shortdesignationcourt> <ns2:city>Weiz</ns2:city> <ns2:postcode>8160</ns2:postcode> </ns2:register> <ns2:reasonofregister> <ns2:key>RERS-21</ns2:key> <ns2:designation>Prokuraänderung</ns2:designation> </ns2:reasonofregister> </ns2:register> <ns2:deputymanagement> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-200</ns2:key> <ns2:designation>Geschäftsführer</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09119110000829</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:title> <ns2:key>TI-621</ns2:key> <ns2:designation>Master of Arts in Cultural Studies (M.A.)</ns2:designation> <ns2:shortdesignation>M.A.</ns2:shortdesignation> </ns2:title> <ns2:surname>von Kitzewitz KTO</ns2:surname> <ns2:firstname>Kira</ns2:firstname> <ns2:dateofbirth>1958-06-11</ns2:dateofbirth> </ns2:privateperson> <ns2:powerofrepresentation> <ns2:key>PWRP-5</ns2:key> <ns2:designation>alleinvertretungsberechtigt</ns2:designation> </ns2:powerofrepresentation> <ns2:participatingsince>2003-03-04</ns2:participatingsince> <ns2:street>Mollardgasse</ns2:street> <ns2:housenumber>216</ns2:housenumber> <ns2:postcode>1060</ns2:postcode> <ns2:city>Wien</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>grün</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> <ns2:active> <ns2:identificationnumber>09159152001685</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:surname>Ludewig KTO</ns2:surname> <ns2:firstname>Lambert</ns2:firstname> <ns2:dateofbirth>1966-07-28</ns2:dateofbirth> </ns2:privateperson> <ns2:powerofrepresentation> <ns2:key>PWRP-6</ns2:key> <ns2:designation>gemeinsam vertretungsberechtigt</ns2:designation> </ns2:powerofrepresentation> <ns2:participatingsince>2003-03-04</ns2:participatingsince> <ns2:street>Mozartweg</ns2:street> <ns2:housenumber>77</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>grün</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> </ns2:participantcapacities> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-800</ns2:key> <ns2:designation>Prokurist</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09159152001686</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Herr</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Manteuffell KTO</ns2:surname> <ns2:firstname>Meander</ns2:firstname> <ns2:dateofbirth>1957-02-08</ns2:dateofbirth> </ns2:privateperson> <ns2:typeofpowerofattorney> <ns2:key>PWATTY-2</ns2:key> <ns2:designation>Gesamtprokura</ns2:designation> </ns2:typeofpowerofattorney> <ns2:participatingsince>2011-03-24</ns2:participatingsince> <ns2:street>Fürstenplatz</ns2:street> <ns2:housenumber>111</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Gesamtprokura</ns2:paragraph> </ns2:text> </ns2:active> <ns2:active> <ns2:identificationnumber>09159152001687</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Herr</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Nussbaum KTO</ns2:surname> <ns2:firstname>Norbert</ns2:firstname> <ns2:dateofbirth>1965-08-05</ns2:dateofbirth> </ns2:privateperson> <ns2:typeofpowerofattorney> <ns2:key>PWATTY-2</ns2:key> <ns2:designation>Gesamtprokura</ns2:designation> </ns2:typeofpowerofattorney> <ns2:participatingsince>2011-03-24</ns2:participatingsince> <ns2:street>Angerweg</ns2:street> <ns2:housenumber>57</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Gesamtprokura</ns2:paragraph> </ns2:text> </ns2:active> <ns2:active> <ns2:identificationnumber>09159152001688</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>geschäftsfähig</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Herr</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Ochsenkott KTO</ns2:surname> <ns2:firstname>Oswald</ns2:firstname> <ns2:dateofbirth>1949-12-04</ns2:dateofbirth> </ns2:privateperson> <ns2:typeofpowerofattorney> <ns2:key>PWATTY-2</ns2:key> <ns2:designation>Gesamtprokura</ns2:designation> </ns2:typeofpowerofattorney> <ns2:participatingsince>2011-03-24</ns2:participatingsince> <ns2:street>Mondweg</ns2:street> <ns2:housenumber>12</ns2:housenumber> <ns2:postcode>2560</ns2:postcode> <ns2:city>Berndorf</ns2:city> <ns2:country> <ns2:key>AT</ns2:key> <ns2:designation>Österreich</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Gesamtprokura</ns2:paragraph> </ns2:text> </ns2:active> </ns2:participantcapacities> </ns2:deputymanagement> <ns2:paymentmode> <ns2:paymentmode> <ns2:key>PYMD-10071</ns2:key> <ns2:designation>- entfällt -</ns2:designation> <ns2:grade>0</ns2:grade> </ns2:paymentmode> </ns2:paymentmode> <ns2:creditopinion> <ns2:creditlimitstatement> <ns2:key>CROP-10074</ns2:key> <ns2:designation>- entfällt -</ns2:designation> <ns2:grade>0</ns2:grade> </ns2:creditlimitstatement> <ns2:typeofcreditopinion> <ns2:key>CROP-10074</ns2:key> <ns2:designation>- entfällt -</ns2:designation> <ns2:grade>0</ns2:grade> </ns2:typeofcreditopinion> </ns2:creditopinion> <ns2:negativefacts> <ns2:typeofnegativefacts> <ns2:key>NEFATY-1</ns2:key> <ns2:designation>Negativmerkmale</ns2:designation> </ns2:typeofnegativefacts> <ns2:evaluation> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>grün</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:evaluation> </ns2:negativefacts> <ns2:solvencyfinanceindustry> <ns2:classexplanation>Eine fundierte Bonitätsbewertung ist derzeit nicht möglich.</ns2:classexplanation> <ns2:pdaverage>0.95</ns2:pdaverage> <ns2:pdaveragedate>2020-09-30</ns2:pdaveragedate> <ns2:pdaverageexplanation>Die PD (Probability of Default / Ausfallwahrscheinlichkeit) gibt die Wahrscheinlichkeit an, dass ein Kreditnehmer innerhalb eines Jahres gemäß Basel-II-Kriterien ausfällt. Der Durchschnitt in Österreich liegt bei 0,95 %. (Stand: September 2020)</ns2:pdaverageexplanation> <ns2:assignments> <ns2:note> <ns2:subject>PD-Bereich</ns2:subject> <ns2:line>von (inkl.) bis (exkl.)</ns2:line> </ns2:note> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:assignment> </ns2:assignments> </ns2:solvencyfinanceindustry> <ns2:evaluationsfinanceindustry> <ns2:pdexplanation>Die PD (Probability of Default) gibt die Wahrscheinlichkeit an, dass ein Kreditnehmer innerhalb eines Jahres gemäß Basel II-Kriterien ausfällt. Übertragen auf Creditreform gelten der Bonitätsindex 500 und 600 als Ausfall. Angabe des PD-Bereichs von (inkl.) bis (exkl.)</ns2:pdexplanation> <ns2:evaluator> <ns2:name>Creditreform Bonitätsindex 2.0</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>100 - 262</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>263 - 281</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>282 - 303</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>304 - 354</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>355 - 405</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>406 - 600</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Creditreform Rating AG</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Commerzbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1,0 - 2,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2,4 - 3,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3,0 - 3,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>3,4 - 4,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>4,0 - 4,8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 4,8</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Deutsche Bank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>iAAA - iBBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>iBBB - iBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>iBB+ - iBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>iBB- - iB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>iB+ - iB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= iB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>HypoVereinsbank - UniCredit</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1+ - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2 - 3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>4 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 6-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>KFW Bankengruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>BK1 - BK2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BK2 - BK3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BK3 - BK4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BK4 - BK6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>BK6 - BK7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>BK7</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>CredaRate Solutions GmbH</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>5 - 7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>7 - 9</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>9 - 11</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>11 - 13</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>13 - 15</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Sparkassen Finanzgruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>4 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>6 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>8 - 10</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>10 - 12</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 12</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Postbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>pAAA - pBBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>pBBB+ - pBBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>pBBB- - pBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>pBB - pB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>pB+ - pB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= pB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Volksbanken Raiffeisenbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>0+ - 1d</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>1e - 2a</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>2b - 2c</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>2d - 2e</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>3a - 3b</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 3c</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Standard &amp; Poor\'s</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Verband deutscher Bürgschaftsbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>7 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>9 - 10</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:classvalue> <ns2:class>I</ns2:class> <ns2:classmeaning>Unternehmen mit sehr guter bis guter Bonität</ns2:classmeaning> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>II</ns2:class> <ns2:classmeaning>Unternehmen mit guter bis zufriedenstellender Bonität</ns2:classmeaning> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>III</ns2:class> <ns2:classmeaning>Unternehmen mit befriedigender bzw. noch guter Bonität</ns2:classmeaning> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>IV</ns2:class> <ns2:classmeaning>Unternehmen mit überdurchschnittlichem bis erhöhtem Risiko</ns2:classmeaning> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>V</ns2:class> <ns2:classmeaning>Unternehmen mit hohem Risiko</ns2:classmeaning> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>VI</ns2:class> <ns2:classmeaning>Unternehmen mit sehr hohem Risiko</ns2:classmeaning> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:classvalue> </ns2:evaluationsfinanceindustry> <ns2:turnovercompanyrange> <ns2:currency> <ns2:key>EUR</ns2:key> <ns2:designation>EUR</ns2:designation> </ns2:currency> <ns2:rangeminimum>25000000</ns2:rangeminimum> <ns2:rangemaximum>50000000</ns2:rangemaximum> <ns2:range>25 - 50 Mio. EUR</ns2:range> </ns2:turnovercompanyrange> <ns2:staffcompanyrange> <ns2:rangeminimum>200</ns2:rangeminimum> <ns2:rangemaximum>499</ns2:rangemaximum> <ns2:range>200 - 499 Mitarbeiter</ns2:range> </ns2:staffcompanyrange> <ns2:legaldisclaimer>Diese Auskunft ist nur für den Empfänger bestimmt. Für den Inhalt wird jede Haftung für einfache Fahrlässigkeit abgelehnt. Dies gilt auch für Erfüllungsgehilfen. Wer die Auskunft zur Kenntnis nimmt, unterwirft sich diesen Bedingungen. Der Empfänger darf die übermittelten Daten nur für den Zweck verarbeiten oder nutzen, zu dessen Erfüllung sie ihm übermittelt worden sind. Eine Nutzung für andere Zwecke ist nur unter der Voraussetzung von Art. 6 Abs. 1 f) i.V.m. Abs. 4 EU-DSGVO zulässig.</ns2:legaldisclaimer> <ns2:textreport> <xop:Include href="cid:89e2967d-5a24-4705-a6b0-3aa95f9c5f0b%40onlineservice.creditreform.de" xmlns:xop="http://www.w3.org/2004/08/xop/include"/> </ns2:textreport> </ns2:reportdata> </ns2:body> </ns2:reportResponse> </env:Body> </env:Envelope>', null);
            mocksMap.put('https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', creditreformReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('09159152001683');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: 09159152001683', errorMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        Map<String, Object> nameUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();

        System.assertEquals('Update Name', nameUpdateData.get('header'));

        Map<String, Object> nameFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, nameFieldsToUpdate.containsKey('Account'));
        System.assertEquals('AT KUNDENTESTSYSTEM GMBH - BITTE NICHT ÄNDERN', ((Map<String, Object>) nameFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Berndorf', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

        creditFactoryDataMap.put('street', 'test street');
        creditFactoryDataMap.put('postalStreet', 'test postal street');
        creditFactoryDataMap.put('registeredStreet', 'test registered street');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test vat number validation
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('AT87654321', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123456789012');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test tax id validation
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTaxId() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        Map<String, Object> taxUpdateData = creditFactorySettings.returnTaxIdUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Tax Id', taxUpdateData.get('header'));

        Map<String, Object> taxIdFieldsToUpdate = creditFactory.returnTaxIdFieldsToUpdate();
        System.assertEquals(true, taxIdFieldsToUpdate.containsKey('Account'));
        System.assertEquals('AT1234567', ((Map<String, Object>) taxIdFieldsToUpdate.get('Account')).get('Steuernummer__c'));

        creditFactoryDataMap.put('taxId', '123456789012');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TaxId'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test swift bic validation
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSwiftBic() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        Map<String, Object> swiftBicUpdateData = creditFactorySettings.returnSwiftBicUpdateData(internalCompany);

        System.assertEquals('Update SWIFT BIC', swiftBicUpdateData.get('header'));

        Map<String, Object> swiftBicFieldsToUpdate = creditFactory.returnSwiftBicFieldsToUpdate();
        System.assertEquals(true, swiftBicFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('BCEELULL', ((Map<String, Object>) swiftBicFieldsToUpdate.get('Opportunity')).get('SWIFT_BIC__c'));

        creditFactoryDataMap.put('requestedSwiftBic', '1234567890');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'SwiftBic'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test mandate type validation
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateMandateType() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Austria');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 1
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = String.valueOf(Date.today());
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 3
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = String.valueOf(Date.today());
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 4
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '4';
        report.Credit_Limit__c = '100';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(4, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 4
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = String.valueOf(Date.today());
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 5
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = String.valueOf(Date.today());
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 6
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating6() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '6';
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 6)', cfResult.depositReason);
        System.assertEquals(110, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for no rating
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringNoRating() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (no rating)', cfResult.depositReason);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for no rating
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringNoRating() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = String.valueOf(Date.today());
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for no rating
    *  Created         : 16/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Austria');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 10000;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Austria');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}