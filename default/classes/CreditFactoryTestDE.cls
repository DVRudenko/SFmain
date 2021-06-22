@IsTest
public class CreditFactoryTestDE {


    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityDE();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactDE();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Germany');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Germany');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c schufaSettings = CreditFactoryTestUtils.generateSchufaSetting();
        customSettingsList.add(schufaSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        CF_Order_Notifications__c orderNotifications = CreditFactoryTestUtils.generateOrderNotificationsSettingsDE();
        customSettingsList.add(orderNotifications);
        Solvency__c returnSolvencySettingsDE = CreditFactoryTestUtils.returnSolvencySettingsDE();
        customSettingsList.add(returnSolvencySettingsDE);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Germany', Index__c = 1.25);
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

        Attachment attachment = CreditFactoryTestUtils.generateGWAAttachment();
        attachment.ParentId = opportunity.Id;
        insert attachment;

        ContentVersion contentVersion = CreditFactoryTestUtils.generateContentVersion();
        insert contentVersion;

        ContentDocumentLink contentDocumentLink = CreditFactoryTestUtils.generateContentDocumentLink();
        contentDocumentLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        contentDocumentLink.LinkedEntityId = opportunity.Id;
        insert contentDocumentLink;

        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'DE');
        insert riskyBusinessCode;

        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsDE();
        insert calculations;
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplDE);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompanyValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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

        System.assertEquals('BUCHVERLAGSGESELLSCHAFT DRUCK MBH', company.name);
    }


    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);
        
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        creditFactorySettings.returnSearchValidations();
    }


    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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
    *  Created         : 13/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyDE();
        blackListCompany2.Customer_Id__c = 'DE';
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate desired payment terms and billing period
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateDesiredPaymentDetails() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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
    *  Created         : 23/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSepaAttachments() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidatePaymentMethod() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
    *  Summary         : test number of cards
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateOrder() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountDE();
        dupAccount.Steuernummer__c = '12344312';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityDE();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactDE();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplDE);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        System.assertEquals('BUCHVERLAGSGESELLSCHAFT DRUCK MBH', company.name);
    }


    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"companyId": 1645768,"companyName": "Buchverlagsgesellschaft Druck mbH","formOfOrganisation": "GMBH","street": "Schillerstr. 52-60","city": "Frankfurt am Main","dialingCode": "069","phoneNumber": "3352587","vatId": "DE123547899","branchCode": "7112","registerCourt": "Frankfurt am Main","traderegisterNumber": "HRB 3867","alreadyOnboarded": false,"onboardingDate": "","headQuarterID": 1645768}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/search/full/detail', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();
        
        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for ordering report on search step
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestOrderSearch() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);

        System.assertEquals('Order request was sent.', orderItem.message);
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
            SingleRequestMock schufaAuthMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', schufaAuthMock);
            SingleRequestMock schufaOrderEconomyInfoMock = new SingleRequestMock(200, 'Complete', '"ok"', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', schufaOrderEconomyInfoMock);
            SingleRequestMock shufaOrderStatusMock = new SingleRequestMock(200, 'Complete', '{"companyIDs": 1645768,"name": "Buchverlagsgesellschaft Druck mbH","order": [{"name": "CoreData","orderDate": "10.03.2020 13:05:34","reason": "","ordered": true,"completed": true,"failed": false},{"name": "Linkage","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "FullEconomyInfo","orderDate": "11.03.2020 06:29:52","reason": "","ordered": true,"completed": true,"failed": false},{"name": "ShortEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "CompactEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "Compliance","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "MediaScreening","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "TransparencyRegister","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false}],"tradeRegisterOrder": [{"documentType": "AD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "CD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "LG","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "GSS","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', shufaOrderStatusMock);
            SingleRequestMock shufaReportMock = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 150,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', shufaReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            creditFactory.requestStartReportsCheck('1645768');
            reportsItem = creditFactory.requestCompanyReports('1645768');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Buchverlagsgesellschaft Druck mbH', reportsItem.companiesList.get(0).name);
        System.assertEquals('1', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('0,5 Mio. bis 1 Mio. EUR', reportsItem.companiesList.get(0).turnOver);
        System.assertEquals('25000', reportsItem.companiesList.get(0).creditLimit);
        System.assertEquals('150', reportsItem.companiesList.get(0).solvencyIndex);
        System.assertEquals('Verified', reportsItem.companiesList.get(0).emailStatus);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        Map<String, Object> fieldsToUpdateMap = creditFactory.returnReportFieldsToUpdate();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('Buchverlagsgesellschaft Druck mbH', reportsList.get(0).Name);
        System.assertEquals(2, reportEmployeesList.size());
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Opportunity'));
        System.assertEquals('1', ((Map<String, Object>) fieldsToUpdateMap.get('Opportunity')).get('Credit_System_Rating__c'));
        System.assertEquals(true, fieldsToUpdateMap.containsKey('Account'));
        System.assertEquals('7112', ((Map<String, Object>) fieldsToUpdateMap.get('Account')).get('Branchencode__c'));
    }


    /*******************************************************************************
    *  Summary         : test response from Schufa with API error
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSchufaApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
            SingleRequestMock schufaReportMock = new SingleRequestMock(400, 'Complete', '{"code": 400,"message": "Invalid or missing company id"}', null);
            Test.setMock(HttpCalloutMock.class, schufaReportMock);
            try {
                creditFactory.requestCompanyReports('1234512345');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Schufa API error. Please contact your administrator. Bad request. Company Id: 1234512345', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
            SingleRequestMock schufaAuthMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', schufaAuthMock);
            SingleRequestMock schufaOrderEconomyInfoMock = new SingleRequestMock(200, 'Complete', '"ok"', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', schufaOrderEconomyInfoMock);
            SingleRequestMock shufaOrderStatusMock = new SingleRequestMock(200, 'Complete', '{"companyIDs": 1645768,"name": "Buchverlagsgesellschaft Druck mbH","order": [{"name": "CoreData","orderDate": "10.03.2020 13:05:34","reason": "","ordered": true,"completed": true,"failed": false},{"name": "Linkage","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "FullEconomyInfo","orderDate": "11.03.2020 06:29:52","reason": "","ordered": true,"completed": true,"failed": false},{"name": "ShortEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "CompactEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "Compliance","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "MediaScreening","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "TransparencyRegister","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false}],"tradeRegisterOrder": [{"documentType": "AD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "CD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "LG","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "GSS","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', shufaOrderStatusMock);
            SingleRequestMock shufaReportMock = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 150,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', shufaReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('1645768');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: 1645768', errorMessage);
    }


    /*******************************************************************************
    *  Summary         : test request for ordering company on report step
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestOrderReport() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);

        System.assertEquals('Order request was sent.', orderItem.message);
    }


    /*******************************************************************************
    *  Summary         : test report ordering with the attachment from Classic
    *  Created         : 12/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestOrderReportWithAttachmentFromClassic() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        List<Attachment> attachmentsList = CreditFactoryService.selectAttachmentsList(opportunityId);
        List<Map<String, Object>> attachmentsListToAdd = new List<Map<String, Object>>();
        for (Attachment attachment : attachmentsList) {
            Map<String, Object> attachmentsMap = CreditFactoryService.generateAttachmentsDataStructure(attachment);
            attachmentsMap.put('body', EncodingUtil.base64Encode(attachment.Body));
            attachmentsListToAdd.add(attachmentsMap);
        }

        creditFactoryDataMap.put('attachments', attachmentsListToAdd);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);

        System.assertEquals('Order request was sent.', orderItem.message);
    }


    /*******************************************************************************
    *  Summary         : test report ordering with the attachment from Lightning
    *  Created         : 12/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestOrderReportWithAttachmentFromLightning() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        List<ContentVersion> filesList = CreditFactoryService.selectFilesList(opportunityId);
        List<Map<String, Object>> filesListToAdd = new List<Map<String, Object>>();
        for (ContentVersion file : filesList) {
            Map<String, Object> filesMap = CreditFactoryService.generateFilesDataStructure(file);
            filesMap.put('versionData', EncodingUtil.base64Encode(file.VersionData));
            filesListToAdd.add(filesMap);
        }

        creditFactoryDataMap.put('files', filesListToAdd);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);

        System.assertEquals('Order request was sent.', orderItem.message);
    }


    /*******************************************************************************
    *  Summary         : test request for searching company
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnOrderFieldsToUpdate() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);

        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        Map<String, Object> fieldsToUpdate = creditFactory.returnOrderFieldsToUpdate(null);

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
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();
        
        System.assertEquals('Update Name', addressUpdateData.get('header'));
        
        Map<String, Object> addressFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Buchverlagsgesellschaft Druck mbH', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('Frankfurt am Main', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

        creditFactoryDataMap.put('street', 'test');
        creditFactoryDataMap.put('postalStreet', 'test');
        creditFactoryDataMap.put('registeredStreet', 'test');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test vat number validation
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('DE123547899', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', '123412341234');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test swift bic validation
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSwiftBic() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
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
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateMandateType() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
    *  Created         : 14/08/2020 by Anton
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }


    /*******************************************************************************
    *  Summary         : test business code validation
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateIndustry() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Germany');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Industry'}, true);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        cfItem.companiesList.get(0).principalActivityCode = '4931';
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfItem.companiesList);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Industry'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('010', cfResult.statusCode);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
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
    *  Summary         : test 2 credit scoring for rating 1
    *  Created         : 16/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = '01.01.' + String.valueOf(Date.today().year());
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals('New business', cfResult.depositReason);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('15', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(4, cfResult.securityLevel);
        System.assertEquals(true, cfResult.depositReason.contains('Recommended CL'));
    }


    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 2
    *  Created         : 15/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Sec_Channel__c = 'Outbound';
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
        creditFactoryDataMap.put('desiredBillingPeriod', '30');
        creditFactoryDataMap.put('desiredPaymentTerms', '10');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('10', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 3
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '3';
        report.Date_of_Foundation__c = '01.01.' + String.valueOf(Date.today().year());
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals(true, cfResult.depositReason.contains('New business'));
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 4
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '4';
        report.Date_of_Foundation__c = '01.01.' + String.valueOf(Date.today().year());
        update report;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        opportunity.Total_consumption_l_month__c = 100;
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals(true, cfResult.depositReason.contains('rating 5'));
    }


    /*******************************************************************************
    *  Summary         : test credit scoring for rating 6
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating6() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('7', cfResult.billingPeriod);
        System.assertEquals('7', cfResult.paymentTerms);
        System.assertEquals(110, cfResult.securityLevel);
        System.assertEquals(true, cfResult.depositReason.contains('rating 6'));
    }


    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Germany');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Germany');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}