public class E2ELongFormUtilsTest {
    public static LongForm__c longFormDE;
    public static LongForm_Menu__c longFormMenu;
    public static LongForm_Menu_Item__c longFormMenuForStep1;
    public static LongForm_Menu_Item__c longFormMenuForStep2;
    public static LongForm_Menu_Item__c longFormMenuForStep3;
    public static LongForm_Menu_Item__c longFormMenuForStep4;
    public static LongForm_Pricelist__c internationalPartnerPrice;
    public static LongForm_Pricelist__c internationalPartnerDiffPrice;
    public static LongForm_Pricelist__c nationalNotPartnersPrice;
    public static LongForm_Pricelist__c nationalNotPartnersDiffPrice;
    public static LongForm_Pricelist__c internationalNotPartners;
    public static LongForm_Pricelist__c internationalNotPartnersDiffPrice;
    public static LongForm_Pricelist__c nationalPartners;
    public static LongForm_Pricelist__c nationalPartnersDiffPrice;
    public static Map<String, Map<String, Product2>> productsMap;
    public static Map<String, Map<String, Map<String, Offer_Item_Type__c>>> offerItemTypesMap;
    public static Map<String, Map<String, PricebookEntry>> pricebookEntriesMap;


    /*******************************************************************************
    *  Name            : createE2EDEUser()
    *  Summary         : Create E2EDE user
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : user
    ******************************************************************************/
    public static User createE2EDEUser() {
        Profile e2eProfile = [SELECT Id FROM Profile WHERE Name = 'E2E Profile'];
        User e2eUser = new User(
                ProfileId = e2eProfile.Id,
                Username = 'e2e' + System.now().millisecond() + '@fleetcor.de',
                Alias = 'sr',
                Email = 'test@fleetcor.de',
                Country = 'Germany',
                CountryCode = 'DE',
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );

        return e2eUser;
    }


    /*******************************************************************************
	*  Name            : createLongForm()
	*  Summary         : Create long form DE
	*  CreatedDate     : 10/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public static void createLongForm(String country) {
        longFormDE = new LongForm__c(
                Name = 'LongFormDETEST',
                Country__c = country,
                Active__c = true,
                Test_Locator__c = true,
                Test_Payment__c = true,
                Test_Mode__c = false,
                Title__c = 'Order a fuel card online'
        );
        insert longFormDE;
    }


    /*******************************************************************************
    *  Name            : createLongFormMenu()
    *  Summary         : Create long for menu
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createLongFormMenu() {
        longFormMenu = new LongForm_Menu__c(
                Name = 'LongForm Menu DE Test',
                Long_Form__c = longFormDE.Id,
                Test_Mode__c = false
        );
        insert longFormMenu;
    }


    /*******************************************************************************
    *  Name            : createMenuItemForStep1()
    *  Summary         : Create menu fot step 1
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createMenuItemForStep1(String deviceView) {
        longFormMenuForStep1 = new LongForm_Menu_Item__c(
                Name = '1. CREDIT SCORE',
                Long_Form_Menu__c = longFormMenu.Id,
                Step_Name__c = '1. Kreditprüfung',
                Order__c = 1,
                Device_View__c = deviceView
        );
        insert longFormMenuForStep1;
    }


    /*******************************************************************************
    *  Name            : createMenuItemForStep2()
    *  Summary         : Create menu fot step 2
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createMenuItemForStep2(String deviceView) {
        longFormMenuForStep2 = new LongForm_Menu_Item__c(
                Name = '2. CARD CONFIGURATIONS',
                Long_Form_Menu__c = longFormMenu.Id,
                Step_Name__c = '2. Kartenkonfiguration',
                Order__c = 2,
                Device_View__c = deviceView
        );
        insert longFormMenuForStep2;
    }


    /*******************************************************************************
    *  Name            : createMenuItemForStep3()
    *  Summary         : Create menu fot step 3
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createMenuItemForStep3(String deviceView) {
        longFormMenuForStep3 = new LongForm_Menu_Item__c(
                Name = '3. ADDITIONAL',
                Long_Form_Menu__c = longFormMenu.Id,
                Step_Name__c = '3. Zusätzlicher Service',
                Order__c = 3,
                Device_View__c = deviceView
        );
        insert longFormMenuForStep3;
    }


    /*******************************************************************************
    *  Name            : createMenuItemForStep4()
    *  Summary         : Create menu fot step 4
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createMenuItemForStep4(String deviceView) {
        longFormMenuForStep4 = new LongForm_Menu_Item__c(
                Name = '4. PAYMENT OPTIONS',
                Long_Form_Menu__c = longFormMenu.Id,
                Step_Name__c = '4. Zahlungsdaten',
                Order__c = 4,
                Device_View__c = deviceView
        );
        insert longFormMenuForStep4;
    }


    /*******************************************************************************
    *  Name            : createHeader()
    *  Summary         : Creating header
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createHeader(String deviceView) {
        LongForm_Page__c contactDetails = new LongForm_Page__c(
                Name = 'HEADER',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_View__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert contactDetails;

        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = contactDetails.Id
        );
        insert topHeading;

        LongForm_Element_Item__c topHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Shell Tankkarten online bestellen',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        insert topHeadingValue;
    }


    /*******************************************************************************
    *  Name            : createAttachment(String oppId)
    *  Summary         : Create attachment file for test
    *  CreatedDate     : 02/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String id
    *  Returns         : Attachment
    ******************************************************************************/
    public static Attachment createAttachment(String fileName, String id) {
        Attachment attachment = new Attachment(
                Name = fileName,
                ParentId = id,
                Body = Blob.valueOf('test')
        );
        return attachment;
    }


    /*******************************************************************************
    *  Name            : createCFReport(String oppId)
    *  Summary         : Create CFReport
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String oppId
    *  Returns         : Credit_Factory_Report__c
    ******************************************************************************/
    public static Credit_Factory_Report__c createCFReport(String oppId) {
        Credit_Factory_Report__c cfReport = new Credit_Factory_Report__c(
                Name = 'Kundentestsystem Gesellschaft & Co. KG Negativmerkmale - BITTE NICHT ÄNDERN',
                Age_of_Company__c = '18',
                City__c = 'Weimar',
                Class_Rating__c = '6',
                Company_Status__c = 'aktiv',
                Country__c = 'DE',
                County_Court__c = 'AG Weimar 99423',
                Credit_Decision__c = 'Kredite werden abgelehnt. Von einer Geschäftsverbindung wird abgeraten.',
                Credit_System_Number__c = '3452013682',
                Date_Last_Register_Entry__c = '2005-01-01',
                Date_Legal_Form__c = '2005-01-01',
                Date_of_Foundation__c = '2000-01-01',
                Fax__c = '+4936461234566',
                First_Legal_Form__c = 'Gesellschaft & Co. KG',
                Housenumber__c = '7',
                Legal_Form__c = 'Sonstige Kapitalgesselschaften',
                Opportunity__c = oppId,
                Payment_Behaviour__c = 'PYMD-60',
                Phone__c = '+49364612343567',
                Postcode__c = '99423',
                Reference_Number__c = '40323633',
                Register_Number__c = '0120203404',
                Street__c = 'Am Frauenplan',
                Trade_Name__c = 'GmbH&CoKG Negativmerkmale',
                Credit_Limit_Weekly_7__c = 600,
                Credit_Limit_Bi_Weekly_7__c = 1000,
                Credit_Limit_Monthly_7__c = 1700,
                Max_Value_Weekly_7__c = 1300,
                Max_Value_Bi_Weekly_7__c = 2000,
                Max_Value_Monthly_7__c = 3300
        );
        return cfReport;
    }

    public static Credit_Factory_Report__c createCFNLReport(String oppId) {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '5',
                Opportunity__c = oppId,
                Legal_Form__c = 'BV',
                Name = 'Testgear B.V.',
                Name__c = 'Testgear B.V.',
                Street__c = 'Molensingel',
                City__c = 'DELFT',
                Housenumber__c = '10',
                Postcode__c = '2614LB',
                Email__c = 'test@test.te',
                Date_of_Foundation__c = '2010-10-10',
                Tax_Id__c = '50260340');
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : createFLTproducts(String fuelProductName, String evProductName)
    *  Summary         : create Fleetcor products
    *  CreatedDate     : 05/11/2019
    *  ModifiedDate    : -
    *  Parameters      : String fuelProductName, String evProductName
    *  Returns         : void
    ******************************************************************************/
    public static void createFLTproducts(String fuelProductName, String evProductName) {
        List<Product2> productsToInsertList = new List<Product2>();
        Product2 inboundTypeB = new Product2(
                Name = fuelProductName,
                Integration_Name__c = 'fuelIntegrationName',
                Family = 'SHELL',
                IsActive = true
        );
        productsToInsertList.add(inboundTypeB);

        Product2 ev_de = new Product2(
                Name = evProductName,
                Integration_Name__c = 'evIntegrationName',
                Family = 'EV',
                IsActive = true
        );
        productsToInsertList.add(ev_de);
        insert productsToInsertList;

        productsMap = new Map<String, Map<String, Product2>>();
        productsMap.put(inboundTypeB.Family, new Map<String, Product2>{
                inboundTypeB.Name => inboundTypeB
        });
        productsMap.put(ev_de.Family, new Map<String, Product2>{
                ev_de.Name => ev_de
        });
    }


    /*******************************************************************************
    *  Name            : createPriceBookItems()
    *  Summary         : create Opportunity Line Items
    *  CreatedDate     : 06/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createPriceBookItems() {
        pricebookEntriesMap = new Map<String, Map<String, PricebookEntry>>();
        List<PricebookEntry> pricebookEntriesToInsertList = new List<PricebookEntry>();
        Id pricebookId = Test.getStandardPricebookId();
        for (String productFamily : productsMap.keyset()) {
            for (String productName : productsMap.get(productFamily).keySet()) {
                if (!pricebookEntriesMap.containsKey(productFamily)) {
                    pricebookEntriesMap.put(productFamily, new Map<String, PricebookEntry>());
                }
                PricebookEntry price = new PricebookEntry(
                        Pricebook2Id = pricebookId,
                        Product2Id = productsMap.get(productFamily).get(productName).Id,
                        UnitPrice = 10000, IsActive = true
                );
                pricebookEntriesMap.get(productFamily).put(productName, price);
                pricebookEntriesToInsertList.add(price);
            }
        }
        insert pricebookEntriesToInsertList;
    }


    /******************************************************************************
    *  Name            : createOfferTypes(String fuelProductName, String evProductName)
    *  Summary         : create Fleetcor Offer Types
    *  CreatedDate     : 05/11/2019
    *  ModifiedDate    : -
    *  Parameters      : String fuelProductName, String evProductName
    *  Returns         : Map<String, Product2> eproductsMap
    ******************************************************************************/
    public static void createOfferTypes(String fuelProductName, String evProductName) {
        offerItemTypesMap = new Map<String, Map<String, Map<String, Offer_Item_Type__c>>>();
        List<Offer_Item_Type__c> offerItemTypesToInsertList = new List<Offer_Item_Type__c>();
        for (String productFamily : productsMap.keySet()) {
            if (!offerItemTypesMap.containsKey(productFamily)) {
                offerItemTypesMap.put(productFamily, new Map<String, Map<String, Offer_Item_Type__c>>());
            }
            for (String productName : productsMap.get(productFamily).keySet()) {
                if (!offerItemTypesMap.get(productFamily).containsKey(productName)) {
                    offerItemTypesMap.get(productFamily).put(productName, new Map<String, Offer_Item_Type__c>());
                }
                if (productName == fuelProductName) {
                    Offer_Item_Type__c shellFuelCard = new Offer_Item_Type__c(
                            Name = 'Shell Fuel Card'
                    );
                    offerItemTypesToInsertList.add(shellFuelCard);
                    offerItemTypesMap.get(productFamily).get(productName).put(shellFuelCard.Name, shellFuelCard);
                } else if (productName == evProductName) {
                    Offer_Item_Type__c evFob = new Offer_Item_Type__c(
                            Name = 'EV Fob'
                    );
                    offerItemTypesToInsertList.add(evFob);
                    offerItemTypesMap.get(productFamily).get(productName).put(evFob.Name, evFob);
                }
            }
        }
        insert offerItemTypesToInsertList;
    }


    /*******************************************************************************
    *  Name            : createOpportunityLineItem(String oppId, Map<String, List<String>> necessaryOpptyLineItemsSet)
    *  Summary         : create Opportunity Line Items
    *  CreatedDate     : 05/11/2019
    *  ModifiedDate    : -
    *  Parameters      : String oppId, Map<String, List<String>> necessaryOpptyLineItemsSet
    *  Returns         : Map<String, OpportunityLineItem>
    ******************************************************************************/
    public static Map<String, OpportunityLineItem> createOpportunityLineItem(String oppId, Map<String, List<String>> necessaryOpptyLineItemsSet) {
        Map<String, OpportunityLineItem> opptyLineItemsMap = new Map<String, OpportunityLineItem>();
        for (String productFamily : necessaryOpptyLineItemsSet.keySet()) {
            for (String productName : necessaryOpptyLineItemsSet.get(productFamily)) {
                opptyLineItemsMap.put(
                        productName,
                        new OpportunityLineItem(
                                OpportunityId = oppId,
                                PricebookEntryId = pricebookEntriesMap.get(productFamily).get(productName).Id,
                                Product2Id = productsMap.get(productFamily).get(productName).Id,
                                Quantity = 1,
                                TotalPrice = 0
                        )
                );
            }
        }
        return opptyLineItemsMap;
    }


    /*******************************************************************************
    *  Name            : createOfferItems(Map<String, Map<String, Map<String, String>>> offerItemParams, Map<String, OpportunityLineItem> opptyLineItemsMap)
    *  Summary         : create Offer Items
    *  CreatedDate     : 05/11/2019
    *  ModifiedDate    : -
    *  Parameters      : Map<String, Map<String, Map<String, String>>> offerItemParams, Map<String, OpportunityLineItem> opptyLineItemsMap
    *  Returns         : List<Offer_Item__c> offerItemsToInsertList
    ******************************************************************************/
    public static List<Offer_Item__c> createOfferItems(Map<String, Map<String, Map<Integer, Map<String, String>>>> offerItemParams, Map<String, OpportunityLineItem> opptyLineItemsMap) {
        List<Offer_Item__c> offerItemsToInsertList = new List<Offer_Item__c>();
        for (String productFamily : offerItemParams.keySet()) {
            for (String productName : offerItemParams.get(productFamily).keySet()) {
                for (Integer cardNumber : offerItemParams.get(productFamily).get(productName).keySet()) {
                    String offerItemTypeName = offerItemParams.get(productFamily).get(productName).get(cardNumber).get('offer type');
                    Offer_Item__c newOfferItem = new Offer_Item__c();

                    newOfferItem.Opportunity_Product_Id__c = opptyLineItemsMap.get(productName).Id;
                    newOfferItem.Offer_Item_Type__c = offerItemTypesMap.get(productFamily).get(productName).get(offerItemTypeName).Id;
                    newOfferItem.Driver_Name__c = offerItemParams.get(productFamily).get(productName).get(cardNumber).get('driver name');
                    newOfferItem.Category_of_products__c = offerItemParams.get(productFamily).get(productName).get(cardNumber).get('category');
                    newOfferItem.Company_Name__c = offerItemParams.get(productFamily).get(productName).get(cardNumber).get('company name');
                    newOfferItem.Mileage_data__c = Boolean.valueOf(offerItemParams.get(productFamily).get(productName).get(cardNumber).get('mileage data'));
                    newOfferItem.Type_of_Card__c = offerItemParams.get(productFamily).get(productName).get(cardNumber).get('type of card');
                    newOfferItem.Type_of_Vehicle__c = offerItemParams.get(productFamily).get(productName).get(cardNumber).get('type of vehicle');
                    newOfferItem.License_plate_number__c = offerItemParams.get(productFamily).get(productName).get(cardNumber).get('license plate number');
                    offerItemsToInsertList.add(newOfferItem);
                }
            }
        }
        return offerItemsToInsertList;
    }


    /*******************************************************************************
    *  Name            : createCard1(String oppId)
    *  Summary         : Create Multi Network Card -- International
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String oppId
    *  Returns         : Tankkarten__c
    ******************************************************************************/
    public static Tankkarten__c createMultiNetworkCardInternational(String oppId) {
        Tankkarten__c card = new Tankkarten__c(
                Opportunity__c = oppId,
                Gewuenschter_Kartentyp__c = 'Multi Network Card -- International',
                Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)',
                Firmenname_auf_der_Karte__c = 'cyberdyne systems',
                Kilometerstand_Abfrage__c = true,
                Fahrzeugtyp__c = 'PKW',
                Driver_Name__c = 'CONOR MCGREGOR'
        );
        return card;
    }


    /*******************************************************************************
    *  Name            : createCard2(String oppId)
    *  Summary         : Create Multi Network Card -- National
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String oppId
    *  Returns         : Tankkarten__c
    ******************************************************************************/
    public static Tankkarten__c createMultiNetworkCardNational(String oppId) {
        Tankkarten__c card = new Tankkarten__c(
                Opportunity__c = oppId,
                Gewuenschter_Kartentyp__c = 'Multi Network Card -- National',
                Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren',
                Firmenname_auf_der_Karte__c = 'cyberdyne systems',
                Kilometerstand_Abfrage__c = true,
                Fahrzeugtyp__c = 'LKW',
                Driver_Name__c = 'JOHN WICK'
        );
        return card;
    }


    /*******************************************************************************
    *  Name            : createCard2(String oppId)
    *  Summary         : Single Network Card -- International
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String oppId
    *  Returns         : Tankkarten__c
    ******************************************************************************/
    public static Tankkarten__c createSingleNetworkCardInternational(String oppId) {
        Tankkarten__c card = new Tankkarten__c(
                Opportunity__c = oppId,
                Gewuenschter_Kartentyp__c = 'Single Network Card -- International',
                Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren',
                Firmenname_auf_der_Karte__c = 'cyberdyne systems',
                Kilometerstand_Abfrage__c = true,
                Fahrzeugtyp__c = 'PKW',
                Driver_Name__c = 'KURT COBAIN'
        );
        return card;
    }


    /*******************************************************************************
    *  Name            : createCard2(String oppId)
    *  Summary         : Single Network Card -- International
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String oppId
    *  Returns         : Tankkarten__c
    ******************************************************************************/
    public static Tankkarten__c createSingleNetworkCardNational(String oppId) {
        Tankkarten__c card = new Tankkarten__c(
                Opportunity__c = oppId,
                Gewuenschter_Kartentyp__c = 'Single Network Card -- National',
                Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)',
                Firmenname_auf_der_Karte__c = 'cyberdyne systems',
                Kilometerstand_Abfrage__c = true,
                Fahrzeugtyp__c = 'LKW',
                Driver_Name__c = 'TEST TEST'
        );
        return card;
    }


    /*******************************************************************************
    *  Name            : createPaymentTransaction(String oppId)
    *  Summary         : Create payment transaction
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String oppId
    *  Returns         : Payment_Transaction__c
    ******************************************************************************/
    public static Payment_Transaction__c createPaymentTransaction(String oppId) {
        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c(
                Name = 'a4m0E0000000CQf',
                OpportunityId__c = oppId,
                Amount__c = 2100,
                Currency__c = 'EUR'
        );
        return paymentTransaction;
    }


    /*******************************************************************************
    *  Name            : createAccountForTestDuplactes()
    *  Summary         : Create account for testing duplicates
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createAccountForTestDuplactes() {
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1];
        Account account = new Account(
                Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN',
                BillingCountry = 'Germany',
                BillingCity = 'WEIMAR',
                BillingStreet = 'AM FRAUENPLAN 7',
                BillingPostalCode = '99423',
                ShippingCountry = 'Germany',
                ShippingCity = 'WEIMAR',
                ShippingStreet = 'AM FRAUENPLAN 7',
                ShippingPostalCode = '99423',
                RecordTypeId = accountRecordTypeList.get(0).Id,
                Type = 'Customer',
                E2E__c = true
        );
        return account;
    }


    /*******************************************************************************
    *  Name            : createOpportunityForTestDuplactes()
    *  Summary         : Create Opportunity for test diplcates
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String accId
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createOpportunityForTestDuplactes(String accId) {
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = 'KUNDENTESTSYSTEM GESELLSCHAFT & CO. KG NEGATIVMERKMALE - BITTE NICHT ÄNDERN',
                StageName = 'Prospecting',
                RecordTypeId = opptyRecordTypeList.get(0).Id,
                AccountId = accId,
                CloseDate = Date.today(),
                E2E__c = true,
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                Total_consumption_l_month__c = 1000,
                E2E_Active_Step__c = 1,
                E2E_Active_Substep__c = 'Calculating credit score'
        );
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createAccountDE()
    *  Summary         : Create account DE
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createAccountDE() {
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1];
        Account account = new Account(
                Name = 'TESTCOMPANY',
                BillingCountry = 'Germany',
                ShippingCountry = 'Germany',
                Type = 'Customer',
                E2E__c = true,
                Steuernummer__c = '12345678912',
                RecordTypeId = accountRecordTypeList.get(0).Id
        );
        return account;
    }


    /*******************************************************************************
    *  Name            : createOpportunityDE(String accId)
    *  Summary         : Create opportunity DE
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String accId
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createOpportunityDE(String accId) {
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = 'TEST',
                StageName = 'Credit approved',
                Product__c = 'Inbound Typ B',
                AccountId = accId,
                CloseDate = Date.today(),
                Language_preference__c = 'German',
                Primary_Contact_Phone__c = '+493811698111',
                Agree_to_Privacy_Policy__c = true,
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                Visitor_ID__c = '91.149.129.86',
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Active_Step__c = 4,
                E2E_Active_Substep__c = 'DirectDebitDeposit',
                Total_consumption_l_month__c = 1000,
                Zahlungsart__c = 'Lastschrift',
                Rechnungsperiode__c = '30',
                Zahlungsziel_Credit__c = '7',
                Eco_Fee__c = true,
                Name_of_the_payer_Account_holder__c = 'JOHN WICK',
                IBAN__c = 'DE89370400440532013000',
                SWIFT_BIC__c = 'AARBDE5W100',
                Security_Amount_To_Pay__c = 2100,
                RecordTypeId = opptyRecordTypeList.get(0).Id,
                E2E_Status__c = 'Abandoned (hard)',
                E2E_Sub_Status__c = 'Marketing automation'
        );
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createOpportunityContactRoleDE(String oppId, String conId)
    *  Summary         : Create opportunity contact role
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String oppId, String conId
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createOpportunityContactRoleDE(String oppId, String conId) {
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
                OpportunityId = oppId,
                ContactId = conId,
                IsPrimary = true
        );
        return oppContactRole;
    }


    /*******************************************************************************
    *  Name            : createContactForTestingDeduplication()
    *  Summary         : Create contact DE
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String accId
    *  Returns         : Contact8
    ******************************************************************************/
    public static Contact createContactForTestingDeduplication(String accId) {
        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Contact_layout' LIMIT 1];
        Contact contact = new Contact(
                Salutation = 'Mr',
                FirstName = 'JOHN',
                LastName = 'SMITH',
                AccountId = accId,
                Phone = '+491234567890',
                Email = 'test@fleetcor.com',
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = 'Germany',
                RecordTypeId = contactRecordTypeList.get(0).Id
        );
        return contact;
    }


    /*******************************************************************************
    *  Name            : createContactDE(String accId)
    *  Summary         : Create contact DE
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String accId
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createContactDE(String accId) {
        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Contact_layout' LIMIT 1];
        Contact contact = new Contact(
                Salutation = 'Mr',
                FirstName = 'Martina',
                LastName = 'Muck KTO',
                AccountId = accId,
                Phone = '+493811698111',
                Email = 'jrogers@burlington.com',
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = 'Germany',
                RecordTypeId = contactRecordTypeList.get(0).Id
        );
        return contact;
    }


    /*******************************************************************************
    *  Name            : createLeadDE()
    *  Summary         : Create Lead DE
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : lead
    ******************************************************************************/
    public static Lead createLeadDE() {
        List<RecordType> leadRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Endkunde' LIMIT 1];
        Lead lead = new Lead(
                RecordTypeId = leadRecordType.get(0).Id,
                Email = 'jrogers@burlington.com',
                Phone = '+493811698111',
                FirstName = 'Martina',
                LastName = 'Muck KTO',
                Country = 'Germany',
                Company = 'CYBERDYNE SYSTEMS'
        );
        return lead;
    }


    /*******************************************************************************
    *  Name            : createLeadForDuplicateDE()
    *  Summary         : Create Lead DE
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : lead
    ******************************************************************************/
    public static Lead createLeadForDuplicateDE() {
        List<RecordType> leadRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Endkunde' LIMIT 1];
        Lead lead = new Lead(
                RecordTypeId = leadRecordType.get(0).Id,
                Email = 'test@fleetcor.com',
                Phone = '+491234567890',
                FirstName = 'John',
                LastName = 'Smith',
                Country = 'Germany',
                Company = 'CYBERDYNE SYSTEMS'
        );
        return lead;
    }


    /*******************************************************************************
    *  Name            : createDocusignStatus(String opportunityId)
    *  Summary         : Create docusign status
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId
    *  Returns         : dsfs__DocuSign_Status__c
    ******************************************************************************/
    public static dsfs__DocuSign_Status__c createDocusignStatus(String opportunityId) {
        dsfs__DocuSign_Status__c docusignStatus = new dsfs__DocuSign_Status__c(
                dsfs__Opportunity__c = opportunityId,
                dsfs__DocuSign_Envelope_ID__c = '8ED1C319-A49F-4C71-BB88-78A139EFEBBD',
                dsfs__Sender__c = 'Fleetcor',
                dsfs__Sender_Email__c = 'fleetcor@gmail.com',
                dsfs__Subject__c = 'Declined'
        );
        return docusignStatus;
    }


    /*******************************************************************************
    *  Name            : createRecipientStatus(String docusignStatusId)
    *  Summary         : Create docusign recipient status
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String docusignStatusId
    *  Returns         : dsfs__DocuSign_Recipient_Status__c
    ******************************************************************************/
    public static dsfs__DocuSign_Recipient_Status__c createRecipientStatus(String docusignStatusId) {
        dsfs__DocuSign_Recipient_Status__c docusignRecipientStatus = new dsfs__DocuSign_Recipient_Status__c(
                dsfs__Parent_Status_Record__c = docusignStatusId,
                Name = 'bruce buffer',
                dsfs__DocuSign_Recipient_Email__c = 'brucebuffer@gmail.com',
                dsfs__Recipient_Status__c = 'Declined',
                dsfs__DocuSign_Routing_Order__c = 1,
                dsfs__DocuSign_Recipient_Id__c = '1F364B40-48E4-4B67-A5BA-5D282F0F8458',
                dsfs__Envelope_Id__c = '8ED1C319-A49F-4C71-BB88-78A139EFEBBD'
        );
        return docusignRecipientStatus;
    }


    /*******************************************************************************
    *  Name            : createDataForZeroStep()
    *  Summary         : Create contact deatails data
    *  CreatedDate     : 09/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createContactDeatilsData(String deviceView) {
        LongForm_Page__c contactDetails = new LongForm_Page__c(
                Name = 'CONTACT DETAILS',
                Title__c = 'E2E Contact Information',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Basic',
                Device_View__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert contactDetails;

        List<LongForm_Element__c> contactDetailsElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(topHeading);

        LongForm_Element__c salutation = new LongForm_Element__c(
                Name = 'SALUTATION',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(salutation);

        LongForm_Element__c firstName = new LongForm_Element__c(
                Name = 'FIRST NAME',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(firstName);

        LongForm_Element__c lastName = new LongForm_Element__c(
                Name = 'LAST NAME',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(lastName);

        LongForm_Element__c mobileNumber = new LongForm_Element__c(
                Name = 'MOBILE NUMBER',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(mobileNumber);

        LongForm_Element__c emailAddress = new LongForm_Element__c(
                Name = 'EMAIL ADDRESS',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(emailAddress);

        LongForm_Element__c newsAgreement = new LongForm_Element__c(
                Name = 'NEWS AGREEMENT',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(newsAgreement);

        LongForm_Element__c phoneContactAgreement = new LongForm_Element__c(
                Name = 'PHONE CONTACT AGREEMENT',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(phoneContactAgreement);

        LongForm_Element__c infoByEmail = new LongForm_Element__c(
                Name = 'RECEIVE COMM INFO BY EMAIL AGREEMENT',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(infoByEmail);

        LongForm_Element__c otherAgreement = new LongForm_Element__c(
                Name = 'OTHER AGREEMENT',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(otherAgreement);

        LongForm_Element__c goToStep2Button = new LongForm_Element__c(
                Name = 'GO TO STEP 2 BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(goToStep2Button);

        LongForm_Element__c companyForm = new LongForm_Element__c(
                Name = 'COMPANY FORM',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(companyForm);

        // only for modbile
        LongForm_Element__c getStartedButton = new LongForm_Element__c(
                Name = 'GET STARTED BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(getStartedButton);

        // only for modbile
        LongForm_Element__c continueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(continueButton);

        LongForm_Element__c numberOfCards = new LongForm_Element__c(
                Name = 'NUMBER OF CARDS',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(numberOfCards);

        LongForm_Element__c numberOfEVCards = new LongForm_Element__c(
                Name = 'NUMBER OF EV CARDS',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(numberOfEVCards);

        insert contactDetailsElementsList;

        List<LongForm_Element_Item__c> contactDetailsElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c topHeadingValue = new LongForm_Element_Item__c(
                Name = 'TOP HEADING VALUE',
                Active__c = true,
                Value__c = 'To begin order enter your contact details',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        contactDetailsElementItemsList.add(topHeadingValue);

        LongForm_Element_Item__c topSubheadingValue = new LongForm_Element_Item__c(
                Name = 'TOP SUBHEADING VALUE',
                Active__c = true,
                Value__c = 'Contact person must be able to take decisions on behalf of the company',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        contactDetailsElementItemsList.add(topSubheadingValue);

        // SALUTATION
        LongForm_Element_Item__c mrButtonLabel = new LongForm_Element_Item__c(
                Name = 'MR BUTTON LABEL',
                Active__c = true,
                Value__c = 'Herr',
                Type__c = 'Label',
                Long_Form_Element__c = salutation.Id
        );
        contactDetailsElementItemsList.add(mrButtonLabel);

        LongForm_Element_Item__c mrsButtonLabel = new LongForm_Element_Item__c(
                Name = 'MRS BUTTON LABEL',
                Active__c = true,
                Value__c = 'Frau',
                Type__c = 'Label',
                Long_Form_Element__c = salutation.Id
        );
        contactDetailsElementItemsList.add(mrsButtonLabel);

        LongForm_Element_Item__c salutationDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'Mr',
                Type__c = 'Default Value',
                Long_Form_Element__c = salutation.Id
        );
        contactDetailsElementItemsList.add(salutationDefaultValue);

        LongForm_Element_Item__c mrButtonApi = new LongForm_Element_Item__c(
                Name = 'MR BUTTON API',
                Active__c = true,
                Value__c = 'Mr',
                Type__c = 'Free Text',
                Long_Form_Element__c = salutation.Id
        );
        contactDetailsElementItemsList.add(mrButtonApi);

        LongForm_Element_Item__c mrsButtonApi = new LongForm_Element_Item__c(
                Name = 'MRS BUTTON API',
                Active__c = true,
                Value__c = 'Mrs',
                Type__c = 'Free Text',
                Long_Form_Element__c = salutation.Id
        );
        contactDetailsElementItemsList.add(mrsButtonApi);

        //
        LongForm_Element_Item__c firstNamelabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'First Name',
                Type__c = 'Label',
                Long_Form_Element__c = firstName.Id
        );
        contactDetailsElementItemsList.add(firstNamelabel);

        LongForm_Element_Item__c firstNameAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = firstName.Id
        );
        contactDetailsElementItemsList.add(firstNameAsterisk);

        LongForm_Element_Item__c firstNameDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = firstName.Id
        );
        contactDetailsElementItemsList.add(firstNameDefaultValue);

        LongForm_Element_Item__c firstNamePlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'Enter first name',
                Type__c = 'Placeholder',
                Long_Form_Element__c = firstName.Id
        );
        contactDetailsElementItemsList.add(firstNamePlaceholder);

        LongForm_Element_Item__c firstNameWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'First name should not be empty and contains only letters',
                Type__c = 'Validation Text',
                Long_Form_Element__c = firstName.Id
        );
        contactDetailsElementItemsList.add(firstNameWarnMessage);

        LongForm_Element_Item__c lastNamelabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Last Name',
                Type__c = 'Label',
                Long_Form_Element__c = lastName.Id
        );
        contactDetailsElementItemsList.add(lastNamelabel);

        LongForm_Element_Item__c lastNameAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = lastName.Id
        );
        contactDetailsElementItemsList.add(lastNameAsterisk);

        LongForm_Element_Item__c lastNameDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = lastName.Id
        );
        contactDetailsElementItemsList.add(lastNameDefaultValue);

        LongForm_Element_Item__c lastNamePlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'Enter first name',
                Type__c = 'Placeholder',
                Long_Form_Element__c = lastName.Id
        );
        contactDetailsElementItemsList.add(lastNamePlaceholder);

        LongForm_Element_Item__c lastNameWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'First name should not be empty and contains only letters',
                Type__c = 'Validation Text',
                Long_Form_Element__c = lastName.Id
        );
        contactDetailsElementItemsList.add(lastNameWarnMessage);

        LongForm_Element_Item__c mobileNumberLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Mobile Number',
                Type__c = 'Label',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberLabel);

        LongForm_Element_Item__c mobileNumberAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberAsterisk);

        LongForm_Element_Item__c mobileNumberDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberDefaultValue);

        LongForm_Element_Item__c mobileNumberPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = '+49XXXXXXXXXXXX',
                Type__c = 'Placeholder',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberPlaceholder);

        LongForm_Element_Item__c mobileNumberWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Mobile number should not be empty and looks like +49XXXXXXXXXXXX',
                Type__c = 'Validation Text',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberWarnMessage);

        LongForm_Element_Item__c emailAddressLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Email Address',
                Type__c = 'Label',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressLabel);

        LongForm_Element_Item__c emailAddressAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressAsterisk);

        LongForm_Element_Item__c emailAddressDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressDefaultValue);

        LongForm_Element_Item__c emailAddressPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'Enter email address',
                Type__c = 'Placeholder',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressPlaceholder);

        LongForm_Element_Item__c emailAddressWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Email should not be empty and looks like example-123@example-123.com',
                Type__c = 'Validation Text',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressWarnMessage);

        LongForm_Element_Item__c newsAgreementLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Yes, I want to receive news and updates about my euroshell card',
                Type__c = 'Label',
                Long_Form_Element__c = newsAgreement.Id
        );
        contactDetailsElementItemsList.add(newsAgreementLabel);

        LongForm_Element_Item__c newsAgreementDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = newsAgreement.Id
        );
        contactDetailsElementItemsList.add(newsAgreementDefaultValue);

        LongForm_Element_Item__c newsAgreementDU = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = newsAgreement.Id
        );
        contactDetailsElementItemsList.add(newsAgreementDU);

        LongForm_Element_Item__c newsAgreementIU = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = newsAgreement.Id
        );
        contactDetailsElementItemsList.add(newsAgreementIU);

        // phone contact agreement
        LongForm_Element_Item__c phoneContactAgreementLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zgadzam się na',
                Type__c = 'Label',
                Long_Form_Element__c = phoneContactAgreement.Id
        );
        contactDetailsElementItemsList.add(phoneContactAgreementLabel);

        LongForm_Element_Item__c phoneContactAgreementLabelUrl = new LongForm_Element_Item__c(
                Name = 'LABEL URL',
                Active__c = true,
                Value__c = 'kontakt telefoniczny.',
                Type__c = 'Label',
                Long_Form_Element__c = phoneContactAgreement.Id
        );
        contactDetailsElementItemsList.add(phoneContactAgreementLabelUrl);

        LongForm_Element_Item__c phoneContactAgreementDV = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = phoneContactAgreement.Id
        );
        contactDetailsElementItemsList.add(phoneContactAgreementDV);

        LongForm_Element_Item__c phoneContactAgreementDU = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = phoneContactAgreement.Id
        );
        contactDetailsElementItemsList.add(phoneContactAgreementDU);

        LongForm_Element_Item__c phoneContactAgreementIU = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = phoneContactAgreement.Id
        );
        contactDetailsElementItemsList.add(phoneContactAgreementIU);

        LongForm_Element_Item__c phoneContactAgreementBB = new LongForm_Element_Item__c(
                Name = 'BACK BUTTON',
                Active__c = true,
                Value__c = 'OK',
                Type__c = 'Label',
                Long_Form_Element__c = phoneContactAgreement.Id
        );
        contactDetailsElementItemsList.add(phoneContactAgreementBB);

        LongForm_Element_Item__c phoneContactAgreementIH = new LongForm_Element_Item__c(
                Name = 'IFRAME HEADING',
                Active__c = true,
                Value__c = 'Zgoda na kontakt',
                Type__c = 'Free Text',
                Long_Form_Element__c = phoneContactAgreement.Id
        );
        contactDetailsElementItemsList.add(phoneContactAgreementIH);

        //RECEIVE COMM INFO BY EMAIL AGREEMENT
        LongForm_Element_Item__c pinfoByEmailLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zgadzam się na',
                Type__c = 'Label',
                Long_Form_Element__c = infoByEmail.Id
        );
        contactDetailsElementItemsList.add(pinfoByEmailLabel);

        LongForm_Element_Item__c infoByEmailLabelUrl = new LongForm_Element_Item__c(
                Name = 'LABEL URL',
                Active__c = true,
                Value__c = 'kontakt telefoniczny.',
                Type__c = 'Label',
                Long_Form_Element__c = infoByEmail.Id
        );
        contactDetailsElementItemsList.add(infoByEmailLabelUrl);

        LongForm_Element_Item__c infoByEmailDV = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = infoByEmail.Id
        );
        contactDetailsElementItemsList.add(infoByEmailDV);

        LongForm_Element_Item__c infoByEmailDU = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = infoByEmail.Id
        );
        contactDetailsElementItemsList.add(infoByEmailDU);

        LongForm_Element_Item__c infoByEmailIU = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = infoByEmail.Id
        );
        contactDetailsElementItemsList.add(infoByEmailIU);

        LongForm_Element_Item__c infoByEmailBB = new LongForm_Element_Item__c(
                Name = 'BACK BUTTON',
                Active__c = true,
                Value__c = 'OK',
                Type__c = 'Label',
                Long_Form_Element__c = infoByEmail.Id
        );
        contactDetailsElementItemsList.add(infoByEmailBB);

        LongForm_Element_Item__c infoByEmailIH = new LongForm_Element_Item__c(
                Name = 'IFRAME HEADING',
                Active__c = true,
                Value__c = 'Zgoda na kontakt',
                Type__c = 'Free Text',
                Long_Form_Element__c = infoByEmail.Id
        );
        contactDetailsElementItemsList.add(infoByEmailIH);

        //
        LongForm_Element_Item__c otherAgreementLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo.',
                Type__c = 'Label',
                Long_Form_Element__c = otherAgreement.Id
        );
        contactDetailsElementItemsList.add(otherAgreementLabel);

        LongForm_Element_Item__c otherAgreementDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = otherAgreement.Id
        );
        contactDetailsElementItemsList.add(otherAgreementDefaultValue);

        LongForm_Element_Item__c buttonElementItem = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'GET STARTED',
                Type__c = 'Free Text',
                Long_Form_Element__c = goToStep2Button.Id
        );
        contactDetailsElementItemsList.add(buttonElementItem);

        // COMPANY FORM
        LongForm_Element_Item__c companyButtonLabel = new LongForm_Element_Item__c(
                Name = 'COMPANY BUTTON LABEL',
                Active__c = true,
                Value__c = 'Firma',
                Type__c = 'Label',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(companyButtonLabel);

        LongForm_Element_Item__c solotraderButtonLabel = new LongForm_Element_Item__c(
                Name = 'SOLO-TRADER BUTTON LABEL',
                Active__c = true,
                Value__c = 'Einzelfirma',
                Type__c = 'Label',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(solotraderButtonLabel);

        LongForm_Element_Item__c privateEntityButtonLabel = new LongForm_Element_Item__c(
                Name = 'PRIVATE ENTITY BUTTON LABEL',
                Active__c = true,
                Value__c = 'Privatperson',
                Type__c = 'Label',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(privateEntityButtonLabel);

        LongForm_Element_Item__c businessDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'Company',
                Type__c = 'Default Value',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(businessDefaultValue);

        LongForm_Element_Item__c businessLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Geschäftsform',
                Type__c = 'Label',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(businessLabel);

        LongForm_Element_Item__c businessAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(businessAsterisk);

        LongForm_Element_Item__c companyButtonApi = new LongForm_Element_Item__c(
                Name = 'COMPANY BUTTON API',
                Active__c = true,
                Value__c = 'Company',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(companyButtonApi);

        LongForm_Element_Item__c solotraderButtonApi = new LongForm_Element_Item__c(
                Name = 'SOLO-TRADER BUTTON API',
                Active__c = true,
                Value__c = 'Solo-trader',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(solotraderButtonApi);

        LongForm_Element_Item__c privateEntityButtonApi = new LongForm_Element_Item__c(
                Name = 'PRIVATE ENTITY BUTTON API',
                Active__c = true,
                Value__c = 'Private',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyForm.Id
        );
        contactDetailsElementItemsList.add(privateEntityButtonApi);

        // GET STARTED BUTTON
        LongForm_Element_Item__c getStartedValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Starten',
                Type__c = 'Label',
                Long_Form_Element__c = getStartedButton.Id
        );
        contactDetailsElementItemsList.add(getStartedValue);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Weiter',
                Type__c = 'Label',
                Long_Form_Element__c = continueButton.Id
        );
        contactDetailsElementItemsList.add(continueValue);

        // NUMBER OF CARDS
        LongForm_Element_Item__c numberOfCardsAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = numberOfCards.Id
        );
        contactDetailsElementItemsList.add(numberOfCardsAsterisk);

        LongForm_Element_Item__c numberOfCardsDefValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '1',
                Type__c = 'Free Text',
                Long_Form_Element__c = numberOfCards.Id
        );
        contactDetailsElementItemsList.add(numberOfCardsDefValue);

        LongForm_Element_Item__c numberOfCardsLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Anzahl der Karten',
                Type__c = 'Label',
                Long_Form_Element__c = numberOfCards.Id
        );
        contactDetailsElementItemsList.add(numberOfCardsLabel);

        // number of ev cards
        LongForm_Element_Item__c numberOfEVCardsAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = numberOfEvCards.Id
        );
        contactDetailsElementItemsList.add(numberOfEVCardsAsterisk);

        LongForm_Element_Item__c numberOfEVCardsDefValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '1',
                Type__c = 'Free Text',
                Long_Form_Element__c = numberOfEvCards.Id
        );
        contactDetailsElementItemsList.add(numberOfEVCardsDefValue);

        LongForm_Element_Item__c numberOfEVCardsLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Anzahl der ev Karten',
                Type__c = 'Label',
                Long_Form_Element__c = numberOfEvCards.Id
        );
        contactDetailsElementItemsList.add(numberOfEVCardsLabel);

        insert contactDetailsElementItemsList;
    }

    private static Map<String, String> countryToCountryCodeMap = new Map<String, String>{
            'Germany' => 'DE',
            'Netherlands' => 'NL',
            'Poland' => 'PL',
            'Hungary' => 'HU',
            'Belgium-FR' => 'BEFR',
            'Belgium-NL' => 'BENL',
            'France' => 'FR',
            'Switzerland-DE' => 'CHDE',
            'Switzerland-FR' => 'CHFR',
            'Switzerland-IT' => 'CHIT',
            'Austria' => 'AT'
    };


    /*******************************************************************************
    *  Name            : createReviewFuelConsumption(String deviceView)
    *  Summary         : Create review fuel consumption data
    *  CreatedDate     : 12/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createReviewFuelConsumption(String deviceView) {
        LongForm_Page__c reviewFuelConsumtion = new LongForm_Page__c(
                Name = 'REVIEW FUEL CONSUMPTION',
                Type__c = 'Lightbox',
                Device_View__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert reviewFuelConsumtion;

        List<LongForm_Element__c> reviewFuelConsumtionElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c heading = new LongForm_Element__c(
                Name = 'HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = reviewFuelConsumtion.Id
        );
        reviewFuelConsumtionElementsList.add(heading);

        LongForm_Element__c body = new LongForm_Element__c(
                Name = 'BODY',
                Type__c = 'Text Field',
                Long_Form_Page__c = reviewFuelConsumtion.Id
        );
        reviewFuelConsumtionElementsList.add(body);

        LongForm_Element__c button = new LongForm_Element__c(
                Name = 'BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = reviewFuelConsumtion.Id
        );
        reviewFuelConsumtionElementsList.add(button);

        insert reviewFuelConsumtionElementsList;

        List<LongForm_Element_Item__c> reviewFuelConsumtionElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c headingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Monthly fuel consumption updated',
                Type__c = 'Free Text',
                Long_Form_Element__c = heading.Id
        );
        reviewFuelConsumtionElementItemsList.add(headingValue);

        LongForm_Element_Item__c bodyValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Dear Customer, your monthly fuel consumption was updated. Please review the new value before proceeding with ordering your Shell Cards.',
                Type__c = 'Free Text',
                Long_Form_Element__c = body.Id
        );
        reviewFuelConsumtionElementItemsList.add(bodyValue);

        LongForm_Element_Item__c buttonValue = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Review fuel consumption',
                Type__c = 'Label',
                Long_Form_Element__c = button.Id
        );
        reviewFuelConsumtionElementItemsList.add(buttonValue);

        insert reviewFuelConsumtionElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createCustomSettings(String country, String e2eFormName, String creditSystemName, String userId)
    *  Summary         : Create custom settings
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : 12/11/2018
    *  Parameters      : String country, String e2eFormName, String creditSystemName, String userId
    *  Returns         : void
    ******************************************************************************/
    public static void createCustomSettings(String country, String e2eFormName, String creditSystemName, String userId) {
        List<SObject> e2eSettingsToInsertList = new List<SObject>();
        // create a second list cause we can't insert more than 10 different sObjects in one scope.
        List<SObject> generalSettingsToInsertList = new List<SObject>();

        GFNI_General_Settings__c customSetting = new GFNI_General_Settings__c();
        if (countryToCountryCodeMap.containsKey(country)) {
            customSetting.Name = countryToCountryCodeMap.get(country);
        } else {
            customSetting.Name = 'DE';
        }
        customSetting.Application_Status__c = '/applicationstatus';
        customSetting.Create_Customer_and_Cards__c = '/customer';
        customSetting.Get_Customer_Id__c = '/customerId';
        customSetting.IsForRobot__c = true;
        customSetting.Number_Of_Send_Tries__c = 3;
        customSetting.Prod_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        customSetting.Test_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        customSetting.x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        customSetting.x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        customSetting.Support_email__c = 'test@email.com';
        customSetting.Test_support_email__c = 'test@test.com';
        customSetting.test_x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        customSetting.test_x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        customSetting.Test_mode__c = true;
        e2eSettingsToInsertList.add(customSetting);

        LexisNexis_Settings__c lexisNexisSettings = new LexisNexis_Settings__c(
                Name = 'Production',
                Active__c = true,
                Endpoint__c = 'https://test.com',
                User_Name__c = 'test',
                Password__c = 'test');
        e2eSettingsToInsertList.add(lexisNexisSettings);

        Fleetcor_Profile_Info_Settings__c fltProfileSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'E2E Profile',
                ProfileId__c = '00e0O000001Z1VtQAK'
        );
        generalSettingsToInsertList.add(fltProfileSettings);

        List<Profile> adminsProfiles = [SELECT Id, Name FROM Profile WHERE Name = 'API Only' OR Name = 'System Administrator'];

        for (Profile adminProfile : adminsProfiles) {
            generalSettingsToInsertList.add(new Fleetcor_Profile_Info_Settings__c(
                    Name = adminProfile.Name,
                    ProfileId__c = adminProfile.Id
            ));
        }

        IBAN_API_Settings__c ibanApiSettings = new IBAN_API_Settings__c(
                Name = country,
                Endpoint__c = 'https://rest.sepatools.eu/validate_iban/',
                Login__c = 'FleetcorDE',
                Password__c = 'Fleetcor2019'
        );
        generalSettingsToInsertList.add(ibanApiSettings);

        VAT_ID_Validator_Settings__c vatValidatorSettings = new VAT_ID_Validator_Settings__c(
                Name = country,
                End_Point__c = 'http://apilayer.net/api/validate',
                Access_Key__c = '938eaa137fd3c965cd2d5f0a0915bf5c',
                Country_Code__c = country.substring(0, 2)
        );
        generalSettingsToInsertList.add(vatValidatorSettings);

        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
                Name = country,
                Abandonment_User__c = userId,
                Test_mode__c = false,
                Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Enable_authorization_non_granted_check__c = true,
                Set_GFN_Status__c = true
        );
        e2eSettingsToInsertList.add(e2eFormGeneralSettings);

        if (country != 'Germany') {
            E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
                    Name = country,
                    E2E_Form_Url__c = 'https://e2e-e2efleetcor.cs108.force.com/e2eform?country=Germany',
                    E2E_JITB_Form_Url__c = 'https://e2e-e2efleetcor.cs108.force.com/e2ejitbde',
                    Private_Key__c = 'P83U8MmjgIBU0V4l',
                    Short_Url__c = 'https://e2e-e2efleetcor.cs108.force.com/i'
            );
            e2eSettingsToInsertList.add(shortUrlSettings);
        }

        // create Germany custom setting because we had a problem with shor URL from ShortURLHookService (hardcode Germany)
        E2E_Short_Url__c shortUrlSettingsDE = new E2E_Short_Url__c(
                Name = 'Germany',
                E2E_Form_Url__c = 'https://e2e-e2efleetcor.cs108.force.com/e2eform?country=Germany',
                E2E_JITB_Form_Url__c = 'https://e2e-e2efleetcor.cs108.force.com/e2ejitbde',
                Private_Key__c = 'P83U8MmjgIBU0V4l',
                Short_Url__c = 'https://e2e-e2efleetcor.cs108.force.com/i'
        );
        e2eSettingsToInsertList.add(shortUrlSettingsDE);

        E2E_Chat_Setup__c e2eChatSetup = new E2E_Chat_Setup__c(
                Name = 'Germany',
                chatButtonId__c = '5730O000000byby',
                chatURL__c = 'https://d.la1-c1cs-frf.salesforceliveagent.com/chat',
                DeploymentJS__c = '/resource/1525433079000/e2eLiveAgentDeployment',
                chatDeploymentId__c = '5720O000000byvg'
        );
        e2eSettingsToInsertList.add(e2eChatSetup);

        Starts_Settings__c startsSettings = new Starts_Settings__c(
                Notifications_Email__c = 'start@fleetcor.de',
                Name = country
        );
        generalSettingsToInsertList.add(startsSettings);

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = e2eFormName,
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        e2eSettingsToInsertList.add(e2eKeysApi);

        Customer_Feedback_Settings__c customerFeedbackSettings = new Customer_Feedback_Settings__c(
                Name = country,
                Active_Customer_Feedback__c = true,
                Active_Google_Translate__c = true,
                Translation_Endpoint__c = 'https://www.googleapis.com/language/translate/v2?key=AIzaSyDOn0FaRSBlp5ZCq9ZODmg2lg-H8KbFo1c&target=en&q='
        );
        generalSettingsToInsertList.add(customerFeedbackSettings);

        if (country == 'Poland') {
            CreditSystem__c creditSystemPL = new CreditSystem__c(
                    Name = 'Crif',
                    Endpoint__c = 'https://demo.deltavista.pl/Search_Soap_Service_PL/services/SearchService,' +
                            'https://demo.deltavista.pl/dvs-soap/services/OrderCheckService,https://demo.deltavista.pl/pdfservice/pdfservlet',
                    Username__c = 'demo_fleetcor_soap',
                    Password__c = 'cvujmHe4',
                    Supported_Countries__c = 'Poland'
            );
            generalSettingsToInsertList.add(creditSystemPL);
        } else if (country == 'Hungary') {
            CreditSystem__c creditSystemHU = new CreditSystem__c(
                    Name = 'Coface',
                    Endpoint__c = 'https://test.cofacecentraleurope.com/iconwebservices',
                    Username__c = 'Petr.Cermak@fleetcor.eu',
                    Password__c = 'Fleetcor2018',
                    Supported_Countries__c = 'Hungary'
            );
            generalSettingsToInsertList.add(creditSystemHU);
            Fuel_Price__c fuelPriceHungary = new Fuel_Price__c(Name = country, Index__c = 350);
            generalSettingsToInsertList.add(fuelPriceHungary);
        } else if (country == 'Switzerland-DE' || country == 'Switzerland-FR' || country == 'Switzerland-IT') {
            CreditSystem__c creditForm = new CreditSystem__c(
                    Name = creditSystemName,
                    API_Key__c = 'CFflt123',
                    Endpoint__c = 'https://webservice.crediconnect.ch/V2/03/CrediConnect.svc/basic',
                    Password__c = 'CON4CC20VENT99',
                    Supported_Countries__c = country,
                    UserName__c = 'VENT4CC20_CONNECT'
            );
            generalSettingsToInsertList.add(creditForm);
            Fuel_Price__c fuelPriceSwitzerland = new Fuel_Price__c(Name = country, Index__c = 1.6);
            generalSettingsToInsertList.add(fuelPriceSwitzerland);
        } else if (country == 'Belgium-NL' || country == 'Belgium-FR' || country == 'France' || country == 'Netherlands') {
            CreditSystem__c creditSystem = new CreditSystem__c(
                    Name = 'Creditsafe',
                    Endpoint__c = 'https://connect.creditsafe.com/v1',
                    Username__c = 'test@test.test',
                    Password__c = 'test',
                    Supported_Countries__c = country
            );
            generalSettingsToInsertList.add(creditSystem);
            Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = country, Index__c = 1.6);
            generalSettingsToInsertList.add(fuelPrice);
        } else if (country == 'Germany') {
            CreditSystem__c schufa = new CreditSystem__c(
                    Name = creditSystemName,
                    API_Key__c = 'CFflt123',
                    Endpoint__c = 'https://kycnow.test.fino.cloud/api/v1',
                    Password__c = 'f0503e6c-c180-49b2-9f8a-4d9fcdd1b262',
                    Supported_Countries__c = country,
                    UserName__c = 'fleetcor_eu'
            );
            generalSettingsToInsertList.add(schufa);
        } else {
            CreditSystem__c creditForm = new CreditSystem__c(
                    Name = creditSystemName,
                    API_Key__c = 'CFflt123',
                    Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl',
                    Password__c = '1ppf39vE',
                    Supported_Countries__c = country,
                    UserName__c = '345013323001'
            );
            generalSettingsToInsertList.add(creditForm);
        }

        Account_GFN_Report_Email_Params__c gfnReport = new Account_GFN_Report_Email_Params__c(
                Attach_format__c = '.xls',
                Email__c = 'fleetcor@enway.co',
                Email_body__c = 'Attached file is generated using Salesforce for a robot processing',
                Name = 'Excel'
        );
        generalSettingsToInsertList.add(gfnReport);

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        // Docusign settings for Poland and Hungary only
        if (country == 'Poland') {
            E2E_Docusign_Settings__c e2eDocusignSettings = new E2E_Docusign_Settings__c(
                    Name = country,
                    AccountId__c = '68300806-41ed-466c-a7f1-9c97ace583e0',
                    Body__c = 'test',
                    IntegratorsKeyDesktop__c = '57c6330f-6449-4c36-9336-482e9a2d6cdf',
                    IntegratorsKeyMob__c = 'a6d9ca37-8d88-4058-86cb-09d372a38fe6',
                    Password__c = 'Fleetcor2019!',
                    Subject__c = 'Karty paliwowe FLEETCOR-dokumenty do podpisu elektronicznego',
                    UserId__c = 'e425921f-bf72-4a5b-84af-2dbdc472a16e',
                    WebServiceUrl__c = 'https://demo.docusign.net/api/3.0/dsapi.asmx'
            );
            e2eSettingsToInsertList.add(e2eDocusignSettings);

            E2E_Docusign_Templates__c contractSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E PL Contract',
                    Attachment_Name__c = 'Umowa Karty euroShell (DocuSign).pdf',
                    Docusign_Template_Id__c = 'eeba098f-62fc-4cc5-8160-b1f7f6b8073c',
                    Docusign_Template_Name__c = 'E2E PL Umowa Karty euroShell'
            );
            e2eSettingsToInsertList.add(contractSettings);

            E2E_Docusign_Templates__c depositAgreementSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E PL Deposit Agreement',
                    Attachment_Name__c = 'Umowa_o_kaucji (DocuSign).pdf',
                    Docusign_Template_Id__c = '4ef2c17d-1f28-4fed-8aa0-2f0de38928da',
                    Docusign_Template_Name__c = 'E2E PL Umowa o kaucji'
            );
            e2eSettingsToInsertList.add(depositAgreementSettings);

            E2E_Docusign_Templates__c creditScoringAllowanceSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E PL Credit Scoring Allowance',
                    Attachment_Name__c = 'Zgoda na weryfikację (DocuSign).pdf',
                    Docusign_Template_Id__c = 'a7dba935-2db4-4e5a-94df-8b7114bebdee',
                    Docusign_Template_Name__c = 'E2E PL Zgoda'
            );
            e2eSettingsToInsertList.add(creditScoringAllowanceSettings);

            E2E_PayU_Settings__c payUSettings = new E2E_PayU_Settings__c(
                    Name = 'Poland',
                    API_Endpoint__c = 'https://secure.snd.payu.com',
                    Client_Id__c = '356975',
                    Client_Secret__c = '8d2da48cbb22b1a0b9dac3dc62262987',
                    Company_Id__c = 236039,
                    IsActive__c = true,
                    notifyUrl__c = 'https://e2e-e2efleetcor.cs101.force.com',
                    Pos_Id__c = '356975',
                    Second_key_MD5__c = 'a85b502dfbc3c010b1746ed8cb2a2b6f',
                    Shop_Id__c = 'Fa1uzXfU');
            e2eSettingsToInsertList.add(payUSettings);
        } else if (country == 'Hungary') {
            E2E_Docusign_Settings__c e2eDocusignSettings = new E2E_Docusign_Settings__c(
                    Name = country,
                    AccountId__c = '68300806-41ed-466c-a7f1-9c97ace583e0',
                    Body__c = 'test',
                    IntegratorsKeyDesktop__c = '797dc5d9-6fb0-43af-9068-d725eebe6979',
                    IntegratorsKeyMob__c = '94f4f7a9-5413-4f3e-88b9-f2ae2d29ca38',
                    Password__c = 'Fleetcor2019!',
                    Subject__c = 'Karty paliwowe FLEETCOR-dokumenty do podpisu elektronicznego',
                    UserId__c = 'e425921f-bf72-4a5b-84af-2dbdc472a16e',
                    WebServiceUrl__c = 'https://demo.docusign.net/api/3.0/dsapi.asmx'
            );
            e2eSettingsToInsertList.add(e2eDocusignSettings);

            E2E_Docusign_Templates__c contractSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E HU Contract',
                    Attachment_Name__c = 'Kártyaszerződés.pdf',
                    Docusign_Template_Id__c = '278a3f4f-012c-434d-bdc8-cd79e0f964c0',
                    Docusign_Template_Name__c = 'E2E HU Contract'
            );
            e2eSettingsToInsertList.add(contractSettings);

            E2E_Docusign_Templates__c depositAgreementSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E HU Deposit Agreement',
                    Attachment_Name__c = 'Óvadéki szerződés (DocuSign).pdf',
                    Docusign_Template_Id__c = '3f85c150-add3-435a-a5ab-6bd2a93a32b5',
                    Docusign_Template_Name__c = 'E2E HU Deposit Agreement'
            );
            e2eSettingsToInsertList.add(depositAgreementSettings);

            E2E_PayU_Settings__c payUSettings = new E2E_PayU_Settings__c(
                    Name = 'Hungary',
                    API_Endpoint__c = 'https://secure.snd.payu.com',
                    Client_Id__c = '356975',
                    Client_Secret__c = '8d2da48cbb22b1a0b9dac3dc62262987',
                    Company_Id__c = 236039,
                    IsActive__c = true,
                    notifyUrl__c = 'https://e2e-e2efleetcor.cs101.force.com',
                    Pos_Id__c = '356975',
                    Second_key_MD5__c = 'a85b502dfbc3c010b1746ed8cb2a2b6f',
                    Shop_Id__c = 'Fa1uzXfU');
            e2eSettingsToInsertList.add(payUSettings);
        }

        // Solvency settings
        if (country == 'Switzerland-DE' || country == 'Switzerland-FR') {
            Solvency__c solvency = new Solvency__c(
                    Name = 'Switzerland',
                    Rating_1_Maximum__c = 91,
                    Rating_1_Minimum__c = 81,
                    Rating_2_Maximum__c = 71,
                    Rating_2_Minimum__c = 60,
                    Rating_3_Maximum__c = 39,
                    Rating_3_Minimum__c = 0,
                    Rating_4_Maximum__c = 100,
                    Rating_4_Minimum__c = 90,
                    Rating_5_Maximum__c = 80,
                    Rating_5_Minimum__c = 70,
                    Rating_6_Maximum__c = 59,
                    Rating_6_Minimum__c = 38
            );
            generalSettingsToInsertList.add(solvency);
        } else if (country == 'Germany') {
            Solvency__c solvency = new Solvency__c(
                    Name = 'Germany',
                    Rating_1_Minimum__c = 100,
                    Rating_2_Minimum__c = 217,
                    Rating_3_Minimum__c = 246,
                    Rating_4_Minimum__c = 284,
                    Rating_5_Minimum__c = 303,
                    Rating_6_Minimum__c = 359,
                    Rating_1_Maximum__c = 216,
                    Rating_2_Maximum__c = 246,
                    Rating_3_Maximum__c = 283,
                    Rating_4_Maximum__c = 302,
                    Rating_5_Maximum__c = 358,
                    Rating_6_Maximum__c = 600
            );
            generalSettingsToInsertList.add(solvency);

            Fuel_Price__c fuelPrice = new Fuel_Price__c();
            fuelPrice.Name = country;
            fuelPrice.Index__c = 1.4;
            generalSettingsToInsertList.add(fuelPrice);
        } else if (country == 'Austria') {
            Solvency__c solvency = new Solvency__c(
                    Name = 'Austria',
                    Rating_1_Minimum__c = 100,
                    Rating_2_Minimum__c = 217,
                    Rating_3_Minimum__c = 246,
                    Rating_4_Minimum__c = 284,
                    Rating_5_Minimum__c = 303,
                    Rating_6_Minimum__c = 359,
                    Rating_1_Maximum__c = 216,
                    Rating_2_Maximum__c = 246,
                    Rating_3_Maximum__c = 283,
                    Rating_4_Maximum__c = 302,
                    Rating_5_Maximum__c = 358,
                    Rating_6_Maximum__c = 600
            );
            generalSettingsToInsertList.add(solvency);
            Fuel_Price__c fuelPrice = new Fuel_Price__c();
            fuelPrice.Name = country;
            fuelPrice.Index__c = 1.15;
            generalSettingsToInsertList.add(fuelPrice);
        } else if (country == 'Poland') {
            Fuel_Price__c fuelPrice = new Fuel_Price__c();
            fuelPrice.Name = country;
            fuelPrice.Index__c = 5.25;
            generalSettingsToInsertList.add(fuelPrice);
        }
        if (country == 'Hungary') {
            CF_Order_Notifications__c notification = new CF_Order_Notifications__c();
            notification.Name = 'Hungary';
            notification.Active__c = true;
            notification.Email__c = 'test@test.com';
            generalSettingsToInsertList.add(notification);
        }

        insert e2eSettingsToInsertList;
        insert generalSettingsToInsertList;
    }


    /*******************************************************************************
    *  Name            : createCreditScoreInputVatId(String deviceView)
    *  Summary         : Create credit score input vat id
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCreditScoreInputVatId(String deviceView) {
        LongForm_Page__c creditScoreInputVatId = new LongForm_Page__c(
                Name = 'CREDIT SCORE. INPUT VAT ID',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert creditScoreInputVatId;

        List<LongForm_Element__c> creditScoreInputVatIdElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = creditScoreInputVatId.Id
        );
        creditScoreInputVatIdElementsList.add(topHeading);

        LongForm_Element__c vatNumber = new LongForm_Element__c(
                Name = 'VAT NUMBER',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreInputVatId.Id
        );
        creditScoreInputVatIdElementsList.add(vatNumber);

        LongForm_Element__c backButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreInputVatId.Id
        );
        creditScoreInputVatIdElementsList.add(backButton);

        LongForm_Element__c continueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreInputVatId.Id
        );
        creditScoreInputVatIdElementsList.add(continueButton);

        LongForm_Element__c noVat = new LongForm_Element__c(
                Name = 'NO VAT',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = creditScoreInputVatId.Id
        );
        creditScoreInputVatIdElementsList.add(noVat);
        insert creditScoreInputVatIdElementsList;

        List<LongForm_Element_Item__c> elementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c headingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Voer a.u.b. uw btw-nummer in',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        elementItemsList.add(headingItem);

        LongForm_Element_Item__c subHeadingItem = new LongForm_Element_Item__c(
                Name = 'SUBHEADING',
                Active__c = true,
                Value__c = 'Om de internationale passen te kunnen gebruiken, dient u uw btw-nummer in te voeren',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        elementItemsList.add(subHeadingItem);
        // VAT NUMBER
        LongForm_Element_Item__c labelVatNumber = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Btw-nummer',
                Type__c = 'Label',
                Long_Form_Element__c = vatNumber.Id
        );
        elementItemsList.add(labelVatNumber);

        LongForm_Element_Item__c asteriskVatNumber = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Free Text',
                Long_Form_Element__c = vatNumber.Id
        );
        elementItemsList.add(asteriskVatNumber);

        LongForm_Element_Item__c helpVatNumber = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Het btw-nummer is een eenduidig nummer dat wordt gebruikt voor de btw. Voorbeeld: NL001435784B01.',
                Type__c = 'Free Text',
                Long_Form_Element__c = vatNumber.Id
        );
        elementItemsList.add(helpVatNumber);

        LongForm_Element_Item__c defaultValueVatNumber = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = vatNumber.Id
        );
        elementItemsList.add(defaultValueVatNumber);

        LongForm_Element_Item__c warnMessageVatNumber = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Voer a.u.b. uw btw-nummer in het juiste formaat in. Voorbeeld: NL001435784B01.',
                Type__c = 'Validation Text',
                Long_Form_Element__c = vatNumber.Id
        );
        elementItemsList.add(warnMessageVatNumber);
        // BACK BUTTON
        LongForm_Element_Item__c labelBackButton = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'TERUG',
                Type__c = 'Label',
                Long_Form_Element__c = backButton.Id
        );
        elementItemsList.add(labelBackButton);
        // CONTINUE BUTTON
        LongForm_Element_Item__c labelContinueButton = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'TERUG',
                Type__c = 'Label',
                Long_Form_Element__c = continueButton.Id
        );
        elementItemsList.add(labelContinueButton);
        // NO VAT
        LongForm_Element_Item__c noVatLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'No Vat',
                Type__c = 'Label',
                Long_Form_Element__c = noVat.Id
        );
        elementItemsList.add(noVatLabel);

        LongForm_Element_Item__c noVatDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = noVat.Id
        );
        elementItemsList.add(noVatDefaultValue);
        insert elementItemsList;
    }


    /*******************************************************************************
    *  Name            : createCreditScoreSearchCompany()
    *  Summary         : Create credit score search company
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCreditScoreSearchCompany(String deviceView) {
        LongForm_Page__c creditScoreSearchCompany = new LongForm_Page__c(
                Name = 'CREDIT SCORE. SEARCH COMPANY',
                Title__c = 'E2E Credit Score',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep1.Id
        );
        insert creditScoreSearchCompany;

        List<LongForm_Element__c> creditScoreSearchCompanyElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeadingSearchCompany = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(topHeadingSearchCompany);

        LongForm_Element__c companyNameSearchCompany = new LongForm_Element__c(
                Name = 'COMPANY NAME',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(companyNameSearchCompany);

        LongForm_Element__c taxIdSearchCompany = new LongForm_Element__c(
                Name = 'TAX ID',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(taxIdSearchCompany);

        LongForm_Element__c vatIdSearchCompany = new LongForm_Element__c(
                Name = 'VAT ID',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(vatIdSearchCompany);

        LongForm_Element__c countrySearchCompany = new LongForm_Element__c(
                Name = 'COUNTRY',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(countrySearchCompany);

        LongForm_Element__c backButtonSearchCompany = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(backButtonSearchCompany);

        LongForm_Element__c continueButtonSearchCompany = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(continueButtonSearchCompany);

        LongForm_Element__c infoBlockSearchCompany = new LongForm_Element__c(
                Name = 'INFO BLOCK 1',
                Type__c = 'Text Block',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(infoBlockSearchCompany);

        LongForm_Element__c searchButtonSearchCompany = new LongForm_Element__c(
                Name = 'SEARCH BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(searchButtonSearchCompany);

        LongForm_Element__c selectCompanyBlockSearchCompany = new LongForm_Element__c(
                Name = 'SELECT COMPANY BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(selectCompanyBlockSearchCompany);

        LongForm_Element__c citySearchCompany = new LongForm_Element__c(
                Name = 'CITY',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(citySearchCompany);

        LongForm_Element__c isSandbox = new LongForm_Element__c(
                Name = 'ISSANDBOX',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(isSandbox);

        LongForm_Element__c firmenWissenElem = new LongForm_Element__c(
                Name = 'FIRMENWISSEN NUMBER OF COMPANIES',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(firmenWissenElem);

        LongForm_Element__c creditsafeNumberOfCompanies = new LongForm_Element__c(
                Name = 'CREDITSAFE NUMBER OF COMPANIES',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreSearchCompany.Id
        );
        creditScoreSearchCompanyElementsList.add(creditsafeNumberOfCompanies);

        insert creditScoreSearchCompanyElementsList;

        List<LongForm_Element_Item__c> longFormElementItemsStep1List = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c topHeadingValueStep1 = new LongForm_Element_Item__c(
                Name = 'TOP HEADING VALUE',
                Active__c = true,
                Value__c = 'Our cards are credit. We need to identify your company to offer a credit line.',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeadingSearchCompany.Id
        );
        longFormElementItemsStep1List.add(topHeadingValueStep1);

        LongForm_Element_Item__c topSubHeadingValueStep1 = new LongForm_Element_Item__c(
                Name = 'TOP SUBHEADING VALUE',
                Active__c = true,
                Value__c = 'Contact person must be able to take decisions on behalf of the company',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeadingSearchCompany.Id
        );
        longFormElementItemsStep1List.add(topSubHeadingValueStep1);

        // COMPANY NAME
        LongForm_Element_Item__c companyNameLabelStep1 = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Company name',
                Type__c = 'Label',
                Long_Form_Element__c = companyNameSearchCompany.Id
        );
        longFormElementItemsStep1List.add(companyNameLabelStep1);

        LongForm_Element_Item__c companyNameDefaultValueStep1 = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = companyNameSearchCompany.Id
        );
        longFormElementItemsStep1List.add(companyNameDefaultValueStep1);

        LongForm_Element_Item__c companyNamePlaceholderStep1 = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'Enter company name',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyNameSearchCompany.Id
        );
        longFormElementItemsStep1List.add(companyNamePlaceholderStep1);

        LongForm_Element_Item__c companyNameAsteriskStep1 = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = companyNameSearchCompany.Id
        );
        longFormElementItemsStep1List.add(companyNameAsteriskStep1);

        LongForm_Element_Item__c companyNameWarnMessageStep1 = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Company name should not be empty',
                Type__c = 'Validation Text',
                Long_Form_Element__c = companyNameSearchCompany.Id
        );
        longFormElementItemsStep1List.add(companyNameWarnMessageStep1);

        // TAX ID
        LongForm_Element_Item__c taxIdLabelStep1 = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'TAX ID',
                Type__c = 'Label',
                Long_Form_Element__c = taxIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(taxIdLabelStep1);

        LongForm_Element_Item__c taxIdAsteriskStep1 = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = taxIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(taxIdAsteriskStep1);

        LongForm_Element_Item__c taxIdDefaultValueStep1 = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = taxIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(taxIdDefaultValueStep1);

        LongForm_Element_Item__c taxIdPlaceholderStep1 = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'Enter TAX ID',
                Type__c = 'Placeholder',
                Long_Form_Element__c = taxIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(taxIdPlaceholderStep1);

        LongForm_Element_Item__c taxIdWarnMessageStep1 = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'TAX ID should not be empty and and looks like XXXXXXXXXXXXXXX',
                Type__c = 'Validation Text',
                Long_Form_Element__c = taxIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(taxIdWarnMessageStep1);

        // VAT ID
        LongForm_Element_Item__c vatIdLabelStep1 = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'VAT ID',
                Type__c = 'Label',
                Long_Form_Element__c = vatIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(vatIdLabelStep1);

        LongForm_Element_Item__c vatIdAsteriskStep1 = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = vatIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(vatIdAsteriskStep1);

        LongForm_Element_Item__c vatIdDefaultValueStep1 = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = vatIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(vatIdDefaultValueStep1);

        LongForm_Element_Item__c vatIdPlaceholderStep1 = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'Enter TAX ID',
                Type__c = 'Placeholder',
                Long_Form_Element__c = vatIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(vatIdPlaceholderStep1);

        LongForm_Element_Item__c vatIdWarnMessageStep1 = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'TAX ID should not be empty and and looks like XXXXXXXXXXXXXXX',
                Type__c = 'Validation Text',
                Long_Form_Element__c = vatIdSearchCompany.Id
        );
        longFormElementItemsStep1List.add(vatIdWarnMessageStep1);

        // COUNTRY
        LongForm_Element_Item__c countryLabelStep1 = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Country of registration',
                Type__c = 'Label',
                Long_Form_Element__c = countrySearchCompany.Id
        );
        longFormElementItemsStep1List.add(countryLabelStep1);

        LongForm_Element_Item__c countryDefaultValueStep1 = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'Germany',
                Type__c = 'Default Value',
                Long_Form_Element__c = countrySearchCompany.Id
        );
        longFormElementItemsStep1List.add(countryDefaultValueStep1);

        LongForm_Element_Item__c countryRemarkStep1 = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Service unavailable for companies registered outside Germany',
                Type__c = 'Free Text',
                Long_Form_Element__c = countrySearchCompany.Id
        );
        longFormElementItemsStep1List.add(countryRemarkStep1);

        // BACK BUTTON
        LongForm_Element_Item__c backButtonNameStep1 = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'BACK',
                Type__c = 'Free Text',
                Long_Form_Element__c = backButtonSearchCompany.Id
        );
        longFormElementItemsStep1List.add(backButtonNameStep1);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonNameStep1 = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Free Text',
                Long_Form_Element__c = continueButtonSearchCompany.Id
        );
        longFormElementItemsStep1List.add(continueButtonNameStep1);

        // INFO BLOCK 1
        LongForm_Element_Item__c infoBlockHeadingStep1 = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'What is credit line?',
                Type__c = 'Free Text',
                Long_Form_Element__c = infoBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(infoBlockHeadingStep1);

        LongForm_Element_Item__c infoBlockBodyBlockStep1 = new LongForm_Element_Item__c(
                Name = 'BODY OF BLOCK',
                Active__c = true,
                Value__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna',
                Type__c = 'Free Text',
                Long_Form_Element__c = infoBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(infoBlockBodyBlockStep1);

        LongForm_Element_Item__c infoBlockSubheading1Step1 = new LongForm_Element_Item__c(
                Name = 'SUBHEADING 1',
                Active__c = true,
                Value__c = 'Always solvency',
                Type__c = 'Free Text',
                Long_Form_Element__c = infoBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(infoBlockSubheading1Step1);

        LongForm_Element_Item__c infoBlockSubheading2Step1 = new LongForm_Element_Item__c(
                Name = 'SUBHEADING 2',
                Active__c = true,
                Value__c = 'Don’t care about deposit',
                Type__c = 'Free Text',
                Long_Form_Element__c = infoBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(infoBlockSubheading2Step1);

        LongForm_Element_Item__c infoBlockBodySubblock1Step1 = new LongForm_Element_Item__c(
                Name = 'BODY OF SUBBLOCK 1',
                Active__c = true,
                Value__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
                Type__c = 'Free Text',
                Long_Form_Element__c = infoBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(infoBlockBodySubblock1Step1);

        LongForm_Element_Item__c infoBlockBodySubblock2Step1 = new LongForm_Element_Item__c(
                Name = 'BODY OF SUBBLOCK 2',
                Active__c = true,
                Value__c = 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo.',
                Type__c = 'Free Text',
                Long_Form_Element__c = infoBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(infoBlockBodySubblock2Step1);

        // SEARCH BUTTON
        LongForm_Element_Item__c searchButtonNameStep1 = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'SEARCH',
                Type__c = 'Free Text',
                Long_Form_Element__c = searchButtonSearchCompany.Id
        );
        longFormElementItemsStep1List.add(searchButtonNameStep1);

        // SELECT COMPANY BLOCK
        LongForm_Element_Item__c selectCompanyBlockHeadingStep1 = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Select your company',
                Type__c = 'Free Text',
                Long_Form_Element__c = selectCompanyBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(selectCompanyBlockHeadingStep1);

        LongForm_Element_Item__c selectCompanyBlockRemarkStep1 = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'The address shown here is mailing address',
                Type__c = 'Free Text',
                Long_Form_Element__c = selectCompanyBlockSearchCompany.Id
        );
        longFormElementItemsStep1List.add(selectCompanyBlockRemarkStep1);

        // CITY
        LongForm_Element_Item__c cityLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'City',
                Type__c = 'Label',
                Long_Form_Element__c = citySearchCompany.Id
        );
        longFormElementItemsStep1List.add(cityLabel);

        LongForm_Element_Item__c cityDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = citySearchCompany.Id
        );
        longFormElementItemsStep1List.add(cityDefaultValue);

        LongForm_Element_Item__c cityPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = '',
                Type__c = 'Placeholder',
                Long_Form_Element__c = citySearchCompany.Id
        );
        longFormElementItemsStep1List.add(cityPlaceholder);

        LongForm_Element_Item__c cityAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = citySearchCompany.Id
        );
        longFormElementItemsStep1List.add(cityAsterisk);

        LongForm_Element_Item__c cityWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Please enter the City in a valid format. Special characters are not allowed.',
                Type__c = 'Validation Text',
                Long_Form_Element__c = citySearchCompany.Id
        );
        longFormElementItemsStep1List.add(cityWarnMessage);

        LongForm_Element_Item__c isSandboxValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = ' Default Value',
                Long_Form_Element__c = isSandbox.Id
        );
        longFormElementItemsStep1List.add(isSandboxValue);

        // firmenWissen
        LongForm_Element_Item__c firmenWissenItem = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = firmenWissenElem.Id
        );
        longFormElementItemsStep1List.add(firmenWissenItem);

        LongForm_Element_Item__c creditsafeNumberOfCompaniesItem = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = creditsafeNumberOfCompanies.Id
        );
        longFormElementItemsStep1List.add(creditsafeNumberOfCompaniesItem);

        insert longFormElementItemsStep1List;
    }


    /*******************************************************************************
    *  Name            : createOrderDetailsBlock()
    *  Summary         : Create order details block
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createOrderDetailsBlock(String deviceView) {
        LongForm_Page__c orderDetailBlock = new LongForm_Page__c(
                Name = 'ORDER DETAIL BLOCK',
                Title__c = 'Order details',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert orderDetailBlock;

        List<LongForm_Element__c> orderDetailElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c orderDetailTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = orderDetailBlock.Id
        );
        orderDetailElementsList.add(orderDetailTopHeading);

        LongForm_Element__c orderDetailCreditLimit = new LongForm_Element__c(
                Name = 'CREDIT LIMIT',
                Type__c = 'Text Block',
                Long_Form_Page__c = orderDetailBlock.Id
        );
        orderDetailElementsList.add(orderDetailCreditLimit);

        LongForm_Element__c orderDetailPrognosedConsumption = new LongForm_Element__c(
                Name = 'PROGNOSED CONSUMPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = orderDetailBlock.Id
        );
        orderDetailElementsList.add(orderDetailPrognosedConsumption);

        LongForm_Element__c orderDetailCompanyInfo = new LongForm_Element__c(
                Name = 'COMPANY INFO',
                Type__c = 'Text Block',
                Long_Form_Page__c = orderDetailBlock.Id
        );
        orderDetailElementsList.add(orderDetailCompanyInfo);

        LongForm_Element__c orderDetailContactPerson = new LongForm_Element__c(
                Name = 'CONTACT PERSON',
                Type__c = 'Text Block',
                Long_Form_Page__c = orderDetailBlock.Id
        );
        orderDetailElementsList.add(orderDetailContactPerson);

        LongForm_Element__c orderDetailFeesCostInfo = new LongForm_Element__c(
                Name = 'FEES AND COSTS INFO',
                Type__c = 'Text Block',
                Long_Form_Page__c = orderDetailBlock.Id
        );
        orderDetailElementsList.add(orderDetailFeesCostInfo);

        insert orderDetailElementsList;

        List<LongForm_Element_Item__c> orderDetailElementItemsList = new List<LongForm_Element_Item__c>();

        // TOP HEADING
        LongForm_Element_Item__c topHeadingValueStep1 = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Order details',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailTopHeading.Id
        );
        orderDetailElementItemsList.add(topHeadingValueStep1);

        // CREDIT LIMIT
        LongForm_Element_Item__c creditLimitEditButton = new LongForm_Element_Item__c(
                Name = 'EDIT BUTTON',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitEditButton);

        LongForm_Element_Item__c creditLimitShowBlock = new LongForm_Element_Item__c(
                Name = 'SHOW BLOCK',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitShowBlock);

        LongForm_Element_Item__c creditLimitHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Credit limit',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitHeading);

        LongForm_Element_Item__c creditLimitUnit = new LongForm_Element_Item__c(
                Name = 'UNIT',
                Active__c = true,
                Value__c = '€',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitUnit);

        LongForm_Element_Item__c creditLimitDepositNotRequired = new LongForm_Element_Item__c(
                Name = 'DEPOSIT NOT REQUIRED',
                Active__c = true,
                Value__c = 'Deposit does not required',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitDepositNotRequired);

        LongForm_Element_Item__c creditLimitDepositRequired = new LongForm_Element_Item__c(
                Name = 'DEPOSIT REQUIRED',
                Active__c = true,
                Value__c = 'Deposit:',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitDepositRequired);

        LongForm_Element_Item__c creditLimitWeeklyInvoices = new LongForm_Element_Item__c(
                Name = 'WEEKLY INVOICES',
                Active__c = true,
                Value__c = 'Weekly invoices',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitWeeklyInvoices);

        LongForm_Element_Item__c creditLimitBIWeeklyInvoices = new LongForm_Element_Item__c(
                Name = 'BI-WEEKLY INVOICES',
                Active__c = true,
                Value__c = 'Bi-weekly invoices',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitBIWeeklyInvoices);

        LongForm_Element_Item__c creditLimitMonthlyInvoices = new LongForm_Element_Item__c(
                Name = 'MONTHLY INVOICES',
                Active__c = true,
                Value__c = 'Monthly invoices',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitMonthlyInvoices);

        LongForm_Element_Item__c creditLimitDirectDebit = new LongForm_Element_Item__c(
                Name = 'DIRECT DEBIT',
                Active__c = true,
                Value__c = 'Direct Debit',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitDirectDebit);

        LongForm_Element_Item__c creditLimitBankTransfer = new LongForm_Element_Item__c(
                Name = 'BANK TRANSFER',
                Active__c = true,
                Value__c = 'Bank Transfer',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCreditLimit.Id
        );
        orderDetailElementItemsList.add(creditLimitBankTransfer);

        // PROGNOSED CONSUMPTION
        LongForm_Element_Item__c prognosedConsumprionEditButton = new LongForm_Element_Item__c(
                Name = 'EDIT BUTTON',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailPrognosedConsumption.Id
        );
        orderDetailElementItemsList.add(prognosedConsumprionEditButton);

        LongForm_Element_Item__c prognosedConsumprionHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Prognosed consumption',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailPrognosedConsumption.Id
        );
        orderDetailElementItemsList.add(prognosedConsumprionHeading);

        LongForm_Element_Item__c prognosedConsumprionUnit = new LongForm_Element_Item__c(
                Name = 'UNIT',
                Active__c = true,
                Value__c = 'litres / month',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailPrognosedConsumption.Id
        );
        orderDetailElementItemsList.add(prognosedConsumprionUnit);

        LongForm_Element_Item__c prognosedConsumprionShowBlock = new LongForm_Element_Item__c(
                Name = 'SHOW BLOCK',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = orderDetailPrognosedConsumption.Id
        );
        orderDetailElementItemsList.add(prognosedConsumprionShowBlock);

        // COMPANY INFO
        LongForm_Element_Item__c companyInfoEditButton = new LongForm_Element_Item__c(
                Name = 'EDIT BUTTON',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCompanyInfo.Id
        );
        orderDetailElementItemsList.add(companyInfoEditButton);

        LongForm_Element_Item__c companyInfoVatLabel = new LongForm_Element_Item__c(
                Name = 'VAT LABEL',
                Active__c = true,
                Value__c = 'VAT',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCompanyInfo.Id
        );
        orderDetailElementItemsList.add(companyInfoVatLabel);

        LongForm_Element_Item__c companyInfoRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Card will be delivered to this address',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailCompanyInfo.Id
        );
        orderDetailElementItemsList.add(companyInfoRemark);

        LongForm_Element_Item__c companyInfoShowBlock = new LongForm_Element_Item__c(
                Name = 'SHOW BLOCK',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = orderDetailCompanyInfo.Id
        );
        orderDetailElementItemsList.add(companyInfoShowBlock);

        // CONTACT PERSON
        LongForm_Element_Item__c contactPersonEditButton = new LongForm_Element_Item__c(
                Name = 'EDIT BUTTON',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailContactPerson.Id
        );
        orderDetailElementItemsList.add(contactPersonEditButton);

        LongForm_Element_Item__c contactPersonHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Contact person',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailContactPerson.Id
        );
        orderDetailElementItemsList.add(contactPersonHeading);

        LongForm_Element_Item__c contactPersonShowBlock = new LongForm_Element_Item__c(
                Name = 'SHOW BLOCK',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailContactPerson.Id
        );
        orderDetailElementItemsList.add(contactPersonShowBlock);

        // FEES AND COSTS INFO
        LongForm_Element_Item__c feesCostInfoShowBlock = new LongForm_Element_Item__c(
                Name = 'SHOW BLOCK',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoShowBlock);

        LongForm_Element_Item__c feesCostInfoCard = new LongForm_Element_Item__c(
                Name = '-CARD-',
                Active__c = true,
                Value__c = 'card',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoCard);

        LongForm_Element_Item__c feesCostInfoCards = new LongForm_Element_Item__c(
                Name = '-CARDS-',
                Active__c = true,
                Value__c = 'cards',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoCards);

        LongForm_Element_Item__c feesCostInfoCardsDescription = new LongForm_Element_Item__c(
                Name = 'CARDS DESCRIPTION',
                Active__c = true,
                Value__c = 'Some description text about all cards here',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoCardsDescription);

        LongForm_Element_Item__c feesCostInfoPer = new LongForm_Element_Item__c(
                Name = '-PER-',
                Active__c = true,
                Value__c = 'per',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoPer);

        LongForm_Element_Item__c feesCostInfoMoreDetails = new LongForm_Element_Item__c(
                Name = 'MORE DETAILS',
                Active__c = true,
                Value__c = 'more details',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoMoreDetails);

        LongForm_Element_Item__c feesCostInfoMonthlyFeeHeading = new LongForm_Element_Item__c(
                Name = 'MONTHLY FEE HEADING',
                Active__c = true,
                Value__c = 'Monthly fee',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoMonthlyFeeHeading);

        LongForm_Element_Item__c feesCostInfoOneTimeFeeHeading = new LongForm_Element_Item__c(
                Name = 'ONE TIME FEE HEADING',
                Active__c = true,
                Value__c = 'One time setup fee',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoOneTimeFeeHeading);

        LongForm_Element_Item__c feesCostInfoCardGrillIcon = new LongForm_Element_Item__c(
                Name = 'CARD #',
                Active__c = true,
                Value__c = 'Card #',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoCardGrillIcon);

        LongForm_Element_Item__c feesCostInfoEditButton = new LongForm_Element_Item__c(
                Name = 'EDIT BUTTON',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoEditButton);

        LongForm_Element_Item__c feesCostInfoEmbossingHeading = new LongForm_Element_Item__c(
                Name = 'EMBOSSING HEADING',
                Active__c = true,
                Value__c = 'Embossing',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderDetailFeesCostInfo.Id
        );
        orderDetailElementItemsList.add(feesCostInfoEmbossingHeading);

        insert orderDetailElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createFooter()
    *  Summary         : Creating footer
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createFooter(String deviceView) {
        LongForm_Page__c footer = new LongForm_Page__c(
                Name = 'FOOTER',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert footer;

        List<LongForm_Element__c> footerElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c footerDescription = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = footer.Id
        );
        footerElementsList.add(footerDescription);

        LongForm_Element__c footerOurCompany = new LongForm_Element__c(
                Name = 'OUR COMPANY',
                Type__c = 'Text Block',
                Long_Form_Page__c = footer.Id
        );
        footerElementsList.add(footerOurCompany);

        LongForm_Element__c footerLegalInformation = new LongForm_Element__c(
                Name = 'LEGAL INFORMATION',
                Type__c = 'Text Block',
                Long_Form_Page__c = footer.Id
        );
        footerElementsList.add(footerLegalInformation);

        LongForm_Element__c footerCopyright = new LongForm_Element__c(
                Name = 'COPYRIGHT',
                Type__c = 'Text Block',
                Long_Form_Page__c = footer.Id
        );
        footerElementsList.add(footerCopyright);

        insert footerElementsList;

        List<LongForm_Element_Item__c> footerElementItemsList = new List<LongForm_Element_Item__c>();

        // DESCRIPTION
        LongForm_Element_Item__c footerDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'FLEETCOR is a leading independent global provider of specialized payment products and services including fleet cards, food cards, corporate lodging discount cards and other specialized payment services for businesses throughout the world.',
                Type__c = 'Free Text',
                Long_Form_Element__c = footerDescription.Id
        );
        footerElementItemsList.add(footerDescriptionValue);

        // OUR COMPANY
        LongForm_Element_Item__c ourCompanyURL1 = new LongForm_Element_Item__c(
                Name = 'URL 1',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = footerOurCompany.Id
        );
        footerElementItemsList.add(ourCompanyURL1);

        LongForm_Element_Item__c ourCompanyURL2 = new LongForm_Element_Item__c(
                Name = 'URL 2',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = footerOurCompany.Id
        );
        footerElementItemsList.add(ourCompanyURL2);

        LongForm_Element_Item__c ourCompanyURL3 = new LongForm_Element_Item__c(
                Name = 'URL 3',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = footerOurCompany.Id
        );
        footerElementItemsList.add(ourCompanyURL3);

        LongForm_Element_Item__c ourCompanyURL1Label = new LongForm_Element_Item__c(
                Name = 'URL 1 LABEL',
                Active__c = true,
                Value__c = 'About Fleetcor',
                Type__c = 'Label',
                Long_Form_Element__c = footerOurCompany.Id
        );
        footerElementItemsList.add(ourCompanyURL1Label);

        LongForm_Element_Item__c ourCompanyURL2Label = new LongForm_Element_Item__c(
                Name = 'URL 2 LABEL',
                Active__c = true,
                Value__c = 'Contacts',
                Type__c = 'Label',
                Long_Form_Element__c = footerOurCompany.Id
        );
        footerElementItemsList.add(ourCompanyURL2Label);

        LongForm_Element_Item__c ourCompanyURL3Label = new LongForm_Element_Item__c(
                Name = 'URL 3 LABEL',
                Active__c = true,
                Value__c = 'Partner Login',
                Type__c = 'Label',
                Long_Form_Element__c = footerOurCompany.Id
        );
        footerElementItemsList.add(ourCompanyURL3Label);

        LongForm_Element_Item__c ourCompanyHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Our Company',
                Type__c = 'Label',
                Long_Form_Element__c = footerOurCompany.Id
        );
        footerElementItemsList.add(ourCompanyHeading);

        // LEGAL INFORMATION
        LongForm_Element_Item__c legalInformationURL1Label = new LongForm_Element_Item__c(
                Name = 'URL 1 LABEL',
                Active__c = true,
                Value__c = 'Use Policy',
                Type__c = 'Label',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL1Label);

        LongForm_Element_Item__c legalInformationURL1 = new LongForm_Element_Item__c(
                Name = 'URL 1',
                Active__c = true,
                Value__c = 'https://fleetcor.de',
                Type__c = 'URL',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL1);

        LongForm_Element_Item__c legalInformationURL2 = new LongForm_Element_Item__c(
                Name = 'URL 2',
                Active__c = true,
                Value__c = 'https://fleetcor.de',
                Type__c = 'URL',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL2);

        LongForm_Element_Item__c legalInformationURL3 = new LongForm_Element_Item__c(
                Name = 'URL 3',
                Active__c = true,
                Value__c = 'https://fleetcor.de',
                Type__c = 'URL',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL3);

        LongForm_Element_Item__c legalInformationURL4 = new LongForm_Element_Item__c(
                Name = 'URL 4',
                Active__c = true,
                Value__c = 'https://fleetcor.de',
                Type__c = 'URL',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL4);

        LongForm_Element_Item__c legalInformationURL5 = new LongForm_Element_Item__c(
                Name = 'URL 5',
                Active__c = true,
                Value__c = 'https://fleetcor.de',
                Type__c = 'URL',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL5);

        LongForm_Element_Item__c legalInformationURL2Label = new LongForm_Element_Item__c(
                Name = 'URL 2 LABEL',
                Active__c = true,
                Value__c = 'Privacy policy',
                Type__c = 'Label',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL2Label);

        LongForm_Element_Item__c legalInformationURL3Label = new LongForm_Element_Item__c(
                Name = 'URL 3 LABEL',
                Active__c = true,
                Value__c = 'Copyright and limitation of liability',
                Type__c = 'Label',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL3Label);

        LongForm_Element_Item__c legalInformationURL4Label = new LongForm_Element_Item__c(
                Name = 'URL 4 LABEL',
                Active__c = true,
                Value__c = 'Cookie policy',
                Type__c = 'Label',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL4Label);

        LongForm_Element_Item__c legalInformationURL5Label = new LongForm_Element_Item__c(
                Name = 'URL 5 LABEL',
                Active__c = true,
                Value__c = 'Website use policy',
                Type__c = 'Label',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationURL5Label);

        LongForm_Element_Item__c legalInformationHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Legal information',
                Type__c = 'Free Text',
                Long_Form_Element__c = footerLegalInformation.Id
        );
        footerElementItemsList.add(legalInformationHeading);

        // COPYRIGHT
        LongForm_Element_Item__c copyrightValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Copyright © 2018 FLEETCOR LLC. All rights reserved.',
                Type__c = 'Free Text',
                Long_Form_Element__c = footerCopyright.Id
        );
        footerElementItemsList.add(copyrightValue);

        insert footerElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createCreditScoreAnotherTaxID()
    *  Summary         : Creating credit score tax id
    *  CreatedDate     : 11/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCreditScoreAnotherTaxID(String deviceView) {
        LongForm_Page__c creditScoreAnotherTaxId = new LongForm_Page__c(
                Name = 'CREDIT SCORE. ANOTHER TAX ID',
                Title__c = 'E2E Another Tax ID',
                System_Error__c = 'Some error',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep1.Id
        );
        insert creditScoreAnotherTaxId;

        List<LongForm_Element__c> anotherTaxIdElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c anotherTaxIdTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = creditScoreAnotherTaxId.Id
        );
        anotherTaxIdElementsList.add(anotherTaxIdTopHeading);

        LongForm_Element__c anotherTaxIdProvideTaxId = new LongForm_Element__c(
                Name = 'PROVIDED TAX ID',
                Type__c = 'Heading',
                Long_Form_Page__c = creditScoreAnotherTaxId.Id
        );
        anotherTaxIdElementsList.add(anotherTaxIdProvideTaxId);

        LongForm_Element__c anotherTaxIdFoundTaxId = new LongForm_Element__c(
                Name = 'FOUND TAX ID',
                Type__c = 'Heading',
                Long_Form_Page__c = creditScoreAnotherTaxId.Id
        );
        anotherTaxIdElementsList.add(anotherTaxIdFoundTaxId);

        LongForm_Element__c anotherTaxIdContinueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreAnotherTaxId.Id
        );
        anotherTaxIdElementsList.add(anotherTaxIdContinueButton);

        insert anotherTaxIdElementsList;

        List<LongForm_Element_Item__c> anotherTaxIdElementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c topHeadingHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'What Tax ID shall we use?',
                Type__c = 'Free Text',
                Long_Form_Element__c = anotherTaxIdTopHeading.Id
        );
        anotherTaxIdElementItemsList.add(topHeadingHeading);

        LongForm_Element_Item__c topHeadingSubheadingPart1 = new LongForm_Element_Item__c(
                Name = 'SUBHEADING PART 1',
                Active__c = true,
                Value__c = 'We have found another Tax ID for',
                Type__c = 'Free Text',
                Long_Form_Element__c = anotherTaxIdTopHeading.Id
        );
        anotherTaxIdElementItemsList.add(topHeadingSubheadingPart1);

        LongForm_Element_Item__c topHeadingSubheadingPart2 = new LongForm_Element_Item__c(
                Name = 'SUBHEADING PART 2',
                Active__c = true,
                Value__c = 'than you provide',
                Type__c = 'Free Text',
                Long_Form_Element__c = anotherTaxIdTopHeading.Id
        );
        anotherTaxIdElementItemsList.add(topHeadingSubheadingPart2);

        // PROVIDED TAX ID
        LongForm_Element_Item__c provideTaxIdHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'You have provided:',
                Type__c = 'Free Text',
                Long_Form_Element__c = anotherTaxIdProvideTaxId.Id
        );
        anotherTaxIdElementItemsList.add(provideTaxIdHeading);

        // FOUND TAX ID
        LongForm_Element_Item__c foundTaxIdHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'We have found:',
                Type__c = 'Free Text',
                Long_Form_Element__c = anotherTaxIdFoundTaxId.Id
        );
        anotherTaxIdElementItemsList.add(foundTaxIdHeading);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Free Text',
                Long_Form_Element__c = anotherTaxIdContinueButton.Id
        );
        anotherTaxIdElementItemsList.add(continueButtonName);

        insert anotherTaxIdElementItemsList;
    }

    /*******************************************************************************
    *  Name            : createCreditScoreTotalConsumption()
    *  Summary         : Creating credit score total consumption
    *  CreatedDate     : 11/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCreditScoreTotalConsumption(String deviceView) {
        LongForm_Page__c creditScoreTotalConsumption = new LongForm_Page__c(
                Name = 'CREDIT SCORE. TOTAL CONSUMPTION',
                Title__c = 'E2E Planned total consumption',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep1.Id
        );
        insert creditScoreTotalConsumption;

        List<LongForm_Element__c> totalConsumptionElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c totalConsumptionTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = creditScoreTotalConsumption.Id
        );
        totalConsumptionElementsList.add(totalConsumptionTopHeading);

        LongForm_Element__c totalConsumptionTextField = new LongForm_Element__c(
                Name = 'TOTAL CONSUMPTION',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoreTotalConsumption.Id
        );
        totalConsumptionElementsList.add(totalConsumptionTextField);

        LongForm_Element__c totalConsumptionBackButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreTotalConsumption.Id
        );
        totalConsumptionElementsList.add(totalConsumptionBackButton);

        LongForm_Element__c totalConsumptionContinueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoreTotalConsumption.Id
        );
        totalConsumptionElementsList.add(totalConsumptionContinueButton);

        insert totalConsumptionElementsList;

        List<LongForm_Element_Item__c> totalConsumptionElementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c topHeadingValue = new LongForm_Element_Item__c(
                Name = 'TOP HEADING VALUE',
                Active__c = true,
                Value__c = 'How much fuel do all your vehicles consume per month?',
                Type__c = 'Free Text',
                Long_Form_Element__c = totalConsumptionTopHeading.Id
        );
        totalConsumptionElementItemsList.add(topHeadingValue);

        // TOTAL CONSUMPTION
        LongForm_Element_Item__c textFieldLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Fuel consumption for all my vehicles',
                Type__c = 'Label',
                Long_Form_Element__c = totalConsumptionTextField.Id
        );
        totalConsumptionElementItemsList.add(textFieldLabel);

        LongForm_Element_Item__c totalConsumptionAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = totalConsumptionTextField.Id
        );
        totalConsumptionElementItemsList.add(totalConsumptionAsterisk);

        LongForm_Element_Item__c totalConsumptionDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '75',
                Type__c = 'Default Value',
                Long_Form_Element__c = totalConsumptionTextField.Id
        );
        totalConsumptionElementItemsList.add(totalConsumptionDefaultValue);

        LongForm_Element_Item__c totalConsumptionPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'xxxxx',
                Type__c = 'Placeholder',
                Long_Form_Element__c = totalConsumptionTextField.Id
        );
        totalConsumptionElementItemsList.add(totalConsumptionPlaceholder);

        LongForm_Element_Item__c totalConsumptionWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Planed fuel pump should not be empty and contains only numbers',
                Type__c = 'Validation Text',
                Long_Form_Element__c = totalConsumptionTextField.Id
        );
        totalConsumptionElementItemsList.add(totalConsumptionWarnMessage);

        LongForm_Element_Item__c totalConsumptionUnit = new LongForm_Element_Item__c(
                Name = 'UNIT',
                Active__c = true,
                Value__c = 'liters / month',
                Type__c = 'Free Text',
                Long_Form_Element__c = totalConsumptionTextField.Id
        );
        totalConsumptionElementItemsList.add(totalConsumptionUnit);

        LongForm_Element_Item__c totalConsumptionRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Sufficient volume is between 75 and 50K Liters',
                Type__c = 'Free Text',
                Long_Form_Element__c = totalConsumptionTextField.Id
        );
        totalConsumptionElementItemsList.add(totalConsumptionRemark);

        // BACK BUTTON
        LongForm_Element_Item__c backButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'BACK',
                Type__c = 'Free Text',
                Long_Form_Element__c = totalConsumptionBackButton.Id
        );
        totalConsumptionElementItemsList.add(backButtonName);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Free Text',
                Long_Form_Element__c = totalConsumptionContinueButton.Id
        );
        totalConsumptionElementItemsList.add(continueButtonName);

        insert totalConsumptionElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createAdditionalCreditScoring(String deviceView)
    *  Summary         : Create additional credit scoring
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createAdditionalCreditScoring(String deviceView) {
        LongForm_Page__c additionalCreditScoringResult = new LongForm_Page__c(
                Name = 'CREDIT SCORE. ADDITIONAL CREDIT SCORING',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Lightbox',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert additionalCreditScoringResult;

        List<LongForm_Element__c> additionalElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c documentsBlock = new LongForm_Element__c(
                Name = 'DOCUMENT',
                Type__c = 'Text Block',
                Long_Form_Page__c = additionalCreditScoringResult.Id
        );
        additionalElementsList.add(documentsBlock);
        insert additionalElementsList;

        List<LongForm_Element_Item__c> additionalElementItemList = new List<LongForm_Element_Item__c>();
        // DOCUMENT
        LongForm_Element_Item__c documentDownloadUrl = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = documentsBlock.Id
        );
        additionalElementItemList.add(documentDownloadUrl);

        LongForm_Element_Item__c documentIframeUrl = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = documentsBlock.Id
        );
        additionalElementItemList.add(documentIframeUrl);
        insert additionalElementItemList;
    }


    /*******************************************************************************
    *  Name            : createCreditScoringResult()
    *  Summary         : Create credit scoring result
    *  CreatedDate     : 11/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCreditScoringResult(String deviceView) {
        LongForm_Page__c creditScoringResult = new LongForm_Page__c(
                Name = 'CREDIT SCORE. SCORING RESULT',
                Title__c = 'E2E Scoring result',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep1.Id
        );
        insert creditScoringResult;

        List<LongForm_Element__c> scoringResultElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c resultPaymentMethod = new LongForm_Element__c(
                Name = 'PAYMENT METHOD',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultPaymentMethod);

        LongForm_Element__c resultTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultTopHeading);

        LongForm_Element__c resultBillingPeriod = new LongForm_Element__c(
                Name = 'BILLING PERIOD',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultBillingPeriod);

        LongForm_Element__c resultCreditLimitSelectionBlock = new LongForm_Element__c(
                Name = 'CREDIT LIMIT SELECTION BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultCreditLimitSelectionBlock);

        LongForm_Element__c resultCreditLimit = new LongForm_Element__c(
                Name = 'CREDIT LIMIT',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultCreditLimit);

        LongForm_Element__c resultDeposit = new LongForm_Element__c(
                Name = 'DEPOSIT',
                Type__c = 'Text Field',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultDeposit);

        LongForm_Element__c resultInfoBlock1 = new LongForm_Element__c(
                Name = 'INFO BLOCK 1',
                Type__c = 'Text Block',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultInfoBlock1);

        LongForm_Element__c resultBackButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultBackButton);

        LongForm_Element__c resultContinueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = creditScoringResult.Id
        );
        scoringResultElementsList.add(resultContinueButton);

        insert scoringResultElementsList;

        List<LongForm_Element_Item__c> scoringResultElementItemsList = new List<LongForm_Element_Item__c>();
        // PAYMENT METHOD
        LongForm_Element_Item__c paymentMethodLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'What payment method do you prefer?',
                Type__c = 'Label',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodLabel);

        LongForm_Element_Item__c paymentMethodButtonName1 = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME 1',
                Active__c = true,
                Value__c = 'Direct debit',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodButtonName1);

        LongForm_Element_Item__c paymentMethodButtonName2 = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME 2',
                Active__c = true,
                Value__c = 'Bank transfer',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodButtonName2);

        LongForm_Element_Item__c paymentMethodDDlabel = new LongForm_Element_Item__c(
                Name = 'DD LABEL',
                Active__c = true,
                Value__c = 'label1',
                Type__c = 'Label',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodDDlabel);

        LongForm_Element_Item__c paymentMethodBTlabel = new LongForm_Element_Item__c(
                Name = 'BT LABEL',
                Active__c = true,
                Value__c = 'label2',
                Type__c = 'Label',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodBTlabel);

        LongForm_Element_Item__c paymentMethodDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'Lastschrift',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodDefaultValue);

        LongForm_Element_Item__c paymentMethodDirectDebitDescription = new LongForm_Element_Item__c(
                Name = 'DIRECT DEBIT DESCRIPTION',
                Active__c = true,
                Value__c = 'Direct debit description here',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodDirectDebitDescription);

        LongForm_Element_Item__c paymentMethodBankTransferDescription = new LongForm_Element_Item__c(
                Name = 'BANK TRANSFER DESCRIPTION',
                Active__c = true,
                Value__c = 'Bank transfer description here',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(paymentMethodBankTransferDescription);

        LongForm_Element_Item__c ddButtonLabel = new LongForm_Element_Item__c(
                Name = 'DD BUTTON LABEL',
                Active__c = true,
                Value__c = 'DD BUTTON LABEL',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(ddButtonLabel);

        LongForm_Element_Item__c ddLabel = new LongForm_Element_Item__c(
                Name = 'DD LABEL',
                Active__c = true,
                Value__c = 'DD LABEL',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(ddLabel);

        LongForm_Element_Item__c btButtonLabel = new LongForm_Element_Item__c(
                Name = 'BT BUTTON LABEL',
                Active__c = true,
                Value__c = 'BT BUTTON LABEL',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(btButtonLabel);

        LongForm_Element_Item__c btLabel = new LongForm_Element_Item__c(
                Name = 'BT LABEL',
                Active__c = true,
                Value__c = 'BT LABEL',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultPaymentMethod.Id
        );
        scoringResultElementItemsList.add(btLabel);

        // TOP HEADING
        LongForm_Element_Item__c topHeadingPart1 = new LongForm_Element_Item__c(
                Name = 'HEADING PART 1',
                Active__c = true,
                Value__c = 'We offer you from',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultTopHeading.Id
        );
        scoringResultElementItemsList.add(topHeadingPart1);

        LongForm_Element_Item__c topHeadingPart2 = new LongForm_Element_Item__c(
                Name = 'HEADING PART 2',
                Active__c = true,
                Value__c = '€ to',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultTopHeading.Id
        );
        scoringResultElementItemsList.add(topHeadingPart2);

        LongForm_Element_Item__c topHeadingPart3 = new LongForm_Element_Item__c(
                Name = 'HEADING PART 3',
                Active__c = true,
                Value__c = '€ credit line',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultTopHeading.Id
        );
        scoringResultElementItemsList.add(topHeadingPart3);

        LongForm_Element_Item__c subheading = new LongForm_Element_Item__c(
                Name = 'SUBHEADING',
                Active__c = true,
                Value__c = 'subheading',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultTopHeading.Id
        );
        scoringResultElementItemsList.add(subheading);

        LongForm_Element_Item__c scoringResultGeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'heading',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultTopHeading.Id
        );
        scoringResultElementItemsList.add(scoringResultGeading);

        // BILLING PERIOD
        LongForm_Element_Item__c billingPeriodWeekly = new LongForm_Element_Item__c(
                Name = 'WEEKLY BUTTON NAME',
                Active__c = true,
                Value__c = 'Weekly',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodWeekly);

        LongForm_Element_Item__c billingPeriodWeekly7 = new LongForm_Element_Item__c(
                Name = 'WEEKLY BUTTON NAME + 7',
                Active__c = true,
                Value__c = 'Weekly',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodWeekly7);

        LongForm_Element_Item__c billingPeriodBiWeekly = new LongForm_Element_Item__c(
                Name = 'BI-WEEKLY BUTTON NAME',
                Active__c = true,
                Value__c = 'Bi-Weekly',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodBiWeekly);

        LongForm_Element_Item__c billingPeriodBiWeekly14 = new LongForm_Element_Item__c(
                Name = 'BI-WEEKLY BUTTON NAME + 14',
                Active__c = true,
                Value__c = 'Bi-Weekly',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodBiWeekly14);

        LongForm_Element_Item__c billingPeriodMonthly = new LongForm_Element_Item__c(
                Name = 'MONTHLY BUTTON NAME',
                Active__c = true,
                Value__c = 'Monthly',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodMonthly);

        LongForm_Element_Item__c billingPeriodLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'How often would you like to pay invoices?',
                Type__c = 'Label',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodLabel);

        LongForm_Element_Item__c billingPeriodRemarkPart1 = new LongForm_Element_Item__c(
                Name = 'REMARK PART 1',
                Active__c = true,
                Value__c = 'You will have',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodRemarkPart1);

        LongForm_Element_Item__c billingPeriodRemarkPart2 = new LongForm_Element_Item__c(
                Name = 'REMARK PART 2',
                Active__c = true,
                Value__c = 'days to pay invoice',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(billingPeriodRemarkPart2);

        LongForm_Element_Item__c ddRemark = new LongForm_Element_Item__c(
                Name = 'DD REMARK',
                Active__c = true,
                Value__c = 'direct debit remark',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(ddRemark);

        LongForm_Element_Item__c remark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'remark',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBillingPeriod.Id
        );
        scoringResultElementItemsList.add(remark);

        LongForm_Element_Item__c ddDEItem = new LongForm_Element_Item__c(
                Name = 'DD 14 REMARK',
                Value__c = 'Die Kontobelastung findet am 14ten Tag nach Ablauf statt.',
                Active__c = true,
                Long_Form_Element__c = resultBillingPeriod.Id,
                Type__c = 'Free Text'
        );
        scoringResultElementItemsList.add(ddDEItem);

        LongForm_Element_Item__c btDEItem = new LongForm_Element_Item__c(
                Name = 'BT 14 REMARK',
                Value__c = 'Die Rechnung ist 14 Tage nach dem Ausstellungsdatum der Rechnung fällig.',
                Active__c = true,
                Long_Form_Element__c = resultBillingPeriod.Id,
                Type__c = 'Free Text'
        );
        scoringResultElementItemsList.add(btDEItem);

        // CREDIT LIMIT SELECTION BLOCK
        LongForm_Element_Item__c selectionBlockHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Choose your credit limit',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultCreditLimitSelectionBlock.Id
        );
        scoringResultElementItemsList.add(selectionBlockHeading);

        LongForm_Element_Item__c selectionBlockRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'This limit will be shared to all cards you order',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultCreditLimitSelectionBlock.Id
        );
        scoringResultElementItemsList.add(selectionBlockRemark);

        // CREDIT LIMIT
        LongForm_Element_Item__c creditLimitLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Credit limit',
                Type__c = 'Label',
                Long_Form_Element__c = resultCreditLimit.Id
        );
        scoringResultElementItemsList.add(creditLimitLabel);

        LongForm_Element_Item__c creditLimitAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = resultCreditLimit.Id
        );
        scoringResultElementItemsList.add(creditLimitAsterisk);

        LongForm_Element_Item__c creditLimitWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Credit limit should not be empty and contains only numbers',
                Type__c = 'Validation Text',
                Long_Form_Element__c = resultCreditLimit.Id
        );
        scoringResultElementItemsList.add(creditLimitWarnMessage);

        LongForm_Element_Item__c creditLimitUnit = new LongForm_Element_Item__c(
                Name = 'UNIT',
                Active__c = true,
                Value__c = '€',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultCreditLimit.Id
        );
        scoringResultElementItemsList.add(creditLimitUnit);

        // DEPOSIT
        LongForm_Element_Item__c depositLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Deposit',
                Type__c = 'Label',
                Long_Form_Element__c = resultDeposit.Id
        );
        scoringResultElementItemsList.add(depositLabel);

        LongForm_Element_Item__c depositUnit = new LongForm_Element_Item__c(
                Name = 'UNIT',
                Active__c = true,
                Value__c = '€',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultDeposit.Id
        );
        scoringResultElementItemsList.add(depositUnit);

        LongForm_Element_Item__c depositRemarkRequired = new LongForm_Element_Item__c(
                Name = 'REMARK REQUIRED DEPOSIT',
                Active__c = true,
                Value__c = 'Required to be paid at once',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultDeposit.Id
        );
        scoringResultElementItemsList.add(depositRemarkRequired);

        LongForm_Element_Item__c depositHelpRequired = new LongForm_Element_Item__c(
                Name = 'HELP REQUIRED DEPOSIT',
                Active__c = true,
                Value__c = 'Some content',
                Type__c = 'Help Text',
                Long_Form_Element__c = resultDeposit.Id
        );
        scoringResultElementItemsList.add(depositHelpRequired);

        LongForm_Element_Item__c depositHelpNotRequired = new LongForm_Element_Item__c(
                Name = 'HELP NOT REQUIRED DEPOSIT',
                Active__c = true,
                Value__c = 'Some content',
                Type__c = 'Help Text',
                Long_Form_Element__c = resultDeposit.Id
        );
        scoringResultElementItemsList.add(depositHelpNotRequired);

        LongForm_Element_Item__c depositRemarkNotRequired = new LongForm_Element_Item__c(
                Name = 'REMARK NOT REQUIRED DEPOSIT',
                Active__c = true,
                Value__c = 'Not required',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultDeposit.Id
        );
        scoringResultElementItemsList.add(depositRemarkNotRequired);

        // INFO BLOCK 1
        LongForm_Element_Item__c infoBlock1Heading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'What if I want another conditions?',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultInfoBlock1.Id
        );
        scoringResultElementItemsList.add(infoBlock1Heading);

        LongForm_Element_Item__c infoBodyOfBlock1 = new LongForm_Element_Item__c(
                Name = 'BODY OF BLOCK 1',
                Active__c = true,
                Value__c = 'Contact us at +49 XXX XXX-XX-XX (07:00-17:00 Mon - Fri) and we’ll try to find other variant for you.',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultInfoBlock1.Id
        );
        scoringResultElementItemsList.add(infoBodyOfBlock1);

        // BACK BUTTON
        LongForm_Element_Item__c backButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'BACK',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultBackButton.Id
        );
        scoringResultElementItemsList.add(backButtonName);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Free Text',
                Long_Form_Element__c = resultContinueButton.Id
        );
        scoringResultElementItemsList.add(continueButtonName);

        insert scoringResultElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createCardConfiguration()
    *  Summary         : Create card configaration
    *  CreatedDate     : 11/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCardConfiguration(String deviceView) {
        LongForm_Page__c cardConfiguration = new LongForm_Page__c(
                Name = 'CARD CONFIGURATION',
                Title__c = 'E2E Card configuration',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep2.Id
        );
        insert cardConfiguration;

        List<LongForm_Element__c> cardConfigurationElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c categoryTab = new LongForm_Element__c(
                Name = 'CATEGORY TAB',
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(categoryTab);

        LongForm_Element__c optionsTab = new LongForm_Element__c(
                Name = 'OPTIONS TAB',
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(optionsTab);

        LongForm_Element__c embossingTab = new LongForm_Element__c(
                Name = 'EMBOSSING TAB',
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(embossingTab);

        LongForm_Element__c cardSharp = new LongForm_Element__c(
                Name = '-CARD #-',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardSharp);

        LongForm_Element__c odometerOptions = new LongForm_Element__c(
                Name = 'ODOMETER OPTIONS',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(odometerOptions);

        LongForm_Element__c driverOrCarField = new LongForm_Element__c(
                Name = 'DRIVER OR CAR FIELD',
                Type__c = 'Text Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(driverOrCarField);

        LongForm_Element__c companyName = new LongForm_Element__c(
                Name = 'COMPANY NAME',
                Type__c = 'Text Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(companyName);

        LongForm_Element__c typeOfCar = new LongForm_Element__c(
                Name = 'TYPE OF CAR',
                Type__c = 'Text Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(typeOfCar);

        LongForm_Element__c editButton = new LongForm_Element__c(
                Name = 'EDIT BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(editButton);

        LongForm_Element__c cardConfigurationTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationTopHeading);

        LongForm_Element__c cardConfigurationNumberOfCards = new LongForm_Element__c(
                Name = 'NUMBER OF CARDS',
                Type__c = 'Text Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationNumberOfCards);

        LongForm_Element__c cardConfigurationFeesCost = new LongForm_Element__c(
                Name = 'FEES AND COSTS',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationFeesCost);

        LongForm_Element__c cardConfigurationServiceFee = new LongForm_Element__c(
                Name = 'SERVICE FEE',
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationServiceFee);

        LongForm_Element__c cardConfigurationTransactionFee = new LongForm_Element__c(
                Name = 'TRANSACTION FEE',
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationTransactionFee);

        LongForm_Element__c cardConfigurationOtherFee = new LongForm_Element__c(
                Name = 'OTHER FEE',
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationOtherFee);

        LongForm_Element__c cardConfigurationSameTab = new LongForm_Element__c(
                Name = 'SAME CARDS TAB',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationSameTab);

        LongForm_Element__c cardConfigurationDiffTab = new LongForm_Element__c(
                Name = 'DIFF CARDS TAB',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationDiffTab);

        LongForm_Element__c cardConfigurationTypeSection = new LongForm_Element__c(
                Name = 'CHOOSE TYPE SECTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationTypeSection);

        LongForm_Element__c cardConfigurationPumpSection = new LongForm_Element__c(
                Name = 'CHOOSE PUMP TYPE SECTION',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardConfigurationPumpSection);

        LongForm_Element__c cardType1 = new LongForm_Element__c(
                Name = 'CARD TYPE 1',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardType1);

        LongForm_Element__c cardType2 = new LongForm_Element__c(
                Name = 'CARD TYPE 2',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardType2);

        LongForm_Element__c cardType3 = new LongForm_Element__c(
                Name = 'CARD TYPE 3',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardType3);

        LongForm_Element__c pumpLocation = new LongForm_Element__c(
                Name = 'PUMP LOCATION',
                Type__c = 'Slider Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(pumpLocation);

        LongForm_Element__c pumpPartners = new LongForm_Element__c(
                Name = 'PUMP PARTNERS',
                Type__c = 'Slider Field',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(pumpPartners);

        LongForm_Element__c buttonOn = new LongForm_Element__c(
                Name = 'BUTTON ON',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(buttonOn);

        LongForm_Element__c buttonOff = new LongForm_Element__c(
                Name = 'BUTTON OFF',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(buttonOff);

        LongForm_Element__c cardGrill = new LongForm_Element__c(
                Name = 'CARD #',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(cardGrill);

        LongForm_Element__c backButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(backButton);

        LongForm_Element__c continueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfiguration.Id
        );
        cardConfigurationElementsList.add(continueButton);

        insert cardConfigurationElementsList;

        List<LongForm_Element_Item__c> cardConfigurationElementItemsList = new List<LongForm_Element_Item__c>();
        // CATEGORY TAB
        LongForm_Element_Item__c categoryTabName = new LongForm_Element_Item__c(
                Name = 'TAB NAME',
                Active__c = true,
                Value__c = 'Kategorie',
                Type__c = 'Free Text',
                Long_Form_Element__c = categoryTab.Id
        );
        cardConfigurationElementItemsList.add(categoryTabName);

        LongForm_Element_Item__c categoryDescription = new LongForm_Element_Item__c(
                Name = 'DESCRIPTION',
                Active__c = true,
                Value__c = 'Die Wahl der Kategorien beeinflusst die Kartengebühren nicht.',
                Type__c = 'Free Text',
                Long_Form_Element__c = categoryTab.Id
        );
        cardConfigurationElementItemsList.add(categoryDescription);

        LongForm_Element_Item__c categoryNextButton = new LongForm_Element_Item__c(
                Name = 'NEXT BUTTON',
                Active__c = true,
                Value__c = 'Weiter',
                Type__c = 'Label',
                Long_Form_Element__c = categoryTab.Id
        );
        cardConfigurationElementItemsList.add(categoryNextButton);

        // OPTIONS TAB
        LongForm_Element_Item__c optionsTabName = new LongForm_Element_Item__c(
                Name = 'TAB NAME',
                Active__c = true,
                Value__c = 'Optionen',
                Type__c = 'Free Text',
                Long_Form_Element__c = optionsTab.Id
        );
        cardConfigurationElementItemsList.add(optionsTabName);

        LongForm_Element_Item__c optionsNextButton = new LongForm_Element_Item__c(
                Name = 'NEXT BUTTON',
                Active__c = true,
                Value__c = 'Weiter',
                Type__c = 'Free Text',
                Long_Form_Element__c = optionsTab.Id
        );
        cardConfigurationElementItemsList.add(optionsNextButton);

        // EMBOSSING TAB
        LongForm_Element_Item__c embossingTabName = new LongForm_Element_Item__c(
                Name = 'TAB NAME',
                Active__c = true,
                Value__c = 'Prägung',
                Type__c = 'Free Text',
                Long_Form_Element__c = embossingTab.Id
        );
        cardConfigurationElementItemsList.add(embossingTabName);

        LongForm_Element_Item__c embossingTabDescription = new LongForm_Element_Item__c(
                Name = 'DESCRIPTION',
                Active__c = true,
                Value__c = 'Was möchten Sie auf Ihrer Karte prägen?',
                Type__c = 'Free Text',
                Long_Form_Element__c = embossingTab.Id
        );
        cardConfigurationElementItemsList.add(embossingTabDescription);

        LongForm_Element_Item__c embossingSaveButton = new LongForm_Element_Item__c(
                Name = 'SAVE BUTTON',
                Active__c = true,
                Value__c = 'Speichern',
                Type__c = 'Label',
                Long_Form_Element__c = embossingTab.Id
        );
        cardConfigurationElementItemsList.add(embossingSaveButton);

        LongForm_Element_Item__c embossingContinueButton = new LongForm_Element_Item__c(
                Name = 'CONTINUE BUTTON',
                Active__c = true,
                Value__c = 'Weiter',
                Type__c = 'Label',
                Long_Form_Element__c = embossingTab.Id
        );
        cardConfigurationElementItemsList.add(embossingContinueButton);

        // -CARD #-
        LongForm_Element_Item__c cardSharpLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Karte Nr.',
                Type__c = 'Label',
                Long_Form_Element__c = cardSharp.Id
        );
        cardConfigurationElementItemsList.add(cardSharpLabel);

        // ODOMETER OPTIONS
        LongForm_Element_Item__c odometerOptionsLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Kilometerzähler-Option',
                Type__c = 'Label',
                Long_Form_Element__c = odometerOptions.Id
        );
        cardConfigurationElementItemsList.add(odometerOptionsLabel);

        LongForm_Element_Item__c odometerOptionsDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = odometerOptions.Id
        );
        cardConfigurationElementItemsList.add(odometerOptionsDefaultValue);

        LongForm_Element_Item__c odometerOptionsRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Um die Ausgaben besser unter Kontrolle zu haben, kann beim Tanken die zurückgelegte Strecke erfasst werden.',
                Type__c = 'Free Text',
                Long_Form_Element__c = odometerOptions.Id
        );
        cardConfigurationElementItemsList.add(odometerOptionsRemark);

        // DRIVER OR CAR FIELD
        LongForm_Element_Item__c driverOrCarFieldLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Geben Sie eine der Optionen ein',
                Type__c = 'Label',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(driverOrCarFieldLabel);

        LongForm_Element_Item__c driverButtonLabel = new LongForm_Element_Item__c(
                Name = 'DRIVER BUTTON LABEL',
                Active__c = true,
                Value__c = 'Fahrername',
                Type__c = 'Label',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(driverButtonLabel);

        LongForm_Element_Item__c carButtonLabel = new LongForm_Element_Item__c(
                Name = 'CAR BUTTON LABEL',
                Active__c = true,
                Value__c = 'Kfz-Kennzeichen',
                Type__c = 'Label',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(carButtonLabel);

        LongForm_Element_Item__c driverButtonApi = new LongForm_Element_Item__c(
                Name = 'DRIVER BUTTON API',
                Active__c = true,
                Value__c = 'driver-name',
                Type__c = 'Free Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(driverButtonApi);

        LongForm_Element_Item__c carButtonApi = new LongForm_Element_Item__c(
                Name = 'CAR BUTTON API',
                Active__c = true,
                Value__c = 'car-number',
                Type__c = 'Free Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(carButtonApi);

        LongForm_Element_Item__c driverOrCarDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'driver-name',
                Type__c = 'Default Value',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(driverOrCarDefaultValue);

        LongForm_Element_Item__c warnMessageDriverName = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE DRIVER NAME',
                Active__c = true,
                Value__c = 'Bitte geben Sie den Fahrernamen in einem gültigen Format ein.',
                Type__c = 'Validation Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(warnMessageDriverName);

        LongForm_Element_Item__c warnMessageCarNumber = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE CAR NUMBER',
                Active__c = true,
                Value__c = 'Bitte geben Sie die Autonummer in einem gültigen Format ein.',
                Type__c = 'Validation Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(warnMessageCarNumber);

        LongForm_Element_Item__c driverOrCarFieldAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = driverOrCarField.Id
        );
        cardConfigurationElementItemsList.add(driverOrCarFieldAsterisk);

        // COMPANY NAME
        LongForm_Element_Item__c companyNameLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Firmenname (alle Karten)',
                Type__c = 'Label',
                Long_Form_Element__c = companyName.Id
        );
        cardConfigurationElementItemsList.add(companyNameLabel);

        LongForm_Element_Item__c companyNameAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = companyName.Id
        );
        cardConfigurationElementItemsList.add(companyNameAsterisk);

        LongForm_Element_Item__c companyNameWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Bitte geben Sie den Firmennamen in einem gültigen Format ein Sonderzeichen sind nicht zulässig.',
                Type__c = 'Validation Text',
                Long_Form_Element__c = companyName.Id
        );
        cardConfigurationElementItemsList.add(companyNameWarnMessage);

        LongForm_Element_Item__c companyNameRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Die Prägung des Firmennamens auf der Karte kann höchstens 25 Zeichen umfassen. Bitte geben Sie den korrekten Firmennamen an.',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyName.Id
        );
        cardConfigurationElementItemsList.add(companyNameRemark);

        // TYPE OF CAR
        LongForm_Element_Item__c typeOfCarLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Fahrzeugtyp',
                Type__c = 'Label',
                Long_Form_Element__c = typeOfCar.Id
        );
        cardConfigurationElementItemsList.add(typeOfCarLabel);

        LongForm_Element_Item__c typeOfCarLabelPKW = new LongForm_Element_Item__c(
                Name = 'PKW BUTTON LABEL',
                Active__c = true,
                Value__c = 'PKW',
                Type__c = 'Label',
                Long_Form_Element__c = typeOfCar.Id
        );
        cardConfigurationElementItemsList.add(typeOfCarLabelPKW);

        LongForm_Element_Item__c typeOfCarLabelLKW = new LongForm_Element_Item__c(
                Name = 'LKW BUTTON LABEL',
                Active__c = true,
                Value__c = 'LKW',
                Type__c = 'Label',
                Long_Form_Element__c = typeOfCar.Id
        );
        cardConfigurationElementItemsList.add(typeOfCarLabelLKW);

        LongForm_Element_Item__c pkwButtonApi = new LongForm_Element_Item__c(
                Name = 'PKW BUTTON API',
                Active__c = true,
                Value__c = 'PKW',
                Type__c = 'Free Text',
                Long_Form_Element__c = typeOfCar.Id
        );
        cardConfigurationElementItemsList.add(pkwButtonApi);

        LongForm_Element_Item__c typeOfCarDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'PKW',
                Type__c = 'Default Value',
                Long_Form_Element__c = typeOfCar.Id
        );
        cardConfigurationElementItemsList.add(typeOfCarDefaultValue);

        LongForm_Element_Item__c lkwButtonApi = new LongForm_Element_Item__c(
                Name = 'LKW BUTTON API',
                Active__c = true,
                Value__c = 'LKW',
                Type__c = 'Free Text',
                Long_Form_Element__c = typeOfCar.Id
        );
        cardConfigurationElementItemsList.add(lkwButtonApi);

        // EDIT BUTTON
        LongForm_Element_Item__c editButtonValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Ändern',
                Type__c = 'Label',
                Long_Form_Element__c = editButton.Id
        );
        cardConfigurationElementItemsList.add(editButtonValue);

        // TOP HEADING
        LongForm_Element_Item__c topHeadingName = new LongForm_Element_Item__c(
                Name = 'TOP HEADING NAME',
                Active__c = true,
                Value__c = 'How many cards do you need?',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationTopHeading.Id
        );
        cardConfigurationElementItemsList.add(topHeadingName);

        // NUMBER OF CARDS
        LongForm_Element_Item__c numberOfCardsAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationNumberOfCards.Id
        );
        cardConfigurationElementItemsList.add(numberOfCardsAsterisk);

        LongForm_Element_Item__c numberOfCardsLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Number of cards',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationNumberOfCards.Id
        );
        cardConfigurationElementItemsList.add(numberOfCardsLabel);

        LongForm_Element_Item__c numberOfCardsDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '1',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationNumberOfCards.Id
        );
        cardConfigurationElementItemsList.add(numberOfCardsDefaultValue);

        LongForm_Element_Item__c numberOfCardsRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Аn example of the description to the input field',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationNumberOfCards.Id
        );
        cardConfigurationElementItemsList.add(numberOfCardsRemark);

        LongForm_Element_Item__c numberOfCardsWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Please delete extra cards in the "Different category for each one" section',
                Type__c = 'Validation Text',
                Long_Form_Element__c = cardConfigurationNumberOfCards.Id
        );
        cardConfigurationElementItemsList.add(numberOfCardsWarnMessage);

        // FEES AND COSTS
        LongForm_Element_Item__c feesCostHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Fees & costs',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationFeesCost.Id
        );
        cardConfigurationElementItemsList.add(feesCostHeading);

        // SERVICE FEE
        LongForm_Element_Item__c monthlyFeeHeading = new LongForm_Element_Item__c(
                Name = 'MONTHLY FEE HEADING',
                Active__c = true,
                Value__c = 'Monthly fee',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationServiceFee.Id
        );
        cardConfigurationElementItemsList.add(monthlyFeeHeading);

        LongForm_Element_Item__c oneTimeFeeHeading = new LongForm_Element_Item__c(
                Name = 'ONE TIME FEE HEADING',
                Active__c = true,
                Value__c = 'One time setup fee',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationServiceFee.Id
        );
        cardConfigurationElementItemsList.add(oneTimeFeeHeading);

        LongForm_Element_Item__c serviceFeePer = new LongForm_Element_Item__c(
                Name = '-PER-',
                Active__c = true,
                Value__c = 'per',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationServiceFee.Id
        );
        cardConfigurationElementItemsList.add(serviceFeePer);

        LongForm_Element_Item__c serviceFeeCard = new LongForm_Element_Item__c(
                Name = '-CARD-',
                Active__c = true,
                Value__c = 'card',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationServiceFee.Id
        );
        cardConfigurationElementItemsList.add(serviceFeeCard);

        LongForm_Element_Item__c serviceFeeCards = new LongForm_Element_Item__c(
                Name = '-CARDS-',
                Active__c = true,
                Value__c = 'cards',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationServiceFee.Id
        );
        cardConfigurationElementItemsList.add(serviceFeeCards);

        // TRANSACTION FEE
        LongForm_Element_Item__c transactionFeeNationalHeading = new LongForm_Element_Item__c(
                Name = 'NATIONAL HEADING',
                Active__c = true,
                Value__c = 'National transactions',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(transactionFeeNationalHeading);

        LongForm_Element_Item__c nationalHeadingHelp = new LongForm_Element_Item__c(
                Name = 'NATIONAL HEADING HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nationalHeadingHelp);

        LongForm_Element_Item__c fuelShell = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL',
                Active__c = true,
                Value__c = 'Fuel (Shell)',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShell);

        LongForm_Element_Item__c fuelShellHelp = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShellHelp);

        LongForm_Element_Item__c fuelShellFavorite = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL FAVORITE',
                Active__c = true,
                Value__c = 'Fuel (Shell Favorite)',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShellFavorite);

        LongForm_Element_Item__c fuelShellFavoriteHelp = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL FAVORITE HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShellFavoriteHelp);

        LongForm_Element_Item__c fuelShellOther = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL OTHER',
                Active__c = true,
                Value__c = 'Fuel (Shell Other)',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShellOther);

        LongForm_Element_Item__c fuelShellOtherHelp = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL OTHER HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShellOtherHelp);

        LongForm_Element_Item__c shellPartner = new LongForm_Element_Item__c(
                Name = 'SHELL PARTNER',
                Active__c = true,
                Value__c = 'Shell Partner',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(shellPartner);

        LongForm_Element_Item__c shellPartnerHelp = new LongForm_Element_Item__c(
                Name = 'SHELL PARTNER HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(shellPartnerHelp);

        LongForm_Element_Item__c fuelShellPartner = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL PARTNER',
                Active__c = true,
                Value__c = 'Fuel (Shell Partner)',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShellPartner);

        LongForm_Element_Item__c nonFuelShellPartner = new LongForm_Element_Item__c(
                Name = 'NON-FUEL SHELL PARTNER',
                Active__c = true,
                Value__c = 'Non-fuel (Shell Partner)',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuelShellPartner);

        LongForm_Element_Item__c fuelShellPartnerHelp = new LongForm_Element_Item__c(
                Name = 'FUEL SHELL PARTNER HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(fuelShellPartnerHelp);

        LongForm_Element_Item__c nonFuelShellPartnerHelp = new LongForm_Element_Item__c(
                Name = 'NON-FUEL SHELL PARTNER HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuelShellPartnerHelp);

        LongForm_Element_Item__c nonFuel = new LongForm_Element_Item__c(
                Name = 'NON-FUEL',
                Active__c = true,
                Value__c = 'Non-fuel',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuel);

        LongForm_Element_Item__c nonFuelHelp = new LongForm_Element_Item__c(
                Name = 'NON-FUEL HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuelHelp);

        LongForm_Element_Item__c nonFuelShellFavorite = new LongForm_Element_Item__c(
                Name = 'NON-FUEL SHELL FAVORITE',
                Active__c = true,
                Value__c = 'Non-fuel (Shell Favorite)',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuelShellFavorite);

        LongForm_Element_Item__c nonFuelShellFavoriteHelp = new LongForm_Element_Item__c(
                Name = 'NON-FUEL SHELL FAVORITE HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuelShellFavoriteHelp);

        LongForm_Element_Item__c nonFuelShellOther = new LongForm_Element_Item__c(
                Name = 'NON-FUEL SHELL OTHER',
                Active__c = true,
                Value__c = 'Non-fuel (Shell Other)',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuelShellOther);

        LongForm_Element_Item__c nonFuelShellOtherHelp = new LongForm_Element_Item__c(
                Name = 'NON-FUEL SHELL OTHER HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(nonFuelShellOtherHelp);

        LongForm_Element_Item__c internationalHeading = new LongForm_Element_Item__c(
                Name = 'INTERNATIONAL HEADING',
                Active__c = true,
                Value__c = 'International transactions',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(internationalHeading);

        LongForm_Element_Item__c internationalHeadingHelp = new LongForm_Element_Item__c(
                Name = 'INTERNATIONAL HEADING HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(internationalHeadingHelp);

        LongForm_Element_Item__c allTypes = new LongForm_Element_Item__c(
                Name = 'ALL TYPES',
                Active__c = true,
                Value__c = 'All types',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(allTypes);

        LongForm_Element_Item__c allTypesHelp = new LongForm_Element_Item__c(
                Name = 'ALL TYPES HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(allTypesHelp);

        LongForm_Element_Item__c allFuel = new LongForm_Element_Item__c(
                Name = 'ALL FUEL',
                Active__c = true,
                Value__c = 'All: Fuel',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(allFuel);

        LongForm_Element_Item__c allFuelHelp = new LongForm_Element_Item__c(
                Name = 'ALL FUEL HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(allFuelHelp);

        LongForm_Element_Item__c allNonFuel = new LongForm_Element_Item__c(
                Name = 'ALL NON FUEL',
                Active__c = true,
                Value__c = 'All: Non-fuel',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(allNonFuel);

        LongForm_Element_Item__c allNonFuelHelp = new LongForm_Element_Item__c(
                Name = 'ALL NON FUEL HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(allNonFuelHelp);

        LongForm_Element_Item__c axchangeRate = new LongForm_Element_Item__c(
                Name = 'EXCHANGE RATE',
                Active__c = true,
                Value__c = 'Prowizja za przewalutowanie',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(axchangeRate);

        LongForm_Element_Item__c exchangeRateHelp = new LongForm_Element_Item__c(
                Name = 'EXCHANGE RATE HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationTransactionFee.Id
        );
        cardConfigurationElementItemsList.add(exchangeRateHelp);

        // OTHER FEE
        LongForm_Element_Item__c otherFeesHeading = new LongForm_Element_Item__c(
                Name = 'OTHER FEES HEADING',
                Active__c = true,
                Value__c = 'Other possible fees',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(otherFeesHeading);

        LongForm_Element_Item__c otherFeesSubheading = new LongForm_Element_Item__c(
                Name = 'OTHER FEES SUBHEADING',
                Active__c = true,
                Value__c = 'May apply in case of some event occurs',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(otherFeesSubheading);

        LongForm_Element_Item__c duplicatePayment = new LongForm_Element_Item__c(
                Name = 'DUPLICATE PAYMENT',
                Active__c = true,
                Value__c = 'Duplicate invoice payment',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(duplicatePayment);

        LongForm_Element_Item__c duplicatePaymentHelp = new LongForm_Element_Item__c(
                Name = 'DUPLICATE PAYMENT HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(duplicatePaymentHelp);

        LongForm_Element_Item__c latePayment = new LongForm_Element_Item__c(
                Name = 'LATE PAYMENT',
                Active__c = true,
                Value__c = 'Late invoice payment',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(latePayment);

        LongForm_Element_Item__c latePaymentHelp = new LongForm_Element_Item__c(
                Name = 'LATE PAYMENT HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(latePaymentHelp);

        LongForm_Element_Item__c cardReplacement = new LongForm_Element_Item__c(
                Name = 'CARD REPLACEMENT',
                Active__c = true,
                Value__c = 'Vervangende pas',
                Type__c = 'Label',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(cardReplacement);

        LongForm_Element_Item__c cardReplacementHelp = new LongForm_Element_Item__c(
                Name = 'CARD REPLACEMENT HELP',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationOtherFee.Id
        );
        cardConfigurationElementItemsList.add(cardReplacementHelp);

        // SAME CARDS TAB
        LongForm_Element_Item__c tabNamePart1 = new LongForm_Element_Item__c(
                Name = 'TAB NAME PART 1',
                Active__c = true,
                Value__c = 'All',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationSameTab.Id
        );
        cardConfigurationElementItemsList.add(tabNamePart1);

        LongForm_Element_Item__c tabNamePart2 = new LongForm_Element_Item__c(
                Name = 'TAB NAME PART 2',
                Active__c = true,
                Value__c = 'cards are same',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationSameTab.Id
        );
        cardConfigurationElementItemsList.add(tabNamePart2);

        // DIFF CARDS TAB
        LongForm_Element_Item__c tabName = new LongForm_Element_Item__c(
                Name = 'TAB NAME',
                Active__c = true,
                Value__c = 'Different category for each one',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationDiffTab.Id
        );
        cardConfigurationElementItemsList.add(tabName);

        LongForm_Element_Item__c saveCardButton = new LongForm_Element_Item__c(
                Name = 'SAVE CARD BUTTON',
                Active__c = true,
                Value__c = 'SAVE CARD',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationDiffTab.Id
        );
        cardConfigurationElementItemsList.add(saveCardButton);

        // CHOOSE TYPE SECTION
        LongForm_Element_Item__c sectionNameSingular = new LongForm_Element_Item__c(
                Name = 'SECTION NAME SINGULAR',
                Active__c = true,
                Value__c = 'Choose a category of card',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationTypeSection.Id
        );
        cardConfigurationElementItemsList.add(sectionNameSingular);

        LongForm_Element_Item__c sectionNamePlural = new LongForm_Element_Item__c(
                Name = 'SECTION NAME PLURAL',
                Active__c = true,
                Value__c = 'Choose a category of cards',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationTypeSection.Id
        );
        cardConfigurationElementItemsList.add(sectionNamePlural);

        LongForm_Element_Item__c typeSectionRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Doesn\'t Affect Fees',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationTypeSection.Id
        );
        cardConfigurationElementItemsList.add(typeSectionRemark);

        // CHOOSE PUMP TYPE SECTION
        LongForm_Element_Item__c sameCardsSectionNamePart1 = new LongForm_Element_Item__c(
                Name = 'SAME CARDS SECTION NAME PART 1',
                Active__c = true,
                Value__c = 'Service for',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationPumpSection.Id
        );
        cardConfigurationElementItemsList.add(sameCardsSectionNamePart1);

        LongForm_Element_Item__c sameCardsSectionNameSingularPart2 = new LongForm_Element_Item__c(
                Name = 'SAME CARDS SECTION NAME SINGULAR PART 2',
                Active__c = true,
                Value__c = 'card',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationPumpSection.Id
        );
        cardConfigurationElementItemsList.add(sameCardsSectionNameSingularPart2);

        LongForm_Element_Item__c sameCardsSectionNamePluralPart2 = new LongForm_Element_Item__c(
                Name = 'SAME CARDS SECTION NAME PLURAL PART 2',
                Active__c = true,
                Value__c = 'cards',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationPumpSection.Id
        );
        cardConfigurationElementItemsList.add(sameCardsSectionNamePluralPart2);

        LongForm_Element_Item__c diffCardsSectionName = new LongForm_Element_Item__c(
                Name = 'DIFF CARDS SECTION NAME',
                Active__c = true,
                Value__c = 'Service for Card #',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardConfigurationPumpSection.Id
        );
        cardConfigurationElementItemsList.add(diffCardsSectionName);

        // CARD TYPE 1
        LongForm_Element_Item__c cardTypeName1 = new LongForm_Element_Item__c(
                Name = 'TYPE NAME',
                Active__c = true,
                Value__c = 'Vehicle-related products',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType1.Id
        );
        cardConfigurationElementItemsList.add(cardTypeName1);

        LongForm_Element_Item__c cardTypeItem1 = new LongForm_Element_Item__c(
                Name = 'ITEM 1',
                Active__c = true,
                Value__c = 'Fuel: all types',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType1.Id
        );
        cardConfigurationElementItemsList.add(cardTypeItem1);

        LongForm_Element_Item__c cardTypeDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'true',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType1.Id
        );
        cardConfigurationElementItemsList.add(cardTypeDefaultValue);

        LongForm_Element_Item__c cardTypeItem2 = new LongForm_Element_Item__c(
                Name = 'ITEM 2',
                Active__c = true,
                Value__c = 'Car liquids',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType1.Id
        );
        cardConfigurationElementItemsList.add(cardTypeItem2);

        LongForm_Element_Item__c cardTypeItem3 = new LongForm_Element_Item__c(
                Name = 'ITEM 3',
                Active__c = true,
                Value__c = 'Car accessories',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType1.Id
        );
        cardConfigurationElementItemsList.add(cardTypeItem3);

        LongForm_Element_Item__c cardTypeItem4 = new LongForm_Element_Item__c(
                Name = 'ITEM 4',
                Active__c = true,
                Value__c = 'Car services',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType1.Id
        );
        cardConfigurationElementItemsList.add(cardTypeItem4);

        LongForm_Element_Item__c cardTypeItem5 = new LongForm_Element_Item__c(
                Name = 'ITEM 5',
                Active__c = true,
                Value__c = 'Tolls & tunnels',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType1.Id
        );
        cardConfigurationElementItemsList.add(cardTypeItem5);

        // CARD TYPE 2
        LongForm_Element_Item__c cardTypeName2 = new LongForm_Element_Item__c(
                Name = 'TYPE NAME',
                Active__c = true,
                Value__c = 'Fuel: all types',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType2.Id
        );
        cardConfigurationElementItemsList.add(cardTypeName2);

        LongForm_Element_Item__c cardType2Item1 = new LongForm_Element_Item__c(
                Name = 'ITEM 1',
                Active__c = true,
                Value__c = 'Fuel: all types',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType2.Id
        );
        cardConfigurationElementItemsList.add(cardType2Item1);

        LongForm_Element_Item__c cardType2Item2 = new LongForm_Element_Item__c(
                Name = 'ITEM 2',
                Active__c = true,
                Value__c = 'Car liquids',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType2.Id
        );
        cardConfigurationElementItemsList.add(cardType2Item2);

        LongForm_Element_Item__c cardType2DefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType2.Id
        );
        cardConfigurationElementItemsList.add(cardType2DefaultValue);

        // CARD TYPE 3
        LongForm_Element_Item__c cardType3Name = new LongForm_Element_Item__c(
                Name = 'TYPE NAME',
                Active__c = true,
                Value__c = 'Fuel: diesel',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType3.Id
        );
        cardConfigurationElementItemsList.add(cardType3Name);

        LongForm_Element_Item__c cardType3Item1 = new LongForm_Element_Item__c(
                Name = 'ITEM 1',
                Active__c = true,
                Value__c = 'Fuel: diesel only',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType3.Id
        );
        cardConfigurationElementItemsList.add(cardType3Item1);

        LongForm_Element_Item__c cardType3Item2 = new LongForm_Element_Item__c(
                Name = 'ITEM 2',
                Active__c = true,
                Value__c = 'AdBlue',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType3.Id
        );
        cardConfigurationElementItemsList.add(cardType3Item2);

        LongForm_Element_Item__c cardType3Item3 = new LongForm_Element_Item__c(
                Name = 'ITEM 3',
                Active__c = true,
                Value__c = 'AdBlue',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType3.Id
        );
        cardConfigurationElementItemsList.add(cardType3Item3);

        LongForm_Element_Item__c cardType3DefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardType3.Id
        );
        cardConfigurationElementItemsList.add(cardType3DefaultValue);

        // PUMP LOCATION
        LongForm_Element_Item__c pumpLocationLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Pump outside Germany',
                Type__c = 'Free Text',
                Long_Form_Element__c = pumpLocation.Id
        );
        cardConfigurationElementItemsList.add(pumpLocationLabel);

        LongForm_Element_Item__c pumpLocationRemark1 = new LongForm_Element_Item__c(
                Name = 'REMARK 1',
                Active__c = true,
                Value__c = 'Make your card valid everywhere in EU',
                Type__c = 'Free Text',
                Long_Form_Element__c = pumpLocation.Id
        );
        cardConfigurationElementItemsList.add(pumpLocationRemark1);

        LongForm_Element_Item__c pumpLocationRemark2 = new LongForm_Element_Item__c(
                Name = 'REMARK 2',
                Active__c = true,
                Value__c = 'Plus 1 € Monthly fee',
                Type__c = 'Free Text',
                Long_Form_Element__c = pumpLocation.Id
        );
        cardConfigurationElementItemsList.add(pumpLocationRemark2);

        LongForm_Element_Item__c pumpLocationDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'true',
                Type__c = 'Default Value',
                Long_Form_Element__c = pumpLocation.Id
        );
        cardConfigurationElementItemsList.add(pumpLocationDefaultValue);

        LongForm_Element_Item__c pumpLocationHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = pumpLocation.Id
        );
        cardConfigurationElementItemsList.add(pumpLocationHelp);

        // PUMP PARTNERS
        LongForm_Element_Item__c pumpPartnersLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Pump at Shell’s partners',
                Type__c = 'Free Text',
                Long_Form_Element__c = pumpPartners.Id
        );
        cardConfigurationElementItemsList.add(pumpPartnersLabel);

        LongForm_Element_Item__c pumpPartnersRemark2 = new LongForm_Element_Item__c(
                Name = 'REMARK 2',
                Active__c = true,
                Value__c = '2 € Transaction fee for fuel',
                Type__c = 'Free Text',
                Long_Form_Element__c = pumpPartners.Id
        );
        cardConfigurationElementItemsList.add(pumpPartnersRemark2);

        LongForm_Element_Item__c pumpPartnersDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'true',
                Type__c = 'Default Value',
                Long_Form_Element__c = pumpPartners.Id
        );
        cardConfigurationElementItemsList.add(pumpPartnersDefaultValue);

        LongForm_Element_Item__c pumpPartnersHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = pumpPartners.Id
        );
        cardConfigurationElementItemsList.add(pumpPartnersHelp);

        LongForm_Element_Item__c pumpPartnersRemark1 = new LongForm_Element_Item__c(
                Name = 'REMARK 1',
                Active__c = true,
                Value__c = 'Able to use card at such partners: parent here ...',
                Type__c = 'Free Text',
                Long_Form_Element__c = pumpPartners.Id
        );
        cardConfigurationElementItemsList.add(pumpPartnersRemark1);

        // BUTTON ON
        LongForm_Element_Item__c buttonOnLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'ON',
                Type__c = 'Label',
                Long_Form_Element__c = buttonOn.Id
        );
        cardConfigurationElementItemsList.add(buttonOnLabel);

        // BUTTON OFF
        LongForm_Element_Item__c buttonOffLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'OFF',
                Type__c = 'Label',
                Long_Form_Element__c = buttonOff.Id
        );
        cardConfigurationElementItemsList.add(buttonOffLabel);

        // CARD #
        LongForm_Element_Item__c cardGrillHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Card #',
                Type__c = 'Free Text',
                Long_Form_Element__c = cardGrill.Id
        );
        cardConfigurationElementItemsList.add(cardGrillHeading);

        LongForm_Element_Item__c testOptions = new LongForm_Element_Item__c(
                Name = 'OPTIONS',
                Active__c = true,
                Value__c = 'Sofort=>SOFORT-logo.png;Giropay=>giroPay-logo.png;',
                Type__c = 'Options',
                Long_Form_Element__c = cardGrill.Id
        );
        cardConfigurationElementItemsList.add(testOptions);

        // BACK BUTTON
        LongForm_Element_Item__c backButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'BACK',
                Type__c = 'Free Text',
                Long_Form_Element__c = backButton.Id
        );
        cardConfigurationElementItemsList.add(backButtonName);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Free Text',
                Long_Form_Element__c = continueButton.Id
        );
        cardConfigurationElementItemsList.add(continueButtonName);

        insert cardConfigurationElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createCardConfigurationSpecialOffers(String deviceView, String homeOffer, String nonHomeOffer, String country, String channel, String product)
    *  Summary         : Create card configaration special offers data
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView, String homeOffer, String nonHomeOffer, String country, String channel, String product
    *  Returns         : void
    ******************************************************************************/
    public static void createCardConfigurationSpecialOffers(String deviceView, String homeOffer, String nonHomeOffer, String country, String channel, String product1, String product2) {
        LongForm_Page__c cardConfigurationSpecialOffers = new LongForm_Page__c(
                Name = 'CARD CONFIGURATION. SPECIAL OFFERS',
                Title__c = 'E2E Special offers',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep2.Id
        );
        insert cardConfigurationSpecialOffers;

        List<LongForm_Element__c> specialOffersElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c specialOfferTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfigurationSpecialOffers.Id
        );
        specialOffersElementsList.add(specialOfferTopHeading);

        LongForm_Element__c specialOfferInboundTypeC = new LongForm_Element__c(
                Name = homeOffer,
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfigurationSpecialOffers.Id
        );
        specialOffersElementsList.add(specialOfferInboundTypeC);

        LongForm_Element__c specialOfferInboundTypeB = new LongForm_Element__c(
                Name = nonHomeOffer,
                Type__c = 'Text Block',
                Long_Form_Page__c = cardConfigurationSpecialOffers.Id
        );
        specialOffersElementsList.add(specialOfferInboundTypeB);

        LongForm_Element__c specialOfferBackButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfigurationSpecialOffers.Id
        );
        specialOffersElementsList.add(specialOfferBackButton);

        LongForm_Element__c specialOfferContinueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfigurationSpecialOffers.Id
        );
        specialOffersElementsList.add(specialOfferContinueButton);

        LongForm_Element__c specialOfferLocatorUrl = new LongForm_Element__c(
                Name = 'LOCATOR URL',
                Type__c = 'URL',
                Long_Form_Page__c = cardConfigurationSpecialOffers.Id
        );
        specialOffersElementsList.add(specialOfferLocatorUrl);

        insert specialOffersElementsList;

        List<LongForm_Element_Item__c> specialOfferElementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c topHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Reduce prices with Special Offers',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferTopHeading.Id
        );
        specialOfferElementItemsList.add(topHeadingItem);

        LongForm_Element_Item__c specialOfferRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'At least one Special Offer will stay with you',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferTopHeading.Id
        );
        specialOfferElementItemsList.add(specialOfferRemark);

        // INBOUND TYPE C OFFER #1
        LongForm_Element_Item__c allFuelTypesC = new LongForm_Element_Item__c(
                Name = '-ALL FUEL TYPES-',
                Active__c = true,
                Value__c = 'All fuel types',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(allFuelTypesC);

        LongForm_Element_Item__c anyFuelTypeC = new LongForm_Element_Item__c(
                Name = '-ANY FUEL TYPE-',
                Active__c = true,
                Value__c = 'Any',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(anyFuelTypeC);

        LongForm_Element_Item__c centOffTypeC = new LongForm_Element_Item__c(
                Name = '-CENT OFF-',
                Active__c = true,
                Value__c = 'cent off',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(centOffTypeC);

        LongForm_Element_Item__c centOffsTypeC = new LongForm_Element_Item__c(
                Name = '-CENTS OFF-',
                Active__c = true,
                Value__c = 'cents off',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(centOffsTypeC);

        LongForm_Element_Item__c dieselAgoLowSulphurTypeC = new LongForm_Element_Item__c(
                Name = '-DIESEL AGO LOW SULPHUR-',
                Active__c = true,
                Value__c = 'Diesel (AGO Low Sulphur)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselAgoLowSulphurTypeC);

        LongForm_Element_Item__c dieselAgoTypeC = new LongForm_Element_Item__c(
                Name = '-DIESEL AGO-',
                Active__c = true,
                Value__c = 'Diesel (AGO)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselAgoTypeC);

        LongForm_Element_Item__c dieselAllTypesC = new LongForm_Element_Item__c(
                Name = '-DIESEL ALL TYPES-',
                Active__c = true,
                Value__c = 'Diesel (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselAllTypesC);

        LongForm_Element_Item__c dieselBioTypeC = new LongForm_Element_Item__c(
                Name = '-DIESEL BIO-',
                Active__c = true,
                Value__c = 'Diesel (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselBioTypeC);

        LongForm_Element_Item__c dieselForTruckTypeC = new LongForm_Element_Item__c(
                Name = '-DIESEL FOR TRUCKS-',
                Active__c = true,
                Value__c = 'Diesel (for trucks)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselForTruckTypeC);

        LongForm_Element_Item__c dieselPlusTypeC = new LongForm_Element_Item__c(
                Name = '-DIESEL PLUS-',
                Active__c = true,
                Value__c = 'Diesel (Plus)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselPlusTypeC);

        LongForm_Element_Item__c dieselVPowerTypeC = new LongForm_Element_Item__c(
                Name = '-DIESEL V-POWER-',
                Active__c = true,
                Value__c = 'Diesel (V-Power)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselVPowerTypeC);

        LongForm_Element_Item__c dieselTypeC = new LongForm_Element_Item__c(
                Name = '-DIESEL-',
                Active__c = true,
                Value__c = 'Diesel',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselTypeC);

        LongForm_Element_Item__c expectTypeC = new LongForm_Element_Item__c(
                Name = '-EXPECT-',
                Active__c = true,
                Value__c = 'expect',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(expectTypeC);

        LongForm_Element_Item__c gasFuelAllTypesC = new LongForm_Element_Item__c(
                Name = '-GAS FUEL ALL TYPES-',
                Active__c = true,
                Value__c = 'Gas Fuel (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(gasFuelAllTypesC);

        LongForm_Element_Item__c gasFuelCNGTypeC = new LongForm_Element_Item__c(
                Name = '-GAS FUEL CNG-',
                Active__c = true,
                Value__c = 'Gas Fuel (CNG)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(gasFuelCNGTypeC);

        LongForm_Element_Item__c gasFuelLPGTypeC = new LongForm_Element_Item__c(
                Name = '-GAS FUEL LPG-',
                Active__c = true,
                Value__c = 'Gas Fuel (LPG)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(gasFuelLPGTypeC);

        LongForm_Element_Item__c germanyAndEuropeTypeC = new LongForm_Element_Item__c(
                Name = '-GERMANY AND EUROPE-',
                Active__c = true,
                Value__c = 'Germany & Europe',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(germanyAndEuropeTypeC);

        LongForm_Element_Item__c germanyTypeC = new LongForm_Element_Item__c(
                Name = '-GERMANY-',
                Active__c = true,
                Value__c = 'Germany',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(germanyTypeC);

        LongForm_Element_Item__c literTypeC = new LongForm_Element_Item__c(
                Name = '-LITER-',
                Active__c = true,
                Value__c = 'liter',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(literTypeC);

        LongForm_Element_Item__c litersTypeC = new LongForm_Element_Item__c(
                Name = '-LITERS-',
                Active__c = true,
                Value__c = 'liters',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(litersTypeC);

        LongForm_Element_Item__c mogalAllTypesTypeC = new LongForm_Element_Item__c(
                Name = '-MOGAS ALL TYPES-',
                Active__c = true,
                Value__c = 'MOGAS (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogalAllTypesTypeC);

        LongForm_Element_Item__c mogalLeadedUnleadedTypeC = new LongForm_Element_Item__c(
                Name = '-MOGAS LEADED UNLEADED-',
                Active__c = true,
                Value__c = 'MOGAS (leaded & unleaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogalLeadedUnleadedTypeC);

        LongForm_Element_Item__c mogalLeadedTypeC = new LongForm_Element_Item__c(
                Name = '-MOGAS LEADED-',
                Active__c = true,
                Value__c = 'MOGAS (leaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogalLeadedTypeC);

        LongForm_Element_Item__c mogasUnLeadedTypeC = new LongForm_Element_Item__c(
                Name = '-MOGAS UNLEADED-',
                Active__c = true,
                Value__c = 'MOGAS (unleaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogasUnLeadedTypeC);

        LongForm_Element_Item__c monthTypeC = new LongForm_Element_Item__c(
                Name = '-MONTH-',
                Active__c = true,
                Value__c = 'month',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(monthTypeC);

        LongForm_Element_Item__c monthsTypeC = new LongForm_Element_Item__c(
                Name = '-MONTHS-',
                Active__c = true,
                Value__c = 'months',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(monthsTypeC);

        LongForm_Element_Item__c moreThanTypeC = new LongForm_Element_Item__c(
                Name = '-MORE THAN-',
                Active__c = true,
                Value__c = 'more than',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(moreThanTypeC);

        LongForm_Element_Item__c notMoreThanTypeC = new LongForm_Element_Item__c(
                Name = '-NOT MORE THAN-',
                Active__c = true,
                Value__c = 'not more than',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(notMoreThanTypeC);

        LongForm_Element_Item__c notSpeciFiedYetTypeC = new LongForm_Element_Item__c(
                Name = '-NOT SPECIFIED YET-',
                Active__c = true,
                Value__c = 'Not specified yet',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(notSpeciFiedYetTypeC);

        LongForm_Element_Item__c onlyForTypeC = new LongForm_Element_Item__c(
                Name = '-ONLY FOR-',
                Active__c = true,
                Value__c = 'only for',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(onlyForTypeC);

        LongForm_Element_Item__c per1CardTypeC = new LongForm_Element_Item__c(
                Name = '-PER 1 CARD-',
                Active__c = true,
                Value__c = 'per 1 card',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(per1CardTypeC);

        LongForm_Element_Item__c per1MonthTypeC = new LongForm_Element_Item__c(
                Name = '-PER 1 MONTH-',
                Active__c = true,
                Value__c = 'per 1 month',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(per1MonthTypeC);

        LongForm_Element_Item__c perAccountCompanyTypeC = new LongForm_Element_Item__c(
                Name = '-PER ACCOUNT COMPANY-',
                Active__c = true,
                Value__c = 'per account\\company',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(perAccountCompanyTypeC);

        LongForm_Element_Item__c perTypeC = new LongForm_Element_Item__c(
                Name = '-PER-',
                Active__c = true,
                Value__c = 'per',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(perTypeC);

        LongForm_Element_Item__c percentTypeC = new LongForm_Element_Item__c(
                Name = '-PERCENT-',
                Active__c = true,
                Value__c = 'percent',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(percentTypeC);

        LongForm_Element_Item__c petrolTypeC = new LongForm_Element_Item__c(
                Name = '-PETROL-',
                Active__c = true,
                Value__c = 'Petrol',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(petrolTypeC);

        LongForm_Element_Item__c shellAllStationsTypeC = new LongForm_Element_Item__c(
                Name = '-SHELL ALL STATIONS-',
                Active__c = true,
                Value__c = 'Shell (All Stations)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(shellAllStationsTypeC);

        LongForm_Element_Item__c shellAndPartnersTypeC = new LongForm_Element_Item__c(
                Name = '-SHELL AND PARTNERS-',
                Active__c = true,
                Value__c = 'Shell & Partners',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(shellAndPartnersTypeC);

        LongForm_Element_Item__c shellHomeStationTypeC = new LongForm_Element_Item__c(
                Name = '-SHELL HOME STATION-',
                Active__c = true,
                Value__c = 'Shell (Home Station)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(shellHomeStationTypeC);

        LongForm_Element_Item__c dieselBioC = new LongForm_Element_Item__c(
                Name = '-Diesel (Bio)-',
                Active__c = true,
                Value__c = 'Diesel (Bio)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselBioC);

        LongForm_Element_Item__c dieselPlusC = new LongForm_Element_Item__c(
                Name = '-Diesel (Plus)-',
                Active__c = true,
                Value__c = 'Diesel (Plus)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselPlusC);

        LongForm_Element_Item__c dieselForTrucksC = new LongForm_Element_Item__c(
                Name = '-Diesel (for trucks)-',
                Active__c = true,
                Value__c = 'Diesel (for trucks)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(dieselForTrucksC);

        LongForm_Element_Item__c mogasAllTypesC = new LongForm_Element_Item__c(
                Name = '-Mogas (all types)-',
                Active__c = true,
                Value__c = 'MOGAS (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogasAllTypesC);

        LongForm_Element_Item__c mogasLeadedAndUnleadedC = new LongForm_Element_Item__c(
                Name = '-Mogas (leaded & unleaded)-',
                Active__c = true,
                Value__c = 'MOGAS (leaded & unleaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogasLeadedAndUnleadedC);

        LongForm_Element_Item__c mogasLeadedC = new LongForm_Element_Item__c(
                Name = '-Mogas (leaded)-',
                Active__c = true,
                Value__c = 'MOGAS (leaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogasLeadedC);

        LongForm_Element_Item__c mogasUnLeadedC = new LongForm_Element_Item__c(
                Name = '-Mogas (unleaded)-',
                Active__c = true,
                Value__c = 'MOGAS (unleaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(mogasUnLeadedC);

        LongForm_Element_Item__c unlimitedTypeC = new LongForm_Element_Item__c(
                Name = '-UNLIMITED-',
                Active__c = true,
                Value__c = 'Unlimited',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(unlimitedTypeC);

        LongForm_Element_Item__c unlimitedDiff = new LongForm_Element_Item__c(
                Name = '-UNLIMITED DIFF-',
                Active__c = true,
                Value__c = 'Unlimited',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(unlimitedDiff);

        LongForm_Element_Item__c weekTypeC = new LongForm_Element_Item__c(
                Name = '-WEEK-',
                Active__c = true,
                Value__c = 'Week',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(weekTypeC);

        LongForm_Element_Item__c weeksTypeC = new LongForm_Element_Item__c(
                Name = '-WEEKS-',
                Active__c = true,
                Value__c = 'Weeks',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(weeksTypeC);

        LongForm_Element_Item__c yearTypeC = new LongForm_Element_Item__c(
                Name = '-YEAR-',
                Active__c = true,
                Value__c = 'Year',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(yearTypeC);

        LongForm_Element_Item__c yearsTypeC = new LongForm_Element_Item__c(
                Name = '-YEARS-',
                Active__c = true,
                Value__c = 'Year',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(yearsTypeC);

        LongForm_Element_Item__c alreadySelectedOfferMessageTypeC = new LongForm_Element_Item__c(
                Name = 'ALREADY SELECTED OFFER MESSAGE',
                Active__c = true,
                Value__c = 'You’ve chosen the Special Offer already',
                Type__c = 'Validation Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(alreadySelectedOfferMessageTypeC);

        LongForm_Element_Item__c cancelButtonTypeC = new LongForm_Element_Item__c(
                Name = 'CANCEL BUTTON',
                Active__c = true,
                Value__c = 'CANCEL',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(cancelButtonTypeC);

        LongForm_Element_Item__c chooseStationButtonTypeC = new LongForm_Element_Item__c(
                Name = 'CHOOSE STATION BUTTON',
                Active__c = true,
                Value__c = 'CHOOSE STATION...',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(chooseStationButtonTypeC);

        LongForm_Element_Item__c confirmStationButtonTypeC = new LongForm_Element_Item__c(
                Name = 'CONFIRM STATION BUTTON',
                Active__c = true,
                Value__c = 'THIS IS MY STATION',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(confirmStationButtonTypeC);

        LongForm_Element_Item__c detailsHeadingTypeC = new LongForm_Element_Item__c(
                Name = 'DETAILS HEADING',
                Active__c = true,
                Value__c = 'Details',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(detailsHeadingTypeC);

        LongForm_Element_Item__c discountTypeC = new LongForm_Element_Item__c(
                Name = 'DISCOUNT',
                Active__c = true,
                Value__c = 'Discount:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(discountTypeC);

        LongForm_Element_Item__c discountLocationTypeC = new LongForm_Element_Item__c(
                Name = 'DISCOUNT LOCATION',
                Active__c = true,
                Value__c = 'at favorite station',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(discountLocationTypeC);

        LongForm_Element_Item__c editButtonTypeC = new LongForm_Element_Item__c(
                Name = 'EDIT BUTTON',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(editButtonTypeC);

        LongForm_Element_Item__c favouriteStationHeadingTypeC = new LongForm_Element_Item__c(
                Name = 'FAVOURITE STATION HEADING',
                Active__c = true,
                Value__c = 'Favourite station:',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(favouriteStationHeadingTypeC);

        LongForm_Element_Item__c fuelTypeC = new LongForm_Element_Item__c(
                Name = 'FUEL TYPE',
                Active__c = true,
                Value__c = 'Fuel Type:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(fuelTypeC);

        LongForm_Element_Item__c geographyTypeC = new LongForm_Element_Item__c(
                Name = 'GEOGRAPHY',
                Active__c = true,
                Value__c = 'Geography:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(geographyTypeC);

        LongForm_Element_Item__c locatorNoDataMessageTypeC = new LongForm_Element_Item__c(
                Name = 'LOCATOR NO DATA MESSAGE',
                Active__c = true,
                Value__c = 'Sorry, nothing is found here. Try another address',
                Type__c = 'Validation Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(locatorNoDataMessageTypeC);

        LongForm_Element_Item__c locatorUrlTypeC = new LongForm_Element_Item__c(
                Name = 'LOCATOR URL',
                Active__c = true,
                Value__c = 'https://de.eurolocator-v3.transitcard.ru/locator/?product=4&mode=choose-station&address=',
                Type__c = 'URL',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(locatorUrlTypeC);

        LongForm_Element_Item__c locatorWrongAddressMessageTypeC = new LongForm_Element_Item__c(
                Name = 'LOCATOR WRONG ADDRESS MESSAGE',
                Active__c = true,
                Value__c = 'Sorry, you use incorrect address. Try another address',
                Type__c = 'Validation Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(locatorWrongAddressMessageTypeC);

        LongForm_Element_Item__c offerDescriptionTypeC = new LongForm_Element_Item__c(
                Name = 'OFFER DESCRIPTION',
                Active__c = true,
                Value__c = 'Tell us which station is your favorite and we grant you a special price on pumping',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(offerDescriptionTypeC);

        LongForm_Element_Item__c offerNameTypeC = new LongForm_Element_Item__c(
                Name = 'OFFER NAME',
                Active__c = true,
                Value__c = 'Favorite Shell station example of the header with line wrapping',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(offerNameTypeC);

        LongForm_Element_Item__c removeOfferButtonTypeC = new LongForm_Element_Item__c(
                Name = 'REMOVE OFFER BUTTON',
                Active__c = true,
                Value__c = 'REMOVE',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(removeOfferButtonTypeC);

        LongForm_Element_Item__c stationTypeC = new LongForm_Element_Item__c(
                Name = 'STATION',
                Active__c = true,
                Value__c = 'Station:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(stationTypeC);

        LongForm_Element_Item__c timeTypeC = new LongForm_Element_Item__c(
                Name = 'TIME',
                Active__c = true,
                Value__c = 'Time:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(timeTypeC);

        LongForm_Element_Item__c volumeTypeC = new LongForm_Element_Item__c(
                Name = 'VOLUME',
                Active__c = true,
                Value__c = 'Volume:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeC.Id
        );
        specialOfferElementItemsList.add(volumeTypeC);

        // INBOUND TYPE B OFFER #1
        LongForm_Element_Item__c allFuelTypesB = new LongForm_Element_Item__c(
                Name = '-ALL FUEL TYPES-',
                Active__c = true,
                Value__c = 'All fuel types',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(allFuelTypesB);

        LongForm_Element_Item__c anyFuelTypeB = new LongForm_Element_Item__c(
                Name = '-ANY FUEL TYPE-',
                Active__c = true,
                Value__c = 'Any',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(anyFuelTypeB);

        LongForm_Element_Item__c centOffTypeB = new LongForm_Element_Item__c(
                Name = '-CENT OFF-',
                Active__c = true,
                Value__c = 'cent off',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(centOffTypeB);

        LongForm_Element_Item__c centOffsTypeB = new LongForm_Element_Item__c(
                Name = '-CENTS OFF-',
                Active__c = true,
                Value__c = 'cents off',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(centOffsTypeB);

        LongForm_Element_Item__c dieselAgoLowSulphurTypeB = new LongForm_Element_Item__c(
                Name = '-DIESEL AGO LOW SULPHUR-',
                Active__c = true,
                Value__c = 'Diesel (AGO Low Sulphur)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselAgoLowSulphurTypeB);

        LongForm_Element_Item__c dieselAgoTypeB = new LongForm_Element_Item__c(
                Name = '-DIESEL AGO-',
                Active__c = true,
                Value__c = 'Diesel (AGO)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselAgoTypeB);

        LongForm_Element_Item__c dieselAllTypesB = new LongForm_Element_Item__c(
                Name = '-DIESEL ALL TYPES-',
                Active__c = true,
                Value__c = 'Diesel (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselAllTypesB);

        LongForm_Element_Item__c dieselBioTypeB = new LongForm_Element_Item__c(
                Name = '-DIESEL BIO-',
                Active__c = true,
                Value__c = 'Diesel (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselBioTypeB);

        LongForm_Element_Item__c dieselForTruckTypeB = new LongForm_Element_Item__c(
                Name = '-DIESEL FOR TRUCKS-',
                Active__c = true,
                Value__c = 'Diesel (for trucks)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselForTruckTypeB);

        LongForm_Element_Item__c dieselPlusTypeB = new LongForm_Element_Item__c(
                Name = '-DIESEL PLUS-',
                Active__c = true,
                Value__c = 'Diesel (Plus)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselPlusTypeB);

        LongForm_Element_Item__c dieselVPowerTypeB = new LongForm_Element_Item__c(
                Name = '-DIESEL V-POWER-',
                Active__c = true,
                Value__c = 'Diesel (V-Power)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselVPowerTypeB);

        LongForm_Element_Item__c dieselTypeB = new LongForm_Element_Item__c(
                Name = '-DIESEL-',
                Active__c = true,
                Value__c = 'Diesel',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(dieselTypeB);

        LongForm_Element_Item__c expectTypeB = new LongForm_Element_Item__c(
                Name = '-EXPECT-',
                Active__c = true,
                Value__c = 'expect',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(expectTypeB);

        LongForm_Element_Item__c gasFuelAllTypesB = new LongForm_Element_Item__c(
                Name = '-GAS FUEL ALL TYPES-',
                Active__c = true,
                Value__c = 'Gas Fuel (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(gasFuelAllTypesB);

        LongForm_Element_Item__c gasFuelCNGTypeB = new LongForm_Element_Item__c(
                Name = '-GAS FUEL CNG-',
                Active__c = true,
                Value__c = 'Gas Fuel (CNG)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(gasFuelCNGTypeB);

        LongForm_Element_Item__c gasFuelLPGTypeB = new LongForm_Element_Item__c(
                Name = '-GAS FUEL LPG-',
                Active__c = true,
                Value__c = 'Gas Fuel (LPG)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(gasFuelLPGTypeB);

        LongForm_Element_Item__c germanyAndEuropeTypeB = new LongForm_Element_Item__c(
                Name = '-GERMANY AND EUROPE-',
                Active__c = true,
                Value__c = 'Germany & Europe',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(germanyAndEuropeTypeB);

        LongForm_Element_Item__c germanyTypeB = new LongForm_Element_Item__c(
                Name = '-GERMANY-',
                Active__c = true,
                Value__c = 'Germany',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(germanyTypeB);

        LongForm_Element_Item__c literTypeB = new LongForm_Element_Item__c(
                Name = '-LITER-',
                Active__c = true,
                Value__c = 'liter',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(literTypeB);

        LongForm_Element_Item__c litersTypeB = new LongForm_Element_Item__c(
                Name = '-LITERS-',
                Active__c = true,
                Value__c = 'liters',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(litersTypeB);

        LongForm_Element_Item__c mogalAllTypesTypeB = new LongForm_Element_Item__c(
                Name = '-MOGAS ALL TYPES-',
                Active__c = true,
                Value__c = 'MOGAS (all types)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(mogalAllTypesTypeB);

        LongForm_Element_Item__c mogalLeadedUnleadedTypeB = new LongForm_Element_Item__c(
                Name = '-MOGAS LEADED UNLEADED-',
                Active__c = true,
                Value__c = 'MOGAS (leaded & unleaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(mogalLeadedUnleadedTypeB);

        LongForm_Element_Item__c mogalLeadedTypeB = new LongForm_Element_Item__c(
                Name = '-MOGAS LEADED-',
                Active__c = true,
                Value__c = 'MOGAS (leaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(mogalLeadedTypeB);

        LongForm_Element_Item__c mogasUnLeadedTypeB = new LongForm_Element_Item__c(
                Name = '-MOGAS UNLEADED-',
                Active__c = true,
                Value__c = 'MOGAS (unleaded)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(mogasUnLeadedTypeB);

        LongForm_Element_Item__c monthTypeB = new LongForm_Element_Item__c(
                Name = '-MONTH-',
                Active__c = true,
                Value__c = 'month',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(monthTypeB);

        LongForm_Element_Item__c monthsTypeB = new LongForm_Element_Item__c(
                Name = '-MONTHS-',
                Active__c = true,
                Value__c = 'months',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(monthsTypeB);

        LongForm_Element_Item__c moreThanTypeB = new LongForm_Element_Item__c(
                Name = '-MORE THAN-',
                Active__c = true,
                Value__c = 'more than',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(moreThanTypeB);

        LongForm_Element_Item__c notMoreThanTypeB = new LongForm_Element_Item__c(
                Name = '-NOT MORE THAN-',
                Active__c = true,
                Value__c = 'not more than',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(notMoreThanTypeB);

        LongForm_Element_Item__c notSpeciFiedYetTypeB = new LongForm_Element_Item__c(
                Name = '-NOT SPECIFIED YET-',
                Active__c = true,
                Value__c = 'Not specified yet',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(notSpeciFiedYetTypeB);

        LongForm_Element_Item__c onlyForTypeB = new LongForm_Element_Item__c(
                Name = '-ONLY FOR-',
                Active__c = true,
                Value__c = 'only for',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(onlyForTypeB);

        LongForm_Element_Item__c per1CardTypeB = new LongForm_Element_Item__c(
                Name = '-PER 1 CARD-',
                Active__c = true,
                Value__c = 'per 1 card',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(per1CardTypeB);

        LongForm_Element_Item__c per1MonthTypeB = new LongForm_Element_Item__c(
                Name = '-PER 1 MONTH-',
                Active__c = true,
                Value__c = 'per 1 month',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(per1MonthTypeB);

        LongForm_Element_Item__c perAccountCompanyTypeB = new LongForm_Element_Item__c(
                Name = '-PER ACCOUNT COMPANY-',
                Active__c = true,
                Value__c = 'per account\\company',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(perAccountCompanyTypeB);

        LongForm_Element_Item__c perTypeB = new LongForm_Element_Item__c(
                Name = '-PER-',
                Active__c = true,
                Value__c = 'per',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(perTypeB);

        LongForm_Element_Item__c percentTypeB = new LongForm_Element_Item__c(
                Name = '-PERCENT-',
                Active__c = true,
                Value__c = 'percent',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(percentTypeB);

        LongForm_Element_Item__c petrolTypeB = new LongForm_Element_Item__c(
                Name = '-PETROL-',
                Active__c = true,
                Value__c = 'Petrol',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(petrolTypeB);

        LongForm_Element_Item__c shellAllStationsTypeB = new LongForm_Element_Item__c(
                Name = '-SHELL ALL STATIONS-',
                Active__c = true,
                Value__c = 'Shell (All Stations)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(shellAllStationsTypeB);

        LongForm_Element_Item__c shellAndPartnersTypeB = new LongForm_Element_Item__c(
                Name = '-SHELL AND PARTNERS-',
                Active__c = true,
                Value__c = 'Shell & Partners',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(shellAndPartnersTypeB);

        LongForm_Element_Item__c shellHomeStationTypeB = new LongForm_Element_Item__c(
                Name = '-SHELL HOME STATION-',
                Active__c = true,
                Value__c = 'Shell (Home Station)',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(shellHomeStationTypeB);

        LongForm_Element_Item__c unlimitedTypeB = new LongForm_Element_Item__c(
                Name = '-UNLIMITED-',
                Active__c = true,
                Value__c = 'Unlimited',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(unlimitedTypeB);

        LongForm_Element_Item__c weekTypeB = new LongForm_Element_Item__c(
                Name = '-WEEK-',
                Active__c = true,
                Value__c = 'Week',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(weekTypeB);

        LongForm_Element_Item__c weeksTypeB = new LongForm_Element_Item__c(
                Name = '-WEEKS-',
                Active__c = true,
                Value__c = 'Weeks',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(weeksTypeB);

        LongForm_Element_Item__c yearTypeB = new LongForm_Element_Item__c(
                Name = '-YEAR-',
                Active__c = true,
                Value__c = 'Year',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(yearTypeB);

        LongForm_Element_Item__c yearsTypeB = new LongForm_Element_Item__c(
                Name = '-YEARS-',
                Active__c = true,
                Value__c = 'Year',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(yearsTypeB);

        LongForm_Element_Item__c alreadySelectedOfferMessageTypeB = new LongForm_Element_Item__c(
                Name = 'ALREADY SELECTED OFFER MESSAGE',
                Active__c = true,
                Value__c = 'You’ve chosen the Special Offer already',
                Type__c = 'Validation Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(alreadySelectedOfferMessageTypeB);

        LongForm_Element_Item__c cancelButtonTypeB = new LongForm_Element_Item__c(
                Name = 'CANCEL BUTTON',
                Active__c = true,
                Value__c = 'CANCEL',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(cancelButtonTypeB);

        LongForm_Element_Item__c chooseStationButtonTypeB = new LongForm_Element_Item__c(
                Name = 'CHOOSE STATION BUTTON',
                Active__c = true,
                Value__c = 'CHOOSE STATION...',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(chooseStationButtonTypeB);

        LongForm_Element_Item__c confirmStationButtonTypeB = new LongForm_Element_Item__c(
                Name = 'CONFIRM STATION BUTTON',
                Active__c = true,
                Value__c = 'I WANT IT',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(confirmStationButtonTypeB);

        LongForm_Element_Item__c detailsHeadingTypeB = new LongForm_Element_Item__c(
                Name = 'DETAILS HEADING',
                Active__c = true,
                Value__c = 'Details',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(detailsHeadingTypeB);

        LongForm_Element_Item__c discountTypeB = new LongForm_Element_Item__c(
                Name = 'DISCOUNT',
                Active__c = true,
                Value__c = 'Discount:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(discountTypeB);

        LongForm_Element_Item__c discountLocationTypeB = new LongForm_Element_Item__c(
                Name = 'DISCOUNT LOCATION',
                Active__c = true,
                Value__c = 'at any Shell station',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(discountLocationTypeB);

        LongForm_Element_Item__c editButtonTypeB = new LongForm_Element_Item__c(
                Name = 'EDIT BUTTON',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(editButtonTypeB);

        LongForm_Element_Item__c favouriteStationHeadingTypeB = new LongForm_Element_Item__c(
                Name = 'FAVOURITE STATION HEADING',
                Active__c = true,
                Value__c = 'Favourite station:',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(favouriteStationHeadingTypeB);

        LongForm_Element_Item__c fuelTypeB = new LongForm_Element_Item__c(
                Name = 'FUEL TYPE',
                Active__c = true,
                Value__c = 'Fuel Type:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(fuelTypeB);

        LongForm_Element_Item__c geographyTypeB = new LongForm_Element_Item__c(
                Name = 'GEOGRAPHY',
                Active__c = true,
                Value__c = 'Geography:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(geographyTypeB);

        LongForm_Element_Item__c locatorNoDataMessageTypeB = new LongForm_Element_Item__c(
                Name = 'LOCATOR NO DATA MESSAGE',
                Active__c = true,
                Value__c = 'Sorry, nothing is found here. Try another address',
                Type__c = 'Validation Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(locatorNoDataMessageTypeB);

        LongForm_Element_Item__c locatorUrlTypeB = new LongForm_Element_Item__c(
                Name = 'LOCATOR URL',
                Active__c = true,
                Value__c = 'https://de.eurolocator-v3.transitcard.ru/locator/?product=4&mode=choose-station&address=',
                Type__c = 'URL',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(locatorUrlTypeB);

        LongForm_Element_Item__c locatorWrongAddressMessageTypeB = new LongForm_Element_Item__c(
                Name = 'LOCATOR WRONG ADDRESS MESSAGE',
                Active__c = true,
                Value__c = 'Sorry, you use incorrect address. Try another address',
                Type__c = 'Validation Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(locatorWrongAddressMessageTypeB);

        LongForm_Element_Item__c offerDescriptionTypeB = new LongForm_Element_Item__c(
                Name = 'OFFER DESCRIPTION',
                Active__c = true,
                Value__c = 'Flexibility is a great thing! We grant you a special price on pumping at any Shell station at any moment.',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(offerDescriptionTypeB);

        LongForm_Element_Item__c offerNameTypeB = new LongForm_Element_Item__c(
                Name = 'OFFER NAME',
                Active__c = true,
                Value__c = 'All Shell’s discount',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(offerNameTypeB);

        LongForm_Element_Item__c removeOfferButtonTypeB = new LongForm_Element_Item__c(
                Name = 'REMOVE OFFER BUTTON',
                Active__c = true,
                Value__c = 'REMOVE',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(removeOfferButtonTypeB);

        LongForm_Element_Item__c stationTypeB = new LongForm_Element_Item__c(
                Name = 'STATION',
                Active__c = true,
                Value__c = 'Station:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(stationTypeB);

        LongForm_Element_Item__c timeTypeB = new LongForm_Element_Item__c(
                Name = 'TIME',
                Active__c = true,
                Value__c = 'Time:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(timeTypeB);

        LongForm_Element_Item__c volumeTypeB = new LongForm_Element_Item__c(
                Name = 'VOLUME',
                Active__c = true,
                Value__c = 'Volume:',
                Type__c = 'Label',
                Long_Form_Element__c = specialOfferInboundTypeB.Id
        );
        specialOfferElementItemsList.add(volumeTypeB);

        // BACK BUTTON
        LongForm_Element_Item__c backButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'BACK',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferBackButton.Id
        );
        specialOfferElementItemsList.add(backButtonName);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Free Text',
                Long_Form_Element__c = specialOfferContinueButton.Id
        );
        specialOfferElementItemsList.add(continueButtonName);

        // LOCATOR URL
        LongForm_Element_Item__c locatorUrlBasic = new LongForm_Element_Item__c(
                Name = 'BASIC',
                Active__c = true,
                Value__c = 'https://eurolocator.fleetcor.de/?product=4&mode=choose-station&address=',
                Type__c = 'URL',
                Long_Form_Element__c = specialOfferLocatorUrl.Id
        );
        specialOfferElementItemsList.add(locatorUrlBasic);

        LongForm_Element_Item__c locatorUrlZoomParam = new LongForm_Element_Item__c(
                Name = 'ZOOM PARAM',
                Active__c = true,
                Value__c = '&zoom=14',
                Type__c = 'URL',
                Long_Form_Element__c = specialOfferLocatorUrl.Id
        );
        specialOfferElementItemsList.add(locatorUrlZoomParam);

        insert specialOfferElementItemsList;

        //Offer
        List<LongForm_Offer__c> specialOfferInboundList = new List<LongForm_Offer__c>();

        LongForm_Offer__c offerInboundTypeC = new LongForm_Offer__c(
                Country__c = country,
                LongForm_Element__c = specialOfferInboundTypeC.Id,
                LongForm_Element_Mobile__c = specialOfferInboundTypeC.Id,
                Product__c = product1,
                Channel__c = channel
        );
        specialOfferInboundList.add(offerInboundTypeC);

        LongForm_Offer__c offerInboundTypeB = new LongForm_Offer__c(
                Country__c = country,
                LongForm_Element__c = specialOfferInboundTypeB.Id,
                LongForm_Element_Mobile__c = specialOfferInboundTypeB.Id,
                Product__c = product2,
                Channel__c = channel
        );
        specialOfferInboundList.add(offerInboundTypeB);

        insert specialOfferInboundList;

        List<LongForm_Offer_Item__c> specialOfferItemInboundList = new List<LongForm_Offer_Item__c>();

        LongForm_Offer_Item__c offerItemInboundTypeC = new LongForm_Offer_Item__c(
                Long_Form_Offer__c = offerInboundTypeC.Id,
                Type__c = 'Transaction Shell Home Fuel; Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Currency__c = '€',
                Rate__c = -0.030,
                Rate_Per__c = '1 Liter',
                Apply_Filter__c = true,
                Applied_For_Filter__c = 'Card',
                Basic_Filter__c = 'Fuel + Volume',
                Volume_Operator_Filter__c = 'more than [X] liters per 1 month',
                Volume_Amount_Filter__c = 400,
                Time_Filter__c = 'Unlimited',
                Fuel_Type_Filter__c = 'Diesel (all types); Gas Fuel (all types)',
                Fuel_Exception_Filter__c = 'Diesel (V-Power)',
                Check_Fuel_Consumption__c = false,
                Geography__c = 'Germany & Europe',
                Stations__c = 'Shell (Home Station)'
        );
        specialOfferItemInboundList.add(offerItemInboundTypeC);

        LongForm_Offer_Item__c offerItemInboundTypeB = new LongForm_Offer_Item__c(
                Long_Form_Offer__c = offerInboundTypeB.Id,
                Type__c = 'Transaction Shell Home Fuel; Transaction Shell Home Non-Fuel; Transaction Shell Non-Home Fuel; Transaction Shell Non-Home Non-Fuel; Transaction Shell Partner Fuel; Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Currency__c = '€',
                Rate__c = -0.020,
                Rate_Per__c = '1 Liter',
                Apply_Filter__c = true,
                Applied_For_Filter__c = 'Card',
                Basic_Filter__c = 'Fuel',
                Volume_Operator_Filter__c = 'Unlimited',
                Time_Filter__c = 'Unlimited',
                Fuel_Type_Filter__c = 'Diesel (all types); Gas Fuel (all types)',
                Fuel_Exception_Filter__c = 'Diesel (V-Power)',
                Check_Fuel_Consumption__c = true,
                Geography__c = 'Germany & Europe',
                Stations__c = 'Shell (Home Station)'
        );
        specialOfferItemInboundList.add(offerItemInboundTypeB);

        insert specialOfferItemInboundList;

        //LongForm Fleetcor Product
        List<LongForm_Fleetcor_Product__c> longFormFleetcorProductList = new List<LongForm_Fleetcor_Product__c>();

        // TYPE C
        LongForm_Fleetcor_Product__c nationalPartnersTypeCProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYPE C OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = nationalPartners.Id,
                Long_Form_Offer__c = offerInboundTypeC.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(nationalPartnersTypeCProduct);

        LongForm_Fleetcor_Product__c internationalNotPartnersTypeCProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYPE C OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Long_Form_Offer__c = offerInboundTypeC.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(internationalNotPartnersTypeCProduct);

        LongForm_Fleetcor_Product__c internationalPartnersTypeCProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYPE C OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Long_Form_Offer__c = offerInboundTypeC.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(internationalPartnersTypeCProduct);

        LongForm_Fleetcor_Product__c nationalNotPartnersTypeCProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYPE C OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Long_Form_Offer__c = offerInboundTypeC.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(nationalNotPartnersTypeCProduct);

        // TYPE B
        LongForm_Fleetcor_Product__c nationalPartnersTypeBProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYP B OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = nationalPartners.Id,
                Long_Form_Offer__c = offerInboundTypeB.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(nationalPartnersTypeBProduct);

        LongForm_Fleetcor_Product__c internationalNotPartnersTypeBProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYP B OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Long_Form_Offer__c = offerInboundTypeB.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(internationalNotPartnersTypeBProduct);

        LongForm_Fleetcor_Product__c internationalPartnersTypeBProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYP B OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Long_Form_Offer__c = offerInboundTypeB.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(internationalPartnersTypeBProduct);

        LongForm_Fleetcor_Product__c nationalNotPartnersTypeBProduct = new LongForm_Fleetcor_Product__c(
                Name = 'INBOUND TYP B OFFER #1',
                Active__c = true,
                Channel__c = channel,
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Long_Form_Offer__c = offerInboundTypeB.Id,
                Country__c = country
        );
        longFormFleetcorProductList.add(nationalNotPartnersTypeBProduct);

        insert longFormFleetcorProductList;
    }


    /*******************************************************************************
    *  Name            : createCardConfigurationTechnicalParameters()
    *  Summary         : Create card configaration special offers
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCardConfigurationTechnicalParameters(String deviceView) {
        LongForm_Page__c cardConfigurationTechnicalParameters = new LongForm_Page__c(
                Name = 'CARD CONFIGURATION. TECHNICAL PARAMETERS',
                Title__c = 'E2E Technical parameters',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep2.Id
        );
        insert cardConfigurationTechnicalParameters;

        List<LongForm_Element__c> technicalParametersElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c whatToEmbossHeading = new LongForm_Element__c(
                Name = 'WHAT TO EMBOSS HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(whatToEmbossHeading);

        LongForm_Element__c driverOrCarField = new LongForm_Element__c(
                Name = 'DRIVER OR CAR FIELD',
                Type__c = 'Text Field',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(driverOrCarField);

        LongForm_Element__c companyName = new LongForm_Element__c(
                Name = 'COMPANY NAME',
                Type__c = 'Text Field',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(companyName);

        LongForm_Element__c editButton = new LongForm_Element__c(
                Name = 'EDIT BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(editButton);

        LongForm_Element__c whatCardTypeHeading = new LongForm_Element__c(
                Name = 'WHAT CARD TYPE HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(whatCardTypeHeading);

        LongForm_Element__c typeOfCar = new LongForm_Element__c(
                Name = 'TYPE OF CAR',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(typeOfCar);

        LongForm_Element__c odometerOptions = new LongForm_Element__c(
                Name = 'ODOMETER OPTIONS',
                Type__c = 'Slider Field',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(odometerOptions);

        LongForm_Element__c cardNumber = new LongForm_Element__c(
                Name = 'CARD NUMBER',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(cardNumber);

        LongForm_Element__c technicalParamHeading = new LongForm_Element__c(
                Name = 'TECHNICAL PARAM HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(technicalParamHeading);

        LongForm_Element__c saveParamsButton = new LongForm_Element__c(
                Name = 'SAVE PARAMS BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(saveParamsButton);

        LongForm_Element__c backButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(backButton);

        LongForm_Element__c continueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = cardConfigurationTechnicalParameters.Id
        );
        technicalParametersElementsList.add(continueButton);

        insert technicalParametersElementsList;

        List<LongForm_Element_Item__c> technicalParametersElementItemsList = new List<LongForm_Element_Item__c>();
        // WHAT TO EMBOSS HEADING
        LongForm_Element_Item__c embossHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'What to emboss on Card #',
                Type__c = 'Free Text',
                Long_Form_Element__c = whatToEmbossHeading.Id
        );
        technicalParametersElementItemsList.add(embossHeadingItem);

        LongForm_Element_Item__c embossSubheadingItem = new LongForm_Element_Item__c(
                Name = 'SUBHEADING',
                Active__c = true,
                Value__c = 'In every variation we emboss Company name',
                Type__c = 'Free Text',
                Long_Form_Element__c = whatToEmbossHeading.Id
        );
        technicalParametersElementItemsList.add(embossSubheadingItem);

        LongForm_Element_Item__c questionMarkHeading = new LongForm_Element_Item__c(
                Name = '-?-',
                Active__c = true,
                Value__c = '?',
                Type__c = 'Free Text',
                Long_Form_Element__c = whatToEmbossHeading.Id
        );
        technicalParametersElementItemsList.add(questionMarkHeading);

        // DRIVER OR CAR FIELD
        LongForm_Element_Item__c driverOrCardHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'For security reasons, the driver name embossed on card will be checked during pumping by station staff.It has to match the signature on the back of the card. The usage of this card by another person is not allowed. For security reasons, the vehicle registration number embossed on card will be checked by station staff. It has to match a car’s number, which is pumped. The usage of this card with another car is not allowed.',
                Type__c = 'Help Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        technicalParametersElementItemsList.add(driverOrCardHelp);

        LongForm_Element_Item__c driverOrCardWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Some message',
                Type__c = 'Validation Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        technicalParametersElementItemsList.add(driverOrCardWarnMessage);

        LongForm_Element_Item__c driverButton = new LongForm_Element_Item__c(
                Name = 'DRIVER BUTTON',
                Active__c = true,
                Value__c = 'Driver name',
                Type__c = 'Free Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        technicalParametersElementItemsList.add(driverButton);

        LongForm_Element_Item__c carButton = new LongForm_Element_Item__c(
                Name = 'CAR BUTTON',
                Active__c = true,
                Value__c = 'Car number',
                Type__c = 'Free Text',
                Long_Form_Element__c = driverOrCarField.Id
        );
        technicalParametersElementItemsList.add(carButton);

        LongForm_Element_Item__c buttonDefaultValue = new LongForm_Element_Item__c(
                Name = 'BUTTON DEFAULT VALUE',
                Active__c = true,
                Value__c = 'driver-name',
                Type__c = 'Default Value',
                Long_Form_Element__c = driverOrCarField.Id
        );
        technicalParametersElementItemsList.add(buttonDefaultValue);

        LongForm_Element_Item__c driverOrCarLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Enter one of options',
                Type__c = 'Label',
                Long_Form_Element__c = driverOrCarField.Id
        );
        technicalParametersElementItemsList.add(driverOrCarLabel);

        LongForm_Element_Item__c driverOrCarAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = driverOrCarField.Id
        );
        technicalParametersElementItemsList.add(driverOrCarAsterisk);

        // COMPANY NAME
        LongForm_Element_Item__c companyNameLabel1 = new LongForm_Element_Item__c(
                Name = 'LABEL 1',
                Active__c = true,
                Value__c = 'Company name',
                Type__c = 'Label',
                Long_Form_Element__c = companyName.Id
        );
        technicalParametersElementItemsList.add(companyNameLabel1);

        LongForm_Element_Item__c companyNameLabel2 = new LongForm_Element_Item__c(
                Name = 'LABEL 2',
                Active__c = true,
                Value__c = '(all cards)',
                Type__c = 'Label',
                Long_Form_Element__c = companyName.Id
        );
        technicalParametersElementItemsList.add(companyNameLabel2);

        LongForm_Element_Item__c companyNameAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = companyName.Id
        );
        technicalParametersElementItemsList.add(companyNameAsterisk);

        LongForm_Element_Item__c companyNameWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Some message',
                Type__c = 'Validation Text',
                Long_Form_Element__c = companyName.Id
        );
        technicalParametersElementItemsList.add(companyNameWarnMessage);

        LongForm_Element_Item__c companyNameRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'We able to emboss just 25 symbols of the company name at the card',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyName.Id
        );
        technicalParametersElementItemsList.add(companyNameRemark);

        // EDIT BUTTON
        LongForm_Element_Item__c editButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'edit',
                Type__c = 'Free Text',
                Long_Form_Element__c = editButton.Id
        );
        technicalParametersElementItemsList.add(editButtonName);

        // WHAT CARD TYPE HEADING
        LongForm_Element_Item__c whatCardTypeHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'What type of car will this card be used with?',
                Type__c = 'Free Text',
                Long_Form_Element__c = whatCardTypeHeading.Id
        );
        technicalParametersElementItemsList.add(whatCardTypeHeadingItem);

        // TYPE OF CAR
        LongForm_Element_Item__c typeOfCarLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Type of car',
                Type__c = 'Label',
                Long_Form_Element__c = typeOfCar.Id
        );
        technicalParametersElementItemsList.add(typeOfCarLabel);

        LongForm_Element_Item__c typeOfCarPkwButton = new LongForm_Element_Item__c(
                Name = 'PKW BUTTON',
                Active__c = true,
                Value__c = 'PKW',
                Type__c = 'Free Text',
                Long_Form_Element__c = typeOfCar.Id
        );
        technicalParametersElementItemsList.add(typeOfCarPkwButton);

        LongForm_Element_Item__c typeOfCarLkwButton = new LongForm_Element_Item__c(
                Name = 'LKW BUTTON',
                Active__c = true,
                Value__c = 'LKW',
                Type__c = 'Free Text',
                Long_Form_Element__c = typeOfCar.Id
        );
        technicalParametersElementItemsList.add(typeOfCarLkwButton);

        LongForm_Element_Item__c typeOfCarDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'PKW',
                Type__c = 'Default Value',
                Long_Form_Element__c = typeOfCar.Id
        );
        technicalParametersElementItemsList.add(typeOfCarDefaultValue);

        // ODOMETER OPTIONS
        LongForm_Element_Item__c odometerOptionsDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = odometerOptions.Id
        );
        technicalParametersElementItemsList.add(odometerOptionsDefaultValue);

        LongForm_Element_Item__c odometerOptionsLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Odometer options',
                Type__c = 'Free Text',
                Long_Form_Element__c = odometerOptions.Id
        );
        technicalParametersElementItemsList.add(odometerOptionsLabel);

        LongForm_Element_Item__c odometerOptionsRemark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore',
                Type__c = 'Label',
                Long_Form_Element__c = odometerOptions.Id
        );
        technicalParametersElementItemsList.add(odometerOptionsRemark);

        LongForm_Element_Item__c odometerOptionsHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Some text',
                Type__c = 'Help Text',
                Long_Form_Element__c = odometerOptions.Id
        );
        technicalParametersElementItemsList.add(odometerOptionsHelp);

        // CARD NUMBER
        LongForm_Element_Item__c cardNumberItem = new LongForm_Element_Item__c(
                Name = 'NUMBER',
                Active__c = true,
                Value__c = '1111 2222 3333 4444 023',
                Type__c = 'Help Text',
                Long_Form_Element__c = cardNumber.Id
        );
        technicalParametersElementItemsList.add(cardNumberItem);

        // TECHNICAL PARAM HEADING
        LongForm_Element_Item__c technicalParamHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Technical parameters for Card #',
                Type__c = 'Free Text',
                Long_Form_Element__c = technicalParamHeading.Id
        );
        technicalParametersElementItemsList.add(technicalParamHeadingItem);

        // SAVE PARAMS BUTTON
        LongForm_Element_Item__c saveParamsButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'SAVE PARAMS',
                Type__c = 'Free Text',
                Long_Form_Element__c = saveParamsButton.Id
        );
        technicalParametersElementItemsList.add(saveParamsButtonName);

        // BACK BUTTON
        LongForm_Element_Item__c backButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'BACK',
                Type__c = 'Free Text',
                Long_Form_Element__c = backButton.Id
        );
        technicalParametersElementItemsList.add(backButtonName);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Free Text',
                Long_Form_Element__c = continueButton.Id
        );
        technicalParametersElementItemsList.add(continueButtonName);

        LongForm_Element_Item__c continueButtonMobileName = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Label',
                Long_Form_Element__c = continueButton.Id
        );
        technicalParametersElementItemsList.add(continueButtonMobileName);

        insert technicalParametersElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createCardConfigurationInputVatId()
    *  Summary         : Create Input Vat Id page
    *  CreatedDate     : 21/06/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCardConfigurationInputVatId(String deviceView) {
        LongForm_Page__c inputVatId = new LongForm_Page__c(
                Name = 'CARD CONFIGURATION. INPUT VAT ID',
                Title__c = 'E2E VAT Number',
                System_Error__c = 'Some error',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep2.Id
        );
        insert inputVatId;

        List<LongForm_Element__c> inputVatIdElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = inputVatId.Id
        );
        inputVatIdElementsList.add(topHeading);

        LongForm_Element__c continueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = inputVatId.Id
        );
        inputVatIdElementsList.add(continueButton);

        LongForm_Element__c vatNumber = new LongForm_Element__c(
                Name = 'VAT NUMBER',
                Type__c = 'Text Field',
                Long_Form_Page__c = inputVatId.Id
        );
        inputVatIdElementsList.add(vatNumber);

        insert inputVatIdElementsList;

        List<LongForm_Element_Item__c> inputVatIdElementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c headingElemItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Bitte geben Sie Ihre Umsatzsteuer-ID ein',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        inputVatIdElementItemsList.add(headingElemItem);

        LongForm_Element_Item__c subheadingElemItem = new LongForm_Element_Item__c(
                Name = 'SUBHEADING',
                Active__c = true,
                Value__c = 'Um die Internationale Karte nutzen zu können, geben Sie bitte Ihre Umsatzsteuer ID an',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        inputVatIdElementItemsList.add(subheadingElemItem);

        // CONTINUE BUTTON
        LongForm_Element_Item__c valueContinueButton = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Weiter',
                Type__c = 'Label',
                Long_Form_Element__c = continueButton.Id
        );
        inputVatIdElementItemsList.add(valueContinueButton);

        // VAT NUMBER
        LongForm_Element_Item__c vatNumberLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Umsatzsteuer-ID',
                Type__c = 'Label',
                Long_Form_Element__c = vatNumber.Id
        );
        inputVatIdElementItemsList.add(vatNumberLabel);

        LongForm_Element_Item__c vatNumberAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = vatNumber.Id
        );
        inputVatIdElementItemsList.add(vatNumberAsterisk);

        LongForm_Element_Item__c vatNumberDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = vatNumber.Id
        );
        inputVatIdElementItemsList.add(vatNumberDefaultValue);

        LongForm_Element_Item__c vatNumberPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'DE123456789',
                Type__c = 'Placeholder',
                Long_Form_Element__c = vatNumber.Id
        );
        inputVatIdElementItemsList.add(vatNumberPlaceholder);

        LongForm_Element_Item__c vatNumberWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Bitte tragen Sie Ihre Umsatzsteuer ID in dem richtigen Format ein. z.B. DE123456789.',
                Type__c = 'Validation Text',
                Long_Form_Element__c = vatNumber.Id
        );
        inputVatIdElementItemsList.add(vatNumberWarnMessage);

        LongForm_Element_Item__c vatNumberHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Die Umsatzsteuer ID ist ein eindeutige Zahl, welche für die Mehrwertsteuer verwendet wird. Diese besteht aus der Länderkennung (DE+ Neun Ziffern). z.B. DE123456789.',
                Type__c = 'Help Text',
                Long_Form_Element__c = vatNumber.Id
        );
        inputVatIdElementItemsList.add(vatNumberHelp);

        insert inputVatIdElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createAdditionalPage()
    *  Summary         : Create additional page
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createAdditionalPage(String deviceView) {
        LongForm_Page__c additionalPage = new LongForm_Page__c(
                Name = 'ADDITIONAL',
                Title__c = 'Additional',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep3.Id
        );
        insert additionalPage;

        List<LongForm_Element__c> additionalElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c co2Heading = new LongForm_Element__c(
                Name = 'CO2 HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(co2Heading);

        LongForm_Element__c co2Subheading = new LongForm_Element__c(
                Name = 'CO2 SUBHEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(co2Subheading);

        LongForm_Element__c co2Description = new LongForm_Element__c(
                Name = 'CO2 DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(co2Description);

        LongForm_Element__c co2Image = new LongForm_Element__c(
                Name = 'CO2 IMAGE',
                Type__c = 'Image',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(co2Image);

        LongForm_Element__c co2TakeCare = new LongForm_Element__c(
                Name = 'CO2 TAKE CARE',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(co2TakeCare);

        LongForm_Element__c orderCardsButton = new LongForm_Element__c(
                Name = 'ORDER CARDS BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(orderCardsButton);

        LongForm_Element__c backButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(backButton);

        LongForm_Element__c additionalService1 = new LongForm_Element__c(
                Name = 'ADDITIONAL SERVICE #1',
                Type__c = ' Text Block',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(additionalService1);

        LongForm_Element__c additionalService2 = new LongForm_Element__c(
                Name = 'ADDITIONAL SERVICE #2',
                Type__c = ' Text Block',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(additionalService2);

        LongForm_Element__c additionalService3 = new LongForm_Element__c(
                Name = 'ADDITIONAL SERVICE #3',
                Type__c = ' Text Block',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(additionalService3);

        LongForm_Element__c additionalPaperInvoice = new LongForm_Element__c(
                Name = 'PAPER INVOICE',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = additionalPage.Id
        );
        additionalElementsList.add(additionalPaperInvoice);

        insert additionalElementsList;

        List<LongForm_Element_Item__c> additionalElementItemsList = new List<LongForm_Element_Item__c>();

        // CO2 HEADING
        LongForm_Element_Item__c co2HeadingValue = new LongForm_Element_Item__c(
                Name = 'HEADING VALUE',
                Active__c = true,
                Value__c = 'Take care of Nature: CO2 compensation',
                Type__c = 'Free Text',
                Long_Form_Element__c = co2Heading.Id
        );
        additionalElementItemsList.add(co2HeadingValue);

        // CO2 SUBHEADING
        LongForm_Element_Item__c co2SubheadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Only 1 % of all fuel transactions to protect environment',
                Type__c = 'Free Text',
                Long_Form_Element__c = co2Subheading.Id
        );
        additionalElementItemsList.add(co2SubheadingValue);

        LongForm_Element_Item__c co2SubheadingHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'If you tick this box, you are agreeing to pay an additional 1% of your invoice amount to join us in investing in projects which have been proven to reduce carbon.',
                Type__c = 'Help Text',
                Long_Form_Element__c = co2Subheading.Id
        );
        additionalElementItemsList.add(co2SubheadingHelp);

        // CO2 DESCRIPTION
        LongForm_Element_Item__c co2DescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'A simple way of reducing your CO2 emissions by planting new trees and generating alternative energy sources and supporting other carbon-reducing projects.',
                Type__c = 'Free Text',
                Long_Form_Element__c = co2Description.Id
        );
        additionalElementItemsList.add(co2DescriptionValue);

        // CO2 IMAGE
        LongForm_Element_Item__c co2ImageUrl = new LongForm_Element_Item__c(
                Name = 'URL',
                Active__c = true,
                Value__c = 'https://c.cs89.visual.force.com/resource/1521206933000/e2e_images/eco1.png',
                Type__c = 'URL',
                Long_Form_Element__c = co2Image.Id
        );
        additionalElementItemsList.add(co2ImageUrl);

        // CO2 TAKE CARE
        LongForm_Element_Item__c co2TakeCareValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = co2TakeCare.Id
        );
        additionalElementItemsList.add(co2TakeCareValue);

        LongForm_Element_Item__c co2TakeCareLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Yes, I would like to protect the environment with FLEETCOR',
                Type__c = 'Label',
                Long_Form_Element__c = co2TakeCare.Id
        );
        additionalElementItemsList.add(co2TakeCareLabel);

        LongForm_Element_Item__c co2TakeCareSublabel = new LongForm_Element_Item__c(
                Name = 'SUBLABEL',
                Active__c = true,
                Value__c = 'and I agree to pay an additional 1% of my invoice amount to contribute to the program.',
                Type__c = 'Label',
                Long_Form_Element__c = co2TakeCare.Id
        );
        additionalElementItemsList.add(co2TakeCareSublabel);

        // ORDER CARDS BUTTON
        LongForm_Element_Item__c buttonOrder = new LongForm_Element_Item__c(
                Name = '-ORDER-',
                Active__c = true,
                Value__c = 'ORDER',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderCardsButton.Id
        );
        additionalElementItemsList.add(buttonOrder);

        LongForm_Element_Item__c buttonCard = new LongForm_Element_Item__c(
                Name = '-CARD-',
                Active__c = true,
                Value__c = 'CARD',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderCardsButton.Id
        );
        additionalElementItemsList.add(buttonCard);

        LongForm_Element_Item__c buttonCards = new LongForm_Element_Item__c(
                Name = '-CARDS-',
                Active__c = true,
                Value__c = 'CARDS',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderCardsButton.Id
        );
        additionalElementItemsList.add(buttonCards);

        // BACK BUTTON
        LongForm_Element_Item__c orderCardsButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'CANCEL',
                Type__c = 'Free Text',
                Long_Form_Element__c = orderCardsButton.Id
        );
        additionalElementItemsList.add(orderCardsButtonName);

        // ADDITIONAL SERVICE #1
        LongForm_Element_Item__c agreementCheckboxValue = new LongForm_Element_Item__c(
                Name = 'AGREEMENT CHECKBOX VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = additionalService1.Id
        );
        additionalElementItemsList.add(agreementCheckboxValue);

        LongForm_Element_Item__c tcAgreement = new LongForm_Element_Item__c(
                Name = 'TC AGREEMENT CHECKBOX VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = additionalService1.Id
        );
        additionalElementItemsList.add(tcAgreement);

        LongForm_Element_Item__c behalfOfCompany = new LongForm_Element_Item__c(
                Name = 'BEHALF OF COMPANY CHECKBOX VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = additionalService1.Id
        );
        additionalElementItemsList.add(behalfOfCompany);

        // ADDITIONAL SERVICE #2
        LongForm_Element_Item__c vatAgreementCheckboxValue = new LongForm_Element_Item__c(
                Name = 'VAT AGREEMENT CHECKBOX VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = additionalService2.Id
        );
        additionalElementItemsList.add(vatAgreementCheckboxValue);

        LongForm_Element_Item__c showService = new LongForm_Element_Item__c(
                Name = 'SHOW SERVICE',
                Active__c = true,
                Value__c = 'true',
                Type__c = 'Free Text',
                Long_Form_Element__c = additionalService2.Id
        );
        additionalElementItemsList.add(showService);

        LongForm_Element_Item__c vatTcAgreementCheckboxValue = new LongForm_Element_Item__c(
                Name = 'VAT TC AGREEMENT CHECKBOX VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = additionalService2.Id
        );
        additionalElementItemsList.add(vatTcAgreementCheckboxValue);

        LongForm_Element_Item__c tcDownloadUrl = new LongForm_Element_Item__c(
                Name = 'TC DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = additionalService2.Id
        );
        additionalElementItemsList.add(tcDownloadUrl);

        LongForm_Element_Item__c tcIframeUrl = new LongForm_Element_Item__c(
                Name = 'TC IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = additionalService2.Id
        );
        additionalElementItemsList.add(tcIframeUrl);

        // ADDITIONAL SERVICE #3
        LongForm_Element_Item__c aggrementCheckbox3 = new LongForm_Element_Item__c(
                Name = 'AGREEMENT CHECKBOX VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'URL',
                Long_Form_Element__c = additionalService3.Id
        );
        additionalElementItemsList.add(aggrementCheckbox3);

        LongForm_Element_Item__c showService3 = new LongForm_Element_Item__c(
                Name = 'SHOW SERVICE',
                Active__c = true,
                Value__c = 'true',
                Type__c = 'Free Text',
                Long_Form_Element__c = additionalService3.Id
        );
        additionalElementItemsList.add(showService3);

        // PAPER INVOICE
        LongForm_Element_Item__c paperInvoiceValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = additionalPaperInvoice.Id
        );
        additionalElementItemsList.add(paperInvoiceValue);

        insert additionalElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createAdditionalDateOfBirth(String deviceView)
    *  Summary         : Create additional date of birth page
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createAdditionalDateOfBirth(String deviceView) {
        LongForm_Page__c dateOfBirthPage = new LongForm_Page__c(
                Name = 'ADDITIONAL. ENTER DATE OF BIRTH',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert dateOfBirthPage;

        List<LongForm_Element__c> dateOfBirthElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c dateOfBirthElement = new LongForm_Element__c(
                Name = 'DATE OF BIRTH',
                Type__c = 'Text Field',
                Long_Form_Page__c = dateOfBirthPage.Id
        );
        dateOfBirthElementsList.add(dateOfBirthElement);

        LongForm_Element__c continueButtonElement = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = dateOfBirthPage.Id
        );
        dateOfBirthElementsList.add(continueButtonElement);

        LongForm_Element__c backButtonElement = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = dateOfBirthPage.Id
        );
        dateOfBirthElementsList.add(backButtonElement);

        insert dateOfBirthElementsList;

        List<LongForm_Element_Item__c> dateOfBirthElementItemList = new List<LongForm_Element_Item__c>();
        // DATE OF BIRTH
        LongForm_Element_Item__c dateOfBirthDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = dateOfBirthElement.Id
        );
        dateOfBirthElementItemList.add(dateOfBirthDefaultValue);
        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Dalej',
                Type__c = 'Label',
                Long_Form_Element__c = continueButtonElement.Id
        );
        dateOfBirthElementItemList.add(continueButtonLabel);
        // BACK BUTTON
        LongForm_Element_Item__c backButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Wstecz',
                Type__c = 'Label',
                Long_Form_Element__c = backButtonElement.Id
        );
        dateOfBirthElementItemList.add(backButtonLabel);

        insert dateOfBirthElementItemList;
    }


    /*******************************************************************************
    *  Name            : createDocuments(String deviceView)
    *  Summary         : Create documents page
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createDocuments(String deviceView) {
        LongForm_Page__c documentsPage = new LongForm_Page__c(
                Name = 'DOCUMENTS',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert documentsPage;

        List<LongForm_Element__c> documentsElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c paperInvoice = new LongForm_Element__c(
                Name = 'PAPER INVOICE',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = documentsPage.Id
        );
        documentsElementsList.add(paperInvoice);

        LongForm_Element__c documentsBlock = new LongForm_Element__c(
                Name = 'DOCUMENTS BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = documentsPage.Id
        );
        documentsElementsList.add(documentsBlock);

        LongForm_Element__c backButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = documentsPage.Id
        );
        documentsElementsList.add(backButton);

        LongForm_Element__c continueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = documentsPage.Id
        );
        documentsElementsList.add(continueButton);

        LongForm_Element__c decision = new LongForm_Element__c(
                Name = 'DECISION',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = documentsPage.Id
        );
        documentsElementsList.add(decision);

        LongForm_Element__c acceptTermConditions = new LongForm_Element__c(
                Name = 'ACCEPT TERMS AND CONDITIONS',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = documentsPage.Id
        );
        documentsElementsList.add(acceptTermConditions);

        LongForm_Element__c pricing = new LongForm_Element__c(
                Name = 'PRICING',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = documentsPage.Id
        );
        documentsElementsList.add(pricing);

        insert documentsElementsList;

        List<LongForm_Element_Item__c> documentsElementItemsList = new List<LongForm_Element_Item__c>();
        // PAPER INVOICE
        LongForm_Element_Item__c paperInvoiceValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'true',
                Type__c = 'Default Value',
                Long_Form_Element__c = paperInvoice.Id
        );
        documentsElementItemsList.add(paperInvoiceValue);
        // DOCUMENTS BLOCK
        LongForm_Element_Item__c documentsIframeUrl = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = documentsBlock.Id
        );
        documentsElementItemsList.add(documentsIframeUrl);

        LongForm_Element_Item__c documentsDownloadUrl = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = documentsBlock.Id
        );
        documentsElementItemsList.add(documentsDownloadUrl);
        // BACK BUTTON
        LongForm_Element_Item__c backButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Wstecz',
                Type__c = 'Label',
                Long_Form_Element__c = backButton.Id
        );
        documentsElementItemsList.add(backButtonLabel);
        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Podpisz',
                Type__c = 'Label',
                Long_Form_Element__c = continueButton.Id
        );
        documentsElementItemsList.add(continueButtonLabel);
        // DECISION
        LongForm_Element_Item__c decisionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = decision.Id
        );
        documentsElementItemsList.add(decisionValue);
        // ACCEPT TERMS AND CONDITIONS
        LongForm_Element_Item__c termConditionsValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        documentsElementItemsList.add(termConditionsValue);

        LongForm_Element_Item__c termConditionsDownloadUrl = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        documentsElementItemsList.add(termConditionsDownloadUrl);

        LongForm_Element_Item__c termConditionsIframeUrl = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        documentsElementItemsList.add(termConditionsIframeUrl);
        // PRICING
        LongForm_Element_Item__c pricingUrl = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = pricing.Id
        );
        documentsElementItemsList.add(pricingUrl);

        LongForm_Element_Item__c iframeUrl = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = pricing.Id
        );
        documentsElementItemsList.add(iframeUrl);

        insert documentsElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createPaymentOptions()
    *  Summary         : Create payment options page
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createPaymentOptions(String deviceView) {
        LongForm_Page__c paymentOptionsPage = new LongForm_Page__c(
                Name = 'PAYMENT OPTIONS',
                Title__c = 'Payment options',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep4.Id
        );
        insert paymentOptionsPage;

        List<LongForm_Element__c> paymentOptionsElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c paymentMethodCards = new LongForm_Element__c(
                Name = 'PaymentMethod Cards',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(paymentMethodCards);

        LongForm_Element__c paymentMethodOnlineBank = new LongForm_Element__c(
                Name = 'PaymentMethod Online Bank',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(paymentMethodOnlineBank);

        LongForm_Element__c paymentOptionsButtonOn = new LongForm_Element__c(
                Name = 'BUTTON ON',
                Type__c = 'Button',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(paymentOptionsButtonOn);

        LongForm_Element__c paymentOptionsButtonOff = new LongForm_Element__c(
                Name = 'BUTTON OFF',
                Type__c = 'Button',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(paymentOptionsButtonOff);

        LongForm_Element__c ddHeading = new LongForm_Element__c(
                Name = 'DD HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(ddHeading);

        LongForm_Element__c billingPeriod = new LongForm_Element__c(
                Name = 'BILLING PERIOD',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(billingPeriod);

        LongForm_Element__c accountHolder = new LongForm_Element__c(
                Name = 'ACCOUNT HOLDER',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(accountHolder);

        LongForm_Element__c iban = new LongForm_Element__c(
                Name = 'IBAN',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(iban);

        LongForm_Element__c swift = new LongForm_Element__c(
                Name = 'SWIFT',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(swift);

        LongForm_Element__c formatInfo = new LongForm_Element__c(
                Name = 'FORMAT INFO',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(formatInfo);

        LongForm_Element__c paperInvoice = new LongForm_Element__c(
                Name = 'PAPER INVOICE',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(paperInvoice);

        LongForm_Element__c ddSepa = new LongForm_Element__c(
                Name = 'DD SEPA',
                Type__c = 'Text Block',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(ddSepa);

        LongForm_Element__c acceptSepa = new LongForm_Element__c(
                Name = 'ACCEPT SEPA',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(acceptSepa);

        LongForm_Element__c decision = new LongForm_Element__c(
                Name = 'DECISION',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(decision);

        LongForm_Element__c acceptTermConditions = new LongForm_Element__c(
                Name = 'ACCEPT TERM CONDITIONS',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(acceptTermConditions);

        LongForm_Element__c backButton = new LongForm_Element__c(
                Name = 'BACK BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(backButton);

        LongForm_Element__c continueButton = new LongForm_Element__c(
                Name = 'CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(continueButton);

        LongForm_Element__c banktransferHeading = new LongForm_Element__c(
                Name = 'BANKTRANSFER HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(banktransferHeading);

        LongForm_Element__c depositHeading = new LongForm_Element__c(
                Name = 'DEPOSIT HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(depositHeading);

        LongForm_Element__c amountToBePaid = new LongForm_Element__c(
                Name = 'AMOUNT TO BE PAID',
                Type__c = 'Text Block',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(amountToBePaid);

        LongForm_Element__c depositFooter = new LongForm_Element__c(
                Name = 'DEPOSIT FOOTER',
                Type__c = 'Text Block',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(depositFooter);

        LongForm_Element__c depositAgreement = new LongForm_Element__c(
                Name = 'DEPOSIT AGREEMENT',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(depositAgreement);

        LongForm_Element__c depositButton = new LongForm_Element__c(
                Name = 'DEPOSIT BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(depositButton);

        LongForm_Element__c ddDepositHeading = new LongForm_Element__c(
                Name = 'DD DEPOSIT HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(ddDepositHeading);

        LongForm_Element__c ddDepositDescription = new LongForm_Element__c(
                Name = 'DD DEPOSIT DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(ddDepositDescription);

        LongForm_Element__c ddDepositCardsHeading = new LongForm_Element__c(
                Name = 'DD DEPOSIT CARDS HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(ddDepositCardsHeading);

        LongForm_Element__c onlinePaymentBank = new LongForm_Element__c(
                Name = 'ONLINE PAYMENT BANK',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(onlinePaymentBank);

        LongForm_Element__c proceedToCheckoutButton = new LongForm_Element__c(
                Name = 'PROCEED TO CHECKOUT BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(proceedToCheckoutButton);

        LongForm_Element__c btHeading = new LongForm_Element__c(
                Name = 'BT HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(btHeading);

        LongForm_Element__c btDepositCardsHeading = new LongForm_Element__c(
                Name = 'BT DEPOSIT CARDS HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = paymentOptionsPage.Id
        );
        paymentOptionsElementsList.add(btDepositCardsHeading);

        insert paymentOptionsElementsList;

        List<LongForm_Element_Item__c> paymentOptionsElementItemList = new List<LongForm_Element_Item__c>();
        // PaymentMethod Cards
        LongForm_Element_Item__c paymentMethodOptions = new LongForm_Element_Item__c(
                Name = 'OPTIONS',
                Active__c = true,
                Value__c = 'Visa=>visa-logo.png; MasterCard=>Mastercard-logo.png; Maestro=>maestro-logo.png;',
                Type__c = 'Options',
                Long_Form_Element__c = paymentMethodCards.Id
        );
        paymentOptionsElementItemList.add(paymentMethodOptions);

        // PaymentMethod Online Bank
        LongForm_Element_Item__c paymentMethodOnlineBankItem = new LongForm_Element_Item__c(
                Name = 'a3Y0E0000004ekD',
                Active__c = true,
                Value__c = 'Sofort=>SOFORT-logo.png;Giropay=>giroPay-logo.png;',
                Type__c = 'Options',
                Long_Form_Element__c = paymentMethodOnlineBank.Id
        );
        paymentOptionsElementItemList.add(paymentMethodOnlineBankItem);

        // BUTTON ON
        LongForm_Element_Item__c buttonOnLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'ON',
                Type__c = 'Label',
                Long_Form_Element__c = paymentOptionsButtonOn.Id
        );
        paymentOptionsElementItemList.add(buttonOnLabel);

        // BUTTON OFF
        LongForm_Element_Item__c buttonOffLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'OFF',
                Type__c = 'Label',
                Long_Form_Element__c = paymentOptionsButtonOff.Id
        );
        paymentOptionsElementItemList.add(buttonOffLabel);

        // DD HEADING
        LongForm_Element_Item__c ddHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Payment options for direct debit',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddHeading.Id
        );
        paymentOptionsElementItemList.add(ddHeadingValue);

        // BILLING PERIOD
        LongForm_Element_Item__c billingPeriodDays = new LongForm_Element_Item__c(
                Name = '-DAYS-',
                Active__c = true,
                Value__c = 'days',
                Type__c = 'Free Text',
                Long_Form_Element__c = billingPeriod.Id
        );
        paymentOptionsElementItemList.add(billingPeriodDays);

        LongForm_Element_Item__c billingPeriodLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Billing Period',
                Type__c = 'Label',
                Long_Form_Element__c = billingPeriod.Id
        );
        paymentOptionsElementItemList.add(billingPeriodLabel);

        // ACCOUNT HOLDER
        LongForm_Element_Item__c accountHolderValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = accountHolder.Id
        );
        paymentOptionsElementItemList.add(accountHolderValue);

        LongForm_Element_Item__c accountHolderLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Account Holder',
                Type__c = 'Label',
                Long_Form_Element__c = accountHolder.Id
        );
        paymentOptionsElementItemList.add(accountHolderLabel);

        LongForm_Element_Item__c accountHolderAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = accountHolder.Id
        );
        paymentOptionsElementItemList.add(accountHolderAsterisk);

        LongForm_Element_Item__c accountHolderWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = false,
                Value__c = 'Enter account holder',
                Type__c = 'Validation Text',
                Long_Form_Element__c = accountHolder.Id
        );
        paymentOptionsElementItemList.add(accountHolderWarnMessage);

        // IBAN
        LongForm_Element_Item__c ibanValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = iban.Id
        );
        paymentOptionsElementItemList.add(ibanValue);

        LongForm_Element_Item__c ibanLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'IBAN',
                Type__c = 'Label',
                Long_Form_Element__c = iban.Id
        );
        paymentOptionsElementItemList.add(ibanLabel);

        LongForm_Element_Item__c ibanAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = iban.Id
        );
        paymentOptionsElementItemList.add(ibanAsterisk);

        LongForm_Element_Item__c ibanHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Help text',
                Type__c = 'Help text',
                Long_Form_Element__c = iban.Id
        );
        paymentOptionsElementItemList.add(ibanHelp);

        LongForm_Element_Item__c ibanWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'WARN MESSAGE',
                Type__c = 'Free Text',
                Long_Form_Element__c = iban.Id
        );
        paymentOptionsElementItemList.add(ibanWarnMessage);

        // SWIFT
        LongForm_Element_Item__c swiftLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'SWIFT',
                Type__c = 'Label',
                Long_Form_Element__c = swift.Id
        );
        paymentOptionsElementItemList.add(swiftLabel);

        LongForm_Element_Item__c swiftValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = swift.Id
        );
        paymentOptionsElementItemList.add(swiftValue);

        LongForm_Element_Item__c swiftAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = swift.Id
        );
        paymentOptionsElementItemList.add(swiftAsterisk);

        LongForm_Element_Item__c swiftHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Help text',
                Type__c = 'Help Text',
                Long_Form_Element__c = swift.Id
        );
        paymentOptionsElementItemList.add(swiftHelp);

        LongForm_Element_Item__c swiftWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'WARN MESSAGE',
                Type__c = 'Free Text',
                Long_Form_Element__c = swift.Id
        );
        paymentOptionsElementItemList.add(swiftWarnMessage);

        // FORMAT INFO
        LongForm_Element_Item__c formatInfoText = new LongForm_Element_Item__c(
                Name = 'TEXT',
                Active__c = true,
                Value__c = 'All invoices are delivered in electronic format',
                Type__c = 'Free Text',
                Long_Form_Element__c = formatInfo.Id
        );
        paymentOptionsElementItemList.add(formatInfoText);

        // PAPER INVOICE
        LongForm_Element_Item__c paperInvoiceValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'true',
                Type__c = 'Default Value',
                Long_Form_Element__c = paperInvoice.Id
        );
        paymentOptionsElementItemList.add(paperInvoiceValue);

        LongForm_Element_Item__c paperInvoiceLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Paper invoices',
                Type__c = 'Label',
                Long_Form_Element__c = paperInvoice.Id
        );
        paymentOptionsElementItemList.add(paperInvoiceLabel);

        LongForm_Element_Item__c paperInvoiceLabel2 = new LongForm_Element_Item__c(
                Name = 'LABEL2',
                Active__c = true,
                Value__c = 'Able to use card at such partners',
                Type__c = 'Label',
                Long_Form_Element__c = paperInvoice.Id
        );
        paymentOptionsElementItemList.add(paperInvoiceLabel2);

        LongForm_Element_Item__c paperInvoiceLabel3 = new LongForm_Element_Item__c(
                Name = 'LABEL3',
                Active__c = true,
                Value__c = '2 € Transaction fee for fuel',
                Type__c = 'Label',
                Long_Form_Element__c = paperInvoice.Id
        );
        paymentOptionsElementItemList.add(paperInvoiceLabel3);

        // DD SEPA
        LongForm_Element_Item__c ddSepaHeading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'SEPA-Mandate',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddSepa.Id
        );
        paymentOptionsElementItemList.add(ddSepaHeading);

        LongForm_Element_Item__c ddSepaSubheading = new LongForm_Element_Item__c(
                Name = 'SUBHEADING',
                Active__c = true,
                Value__c = 'Please inform your bank about new B2B SEPA Mandate accepted',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddSepa.Id
        );
        paymentOptionsElementItemList.add(ddSepaSubheading);

        LongForm_Element_Item__c ddSepaHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Help text',
                Type__c = 'Help text',
                Long_Form_Element__c = ddSepa.Id
        );
        paymentOptionsElementItemList.add(ddSepaHelp);

        LongForm_Element_Item__c ddSepaIframeUrl = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = ddSepa.Id
        );
        paymentOptionsElementItemList.add(ddSepaIframeUrl);

        LongForm_Element_Item__c ddSepaDownloadUrl = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = ddSepa.Id
        );
        paymentOptionsElementItemList.add(ddSepaDownloadUrl);

        // ACCEPT SEPA
        LongForm_Element_Item__c acceptSepaLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'I accept the terms of SEPA-Mandate',
                Type__c = 'Label',
                Long_Form_Element__c = acceptSepa.Id
        );
        paymentOptionsElementItemList.add(acceptSepaLabel);

        LongForm_Element_Item__c acceptSepaValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = acceptSepa.Id
        );
        paymentOptionsElementItemList.add(acceptSepaValue);

        // DECISION
        LongForm_Element_Item__c decisionLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'I guarantee that I have permission to make <kind of decisions here> on behalf of the',
                Type__c = 'Label',
                Long_Form_Element__c = decision.Id
        );
        paymentOptionsElementItemList.add(decisionLabel);

        LongForm_Element_Item__c decisionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = decision.Id
        );
        paymentOptionsElementItemList.add(decisionValue);

        // ACCEPT TERM CONDITIONS
        LongForm_Element_Item__c termConditionLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'I agree with',
                Type__c = 'Label',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        paymentOptionsElementItemList.add(termConditionLabel);

        LongForm_Element_Item__c termConditionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        paymentOptionsElementItemList.add(termConditionValue);

        LongForm_Element_Item__c termConditionIframeUrl = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        paymentOptionsElementItemList.add(termConditionIframeUrl);

        LongForm_Element_Item__c termConditionDownloadUrl = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        paymentOptionsElementItemList.add(termConditionDownloadUrl);

        LongForm_Element_Item__c termConditionLabelUrl = new LongForm_Element_Item__c(
                Name = 'LABEL URL',
                Active__c = true,
                Value__c = 'Term Conditions',
                Type__c = 'Label',
                Long_Form_Element__c = acceptTermConditions.Id
        );
        paymentOptionsElementItemList.add(termConditionLabelUrl);

        // BACK BUTTON
        LongForm_Element_Item__c backButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'BACK',
                Type__c = 'Label',
                Long_Form_Element__c = backButton.Id
        );
        paymentOptionsElementItemList.add(backButtonLabel);

        // CONTINUE BUTTON
        LongForm_Element_Item__c continueButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'CONTINUE',
                Type__c = 'Label',
                Long_Form_Element__c = continueButton.Id
        );
        paymentOptionsElementItemList.add(continueButtonLabel);

        // BANKTRANSFER HEADING
        LongForm_Element_Item__c banktransferHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Payment options for bank transfer',
                Type__c = 'Free Text',
                Long_Form_Element__c = banktransferHeading.Id
        );
        paymentOptionsElementItemList.add(banktransferHeadingValue);

        // DEPOSIT HEADING
        LongForm_Element_Item__c depositHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Pay deposit now',
                Type__c = 'Free Text',
                Long_Form_Element__c = depositHeading.Id
        );
        paymentOptionsElementItemList.add(depositHeadingValue);

        // AMOUNT TO BE PAID
        LongForm_Element_Item__c amountToBePaidLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Amount to be paid:',
                Type__c = 'Label',
                Long_Form_Element__c = amountToBePaid.Id
        );
        paymentOptionsElementItemList.add(amountToBePaidLabel);

        LongForm_Element_Item__c amountToBePaidValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = amountToBePaid.Id
        );
        paymentOptionsElementItemList.add(amountToBePaidValue);

        LongForm_Element_Item__c amountToBePaidDescription = new LongForm_Element_Item__c(
                Name = 'DESCRIPTION',
                Active__c = true,
                Value__c = 'To start using your fuel cards immediately after you receive them, we kindly ask you to pay deposit now. After you press Proceed to Checkout Button, you will be redirected to Ingenico Payment Gateway.',
                Type__c = 'Free Text',
                Long_Form_Element__c = amountToBePaid.Id
        );
        paymentOptionsElementItemList.add(amountToBePaidDescription);

        LongForm_Element_Item__c amountToBePaidHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Help text',
                Type__c = 'Help text',
                Long_Form_Element__c = amountToBePaid.Id
        );
        paymentOptionsElementItemList.add(amountToBePaidHelp);

        // DEPOSIT FOOTER
        LongForm_Element_Item__c depositFooterValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'After you press "Proceed to checkout" Lorem ipsum dolor sit amet, consectetur," Lorem ipsum dolor sit amet, consectetur," Lorem ipsum dolor sit amet, consectetur," Lorem ipsum dolor sit amet, consectetur," Lorem ipsum dolor sit amet, consectetur,',
                Type__c = 'Free Text',
                Long_Form_Element__c = depositFooter.Id
        );
        paymentOptionsElementItemList.add(depositFooterValue);

        // DEPOSIT AGREEMENT
        LongForm_Element_Item__c depositAgreementIframeUrl = new LongForm_Element_Item__c(
                Name = 'IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = depositAgreement.Id
        );
        paymentOptionsElementItemList.add(depositAgreementIframeUrl);

        LongForm_Element_Item__c depositAgreementDownloadUrl = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = depositAgreement.Id
        );
        paymentOptionsElementItemList.add(depositAgreementDownloadUrl);

        LongForm_Element_Item__c depositAgreementLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'I\'m ok',
                Type__c = 'Label',
                Long_Form_Element__c = depositAgreement.Id
        );
        paymentOptionsElementItemList.add(depositAgreementLabel);

        LongForm_Element_Item__c depositAgreementValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'false',
                Type__c = 'Default Value',
                Long_Form_Element__c = depositAgreement.Id
        );
        paymentOptionsElementItemList.add(depositAgreementValue);

        LongForm_Element_Item__c depositAgreementDownloadUrlLabel = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL LABEL',
                Active__c = true,
                Value__c = 'to pay deposit',
                Type__c = 'Free Text',
                Long_Form_Element__c = depositAgreement.Id
        );
        paymentOptionsElementItemList.add(depositAgreementDownloadUrlLabel);

        // DEPOSIT BUTTON
        LongForm_Element_Item__c depositButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'to pay deposit',
                Type__c = 'Label',
                Long_Form_Element__c = depositButton.Id
        );
        paymentOptionsElementItemList.add(depositButtonLabel);

        // DD DEPOSIT HEADING
        LongForm_Element_Item__c ddDepositHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Pay deposit now',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddDepositHeading.Id
        );
        paymentOptionsElementItemList.add(ddDepositHeadingValue);

        // DD DEPOSIT DESCRIPTION
        LongForm_Element_Item__c ddDepositDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'To start using your fuel cards immediately after you receive them, we kindly ask you to pay deposit now. After you press Proceed to Checkout Button, you will be redirected to Ingenico Payment Gateway.',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddDepositDescription.Id
        );
        paymentOptionsElementItemList.add(ddDepositDescriptionValue);

        LongForm_Element_Item__c ddDepositDescriptionHelp = new LongForm_Element_Item__c(
                Name = 'HELP',
                Active__c = true,
                Value__c = 'Help text',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddDepositDescription.Id
        );
        paymentOptionsElementItemList.add(ddDepositDescriptionHelp);

        // DD DEPOSIT CARDS HEADING
        LongForm_Element_Item__c ddDepositCardsHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Cards',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddDepositCardsHeading.Id
        );
        paymentOptionsElementItemList.add(ddDepositCardsHeadingValue);

        LongForm_Element_Item__c ddDepositCardsHeadingDescription = new LongForm_Element_Item__c(
                Name = 'DESCRIPTION',
                Active__c = true,
                Value__c = 'Description',
                Type__c = 'Free Text',
                Long_Form_Element__c = ddDepositCardsHeading.Id
        );
        paymentOptionsElementItemList.add(ddDepositCardsHeadingDescription);

        // ONLINE PAYMENT BANK
        LongForm_Element_Item__c onlinePaymentBankValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'or Online Payment Through Your Bank',
                Type__c = 'Free Text',
                Long_Form_Element__c = onlinePaymentBank.Id
        );
        paymentOptionsElementItemList.add(onlinePaymentBankValue);

        LongForm_Element_Item__c onlinePaymentBankDescription = new LongForm_Element_Item__c(
                Name = 'DESCRIPTION',
                Active__c = true,
                Value__c = 'Description text',
                Type__c = 'Free Text',
                Long_Form_Element__c = onlinePaymentBank.Id
        );
        paymentOptionsElementItemList.add(onlinePaymentBankDescription);

        // PROCEED TO CHECKOUT BUTTON
        LongForm_Element_Item__c proceedToCheckoutButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'PROCEED TO CHECKOUT',
                Type__c = 'Free Text',
                Long_Form_Element__c = proceedToCheckoutButton.Id
        );
        paymentOptionsElementItemList.add(proceedToCheckoutButtonLabel);

        // BT HEADING
        LongForm_Element_Item__c btHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Payment options for bank transfer',
                Type__c = 'Free Text',
                Long_Form_Element__c = btHeading.Id
        );
        paymentOptionsElementItemList.add(btHeadingValue);

        // BT DEPOSIT CARDS HEADING
        LongForm_Element_Item__c btDepositCardsHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Cards',
                Type__c = 'Free Text',
                Long_Form_Element__c = btDepositCardsHeading.Id
        );
        paymentOptionsElementItemList.add(btDepositCardsHeadingValue);

        LongForm_Element_Item__c btDepositCardsHeadingDescription = new LongForm_Element_Item__c(
                Name = 'DESCRIPTION',
                Active__c = true,
                Value__c = 'Description',
                Type__c = 'Free Text',
                Long_Form_Element__c = btDepositCardsHeading.Id
        );
        paymentOptionsElementItemList.add(btDepositCardsHeadingDescription);

        insert paymentOptionsElementItemList;
    }


    /*******************************************************************************
    *  Name            : createPaymentOptionsCongratulations()
    *  Summary         : Create payment options congratulations page
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createPaymentOptionsCongratulations(String deviceView) {
        LongForm_Page__c paymentOptionsCongratulationsPage = new LongForm_Page__c(
                Name = 'CONGRATULATIONS',
                Title__c = 'Payment options',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep4.Id
        );
        insert paymentOptionsCongratulationsPage;

        List<LongForm_Element__c> paymentOptionsConElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c howToPayBlock = new LongForm_Element__c(
                Name = 'HOW TO PAY BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = paymentOptionsCongratulationsPage.Id
        );
        paymentOptionsConElementsList.add(howToPayBlock);

        insert paymentOptionsConElementsList;

        List<LongForm_Element_Item__c> paymentOptionsConElementItemList = new List<LongForm_Element_Item__c>();
        // HOW TO PAY BLOCK
        LongForm_Element_Item__c savePaymentInformationButton = new LongForm_Element_Item__c(
                Name = 'SAVE PAYMENT INFORMATION DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = howToPayBlock.Id
        );
        paymentOptionsConElementItemList.add(savePaymentInformationButton);

        insert paymentOptionsConElementItemList;
    }


    /*******************************************************************************
    *  Name            : createCongratulations()
    *  Summary         : Create payment options congratulations page
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCongratulations(String deviceView) {
        LongForm_Page__c congratulationsPage = new LongForm_Page__c(
                Name = 'CONGRATULATIONS',
                Title__c = 'Payment options',
                System_Error__c = 'An unexpected error has occurred. Please contact your administrator',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id,
                LongForm_Menu_Item__c = longFormMenuForStep4.Id
        );
        insert congratulationsPage;

        List<LongForm_Element__c> congratulationsElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c howToPayBlock = new LongForm_Element__c(
                Name = 'HOW TO PAY BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = congratulationsPage.Id
        );
        congratulationsElementsList.add(howToPayBlock);

        insert congratulationsElementsList;

        List<LongForm_Element_Item__c> congratulationsElementItemList = new List<LongForm_Element_Item__c>();
        // HOW TO PAY BLOCK
        LongForm_Element_Item__c downloadUrl = new LongForm_Element_Item__c(
                Name = 'SAVE PAYMENT INFORMATION DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = howToPayBlock.Id
        );
        congratulationsElementItemList.add(downloadUrl);

        insert congratulationsElementItemList;
    }


    /*******************************************************************************
    *  Name            : createInternationalPartnersPriceList(String country, String channel)
    *  Summary         : Create international partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createInternationalPartnersPrice(String country, String channel) {
        internationalPartnerPrice = new LongForm_Pricelist__c(
                Type__c = 'International Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert internationalPartnerPrice;

        List<LongForm_Pricelist_Item__c> internationalPartnerPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(monthlyDirectDebit);


        LongForm_Pricelist_Item__c evMonthlyFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'EV Monthly Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(evMonthlyFee);

        LongForm_Pricelist_Item__c evManagementFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'EV Management Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(evManagementFee);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 0.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerPrice.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(monthlyCardFee);

        insert internationalPartnerPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createInternationalPartnersDiffPrice(String country, String channel)
    *  Summary         : Create international partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createInternationalPartnersDiffPrice(String country, String channel) {
        internationalPartnerDiffPrice = new LongForm_Pricelist__c(
                Type__c = 'International Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert internationalPartnerDiffPrice;

        List<LongForm_Pricelist_Item__c> internationalPartnerPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(monthlyDirectDebit);

        LongForm_Pricelist_Item__c evMonthlyFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'EV Monthly Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(evMonthlyFee);

        LongForm_Pricelist_Item__c evManagementFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'EV Management Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(evManagementFee);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 6.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 7.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 8.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 9.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 10.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 11.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 12.00,
                Show_Category__c = false
        );
        internationalPartnerPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 13.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 14.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalPartnerDiffPrice.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalPartnerPriceItemList.add(monthlyCardFee);

        insert internationalPartnerPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createNationalNotPartnersPrice(String country, String channel)
    *  Summary         : Create national not partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createNationalNotPartnersPrice(String country, String channel) {
        nationalNotPartnersPrice = new LongForm_Pricelist__c(
                Type__c = 'National Not Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert nationalNotPartnersPrice;

        List<LongForm_Pricelist_Item__c> nationalNotPartnersPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(monthlyDirectDebit);

        LongForm_Pricelist_Item__c evMonthlyFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'EV Monthly Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(evMonthlyFee);

        LongForm_Pricelist_Item__c evManagementFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'EV Management Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(evManagementFee);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 0.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersPrice.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(monthlyCardFee);

        insert nationalNotPartnersPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createNationalNotPartnersDiffPrice(String country, String channel)
    *  Summary         : Create national not partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createNationalNotPartnersDiffPrice(String country, String channel) {
        nationalNotPartnersDiffPrice = new LongForm_Pricelist__c(
                Type__c = 'National Not Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert nationalNotPartnersDiffPrice;

        List<LongForm_Pricelist_Item__c> nationalNotPartnersPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 6.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(monthlyDirectDebit);

        LongForm_Pricelist_Item__c evMonthlyFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'EV Monthly Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(evMonthlyFee);

        LongForm_Pricelist_Item__c evManagementFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'EV Management Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(evManagementFee);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 7.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 8.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 9.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 10.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 11.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 12.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 13.00,
                Show_Category__c = false
        );
        nationalNotPartnersPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 14.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 15.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalNotPartnersPriceItemList.add(monthlyCardFee);

        insert nationalNotPartnersPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createInternationalNotPartnersPrice(String country, String channel)
    *  Summary         : Create international not partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createInternationalNotPartnersPrice(String country, String channel) {
        internationalNotPartners = new LongForm_Pricelist__c(
                Type__c = 'International Not Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert internationalNotPartners;

        List<LongForm_Pricelist_Item__c> internationalNotPartnersPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(monthlyDirectDebit);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 0.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartners.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(monthlyCardFee);

        insert internationalNotPartnersPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createInternationalNotPartnersDiffPrice(String country, String channel)
    *  Summary         : Create international not partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createInternationalNotPartnersDiffPrice(String country, String channel) {
        internationalNotPartnersDiffPrice = new LongForm_Pricelist__c(
                Type__c = 'International Not Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert internationalNotPartnersDiffPrice;

        List<LongForm_Pricelist_Item__c> internationalNotPartnersPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(monthlyDirectDebit);

        LongForm_Pricelist_Item__c evMonthlyFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'EV Monthly Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(evMonthlyFee);

        LongForm_Pricelist_Item__c evManagementFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'EV Management Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(evManagementFee);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 6.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 7.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 8.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 9.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 10.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 11.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 12.00,
                Show_Category__c = false
        );
        internationalNotPartnersPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 13.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 14.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = internationalNotPartnersDiffPrice.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        internationalNotPartnersPriceItemList.add(monthlyCardFee);

        insert internationalNotPartnersPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createNationalPartnersPrice(String country, String channel)
    *  Summary         : Create international not partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createNationalPartnersPrice(String country, String channel) {
        nationalPartners = new LongForm_Pricelist__c(
                Type__c = 'National Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert nationalPartners;

        List<LongForm_Pricelist_Item__c> nationalPartnersPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(monthlyDirectDebit);

        LongForm_Pricelist_Item__c evMonthlyFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'EV Monthly Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(evMonthlyFee);

        LongForm_Pricelist_Item__c evManagementFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'EV Management Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(evManagementFee);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 0.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartners.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(monthlyCardFee);

        insert nationalPartnersPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createNationalPartnersDiffPrice(String country, String channel)
    *  Summary         : Create international not partners price
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String channel
    *  Returns         : void
    ******************************************************************************/
    public static void createNationalPartnersDiffPrice(String country, String channel) {
        nationalPartnersDiffPrice = new LongForm_Pricelist__c(
                Type__c = 'National Partners',
                Country__c = country,
                Channel__c = channel
        );
        insert nationalPartnersDiffPrice;

        List<LongForm_Pricelist_Item__c> nationalPartnersPriceItemList = new List<LongForm_Pricelist_Item__c>();

        LongForm_Pricelist_Item__c transactionShellHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 0.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellHomeFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 1.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellNonHomeFuel);

        LongForm_Pricelist_Item__c monthlyDirectDebit = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Monthly Direct Debit',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(monthlyDirectDebit);

        LongForm_Pricelist_Item__c evMonthlyFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'EV Monthly Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.95,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(evMonthlyFee);

        LongForm_Pricelist_Item__c evManagementFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'EV Management Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(evManagementFee);

        LongForm_Pricelist_Item__c monthlyBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Monthly Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.95,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(monthlyBankTransfer);

        LongForm_Pricelist_Item__c transactionShellHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 2.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellHomeNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 3.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellPartnerNonFuel);

        LongForm_Pricelist_Item__c transactionShellPartnerFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Partner Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 4.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellPartnerFuel);

        LongForm_Pricelist_Item__c transactionShellNonHomeNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Transaction Shell Non-Home Non-Fuel',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(transactionShellNonHomeNonFuel);

        LongForm_Pricelist_Item__c oneTimeCardSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'One Time Card Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 6.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(oneTimeCardSetUp);

        LongForm_Pricelist_Item__c regularBankTransfer = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Regular Bank Transfer',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 7.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(regularBankTransfer);

        LongForm_Pricelist_Item__c regularPaperInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Regular Paper Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 8.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(regularPaperInvoice);

        LongForm_Pricelist_Item__c monthlyAccountManagement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Monthly Account Management',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 9.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(monthlyAccountManagement);

        LongForm_Pricelist_Item__c lateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Late Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 50.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(lateInvoice);

        LongForm_Pricelist_Item__c duplicateInvoice = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Duplicate Invoice',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 10.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(duplicateInvoice);

        LongForm_Pricelist_Item__c ecoFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Eco Fee',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 11.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(ecoFee);

        LongForm_Pricelist_Item__c oneTimeAccountSetUp = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'One Time Account Set Up',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 12.00,
                Show_Category__c = false
        );
        nationalPartnersPriceItemList.add(oneTimeAccountSetUp);

        LongForm_Pricelist_Item__c allNonFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'All: Non-Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 13.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(allNonFuel);

        LongForm_Pricelist_Item__c allFuel = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'All: Fuel',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 14.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(allFuel);

        LongForm_Pricelist_Item__c cardReplacement = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Card replacement',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(cardReplacement);

        LongForm_Pricelist_Item__c exchangeRate = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Exchange Rate',
                Tariff__c = 'Percent',
                Unit__c = '%',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(exchangeRate);

        LongForm_Pricelist_Item__c monthlyCardFee = new LongForm_Pricelist_Item__c(
                Long_Form_Pricelist__c = nationalPartnersDiffPrice.Id,
                Type__c = 'Monthly Card Fee',
                Tariff__c = 'Amount',
                Unit__c = '€',
                Price__c = 5.00,
                Show_Category__c = true
        );
        nationalPartnersPriceItemList.add(monthlyCardFee);

        insert nationalPartnersPriceItemList;
    }


    /*******************************************************************************
    *  Name            : createSystemErrorPage()
    *  Summary         : Create system error page
    *  CreatedDate     : 02/05/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createSystemErrorPage(String deviceView) {
        LongForm_Page__c systemErrorPage = new LongForm_Page__c(
                Name = 'SYSTEM ERROR',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Lightbox',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert systemErrorPage;

        List<LongForm_Element__c> systemErrorElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c systemErrorTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = systemErrorPage.Id
        );
        systemErrorElementsList.add(systemErrorTopHeading);

        LongForm_Element__c systemErrorDescription = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = systemErrorPage.Id
        );
        systemErrorElementsList.add(systemErrorDescription);

        LongForm_Element__c systemErrorPhone = new LongForm_Element__c(
                Name = 'PHONE',
                Type__c = 'Text Block',
                Long_Form_Page__c = systemErrorPage.Id
        );
        systemErrorElementsList.add(systemErrorPhone);

        LongForm_Element__c systemErrorEmail = new LongForm_Element__c(
                Name = 'EMAIL',
                Type__c = 'Text Block',
                Long_Form_Page__c = systemErrorPage.Id
        );
        systemErrorElementsList.add(systemErrorEmail);

        LongForm_Element__c systemErrorWorkTime = new LongForm_Element__c(
                Name = 'WORK TIME',
                Type__c = 'Text Block',
                Long_Form_Page__c = systemErrorPage.Id
        );
        systemErrorElementsList.add(systemErrorWorkTime);

        LongForm_Element__c systemErrorConfirmButton = new LongForm_Element__c(
                Name = 'CONFIRM BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = systemErrorPage.Id
        );
        systemErrorElementsList.add(systemErrorConfirmButton);

        insert systemErrorElementsList;

        List<LongForm_Element_Item__c> systemErrorElementItemList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c systemErrorTopHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Sorry, unexpected error happened.',
                Type__c = 'Free Text',
                Long_Form_Element__c = systemErrorTopHeading.Id
        );
        systemErrorElementItemList.add(systemErrorTopHeadingItem);

        // DESCRIPTION
        LongForm_Element_Item__c systemErrorDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'We can’t proceed your order for a moment. As soon as problem is fixed, we will notify you via email and suggest how to continue your order.',
                Type__c = 'Free Text',
                Long_Form_Element__c = systemErrorDescription.Id
        );
        systemErrorElementItemList.add(systemErrorDescriptionValue);

        // PHONE
        LongForm_Element_Item__c systemErrorPhoneValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '+ 49 911 14955287',
                Type__c = 'Free Text',
                Long_Form_Element__c = systemErrorPhone.Id
        );
        systemErrorElementItemList.add(systemErrorPhoneValue);

        // EMAIL
        LongForm_Element_Item__c systemErrorEmailValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'kundenwerden@fleetcor.de',
                Type__c = 'Free Text',
                Long_Form_Element__c = systemErrorEmail.Id
        );
        systemErrorElementItemList.add(systemErrorEmailValue);

        // WORK TIME
        LongForm_Element_Item__c systemErrorWorkTimeValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '8:00 – 17:00 (from Monday to Friday)',
                Type__c = 'Free Text',
                Long_Form_Element__c = systemErrorWorkTime.Id
        );
        systemErrorElementItemList.add(systemErrorWorkTimeValue);

        // CONFIRM BUTTON
        LongForm_Element_Item__c systemErrorConfirmButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'OK',
                Type__c = 'Label',
                Long_Form_Element__c = systemErrorConfirmButton.Id
        );
        systemErrorElementItemList.add(systemErrorConfirmButtonName);

        insert systemErrorElementItemList;
    }


    /*******************************************************************************
    *  Name            : createProcessErrorPage()
    *  Summary         : Create procees error page
    *  CreatedDate     : 02/05/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createProcessErrorPage(String deviceView) {
        LongForm_Page__c processErrorPage = new LongForm_Page__c(
                Name = 'PROCESS ERROR',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert processErrorPage;

        List<LongForm_Element__c> processErrorElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c tooHightLimitTopHeading = new LongForm_Element__c(
                Name = 'TOO HIGH LIMIT TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(tooHightLimitTopHeading);

        LongForm_Element__c tooHightLimitDescription = new LongForm_Element__c(
                Name = 'TOO HIGH LIMIT DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(tooHightLimitDescription);

        LongForm_Element__c tooHightLimitContactDetailsHeading = new LongForm_Element__c(
                Name = 'TOO HIGH LIMIT CONTACT DETAILS HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(tooHightLimitContactDetailsHeading);

        LongForm_Element__c tooHightLimitPhone = new LongForm_Element__c(
                Name = 'TOO HIGH LIMIT PHONE',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(tooHightLimitPhone);

        LongForm_Element__c tooHightLimitEmail = new LongForm_Element__c(
                Name = 'TOO HIGH LIMIT EMAIL',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(tooHightLimitEmail);

        LongForm_Element__c tooHightLimitWorkTime = new LongForm_Element__c(
                Name = 'TOO HIGH LIMIT WORK TIME',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(tooHightLimitWorkTime);

        LongForm_Element__c noReportTopHeading = new LongForm_Element__c(
                Name = 'NO REPORT TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(noReportTopHeading);

        LongForm_Element__c noReportDescription = new LongForm_Element__c(
                Name = 'NO REPORT DESCRIPTION',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(noReportDescription);

        LongForm_Element__c noReportPhone = new LongForm_Element__c(
                Name = 'NO REPORT PHONE',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(noReportPhone);

        LongForm_Element__c noReportEmail = new LongForm_Element__c(
                Name = 'NO REPORT EMAIL',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(noReportEmail);

        LongForm_Element__c noReportWorkTime = new LongForm_Element__c(
                Name = 'NO REPORT WORK TIME',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(noReportWorkTime);

        LongForm_Element__c companyNotFoundTopHeading = new LongForm_Element__c(
                Name = 'COMPANY NOT FOUND TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(companyNotFoundTopHeading);

        LongForm_Element__c companyNotFoundDescription = new LongForm_Element__c(
                Name = 'COMPANY NOT FOUND DESCRIPTION',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(companyNotFoundDescription);

        LongForm_Element__c companyNotFoundPhone = new LongForm_Element__c(
                Name = 'COMPANY NOT FOUND PHONE',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(companyNotFoundPhone);

        LongForm_Element__c companyNotFoundEmail = new LongForm_Element__c(
                Name = 'COMPANY NOT FOUND EMAIL',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(companyNotFoundEmail);

        LongForm_Element__c companyNotFoundWorkTime = new LongForm_Element__c(
                Name = 'COMPANY NOT FOUND WORK TIME',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(companyNotFoundWorkTime);

        LongForm_Element__c returnToSiteButton = new LongForm_Element__c(
                Name = 'RETURN TO SITE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(returnToSiteButton);

        LongForm_Element__c authorizationNotGrantedHeading = new LongForm_Element__c(
                Name = 'AUTHORIZATION NOT GRANTED HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(authorizationNotGrantedHeading);

        LongForm_Element__c authorizationNotGrantedDescription = new LongForm_Element__c(
                Name = 'AUTHORIZATION NOT GRANTED DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(authorizationNotGrantedDescription);

        LongForm_Element__c authorizationNotGrantedPhone = new LongForm_Element__c(
                Name = 'AUTHORIZATION NOT GRANTED PHONE',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(authorizationNotGrantedPhone);

        LongForm_Element__c authorizationNotGrantedEmail = new LongForm_Element__c(
                Name = 'AUTHORIZATION NOT GRANTED EMAIL',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(authorizationNotGrantedEmail);

        LongForm_Element__c authorizationNotGrantedWorkTime = new LongForm_Element__c(
                Name = 'AUTHORIZATION NOT GRANTED WORK TIME',
                Type__c = 'Text Block',
                Long_Form_Page__c = processErrorPage.Id
        );
        processErrorElementsList.add(authorizationNotGrantedWorkTime);

        insert processErrorElementsList;

        List<LongForm_Element_Item__c> processErrorElementItemList = new List<LongForm_Element_Item__c>();
        // TOO HIGH LIMIT TOP HEADING
        LongForm_Element_Item__c tooHightLimitTopHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Sorry, we can’t place your order at the moment.',
                Type__c = 'Free Text',
                Long_Form_Element__c = tooHightLimitTopHeading.Id
        );
        processErrorElementItemList.add(tooHightLimitTopHeadingItem);

        // TOO HIGH LIMIT DESCRIPTION
        LongForm_Element_Item__c tooHightLimitDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'It seems we need more information to prepare proper Credit Line calculation for you. We will contact you back shortly to discuss all details.',
                Type__c = 'Free Text',
                Long_Form_Element__c = tooHightLimitDescription.Id
        );
        processErrorElementItemList.add(tooHightLimitDescriptionValue);

        // TOO HIGH LIMIT CONTACT DETAILS HEADING
        LongForm_Element_Item__c tooHightLimitContactDetailsHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'If you need assistance',
                Type__c = 'Free Text',
                Long_Form_Element__c = tooHightLimitContactDetailsHeading.Id
        );
        processErrorElementItemList.add(tooHightLimitContactDetailsHeadingItem);

        // TOO HIGH LIMIT PHONE
        LongForm_Element_Item__c tooHightLimitPhoneValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '+ 49 911 14955287',
                Type__c = 'Free Text',
                Long_Form_Element__c = tooHightLimitPhone.Id
        );
        processErrorElementItemList.add(tooHightLimitPhoneValue);

        // TOO HIGH LIMIT EMAIL
        LongForm_Element_Item__c tooHightLimitEmailValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'kundenwerden@fleetcor.de',
                Type__c = 'Free Text',
                Long_Form_Element__c = tooHightLimitEmail.Id
        );
        processErrorElementItemList.add(tooHightLimitEmailValue);

        // TOO HIGH LIMIT WORK TIME
        LongForm_Element_Item__c tooHightLimitWorkTimeValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '8:00 – 17:00 (from Monday to Friday)',
                Type__c = 'Free Text',
                Long_Form_Element__c = tooHightLimitWorkTime.Id
        );
        processErrorElementItemList.add(tooHightLimitWorkTimeValue);

        // NO REPORT TOP HEADING
        LongForm_Element_Item__c noReportTopHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Sorry, we can’t place your order at the moment.',
                Type__c = 'Free Text',
                Long_Form_Element__c = noReportTopHeading.Id
        );
        processErrorElementItemList.add(noReportTopHeadingItem);

        // NO REPORT DESCRIPTION
        LongForm_Element_Item__c noReportDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'It seems we need more time to prepare proper Credit Line calculation for you. We will contact you back shortly to discuss all details.',
                Type__c = 'Free Text',
                Long_Form_Element__c = noReportDescription.Id
        );
        processErrorElementItemList.add(noReportDescriptionValue);

        // NO REPORT PHONE
        LongForm_Element_Item__c noReportPhoneValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '+ 49 911 14955287',
                Type__c = 'Free Text',
                Long_Form_Element__c = noReportPhone.Id
        );
        processErrorElementItemList.add(noReportPhoneValue);

        // NO REPORT EMAIL
        LongForm_Element_Item__c noReportEmailValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'kundenwerden@fleetcor.de',
                Type__c = 'Free Text',
                Long_Form_Element__c = noReportEmail.Id
        );
        processErrorElementItemList.add(noReportEmailValue);

        // NO REPORT WORK TIME
        LongForm_Element_Item__c noReportWorkTimeValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '8:00 – 17:00 (from Monday to Friday)',
                Type__c = 'Free Text',
                Long_Form_Element__c = noReportWorkTime.Id
        );
        processErrorElementItemList.add(noReportWorkTimeValue);

        // COMPANY NOT FOUND TOP HEADING
        LongForm_Element_Item__c companyNotFoundTopHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Sorry, we can’t place your order.',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyNotFoundTopHeading.Id
        );
        processErrorElementItemList.add(companyNotFoundTopHeadingItem);

        // COMPANY NOT FOUND DESCRIPTION
        LongForm_Element_Item__c companyNotFoundDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'According to our check, we were not able to identify your company and find all required details. Without company verification, we can’t proceed with next steps.',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyNotFoundDescription.Id
        );
        processErrorElementItemList.add(companyNotFoundDescriptionValue);

        // COMPANY NOT FOUND PHONE
        LongForm_Element_Item__c companyNotFoundPhoneValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '+ 49 911 14955287',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyNotFoundPhone.Id
        );
        processErrorElementItemList.add(companyNotFoundPhoneValue);

        // COMPANY NOT FOUND EMAIL
        LongForm_Element_Item__c companyNotFoundEmailValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'kundenwerden@fleetcor.de',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyNotFoundEmail.Id
        );
        processErrorElementItemList.add(companyNotFoundEmailValue);

        // COMPANY NOT FOUND WORK TIME
        LongForm_Element_Item__c companyNotFoundWorkTimeValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '8:00 – 17:00 (from Monday to Friday)',
                Type__c = 'Free Text',
                Long_Form_Element__c = companyNotFoundWorkTime.Id
        );
        processErrorElementItemList.add(companyNotFoundWorkTimeValue);

        // RETURN TO SITE BUTTON
        LongForm_Element_Item__c returnToSiteButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'RETURN TO SITE',
                Type__c = 'Free Text',
                Long_Form_Element__c = returnToSiteButton.Id
        );
        processErrorElementItemList.add(returnToSiteButtonName);

        LongForm_Element_Item__c returnToSiteButtonUrl = new LongForm_Element_Item__c(
                Name = 'URL',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = returnToSiteButton.Id
        );
        processErrorElementItemList.add(returnToSiteButtonUrl);

        // AUTHORIZATION NOT GRANTED HEADING
        LongForm_Element_Item__c authorizationNotGrantedHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Sorry, we can’t place your order.',
                Type__c = 'Free Text',
                Long_Form_Element__c = authorizationNotGrantedHeading.Id
        );
        processErrorElementItemList.add(authorizationNotGrantedHeadingValue);

        // AUTHORIZATION NOT GRANTED DESCRIPTION
        LongForm_Element_Item__c authorizationNotGrantedDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'According to our check process, you are not authorized to make decisions on behalf of company. Ordering Shell fuel cards online requires you to be either head of company or operate on base of Power of Attorney. Please, suggest an authorized person to order Shell fuel cards online.',
                Type__c = 'Free Text',
                Long_Form_Element__c = authorizationNotGrantedDescription.Id
        );
        processErrorElementItemList.add(authorizationNotGrantedDescriptionValue);

        // AUTHORIZATION NOT GRANTED PHONE
        LongForm_Element_Item__c authorizationNotGrantedPhoneValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '+ 49 911 14955287',
                Type__c = 'Free Text',
                Long_Form_Element__c = authorizationNotGrantedPhone.Id
        );
        processErrorElementItemList.add(authorizationNotGrantedPhoneValue);

        // AUTHORIZATION NOT GRANTED EMAIL
        LongForm_Element_Item__c authorizationNotGrantedEmailValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'kundenwerden@fleetcor.de',
                Type__c = 'Free Text',
                Long_Form_Element__c = authorizationNotGrantedEmail.Id
        );
        processErrorElementItemList.add(authorizationNotGrantedEmailValue);

        // AUTHORIZATION NOT GRANTED WORK TIME
        LongForm_Element_Item__c authorizationNotGrantedWorkTimeValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '8:00 – 17:00 (from Monday to Friday)',
                Type__c = 'Free Text',
                Long_Form_Element__c = authorizationNotGrantedWorkTime.Id
        );
        processErrorElementItemList.add(authorizationNotGrantedWorkTimeValue);

        insert processErrorElementItemList;
    }


    /*******************************************************************************
    *  Name            : createAlreadyCustomerPage()
    *  Summary         : Create customer page
    *  CreatedDate     : 02/05/2018
    *  ModifiedDate    : 21/07/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createAlreadyCustomerPage(String deviceView) {
        LongForm_Page__c alreadyACustomerPage = new LongForm_Page__c(
                Name = 'ALREADY A CUSTOMER',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert alreadyACustomerPage;

        List<LongForm_Element__c> alreadyACustomerElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c alreadyACustomerTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = alreadyACustomerPage.Id
        );
        alreadyACustomerElementsList.add(alreadyACustomerTopHeading);

        LongForm_Element__c alreadyACustomerDescription = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyACustomerPage.Id
        );
        alreadyACustomerElementsList.add(alreadyACustomerDescription);

        LongForm_Element__c alreadyACustomerPhone = new LongForm_Element__c(
                Name = 'PHONE',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyACustomerPage.Id
        );
        alreadyACustomerElementsList.add(alreadyACustomerPhone);

        LongForm_Element__c alreadyACustomerEmail = new LongForm_Element__c(
                Name = 'EMAIL',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyACustomerPage.Id
        );
        alreadyACustomerElementsList.add(alreadyACustomerEmail);

        LongForm_Element__c alreadyACustomerWorkTime = new LongForm_Element__c(
                Name = 'WORK TIME',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyACustomerPage.Id
        );
        alreadyACustomerElementsList.add(alreadyACustomerWorkTime);

        LongForm_Element__c alreadyACustomerButton = new LongForm_Element__c(
                Name = 'RETURN TO SITE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = alreadyACustomerPage.Id
        );
        alreadyACustomerElementsList.add(alreadyACustomerButton);

        LongForm_Element__c alreadyACustomerAssistance = new LongForm_Element__c(
                Name = 'IF YOU NEED ASSISTANCE',
                Type__c = 'Heading',
                Long_Form_Page__c = alreadyACustomerPage.Id
        );
        alreadyACustomerElementsList.add(alreadyACustomerAssistance);

        insert alreadyACustomerElementsList;

        List<LongForm_Element_Item__c> alreadyACustomerElementItemList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c alreadyACustomerTopHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Wir können Ihre Bestellung derzeit leider nicht bearbeiten.',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyACustomerTopHeading.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerTopHeadingItem);

        // DESCRIPTION
        LongForm_Element_Item__c alreadyACustomerDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Wir benötigen weitere Informationen, um Ihren Kreditrahmen korrekt zu berechnen. Wir werden uns in Kürze bei Ihnen melden, um alle Einzelheiten zu besprechen.',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyACustomerDescription.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerDescriptionValue);

        // PHONE
        LongForm_Element_Item__c alreadyACustomerPhoneValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '+49 911 14955287',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyACustomerPhone.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerPhoneValue);

        // EMAIL
        LongForm_Element_Item__c alreadyACustomerEmailValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'start@fleetcor.de',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyACustomerEmail.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerEmailValue);

        // WORK TIME
        LongForm_Element_Item__c alreadyACustomerWorkTimeValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '8:00 – 17:00 (von Montag bis Freitag)',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyACustomerWorkTime.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerWorkTimeValue);

        // RETURN TO SITE BUTTON
        LongForm_Element_Item__c alreadyACustomerButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'Zurück zur Homepage',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyACustomerButton.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerButtonName);

        LongForm_Element_Item__c alreadyACustomerButtonUrl = new LongForm_Element_Item__c(
                Name = 'URL',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = alreadyACustomerButton.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerButtonUrl);

        // IF YOU NEED ASSISTANCE
        LongForm_Element_Item__c alreadyACustomerAssistanceValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Easy card and service management.',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyACustomerAssistance.Id
        );
        alreadyACustomerElementItemList.add(alreadyACustomerAssistanceValue);

        insert alreadyACustomerElementItemList;
    }


    /*******************************************************************************
    *  Name            : createAlreadyInProcessPage(String deviceView)
    *  Summary         : Create already in process page
    *  CreatedDate     : 02/05/2018
    *  ModifiedDate    : 03/09/2018
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createAlreadyInProcessPage(String deviceView) {
        LongForm_Page__c alreadyInProcessPage = new LongForm_Page__c(
                Name = 'ALREADY IN PROCESS',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert alreadyInProcessPage;

        List<LongForm_Element__c> alreadyInProcessElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c alreadyInProcessTopHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = alreadyInProcessPage.Id
        );
        alreadyInProcessElementsList.add(alreadyInProcessTopHeading);

        LongForm_Element__c alreadyInProcessDescription = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyInProcessPage.Id
        );
        alreadyInProcessElementsList.add(alreadyInProcessDescription);

        LongForm_Element__c alreadyInProcessPhone = new LongForm_Element__c(
                Name = 'PHONE',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyInProcessPage.Id
        );
        alreadyInProcessElementsList.add(alreadyInProcessPhone);

        LongForm_Element__c alreadyInProcessEmail = new LongForm_Element__c(
                Name = 'EMAIL',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyInProcessPage.Id
        );
        alreadyInProcessElementsList.add(alreadyInProcessEmail);

        LongForm_Element__c alreadyInProcessWorkTime = new LongForm_Element__c(
                Name = 'WORK TIME',
                Type__c = 'Text Block',
                Long_Form_Page__c = alreadyInProcessPage.Id
        );
        alreadyInProcessElementsList.add(alreadyInProcessWorkTime);

        LongForm_Element__c alreadyInProcessAssistance = new LongForm_Element__c(
                Name = 'IF YOU NEED ASSISTANCE',
                Type__c = 'Heading',
                Long_Form_Page__c = alreadyInProcessPage.Id
        );
        alreadyInProcessElementsList.add(alreadyInProcessAssistance);

        LongForm_Element__c alreadyInProcessButton = new LongForm_Element__c(
                Name = 'RETURN TO SITE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = alreadyInProcessPage.Id
        );
        alreadyInProcessElementsList.add(alreadyInProcessButton);

        insert alreadyInProcessElementsList;

        List<LongForm_Element_Item__c> alreadyInProcessElementItemList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c alreadyInProcessTopHeadingItem = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Sorry, we can’t place your order at the moment.',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyInProcessTopHeading.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessTopHeadingItem);

        // DESCRIPTION
        LongForm_Element_Item__c alreadyInProcessDescriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'It seems we need more time to prepare proper Credit Line calculation for you. We will contact you back shortly to discuss all details.',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyInProcessDescription.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessDescriptionValue);

        // PHONE
        LongForm_Element_Item__c alreadyInProcessPhoneValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '+49 911 14955287',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyInProcessPhone.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessPhoneValue);

        // EMAIL
        LongForm_Element_Item__c alreadyInProcessEmailValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'kundenwerden@fleetcor.de',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyInProcessEmail.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessEmailValue);

        // WORK TIME
        LongForm_Element_Item__c alreadyInProcessWorkTimeValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '8:00 – 17:00 (von Montag bis Freitag)',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyInProcessWorkTime.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessWorkTimeValue);

        // IF YOU NEED ASSISTANCE
        LongForm_Element_Item__c alreadyInProcessAssistanceValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Easy card and service management.',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyInProcessAssistance.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessAssistanceValue);

        // RETURN TO SITE BUTTON
        LongForm_Element_Item__c alreadyInProcessButtonName = new LongForm_Element_Item__c(
                Name = 'BUTTON NAME',
                Active__c = true,
                Value__c = 'RETURN TO THE SITE',
                Type__c = 'Free Text',
                Long_Form_Element__c = alreadyInProcessButton.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessButtonName);

        LongForm_Element_Item__c alreadyInProcessButtonUrl = new LongForm_Element_Item__c(
                Name = 'URL',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = alreadyInProcessButton.Id
        );
        alreadyInProcessElementItemList.add(alreadyInProcessButtonUrl);

        insert alreadyInProcessElementItemList;
    }


    /*******************************************************************************
    *  Name            : createCustomerFeedbackPage(String deviceView)
    *  Summary         : create "CUSTOMER FEEDBACK" page
    *  CreatedDate     : 01/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCustomerFeedbackPage(String deviceView) {
        LongForm_Page__c customerFeedback = new LongForm_Page__c(
                Name = 'CUSTOMER FEEDBACK',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Lightbox',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert customerFeedback;

        List<LongForm_Element__c> customerFeedbackElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c customerFeedbackGrouper = new LongForm_Element__c(
                Name = 'CUSTOMER FEEDBACK GROUPER',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = customerFeedback.Id
        );
        customerFeedbackElementsList.add(customerFeedbackGrouper);

        LongForm_Element__c customerFeedbackInput = new LongForm_Element__c(
                Name = 'FEEDBACK INPUT',
                Type__c = 'Text Field',
                Long_Form_Page__c = customerFeedback.Id
        );
        customerFeedbackElementsList.add(customerFeedbackInput);

        LongForm_Element__c customerFeedbackRating = new LongForm_Element__c(
                Name = 'CUSTOMER FEEDBACK RATING',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = customerFeedback.Id
        );
        customerFeedbackElementsList.add(customerFeedbackRating);

        LongForm_Element__c customerFeedbackShowWindowCheckbox = new LongForm_Element__c(
                Name = 'DONT SHOW WINDOW',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = customerFeedback.Id
        );
        customerFeedbackElementsList.add(customerFeedbackShowWindowCheckbox);
        insert customerFeedbackElementsList;

        List<LongForm_Element_Item__c> customerFeedbackElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c defaultReason = new LongForm_Element_Item__c(
                Name = 'DEFAULT REASON',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(defaultReason);

        LongForm_Element_Item__c reasonLabel_0 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 0',
                Active__c = true,
                Value__c = 'None',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_0);

        LongForm_Element_Item__c reasonValue_0 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 0',
                Active__c = true,
                Value__c = 'None',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_0);

        LongForm_Element_Item__c reasonLabel_1 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 1',
                Active__c = true,
                Value__c = 'label 1',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_1);

        LongForm_Element_Item__c reasonValue_1 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 1',
                Active__c = true,
                Value__c = 'value 1',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_1);

        LongForm_Element_Item__c reasonLabel_2 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 2',
                Active__c = true,
                Value__c = 'label 2',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_2);

        LongForm_Element_Item__c reasonValue_2 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 2',
                Active__c = true,
                Value__c = 'value 2',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_2);

        LongForm_Element_Item__c reasonLabel_3 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 3',
                Active__c = true,
                Value__c = 'label 3',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_3);

        LongForm_Element_Item__c reasonValue_3 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 3',
                Active__c = true,
                Value__c = 'value 3',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_3);

        LongForm_Element_Item__c reasonLabel_4 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 4',
                Active__c = true,
                Value__c = 'label 4',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_4);

        LongForm_Element_Item__c reasonValue_4 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 4',
                Active__c = true,
                Value__c = 'value 4',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_4);

        LongForm_Element_Item__c reasonLabel_5 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 5',
                Active__c = true,
                Value__c = 'label 5',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_5);

        LongForm_Element_Item__c reasonValue_5 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 5',
                Active__c = true,
                Value__c = 'value 5',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_5);

        LongForm_Element_Item__c reasonLabel_6 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 6',
                Active__c = true,
                Value__c = 'label 6',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_6);

        LongForm_Element_Item__c reasonValue_6 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 6',
                Active__c = true,
                Value__c = 'value 6',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_6);

        LongForm_Element_Item__c reasonLabel_7 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 7',
                Active__c = true,
                Value__c = 'label 7',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_7);

        LongForm_Element_Item__c reasonValue_7 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 7',
                Active__c = true,
                Value__c = 'value 7',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_7);

        LongForm_Element_Item__c reasonLabel_8 = new LongForm_Element_Item__c(
                Name = 'LABEL REASON 8',
                Active__c = true,
                Value__c = 'label 8',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonLabel_8);

        LongForm_Element_Item__c reasonValue_8 = new LongForm_Element_Item__c(
                Name = 'VALUE REASON 8',
                Active__c = true,
                Value__c = 'value 8',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(reasonValue_8);

        LongForm_Element_Item__c otherReasonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL OTHER REASON',
                Active__c = true,
                Value__c = 'Other',
                Type__c = 'Label',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(otherReasonLabel);

        LongForm_Element_Item__c otherReasonValue = new LongForm_Element_Item__c(
                Name = 'VALUE OTHER REASON',
                Active__c = true,
                Value__c = 'Other',
                Type__c = 'Free Text',
                Long_Form_Element__c = customerFeedbackGrouper.Id
        );
        customerFeedbackElementItemsList.add(otherReasonValue);

        LongForm_Element_Item__c feedbackInputValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = customerFeedbackInput.Id
        );
        customerFeedbackElementItemsList.add(feedbackInputValue);

        LongForm_Element_Item__c feedbackRatingDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = customerFeedbackRating.Id
        );
        customerFeedbackElementItemsList.add(feedbackRatingDefaultValue);
        insert customerFeedbackElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createSaveAndContinueLater(String deviceView)
    *  Summary         : Create save and continue later longform page
    *  CreatedDate     : 22/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createSaveAndContinueLater(String deviceView) {
        LongForm_Page__c saveAndContinueLater = new LongForm_Page__c(
                Name = 'SAVE AND CONTINUE LATER',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert saveAndContinueLater;

        List<LongForm_Element__c> saveAndContinueLaterElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c saveAndContinueButton = new LongForm_Element__c(
                Name = 'SAVE AND CONTINUE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = saveAndContinueLater.Id
        );
        saveAndContinueLaterElementsList.add(saveAndContinueButton);

        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = saveAndContinueLater.Id
        );
        saveAndContinueLaterElementsList.add(topHeading);

        LongForm_Element__c description = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = saveAndContinueLater.Id
        );
        saveAndContinueLaterElementsList.add(description);

        LongForm_Element__c confirmSaveButton = new LongForm_Element__c(
                Name = 'CONFIRM SAVE BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = saveAndContinueLater.Id
        );
        saveAndContinueLaterElementsList.add(confirmSaveButton);

        LongForm_Element__c backToFormButton = new LongForm_Element__c(
                Name = 'BACK TO FORM BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = saveAndContinueLater.Id
        );
        saveAndContinueLaterElementsList.add(backToFormButton);

        LongForm_Element__c sendButton = new LongForm_Element__c(
                Name = 'SEND BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = saveAndContinueLater.Id
        );
        saveAndContinueLaterElementsList.add(sendButton);

        insert saveAndContinueLaterElementsList;

        List<LongForm_Element_Item__c> saveAndContinueLaterElementItemsList = new List<LongForm_Element_Item__c>();
        // SAVE AND CONTINUE BUTTON
        LongForm_Element_Item__c label = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Speichern und später fortfahren',
                Type__c = 'Label',
                Long_Form_Element__c = saveAndContinueButton.Id
        );
        saveAndContinueLaterElementItemsList.add(label);

        LongForm_Element_Item__c remark = new LongForm_Element_Item__c(
                Name = 'REMARK',
                Active__c = true,
                Value__c = 'Wir übersenden einen Link um per Mail fortzufahren',
                Type__c = 'Free Text',
                Long_Form_Element__c = saveAndContinueButton.Id
        );
        saveAndContinueLaterElementItemsList.add(remark);

        // TOP HEADING
        LongForm_Element_Item__c heading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Sind Sie sicher, dass Sie später fortfahren möchten?',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        saveAndContinueLaterElementItemsList.add(heading);

        // DESCRIPTION
        LongForm_Element_Item__c value = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Sie können den Bestellprozess zu einem späteren Zeitpunkt an der Stelle weiterbearbeiten an dem Sie aufgehört haben. Dazu senden wir Ihnen einen Link per E-Mail.',
                Type__c = 'Free Text',
                Long_Form_Element__c = description.Id
        );
        saveAndContinueLaterElementItemsList.add(value);

        // CONFIRM SAVE BUTTON
        LongForm_Element_Item__c saveButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Später fortzufahren',
                Type__c = 'Label',
                Long_Form_Element__c = confirmSaveButton.Id
        );
        saveAndContinueLaterElementItemsList.add(saveButtonLabel);

        // BACK TO FORM BUTTON
        LongForm_Element_Item__c backToFormButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zurück zum Formular',
                Type__c = 'Label',
                Long_Form_Element__c = backToFormButton.Id
        );
        saveAndContinueLaterElementItemsList.add(backToFormButtonLabel);

        // SEND BUTTON
        LongForm_Element_Item__c sendButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'SEND',
                Type__c = 'Label',
                Long_Form_Element__c = sendButton.Id
        );
        saveAndContinueLaterElementItemsList.add(sendButtonLabel);

        insert saveAndContinueLaterElementItemsList;
    }


    /*******************************************************************************
    *  Name            : createSendSepaToTheEmail(String deviceView)
    *  Summary         : Create send sepa to the email items
    *  CreatedDate     : 22/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createSendSepaToTheEmail(String deviceView) {
        LongForm_Page__c sendSepaToTheEmail = new LongForm_Page__c(
                Name = 'SEND SEPA TO THE EMAIL',
                Title__c = 'Send document to the email',
                System_Error__c = '',
                Type__c = 'Lightbox',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert sendSepaToTheEmail;

        List<LongForm_Element__c> sendSepaToTheEmailElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = sendSepaToTheEmail.Id
        );
        sendSepaToTheEmailElementsList.add(topHeading);

        LongForm_Element__c description = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendSepaToTheEmail.Id
        );
        sendSepaToTheEmailElementsList.add(description);

        LongForm_Element__c sendButton = new LongForm_Element__c(
                Name = 'SEND BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendSepaToTheEmail.Id
        );
        sendSepaToTheEmailElementsList.add(sendButton);

        LongForm_Element__c backToFormButton = new LongForm_Element__c(
                Name = 'BACK TO FORM BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendSepaToTheEmail.Id
        );
        sendSepaToTheEmailElementsList.add(backToFormButton);

        insert sendSepaToTheEmailElementsList;

        List<LongForm_Element_Item__c> elementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c heading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Do you want to send email?',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        elementItemsList.add(heading);

        // DESCRIPTION
        LongForm_Element_Item__c value = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'SEPA Document will be attached to the email.',
                Type__c = 'Free Text',
                Long_Form_Element__c = description.Id
        );
        elementItemsList.add(value);

        // SEND BUTTON
        LongForm_Element_Item__c sendButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'SEND',
                Type__c = 'Free Text',
                Long_Form_Element__c = sendButton.Id
        );
        elementItemsList.add(sendButtonLabel);

        // BACK TO FORM BUTTON
        LongForm_Element_Item__c backToFormButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zurück zum Formular',
                Type__c = 'Free Text',
                Long_Form_Element__c = sendButton.Id
        );
        elementItemsList.add(backToFormButtonLabel);

        insert elementItemsList;
    }

    /*******************************************************************************
    *  Name            : createSendDepositAgreementToTheEmail(String deviceView)
    *  Summary         : Create elements
    *  CreatedDate     : 22/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createSendDepositAgreementToTheEmail(String deviceView) {
        LongForm_Page__c sendDepositAgreement = new LongForm_Page__c(
                Name = 'SEND DEPOSIT AGREEMENT TO THE EMAIL',
                Title__c = 'Send deposit pdf to the email',
                System_Error__c = '',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert sendDepositAgreement;

        List<LongForm_Element__c> elementList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = sendDepositAgreement.Id
        );
        elementList.add(topHeading);

        LongForm_Element__c description = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendDepositAgreement.Id
        );
        elementList.add(description);

        LongForm_Element__c sendButton = new LongForm_Element__c(
                Name = 'SEND BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendDepositAgreement.Id
        );
        elementList.add(sendButton);

        LongForm_Element__c backToFormButton = new LongForm_Element__c(
                Name = 'BACK TO FORM BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendDepositAgreement.Id
        );
        elementList.add(backToFormButton);

        LongForm_Element__c emailDataBlock = new LongForm_Element__c(
                Name = 'EMAIL DATA',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendDepositAgreement.Id
        );
        elementList.add(emailDataBlock);

        insert elementList;

        List<LongForm_Element_Item__c> elementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c heading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Do you want to send email?',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        elementItemsList.add(heading);

        // DESCRIPTION
        LongForm_Element_Item__c descriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Deposit Agreement will be attached to the email.',
                Type__c = 'Free Text',
                Long_Form_Element__c = description.Id
        );
        elementItemsList.add(descriptionValue);

        // SEND BUTTON
        LongForm_Element_Item__c sendButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'SEND',
                Type__c = 'Free Text',
                Long_Form_Element__c = sendButton.Id
        );
        elementItemsList.add(sendButtonLabel);

        // BACK TO FORM BUTTON
        LongForm_Element_Item__c backToFormButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zurück zum Formular',
                Type__c = 'Free Text',
                Long_Form_Element__c = backToFormButton.Id
        );
        elementItemsList.add(backToFormButtonLabel);

        // EMAIL DATA
        LongForm_Element_Item__c fileName = new LongForm_Element_Item__c(
                Name = 'FILENAME',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(fileName);

        LongForm_Element_Item__c subject = new LongForm_Element_Item__c(
                Name = 'SUBJECT',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(subject);

        LongForm_Element_Item__c body = new LongForm_Element_Item__c(
                Name = 'BODY',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(body);

        LongForm_Element_Item__c mrElementItem = new LongForm_Element_Item__c(
                Name = 'MR',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(mrElementItem);

        LongForm_Element_Item__c msElementItem = new LongForm_Element_Item__c(
                Name = 'MS',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(msElementItem);

        insert elementItemsList;
    }


    /*******************************************************************************
    *  Name            : createSendHowToPay(String deviceView)
    *  Summary         : Create elements
    *  CreatedDate     : 22/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createSendHowToPay(String deviceView) {
        LongForm_Page__c sendHowToPay = new LongForm_Page__c(
                Name = 'SEND HOW TO PAY TO THE EMAIL',
                Title__c = 'Send How to pay despoit to the email',
                System_Error__c = '',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert sendHowToPay;

        List<LongForm_Element__c> elementList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(topHeading);

        LongForm_Element__c description = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(description);

        LongForm_Element__c sendButton = new LongForm_Element__c(
                Name = 'SEND BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(sendButton);

        LongForm_Element__c backToFormButton = new LongForm_Element__c(
                Name = 'BACK TO FORM BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(backToFormButton);

        LongForm_Element__c emailDataBlock = new LongForm_Element__c(
                Name = 'EMAIL DATA',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(emailDataBlock);

        insert elementList;

        List<LongForm_Element_Item__c> elementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c heading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Do you want to send email?',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        elementItemsList.add(heading);

        // DESCRIPTION
        LongForm_Element_Item__c descriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Deposit Agreement will be attached to the email.',
                Type__c = 'Free Text',
                Long_Form_Element__c = description.Id
        );
        elementItemsList.add(descriptionValue);

        // SEND BUTTON
        LongForm_Element_Item__c sendButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'SEND',
                Type__c = 'Free Text',
                Long_Form_Element__c = sendButton.Id
        );
        elementItemsList.add(sendButtonLabel);

        // BACK TO FORM BUTTON
        LongForm_Element_Item__c backToFormButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zurück zum Formular',
                Type__c = 'Free Text',
                Long_Form_Element__c = backToFormButton.Id
        );
        elementItemsList.add(backToFormButtonLabel);

        // EMAIL DATA
        LongForm_Element_Item__c fileName = new LongForm_Element_Item__c(
                Name = 'FILENAME',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(fileName);

        LongForm_Element_Item__c subject = new LongForm_Element_Item__c(
                Name = 'SUBJECT',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(subject);

        LongForm_Element_Item__c body = new LongForm_Element_Item__c(
                Name = 'BODY',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(body);

        LongForm_Element_Item__c mrElementItem = new LongForm_Element_Item__c(
                Name = 'MR',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(mrElementItem);

        LongForm_Element_Item__c msElementItem = new LongForm_Element_Item__c(
                Name = 'MS',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(msElementItem);

        insert elementItemsList;
    }


    /*******************************************************************************
    *  Name            : createSendTC(String deviceView)
    *  Summary         : Create elements
    *  CreatedDate     : 22/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createSendTC(String deviceView) {
        LongForm_Page__c sendHowToPay = new LongForm_Page__c(
                Name = 'SEND TC TO THE EMAIL',
                Title__c = 'Send Terms and Conditions to the email',
                System_Error__c = '',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert sendHowToPay;

        List<LongForm_Element__c> elementList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(topHeading);

        LongForm_Element__c description = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(description);

        LongForm_Element__c sendButton = new LongForm_Element__c(
                Name = 'SEND BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(sendButton);

        LongForm_Element__c backToFormButton = new LongForm_Element__c(
                Name = 'BACK TO FORM BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(backToFormButton);

        LongForm_Element__c emailDataBlock = new LongForm_Element__c(
                Name = 'EMAIL DATA',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendHowToPay.Id
        );
        elementList.add(emailDataBlock);

        insert elementList;

        List<LongForm_Element_Item__c> elementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c heading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Do you want to send email?',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        elementItemsList.add(heading);

        // DESCRIPTION
        LongForm_Element_Item__c descriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'TC Document will be attached to the email.',
                Type__c = 'Free Text',
                Long_Form_Element__c = description.Id
        );
        elementItemsList.add(descriptionValue);

        // SEND BUTTON
        LongForm_Element_Item__c sendButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'SEND',
                Type__c = 'Free Text',
                Long_Form_Element__c = sendButton.Id
        );
        elementItemsList.add(sendButtonLabel);

        // BACK TO FORM BUTTON
        LongForm_Element_Item__c backToFormButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zurück zum Formular',
                Type__c = 'Free Text',
                Long_Form_Element__c = backToFormButton.Id
        );
        elementItemsList.add(backToFormButtonLabel);

        // EMAIL DATA
        LongForm_Element_Item__c fileName = new LongForm_Element_Item__c(
                Name = 'FILENAME',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(fileName);

        LongForm_Element_Item__c subject = new LongForm_Element_Item__c(
                Name = 'SUBJECT',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(subject);

        LongForm_Element_Item__c body = new LongForm_Element_Item__c(
                Name = 'BODY',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(body);

        LongForm_Element_Item__c mrElementItem = new LongForm_Element_Item__c(
                Name = 'MR',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(mrElementItem);

        LongForm_Element_Item__c msElementItem = new LongForm_Element_Item__c(
                Name = 'MS',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(msElementItem);

        insert elementItemsList;
    }


    /*******************************************************************************
    *  Name            : createSendTC(String deviceView)
    *  Summary         : Create elements
    *  CreatedDate     : 22/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createDDMandate(String deviceView) {
        LongForm_Page__c sendDDMandate = new LongForm_Page__c(
                Name = 'SEND DDMANDATE TO THE EMAIL',
                Title__c = 'Send Terms and Conditions to the email',
                System_Error__c = '',
                Type__c = 'Inline',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert sendDDMandate;

        List<LongForm_Element__c> elementList = new List<LongForm_Element__c>();
        LongForm_Element__c topHeading = new LongForm_Element__c(
                Name = 'TOP HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = sendDDMandate.Id
        );
        elementList.add(topHeading);

        LongForm_Element__c description = new LongForm_Element__c(
                Name = 'DESCRIPTION',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendDDMandate.Id
        );
        elementList.add(description);

        LongForm_Element__c sendButton = new LongForm_Element__c(
                Name = 'SEND BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendDDMandate.Id
        );
        elementList.add(sendButton);

        LongForm_Element__c backToFormButton = new LongForm_Element__c(
                Name = 'BACK TO FORM BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = sendDDMandate.Id
        );
        elementList.add(backToFormButton);

        LongForm_Element__c emailDataBlock = new LongForm_Element__c(
                Name = 'EMAIL DATA',
                Type__c = 'Text Block',
                Long_Form_Page__c = sendDDMandate.Id
        );
        elementList.add(emailDataBlock);

        insert elementList;

        List<LongForm_Element_Item__c> elementItemsList = new List<LongForm_Element_Item__c>();
        // TOP HEADING
        LongForm_Element_Item__c heading = new LongForm_Element_Item__c(
                Name = 'HEADING',
                Active__c = true,
                Value__c = 'Do you want to send email?',
                Type__c = 'Free Text',
                Long_Form_Element__c = topHeading.Id
        );
        elementItemsList.add(heading);

        // DESCRIPTION
        LongForm_Element_Item__c descriptionValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'TC Document will be attached to the email.',
                Type__c = 'Free Text',
                Long_Form_Element__c = description.Id
        );
        elementItemsList.add(descriptionValue);

        // SEND BUTTON
        LongForm_Element_Item__c sendButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'SEND',
                Type__c = 'Free Text',
                Long_Form_Element__c = sendButton.Id
        );
        elementItemsList.add(sendButtonLabel);

        // BACK TO FORM BUTTON
        LongForm_Element_Item__c backToFormButtonLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Zurück zum Formular',
                Type__c = 'Free Text',
                Long_Form_Element__c = backToFormButton.Id
        );
        elementItemsList.add(backToFormButtonLabel);

        // EMAIL DATA
        LongForm_Element_Item__c fileName = new LongForm_Element_Item__c(
                Name = 'FILENAME',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(fileName);

        LongForm_Element_Item__c subject = new LongForm_Element_Item__c(
                Name = 'SUBJECT',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(subject);

        LongForm_Element_Item__c body = new LongForm_Element_Item__c(
                Name = 'BODY',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(body);

        LongForm_Element_Item__c mrElementItem = new LongForm_Element_Item__c(
                Name = 'MR',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(mrElementItem);

        LongForm_Element_Item__c msElementItem = new LongForm_Element_Item__c(
                Name = 'MS',
                Active__c = true,
                Value__c = 'test',
                Type__c = 'Free Text',
                Long_Form_Element__c = emailDataBlock.Id
        );
        elementItemsList.add(msElementItem);

        insert elementItemsList;
    }


    /*******************************************************************************
    *  Name            : createCongratulationsPage(String deviceView)
    *  Summary         : Create elements
    *  CreatedDate     : 22/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createCongratulationsPage(String deviceView) {
        LongForm_Page__c congratulationsPage = new LongForm_Page__c(
                Name = 'CONGRATULATIONS',
                Title__c = 'Send Terms and Conditions to the email',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_view__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert congratulationsPage;

        List<LongForm_Element__c> elementList = new List<LongForm_Element__c>();

        LongForm_Element__c howToPayBlock = new LongForm_Element__c(
                Name = 'HOW TO PAY BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = congratulationsPage.Id
        );
        elementList.add(howToPayBlock);

        LongForm_Element__c directDebitMandate = new LongForm_Element__c(
                Name = 'DIRECT DEBIT MANDATE ACCEPTANCE BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = congratulationsPage.Id
        );
        elementList.add(directDebitMandate);

        LongForm_Element__c clubSmart = new LongForm_Element__c(
                Name = 'CLUB SMART',
                Type__c = 'Text Block',
                Long_Form_Page__c = congratulationsPage.Id
        );
        elementList.add(clubSmart);

        LongForm_Element__c modalProgramDetails = new LongForm_Element__c(
                Name = 'MODAL PROGRAM DETAILS',
                Type__c = 'Text Block',
                Long_Form_Page__c = congratulationsPage.Id
        );
        elementList.add(modalProgramDetails);

        LongForm_Element__c additionalInfoBlock = new LongForm_Element__c(
                Name = 'ADDITIONAL INFO BLOCK',
                Type__c = 'Text Block',
                Long_Form_Page__c = congratulationsPage.Id
        );
        elementList.add(additionalInfoBlock);
        insert elementList;

        List<LongForm_Element_Item__c> elementItemsList = new List<LongForm_Element_Item__c>();
        // HOW TO PAY BLOCK
        LongForm_Element_Item__c savePaymentInformationButton = new LongForm_Element_Item__c(
                Name = 'SAVE PAYMENT INFORMATION DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = howToPayBlock.Id
        );
        elementItemsList.add(savePaymentInformationButton);

        // DIRECT DEBIT MANDATE ACCEPTANCE BLOCK
        LongForm_Element_Item__c downloadUrlDDM = new LongForm_Element_Item__c(
                Name = 'DOWNLOAD URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = directDebitMandate.Id
        );
        elementItemsList.add(downloadUrlDDM);

        LongForm_Element_Item__c iframeUrlDDM = new LongForm_Element_Item__c(
                Name = 'DOCUMENT. IFRAME URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = directDebitMandate.Id
        );
        elementItemsList.add(iframeUrlDDM);

        // CLUB SMART
        LongForm_Element_Item__c programDetailsLabel = new LongForm_Element_Item__c(
                Name = 'PROGRAM DETAILS LABEL',
                Active__c = true,
                Value__c = 'Details zum Prämienprogramm',
                Type__c = 'Label',
                Long_Form_Element__c = clubSmart.Id
        );
        elementItemsList.add(programDetailsLabel);

        LongForm_Element_Item__c bonusAgreementButton = new LongForm_Element_Item__c(
                Name = 'BONUS AGREEMENT BUTTON',
                Active__c = true,
                Value__c = 'Clubsmart bestellen',
                Type__c = 'Label',
                Long_Form_Element__c = clubSmart.Id
        );
        elementItemsList.add(bonusAgreementButton);

        LongForm_Element_Item__c returnToSiteButton = new LongForm_Element_Item__c(
                Name = 'RETURN TO SITE BUTTON',
                Active__c = true,
                Value__c = 'Zurück zur Homepage',
                Type__c = 'Label',
                Long_Form_Element__c = clubSmart.Id
        );
        elementItemsList.add(returnToSiteButton);

        LongForm_Element_Item__c returnToSiteUrl = new LongForm_Element_Item__c(
                Name = 'RETURN TO SITE URL',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = clubSmart.Id
        );
        elementItemsList.add(returnToSiteUrl);

        // MODAL PROGRAM DETAILS
        LongForm_Element_Item__c moreInfoLabel = new LongForm_Element_Item__c(
                Name = 'MORE INFO LABEL',
                Active__c = true,
                Value__c = 'Shell ClubSmart',
                Type__c = 'Label',
                Long_Form_Element__c = modalProgramDetails.Id
        );
        elementItemsList.add(moreInfoLabel);

        LongForm_Element_Item__c moreInfoUrl = new LongForm_Element_Item__c(
                Name = 'MORE INFO URL',
                Active__c = true,
                Value__c = 'https://www.shellsmart.com/',
                Type__c = 'URL',
                Long_Form_Element__c = modalProgramDetails.Id
        );
        elementItemsList.add(moreInfoUrl);

        LongForm_Element_Item__c okButton = new LongForm_Element_Item__c(
                Name = 'OK BUTTON',
                Active__c = true,
                Value__c = 'ОК',
                Type__c = 'Label',
                Long_Form_Element__c = modalProgramDetails.Id
        );
        elementItemsList.add(okButton);

        // ADDITIONAL INFO BLOCK
        LongForm_Element_Item__c additionalReturnToSiteButton = new LongForm_Element_Item__c(
                Name = 'RETURN TO SITE BUTTON',
                Active__c = true,
                Value__c = 'Zurück zur Homepage',
                Type__c = 'Label',
                Long_Form_Element__c = additionalInfoBlock.Id
        );
        elementItemsList.add(additionalReturnToSiteButton);

        LongForm_Element_Item__c additionalReturnToSite = new LongForm_Element_Item__c(
                Name = 'RETURN TO SITE URL',
                Active__c = true,
                Value__c = 'https://fleetcor.de/',
                Type__c = 'URL',
                Long_Form_Element__c = additionalInfoBlock.Id
        );
        elementItemsList.add(additionalReturnToSite);

        insert elementItemsList;
    }

    /*******************************************************************************
    *  Name            : createJITBLocatorData(String deviceView)
    *  Summary         : Create jitb data
    *  CreatedDate     : 17/04/2019
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public static void createJITBLocatorData(String deviceView) {
        LongForm_Page__c jitbLocator = new LongForm_Page__c(
                Name = 'JITBLocator',
                Title__c = '',
                System_Error__c = '',
                Type__c = 'Basic',
                Device_View__c = deviceView,
                Long_Form__c = longFormDE.Id
        );
        insert jitbLocator;

        List<LongForm_Element__c> jitbLocatorElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c body = new LongForm_Element__c(
                Name = 'BODY',
                Type__c = 'Heading',
                Long_Form_Page__c = jitbLocator.Id
        );
        jitbLocatorElementsList.add(body);

        LongForm_Element__c locatorUrl = new LongForm_Element__c(
                Name = 'LOCATOR URL',
                Type__c = 'URL',
                Long_Form_Page__c = jitbLocator.Id
        );
        jitbLocatorElementsList.add(locatorUrl);

        LongForm_Element__c stationButton = new LongForm_Element__c(
                Name = 'CHOOSE STATION BUTTON',
                Type__c = 'Button',
                Long_Form_Page__c = jitbLocator.Id
        );
        jitbLocatorElementsList.add(stationButton);

        LongForm_Element__c stationHeading = new LongForm_Element__c(
                Name = 'FAVOURITE STATION HEADING',
                Type__c = 'Heading',
                Long_Form_Page__c = jitbLocator.Id
        );
        jitbLocatorElementsList.add(stationHeading);

        insert jitbLocatorElementsList;

        List<LongForm_Element_Item__c> jitbLocatorElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c bodyValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'TSehr geehrter Kunde, bitte teilen Sie uns mit, an welcher Shell-Station Sie unsere Werbematerialien gesehen haben.',
                Type__c = 'Free Text',
                Long_Form_Element__c = body.Id
        );
        jitbLocatorElementItemsList.add(bodyValue);

        LongForm_Element_Item__c basic = new LongForm_Element_Item__c(
                Name = 'BASIC',
                Active__c = true,
                Value__c = 'https://eurolocator.fleetcor.de/?product=4&locationRequest=0&lang=de&mode=choose-station&address=',
                Type__c = 'URL',
                Long_Form_Element__c = locatorUrl.Id
        );
        jitbLocatorElementItemsList.add(basic);

        LongForm_Element_Item__c zoomParam = new LongForm_Element_Item__c(
                Name = 'ZOOM PARAM',
                Active__c = true,
                Value__c = '&zoom=12',
                Type__c = 'URL',
                Long_Form_Element__c = locatorUrl.Id
        );
        jitbLocatorElementItemsList.add(zoomParam);

        LongForm_Element_Item__c stationButtonValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Auswählen',
                Type__c = 'Free Text',
                Long_Form_Element__c = stationButton.Id
        );
        jitbLocatorElementItemsList.add(stationButtonValue);

        LongForm_Element_Item__c stationHeadingValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = 'Stammtankstelle:',
                Type__c = 'Free Text',
                Long_Form_Element__c = stationHeading.Id
        );
        jitbLocatorElementItemsList.add(stationHeadingValue);

        insert jitbLocatorElementItemsList;
    }

    public static void createContentForCards(String fuelProductName, String evProductName, String fuelIntegrationName, String evIntegrationName) {
        RecordType fleetcorRt = [SELECT Id FROM RecordType WHERE Name = 'FLEETCOR'];
        Product2 typeBProduct = new Product2(
                Name = fuelProductName,
                CurrencyIsoCode = 'EUR',
                IsActive = true,
                Family = 'SHELL',
                Integration_Name__c = fuelIntegrationName,
                RecordTypeId = fleetcorRt.Id
        );
        insert typeBProduct;

        Offer_Item_Type__c shellFuelCards = new Offer_Item_Type__c(Name = 'Shell Fuel Card');
        insert shellFuelCards;

        Offer_to_Item_Type_Junction__c junctionTypeB = new Offer_to_Item_Type_Junction__c(
                Product__c = typeBProduct.Id,
                Offer_Item_Type__c = shellFuelCards.Id
        );
        insert junctionTypeB;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbeTypeB = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = typeBProduct.Id,
                UnitPrice = 10,
                IsActive = true,
                CurrencyIsoCode = 'EUR'
        );
        insert pbeTypeB;

        Product2 evDeProduct = new Product2(
                Name = evProductName,
                CurrencyIsoCode = 'EUR',
                Family = 'EV',
                Integration_Name__c = evIntegrationName,
                IsActive = true,
                RecordTypeId = fleetcorRt.Id
        );
        insert evDeProduct;

        Offer_Item_Type__c evFob = new Offer_Item_Type__c(Name = 'EV Fob');
        insert evFob;

        Offer_to_Item_Type_Junction__c junctionEVFob = new Offer_to_Item_Type_Junction__c(
                Product__c = evDeProduct.Id,
                Offer_Item_Type__c = evFob.Id
        );
        insert junctionEVFob;

        PricebookEntry pbeEVDe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = evDeProduct.Id,
                UnitPrice = 10,
                IsActive = true,
                CurrencyIsoCode = 'EUR'
        );
        insert pbeEVDe;
    }
}