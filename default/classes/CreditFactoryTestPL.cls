@isTest
public class CreditFactoryTestPL {
    
    
    /*******************************************************************************
    *  Summary         : create test data for all methods   
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountPL();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityPL();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactPL();
        contact.AccountId = account.Id;
        insert contact;
        
        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Poland');
        report.Opportunity__c = opportunity.Id;
        insert report;
        
        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Poland');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<CreditSystem__c> creditSystemSettings = new List<CreditSystem__c>();
        CreditSystem__c crifSettings = CreditFactoryTestUtils.generateCrifSetting();
        creditSystemSettings.add(crifSettings);
        CreditSystem__c krdSetting = CreditFactoryTestUtils.generateKrdSetting();
        creditSystemSettings.add(krdSetting);
        insert creditSystemSettings;
        
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        insert lexisNexisSettings;
        
        dsfs__DocuSign_Status__c docuSignStatus = CreditFactoryTestUtils.generateDocuSignStatus();
        docuSignStatus.dsfs__Opportunity__c = opportunity.Id;
        insert docuSignStatus;
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = CreditFactoryTestUtils.generateDocuSignRecipient();
        docuSignRecipient.dsfs__Parent_Status_Record__c = docuSignStatus.Id;
        insert docuSignRecipient;
        
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        insert fuelPrice;
        
        BIG__c bigSettings = CreditFactoryTestUtils.generateBigSetting();
        insert bigSettings;
        
        Tankkarten__c card = CreditFactoryTestUtils.generateTankkarten();
        card.Opportunity__c = opportunity.Id;
        insert card;
        
        Product2 product2 = CreditFactoryTestUtils.generateProduct2();
        insert product2;
        
        PricebookEntry pricebookEntry = CreditFactoryTestUtils.generatePricebookEntry();
        pricebookEntry.Product2Id = product2.Id;
        pricebookEntry.CurrencyIsoCode = 'PLN';
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
        
        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'PL');
        insert riskyBusinessCode;

        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsPL();
        insert calculations;
    } 
    
    
    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplPL);
    }
    
    
    /*******************************************************************************
    *  Summary         : test set internal CF company   
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
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
        
        System.assertEquals('KACZE WYROBY BIS MARIUSZ WERNYKS', company.name);
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);
        
        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
        
        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);
        
        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        creditFactorySettings.returnSearchValidations();
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
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
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
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
        
        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyPL();
        blackListCompany2.Customer_Id__c = 'PL';
        insert blackListCompany2;
        
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);
        
        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
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
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 22/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateInvoicing() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        
        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Invoicing'}, false);
        
        System.assertEquals(true, validationItemsMap.values().get(0).passed);
        
        creditFactoryDataMap.put('eInvoice', false);
        creditFactoryDataMap.put('paperInvoice', true);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Invoicing'}, false);
        
        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');

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
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');

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
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateOrder() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');

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
    *  Summary         : test validate process opportunity
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        
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
        
        Account dupAccount = CreditFactoryTestUtils.generateAccountPL();
        dupAccount.Steuernummer__c = '12344312';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityPL();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactPL();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;
        
        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);
        
        System.assertEquals(false, validationItemsMap.values().get(0).passed);
        
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
        System.assertEquals(true, creditFactory instanceof CreditFactoryImplPL);
    }
    
    
    /*******************************************************************************
    *  Summary         : test set internal CF company   
    *  Created         : 08/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
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
        
        System.assertEquals('KACZE WYROBY BIS MARIUSZ WERNYKS', company.name);
    }
    
    
    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 08/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
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
    *  Created         : 08/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
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
    *  Created         : 08/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns1:SearchResponse xmlns:ns1="http://www.deltavista.com/dspone/webservices/search"><ns1:Candidates><ns1:Address><ns1:AddressId>1364830</ns1:AddressId><ns1:ParentId>1364830</ns1:ParentId><ns1:FirstName></ns1:FirstName><ns1:MaidenName></ns1:MaidenName><ns1:Name>Kacze wyroby BIS Mariusz Wernyks</ns1:Name><ns1:LegalForm>2</ns1:LegalForm><ns1:Sex>0</ns1:Sex><ns1:Street>Kacza</ns1:Street><ns1:Unit>1</ns1:Unit><ns1:Zip>82-333</ns1:Zip><ns1:City>Wodnowo</ns1:City><ns1:Country>POL</ns1:Country><ns1:DateLastChange>2018-01-10+01:00</ns1:DateLastChange><ns1:CompanyRegistrationDate>2015-10-04+02:00</ns1:CompanyRegistrationDate><ns1:ReferenceNumbers><ns1:ReferenceNumber><ns1:Name>DV_AID</ns1:Name><ns1:Value>1208000003842292</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_LID</ns1:Name><ns1:Value>3372000003842288</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_UID</ns1:Name><ns1:Value>2849000003842293</ns1:Value></ns1:ReferenceNumber></ns1:ReferenceNumbers><ns1:CompanyRegistrationInfo><ns1:directoryEntry><ns1:type>PL_NIP</ns1:type><ns1:ID>8338085693</ns1:ID></ns1:directoryEntry></ns1:CompanyRegistrationInfo><ns1:CompanyStatus>ACTIVE</ns1:CompanyStatus><ns1:IsRegistered>false</ns1:IsRegistered></ns1:Address><ns1:CompareResult><ns1:HitType>1</ns1:HitType><ns1:Similarity>100.0</ns1:Similarity></ns1:CompareResult></ns1:Candidates></ns1:SearchResponse></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);
            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();
        
        creditFactorySettings.returnSearchColumns();
        
        System.assertEquals(1, companiesList.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : test request for ordering report on search step
    *  Created         : 08/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestOrderSearch() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        
        CreditFactoryOrderItem orderItem;
        Test.startTest();
            SingleRequestMock orderMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:messageContext xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:credentials><ns1:user>demo_fleetcor_soap</ns1:user><ns1:password>cvujmHe4</ns1:password></ns1:credentials></ns1:messageContext></soapenv:Header><soapenv:Body><ns1:orderCheckResponse xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:returnCode>1</ns1:returnCode><ns1:product><ns1:name>CreditCheckBusiness</ns1:name><ns1:country>POL</ns1:country><ns1:language>POL</ns1:language></ns1:product><ns1:archiveID>4751000002428489</ns1:archiveID><ns1:reportCreationTime>201801161118</ns1:reportCreationTime><ns1:foundAddress><ns1:legalForm>COMPANY</ns1:legalForm><ns1:address><ns1:name>Kacze wyroby BIS Mariusz Wernyks</ns1:name><ns1:firstName/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location></ns1:address></ns1:foundAddress><ns1:myDecision><ns1:decision>RED</ns1:decision><ns1:rating>U---</ns1:rating></ns1:myDecision><ns1:companyBasicData><ns1:contact><ns1:item>EMAIL</ns1:item><ns1:value>kaczewyrobybis@wodnowo.pl</ns1:value></ns1:contact><ns1:officialName>Kacze wyroby BIS Mariusz Wernyks</ns1:officialName><ns1:location><ns1:type>POSTAL</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>REGISTERED</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>BUSINESS</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:branchesCount>0</ns1:branchesCount><ns1:classification><ns1:companyLegalForm>74</ns1:companyLegalForm><ns1:industryCode><ns1:name>PKD_2007</ns1:name><ns1:code>10.42.Z</ns1:code><ns1:primary>true</ns1:primary></ns1:industryCode></ns1:classification><ns1:registration><ns1:companyRegistry><ns1:type>PL_REGON</ns1:type><ns1:number>414052396</ns1:number></ns1:companyRegistry><ns1:companyRegistry><ns1:type>PL_NIP</ns1:type><ns1:number>8338085693</ns1:number><ns1:dateOfRegistration>20151004</ns1:dateOfRegistration></ns1:companyRegistry></ns1:registration><ns1:dateOfFoundation>20150414</ns1:dateOfFoundation><ns1:knownSince>20150414</ns1:knownSince></ns1:companyBasicData><ns1:companyExtendedData><ns1:organization><ns1:organizationPosition><ns1:holderLegalForm>PERSON</ns1:holderLegalForm><ns1:firstName>Mariusz</ns1:firstName><ns1:name>Wernyks</ns1:name><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip></ns1:location><ns1:sharePercentage>0.0</ns1:sharePercentage><ns1:function><ns1:functionType>OWNER</ns1:functionType><ns1:functionId>101</ns1:functionId><ns1:isActive>true</ns1:isActive></ns1:function><ns1:signatureType>ALONE</ns1:signatureType><ns1:period><ns1:startDate>20150101</ns1:startDate></ns1:period><ns1:hasPaymentInfo>true</ns1:hasPaymentInfo></ns1:organizationPosition></ns1:organization></ns1:companyExtendedData><ns1:decisionMatrix><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>similarCompanies</ns1:comment><ns1:value>65</ns1:value><ns1:name>companyStability</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value><ns1:name>webScore</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>unableCalculate</ns1:comment><ns1:value>-1</ns1:value><ns1:name>creditLimitTransactional</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>thisCompany</ns1:comment><ns1:value>55</ns1:value><ns1:name>generalEvaluationIndex</ns1:name></ns1:item><ns1:identificationDecision><ns1:companyStatus xsi:type="ns1:DecisionMatrixItemCompanyStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment/><ns1:value>ACTIVE</ns1:value></ns1:companyStatus><ns1:identificationType xsi:type="ns1:DecisionMatrixItemIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>IDENTITY_IN_UNIVERSE</ns1:value></ns1:identificationType><ns1:similarHit xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value></ns1:similarHit><ns1:houseType xsi:type="ns1:DecisionMatrixItemString" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>UNKNOWN</ns1:value></ns1:houseType><ns1:nameHint xsi:type="ns1:DecisionMatrixItemNameHint" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>EMPTY</ns1:value></ns1:nameHint><ns1:locationIdentificationType xsi:type="ns1:DecisionMatrixItemLocationIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>NOT_CONFIRMED</ns1:value></ns1:locationIdentificationType></ns1:identificationDecision><ns1:solvencyDecision><ns1:paymentExperience xsi:type="ns1:DecisionMatrixItemPHS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>RED</ns1:partialDecision><ns1:value>SERIOUS</ns1:value></ns1:paymentExperience><ns1:externalSourcesProcessingStatus xsi:type="ns1:DecisionMatrixItemExternalProcessingStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>ERROR</ns1:value></ns1:externalSourcesProcessingStatus><ns1:daysSinceInBusiness xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>1008</ns1:value></ns1:daysSinceInBusiness><ns1:daysSinceNameChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceNameChange><ns1:daysSinceDomicileChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceDomicileChange></ns1:solvencyDecision></ns1:decisionMatrix><ns1:paymentHistory><ns1:currency>PLN</ns1:currency><ns1:count>1</ns1:count><ns1:dateOfLastEntry>20160315</ns1:dateOfLastEntry><ns1:amountTotal>0.0</ns1:amountTotal><ns1:amountTotalOpen>0.0</ns1:amountTotalOpen><ns1:creditStatusMax>3</ns1:creditStatusMax><ns1:masterRiskStatus>Postępowanie komorniczo-sądowe - Tytuł wykonawczy wystawiony przeciwko osobie fizycznej. (3 - 36) PO.IX NS-REJ.KRS/14418/11/228; SĄD REJONOWY POZNAŃ - NOWE MIASTO I WILDA W POZNANIU, IX WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO</ns1:masterRiskStatus><ns1:detail><ns1:source>PUBLICATION</ns1:source><ns1:debtorName>Kacze wyroby BIS Mariusz Wernyks</ns1:debtorName><ns1:amount>0.0</ns1:amount><ns1:amountOpen>0.0</ns1:amountOpen><ns1:creditStatus>3</ns1:creditStatus><ns1:masterRiskStatus>36</ns1:masterRiskStatus><ns1:paymentStatus>PARTIALLYPAID</ns1:paymentStatus><ns1:comment>Tytuł wykonawczy wystawiony przeciwko osobie fizycznej.</ns1:comment><ns1:courtCaseReferenceNumber>PO.IX NS-REJ.KRS/14418/11/228</ns1:courtCaseReferenceNumber></ns1:detail></ns1:paymentHistory><ns1:normalization><ns1:searchedAddress xsi:type="ns1:SearchedAddressN" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:name/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street/><ns1:city/><ns1:zip/></ns1:location><ns1:liableID>3372000003842288</ns1:liableID></ns1:searchedAddress><ns1:foundAddress><ns1:addressID>1208000003842292</ns1:addressID><ns1:unitID>2849000003842293</ns1:unitID><ns1:liableID>3372000003842288</ns1:liableID><ns1:houseID>308536069</ns1:houseID><ns1:streetID>308536068</ns1:streetID><ns1:cityID>307942197</ns1:cityID></ns1:foundAddress></ns1:normalization><ns1:clientExtensions><ns1:additionalData><ns1:name>mainPKDCode</ns1:name><ns1:value>10.42.Z</ns1:value></ns1:additionalData><ns1:additionalData><ns1:name>detailedCompanyStatus</ns1:name><ns1:value>ACTIVE</ns1:value></ns1:additionalData></ns1:clientExtensions></ns1:orderCheckResponse></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, orderMock);
            orderItem = creditFactory.requestOrder(null);
        Test.stopTest();
        
        System.assertEquals('8338085693', orderItem.orderReferenceNumber);
    }
    
    
    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
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
        creditFactoryDataMap.put('totalConsumption', 1500);
        
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        
        CreditFactoryReportsItem reportsItem;
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock crifReportMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:messageContext xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:credentials><ns1:user>demo_fleetcor_soap</ns1:user><ns1:password>cvujmHe4</ns1:password></ns1:credentials></ns1:messageContext></soapenv:Header><soapenv:Body><ns1:orderCheckResponse xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:returnCode>1</ns1:returnCode><ns1:product><ns1:name>CreditCheckBusiness</ns1:name><ns1:country>POL</ns1:country><ns1:language>POL</ns1:language></ns1:product><ns1:archiveID>4751000002428489</ns1:archiveID><ns1:reportCreationTime>201801161118</ns1:reportCreationTime><ns1:foundAddress><ns1:legalForm>COMPANY</ns1:legalForm><ns1:address><ns1:name>Kacze wyroby BIS Mariusz Wernyks</ns1:name><ns1:firstName/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location></ns1:address></ns1:foundAddress><ns1:myDecision><ns1:decision>RED</ns1:decision><ns1:rating>U---</ns1:rating></ns1:myDecision><ns1:companyBasicData><ns1:contact><ns1:item>EMAIL</ns1:item><ns1:value>kaczewyrobybis@wodnowo.pl</ns1:value></ns1:contact><ns1:officialName>Kacze wyroby BIS Mariusz Wernyks</ns1:officialName><ns1:location><ns1:type>POSTAL</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>REGISTERED</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>BUSINESS</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:branchesCount>0</ns1:branchesCount><ns1:classification><ns1:companyLegalForm>74</ns1:companyLegalForm><ns1:industryCode><ns1:name>PKD_2007</ns1:name><ns1:code>10.42.Z</ns1:code><ns1:primary>true</ns1:primary></ns1:industryCode></ns1:classification><ns1:registration><ns1:companyRegistry><ns1:type>PL_REGON</ns1:type><ns1:number>414052396</ns1:number></ns1:companyRegistry><ns1:companyRegistry><ns1:type>PL_NIP</ns1:type><ns1:number>8338085693</ns1:number><ns1:dateOfRegistration>20151004</ns1:dateOfRegistration></ns1:companyRegistry></ns1:registration><ns1:dateOfFoundation>20150414</ns1:dateOfFoundation><ns1:knownSince>20150414</ns1:knownSince></ns1:companyBasicData><ns1:companyExtendedData><ns1:organization><ns1:organizationPosition><ns1:holderLegalForm>PERSON</ns1:holderLegalForm><ns1:firstName>Mariusz</ns1:firstName><ns1:name>Wernyks</ns1:name><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip></ns1:location><ns1:sharePercentage>0.0</ns1:sharePercentage><ns1:function><ns1:functionType>OWNER</ns1:functionType><ns1:functionId>101</ns1:functionId><ns1:isActive>true</ns1:isActive></ns1:function><ns1:signatureType>ALONE</ns1:signatureType><ns1:period><ns1:startDate>20150101</ns1:startDate></ns1:period><ns1:hasPaymentInfo>true</ns1:hasPaymentInfo></ns1:organizationPosition></ns1:organization></ns1:companyExtendedData><ns1:decisionMatrix><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>similarCompanies</ns1:comment><ns1:value>65</ns1:value><ns1:name>companyStability</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value><ns1:name>webScore</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>unableCalculate</ns1:comment><ns1:value>-1</ns1:value><ns1:name>creditLimitTransactional</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>thisCompany</ns1:comment><ns1:value>55</ns1:value><ns1:name>generalEvaluationIndex</ns1:name></ns1:item><ns1:identificationDecision><ns1:companyStatus xsi:type="ns1:DecisionMatrixItemCompanyStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment/><ns1:value>ACTIVE</ns1:value></ns1:companyStatus><ns1:identificationType xsi:type="ns1:DecisionMatrixItemIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>IDENTITY_IN_UNIVERSE</ns1:value></ns1:identificationType><ns1:similarHit xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value></ns1:similarHit><ns1:houseType xsi:type="ns1:DecisionMatrixItemString" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>UNKNOWN</ns1:value></ns1:houseType><ns1:nameHint xsi:type="ns1:DecisionMatrixItemNameHint" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>EMPTY</ns1:value></ns1:nameHint><ns1:locationIdentificationType xsi:type="ns1:DecisionMatrixItemLocationIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>NOT_CONFIRMED</ns1:value></ns1:locationIdentificationType></ns1:identificationDecision><ns1:solvencyDecision><ns1:paymentExperience xsi:type="ns1:DecisionMatrixItemPHS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>RED</ns1:partialDecision><ns1:value>SERIOUS</ns1:value></ns1:paymentExperience><ns1:externalSourcesProcessingStatus xsi:type="ns1:DecisionMatrixItemExternalProcessingStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>OK</ns1:value></ns1:externalSourcesProcessingStatus><ns1:daysSinceInBusiness xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>1008</ns1:value></ns1:daysSinceInBusiness><ns1:daysSinceNameChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceNameChange><ns1:daysSinceDomicileChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceDomicileChange></ns1:solvencyDecision></ns1:decisionMatrix><ns1:paymentHistory><ns1:currency>PLN</ns1:currency><ns1:count>1</ns1:count><ns1:dateOfLastEntry>20160315</ns1:dateOfLastEntry><ns1:amountTotal>0.0</ns1:amountTotal><ns1:amountTotalOpen>0.0</ns1:amountTotalOpen><ns1:creditStatusMax>3</ns1:creditStatusMax><ns1:masterRiskStatus>Postępowanie komorniczo-sądowe - Tytuł wykonawczy wystawiony przeciwko osobie fizycznej. (3 - 36) PO.IX NS-REJ.KRS/14418/11/228; SĄD REJONOWY POZNAŃ - NOWE MIASTO I WILDA W POZNANIU, IX WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO</ns1:masterRiskStatus><ns1:detail><ns1:source>PUBLICATION</ns1:source><ns1:debtorName>Kacze wyroby BIS Mariusz Wernyks</ns1:debtorName><ns1:amount>0.0</ns1:amount><ns1:amountOpen>0.0</ns1:amountOpen><ns1:creditStatus>3</ns1:creditStatus><ns1:masterRiskStatus>36</ns1:masterRiskStatus><ns1:paymentStatus>PARTIALLYPAID</ns1:paymentStatus><ns1:comment>Tytuł wykonawczy wystawiony przeciwko osobie fizycznej.</ns1:comment><ns1:courtCaseReferenceNumber>PO.IX NS-REJ.KRS/14418/11/228</ns1:courtCaseReferenceNumber></ns1:detail></ns1:paymentHistory><ns1:normalization><ns1:searchedAddress xsi:type="ns1:SearchedAddressN" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:name/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street/><ns1:city/><ns1:zip/></ns1:location><ns1:liableID>3372000003842288</ns1:liableID></ns1:searchedAddress><ns1:foundAddress><ns1:addressID>1208000003842292</ns1:addressID><ns1:unitID>2849000003842293</ns1:unitID><ns1:liableID>3372000003842288</ns1:liableID><ns1:houseID>308536069</ns1:houseID><ns1:streetID>308536068</ns1:streetID><ns1:cityID>307942197</ns1:cityID></ns1:foundAddress></ns1:normalization><ns1:clientExtensions><ns1:additionalData><ns1:name>mainPKDCode</ns1:name><ns1:value>10.42.Z</ns1:value></ns1:additionalData><ns1:additionalData><ns1:name>detailedCompanyStatus</ns1:name><ns1:value>ACTIVE</ns1:value></ns1:additionalData></ns1:clientExtensions></ns1:orderCheckResponse></soapenv:Body></soapenv:Envelope>', null);
            mocksMap.put('https://demo.deltavista.pl/dvs-soap/services/OrderCheckService', crifReportMock);
            SingleRequestMock krdReportMock = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><h:Authorization xmlns:h="http://krd.pl/Authorization/Response" xmlns="http://krd.pl/Authorization/Response" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Ticket>00AC0D1F03AE9AA7D552448CECC06F1953D29B000</Ticket><TicketExpirationDate>2020-08-05T11:45:23+02:00</TicketExpirationDate><ShouldChangePassword>false</ShouldChangePassword><PasswordExpirationDate>2017-06-08T00:00:00+02:00</PasswordExpirationDate></h:Authorization></s:Header><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><InformationDisclosureResponse xmlns="http://krd.pl/Chase3.1/Dto"><DisclosureReport><Number>U1/0000333361/2020</Number><Created>2020-08-04T11:45:24+02:00</Created><SearchCriterion><NonConsumerIdentityNumber><TaxId>7665256263</TaxId></NonConsumerIdentityNumber><AuthorizationDateSpecified>false</AuthorizationDateSpecified><ActAuthorizationDateSpecified>false</ActAuthorizationDateSpecified><SearchType>RegularSearch</SearchType><SearchCriterionType>TaxId</SearchCriterionType></SearchCriterion><Requester><LegalPerson><Name>KLIENT DEMO_CHASE3.1</Name><IdentityNumber><TaxId>5327161905</TaxId></IdentityNumber><SeatAddress><Line>Danuty Siedzikówny 12, Wrocław</Line><Line>51-214 Wrocław</Line><Line>PL</Line></SeatAddress></LegalPerson><LoginFullName>KLIENT DEMO_CHASE3.1</LoginFullName></Requester><Summary><InformationCount>0</InformationCount><OInformationCount>0</OInformationCount><DInformationCount>0</DInformationCount><DebtorsCount>0</DebtorsCount><CreditorsCount>0</CreditorsCount><TotalArrears><Amount>0</Amount><Currency>PLN</Currency></TotalArrears></Summary><PositiveInformationSummary><ProvidersCount>1</ProvidersCount><PaidObligationsCount>1</PaidObligationsCount><AveragePaidDebt>3900.00</AveragePaidDebt><AveragePaymentTimeInDays>7</AveragePaymentTimeInDays><SumPaidDebt>3900.0000</SumPaidDebt></PositiveInformationSummary><Report><PaidObligationInformations><PaidObligationInformation><Provider category="87"><LegalPerson><IdentityNumber><TaxId>5327161905</TaxId></IdentityNumber><Name>KLIENT DEMO_CHASE3.1</Name><SeatAddress><Line>Danuty Siedzikówny 12, Wrocław</Line><Line>51-214 Wrocław</Line><Line>PL</Line></SeatAddress><Branch>Other</Branch></LegalPerson></Provider><ShowProvider>true</ShowProvider><PaidObligationsForSubjects><PaidObligationsForSubject><Subject><LegalPerson><IdentityNumber><TaxId>7665256263</TaxId></IdentityNumber><Name>Mago Sp. z o.o.</Name><SeatAddress><Line>Bukowa 123</Line><Line>40-120 Katowice</Line><Line>PL</Line></SeatAddress></LegalPerson></Subject><PaidObligations><PaidObligation category="0"><Currency>PLN</Currency><TotalDebt>3900.0000</TotalDebt><PaidDebt>3900.0000</PaidDebt><DueDate>2019-10-01T00:00:00+02:00</DueDate><PaidDate>2019-10-08T00:00:00+02:00</PaidDate><Reason>Invoice</Reason><IsSumOfInstalments>false</IsSumOfInstalments><TotalDebtPLN>3900.0000</TotalDebtPLN><PaidDebtPLN>3900.0000</PaidDebtPLN></PaidObligation></PaidObligations></PaidObligationsForSubject></PaidObligationsForSubjects></PaidObligationInformation></PaidObligationInformations></Report></DisclosureReport></InformationDisclosureResponse></s:Body></s:Envelope>', null);
            mocksMap.put('https://demo.krd.pl/Chase/3.1/Search.svc/basic', krdReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportsItem = creditFactory.requestCompanyReports('1234512345');
        Test.stopTest();
        
        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Kacze wyroby BIS Mariusz Wernyks', reportsItem.companiesList.get(0).name);
        System.assertEquals('3', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('unknown', reportsItem.companiesList.get(0).turnOver);
        System.assertEquals('7000', reportsItem.companiesList.get(0).creditLimit);
        System.assertEquals('600', reportsItem.companiesList.get(0).solvencyIndex);
        System.assertEquals('Verified', reportsItem.companiesList.get(0).emailStatus);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);
        
        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportFieldsToUpdate();
        creditFactory.createPdfReports(opportunityId);
        
        System.assertEquals(1, reportsList.size());
        System.assertEquals('Kacze wyroby BIS Mariusz Wernyks', reportsList.get(0).Name);
        System.assertEquals(1, reportEmployeesList.size());
        System.assertEquals('Mariusz Wernyks', reportEmployeesList.get(0).Name);
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Opportunity'));
        System.assertEquals('3', ((Map<String, Object>) fieldsToUpdateMap.get('Opportunity')).get('Credit_System_Rating__c'));
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Account'));
        System.assertEquals('1042', ((Map<String, Object>) fieldsToUpdateMap.get('Account')).get('Branchencode__c'));
    }



    /*******************************************************************************
    *  Summary         : test KRD request if report exists
    *  Created         : 09/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testKrdRequestIfReportExists() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        List<OpportunityContactRole> contactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
        sobjectsList.addAll(contactRolesList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('totalConsumption', 1500);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem reportsItem = creditFactory.selectCompanyReports(opportunityId);
        reportsItem.companiesList.get(0).paymentHistoryRequested = false;
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');

        Test.startTest();
            SingleRequestMock krdReportMock = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><h:Authorization xmlns:h="http://krd.pl/Authorization/Response" xmlns="http://krd.pl/Authorization/Response" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Ticket>00AC0D1F03AE9AA7D552448CECC06F1953D29B000</Ticket><TicketExpirationDate>2020-08-05T11:45:23+02:00</TicketExpirationDate><ShouldChangePassword>false</ShouldChangePassword><PasswordExpirationDate>2017-06-08T00:00:00+02:00</PasswordExpirationDate></h:Authorization></s:Header><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><InformationDisclosureResponse xmlns="http://krd.pl/Chase3.1/Dto"><DisclosureReport><Number>U1/0000333361/2020</Number><Created>2020-08-04T11:45:24+02:00</Created><SearchCriterion><NonConsumerIdentityNumber><TaxId>7665256263</TaxId></NonConsumerIdentityNumber><AuthorizationDateSpecified>false</AuthorizationDateSpecified><ActAuthorizationDateSpecified>false</ActAuthorizationDateSpecified><SearchType>RegularSearch</SearchType><SearchCriterionType>TaxId</SearchCriterionType></SearchCriterion><Requester><LegalPerson><Name>KLIENT DEMO_CHASE3.1</Name><IdentityNumber><TaxId>5327161905</TaxId></IdentityNumber><SeatAddress><Line>Danuty Siedzikówny 12, Wrocław</Line><Line>51-214 Wrocław</Line><Line>PL</Line></SeatAddress></LegalPerson><LoginFullName>KLIENT DEMO_CHASE3.1</LoginFullName></Requester><Summary><InformationCount>0</InformationCount><OInformationCount>0</OInformationCount><DInformationCount>0</DInformationCount><DebtorsCount>0</DebtorsCount><CreditorsCount>0</CreditorsCount><TotalArrears><Amount>0</Amount><Currency>PLN</Currency></TotalArrears></Summary><PositiveInformationSummary><ProvidersCount>1</ProvidersCount><PaidObligationsCount>1</PaidObligationsCount><AveragePaidDebt>3900.00</AveragePaidDebt><AveragePaymentTimeInDays>7</AveragePaymentTimeInDays><SumPaidDebt>3900.0000</SumPaidDebt></PositiveInformationSummary><Report><PaidObligationInformations><PaidObligationInformation><Provider category="87"><LegalPerson><IdentityNumber><TaxId>5327161905</TaxId></IdentityNumber><Name>KLIENT DEMO_CHASE3.1</Name><SeatAddress><Line>Danuty Siedzikówny 12, Wrocław</Line><Line>51-214 Wrocław</Line><Line>PL</Line></SeatAddress><Branch>Other</Branch></LegalPerson></Provider><ShowProvider>true</ShowProvider><PaidObligationsForSubjects><PaidObligationsForSubject><Subject><LegalPerson><IdentityNumber><TaxId>7665256263</TaxId></IdentityNumber><Name>Mago Sp. z o.o.</Name><SeatAddress><Line>Bukowa 123</Line><Line>40-120 Katowice</Line><Line>PL</Line></SeatAddress></LegalPerson></Subject><PaidObligations><PaidObligation category="0"><Currency>PLN</Currency><TotalDebt>3900.0000</TotalDebt><PaidDebt>3900.0000</PaidDebt><DueDate>2019-10-01T00:00:00+02:00</DueDate><PaidDate>2019-10-08T00:00:00+02:00</PaidDate><Reason>Invoice</Reason><IsSumOfInstalments>false</IsSumOfInstalments><TotalDebtPLN>3900.0000</TotalDebtPLN><PaidDebtPLN>3900.0000</PaidDebtPLN></PaidObligation></PaidObligations></PaidObligationsForSubject></PaidObligationsForSubjects></PaidObligationInformation></PaidObligationInformations></Report></DisclosureReport></InformationDisclosureResponse></s:Body></s:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, krdReportMock);
            CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        Test.stopTest();

        System.assertEquals('Payment history data', cfResult.requiredUpdates);
    }

     /*******************************************************************************
    *  Summary         : test fields to update if report exists
    *  Created         : 21/09/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testAdditionalScoringReportFieldsToUpdate() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunity.Id);
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportAdditionalScoringFieldsToUpdate();
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Credit_Factory_Report__c'));
    }


    /*******************************************************************************
    *  Summary         : test response from Crif with API error 
    *  Created         : 22/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCrifApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
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
            SingleRequestMock crifReportMock = new SingleRequestMock(500, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server</faultcode><faultstring>ErrorMessage</faultstring><detail><ns1:error xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:code>400</ns1:code><ns1:messageText>[Unique request ID = 8672196504]: NIP number is invalid (@TRANSFERRED:POIandValidation)(Error in subdiagram with id: f3342b6c-818c-11ea-b165-11e91f5b2429:1) (@TRANSFERRED:B2B)</ns1:messageText></ns1:error></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, crifReportMock);
            try {
                creditFactory.requestCompanyReports('1234512345');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals('Crif API error. Please contact your administrator. Bad request. Company Id: 1234512345', errorMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error 
    *  Created         : 22/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        SingleRequestMock crifReportMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:messageContext xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:credentials><ns1:user>demo_fleetcor_soap</ns1:user><ns1:password>cvujmHe4</ns1:password></ns1:credentials></ns1:messageContext></soapenv:Header><soapenv:Body><ns1:orderCheckResponse xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:returnCode>1</ns1:returnCode><ns1:product><ns1:name>CreditCheckBusiness</ns1:name><ns1:country>POL</ns1:country><ns1:language>POL</ns1:language></ns1:product><ns1:archiveID>4751000002428489</ns1:archiveID><ns1:reportCreationTime>201801161118</ns1:reportCreationTime><ns1:foundAddress><ns1:legalForm>COMPANY</ns1:legalForm><ns1:address><ns1:name>Kacze wyroby BIS Mariusz Wernyks</ns1:name><ns1:firstName/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location></ns1:address></ns1:foundAddress><ns1:myDecision><ns1:decision>RED</ns1:decision><ns1:rating>U---</ns1:rating></ns1:myDecision><ns1:companyBasicData><ns1:contact><ns1:item>EMAIL</ns1:item><ns1:value>kaczewyrobybis@wodnowo.pl</ns1:value></ns1:contact><ns1:officialName>Kacze wyroby BIS Mariusz Wernyks</ns1:officialName><ns1:location><ns1:type>POSTAL</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>REGISTERED</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:location><ns1:type>BUSINESS</ns1:type><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip><ns1:country>POL</ns1:country></ns1:location><ns1:branchesCount>0</ns1:branchesCount><ns1:classification><ns1:companyLegalForm>74</ns1:companyLegalForm><ns1:industryCode><ns1:name>PKD_2007</ns1:name><ns1:code>10.42.Z</ns1:code><ns1:primary>true</ns1:primary></ns1:industryCode></ns1:classification><ns1:registration><ns1:companyRegistry><ns1:type>PL_REGON</ns1:type><ns1:number>414052396</ns1:number></ns1:companyRegistry><ns1:companyRegistry><ns1:type>PL_NIP</ns1:type><ns1:number>8338085693</ns1:number><ns1:dateOfRegistration>20151004</ns1:dateOfRegistration></ns1:companyRegistry></ns1:registration><ns1:dateOfFoundation>20150414</ns1:dateOfFoundation><ns1:knownSince>20150414</ns1:knownSince></ns1:companyBasicData><ns1:companyExtendedData><ns1:organization><ns1:organizationPosition><ns1:holderLegalForm>PERSON</ns1:holderLegalForm><ns1:firstName>Mariusz</ns1:firstName><ns1:name>Wernyks</ns1:name><ns1:location><ns1:street>Kacza</ns1:street><ns1:house>1</ns1:house><ns1:city>Wodnowo</ns1:city><ns1:zip>82-333</ns1:zip></ns1:location><ns1:sharePercentage>0.0</ns1:sharePercentage><ns1:function><ns1:functionType>OWNER</ns1:functionType><ns1:functionId>101</ns1:functionId><ns1:isActive>true</ns1:isActive></ns1:function><ns1:signatureType>ALONE</ns1:signatureType><ns1:period><ns1:startDate>20150101</ns1:startDate></ns1:period><ns1:hasPaymentInfo>true</ns1:hasPaymentInfo></ns1:organizationPosition></ns1:organization></ns1:companyExtendedData><ns1:decisionMatrix><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>similarCompanies</ns1:comment><ns1:value>65</ns1:value><ns1:name>companyStability</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value><ns1:name>webScore</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>unableCalculate</ns1:comment><ns1:value>-1</ns1:value><ns1:name>creditLimitTransactional</ns1:name></ns1:item><ns1:item xsi:type="ns1:DecisionMatrixItemStringWithName" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment>thisCompany</ns1:comment><ns1:value>55</ns1:value><ns1:name>generalEvaluationIndex</ns1:name></ns1:item><ns1:identificationDecision><ns1:companyStatus xsi:type="ns1:DecisionMatrixItemCompanyStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:comment/><ns1:value>ACTIVE</ns1:value></ns1:companyStatus><ns1:identificationType xsi:type="ns1:DecisionMatrixItemIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>IDENTITY_IN_UNIVERSE</ns1:value></ns1:identificationType><ns1:similarHit xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>0</ns1:value></ns1:similarHit><ns1:houseType xsi:type="ns1:DecisionMatrixItemString" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>UNKNOWN</ns1:value></ns1:houseType><ns1:nameHint xsi:type="ns1:DecisionMatrixItemNameHint" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>EMPTY</ns1:value></ns1:nameHint><ns1:locationIdentificationType xsi:type="ns1:DecisionMatrixItemLocationIdentificationType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>NOT_CONFIRMED</ns1:value></ns1:locationIdentificationType></ns1:identificationDecision><ns1:solvencyDecision><ns1:paymentExperience xsi:type="ns1:DecisionMatrixItemPHS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>RED</ns1:partialDecision><ns1:value>SERIOUS</ns1:value></ns1:paymentExperience><ns1:externalSourcesProcessingStatus xsi:type="ns1:DecisionMatrixItemExternalProcessingStatus" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>OK</ns1:value></ns1:externalSourcesProcessingStatus><ns1:daysSinceInBusiness xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>1008</ns1:value></ns1:daysSinceInBusiness><ns1:daysSinceNameChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceNameChange><ns1:daysSinceDomicileChange xsi:type="ns1:DecisionMatrixItemInt" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:partialDecision>GREEN</ns1:partialDecision><ns1:value>-1</ns1:value></ns1:daysSinceDomicileChange></ns1:solvencyDecision></ns1:decisionMatrix><ns1:paymentHistory><ns1:currency>PLN</ns1:currency><ns1:count>1</ns1:count><ns1:dateOfLastEntry>20160315</ns1:dateOfLastEntry><ns1:amountTotal>0.0</ns1:amountTotal><ns1:amountTotalOpen>0.0</ns1:amountTotalOpen><ns1:creditStatusMax>3</ns1:creditStatusMax><ns1:masterRiskStatus>Postępowanie komorniczo-sądowe - Tytuł wykonawczy wystawiony przeciwko osobie fizycznej. (3 - 36) PO.IX NS-REJ.KRS/14418/11/228; SĄD REJONOWY POZNAŃ - NOWE MIASTO I WILDA W POZNANIU, IX WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO</ns1:masterRiskStatus><ns1:detail><ns1:source>PUBLICATION</ns1:source><ns1:debtorName>Kacze wyroby BIS Mariusz Wernyks</ns1:debtorName><ns1:amount>0.0</ns1:amount><ns1:amountOpen>0.0</ns1:amountOpen><ns1:creditStatus>3</ns1:creditStatus><ns1:masterRiskStatus>36</ns1:masterRiskStatus><ns1:paymentStatus>PARTIALLYPAID</ns1:paymentStatus><ns1:comment>Tytuł wykonawczy wystawiony przeciwko osobie fizycznej.</ns1:comment><ns1:courtCaseReferenceNumber>PO.IX NS-REJ.KRS/14418/11/228</ns1:courtCaseReferenceNumber></ns1:detail></ns1:paymentHistory><ns1:normalization><ns1:searchedAddress xsi:type="ns1:SearchedAddressN" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ns1:name/><ns1:gender>UNKNOWN</ns1:gender><ns1:location><ns1:street/><ns1:city/><ns1:zip/></ns1:location><ns1:liableID>3372000003842288</ns1:liableID></ns1:searchedAddress><ns1:foundAddress><ns1:addressID>1208000003842292</ns1:addressID><ns1:unitID>2849000003842293</ns1:unitID><ns1:liableID>3372000003842288</ns1:liableID><ns1:houseID>308536069</ns1:houseID><ns1:streetID>308536068</ns1:streetID><ns1:cityID>307942197</ns1:cityID></ns1:foundAddress></ns1:normalization><ns1:clientExtensions><ns1:additionalData><ns1:name>mainPKDCode</ns1:name><ns1:value>10.42.Z</ns1:value></ns1:additionalData><ns1:additionalData><ns1:name>detailedCompanyStatus</ns1:name><ns1:value>ACTIVE</ns1:value></ns1:additionalData></ns1:clientExtensions></ns1:orderCheckResponse></soapenv:Body></soapenv:Envelope>', null);
        mocksMap.put('https://demo.deltavista.pl/dvs-soap/services/OrderCheckService', crifReportMock);
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
    *  Summary         : test request for ordering company on report step
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestOrderReport() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryOrderItem orderItem = creditFactory.requestOrder('8338085693');
        
        System.assertEquals('8338085693', orderItem.orderReferenceNumber);
    }
    
    
    /*******************************************************************************
    *  Summary         : test request for searching company
    *  Created         : 08/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnOrderFieldsToUpdate() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        
        Map<String, Object> fieldsToUpdate = creditFactory.returnOrderFieldsToUpdate('8338085693');
        
        System.assertEquals('8338085693', ((Map<String, Object>) fieldsToUpdate.get('Opportunity')).get('Credit_Report_Id__c'));
        System.assertEquals('Pending Credit Report', ((Map<String, Object>) fieldsToUpdate.get('Opportunity')).get('StageName'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');
        
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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();
        
        System.assertEquals('Update Name', addressUpdateData.get('header'));
        
        Map<String, Object> addressFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Kacze wyroby BIS Mariusz Wernyks', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('Name'));
        
        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);
        
        System.assertEquals('Update Address', addressUpdateData.get('header'));
        
        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Wodnowo', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));
        
        Map<String, Object> postalAddressFieldsToUpdate = creditFactory.returnPostalAddressFieldsToUpdate();
        System.assertEquals(true, postalAddressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Wodnowo', ((Map<String, Object>) postalAddressFieldsToUpdate.get('Account')).get('BillingCity'));
        
        Map<String, Object> registeredAddressFieldsToUpdate = creditFactory.returnPostalAddressFieldsToUpdate();
        System.assertEquals(true, registeredAddressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Wodnowo', ((Map<String, Object>) registeredAddressFieldsToUpdate.get('Account')).get('BillingCity'));
        
        creditFactoryDataMap.put('street', 'test');
        creditFactoryDataMap.put('postalStreet', 'test');
        creditFactoryDataMap.put('registeredStreet', 'test');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    

    /*******************************************************************************
    *  Summary         : test empty address validation
    *  Created         : 17/09/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmptyAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        cfItem.companiesList.get(0).registeredStreet = null;
        cfItem.companiesList.get(0).postalStreet = null;
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);
        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmptyAddress'}, true);
        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test tax id validation
    *  Created         : 15/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTaxId() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnTaxIdUpdateData(internalCompany, externalCompany);
        
        System.assertEquals('Update Tax Id', addressUpdateData.get('header'));
        
        Map<String, Object> taxIdFieldsToUpdate = creditFactory.returnTaxIdFieldsToUpdate();
        System.assertEquals(true, taxIdFieldsToUpdate.containsKey('Account'));
        System.assertEquals('8338085693', ((Map<String, Object>) taxIdFieldsToUpdate.get('Account')).get('Steuernummer__c'));
        
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
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('PL8338085693', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test trader register number validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTradeRegisterNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnTradeRegisterNumberUpdateData(internalCompany, externalCompany);
        
        System.assertEquals('Update Trade Register Number', addressUpdateData.get('header'));
        
        Map<String, Object> tradeRegisterFieldsToUpdate = creditFactory.returnTradeRegisterNumberFieldsToUpdate();
        System.assertEquals(true, tradeRegisterFieldsToUpdate.containsKey('Account'));
        System.assertEquals('414052396', ((Map<String, Object>) tradeRegisterFieldsToUpdate.get('Account')).get('HR_Abteilung_HRA_HRB_und_HR_Nummer__c'));
        
        creditFactoryDataMap.put('tradeRegisterNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TradeRegisterNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test contact validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
    *  Summary         : test request status validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateRequestStatus() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'RequestStatus'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);
        
        cfItem.companiesList.get(0).requestStatus = 'ERROR';
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'RequestStatus'}, true);
        
        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test age of company validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAgeOfCompany() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'AgeOfCompany'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);
        
        cfItem.companiesList.get(0).dateOfFoundation = String.valueOf(Date.today()).replace('-', '');
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'AgeOfCompany'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test obligation overdue validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateObligationOverdue() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'ObligationOverdue'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);
        
        cfItem.companiesList.get(0).obligationOverdue = true;
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'ObligationOverdue'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test obligation overdue validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
    *  Summary         : test obligation overdue validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmailRisk'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);
        
        cfItem.companiesList.get(0).emailRisk = 'High';
        cfItem.companiesList.get(0).emailExists = 'No';
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'EmailRisk'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
        
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);
        
        System.assertEquals('009', cfResult.statusCode);
    }


    @isTest
    static void validateCompanyStatus() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyStatus'}, true);
        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        cfItem.companiesList.get(0).status = 'INACTIVE';

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyStatus'}, true);
        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);
        System.assertEquals('012', cfResult.statusCode);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 15', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 7', cfResult.messagesList.get(1).text);
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
    *  Summary         : test 2 credit scoring for rating 1
    *  Created         : 15/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Sec_Channel__c = 'Outbound';
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('desiredBillingPeriod', '15');
        creditFactoryDataMap.put('desiredPaymentTerms', '14');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('14', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '2';
        report.Policy_Rules_Hits__c = 'Forma własności w REGON to własność zagraniczna';
        report.Number_Of_Hits__c = '1';
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
        
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        Map<String, Object> closedLostFieldsToUpdate = creditFactory.returnClosedLostFieldsToUpdate('Refused Credit');
        System.assertEquals(true, closedLostFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Closed Lost', ((Map<String, Object>) closedLostFieldsToUpdate.get('Opportunity')).get('StageName'));
        
        System.assertEquals('007', cfResult.statusCode);
        System.assertEquals('Opportunity is closed as Lost (Rating 3)', cfResult.messagesList.get(0).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring with check of policy rules
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringPolicyRules() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '2';
        report.Policy_Rules_Hits__c = 'Aktywna osoba decyzyjna otworzyła co najmniej 5 stanowisk w ciągu ostatnich 12 miesięcy w innych firmach';
        report.Number_Of_Hits__c = '1';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('005', cfResult.statusCode);
        System.assertEquals(true, cfResult.messagesList.get(0).text.contains('Opportunity is Closed as Lost. Reasons:'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (bad rating)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringBadRating() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        
        Map<String, CreditFactoryValidationItem> reportValidationMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem passedItem = new CreditFactoryValidationItem();
        passedItem.passed = true;
        reportValidationMap.put('ObligationOverdue', passedItem);
        reportValidationMap.put('AgeOfCompany', passedItem);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), reportValidationMap);
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('Billing Period can be set to 15', cfResult.messagesList.get(0).text);
        System.assert(cfResult.messagesList.get(2).text.contains('Deposit to pay'), true);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (bad rating)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringInvalidContact() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        
        Map<String, CreditFactoryValidationItem> reportValidationMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem passedItem = new CreditFactoryValidationItem();
        passedItem.passed = false;
        reportValidationMap.put('Contact', passedItem);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), reportValidationMap);
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        
        Map<String, Object> pendingDepositFieldsMap = creditFactory.returnPendingDepositFieldsToUpdate();
        System.assertEquals(true, pendingDepositFieldsMap.containsKey('Opportunity'));
        System.assertEquals('Pending deposit', ((Map<String, Object>) pendingDepositFieldsMap.get('Opportunity')).get('CF_Stage__c'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (obligation overdue)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringObligationOverdue() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

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
        
        Map<String, CreditFactoryValidationItem> reportValidationMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem passedItem = new CreditFactoryValidationItem();
        passedItem.passed = false;
        reportValidationMap.put('ObligationOverdue', passedItem);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), reportValidationMap);
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('Obligation overdue', cfResult.depositReason);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (age of company is small)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringAgeOfCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        String dateOfFoundation = String.valueOf(Date.today().year()) + '0101';
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
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
        
        Map<String, CreditFactoryValidationItem> reportValidationMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem passedItem = new CreditFactoryValidationItem();
        passedItem.passed = false;
        reportValidationMap.put('AgeOfCompany', passedItem);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), reportValidationMap);
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals('New business', cfResult.depositReason);
        System.assertEquals(100, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (based on PIT)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringPIT() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 1750;
        update testOpportunity;
        
        String opportunityId = testOpportunity.Id;

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(50, cfResult.securityLevel);
        System.assertEquals('Low/no profitability', cfResult.depositReason);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (company should be scored additionally)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringAdditional() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 5000;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.BIG_Requested__c = false;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('002', cfResult.statusCode);
        System.assertEquals('Company should be scored additionally.', cfResult.messagesList.get(0).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (new business exception)
    *  Created         : 19/01/2021
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringNewBusinessException() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 100;
        testOpportunity.Zahlungsziel_2__c = '7';
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = String.valueOf(Date.today()).replace('-', '');
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

        Map<String, CreditFactoryValidationItem> reportValidationMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem passedItem = new CreditFactoryValidationItem();
        passedItem.passed = false;
        reportValidationMap.put('AgeOfCompany', passedItem);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), reportValidationMap);
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }
    
    /*******************************************************************************
    *  Summary         : test consent signer validation
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateConsentSigner() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Poland');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

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
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryReportsItem cfItem = creditFactory.selectCompanyReports(opportunityId);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(creditFactorySettings.returnAdditionalScoringValidations(), true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);
        
        ((List<Map<String, Object>>) creditFactoryDataMap.get('documentsStatusesList')).get(0).put('name', 'test');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(creditFactorySettings.returnAdditionalScoringValidations(), true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test additional scoring request
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestAdditionalScoringData() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.BIG_Requested__c = false;
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
        
        Map<String, CreditFactoryValidationItem> validationItemsMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        validationItem.parametersMap = new Map<String, Object>();
        validationItem.parametersMap.put('ConsentGrantDate', Datetime.now());
        validationItemsMap.put('ConsentSigner', validationItem);
        
        CreditFactoryReportsItem reportsItem;
        Test.startTest();
            SingleRequestMock bigMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><a:getReportResponse xmlns:a="http://api.big.pl/bigApi/v1/types"><responseId>cabb1224d9614a4ab0c24648398075f2</responseId><responseDateTime>2019-10-15T13:07:41.130+02:00</responseDateTime><requestId>kk004</requestId><requestDateTime>2019-10-07T13:00:00</requestDateTime><user>USER188247</user><protocol>bimo v1</protocol><data><![CDATA[&lt;?xml version="1.0" encoding="UTF-8" standalone="yes"?&gt;&lt;ns3:getReportResponse xmlns:ns2="http://api.big.pl/iasWrapper/reports/v1" xmlns:ns3="http://api.big.pl/bimoR/v1"&gt;&lt;success&gt;&lt;currentRequest&gt;&lt;client&gt;&lt;clientId&gt;1777717777&lt;/clientId&gt;&lt;unitId&gt;1777717777&lt;/unitId&gt;&lt;/client&gt;&lt;repeatedRequestMarker&gt;false&lt;/repeatedRequestMarker&gt;&lt;reportComposition xsi:type="ns3:FinancialReportComposition" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;product&gt;entrepreneur&lt;/product&gt;&lt;components select="custom"&gt;&lt;liabilitiesSummaries&gt;&lt;summaryRequest&gt;&lt;liabilitiesSource&gt;bigIm&lt;/liabilitiesSource&gt;&lt;liabilitiesType&gt;overdue fulfilled&lt;/liabilitiesType&gt;&lt;debtorLegalForm&gt;legalPerson&lt;/debtorLegalForm&gt;&lt;/summaryRequest&gt;&lt;/liabilitiesSummaries&gt;&lt;imEntrepreneurOverdueLiabilities&gt;&lt;containRestricted&gt;false&lt;/containRestricted&gt;&lt;searchByPesel&gt;false&lt;/searchByPesel&gt;&lt;/imEntrepreneurOverdueLiabilities&gt;&lt;imEntrepreneurFulfilledLiabilities&gt;&lt;containRestricted&gt;false&lt;/containRestricted&gt;&lt;searchByPesel&gt;false&lt;/searchByPesel&gt;&lt;/imEntrepreneurFulfilledLiabilities&gt;&lt;imEntrepreneurInquiries/&gt;&lt;bikEntrepreneurOverdueLiabilities/&gt;&lt;zbpUnreliableEntrepreneursByNip/&gt;&lt;/components&gt;&lt;reportSubject xsi:type="ns5:LegalPerson" xmlns:ns5="http://api.big.pl/bimo/v1"&gt;&lt;fullName&gt;PTASZNIK&lt;/fullName&gt;&lt;nip&gt;9523658461&lt;/nip&gt;&lt;/reportSubject&gt;&lt;consentList&gt;&lt;consent grantDate="2019-08-28"&gt;entrepreneurZbpAuthorisation&lt;/consent&gt;&lt;consent grantDate="2019-08-28"&gt;bigImInquiriesAuthorisation&lt;/consent&gt;&lt;consent grantDate="2019-08-28"&gt;entrepreneurBikAuthorisation&lt;/consent&gt;&lt;/consentList&gt;&lt;/reportComposition&gt;&lt;/currentRequest&gt;&lt;exchangeRateTable&gt;&lt;id&gt;200/A/NBP/2019&lt;/id&gt;&lt;date&gt;2019-10-15&lt;/date&gt;&lt;/exchangeRateTable&gt;&lt;components&gt;&lt;reportComponent&gt;&lt;componentId&gt;t9c/WB1ysCfI2L2NKP2MR+lxobM=&lt;/componentId&gt;&lt;componentType&gt;imEntrepreneurOverdueLiabilities&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:35.883&lt;/validityDateTime&gt;&lt;processingResult&gt;noDataFound&lt;/processingResult&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;x2lrRU4UH8Nd0KNIMK/7Nk0nH1A=&lt;/componentId&gt;&lt;componentType&gt;imEntrepreneurFulfilledLiabilities&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:35.887&lt;/validityDateTime&gt;&lt;processingResult&gt;noDataFound&lt;/processingResult&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;z0dItQENKoXkF3oaFvBFjsey2Ys=&lt;/componentId&gt;&lt;componentType&gt;imEntrepreneurInquiries&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:36.243&lt;/validityDateTime&gt;&lt;processingResult&gt;success&lt;/processingResult&gt;&lt;data xsi:type="ns3:ImInquiriesData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;inquiriesByMarketSegment&gt;&lt;segment&gt;enterprise&lt;/segment&gt;&lt;inquiries0To30&gt;48&lt;/inquiries0To30&gt;&lt;inquiries31To90&gt;0&lt;/inquiries31To90&gt;&lt;inquiries91To365&gt;0&lt;/inquiries91To365&gt;&lt;/inquiriesByMarketSegment&gt;&lt;/data&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;h0H6YK+gGKXk2VcbosfT5CvK3GM=&lt;/componentId&gt;&lt;componentType&gt;zbpUnreliableEntrepreneursByNip&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:35.886&lt;/validityDateTime&gt;&lt;processingResult&gt;success&lt;/processingResult&gt;&lt;data xsi:type="ns3:ZbpUnreliableEntrepreneursByNipData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;checkResult&gt;noDataFound&lt;/checkResult&gt;&lt;/data&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;ceb85508a50948108ab532f33fc73358&lt;/componentId&gt;&lt;componentType&gt;bikEntrepreneurOverdueLiabilities&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:37.212&lt;/validityDateTime&gt;&lt;processingResult&gt;noDataFound&lt;/processingResult&gt;&lt;/reportComponent&gt;&lt;reportComponent&gt;&lt;componentId&gt;AVrr1m8yNSasPlWBXez5FO09tH0=&lt;/componentId&gt;&lt;componentType&gt;liabilitiesSummary&lt;/componentType&gt;&lt;validityDateTime&gt;2019-10-15T13:07:38&lt;/validityDateTime&gt;&lt;processingResult&gt;success&lt;/processingResult&gt;&lt;data xsi:type="ns3:LiabilitiesSummaryData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;&lt;checkResult&gt;negativeInformationNotFounded&lt;/checkResult&gt;&lt;overdueLiabilitiesSummary&gt;&lt;creditorsCount&gt;0&lt;/creditorsCount&gt;&lt;economicInformationsCount&gt;0&lt;/economicInformationsCount&gt;&lt;liabilitiesCount&gt;0&lt;/liabilitiesCount&gt;&lt;totalAmount&gt;0&lt;/totalAmount&gt;&lt;totalOverdueAmount&gt;0&lt;/totalOverdueAmount&gt;&lt;/overdueLiabilitiesSummary&gt;&lt;fulfilledLiabilitiesSummary&gt;&lt;creditorsCount&gt;0&lt;/creditorsCount&gt;&lt;economicInformationsCount&gt;0&lt;/economicInformationsCount&gt;&lt;liabilitiesCount&gt;0&lt;/liabilitiesCount&gt;&lt;totalAmount&gt;0&lt;/totalAmount&gt;&lt;totalRepaidAmount&gt;0&lt;/totalRepaidAmount&gt;&lt;/fulfilledLiabilitiesSummary&gt;&lt;/data&gt;&lt;/reportComponent&gt;&lt;/components&gt;&lt;/success&gt;&lt;/ns3:getReportResponse&gt;]]></data></a:getReportResponse></soapenv:Body></soapenv:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, bigMock);
            
            reportsItem = creditFactory.requestAdditionalCreditScoringData(validationItemsMap);
        Test.stopTest();
        
        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.companiesList.get(0).bigRequested);
    }
    
    
    /*******************************************************************************
    *  Summary         : test response from Crif with API error 
    *  Created         : 22/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testBigApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.BIG_Requested__c = false;
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
        
        Map<String, CreditFactoryValidationItem> validationItemsMap = new Map<String, CreditFactoryValidationItem>();
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        validationItem.parametersMap = new Map<String, Object>();
        validationItem.parametersMap.put('ConsentGrantDate', Datetime.now());
        validationItemsMap.put('ConsentSigner', validationItem);
        
        String errorMessage;
        Test.startTest();
            SingleRequestMock bigReportMock = new SingleRequestMock(500, 'Complete', 'test', null);
            Test.setMock(HttpCalloutMock.class, bigReportMock);
            try {
                 creditFactory.requestAdditionalCreditScoringData(validationItemsMap);
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals('Big API error. Please contact your administrator. Internal Error', errorMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (overdue debts)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringOverdueDebts() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 5000;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Total_Overdue_Amount__c = 1;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('003', cfResult.statusCode);
        System.assertEquals('Company has overdue debts. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 10000;
        update testOpportunity;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (threashold > 2000 and <= 8000)
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringThreshold() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 5000;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;
        
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());
        
        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(50, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring if there are only carnet GPS units
    *  Created         : 01/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCarnetOnlyProcessing() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_cards_consumption_monthly__c = 0;
        testOpportunity.Anzahl_der_Karten__c = 0;
        testOpportunity.Number_of_GPS_units__c = 2;
        update testOpportunity;

        String opportunityId = testOpportunity.Id;

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('015', cfResult.statusCode);
        System.assertEquals('Customer check successful, waiting for the advance payment for ordered goods.', cfResult.messagesList.get(0).text);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring if there are carnet GPS units with shell cards
    *  Created         : 01/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCarnetWithShellProcessing() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Poland');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Number_of_GPS_units__c = 2;
        testOpportunity.Zahlungsziel_2__c = '7';
        update testOpportunity;

        String opportunityId = testOpportunity.Id;

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Poland');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 7', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 7', cfResult.messagesList.get(1).text);
        System.assertEquals('Customer check successful, waiting for the advance payment for ordered goods.', cfResult.messagesList.get(2).text);
    }
}