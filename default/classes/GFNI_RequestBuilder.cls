/**
 * Created by Nikita.Mikhailov on 21.01.2019.
 * Class for creating REST request to the GFNI via IBM GW
 * Fields logic defined in mapping documents and GFNI_Mapping static resource
 */
public with sharing class GFNI_RequestBuilder {

//    public static String buildJSONGetCustomerId(Opportunity opp) {
////        Opportunity opp = [
////                SELECT Id, Account.Account_Nr__c, Account.Name, Account.Umsatzsteuer_ID__c, Account.BillingCountryCode,
////                        Account.BillingCountry, Account.Owner.Name, (SELECT Id, Contact.Email FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
////                FROM Opportunity
////                WHERE Id = :opportunity.Id
////        ];
//
//        GFNI_GetCustomerIdRequest getCustomerIdRequest = new GFNI_GetCustomerIdRequest();
//        getCustomerIdRequest.Metadata = buildMetadataObject(opp.Account);
//
//        getCustomerIdRequest.Name = opp.Account.Name;
//        getCustomerIdRequest.EmailAddress = opp.OpportunityContactRoles.get(0).Contact.Email;
//        getCustomerIdRequest.CompanyRegNumber = opp.Account.Account_Nr__c;
//        getCustomerIdRequest.VATNumber = opp.Account.Umsatzsteuer_ID__c;
//
//        return JSON.serialize(getCustomerIdRequest);
//    }


    /*******************************************************************************
    *  Name            : buildJSONCreateCustomerAndCards
    *  Summary         : build create new customer with cards REST request. Mapping are provided by business in mapping doc
    *  CreatedDate     : 21/01/2019
    *  Parameters      : Set<Id> opptysToUpdate
    *  Returns         : void
    ******************************************************************************/
    public static String buildJSONCreateCustomerAndCards(Opportunity opportunity) {

        /*******************************************************************************
        *   Mapping for GFN Ids is presented as JSON file in static resources - GFNI_Mapping. First get look into it!
        *   Examples of not standard data input:
        *       acc.BillingCountryCode.substring(0, 2) - there may situation when in country code we can have doubled value (BENL, CHFR etc.). In that case need to use first two letters to get country code. Confirmed by Fučíková Michaela <michaela.fucikova@fleetcor.de>
        *       gfni_contact.Primary = contact.IsPrimary == true ? 1 : 0 - as long GFN is not understand "true" or "false" as boolean this code changes boolean to integer 1 or 0
        ******************************************************************************/

        Opportunity opp = [
                SELECT  Name, AccountId, Id, Sec_Channel__c, Language_preference__c, Owner.FirstName,
                        Owner.LastName, Owner.Name, SWIFT_BIC__c, IBAN__c, Credit_System_Number__c, Product__c,
                        ESI__c, Total_number_of_vehicles__c, Total_consumption_l_month__c, Zahlungsart__c, Credit_Limit__c,
                        Zahlungsziel_Credit__c, Risk_Category__c, Next_Review_Date__c, Rechnungsperiode__c, Papierrechnung__c, e_Invoicing_PDF__c,
                        Credit_System_Rating__c, Garantie__c, Garantie_other__c,Eco_Fee__c,
                        VAT_Recovery__c, Direct_Debit_Mandate_Type__c, Custom_PIN__c, RecordType.Name,
                        (SELECT Contact.Id, Contact.Name, Contact.Salutation, Contact.FirstName, Contact.MiddleName, Contact.LastName,
                                Role, Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.Fax, IsPrimary
                         FROM   OpportunityContactRoles),
                        (SELECT Id, Name, Gewuenschter_Kartentyp__c, Produktbezugskategorie__c, Fahrzeugtyp__c, Firmenname_auf_der_Karte__c,
                                KFZ_Kennzeichen_oder_Fahrername__c, Driver_Name__c, Kilometerstand_Abfrage__c, Daily_limit_per_card_PLN__c, Monthly_limit_per_card_PLN__c
                         FROM   Tankkarten__r),
                        (SELECT Id, Product2.Family, Product_Name__c
                         FROM   OpportunityLineItems)
                FROM    Opportunity
                WHERE   Id =: opportunity.Id
        ];

        Account acc = [
                SELECT  Id, Owner.Name, Account_Nr__c, Name, Steuernummer__c, HR_Abteilung_HRA_HRB_und_HR_Nummer__c,
                        Umsatzsteuer_ID__c, BillingCountry, BillingCountryCode, BillingState, BillingCity,
                        BillingPostalCode, BillingStreet, ShippingCountry, ShippingCountryCode, ShippingState,
                        ShippingCity, ShippingPostalCode, ShippingStreet, Phone, UMR__c
                FROM    Account
                WHERE   Id =: opp.AccountId
        ];

        String billingCountryCode;
        if (String.isNotBlank(acc.BillingCountryCode)) {
            billingCountryCode = acc.BillingCountryCode.substring(0, 2);
        } else {
            throw new GlobalException('Billing country code is empty.');
        }

        GFNI_Customer customer = new GFNI_Customer();
        String product = GFNI_Utils.getUniqueProduct(opp);
        GFNI_CommunicationPreferences communicationPreferences = new GFNI_CommunicationPreferences();

        if (opp.Papierrechnung__c) {
            communicationPreferences.InvoicingType = 'Print';
            communicationPreferences.OutputTypeId = GFNI_Utils.getIntegerValue('Print', null, 'OutputTypeId');
        } else {
            communicationPreferences.InvoicingType = 'Email';
            communicationPreferences.OutputTypeId = opp.e_Invoicing_PDF__c ? GFNI_Utils.getIntegerValue('Link', null, 'OutputTypeId') : GFNI_Utils.getIntegerValue('PDF', null, 'OutputTypeId');
        }

        GFNI_BankAccount bankAccount = new GFNI_BankAccount();
        GFNI_PaymentInfo paymentInfo = new GFNI_PaymentInfo();

        Map<String, Object> paymentMethodMapping = (Map<String, Object>) GFNI_Utils.gfniMapping.get('PaymentMethodId');
        Map<String, Object> paymentMethodCountryMapping = (Map<String, Object>) paymentMethodMapping.get(billingCountryCode);

        List<Object> countryCEEPolicy = (List<Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'CEEPaymentPolicy');
        if (!countryCEEPolicy.contains(billingCountryCode)) {
            if (paymentMethodCountryMapping.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)) instanceof Map<String, Object>) {
                Map<String, Object> paymentMethodDDMapping = (Map<String, Object>) paymentMethodCountryMapping.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c));
                paymentInfo.PaymentMethodId = Integer.valueOf(paymentMethodDDMapping.get(opp.Direct_Debit_Mandate_Type__c));
            } else {
                paymentInfo.PaymentMethodId = Integer.valueOf(paymentMethodCountryMapping.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)));
            }

            if (!GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)).equals('Bank transfer')) {
                bankAccount.SwiftCode = opp.SWIFT_BIC__c;

                if (String.isNotBlank(opp.IBAN__c)) {
                    bankAccount.IBAN = opp.IBAN__c.replaceAll('\\W', '');
                }

                bankAccount.DDRefNo = acc.UMR__c;
                bankAccount.DDEffectiveDate = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('yyyy-MM-dd');
                bankAccount.DDMandateTypeId = GFNI_Utils.getIntegerValue(opp.Direct_Debit_Mandate_Type__c, null, 'DirectDebitMandateTypeID');
            }
        } else {
            paymentInfo.PaymentMethodId = Integer.valueOf(paymentMethodCountryMapping.get('Bank transfer'));
        }

        if (String.isNotBlank(opp.Zahlungsziel_Credit__c)) {
            paymentInfo.PaymentTermsId = GFNI_Utils.getIntegerValue(opp.Zahlungsziel_Credit__c, null, 'PaymentTermsId');
        } else {
            throw new GlobalException('Payment terms Credit is empty.');
        }

        Map<String, Object> paymentFrequencyIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'PaymentFrequencyId');
        Map<String, Object> paymentFrequencyIdCountry = (Map<String, Object>) paymentFrequencyIdMapping.get(billingCountryCode);
        paymentInfo.PaymentFrequencyId = Integer.valueOf(paymentFrequencyIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Rechnungsperiode__c.getDescribe(), opp.Rechnungsperiode__c)));

        paymentInfo.addBankAccount(bankAccount);

        List<GFNI_Card> cardOrder = new List<GFNI_Card>();

        //STCP1-240 Field mapping update for EV
        //Ситуация при которой у нас не возможны дубли в Tankkarten__c и OpportunityLineItems

        Map<String, Object> cardIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'CardTypeId');
        Map<String, Object> cardIdCountry = (Map<String, Object>) cardIdMapping.get(GlobalUtils.blankStringIfNull(billingCountryCode));

        Map<String, Object> purchaseCategoryIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'PurchaseCategoryId');
        Map<String, Object> purchaseCategoryIdCountry = (Map<String, Object>) purchaseCategoryIdMapping.get(GlobalUtils.blankStringIfNull(billingCountryCode));

        List<Tankkarten__c> cardsWithInvalidCardTypeId = new List<Tankkarten__c>();

        //Пишем карты из Tannkarten если они есть
        if (!opp.Tankkarten__r.isEmpty()) {
            if (!opp.Custom_PIN__c) {

                for (Tankkarten__c card : opp.Tankkarten__r) {
                    GFNI_Card gfni_card = new GFNI_Card();

                    gfni_card.CardRefId = GlobalUtils.generateGUIDFromId(card.Id);
                    if(opp.RecordType.Name == 'Lotos') {
                        gfni_card.MonthlyCardLimit = Integer.valueOf(card.Monthly_limit_per_card_PLN__c);
                        gfni_card.DailyCardLimit = Integer.valueOf(card.Daily_limit_per_card_PLN__c);
                    }


                    if (card.Driver_Name__c == null) {
                        //vehicle
                        gfni_card.CardCategoryId = GFNI_Utils.getIntegerValue('Vehicle', null, 'CardCategoryId');
                        gfni_card.EmbossingId = GFNI_Utils.getIntegerValue('Vehicle', null, 'EmbossingId');
                        gfni_card.VehicleRegistrationNumber = GFNI_Utils.replaceSpecialCharacters(card.KFZ_Kennzeichen_oder_Fahrername__c);
                    } else {
                        //driver
                        gfni_card.CardCategoryId = GFNI_Utils.getIntegerValue('Driver', null, 'CardCategoryId');
                        gfni_card.EmbossingId = GFNI_Utils.getIntegerValue('Driver', null, 'EmbossingId');
                        gfni_card.DriverName = GFNI_Utils.replaceSpecialCharacters(card.Driver_Name__c);
                    }

                    if (gfni_card.DriverName == null && gfni_card.VehicleRegistrationNumber == null) {
                        throw new GlobalException('Driver name and Vehicle Registration Number are empty on card: ' + card.Name);
                    }

                    Map<String, Object> cardIdBusiness = null;
                    if (String.isNotBlank(card.Fahrzeugtyp__c)) {
                        cardIdBusiness = (Map<String, Object>) cardIdCountry.get(GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Fahrzeugtyp__c.getDescribe(), card.Fahrzeugtyp__c)));
                    } else {
                        throw new GlobalException('Type of the vehicle is empty on card: ' + card.Name);
                    }

                    if (cardIdBusiness == null) {
                        throw new GlobalException('Type of the vehicle ' + GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Fahrzeugtyp__c.getDescribe(), card.Fahrzeugtyp__c) + ' is not mapped on card: ' + card.Name);
                    }

                    if (String.isNotBlank(card.Gewuenschter_Kartentyp__c)) {
                        gfni_card.CardTypeId = Integer.valueOf(cardIdBusiness.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Gewuenschter_Kartentyp__c.getDescribe(), card.Gewuenschter_Kartentyp__c)));
                    } else {
                        throw new GlobalException('Type of Card is empty on card: ' + card.Name);
                    }

                    if (gfni_card.CardTypeId == null)
                        cardsWithInvalidCardTypeId.add(card);

                    gfni_card.OdometerPromptRequired = card.Kilometerstand_Abfrage__c == true ? 1 : 0;

                    if (String.isNotBlank(card.Produktbezugskategorie__c)) {
                        if (purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Produktbezugskategorie__c.getDescribe(), card.Produktbezugskategorie__c)) instanceof Map<String, Object>) {
                            Map<String, Object> purchaseCategoryIdNational = (Map<String, Object>) purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Produktbezugskategorie__c.getDescribe(), card.Produktbezugskategorie__c));
                            gfni_card.PurchaseCategoryId = Integer.valueOf(purchaseCategoryIdNational.get((GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Gewuenschter_Kartentyp__c.getDescribe(), card.Gewuenschter_Kartentyp__c)).split('.+ -- ').get(1)));
                        } else {
                            gfni_card.PurchaseCategoryId = Integer.valueOf(purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Produktbezugskategorie__c.getDescribe(), card.Produktbezugskategorie__c)));
                        }
                    } else {
                        throw new GlobalException('Category of product is empty on card: ' + card.Name);
                    }

                    cardOrder.add(gfni_card);
                }
            }
        }

        //TODO: check this peace of code - does it need this if statement?
        if (!opp.Tankkarten__r.isEmpty()) {
            if (String.isNotBlank(GFNI_Utils.replaceSpecialCharacters(opp.Tankkarten__r.get(0).Firmenname_auf_der_Karte__c))) {
                customer.ShortName = GFNI_Utils.replaceSpecialCharacters(opp.Tankkarten__r.get(0).Firmenname_auf_der_Karte__c);
            }
        }

        List<Offer_Item__c> offerItemsWithInvalidCardTypeId = new List<Offer_Item__c>();

        //STCP1-240 Field mapping update for EV
        //Пишем из OpportunityLineItem если они есть
        if (!opp.OpportunityLineItems.isEmpty()) {

            Set<Id> lineItemsIds = new Set<Id>();
            for (OpportunityLineItem lineItem : opp.OpportunityLineItems) {
                lineItemsIds.add(lineItem.Id);
            }

            List<Offer_Item__c> offerItemsList = [
                    SELECT Id, Offer_Item_Type__r.Name, Driver_Name__c, License_plate_number__c,
                            Type_of_Vehicle__c, Type_of_Card__c, Mileage_data__c, Category_of_products__c,
                            Opportunity_Product_Id__c, Company_Name__c
                    FROM Offer_Item__c
                    WHERE Opportunity_Product_Id__c IN :lineItemsIds
            ];

            Map<String, List<Offer_Item__c>> offerItemsMap = new Map<String, List<Offer_Item__c>>();
            for (Offer_Item__c offerItem : offerItemsList) {
                if (offerItemsMap.containsKey(offerItem.Opportunity_Product_Id__c)) {
                    offerItemsMap.get(offerItem.Opportunity_Product_Id__c).add(offerItem);
                } else {
                    List<Offer_Item__c> offerItems = new List<Offer_Item__c>{
                            offerItem
                    };
                    offerItemsMap.put(offerItem.Opportunity_Product_Id__c, offerItems);
                }
            }

            for (OpportunityLineItem lineItem : opp.OpportunityLineItems) {

                if (offerItemsMap.containsKey(lineItem.Id)) {
                    for (Offer_Item__c offerItem : offerItemsMap.get(lineItem.Id)) {
                        if (!String.isNotBlank(customer.ShortName)) {
                            if (String.isNotBlank(GFNI_Utils.replaceSpecialCharacters(offerItem.Company_Name__c))) {
                                customer.ShortName = GFNI_Utils.replaceSpecialCharacters(offerItem.Company_Name__c);
                            }
                        }
                        if(!opp.Custom_PIN__c || lineItem.Product2.Family.equals('EV')) {
                            GFNI_Card gfni_card = new GFNI_Card();

                            gfni_card.CardRefId = GlobalUtils.generateGUIDFromId(offerItem.Id);

                            if (String.isNotBlank(offerItem.Driver_Name__c)) {
                                //driver
                                gfni_card.CardCategoryId = GFNI_Utils.getIntegerValue('Driver', null, 'CardCategoryId');
                                gfni_card.EmbossingId = GFNI_Utils.getIntegerValue('Driver', null, 'EmbossingId');
                                gfni_card.DriverName = GFNI_Utils.replaceSpecialCharacters(offerItem.Driver_Name__c);
                            } else {
                                //vehicle
                                gfni_card.CardCategoryId = GFNI_Utils.getIntegerValue('Vehicle', null, 'CardCategoryId');
                                gfni_card.EmbossingId = GFNI_Utils.getIntegerValue('Vehicle', null, 'EmbossingId');
                                gfni_card.VehicleRegistrationNumber = GFNI_Utils.replaceSpecialCharacters(offerItem.License_plate_number__c);
                            }

                            if (cardIdCountry.get(GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Type_of_Vehicle__c.getDescribe(), offerItem.Type_of_Vehicle__c))) != null) {

                                if (!String.isNotBlank(offerItem.Type_of_Card__c)) {
                                    throw new GlobalException('Type of Card is empty on offerItem: ' + offerItem.Offer_Item_Type__r.Name);
                                }

                                if (cardIdCountry.get(GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Type_of_Vehicle__c.getDescribe(), offerItem.Type_of_Vehicle__c))) instanceof Map<String, Object>) {
                                    Map<String, Object> cardIdBusiness = (Map<String, Object>) cardIdCountry.get(GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Type_of_Vehicle__c.getDescribe(), offerItem.Type_of_Vehicle__c)));
                                    gfni_card.CardTypeId = Integer.valueOf(cardIdBusiness.get(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Type_of_Card__c.getDescribe(), offerItem.Type_of_Card__c)));
                                } else {
                                    gfni_card.CardTypeId = Integer.valueOf(cardIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Type_of_Card__c.getDescribe(), offerItem.Type_of_Card__c)));
                                }
                            } else {
                                gfni_card.CardTypeId = Integer.valueOf(cardIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Offer_Item_Type__r.Name.getDescribe(), offerItem.Offer_Item_Type__r.Name)));
                            }

                            if (gfni_card.CardTypeId == null)
                                offerItemsWithInvalidCardTypeId.add(offerItem);

                            gfni_card.OdometerPromptRequired = offerItem.Mileage_data__c == true ? 1 : 0;

                            if (String.isNotBlank(offerItem.Category_of_products__c)) {
                                if (purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Category_of_products__c.getDescribe(), offerItem.Category_of_products__c)) instanceof Map<String, Object>) {
                                    Map<String, Object> purchaseCategoryIdNational = (Map<String, Object>) purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Category_of_products__c.getDescribe(), offerItem.Category_of_products__c));
                                    gfni_card.PurchaseCategoryId = Integer.valueOf(purchaseCategoryIdNational.get((GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Type_of_Card__c.getDescribe(), offerItem.Type_of_Card__c)).split('.+ -- ').get(1)));
                                } else {
                                    gfni_card.PurchaseCategoryId = Integer.valueOf(purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Category_of_products__c.getDescribe(), offerItem.Category_of_products__c)));
                                }
                            } else {
                                gfni_card.PurchaseCategoryId = Integer.valueOf(purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Offer_Item__c.Offer_Item_Type__r.Name.getDescribe(), offerItem.Offer_Item_Type__r.Name)));
                            }

                            if (gfni_card.PurchaseCategoryId == null) {
                                throw new GlobalException('Category of product is empty or not mapped on offerItem: ' + offerItem.Offer_Item_Type__r.Name);
                            }

                            cardOrder.add(gfni_card);

                        }
                    }
                }
            }
        }

        if (!cardsWithInvalidCardTypeId.isEmpty() || !offerItemsWithInvalidCardTypeId.isEmpty()) {
            //Get cards and offer items with empty Type of vehicle
            List<Id> itemsWithoutTypeOfVehicle = new List<Id>();
            for(Integer i = cardsWithInvalidCardTypeId.size() - 1; i >= 0; i--) {
                if(String.isEmpty(cardsWithInvalidCardTypeId[i].Fahrzeugtyp__c)) {
                    itemsWithoutTypeOfVehicle.add(cardsWithInvalidCardTypeId.get(i).Id);
                    cardsWithInvalidCardTypeId.remove(i);
                }
            }
            for(Integer i = offerItemsWithInvalidCardTypeId.size() - 1; i >= 0; i--) {
                if(String.isEmpty(offerItemsWithInvalidCardTypeId[i].Type_of_Vehicle__c)) {
                    itemsWithoutTypeOfVehicle.add(offerItemsWithInvalidCardTypeId.get(i).Id);
                    offerItemsWithInvalidCardTypeId.remove(i);
                }
            }
            //Show in email message list with Cards or Offer with invalid card type
            String errorMessage = 'Opportunity name: ' + opp.Name + '\n';
            if (!cardsWithInvalidCardTypeId.isEmpty() || !offerItemsWithInvalidCardTypeId.isEmpty()) {

                errorMessage += 'Card type is not mapped for client cards or offer items.\n';

                if (!cardsWithInvalidCardTypeId.isEmpty()) {
                    errorMessage += '\nCards: \n';

                    for (Tankkarten__c card : cardsWithInvalidCardTypeId) {
                        errorMessage += Url.getSalesforceBaseUrl().toExternalForm() + '/' + card.Id + ' \n';
                    }
                }

                if (!offerItemsWithInvalidCardTypeId.isEmpty()) {
                    errorMessage += '\nOffer items: \n';

                    for (Offer_Item__c offerItem : offerItemsWithInvalidCardTypeId) {
                        errorMessage += Url.getSalesforceBaseUrl().toExternalForm() + '/' + offerItem.Id + ' \n';
                    }
                }
            }
            //Show in email message list with Cards or Offer items with empty Type of vehicles
            if ( !itemsWithoutTypeOfVehicle.isEmpty() ) {
                errorMessage += '\nType of Vehicle is empty on card or offer item: \n';

                for (Id itemId : itemsWithoutTypeOfVehicle) {
                    errorMessage += Url.getSalesforceBaseUrl().toExternalForm() + '/' + itemId + ' \n';
                }
            }

            throw new GlobalException(errorMessage);
        }

        if (!String.isNotBlank(customer.ShortName))
            throw new GlobalException('No company short name are provided.');

        GFNI_CreditInfo creditInfo = new GFNI_CreditInfo();
        creditInfo.CreditSystemNumber = opp.Credit_System_Number__c;

        creditInfo.CreditLimit = opp.Credit_Limit__c;

        if (String.isNotBlank(GFNI_Utils.getStringValue(opp.Credit_System_Rating__c, Schema.Opportunity.Credit_System_Rating__c.getDescribe(), 'CreditSystemRating'))) {
            creditInfo.CreditSystemRating = GFNI_Utils.getStringValue(opp.Credit_System_Rating__c, Schema.Opportunity.Credit_System_Rating__c.getDescribe(), 'CreditSystemRating');
        } else {
            creditInfo.CreditSystemRating = opp.Credit_System_Rating__c;
        }

        if (String.isNotBlank(opp.Risk_Category__c)) {
            creditInfo.CreditRatingId = GFNI_Utils.getIntegerValue(opp.Risk_Category__c, Schema.Opportunity.Risk_Category__c.getDescribe(), 'CreditRatingId');
        } else {
            throw new GlobalException('Risk Category is empty.');
        }

        List<GFNI_Contact> contacts = new List<GFNI_Contact>();

        String primaryContactPhone;

        String languagePreference;
        if (String.isNotBlank(opp.Language_preference__c)) {
            languagePreference = GFNI_Utils.getStringValue(opp.Language_preference__c, Schema.Opportunity.Language_preference__c.getDescribe(), 'LanguageCode');
        } else {
            throw new GlobalException('Language preference is empty on opportunity ' + opp.Name);
        }

        if (opp.OpportunityContactRoles.isEmpty()) {
            throw new GlobalException('No contact roles is assigned to the opportunity');
        }

        for (OpportunityContactRole contact : opp.OpportunityContactRoles) {
            GFNI_Contact gfni_contact = new GFNI_Contact();
            gfni_contact.Primary = contact.IsPrimary == true ? 1 : 0;

            //TODO: combine phone logic
            //from this
            if (contact.IsPrimary) {
                if (String.isNotBlank(contact.Contact.Phone)) {
                    primaryContactPhone = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.Phone, billingCountryCode);
                } else {
                    primaryContactPhone = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.MobilePhone, billingCountryCode);
                }
            }

            if (String.isNotBlank(contact.Contact.Phone))
                gfni_contact.Phone = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.Phone, billingCountryCode);

            if (String.isNotBlank(contact.Contact.MobilePhone))
                gfni_contact.Mobile = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.MobilePhone, billingCountryCode);
            //to this

            if (String.isNotBlank(contact.Contact.Salutation)) {
                gfni_contact.SalutationId = GFNI_Utils.getIntegerValue(contact.Contact.Salutation, Schema.Contact.Salutation.getDescribe(), 'SalutationId');
            } else {
                throw new GlobalException('Salutation is empty on contact: ' + contact.Contact.Name);
            }
            if(gfni_contact.SalutationId == null) {
                throw new GlobalException('No mapping for Contact.Salutation: ' + contact.Contact.Salutation);
            }

            gfni_contact.FirstName = contact.Contact.FirstName;
            gfni_contact.MiddleName = contact.Contact.MiddleName;

            gfni_contact.LastName = contact.Contact.LastName;
            if (!String.isNotBlank(gfni_contact.LastName))
                throw new GlobalException('Last name is empty on contact ' + contact.Contact.Name);

            gfni_contact.Fax = contact.Contact.Fax;

            gfni_contact.Email = contact.Contact.Email;

            gfni_contact.Language = languagePreference;

            contacts.add(gfni_contact);
        }

        List<GFNI_Address> addresses = new List<GFNI_Address>();

        GFNI_Address address = new GFNI_Address();

        //TODO: move it to the loop
        addresses.add(buildAddressObject(acc, 3, primaryContactPhone, true));

        List<Object> addressTypeIdList = (List<Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'AddressTypeId');

        for (Object typeId : addressTypeIdList) {
            addresses.add(buildAddressObject(acc, Integer.valueOf(typeId), primaryContactPhone, false));
        }

        if (String.isNotBlank(acc.Name)) {
            customer.AccountName = acc.Name;
        } else {
            throw new GlobalException('Customer name is empty.');
        }

        if (String.isNotBlank(acc.Account_Nr__c)) {
            customer.AccountNumber = acc.Account_Nr__c.remove('-');
        } else {
            throw new GlobalException('Account # is empty.');
        }

        //STCP1-358
        customer.AccountManager = opp.Owner.FirstName + ' ' + opp.Owner.LastName;

        Map<String, Object> legalEntityIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'LegalEntityId');
        customer.LegalEntityId = Integer.valueOf(legalEntityIdMapping.get(billingCountryCode));

        customer.RegisteredCountryCode = billingCountryCode;

        switch on billingCountryCode {
            when 'PL' {
                customer.TradeRegistrationNumber = acc.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;
                if (String.isNotBlank(acc.Steuernummer__c))
                    customer.VATNumber = acc.Steuernummer__c.replaceAll('\\W', '');
            }
            when 'HU' {
                customer.TradeRegistrationNumber = acc.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;
                customer.VATNumber = acc.Steuernummer__c;
                customer.VATNumber2 = acc.Umsatzsteuer_ID__c;
            }
            when else {
                customer.TradeRegistrationNumber = String.isNotBlank(acc.Steuernummer__c) ? acc.Steuernummer__c : acc.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;
                if (String.isNotBlank(acc.Umsatzsteuer_ID__c))
                    customer.VATNumber = acc.Umsatzsteuer_ID__c.replaceAll('\\W', '');
            }
        }

        Map<String, Object> priceProfileIdByCountry = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'PriceProfileId');
        Map<String, Object> priceProfileIdByProduct = (Map<String, Object>) priceProfileIdByCountry.get(billingCountryCode);

        if (priceProfileIdByProduct.containsKey(product)) {
            if (priceProfileIdByProduct.get(product) instanceof Map<String, Object>) {
                Map<String, Object> priceProfileIdByPaymentMethod = (Map<String, Object>) priceProfileIdByProduct.get(product);
                customer.PriceProfileId = Integer.valueOf(priceProfileIdByPaymentMethod.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)));
            } else {
                customer.PriceProfileId = Integer.valueOf(priceProfileIdByProduct.get(product));
            }
        } else {
            throw new GlobalException('Price profile is not mapped to product ' + product);
        }

        //TODO: remove constants
        if (opp.Total_number_of_vehicles__c > 10) {
            customer.CustomerSegmentationId = GFNI_Utils.getIntegerValue(11, null, 'CustomerSegmentationId');
        } else {
            customer.CustomerSegmentationId = GFNI_Utils.getIntegerValue(opp.Total_number_of_vehicles__c.intValue(), Schema.Opportunity.Total_number_of_vehicles__c.getDescribe(), 'CustomerSegmentationId');
        }

        customer.MarketingSegmentationId = GFNI_Utils.getIntegerValue(product, null, 'MarketingSegmentationId');
        if (customer.MarketingSegmentationId == null)
            throw new GlobalException('Marketing segmentation have no mapping for product ' + product);

        customer.EstimatedFuelVolume = opp.Total_consumption_l_month__c;

        customer.Language = languagePreference;
        customer.BillingLanguage = languagePreference;

        if (opp.Eco_Fee__c != null)
            customer.IsEcoFeeRuleApplied = opp.Eco_Fee__c == true ? 1 : 0;

        Map<String, Object> feeGroupIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'FeeGroupId');
        Map<String, Object> feeGroupIdCountry = (Map<String, Object>) feeGroupIdMapping.get(billingCountryCode);

        if (feeGroupIdCountry.get(product) instanceof Map<String, Object>) {
            Map<String, Object> feeGroupIdDebit = (Map<String, Object>) feeGroupIdCountry.get(product);

            if (feeGroupIdDebit.containsKey(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c))) { //BankTransfer or DirectDebit
                if (feeGroupIdDebit.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)) instanceof Map<String, Object>) {
                    Map<String, Object> feeGroupIdIsEcoFee = (Map<String, Object>) feeGroupIdDebit.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c));
                    customer.FeeGroupId = Integer.valueOf(feeGroupIdIsEcoFee.get(String.valueOf(opp.Eco_Fee__c)));
                    customer.IsEcoFeeRuleApplied = 0; //STCP1-748 IsEcoFeeRuleApplied is always false for Lotos product
                } else {
                    customer.FeeGroupId = Integer.valueOf(feeGroupIdDebit.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)));
                }
                if (customer.FeeGroupId == null)
                    throw new GlobalException('Fee Group have no mapping for payment method ' + GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c));
            } else if (feeGroupIdDebit.containsKey(String.valueOf(opp.Eco_Fee__c))) { //true or false on EcoFee

                customer.FeeGroupId = Integer.valueOf(feeGroupIdDebit.get(String.valueOf(opp.Eco_Fee__c)));
                customer.IsEcoFeeRuleApplied = 0;

                if (customer.FeeGroupId == null)
                    throw new GlobalException('Fee Group not mapped for EcoFee value "' + opp.Eco_Fee__c + '"');
            } else { //other
                throw new GlobalException('Fee Group Id not logic implemented for this case');
            }
        } else {
            customer.FeeGroupId = Integer.valueOf(feeGroupIdCountry.get(product));
            if (customer.FeeGroupId == null)
                throw new GlobalException('Fee Group have no mapping for product ' + product);
        }

        if (String.isNotBlank(opp.ESI__c))
            customer.HomeSiteCode = opp.ESI__c.replaceAll('(\\W|\\D)', '');

        Map<String, Object> acquisitionChannelIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'AcquisitionChannelId');
        Map<String, Object> acquisitionChannelIdCountry = (Map<String, Object>) acquisitionChannelIdMapping.get(GlobalUtils.blankStringIfNull(billingCountryCode));

        if (String.isNotBlank(opp.Sec_Channel__c)) {
            customer.AcquisitionChannelId = Integer.valueOf(acquisitionChannelIdCountry.get((GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Sec_Channel__c.getDescribe(), opp.Sec_Channel__c))));
            if (customer.AcquisitionChannelId == null)
                throw new GlobalException('AcquisitionChannelId have no mapping for Sec. Channel ' + opp.Sec_Channel__c);
        } else {
            throw new GlobalException('Sec. Channel is empty');
        }


        //logic defined by business
        //TODO: remove constants
        Map<String, Object> NumberOfCardsSelfServiceMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'NumberOfCardsSelfService');
        if (cardOrder.size() > Integer.valueOf(NumberOfCardsSelfServiceMapping.get(billingCountryCode))) {
            customer.SelfServeUserId = 0;
        } else {
            customer.SelfServeUserId = 3;
        }

        //STCP1-748
        customer.LineOfBusinessID = GFNI_Utils.getIntegerValue(opp.RecordType.Name, RecordType.Name.getDescribe(), 'LineOfBusinessId') != null ? GFNI_Utils.getIntegerValue(opp.RecordType.Name, RecordType.Name.getDescribe(), 'LineOfBusinessId') : null;

        //logic defined by business
        customer.NextReviewDate = opp.Next_Review_Date__c != null ? Datetime.newInstance(opp.Next_Review_Date__c.year(), opp.Next_Review_Date__c.month(), opp.Next_Review_Date__c.day()).format('yyyy-MM-dd') : null;

        customer.SecurityTypeId = GFNI_Utils.getIntegerValue(opp.Garantie__c, Schema.Opportunity.Garantie__c.getDescribe(), 'SecurityTypeId');
        customer.SecurityAmount = opp.Garantie_other__c;

        customer.Contacts = contacts;
        customer.Addresses = addresses;
        customer.CreditInfo = creditInfo;
        customer.CardOrder = cardOrder;
        customer.PaymentInfo = paymentInfo;
        customer.CommunicationPreferences = communicationPreferences;

        GFNI_CreateCustomerCardsRequest createCustomerCardsRequest = new GFNI_CreateCustomerCardsRequest();
        createCustomerCardsRequest.Metadata = buildMetadataObject(acc, opp.Owner.Name);

        Map<String, Object> serviceIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'ServiceId');

        if (opp.VAT_Recovery__c) {
            createCustomerCardsRequest.addServiceId(Integer.valueOf(serviceIdMapping.get('VAT Recovery')));
        }

        createCustomerCardsRequest.ApplicationId = GlobalUtils.generateGUID();
        createCustomerCardsRequest.Customer = customer;

        System.debug('DEBUG ==== ');
        System.debug(createCustomerCardsRequest);
        System.debug('JSON === ' + JSON.serialize(createCustomerCardsRequest));

        return JSON.serialize(createCustomerCardsRequest);
    }

    /*******************************************************************************
    *  Name            : buildJSONApplicationStatus
    *  Summary         : build application status REST request as String. Mapping are provided by business in mapping doc
    *  CreatedDate     : 21/01/2019
    *  Parameters      : List<Opportunity> opportunities
    *  Returns         : String
    ******************************************************************************/
    public static String buildJSONApplicationStatus(List<Opportunity> opportunities) {
        GFNI_ApplicationStatusRequest applicationStatusRequest = new GFNI_ApplicationStatusRequest();
        applicationStatusRequest.Metadata = buildMetadataObject(opportunities.get(0).Account, 'E2EIntegration');

        List<GFNI_Application> applications = new List<GFNI_Application>();

        for (Opportunity opportunity : opportunities) {
            GFNI_Application application = new GFNI_Application();
            application.ApplicationDate = opportunity.CreatedDate.format('yyyy-MM-dd');
            application.ApplicationId = opportunity.GFNI_ApplicationId__c;
            applications.add(application);
        }

        applicationStatusRequest.Applications = applications;

        return JSON.serialize(applicationStatusRequest);
    }

    private static GFNI_Metadata buildMetadataObject(Account acc, String userName) {
        GFNI_Metadata metadata = new GFNI_Metadata();

        metadata.ColCoID = GFNI_Utils.getIntegerValue(acc.BillingCountry.split('-').get(0), Schema.Account.BillingCountry.getDescribe(), 'CompanyId');
        metadata.RequestID = GlobalUtils.generateGUID();
        metadata.UserCulture = GFNI_Utils.getStringValue(acc.BillingCountry, Schema.Account.BillingCountry.getDescribe(), 'CultureCode');
        metadata.UserName = userName.replaceAll(' ', '');

        return metadata;
    }

    private static GFNI_Address buildAddressObject(Account acc, Integer typeId, String primaryContactPhone, Boolean isBillingAddress) {
        GFNI_Address address = new GFNI_Address();

        if (typeId != null) {
            address.TypeId = typeId;
        } else {
            throw new GlobalException('Address type id empty.');
        }

        address.Phone = primaryContactPhone;

        if (isBillingAddress) {
            try {
                fillAddressWithChecks(address, acc.BillingCity, acc.BillingCountryCode, acc.BillingPostalCode, acc.BillingStreet);
            } catch (Exception e) {
                throw new GlobalException('Billing ' + e.getMessage());
            }
        } else {
            try {
                fillAddressWithChecks(address, acc.ShippingCity, acc.ShippingCountryCode, acc.ShippingPostalCode, acc.ShippingStreet);
            } catch (Exception e) {
                throw new GlobalException('Shipping ' + e.getMessage());
            }
        }

        return address;
    }

    private static void fillAddressWithChecks(GFNI_Address address, String city, String countryCode, String postalCode, String street) {
        if (String.isNotBlank(city)) {
            address.City = city;
        } else {
            throw new GlobalException('city is empty.');
        }

        if (String.isNotBlank(countryCode)) {
            address.CountryCode = countryCode.substring(0, 2);
        } else {
            throw new GlobalException('country code is empty.');
        }

        address.ZipCode = getZipCodeWithChecks(postalCode, countryCode);

        //TODO: remove constants
        if (String.isNotBlank(street)) {
            if (street.length() <= 40) {
                address.Line1 = street;
            } else {
                throw new GlobalException('Address line is more than 40 characters.');
            }
        } else {
            throw new GlobalException('street is empty.');
        }
    }

    private static String getZipCodeWithChecks(String postalCode, String countryCode) {
        if (String.isNotBlank(postalCode)) {
            //TODO: remove CZ and SK constants
            if (countryCode.substring(0, 2).equals('CZ') || countryCode.substring(0, 2).equals('SK')) {
                if (postalCode.length() >= 5) {
                    postalCode = postalCode.remove(' ');
                    return postalCode.substring(0, 3) + ' ' + postalCode.substring(3);
                } else {
                    throw new GlobalException('postal code length is less than 5 characters.');
                }
            } else {
                return postalCode;
            }
        } else {
            throw new GlobalException('postal code is empty.');
        }
    }
}