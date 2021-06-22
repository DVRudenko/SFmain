/**
 * Created by Nikita.Mikhailov on 14.02.2019.
 */
@IsTest
public with sharing class GFNI_HandlerTest {

    @IsTest
    public static void testCreateCustomerViaEMAIL() {
        createCustomSetting(true, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, false, null, true, false);
        Id cardIdDriver = createCard(oppId, true, true);
        Id cardIdVehicle = createCard(oppId, false, true);

        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateCustomerViaAPIOKResponse() {
        createCustomSetting(false, false);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, false, null, true, false);
        Id cardIdDriver = createCard(oppId, true, true);
        Id cardIdVehicle = createCard(oppId, false, true);
        //Id offerId = createItem(oppId);
        OpportunityLineItem opportunityOffer = generateOpportunityOffer(oppId);
        insert opportunityOffer;
        // Offer Item creation
        Offer_Item__c offerItem = generateOfferLineItem(oppId, opportunityOffer);
        insert offerItem;

        Test.setMock(HttpCalloutMock.class, createOKClientCreateRequestMock());
        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateCustomerViaAPINoCardsOKResponse() {
        createCustomSetting(false, false);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, false, false, true, true);
        Id cardIdDriver = createCard(oppId, true, true);
        Id cardIdVehicle = createCard(oppId, false, true);

        Test.setMock(HttpCalloutMock.class, createOKClientCreateRequestMock());
        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateCustomerViaAPINOTOKResponse() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, false, true, true, false);
        Id cardIdDriver = createCard(oppId, true, true);
        Id cardIdVehicle = createCard(oppId, false, true);

        Test.setMock(HttpCalloutMock.class, createNotOKClientCreateRequestMock());
        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateCustomerViaAPIRequestBuilder() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(true, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, false, false, false, false);
        Id cardIdDriver = createCard(oppId, true, true);
        Id cardIdVehicle = createCard(oppId, false, false);

        Test.setMock(HttpCalloutMock.class, createOKClientCreateRequestMock());
        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateCustomerViaAPIRequestBuilderExceptionBillingAddress() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(true, null, 'This line is more than 40 symbols. May the force be with you.', true);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, false, false, false, false);
        Id cardIdDriver = createCard(oppId, true, true);
        Id cardIdVehicle = createCard(oppId, false, false);

        Test.setMock(HttpCalloutMock.class, createOKClientCreateRequestMock());
        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateCustomerViaAPIRequestBuilderExceptionShippingAddress() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(true, null, 'This line is more than 40 symbols. May the force be with you.', false);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, false, false, false, false);
        Id cardIdDriver = createCard(oppId, true, true);
        Id cardIdVehicle = createCard(oppId, false, false);

        Test.setMock(HttpCalloutMock.class, createOKClientCreateRequestMock());
        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateCustomerViaAPIRequestManyCards() {//test SelfServeUserId logic
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, true, null, true, false);

        for (Integer i = 0; i < 40; i++) {
            createCard(oppId, true, true);
        }

        Test.setMock(HttpCalloutMock.class, createOKClientCreateRequestMock());
        Test.startTest();
        GFNI_Handler.createFullGFNCustomer(oppId);
        Test.stopTest();
    }

    @IsTest
    public static void testApplicationStatusRequestOKCardStatus1() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, true, null, true, false);
        Id cardId = createCard(oppId, true, true);

        Test.setMock(HttpCalloutMock.class, createOKApplicationStatusRequestMock('1', cardId));
        Test.startTest();
        GFNI_Handler.checkCardStatus(new Set<Id>{
                oppId
        });
        Test.stopTest();

        System.assertEquals('Success', [SELECT GFNI_Status__c FROM Tankkarten__c WHERE Id = :cardId].GFNI_Status__c);
    }

    @IsTest
    public static void testApplicationStatusRequestOKCardStatus2() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, true, null, true, false);
        Id cardId = createCard(oppId, true, true);

        Test.setMock(HttpCalloutMock.class, createOKApplicationStatusRequestMock('2', cardId));
        Test.startTest();
        GFNI_Handler.checkCardStatus(new Set<Id>{
                oppId
        });
        Test.stopTest();

        System.assertEquals('Warning', [SELECT GFNI_Status__c FROM Tankkarten__c WHERE Id = :cardId].GFNI_Status__c);
    }

    @IsTest
    public static void testApplicationStatusRequestOKCardStatus3() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, true, null, true, false);
        Id cardId = createCard(oppId, true, true);

        Test.setMock(HttpCalloutMock.class, createOKApplicationStatusRequestMock('3', cardId));
        Test.startTest();
        GFNI_Handler.checkCardStatus(new Set<Id>{
                oppId
        });
        Test.stopTest();

        System.assertEquals('Failed', [SELECT GFNI_Status__c FROM Tankkarten__c WHERE Id = :cardId].GFNI_Status__c);
    }

    @IsTest
    public static void testApplicationStatusRequestNotOK() {
        createCustomSetting(false, true);
        createEmailSendingCustomSetting();
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, true, null, true, false);
        Id cardId = createCard(oppId, true, true);

        Test.setMock(HttpCalloutMock.class, createNotOKApplicationStatusRequestMock());
        Test.startTest();
        GFNI_Handler.checkCardStatus(new Set<Id>{
                oppId
        });
        Test.stopTest();
    }

    @IsTest
    //TODO: DEPRECATE IT
    public static void testGetUniqueProduct() {
        Id accId = createAccount(false, null, null, null);
        Id contactId = createContact();
        Id oppId = createOpportunity(accId, contactId, true, null, true, false);
        //Id offerId = createItem(oppId);
        OpportunityLineItem opportunityOffer = generateOpportunityOffer(oppId);
        insert opportunityOffer;
        // Offer Item creation
        Offer_Item__c offerItem = generateOfferLineItem(oppId, opportunityOffer);
        insert offerItem;

        Opportunity opportunity = [SELECT Id, Product__c, (SELECT Id, Product_Name__c, Product2.Family FROM OpportunityLineItems) FROM Opportunity WHERE Id = :oppId];
        opportunity.Product__c = null;
        update opportunity;

        System.assertEquals('Inbound Type B', GFNI_Utils.getUniqueProduct(opportunity));
    }

    @IsTest
    public static void testOther() {
        GFNI_Address address = new GFNI_Address();
        //address.Line2 = 'Line 2';
        //address.Line3 = 'Line 3';

        GFNI_Contact contact = new GFNI_Contact();
        contact.LastName = 'LasName';

        GFNI_Card card = new GFNI_Card();
        //card.CompanyName = 'CompanyName';

        GFNI_Customer customer = new GFNI_Customer();
        customer.addContact(contact);
        customer.addAddress(address);
        customer.addCardToCardOrder(card);

        Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        System.assertEquals((org.IsSandbox == true) ? false : true, GFNI_Utils.isProductionOrg());
    }

    private static SingleRequestMock createOKClientCreateRequestMock() {
        Map<String, String> responseHeaders = new Map<String, String>();
        String body = '{"CustomerId": "30238", "CustomerServiceReferenceId": "NL12485999"}';

        return new SingleRequestMock(200, 'OK', body, responseHeaders);
    }

    private static SingleRequestMock createNotOKClientCreateRequestMock() {
        Map<String, String> responseHeaders = new Map<String, String>();
        String body = ' {"code" : 422, "message" : "Unprocessable entity", "moreInformation" : "Invalid request message. Please correct that and try again"}';

        return new SingleRequestMock(422, 'Unprocessable entity', body, responseHeaders);
    }

    private static SingleRequestMock createOKApplicationStatusRequestMock(String cardStatus, Id cardId) {
        Map<String, String> responseHeaders = new Map<String, String>();
        String body = '';
        if (cardStatus == '1') {
            body = '[{"ApplicationStatus": "**Customer and all cards created successfully**","CustomerId": "78594","CustomerName": "TEST30 GOSSNER GMBH & CO. KG","CustomerServiceReferenceId": "DE12490330","CardsStatus": [{"CardApplicationStatusId": "' + cardStatus + '","CardId": "718733","CardType": "3","CardPAN": "7002140001730800016","CardDriverName": "Shell Card 1","CardRefId": "' + GlobalUtils.generateGUIDFromId(cardId) + '"}]}]';
        } else {
            body = '[ { "ApplicationStatus": "**Customer and all cards created successfully**", "CustomerId": "78594", "CustomerName": "TEST30 GOSSNER GMBH & CO. KG", "CustomerServiceReferenceId": "DE12490330", "CardsStatus": [ { "CardApplicationStatusId": "' + cardStatus + '", "CardId": "718733", "CardType": "3", "CardPAN": "7002140001730800016", "CardDriverName": "Shell Card 1", "CardProcessingError": { "ErrorMessage": "**IsVRNEmbossed** is required" }, "CardRefId": "' + GlobalUtils.generateGUIDFromId(cardId) + '" } ] } ]';
        }

        return new SingleRequestMock(200, 'OK', body, responseHeaders);
    }

    private static SingleRequestMock createNotOKApplicationStatusRequestMock() {
        Map<String, String> responseHeaders = new Map<String, String>();
        String body = ' {"code": 404, "message": "Not Found", "moreInformation": "Application doesn\'t exist in backend. Please verify the Application Id and try again"}';

        return new SingleRequestMock(404, 'Not Found', body, responseHeaders);
    }

    private static void createCustomSetting(Boolean isForRobotValue, Boolean isTestMode) {
        Map<String, GFNI_General_Settings__c> gfni_general_settings = GFNI_General_Settings__c.getAll();
        if (gfni_general_settings.containsKey('DE')) {
            gfni_general_settings.get('DE').IsForRobot__c = isForRobotValue;
            update gfni_general_settings.get('DE');
        } else {
            GFNI_General_Settings__c customSetting = new GFNI_General_Settings__c();
            customSetting.Name = 'DE';
            customSetting.Application_Status__c = '/applicationstatus';
            customSetting.Create_Customer_and_Cards__c = '/customer';
            customSetting.Get_Customer_Id__c = '/customerId';
            customSetting.IsForRobot__c = isForRobotValue;
            customSetting.Number_Of_Send_Tries__c = 3;
            customSetting.Prod_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
            customSetting.Test_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
            customSetting.x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
            customSetting.x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
            customSetting.Support_email__c = 'test@email.com';
            customSetting.Test_support_email__c = 'test@test.com';
            customSetting.test_x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
            customSetting.test_x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
            customSetting.Test_mode__c = isTestMode;
            insert customSetting;
        }
    }

    private static void createEmailSendingCustomSetting() {
        Map<String, Account_GFN_Report_Email_Params__c> emailParams = Account_GFN_Report_Email_Params__c.getAll();
        Account_GFN_Report_Email_Params__c emailParam = new Account_GFN_Report_Email_Params__c();

        emailParam.Name = 'Excel';
        emailParam.Email__c = 'nikita.mikhailov@fleetcor.ru';
        emailParam.Email_body__c = 'Attached file is generated using Salesforce for a robot processing';
        emailParam.Attach_format__c = '.xls';
        emailParam.Test_mode__c = true;
        emailParam.Test_mode_email__c = 'test@email.com';

        insert emailParam;
    }

    private static Id createAccount(Boolean isSteuernummerNull, String billingCountryCode, String addressLine, Boolean isBillingAddress) {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Test city';
        acc.BillingState = 'Berlin';
        acc.BillingPostalCode = 'TESTPOST';
        acc.BillingCountry = 'Germany';

        if (addressLine == null) {
            acc.BillingStreet = 'Test street';
            acc.ShippingStreet = 'Test street';
        } else if (isBillingAddress) {
            acc.BillingStreet = addressLine;
            acc.ShippingStreet = 'Address line';
        } else {
            acc.BillingStreet = 'Address line';
            acc.ShippingStreet = addressLine;
        }

        if (billingCountryCode == null) {
            acc.BillingCountryCode = 'DE';
        } else {
            acc.BillingCountryCode = billingCountryCode;
        }

        acc.ShippingCity = 'Test city';
        acc.ShippingState = 'Berlin';
        acc.ShippingPostalCode = 'TESTPOST';
        acc.ShippingCountry = 'Germany';
        acc.ShippingCountryCode = 'DE';
        acc.Gesellschaftsform__c = 'Limited partnership';
        acc.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '712627722';
        acc.Umsatzsteuer_ID__c = 'DE141908329';
        if (!isSteuernummerNull)
            acc.Steuernummer__c = '2210583106';

        insert acc;

        return acc.Id;
    }

    private static Id createOpportunity(Id accId, Id contactId, Boolean isCreatedInGFN, Boolean papierrechnung, Boolean useDefault, Boolean customPin) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.Name = 'TestName';
        opp.StageName = 'ClosedWon';
        opp.CloseDate = System.today();
        opp.LeadSource = 'E2E Form';
        opp.CurrencyIsoCode = 'EUR';
        opp.CF_Credit_Limit__c = 1500.0;
        opp.Risk_Category__c = 'High';
        opp.Anzahl_der_Karten__c = 1.0;
        opp.bearbeitet_von__c = 'Autoprocessed by E2E';
        opp.Zahlungsart__c = 'Direct debit';
        opp.Garantie__c = 'Deposit';
        opp.Rechnungsperiode__c = '7 days';
        opp.ESI__c = 'eSI: 1654';
        if (papierrechnung != null) {
            opp.Papierrechnung__c = papierrechnung;
            opp.e_Invoicing_PDF__c = !papierrechnung;
        } else {
            opp.Papierrechnung__c = false;
            opp.e_Invoicing_PDF__c = false;
        }
        opp.Sec_Channel__c = 'Inbound';
        opp.Zahlungsziel_Credit__c = '7';
        opp.Angebotsdauer__c = '4 months';
        opp.Total_number_of_vehicles__c = 1.0;

        if (useDefault) {
            opp.Product__c = 'Platin';
        } else {
            opp.Product__c = 'Inbound Typ B';
            opp.GFNI_ApplicationId__c = 'fdc9254d-17ba-4d7d-9858-e6376893e2a9';
        }

        if (isCreatedInGFN) {
            opp.GFN_number_for_starts__c = 'DE12490330';
        }

        opp.Language_preference__c = 'German';
        opp.Next_Review_Date__c = System.today();
        opp.Garantie_other__c = 1100.0;
        opp.Credit_System_Number__c = '420896214';
        opp.Credit_System_Rating__c = '4';
        opp.SWIFT_BIC__c = 'BBRUBEBB';
        opp.IBAN__c = 'DE63265501051551881590';
        opp.Total_consumption_l_month__c = 100.0;
        opp.Eco_Fee__c = true;
        opp.Direct_Debit_Mandate_Type__c = 'Core';
        opp.VAT_Recovery__c = true;
        opp.Custom_PIN__c = customPin;
        opp.Starts_Status__c = '0.9 Ready for GFN';

        insert opp;
        Opportunity updateFormulaFieldOpp = [SELECT Registered_Country__c FROM Opportunity WHERE Id =: opp.Id];
        update opp;

        OpportunityContactRole contactRole = new OpportunityContactRole();
        contactRole.OpportunityId = opp.Id;
        contactRole.ContactId = contactId;
        contactRole.IsPrimary = true;

        insert contactRole;
        return opp.Id;
    }

    private static Id createCard(Id oppId, Boolean isDriverCard, Boolean useDefault) {
        Tankkarten__c card = new Tankkarten__c();
        card.Opportunity__c = oppId;
        card.Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';

        if (useDefault) {
            card.Produktbezugskategorie__c = '3 Category 2 plus all shop items';
        } else {
            card.Produktbezugskategorie__c = '2 Category 1 plus vehicle-related goods and services (oils, car wash)';
            card.GFNI_Status__c = 'Pending';
        }
        card.Fahrzeugtyp__c = 'PKW';
        card.Firmenname_auf_der_Karte__c = 'TEST';
        if (isDriverCard) {
            card.Driver_Name__c = 'TEST';
        } else {
            card.KFZ_Kennzeichen_oder_Fahrername__c = 'TEST';
        }
        card.Kilometerstand_Abfrage__c = true;

        insert card;

        return card.Id;
    }

    private static Id createContact() {
        Contact contact = new Contact();
        contact.Salutation = 'Herr';
        contact.FirstName = 'Test';
        contact.MiddleName = 'Test';
        contact.LastName = 'Test';
        contact.Email = 'test@test.com';
        contact.Phone = '+4996547654';
        contact.MobilePhone = '+49779654354';
        contact.Fax = null;

        insert contact;

        return contact.Id;
    }

    private static OpportunityLineItem generateOpportunityOffer(String opportunityId) {
        String INBOUND_TYPE_B = 'Inbound Type B';
        String STANDARD_PRICE_BOOK = 'Standard Price Book';

        Product2 product2Inb = new Product2();
        product2Inb.Family = 'SHELL';
        product2Inb.IsActive = true;
        product2Inb.Name = INBOUND_TYPE_B;
        product2Inb.Integration_Name__c = 'test';
        insert product2Inb;

        Offer_Item_Type__c offerItemTypeCard = new Offer_Item_Type__c();
        offerItemTypeCard.Fields_to_display__c = 'Category_of_products__c;Company_Name__c;Driver_Name__c;Mileage_data__c;Type_of_Card__c;Type_of_Vehicle__c;License_plate_number__c';
        offerItemTypeCard.Name = 'Shell Fuel Card';
        insert offerItemTypeCard;

        PricebookEntry pricebookEntryInb = new PricebookEntry();
        //pricebookEntryInb.Name = 'EV DE';
        pricebookEntryInb.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntryInb.Product2Id = product2Inb.Id;
        pricebookEntryInb.UnitPrice = 0.0;
        pricebookEntryInb.IsActive = true;
        insert pricebookEntryInb;

        List<Product2> offersList = [SELECT Name FROM Product2 WHERE Name = :INBOUND_TYPE_B];
        Map<String, Product2> offersMap = new Map<String, Product2>();
        for (Product2 offer : offersList) {
            offersMap.put(offer.Name, offer);
        }
        String pricebookId;
        if (!Test.isRunningTest()) {
            pricebookId = [SELECT Id FROM Pricebook2 WHERE Name = :STANDARD_PRICE_BOOK].Id;
        } else {
            pricebookId = Test.getStandardPricebookId();
        }
        List<PricebookEntry> pricebookEntryList = [
                SELECT Id, Product2.Name
                FROM PricebookEntry
                WHERE Product2Id IN :offersMap.values() AND
                Pricebook2Id = :pricebookId
        ];
        Map<String, PricebookEntry> priceBookMap = new Map<String, PricebookEntry>();
        for (PricebookEntry priceBook : pricebookEntryList) {
            priceBookMap.put(priceBook.Product2.Name, priceBook);
        }
        OpportunityLineItem inboundTypeBOffer = new OpportunityLineItem(
                OpportunityId = opportunityId,
                PricebookEntryId = priceBookMap.get(INBOUND_TYPE_B).Id,
                Product2Id = offersMap.get(INBOUND_TYPE_B).Id,
                Quantity = 1,
                TotalPrice = 0
        );
        return inboundTypeBOffer;
    }


    private static Offer_Item__c generateOfferLineItem(String opportunityId, OpportunityLineItem opportunityOffer) {
        String SHELL_FUEL_CARD = 'Shell Fuel Card';
        String INBOUND_TYPE_B = 'Inbound Type B';
        List<Offer_Item_Type__c> offersItemTypeList = [SELECT Name FROM Offer_Item_Type__c WHERE Name = :SHELL_FUEL_CARD];
        Map<String, Offer_Item_Type__c> offerItemTypesMap = new Map<String, Offer_Item_Type__c>();
        for (Offer_Item_Type__c offerItemType : offersItemTypeList) {
            offerItemTypesMap.put(offerItemType.Name, offerItemType);
        }
        Offer_Item__c fuelOfferItem = new Offer_Item__c(
                Opportunity_Product_Id__c = opportunityOffer.Id,
                Offer_Item_Type__c = offerItemTypesMap.get(SHELL_FUEL_CARD).Id,
                Category_of_products__c = '0 Diesel, tunnel-, highway- and ferry toll fees',
                Type_of_Card__c = 'Multi Network Card -- International',
                Type_of_Vehicle__c = 'PKW'
        );
        return fuelOfferItem;
    }
}