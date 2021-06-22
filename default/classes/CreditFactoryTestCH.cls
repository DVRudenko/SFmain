@IsTest
public class CreditFactoryTestCH {

    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        Account account = CreditFactoryTestUtils.generateAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityCH();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Contact contact = CreditFactoryTestUtils.generateContactCH();
        contact.AccountId = account.Id;
        insert contact;

        OpportunityContactRole role = CreditFactoryTestUtils.generateOpportunityContactRole();
        role.OpportunityId = opportunity.Id;
        role.ContactId = contact.Id;
        insert role;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport('Switzerland-DE');
        report.Opportunity__c = opportunity.Id;
        insert report;

        Credit_Factory_Report_Employee__c reportEmployee = CreditFactoryTestUtils.generateCreditFactoryReportEmployee('Switzerland-DE');
        reportEmployee.Credit_Factory_Report__c = report.Id;
        insert reportEmployee;

        List<SObject> customSettingsList = new List<SObject>();
        CreditSystem__c crediconnectSettings = CreditFactoryTestUtils.generateCrediconnectSetting();
        customSettingsList.add(crediconnectSettings);
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
        customSettingsList.add(lexisNexisSettings);
        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Switzerland-DE', Index__c = 1.6);
        customSettingsList.add(fuelPrice);
        insert customSettingsList;

        Tankkarten__c card = CreditFactoryTestUtils.generateTankkarten();
        card.Opportunity__c = opportunity.Id;
        insert card;

        Product2 product2 = CreditFactoryTestUtils.generateProduct2();
        insert product2;

        PricebookEntry pricebookEntry = CreditFactoryTestUtils.generatePricebookEntry();
        pricebookEntry.Product2Id = product2.Id;
        pricebookEntry.CurrencyIsoCode = 'CHF';
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

        CF_Risky_Business_Code__c riskyBusinessCode = new CF_Risky_Business_Code__c(Name = '4931', Countries__c = 'CHDE');
        insert riskyBusinessCode;
        
        Solvency__c solvency = CreditFactoryTestUtils.returnSolvencySettingsCH();
        insert solvency;

        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsCH();
        insert calculations;
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory validation implementation
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactoryValidation() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

        System.assertEquals(true, creditFactoryValidation instanceof CreditFactoryValidationImplCH);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 02/12/2020 by Ivan Kulinkovich
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

        System.assertEquals('TESTO INDUSTRIAL SERVICES AG', company.name);
    }


    /*******************************************************************************
    *  Summary         : test validate profile
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProfile() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);

        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryTestUtils.generateCreditFactoryUserProfile();
        insert cfUserProfile;
        Map<String, CreditFactoryValidationItem> passedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Profile'}, false);

        System.assertEquals(true, passedValidationItemsMap.values().get(0).passed);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        creditFactorySettings.returnSearchValidations();
    }


    /*******************************************************************************
    *  Summary         : test validate closed opportunity
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateClosedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

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
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBlackList() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

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

        Credit_Black_List_Company__c blackListCompany2 = CreditFactoryTestUtils.generateBlackListCompanyCH();
        insert blackListCompany2;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'BlackList'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateProcessedOpportunity() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

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
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateNumberOfCards() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

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
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBDDAttachments() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

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
    *  Summary         : test sepa attachment
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateBDDAttachments2() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;

        List<SObject> sobjectsList = new List<SObject>();
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);

        Map<String, Object> attachmentsMap = new Map<String, Object>();
        attachmentsMap.put('name', 'BDD');
        List<Map<String, Object>> attachmentsList = new List<Map<String, Object>>();
        attachmentsList.add(attachmentsMap);
        Map<String, Object> filesMap = new Map<String, Object>();
        filesMap.put('title', 'BDD');
        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        filesList.add(filesMap);

        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactoryDataMap.put('directDebitFormAvailable', true);
        creditFactoryDataMap.put('files', filesList);
        creditFactoryDataMap.put('attachments', attachmentsList);

        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'SepaAttachment'}, false);

        System.assertEquals(true, validationItemsMap.values().get(0).passed);
    }


    /*******************************************************************************
    *  Summary         : test validate process opportunity
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSearchDuplicates() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-FR');

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

        Account dupAccount = CreditFactoryTestUtils.generateAccountCH();
        dupAccount.Steuernummer__c = '537643966';
        insert dupAccount;

        Opportunity dupOpportunity = CreditFactoryTestUtils.generateOpportunityCH();
        dupOpportunity.AccountId = dupAccount.Id;
        insert dupOpportunity;

        Contact dupContact = CreditFactoryTestUtils.generateContactCH();
        dupContact.AccountId = dupAccount.Id;
        insert dupContact;

        validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);

        System.assertEquals(false, validationItemsMap.values().get(0).passed);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
        System.assertEquals(true, duplicateFieldsToUpdate.containsKey('Opportunity'));
        System.assertEquals('Manual Scoring', ((Map<String, Object>) duplicateFieldsToUpdate.get('Opportunity')).get('CF_Stage__c'));
    }


    /*******************************************************************************
    *  Summary         : test return Credit Factory implementation
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReturnCreditFactory() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-IT');

        System.assertEquals(true, creditFactory instanceof CreditFactoryImplCH);
    }


    /*******************************************************************************
    *  Summary         : test set internal CF company
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSetInternalCFCompany() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-FR');

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

        System.assertEquals('TESTO INDUSTRIAL SERVICES AG', company.name);
    }


    /*******************************************************************************
    *  Summary         : test check for existing report
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testReportsExist() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSelectCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-IT');

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
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByVatNumber() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <s:Header> <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <u:Timestamp u:Id="_0"> <u:Created>2020-12-02T15:30:40.161Z</u:Created> <u:Expires>2020-12-02T15:35:40.161Z</u:Expires> </u:Timestamp> </o:Security> </s:Header> <s:Body> <GetHitListExResponse xmlns="http://crediconnect.ch/V2/02/"> <GetHitListExResult xmlns:a="http://schemas.creditreform.ch/2017/05" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <a:HitListItem> <a:CrefoID>408687265</a:CrefoID> <a:ReportingCrefoID>408687265</a:ReportingCrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:StatusCode>Active</a:StatusCode> <a:ArchiveType>Business MainArchive Active</a:ArchiveType> <a:Address> <a:Id i:nil="true"></a:Id> <a:CrefoID>408687265</a:CrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:AddressType>Business</a:AddressType> <a:Gender>Void</a:Gender> <a:Salutation i:nil="true"></a:Salutation> <a:FirstName i:nil="true"></a:FirstName> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:YearOfBirth i:nil="true"></a:YearOfBirth> <a:Name>Testo Industrial Services AG</a:Name> <a:AddressLine1>Gewerbestrasse</a:AddressLine1> <a:AddressLine2></a:AddressLine2> <a:HouseNr>12a</a:HouseNr> <a:PostalCode>8132</a:PostalCode> <a:City>Egg b. Zürich</a:City> <a:Canton>ZH</a:Canton> <a:Country>CH</a:Country> <a:Communication> <a:Phone1>0432771030</a:Phone1> <a:Phone2></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax>0432771031</a:Fax> <a:Email>info@testotis.ch</a:Email> <a:Url>www.testotis.ch</a:Url> </a:Communication> </a:Address> <a:PreviousAddress>testo industrial services AG, Gewerbestrasse 12a 8132 Egg b. Zürich</a:PreviousAddress> </a:HitListItem> <a:HitListItem> <a:CrefoID>422205902</a:CrefoID> <a:ReportingCrefoID>408687265</a:ReportingCrefoID> <a:UID></a:UID> <a:HrNr></a:HrNr> <a:StatusCode>Active</a:StatusCode> <a:ArchiveType>Business SubArchive Active</a:ArchiveType> <a:Address> <a:Id i:nil="true"></a:Id> <a:CrefoID>422205902</a:CrefoID> <a:UID></a:UID> <a:HrNr></a:HrNr> <a:AddressType>Business</a:AddressType> <a:Gender>Void</a:Gender> <a:Salutation i:nil="true"></a:Salutation> <a:FirstName i:nil="true"></a:FirstName> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:YearOfBirth i:nil="true"></a:YearOfBirth> <a:Name>Testo Industrial Services AG, Filiale, QM-Office</a:Name> <a:AddressLine1>Hubertingerstrasse</a:AddressLine1> <a:AddressLine2></a:AddressLine2> <a:HouseNr>1</a:HouseNr> <a:PostalCode>8638</a:PostalCode> <a:City>Goldingen</a:City> <a:Canton>SG</a:Canton> <a:Country>CH</a:Country> <a:Communication> <a:Phone1></a:Phone1> <a:Phone2></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax></a:Fax> <a:Email></a:Email> <a:Url></a:Url> </a:Communication> </a:Address> <a:PreviousAddress>QM-Office, Filiale der testo industrial services AG, Hubertingerstrasse 1 8638 Goldingen</a:PreviousAddress> </a:HitListItem> <a:HitListItem> <a:CrefoID>421824565</a:CrefoID> <a:ReportingCrefoID>408687265</a:ReportingCrefoID> <a:UID></a:UID> <a:HrNr></a:HrNr> <a:StatusCode>Active</a:StatusCode> <a:ArchiveType>Business SubArchive Active</a:ArchiveType> <a:Address> <a:Id i:nil="true"></a:Id> <a:CrefoID>421824565</a:CrefoID> <a:UID></a:UID> <a:HrNr></a:HrNr> <a:AddressType>Business</a:AddressType> <a:Gender>Void</a:Gender> <a:Salutation i:nil="true"></a:Salutation> <a:FirstName i:nil="true"></a:FirstName> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:YearOfBirth i:nil="true"></a:YearOfBirth> <a:Name>Testo Industrial Service Center Kaiseraugst</a:Name> <a:AddressLine1>Landstrasse</a:AddressLine1> <a:AddressLine2></a:AddressLine2> <a:HouseNr>71</a:HouseNr> <a:PostalCode>4303</a:PostalCode> <a:City>Kaiseraugst</a:City> <a:Canton>AG</a:Canton> <a:Country>CH</a:Country> <a:Communication> <a:Phone1>0618114741</a:Phone1> <a:Phone2></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax></a:Fax> <a:Email></a:Email> <a:Url></a:Url> </a:Communication> </a:Address> <a:PreviousAddress>Testo Industrial Services AG, Filiale, Service Center, Landstrasse 71 4303 Kaiseraugst</a:PreviousAddress> </a:HitListItem> </GetHitListExResult> </GetHitListExResponse> </s:Body> </s:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(3, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for searching company by all parameters
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestSearchCompanyByAllParameters() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <s:Header> <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <u:Timestamp u:Id="_0"> <u:Created>2020-12-02T15:30:40.161Z</u:Created> <u:Expires>2020-12-02T15:35:40.161Z</u:Expires> </u:Timestamp> </o:Security> </s:Header> <s:Body> <GetHitListExResponse xmlns="http://crediconnect.ch/V2/02/"> <GetHitListExResult xmlns:a="http://schemas.creditreform.ch/2017/05" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> </GetHitListExResult> </GetHitListExResponse> </s:Body> </s:Envelope>', null);
            mocksMap.put('<ns1:UID>CHE113471243</ns1:UID>', searchMock);
            SingleRequestMock searchMock2 = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <s:Header> <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <u:Timestamp u:Id="_0"> <u:Created>2020-12-02T15:30:40.161Z</u:Created> <u:Expires>2020-12-02T15:35:40.161Z</u:Expires> </u:Timestamp> </o:Security> </s:Header> <s:Body> <GetHitListExResponse xmlns="http://crediconnect.ch/V2/02/"> <GetHitListExResult xmlns:a="http://schemas.creditreform.ch/2017/05" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <a:HitListItem> <a:CrefoID>408687265</a:CrefoID> <a:ReportingCrefoID>408687265</a:ReportingCrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:StatusCode>Active</a:StatusCode> <a:ArchiveType>Business MainArchive Active</a:ArchiveType> <a:Address> <a:Id i:nil="true"></a:Id> <a:CrefoID>408687265</a:CrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:AddressType>Business</a:AddressType> <a:Gender>Void</a:Gender> <a:Salutation i:nil="true"></a:Salutation> <a:FirstName i:nil="true"></a:FirstName> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:YearOfBirth i:nil="true"></a:YearOfBirth> <a:Name>Testo Industrial Services AG</a:Name> <a:AddressLine1>Gewerbestrasse</a:AddressLine1> <a:AddressLine2></a:AddressLine2> <a:HouseNr>12a</a:HouseNr> <a:PostalCode>8132</a:PostalCode> <a:City>Egg b. Zürich</a:City> <a:Canton>ZH</a:Canton> <a:Country>CH</a:Country> <a:Communication> <a:Phone1>0432771030</a:Phone1> <a:Phone2></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax>0432771031</a:Fax> <a:Email>info@testotis.ch</a:Email> <a:Url>www.testotis.ch</a:Url> </a:Communication> </a:Address> <a:PreviousAddress>testo industrial services AG, Gewerbestrasse 12a 8132 Egg b. Zürich</a:PreviousAddress> </a:HitListItem> </GetHitListExResult> </GetHitListExResponse> </s:Body> </s:Envelope>', null);
            mocksMap.put('<ns1:Name>TESTO INDUSTRIAL SERVICES AG</ns1:Name>', searchMock2);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
            Set<String> searchParametersSet = creditFactorySettings.returnSearchParameters();
            companiesList = creditFactory.requestSearchCompanies(searchParametersSet);
        Test.stopTest();

        creditFactorySettings.returnSearchColumns();

        System.assertEquals(1, companiesList.size());
    }


    /*******************************************************************************
    *  Summary         : test request for getting reports
    *  Created         : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testRequestCompanyReports() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
            SingleRequestMock crediconnectReportMock = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <s:Header> <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <u:Timestamp u:Id="_0"> <u:Created>2020-12-01T08:18:50.526Z</u:Created> <u:Expires>2020-12-01T08:23:50.526Z</u:Expires> </u:Timestamp> </o:Security> </s:Header> <s:Body> <GetReportResponse xmlns="http://crediconnect.ch/V2/02/"> <GetReportResult xmlns:a="http://schemas.creditreform.ch/2017/05" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <a:OrderData> <a:OrderID>540772617</a:OrderID> <a:OriginOrderID i:nil="true"></a:OriginOrderID> <a:ProductCode>07</a:ProductCode> <a:ReportLanguage>EN</a:ReportLanguage> <a:MemberID>910024010</a:MemberID> <a:UserID>11</a:UserID> <a:Reference1 i:nil="true"></a:Reference1> <a:Reference2 i:nil="true"></a:Reference2> <a:InquiryAmount>0</a:InquiryAmount> <a:TermsOfExecution>Void</a:TermsOfExecution> <a:ReportFormat>PDF</a:ReportFormat> <a:DateOfSupply>2020-12-01T09:18:48.6647854+01:00</a:DateOfSupply> <a:CrefoID>408687265</a:CrefoID> <a:RequestedCrefoID>408687265</a:RequestedCrefoID> <a:UpdateInfo> <a:UpdateOutstanding>None</a:UpdateOutstanding> <a:BranchOffice>ZH</a:BranchOffice> <a:BranchOfficeCommunication> <a:Phone1>0443078080</a:Phone1> <a:Phone2 i:nil="true"></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax>0443078085</a:Fax> <a:Email>order@zuerich.creditreform.ch</a:Email> <a:Url></a:Url> </a:BranchOfficeCommunication> <a:PIType>None</a:PIType> </a:UpdateInfo> <a:State i:nil="true"></a:State> <a:Remark i:nil="true"></a:Remark> </a:OrderData> <a:Address> <a:Id i:nil="true"></a:Id> <a:CrefoID>408687265</a:CrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:AddressType>Business</a:AddressType> <a:Gender>Void</a:Gender> <a:Salutation i:nil="true"></a:Salutation> <a:FirstName i:nil="true"></a:FirstName> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:YearOfBirth i:nil="true"></a:YearOfBirth> <a:Name>Testo Industrial Services AG</a:Name> <a:AddressLine1>Gewerbestrasse</a:AddressLine1> <a:AddressLine2></a:AddressLine2> <a:HouseNr>12a</a:HouseNr> <a:PostalCode>8132</a:PostalCode> <a:City>Egg b. Zürich</a:City> <a:Canton>ZH</a:Canton> <a:Country>CH</a:Country> <a:Communication> <a:Phone1>0432771030</a:Phone1> <a:Phone2></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax>0432771031</a:Fax> <a:Email>info@testotis.ch</a:Email> <a:Url>www.testotis.ch</a:Url> </a:Communication> </a:Address> <a:BasicContent> <a:CrefoID>408687265</a:CrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:Language>DE</a:Language> <a:LegalForm> <a:Code>31</a:Code> <a:Description>Joint-stock Company (AG)</a:Description> </a:LegalForm> <a:Domicile>Egg</a:Domicile> <a:Foundation>2007</a:Foundation> <a:DateOfRegistry>2007-02-28T00:00:00</a:DateOfRegistry> <a:DateOfCancellation i:nil="true"></a:DateOfCancellation> <a:Capitals> <a:Capital> <a:Code>01</a:Code> <a:Description>Share capital</a:Description> <a:Currency>CHF</a:Currency> <a:Amount>100000</a:Amount> </a:Capital> </a:Capitals> <a:Status>Active</a:Status> <a:Nation i:nil="true"></a:Nation> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:PlaceOfOrigin i:nil="true"></a:PlaceOfOrigin> </a:BasicContent> <a:ProductContent> <a:Industry> <a:Code>331300</a:Code> <a:Description>Repair of electronic and optical equipment</a:Description> </a:Industry> <a:CategoryEmployees>Medium150</a:CategoryEmployees> <a:CategoryTurnover>Small10</a:CategoryTurnover> <a:Solvency> <a:Type>BA</a:Type> <a:Value>Green</a:Value> </a:Solvency> <a:ModificationFlags i:nil="true"></a:ModificationFlags> <a:POD i:nil="true"></a:POD> <a:CreditLimit>8000</a:CreditLimit> <a:CreditJudgement i:nil="true"></a:CreditJudgement> </a:ProductContent> <a:ExtendedProductContent> <a:ForeignerStatus i:nil="true"></a:ForeignerStatus> <a:Turnover i:nil="true"></a:Turnover> <a:Employees i:nil="true"></a:Employees> <a:ChapterScores i:nil="true"></a:ChapterScores> <a:Titel i:nil="true"></a:Titel> <a:PostalAddress> <a:NameZ1>Testo Industrial Services AG</a:NameZ1> <a:NameZ2></a:NameZ2> <a:NameZ3></a:NameZ3> <a:Co></a:Co> <a:Street>Gewerbestrasse</a:Street> <a:HouseNr>12a</a:HouseNr> <a:Meadow></a:Meadow> <a:HouseName></a:HouseName> <a:Country>CH</a:Country> <a:PostalCode>8132</a:PostalCode> <a:Place>Egg b. Zürich</a:Place> <a:DeliverableCode></a:DeliverableCode> <a:Postbox></a:Postbox> <a:PBPostalCode></a:PBPostalCode> <a:PBPlace></a:PBPlace> </a:PostalAddress> </a:ExtendedProductContent> <a:CustomizedKeyValues> <a:KeyValue> <a:Key>AuthorisedSignatories</a:Key> <a:Value>&lt;?xml version="1.0" encoding="UTF-8"?&gt;&lt;AuthorisedSignatories&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;402896685&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Kiener -Stauffer&lt;/Name&gt; &lt;Firstname&gt;Daniel&lt;/Firstname&gt; &lt;City&gt;Oetwil am See&lt;/City&gt; &lt;PlaceOfOrigin&gt;Riggisberg&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;CH&lt;/Nation&gt; &lt;Country&gt;CH&lt;/Country&gt; &lt;Body&gt;Supervisory board&lt;/Body&gt; &lt;Position&gt;Member&lt;/Position&gt; &lt;Since&gt;03.2007&lt;/Since&gt; &lt;Signature&gt;Sole sign. authority&lt;/Signature&gt; &lt;SignatureCode&gt;SAUTH&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;421421716&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Hähnel&lt;/Name&gt; &lt;Firstname&gt;Wolfgang&lt;/Firstname&gt; &lt;City&gt;Goldingen&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;DE&lt;/Nation&gt; &lt;Country&gt;CH&lt;/Country&gt; &lt;Body&gt;Management&lt;/Body&gt; &lt;Position&gt;General manager&lt;/Position&gt; &lt;Since&gt;04.2012&lt;/Since&gt; &lt;Signature&gt;Sole sign. authority&lt;/Signature&gt; &lt;SignatureCode&gt;SAUTH&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;423402500&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Sauter&lt;/Name&gt; &lt;Firstname&gt;Markus&lt;/Firstname&gt; &lt;City&gt;Oberried (DE)&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;DE&lt;/Nation&gt; &lt;Country&gt;DE&lt;/Country&gt; &lt;Body&gt;other authorised signatories&lt;/Body&gt; &lt;Position&gt;Signing clerk&lt;/Position&gt; &lt;Since&gt;07.2016&lt;/Since&gt; &lt;Signature&gt;Joint power of attorney in twos&lt;/Signature&gt; &lt;SignatureCode&gt;JATTOR&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;420082117&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Föhrenbacher&lt;/Name&gt; &lt;Firstname&gt;Raimund&lt;/Firstname&gt; &lt;City&gt;St. Peter&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;DE&lt;/Nation&gt; &lt;Country&gt;DE&lt;/Country&gt; &lt;Body&gt;Supervisory board&lt;/Body&gt; &lt;Position&gt;Chairman&lt;/Position&gt; &lt;Since&gt;02.2009&lt;/Since&gt; &lt;Signature&gt;Sole sign. authority&lt;/Signature&gt; &lt;SignatureCode&gt;SAUTH&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;/AuthorisedSignatories&gt;</a:Value> </a:KeyValue> <a:KeyValue> <a:Key>NameAndDomicileChanges</a:Key> <a:Value>&lt;NameAndDomicileChanges&gt; &lt;NameAndDomicileChange&gt; &lt;Alteration&gt;2&lt;/Alteration&gt; &lt;Address&gt;Testo Industrial Services AGGewerbestrasse 12a, 8132 Egg b. Zürich&lt;/Address&gt; &lt;DurationInMonths&gt;33&lt;/DurationInMonths&gt; &lt;From&gt;03.2018&lt;/From&gt; &lt;Until&gt;12.2020&lt;/Until&gt; &lt;/NameAndDomicileChange&gt; &lt;NameAndDomicileChange&gt; &lt;Alteration&gt;3&lt;/Alteration&gt; &lt;Address&gt;testo industrial services AG Gewerbestrasse 12a, 8132 Egg b. Zürich&lt;/Address&gt; &lt;DurationInMonths&gt;133&lt;/DurationInMonths&gt; &lt;From&gt;02.2007&lt;/From&gt; &lt;Until&gt;03.2018&lt;/Until&gt; &lt;/NameAndDomicileChange&gt; &lt;/NameAndDomicileChanges&gt;</a:Value> </a:KeyValue> <a:KeyValue> <a:Key>Owners</a:Key> <a:Value>&lt;Owners&gt; &lt;Owner&gt; &lt;AddressType&gt;Business&lt;/AddressType&gt; &lt;CrefoID&gt;423266745&lt;/CrefoID&gt; &lt;StatusCode&gt;Active&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Testo SE &amp; Co. KGaA&lt;/Name&gt; &lt;Firstname&gt;&lt;/Firstname&gt; &lt;City&gt;Lenzkirch&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;&lt;/Nation&gt; &lt;Country&gt;DE&lt;/Country&gt; &lt;Body&gt;Shareholder&lt;/Body&gt; &lt;Position&gt;Sole shareholder&lt;/Position&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/Owner&gt; &lt;/Owners&gt;</a:Value> </a:KeyValue> <a:KeyValue> <a:Key>Score</a:Key> <a:Value>100</a:Value> </a:KeyValue> </a:CustomizedKeyValues> <a:MonitoringOrderData> <a:MonitoringOrderData> <a:CrefoID>408687265</a:CrefoID> <a:ProductCode>72</a:ProductCode> <a:ReportFormat>PDF</a:ReportFormat> <a:Reference1>360411</a:Reference1> <a:Reference2></a:Reference2> <a:ReasonOfInquiry>Creditworthiness</a:ReasonOfInquiry> <a:StartDate>2020-11-02T00:00:00</a:StartDate> <a:EndDate>2099-12-31T00:00:00</a:EndDate> <a:ExtendedData i:nil="true"></a:ExtendedData> <a:RequestedCrefoID i:nil="true"></a:RequestedCrefoID> <a:OrderID>540211334</a:OrderID> </a:MonitoringOrderData> </a:MonitoringOrderData> <a:ReportData>test</a:ReportData> <a:ReportAttachmentAvailable>false</a:ReportAttachmentAvailable> </GetReportResult> </GetReportResponse> </s:Body> </s:Envelope>', null);
            mocksMap.put('https://webservice.crediconnect.ch/V2/03/CrediConnect.svc/basic', crediconnectReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            reportsItem = creditFactory.requestCompanyReports('408687265');
        Test.stopTest();

        System.assertEquals(1, reportsItem.companiesList.size());
        System.assertEquals(true, reportsItem.isReportAvailable);
        System.assertEquals('Testo Industrial Services AG', reportsItem.companiesList.get(0).name);
        System.assertEquals('1', reportsItem.companiesList.get(0).classRating);
        System.assertEquals('100', reportsItem.companiesList.get(0).solvencyIndex);
        System.assertEquals('Very High', reportsItem.companiesList.get(0).emailRisk);
        System.assertEquals('Email Created at least X Years Ago', reportsItem.companiesList.get(0).riskDescription);
        System.assertEquals('Lower Fraud Risk', reportsItem.companiesList.get(0).riskAdvice);
        System.assertEquals('Full Match', reportsItem.companiesList.get(0).nameMatch);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        creditFactorySettings.returnReportSectionsData(creditFactory.getInternalCFCompany(), reportsItem.companiesList.get(0), null);

        List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
        System.assertEquals(1, reportsItem.companiesList.size());
        List<Credit_Factory_Report_Employee__c> reportEmployeesList = creditFactory.createCFReportEmployeesInstances();
        creditFactory.createPdfReports(opportunityId);

        System.assertEquals(1, reportsList.size());
        System.assertEquals('Testo Industrial Services AG', reportsList.get(0).Name);
        System.assertEquals(4, reportEmployeesList.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : test response from Crediconnect with API error
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCrediconnectApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
            SingleRequestMock crediconnectReportMock = new SingleRequestMock(500, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <s:Header> <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <u:Timestamp u:Id="_0"> <u:Created>2020-12-03T08:43:38.117Z</u:Created> <u:Expires>2020-12-03T08:48:38.117Z</u:Expires> </u:Timestamp> </o:Security> </s:Header> <s:Body> <s:Fault> <faultcode>s:Client</faultcode> <faultstring xml:lang="de-CH">Invalid CrefoID(4086872666)</faultstring> <detail> <InvalidCrefoIDFault xmlns="http://schemas.creditreform.ch/2017/05" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <Message>Invalid CrefoID(4086872666)</Message> </InvalidCrefoIDFault> </detail> </s:Fault> </s:Body> </s:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, crediconnectReportMock);
            try {
                creditFactory.requestCompanyReports('4086872666');
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Crediconnect API error. Please contact your administrator. Invalid CrefoID(4086872666). Company Id: 4086872666', errorMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test response from LexisNexis with API error
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testLexisNexisApiErrors() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
            SingleRequestMock crediconnectReportMock = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <s:Header> <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <u:Timestamp u:Id="_0"> <u:Created>2020-12-01T08:18:50.526Z</u:Created> <u:Expires>2020-12-01T08:23:50.526Z</u:Expires> </u:Timestamp> </o:Security> </s:Header> <s:Body> <GetReportResponse xmlns="http://crediconnect.ch/V2/02/"> <GetReportResult xmlns:a="http://schemas.creditreform.ch/2017/05" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <a:OrderData> <a:OrderID>540772617</a:OrderID> <a:OriginOrderID i:nil="true"></a:OriginOrderID> <a:ProductCode>07</a:ProductCode> <a:ReportLanguage>EN</a:ReportLanguage> <a:MemberID>910024010</a:MemberID> <a:UserID>11</a:UserID> <a:Reference1 i:nil="true"></a:Reference1> <a:Reference2 i:nil="true"></a:Reference2> <a:InquiryAmount>0</a:InquiryAmount> <a:TermsOfExecution>Void</a:TermsOfExecution> <a:ReportFormat>PDF</a:ReportFormat> <a:DateOfSupply>2020-12-01T09:18:48.6647854+01:00</a:DateOfSupply> <a:CrefoID>408687265</a:CrefoID> <a:RequestedCrefoID>408687265</a:RequestedCrefoID> <a:UpdateInfo> <a:UpdateOutstanding>None</a:UpdateOutstanding> <a:BranchOffice>ZH</a:BranchOffice> <a:BranchOfficeCommunication> <a:Phone1>0443078080</a:Phone1> <a:Phone2 i:nil="true"></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax>0443078085</a:Fax> <a:Email>order@zuerich.creditreform.ch</a:Email> <a:Url></a:Url> </a:BranchOfficeCommunication> <a:PIType>None</a:PIType> </a:UpdateInfo> <a:State i:nil="true"></a:State> <a:Remark i:nil="true"></a:Remark> </a:OrderData> <a:Address> <a:Id i:nil="true"></a:Id> <a:CrefoID>408687265</a:CrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:AddressType>Business</a:AddressType> <a:Gender>Void</a:Gender> <a:Salutation i:nil="true"></a:Salutation> <a:FirstName i:nil="true"></a:FirstName> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:YearOfBirth i:nil="true"></a:YearOfBirth> <a:Name>Testo Industrial Services AG</a:Name> <a:AddressLine1>Gewerbestrasse</a:AddressLine1> <a:AddressLine2></a:AddressLine2> <a:HouseNr>12a</a:HouseNr> <a:PostalCode>8132</a:PostalCode> <a:City>Egg b. Zürich</a:City> <a:Canton>ZH</a:Canton> <a:Country>CH</a:Country> <a:Communication> <a:Phone1>0432771030</a:Phone1> <a:Phone2></a:Phone2> <a:Phone3 i:nil="true"></a:Phone3> <a:Fax>0432771031</a:Fax> <a:Email>info@testotis.ch</a:Email> <a:Url>www.testotis.ch</a:Url> </a:Communication> </a:Address> <a:BasicContent> <a:CrefoID>408687265</a:CrefoID> <a:UID>CHE113471243</a:UID> <a:HrNr>CH02030307442</a:HrNr> <a:Language>DE</a:Language> <a:LegalForm> <a:Code>31</a:Code> <a:Description>Joint-stock Company (AG)</a:Description> </a:LegalForm> <a:Domicile>Egg</a:Domicile> <a:Foundation>2007</a:Foundation> <a:DateOfRegistry>2007-02-28T00:00:00</a:DateOfRegistry> <a:DateOfCancellation i:nil="true"></a:DateOfCancellation> <a:Capitals> <a:Capital> <a:Code>01</a:Code> <a:Description>Share capital</a:Description> <a:Currency>CHF</a:Currency> <a:Amount>100000</a:Amount> </a:Capital> </a:Capitals> <a:Status>Active</a:Status> <a:Nation i:nil="true"></a:Nation> <a:DateOfBirth i:nil="true"></a:DateOfBirth> <a:PlaceOfOrigin i:nil="true"></a:PlaceOfOrigin> </a:BasicContent> <a:ProductContent> <a:Industry> <a:Code>331300</a:Code> <a:Description>Repair of electronic and optical equipment</a:Description> </a:Industry> <a:CategoryEmployees>Medium150</a:CategoryEmployees> <a:CategoryTurnover>Small10</a:CategoryTurnover> <a:Solvency> <a:Type>BA</a:Type> <a:Value>Green</a:Value> </a:Solvency> <a:ModificationFlags i:nil="true"></a:ModificationFlags> <a:POD i:nil="true"></a:POD> <a:CreditLimit>8000</a:CreditLimit> <a:CreditJudgement i:nil="true"></a:CreditJudgement> </a:ProductContent> <a:ExtendedProductContent> <a:ForeignerStatus i:nil="true"></a:ForeignerStatus> <a:Turnover i:nil="true"></a:Turnover> <a:Employees i:nil="true"></a:Employees> <a:ChapterScores i:nil="true"></a:ChapterScores> <a:Titel i:nil="true"></a:Titel> <a:PostalAddress> <a:NameZ1>Testo Industrial Services AG</a:NameZ1> <a:NameZ2></a:NameZ2> <a:NameZ3></a:NameZ3> <a:Co></a:Co> <a:Street>Gewerbestrasse</a:Street> <a:HouseNr>12a</a:HouseNr> <a:Meadow></a:Meadow> <a:HouseName></a:HouseName> <a:Country>CH</a:Country> <a:PostalCode>8132</a:PostalCode> <a:Place>Egg b. Zürich</a:Place> <a:DeliverableCode></a:DeliverableCode> <a:Postbox></a:Postbox> <a:PBPostalCode></a:PBPostalCode> <a:PBPlace></a:PBPlace> </a:PostalAddress> </a:ExtendedProductContent> <a:CustomizedKeyValues> <a:KeyValue> <a:Key>AuthorisedSignatories</a:Key> <a:Value>&lt;?xml version="1.0" encoding="UTF-8"?&gt;&lt;AuthorisedSignatories&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;402896685&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Kiener -Stauffer&lt;/Name&gt; &lt;Firstname&gt;Daniel&lt;/Firstname&gt; &lt;City&gt;Oetwil am See&lt;/City&gt; &lt;PlaceOfOrigin&gt;Riggisberg&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;CH&lt;/Nation&gt; &lt;Country&gt;CH&lt;/Country&gt; &lt;Body&gt;Supervisory board&lt;/Body&gt; &lt;Position&gt;Member&lt;/Position&gt; &lt;Since&gt;03.2007&lt;/Since&gt; &lt;Signature&gt;Sole sign. authority&lt;/Signature&gt; &lt;SignatureCode&gt;SAUTH&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;421421716&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Hähnel&lt;/Name&gt; &lt;Firstname&gt;Wolfgang&lt;/Firstname&gt; &lt;City&gt;Goldingen&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;DE&lt;/Nation&gt; &lt;Country&gt;CH&lt;/Country&gt; &lt;Body&gt;Management&lt;/Body&gt; &lt;Position&gt;General manager&lt;/Position&gt; &lt;Since&gt;04.2012&lt;/Since&gt; &lt;Signature&gt;Sole sign. authority&lt;/Signature&gt; &lt;SignatureCode&gt;SAUTH&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;423402500&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Sauter&lt;/Name&gt; &lt;Firstname&gt;Markus&lt;/Firstname&gt; &lt;City&gt;Oberried (DE)&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;DE&lt;/Nation&gt; &lt;Country&gt;DE&lt;/Country&gt; &lt;Body&gt;other authorised signatories&lt;/Body&gt; &lt;Position&gt;Signing clerk&lt;/Position&gt; &lt;Since&gt;07.2016&lt;/Since&gt; &lt;Signature&gt;Joint power of attorney in twos&lt;/Signature&gt; &lt;SignatureCode&gt;JATTOR&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;AuthorisedSignatory&gt; &lt;AddressType&gt;Consumer&lt;/AddressType&gt; &lt;CrefoID&gt;420082117&lt;/CrefoID&gt; &lt;StatusCode&gt;Alive&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Föhrenbacher&lt;/Name&gt; &lt;Firstname&gt;Raimund&lt;/Firstname&gt; &lt;City&gt;St. Peter&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;DE&lt;/Nation&gt; &lt;Country&gt;DE&lt;/Country&gt; &lt;Body&gt;Supervisory board&lt;/Body&gt; &lt;Position&gt;Chairman&lt;/Position&gt; &lt;Since&gt;02.2009&lt;/Since&gt; &lt;Signature&gt;Sole sign. authority&lt;/Signature&gt; &lt;SignatureCode&gt;SAUTH&lt;/SignatureCode&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/AuthorisedSignatory&gt; &lt;/AuthorisedSignatories&gt;</a:Value> </a:KeyValue> <a:KeyValue> <a:Key>NameAndDomicileChanges</a:Key> <a:Value>&lt;NameAndDomicileChanges&gt; &lt;NameAndDomicileChange&gt; &lt;Alteration&gt;2&lt;/Alteration&gt; &lt;Address&gt;Testo Industrial Services AGGewerbestrasse 12a, 8132 Egg b. Zürich&lt;/Address&gt; &lt;DurationInMonths&gt;33&lt;/DurationInMonths&gt; &lt;From&gt;03.2018&lt;/From&gt; &lt;Until&gt;12.2020&lt;/Until&gt; &lt;/NameAndDomicileChange&gt; &lt;NameAndDomicileChange&gt; &lt;Alteration&gt;3&lt;/Alteration&gt; &lt;Address&gt;testo industrial services AG Gewerbestrasse 12a, 8132 Egg b. Zürich&lt;/Address&gt; &lt;DurationInMonths&gt;133&lt;/DurationInMonths&gt; &lt;From&gt;02.2007&lt;/From&gt; &lt;Until&gt;03.2018&lt;/Until&gt; &lt;/NameAndDomicileChange&gt; &lt;/NameAndDomicileChanges&gt;</a:Value> </a:KeyValue> <a:KeyValue> <a:Key>Owners</a:Key> <a:Value>&lt;Owners&gt; &lt;Owner&gt; &lt;AddressType&gt;Business&lt;/AddressType&gt; &lt;CrefoID&gt;423266745&lt;/CrefoID&gt; &lt;StatusCode&gt;Active&lt;/StatusCode&gt; &lt;Gender&gt;Void&lt;/Gender&gt; &lt;Name&gt;Testo SE &amp; Co. KGaA&lt;/Name&gt; &lt;Firstname&gt;&lt;/Firstname&gt; &lt;City&gt;Lenzkirch&lt;/City&gt; &lt;PlaceOfOrigin&gt;&lt;/PlaceOfOrigin&gt; &lt;Nation&gt;&lt;/Nation&gt; &lt;Country&gt;DE&lt;/Country&gt; &lt;Body&gt;Shareholder&lt;/Body&gt; &lt;Position&gt;Sole shareholder&lt;/Position&gt; &lt;Warning&gt;False&lt;/Warning&gt; &lt;/Owner&gt; &lt;/Owners&gt;</a:Value> </a:KeyValue> <a:KeyValue> <a:Key>Score</a:Key> <a:Value>100</a:Value> </a:KeyValue> </a:CustomizedKeyValues> <a:MonitoringOrderData> <a:MonitoringOrderData> <a:CrefoID>408687265</a:CrefoID> <a:ProductCode>72</a:ProductCode> <a:ReportFormat>PDF</a:ReportFormat> <a:Reference1>360411</a:Reference1> <a:Reference2></a:Reference2> <a:ReasonOfInquiry>Creditworthiness</a:ReasonOfInquiry> <a:StartDate>2020-11-02T00:00:00</a:StartDate> <a:EndDate>2099-12-31T00:00:00</a:EndDate> <a:ExtendedData i:nil="true"></a:ExtendedData> <a:RequestedCrefoID i:nil="true"></a:RequestedCrefoID> <a:OrderID>540211334</a:OrderID> </a:MonitoringOrderData> </a:MonitoringOrderData> <a:ReportData>test</a:ReportData> <a:ReportAttachmentAvailable>false</a:ReportAttachmentAvailable> </GetReportResult> </GetReportResponse> </s:Body> </s:Envelope>', null);
            mocksMap.put('https://webservice.crediconnect.ch/V2/03/CrediConnect.svc/basic', crediconnectReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            creditFactory.requestCompanyReports('408687265');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('LexisNexis API error. Please contact your administrator. The format of email is incorrect. Please try again. Company Id: 408687265', errorMessage);
    }
    
    
    /*******************************************************************************
    *  Summary         : test company name validation
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateCompanyName() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, null);
        creditFactorySettings.returnReportValidations();
        creditFactorySettings.returnReportStopValidations();

        System.assertEquals('Update Name', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnNameFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('TESTO INDUSTRIAL SERVICES AG', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('Name'));

        creditFactoryDataMap.put('name', 'Test Name');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'CompanyName'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test address validation
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateAddress() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-FR');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-FR');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-FR');
        Map<String, Object> addressUpdateData = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, null);

        System.assertEquals('Update Address', addressUpdateData.get('header'));

        Map<String, Object> addressFieldsToUpdate = creditFactory.returnAddressFieldsToUpdate();
        System.assertEquals(true, addressFieldsToUpdate.containsKey('Account'));
        System.assertEquals('EGG B. ZÜRICH', ((Map<String, Object>) addressFieldsToUpdate.get('Account')).get('BillingCity'));

        creditFactoryDataMap.put('registeredStreet', 'test street');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'Address'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test vat number validation
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateVatNumber() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-IT');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-IT');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-IT');
        Map<String, Object> vatUpdateData = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Vat Number', vatUpdateData.get('header'));

        Map<String, Object> vatNumberFieldsToUpdate = creditFactory.returnVatNumberFieldsToUpdate();
        System.assertEquals(true, vatNumberFieldsToUpdate.containsKey('Account'));
        System.assertEquals('CHE113471243', ((Map<String, Object>) vatNumberFieldsToUpdate.get('Account')).get('Umsatzsteuer_ID__c'));

        creditFactoryDataMap.put('vatNumber', 'CH123456789');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'VatNumber'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test tax id validation
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateTaxId() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-IT');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-IT');

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
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-IT');
        Map<String, Object> taxUpdateData = creditFactorySettings.returnTaxIdUpdateData(internalCompany, externalCompany);

        System.assertEquals('Update Tax Id', taxUpdateData.get('header'));

        Map<String, Object> taxIdFieldsToUpdate = creditFactory.returnTaxIdFieldsToUpdate();
        System.assertEquals(true, taxIdFieldsToUpdate.containsKey('Account'));
        System.assertEquals('CH02030307442', ((Map<String, Object>) taxIdFieldsToUpdate.get('Account')).get('Steuernummer__c'));

        creditFactoryDataMap.put('taxId', 'CH1234567890');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'TaxId'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test swift bic validation
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateSwiftBic() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
        System.assertEquals('testSWIFT123', ((Map<String, Object>) swiftBicFieldsToUpdate.get('Opportunity')).get('SWIFT_BIC__c'));

        creditFactoryDataMap.put('requestedSwiftBic', '1234567890');
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'SwiftBic'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test contact validation
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateContact() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateLostOpportunitites() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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

        Opportunity lostOpportunity = CreditFactoryTestUtils.generateOpportunityCH();
        lostOpportunity.AccountId = account.Id;
        lostOpportunity.StageName = 'Closed Lost';
        lostOpportunity.Gruende_verloren__c = 'Refused Credit';
        insert lostOpportunity;

        Map<String, CreditFactoryValidationItem> failedValidationItemsMap = creditFactoryValidation.validate(new List<String> {'LostOpportunities'}, true);

        System.assertEquals(false, failedValidationItemsMap.values().get(0).passed);
    }
    
    
    /*******************************************************************************
    *  Summary         : test email risk validation
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidateEmailRisk() {
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation('Switzerland-DE');
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), failedValidationItemsMap);

        System.assertEquals('009', cfResult.statusCode);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 1
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);

        Map<String, Object> updateOpportunityFieldsMap = creditFactory.returnUpdateOpportunityFieldsToUpdate();
        System.assertEquals(true, updateOpportunityFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) updateOpportunityFieldsMap.get('Opportunity')).get('Credit_check_date__c'));

        Map<String, Object> closedWonFieldsMap = creditFactory.returnClosedWonFieldsToUpdate();
        System.assertEquals(true, closedWonFieldsMap.containsKey('Opportunity'));
        System.assertEquals(Date.today(), ((Map<String, Object>) closedWonFieldsMap.get('Opportunity')).get('CloseDate'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 1
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating1() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        String dateToString = String.valueOf(Date.today()).substring(5, 7) + '.' + String.valueOf(Date.today()).substring(0, 4);
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_Of_Last_Change_Of_Director__c = dateToString;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
        System.assertEquals(true, cfResult.messagesList.get(2).text.contains('Deposit to pay'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 2
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 2
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating2() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        testOpportunity.Total_consumption_l_month__c = 300;
        update testOpportunity;
        String opportunityId = testOpportunity.Id;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_of_Foundation__c = String.valueOf(Date.today()) + 'T00:00:00';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('14', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 14', cfResult.messagesList.get(1).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 3
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 1
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        String dateToString = String.valueOf(Date.today()).substring(5, 7) + '.' + String.valueOf(Date.today()).substring(0, 4);
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_Of_Last_Change_Of_Address__c = dateToString;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
        System.assertEquals(true, cfResult.messagesList.get(2).text.contains('Deposit to pay'));
    }


    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 3
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating3() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
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
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        creditFactory.selectCompanyReports(opportunityId);

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals('New business', cfResult.depositReason);
        System.assertEquals(33, cfResult.securityLevel);
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 4
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        testOpportunity.Zahlungsart__c = 'Banküberweisung';
        update testOpportunity;
        
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(null, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
    }
    
    
    /*******************************************************************************
    *  Summary         : test 2 credit scoring for rating 4
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test2CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Class_Rating__c = '4';
        report.Credit_Limit__c = '300';
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals('Low Recommended CL', cfResult.depositReason);
        System.assertEquals(4, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
        System.assertEquals(true, cfResult.messagesList.get(2).text.contains('Deposit to pay'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test 3 credit scoring for rating 4
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void test3CreditScoringRating4() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

        Opportunity testOpportunity = CreditFactoryTestUtils.selectOpportunity();
        String opportunityId = testOpportunity.Id;
        
        String dateToString = String.valueOf(Date.today()).substring(5, 7) + '.' + String.valueOf(Date.today()).substring(0, 4);
        Credit_Factory_Report__c report = CreditFactoryTestUtils.selectCreditFactoryReport();
        report.Date_Of_Last_Change_Of_Name__c = dateToString;
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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
        System.assertEquals(true, cfResult.messagesList.get(2).text.contains('Deposit to pay'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 5
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating5() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(100, cfResult.securityLevel);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
        System.assertEquals(true, cfResult.messagesList.get(2).text.contains('Deposit to pay'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring for rating 6
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringRating6() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('001', cfResult.statusCode);
        System.assertEquals('30', cfResult.billingPeriod);
        System.assertEquals('27', cfResult.paymentTerms);
        System.assertEquals(110, cfResult.securityLevel);
        System.assertEquals('Low credit rating (rating 6)', cfResult.depositReason);
        System.assertEquals('Billing Period can be set to 30', cfResult.messagesList.get(0).text);
        System.assertEquals('Payment Terms can be set to 27', cfResult.messagesList.get(1).text);
        System.assertEquals(true, cfResult.messagesList.get(2).text.contains('Deposit to pay'));
    }
    
    
    /*******************************************************************************
    *  Summary         : test credit scoring (high limit)
    *  Created         : 03/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testCreditScoringHighLimit() {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory('Switzerland-DE');

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

        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings('Switzerland-DE');
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), new Map<String, CreditFactoryValidationItem>());

        System.assertEquals('004', cfResult.statusCode);
        System.assertEquals('Requested limit too high. Please refer to credit.', cfResult.messagesList.get(0).text);
    }
}


