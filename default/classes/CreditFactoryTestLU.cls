@IsTest
public class CreditFactoryTestLU {
    
    
    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityLU();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactLU();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Luxembourg');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Luxembourg');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c creditreformSettings = CreditFactoryTestUtils.generateCreditreformSettings();
        creditreformSettings.Name = 'CreditreformLU';
        customSettingsList.add(creditreformSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Luxembourg', Index__c = 1.00);
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

        Solvency__c solvency = CreditFactoryTestUtils.returnSolvencySettingsLU();
        insert solvency;
    }
    
    
    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplLU);
    }
    
    
    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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

        System.assertEquals('LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', company.name);
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        creditFactorySettings.returnSearchValidations();
    }

    
    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyLU();
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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
    *  Summary         : test sepa attachment
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSepaAttachments() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountLU();
        dupAccount.Steuernummer__c = 'LU1234568';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityLU();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactLU();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplLU);
    }
    
    
    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        System.assertEquals('LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', company.name);
    }
    
    
    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <ns2:searchResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>en</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-22T12:26:55.988+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>6d0cd8c4-870c-4d4d-8e1f-af276ccd78cc</ns2:responseid> </ns2:header> <ns2:body> <ns2:hit> <ns2:identificationnumber>09379370071104</ns2:identificationnumber> <ns2:companyname>LU- Kundentestsystem SA NEGATIV - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:street>Rue Henri IV</ns2:street> <ns2:housenumber>345</ns2:housenumber> <ns2:postcode>2543</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>false</ns2:additionalinformation> </ns2:hit> <ns2:hit> <ns2:identificationnumber>09379370071100</ns2:identificationnumber> <ns2:companyname>LU- Kundentestsystem SARL NEGATIV - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:street>Rue de Pays</ns2:street> <ns2:housenumber>98</ns2:housenumber> <ns2:postcode>1234</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-LU-10</ns2:key> <ns2:designation>Société à responsabilité limitée</ns2:designation> <ns2:shortdesignation>Sarl</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>false</ns2:additionalinformation> </ns2:hit> <ns2:hit> <ns2:identificationnumber>09379370071091</ns2:identificationnumber> <ns2:companyname>LU Kundentestsystem AG - BITTE NICHT ÄNDERN, leer</ns2:companyname> <ns2:street>Allée Francois</ns2:street> <ns2:housenumber>197</ns2:housenumber> <ns2:postcode>2520</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>false</ns2:additionalinformation> </ns2:hit> <ns2:morehits>false</ns2:morehits> </ns2:body> </ns2:searchResponse> </env:Body> </env:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(3, companiesList.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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
            SingleRequestMock creditreformReportMock = new SingleRequestMock(200, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <ns2:reportResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>en</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-22T12:54:28.202+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>aa087f1b-8891-47eb-b72d-bd6fa34670fc</ns2:responseid> </ns2:header> <ns2:body> <ns2:referencenumber>40653139</ns2:referencenumber> <ns2:identificationnumber>09379370071090</ns2:identificationnumber> <ns2:creationtime>2020-12-22T12:54:27.976+01:00</ns2:creationtime> <ns2:producttype> <ns2:key>PRTY-5</ns2:key> <ns2:designation>Brief Report (PD)</ns2:designation> </ns2:producttype> <ns2:reportlanguage>en</ns2:reportlanguage> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:negativereport>false</ns2:negativereport> <ns2:provider>Creditreform Luxembourg</ns2:provider> <ns2:reportdata> <ns2:companyidentification> <ns2:identificationnumber>09379370071090</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:status> <ns2:companyname>LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:tradename>KTO TV International</ns2:tradename> <ns2:street>Bld. Pierre Rot</ns2:street> <ns2:housenumber>169</ns2:housenumber> <ns2:postcode>1543</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:phone> <ns2:countrycode>+352</ns2:countrycode> <ns2:diallingcode>234</ns2:diallingcode> <ns2:phonenumber>2345540</ns2:phonenumber> </ns2:phone> <ns2:fax> <ns2:countrycode>+352</ns2:countrycode> <ns2:diallingcode>234</ns2:diallingcode> <ns2:phonenumber>314125</ns2:phonenumber> </ns2:fax> <ns2:email>info@ktogroup.com</ns2:email> <ns2:website>www.ktogroup.com</ns2:website> </ns2:companyidentification> <ns2:taxdata/> <ns2:legalform> <ns2:presentlegalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:presentlegalform> </ns2:legalform> <ns2:foundation> <ns2:dateoffoundation>1972-12-20</ns2:dateoffoundation> <ns2:ageofcompany>48</ns2:ageofcompany> <ns2:firstlegalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:firstlegalform> </ns2:foundation> <ns2:register> <ns2:chapterheading>Trade register</ns2:chapterheading> <ns2:datelegalform>1972-12-20</ns2:datelegalform> <ns2:registertype> <ns2:key>RETY-LU-22</ns2:key> <ns2:designation>B</ns2:designation> <ns2:shortdesignation>B</ns2:shortdesignation> </ns2:registertype> <ns2:registerid>11.123.2</ns2:registerid> <ns2:register> <ns2:court>District Court</ns2:court> <ns2:shortdesignationcourt>BG</ns2:shortdesignationcourt> <ns2:city>Luxembourg</ns2:city> <ns2:postcode>2080</ns2:postcode> </ns2:register> </ns2:register> <ns2:deputymanagement> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-205</ns2:key> <ns2:designation>Board of Administration</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09379370071092</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Mr.</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Auteil - KTO</ns2:surname> <ns2:firstname>Alain</ns2:firstname> <ns2:dateofbirth>1967-07-31</ns2:dateofbirth> </ns2:privateperson> <ns2:function> <ns2:key>SCFU-25</ns2:key> <ns2:designation>President</ns2:designation> </ns2:function> <ns2:participatingsince>2011-03-25</ns2:participatingsince> <ns2:street>Rue de Mersch</ns2:street> <ns2:housenumber>31</ns2:housenumber> <ns2:postcode>7470</ns2:postcode> <ns2:city>Sael</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Präsident</ns2:paragraph> </ns2:text> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> <ns2:active> <ns2:identificationnumber>09379370071093</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:surname>Bonpoint KTO</ns2:surname> <ns2:firstname>Bernard</ns2:firstname> <ns2:dateofbirth>1955-04-19</ns2:dateofbirth> </ns2:privateperson> <ns2:function> <ns2:key>SCFU-30</ns2:key> <ns2:designation>Managing director</ns2:designation> </ns2:function> <ns2:participatingsince>2011-03-25</ns2:participatingsince> <ns2:street>Rue de Napoli</ns2:street> <ns2:housenumber>25</ns2:housenumber> <ns2:postcode>1456</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Geschäftsführender Direktor</ns2:paragraph> </ns2:text> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> <ns2:active> <ns2:identificationnumber>09379370071095</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Mr.</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Dupont KTO</ns2:surname> <ns2:firstname>Daniel</ns2:firstname> </ns2:privateperson> <ns2:function> <ns2:key>SCFU-30</ns2:key> <ns2:designation>Managing director</ns2:designation> </ns2:function> <ns2:participatingsince>1972-12-20</ns2:participatingsince> <ns2:city>Reims</ns2:city> <ns2:country> <ns2:key>FR</ns2:key> <ns2:designation>France</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Geschäftsführender Direktor</ns2:paragraph> </ns2:text> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> </ns2:participantcapacities> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-106</ns2:key> <ns2:designation>Commissioner</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09379370071094</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:surname>Clement KTO</ns2:surname> <ns2:firstname>Cecile</ns2:firstname> <ns2:dateofbirth>1967-03-14</ns2:dateofbirth> </ns2:privateperson> <ns2:participatingsince>2011-03-25</ns2:participatingsince> <ns2:street>Rue Henri IV</ns2:street> <ns2:housenumber>245</ns2:housenumber> <ns2:postcode>1453</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> </ns2:active> </ns2:participantcapacities> </ns2:deputymanagement> <ns2:paymentmode> <ns2:paymentmode> <ns2:key>PYMD-11</ns2:key> <ns2:designation>Using of cash discounts (if offered by the supplier)</ns2:designation> <ns2:grade>11</ns2:grade> </ns2:paymentmode> </ns2:paymentmode> <ns2:creditopinion> <ns2:typeofcreditopinion> <ns2:key>CROP-11</ns2:key> <ns2:designation>Credits and business connections are recommended.</ns2:designation> <ns2:grade>11</ns2:grade> </ns2:typeofcreditopinion> </ns2:creditopinion> <ns2:negativefacts> <ns2:typeofnegativefacts> <ns2:key>NEFATY-1</ns2:key> <ns2:designation>Negative facts</ns2:designation> </ns2:typeofnegativefacts> <ns2:evaluation> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:evaluation> </ns2:negativefacts> <ns2:solvencyfinanceindustry> <ns2:class>I</ns2:class> <ns2:classmeaning>very good to good solvency</ns2:classmeaning> <ns2:classexplanation>The risk class I means "very good to good solvency".</ns2:classexplanation> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> <ns2:pdaverage>1.06</ns2:pdaverage> <ns2:pdaveragedate>2020-09-30</ns2:pdaveragedate> <ns2:pdaverageexplanation>The PD (Probability of Default) shows the probability that a debtor defaults within one year according to Basel II-criteria. The average amounts to 1,06 %. (as of: September 2020)</ns2:pdaverageexplanation> <ns2:assignments> <ns2:note> <ns2:subject>PD-Range</ns2:subject> <ns2:line>from (incl.) to (excl.)</ns2:line> </ns2:note> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:assignment> </ns2:assignments> </ns2:solvencyfinanceindustry> <ns2:evaluationsfinanceindustry> <ns2:class>I</ns2:class> <ns2:classmeaning>Company with a very good to good solvency</ns2:classmeaning> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> <ns2:pdexplanation>The PD (Probability of Default) shows the probability that a debtor defaults within one year according to Basel II-criteria. Applied to Creditreform the Solvency Index 500 and 600 is considered as default. Indication of the PD-Range from (incl.) to (excl.)</ns2:pdexplanation> <ns2:evaluator> <ns2:name>Creditreform Bonitätsindex 2.0</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>100 - 217</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>218 - 262</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>263 - 283</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>284 - 351</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>352 - 411</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>412 - 600</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Creditreform Rating AG</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Commerzbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1,0 - 2,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2,4 - 3,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3,0 - 3,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>3,4 - 4,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>4,0 - 4,8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 4,8</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Deutsche Bank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>iAAA - iBBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>iBBB - iBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>iBB+ - iBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>iBB- - iB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>iB+ - iB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= iB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>HypoVereinsbank - UniCredit</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1+ - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2 - 3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>4 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 6-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>KFW Bankengruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>BK1 - BK2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BK2 - BK3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BK3 - BK4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BK4 - BK6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>BK6 - BK7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>BK7</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>CredaRate Solutions GmbH</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>5 - 7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>7 - 9</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>9 - 11</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>11 - 13</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>13 - 15</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Sparkassen Finanzgruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>4 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>6 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>8 - 10</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>10 - 12</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 12</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Postbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>pAAA - pBBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>pBBB+ - pBBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>pBBB- - pBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>pBB - pB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>pB+ - pB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= pB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Volksbanken Raiffeisenbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>0+ - 1d</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>1e - 2a</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>2b - 2c</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>2d - 2e</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>3a - 3b</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 3c</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Standard &amp; Poor\'s</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Verband deutscher Bürgschaftsbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>7 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>9 - 10</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:classvalue> <ns2:class>I</ns2:class> <ns2:classmeaning>Company with a very good to good solvency</ns2:classmeaning> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>II</ns2:class> <ns2:classmeaning>Company with a good to satisfactory solvency</ns2:classmeaning> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>III</ns2:class> <ns2:classmeaning>Company with a satisfactory and/or still good solvency</ns2:classmeaning> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>IV</ns2:class> <ns2:classmeaning>Company with a higher-than-average to increased risk</ns2:classmeaning> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>V</ns2:class> <ns2:classmeaning>Company with a high risk</ns2:classmeaning> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>VI</ns2:class> <ns2:classmeaning>Company with a very high risk</ns2:classmeaning> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:classvalue> </ns2:evaluationsfinanceindustry> <ns2:turnovercompanyrange> <ns2:currency> <ns2:key>EUR</ns2:key> <ns2:designation>EUR</ns2:designation> </ns2:currency> <ns2:rangeminimum>100000000</ns2:rangeminimum> <ns2:rangemaximum>500000000</ns2:rangemaximum> <ns2:range>100 - 500 M. EUR</ns2:range> </ns2:turnovercompanyrange> <ns2:staffcompanyrange> <ns2:rangeminimum>100</ns2:rangeminimum> <ns2:rangemaximum>199</ns2:rangemaximum> <ns2:range>100 - 199 persons</ns2:range> </ns2:staffcompanyrange> <ns2:legaldisclaimer>This report is only intended for the recipient. No liability for slight negligence is accepted for the content. This also applies to the assistants. Any person taking note of the report agrees to these conditions. The recipient may process or use the transmitted data only for the purpose it was transmitted for. A use for any other purpose is only permitted under the preconditions of Sec. 6, paragraph 1 f) in conjunction with paragraph 4 GDPR (EU).</ns2:legaldisclaimer> <ns2:textreport> <xop:Include href="cid:2a438a9c-6b71-4485-aef6-086008d16653%40onlineservice.creditreform.de" xmlns:xop="http://www.w3.org/2004/08/xop/include"/> </ns2:textreport> </ns2:reportdata> </ns2:body> </ns2:reportResponse> </env:Body> </env:Envelope>', null);
            mocksMap.put('https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', creditreformReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportsItem = creditFactory.requestCompanyReports('09379370071090');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN', reportsItem.companiesList.get(0).name);
        System.assertEquals('1', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN', reportsList.get(0).Name);
        System.assertEquals(4, reportEmployeesList.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : test request for ordering report
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testUnavailableReport() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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
            reportsItem = creditFactory.requestCompanyReports('09379370071090');
        Test.stopTest();

        System.assertEquals(true, reportsItem.errorMessage.contains('ER-114'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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
            SingleRequestMock creditreformReportMock = new SingleRequestMock(200, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <ns2:reportResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>en</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-22T12:54:28.202+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>aa087f1b-8891-47eb-b72d-bd6fa34670fc</ns2:responseid> </ns2:header> <ns2:body> <ns2:referencenumber>40653139</ns2:referencenumber> <ns2:identificationnumber>09379370071090</ns2:identificationnumber> <ns2:creationtime>2020-12-22T12:54:27.976+01:00</ns2:creationtime> <ns2:producttype> <ns2:key>PRTY-5</ns2:key> <ns2:designation>Brief Report (PD)</ns2:designation> </ns2:producttype> <ns2:reportlanguage>en</ns2:reportlanguage> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:negativereport>false</ns2:negativereport> <ns2:provider>Creditreform Luxembourg</ns2:provider> <ns2:reportdata> <ns2:companyidentification> <ns2:identificationnumber>09379370071090</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:status> <ns2:companyname>LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:tradename>KTO TV International</ns2:tradename> <ns2:street>Bld. Pierre Rot</ns2:street> <ns2:housenumber>169</ns2:housenumber> <ns2:postcode>1543</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:phone> <ns2:countrycode>+352</ns2:countrycode> <ns2:diallingcode>234</ns2:diallingcode> <ns2:phonenumber>2345540</ns2:phonenumber> </ns2:phone> <ns2:fax> <ns2:countrycode>+352</ns2:countrycode> <ns2:diallingcode>234</ns2:diallingcode> <ns2:phonenumber>314125</ns2:phonenumber> </ns2:fax> <ns2:email>info@ktogroup.com</ns2:email> <ns2:website>www.ktogroup.com</ns2:website> </ns2:companyidentification> <ns2:taxdata/> <ns2:legalform> <ns2:presentlegalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:presentlegalform> </ns2:legalform> <ns2:foundation> <ns2:dateoffoundation>1972-12-20</ns2:dateoffoundation> <ns2:ageofcompany>48</ns2:ageofcompany> <ns2:firstlegalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:firstlegalform> </ns2:foundation> <ns2:register> <ns2:chapterheading>Trade register</ns2:chapterheading> <ns2:datelegalform>1972-12-20</ns2:datelegalform> <ns2:registertype> <ns2:key>RETY-LU-22</ns2:key> <ns2:designation>B</ns2:designation> <ns2:shortdesignation>B</ns2:shortdesignation> </ns2:registertype> <ns2:registerid>11.123.2</ns2:registerid> <ns2:register> <ns2:court>District Court</ns2:court> <ns2:shortdesignationcourt>BG</ns2:shortdesignationcourt> <ns2:city>Luxembourg</ns2:city> <ns2:postcode>2080</ns2:postcode> </ns2:register> </ns2:register> <ns2:deputymanagement> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-205</ns2:key> <ns2:designation>Board of Administration</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09379370071092</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Mr.</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Auteil - KTO</ns2:surname> <ns2:firstname>Alain</ns2:firstname> <ns2:dateofbirth>1967-07-31</ns2:dateofbirth> </ns2:privateperson> <ns2:function> <ns2:key>SCFU-25</ns2:key> <ns2:designation>President</ns2:designation> </ns2:function> <ns2:participatingsince>2011-03-25</ns2:participatingsince> <ns2:street>Rue de Mersch</ns2:street> <ns2:housenumber>31</ns2:housenumber> <ns2:postcode>7470</ns2:postcode> <ns2:city>Sael</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Präsident</ns2:paragraph> </ns2:text> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> <ns2:active> <ns2:identificationnumber>09379370071093</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:surname>Bonpoint KTO</ns2:surname> <ns2:firstname>Bernard</ns2:firstname> <ns2:dateofbirth>1955-04-19</ns2:dateofbirth> </ns2:privateperson> <ns2:function> <ns2:key>SCFU-30</ns2:key> <ns2:designation>Managing director</ns2:designation> </ns2:function> <ns2:participatingsince>2011-03-25</ns2:participatingsince> <ns2:street>Rue de Napoli</ns2:street> <ns2:housenumber>25</ns2:housenumber> <ns2:postcode>1456</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Geschäftsführender Direktor</ns2:paragraph> </ns2:text> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> <ns2:active> <ns2:identificationnumber>09379370071095</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:salutation> <ns2:key>SA-1</ns2:key> <ns2:designation>Mr.</ns2:designation> </ns2:salutation> <ns2:privateperson> <ns2:surname>Dupont KTO</ns2:surname> <ns2:firstname>Daniel</ns2:firstname> </ns2:privateperson> <ns2:function> <ns2:key>SCFU-30</ns2:key> <ns2:designation>Managing director</ns2:designation> </ns2:function> <ns2:participatingsince>1972-12-20</ns2:participatingsince> <ns2:city>Reims</ns2:city> <ns2:country> <ns2:key>FR</ns2:key> <ns2:designation>France</ns2:designation> </ns2:country> <ns2:text> <ns2:paragraph>Geschäftsführender Direktor</ns2:paragraph> </ns2:text> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:active> </ns2:participantcapacities> <ns2:participantcapacities> <ns2:capacity> <ns2:key>PAPP-106</ns2:key> <ns2:designation>Commissioner</ns2:designation> </ns2:capacity> <ns2:active> <ns2:identificationnumber>09379370071094</ns2:identificationnumber> <ns2:status> <ns2:key>PEST-8</ns2:key> <ns2:designation>capable of contracting</ns2:designation> </ns2:status> <ns2:privateperson> <ns2:surname>Clement KTO</ns2:surname> <ns2:firstname>Cecile</ns2:firstname> <ns2:dateofbirth>1967-03-14</ns2:dateofbirth> </ns2:privateperson> <ns2:participatingsince>2011-03-25</ns2:participatingsince> <ns2:street>Rue Henri IV</ns2:street> <ns2:housenumber>245</ns2:housenumber> <ns2:postcode>1453</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> </ns2:active> </ns2:participantcapacities> </ns2:deputymanagement> <ns2:paymentmode> <ns2:paymentmode> <ns2:key>PYMD-11</ns2:key> <ns2:designation>Using of cash discounts (if offered by the supplier)</ns2:designation> <ns2:grade>11</ns2:grade> </ns2:paymentmode> </ns2:paymentmode> <ns2:creditopinion> <ns2:typeofcreditopinion> <ns2:key>CROP-11</ns2:key> <ns2:designation>Credits and business connections are recommended.</ns2:designation> <ns2:grade>11</ns2:grade> </ns2:typeofcreditopinion> </ns2:creditopinion> <ns2:negativefacts> <ns2:typeofnegativefacts> <ns2:key>NEFATY-1</ns2:key> <ns2:designation>Negative facts</ns2:designation> </ns2:typeofnegativefacts> <ns2:evaluation> <ns2:trafficlight> <ns2:key>TL-10</ns2:key> <ns2:designation>green</ns2:designation> <ns2:grade>10</ns2:grade> </ns2:trafficlight> </ns2:evaluation> </ns2:negativefacts> <ns2:solvencyfinanceindustry> <ns2:class>I</ns2:class> <ns2:classmeaning>very good to good solvency</ns2:classmeaning> <ns2:classexplanation>The risk class I means "very good to good solvency".</ns2:classexplanation> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> <ns2:pdaverage>1.06</ns2:pdaverage> <ns2:pdaveragedate>2020-09-30</ns2:pdaveragedate> <ns2:pdaverageexplanation>The PD (Probability of Default) shows the probability that a debtor defaults within one year according to Basel II-criteria. The average amounts to 1,06 %. (as of: September 2020)</ns2:pdaverageexplanation> <ns2:assignments> <ns2:note> <ns2:subject>PD-Range</ns2:subject> <ns2:line>from (incl.) to (excl.)</ns2:line> </ns2:note> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:assignment> </ns2:assignments> </ns2:solvencyfinanceindustry> <ns2:evaluationsfinanceindustry> <ns2:class>I</ns2:class> <ns2:classmeaning>Company with a very good to good solvency</ns2:classmeaning> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> <ns2:pdexplanation>The PD (Probability of Default) shows the probability that a debtor defaults within one year according to Basel II-criteria. Applied to Creditreform the Solvency Index 500 and 600 is considered as default. Indication of the PD-Range from (incl.) to (excl.)</ns2:pdexplanation> <ns2:evaluator> <ns2:name>Creditreform Bonitätsindex 2.0</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>100 - 217</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>218 - 262</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>263 - 283</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>284 - 351</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>352 - 411</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>412 - 600</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Creditreform Rating AG</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Commerzbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1,0 - 2,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2,4 - 3,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3,0 - 3,4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>3,4 - 4,0</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>4,0 - 4,8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 4,8</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Deutsche Bank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>iAAA - iBBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>iBBB - iBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>iBB+ - iBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>iBB- - iB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>iB+ - iB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= iB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>HypoVereinsbank - UniCredit</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1+ - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>2 - 3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>3 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>4 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 6-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>KFW Bankengruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>BK1 - BK2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BK2 - BK3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BK3 - BK4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BK4 - BK6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>BK6 - BK7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>BK7</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>CredaRate Solutions GmbH</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 5</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>5 - 7</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>7 - 9</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>9 - 11</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>11 - 13</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>13 - 15</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Sparkassen Finanzgruppe</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>4 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>6 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>8 - 10</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>10 - 12</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 12</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Postbank</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>pAAA - pBBB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>pBBB+ - pBBB-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>pBBB- - pBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>pBB - pB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>pB+ - pB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= pB-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Volksbanken Raiffeisenbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>0+ - 1d</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>1e - 2a</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>2b - 2c</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>2d - 2e</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>3a - 3b</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= 3c</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Standard &amp; Poor\'s</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>AAA - BBB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>BBB - BB+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>BB+ - BB</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>BB - B+</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>B+ - B-</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>>= B-</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:evaluator> <ns2:name>Verband deutscher Bürgschaftsbanken</ns2:name> <ns2:assignment> <ns2:class>I</ns2:class> <ns2:classofevaluator>1 - 2</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>II</ns2:class> <ns2:classofevaluator>3</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>III</ns2:class> <ns2:classofevaluator>4</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>IV</ns2:class> <ns2:classofevaluator>5 - 6</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>V</ns2:class> <ns2:classofevaluator>7 - 8</ns2:classofevaluator> </ns2:assignment> <ns2:assignment> <ns2:class>VI</ns2:class> <ns2:classofevaluator>9 - 10</ns2:classofevaluator> </ns2:assignment> </ns2:evaluator> <ns2:classvalue> <ns2:class>I</ns2:class> <ns2:classmeaning>Company with a very good to good solvency</ns2:classmeaning> <ns2:pdrange>0 % - 0,3 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>II</ns2:class> <ns2:classmeaning>Company with a good to satisfactory solvency</ns2:classmeaning> <ns2:pdrange>0,3 % - 0,7 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>III</ns2:class> <ns2:classmeaning>Company with a satisfactory and/or still good solvency</ns2:classmeaning> <ns2:pdrange>0,7 % - 1,5 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>IV</ns2:class> <ns2:classmeaning>Company with a higher-than-average to increased risk</ns2:classmeaning> <ns2:pdrange>1,5 % - 3,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>V</ns2:class> <ns2:classmeaning>Company with a high risk</ns2:classmeaning> <ns2:pdrange>3,0 % - 8,0 %</ns2:pdrange> </ns2:classvalue> <ns2:classvalue> <ns2:class>VI</ns2:class> <ns2:classmeaning>Company with a very high risk</ns2:classmeaning> <ns2:pdrange>8,0 % - 100 %</ns2:pdrange> </ns2:classvalue> </ns2:evaluationsfinanceindustry> <ns2:turnovercompanyrange> <ns2:currency> <ns2:key>EUR</ns2:key> <ns2:designation>EUR</ns2:designation> </ns2:currency> <ns2:rangeminimum>100000000</ns2:rangeminimum> <ns2:rangemaximum>500000000</ns2:rangemaximum> <ns2:range>100 - 500 M. EUR</ns2:range> </ns2:turnovercompanyrange> <ns2:staffcompanyrange> <ns2:rangeminimum>100</ns2:rangeminimum> <ns2:rangemaximum>199</ns2:rangemaximum> <ns2:range>100 - 199 persons</ns2:range> </ns2:staffcompanyrange> <ns2:legaldisclaimer>This report is only intended for the recipient. No liability for slight negligence is accepted for the content. This also applies to the assistants. Any person taking note of the report agrees to these conditions. The recipient may process or use the transmitted data only for the purpose it was transmitted for. A use for any other purpose is only permitted under the preconditions of Sec. 6, paragraph 1 f) in conjunction with paragraph 4 GDPR (EU).</ns2:legaldisclaimer> <ns2:textreport> <xop:Include href="cid:2a438a9c-6b71-4485-aef6-086008d16653%40onlineservice.creditreform.de" xmlns:xop="http://www.w3.org/2004/08/xop/include"/> </ns2:textreport> </ns2:reportdata> </ns2:body> </ns2:reportResponse> </env:Body> </env:Envelope>', null);
            mocksMap.put('https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', creditreformReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('09379370071090');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: 09379370071090', errorMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test contact validation
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');

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
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();

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
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }
    
    
    /*******************************************************************************
    *  Summary         : test payment method
    *  Created         : 22/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidatePaymentMethod() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Luxembourg');

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
    *  Summary         : test credit scoring for rating 1
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 1
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
        update testOpportunity;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 3
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 4
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 2000;
        update testOpportunity;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low Recommended CL', cfResult.depositReason);
        System.assertEquals(4, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 4
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Low credit rating (rating 5)', cfResult.depositReason);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 5
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 6
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating6() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(110, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for no rating
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringNoRating() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for no rating
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringNoRating() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        testOpportunity.Rechnungsperiode_2__c = '7';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for no rating
    *  Created         : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Luxembourg');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Luxembourg');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}