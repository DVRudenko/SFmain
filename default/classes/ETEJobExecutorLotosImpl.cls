public class ETEJobExecutorLotosImpl extends ETEJobExecutorBaseImpl {

    public ETEJobExecutorLotosImpl(List<String> jobsNeededToRun, String dataObjectId, String countryCode) {
        super(jobsNeededToRun, dataObjectId, countryCode);
    }

    public override Opportunity mapOpportunityFieldsWithDataObjectFields(Opportunity opportunity, E2E_Data_Object__c dataObject) {
        // products and services
        opportunity.Client_Id__c = dataObject.Client_Id__c;
        
        // contacts details
        if (opportunity.Name == 'NEW E2E CUSTOMER') {
            opportunity.Name = dataObject.Selected_Company_Name__c;
        }
        opportunity.Primary_Contact_Phone__c = dataObject.Phone__c;
        opportunity.Agree_to_Privacy_Policy__c = dataObject.Agreement_Privacy_Policy__c;
        opportunity.Agree_to_process_pers_data_for_marketing__c = dataObject.Agree_to_process_pers_data_for_marketing__c;
        opportunity.Agree_to_telephone_contact__c = dataObject.Agreement_To_Phone_Contact__c;
        opportunity.Agree_to_receive_comm_info_by_email__c = dataObject.Agreement_To_Receive_Info_By_Email__c;
        // documents
        if (opportunity.AGB_Datenschutzhinweise_Richtigkeit__c != dataObject.Terms_And_Conditions_Agreement__c) {
            opportunity.AGB_Datenschutzhinweise_Richtigkeit__c = dataObject.Terms_And_Conditions_Agreement__c;
            opportunity.Date_of_Acceptance_TC__c = Datetime.now();
        }
        // pay_deposit
        if (opportunity.Agree_To_Deposit_Agreement__c != dataObject.Deposit_Agreement__c) {
            opportunity.Agree_To_Deposit_Agreement__c = dataObject.Deposit_Agreement__c;
            if (opportunity.Agree_To_Deposit_Agreement__c == true) {
                opportunity.Date_For_Agree_To_Deposit_Agreement__c = Datetime.now();
            } else {
                opportunity.Date_For_Agree_To_Deposit_Agreement__c = null;
            }
        }

        // credit line
        String paymentMethod;
        if (dataObject.Payment_Method__c == 'Direct Debit') {
            paymentMethod = 'Lastschrift';
        } else if (dataObject.Payment_Method__c == 'Bank Transfer') {
            paymentMethod = 'Banküberweisung';
        }
        if (opportunity.CF_Credit_Limit__c != dataObject.Credit_Limit__c || opportunity.Zahlungsart__c != paymentMethod ||
                opportunity.Rechnungsperiode__c != dataObject.Billing_Period__c || opportunity.Zahlungsziel_Credit__c != dataObject.Payment_Terms__c ||
                opportunity.Max_Credit_Limit__c != dataObject.Max_Credit_Limit__c || opportunity.Credit_System_Rating__c != dataObject.Credit_System_Rating__c ||
                opportunity.Risk_Category__c != dataObject.Risk_Category__c) {
            opportunity.CF_Credit_Limit__c = dataObject.Credit_Limit__c;
            opportunity.Zahlungsart__c = paymentMethod;
            opportunity.Rechnungsperiode__c = dataObject.Billing_Period__c;
            opportunity.Zahlungsziel_Credit__c = dataObject.Payment_Terms__c;
            opportunity.Max_Credit_Limit__c = dataObject.Max_Credit_Limit__c;
            opportunity.Security_level_H_he_der_Sicherheit__c = dataObject.Security_Level__c;
            opportunity.Credit_System_Rating__c = dataObject.Credit_System_Rating__c;
            opportunity.Risk_Category__c = dataObject.Risk_Category__c;
            opportunity.E2E_Status__c = dataObject.E2E_Status__c;
            opportunity.E2E_Sub_Status__c = '';
            opportunity.Deposit_reason__c = dataObject.Deposit_Reason__c;
            if (dataObject.Credit_Limit__c != null) {
                opportunity.Credit_check_date__c = Date.today();
                opportunity.bearbeitet_von__c = 'Autoprocessed by E2E';
            } else {
                opportunity.Credit_check_date__c = null;
                opportunity.bearbeitet_von__c = null;
            }
            if (dataObject.Security_Amount_To_Pay__c != 0 && dataObject.Security_Amount_To_Pay__c != null) {
                opportunity.Security_Amount_To_Pay__c = dataObject.Security_Amount_To_Pay__c;
                opportunity.CF_Stage__c = 'Pending deposit';
                opportunity.Credit_Stage__c = 'Pending Sales - Deposit';
                opportunity.E2E_payment_status__c = null;
                opportunity.Security_To_Pay__c = 'Kaution';
                opportunity.Kredit_Entscheidung__c = 'Sicherheit verlangt';
                opportunity.Billing_Period_by_Sales__c = true;
                opportunity.Pending_Deposit_by_CF__c = true;
            } else {
                opportunity.Security_Amount_To_Pay__c = null;
                opportunity.CF_Stage__c = 'Report generated';
                if (dataObject.Credit_Limit__c != null) {
                    opportunity.Credit_Stage__c = 'Credit Approved';
                } else {
                    opportunity.Credit_Stage__c = null;
                }
                opportunity.E2E_payment_status__c = 'NO DEPOSIT';
                opportunity.Security_To_Pay__c = '';
                opportunity.Kredit_Entscheidung__c = 'Genehmigt';
                opportunity.Billing_Period_by_Sales__c = false;
                opportunity.Pending_Deposit_by_CF__c = false;
            }
        }
        // other
        if (opportunity.Direct_Debit_Mandate_Type__c != dataObject.Direct_Debit_Mandate_Type__c) {
            opportunity.Direct_Debit_Mandate_Type__c = dataObject.Direct_Debit_Mandate_Type__c;
        }
        opportunity.StageName = dataObject.StageName__c;
        opportunity.Device_Type__c = dataObject.Device_Type__c;
        opportunity.Language_preference__c = ETEGlobalUtils.returnLanguagePreference(dataObject.Current_Language__c);
        opportunity.E2E_Encoded_URL__c = ETEGlobalUtils.doEncryptParams(dataObject.Id, dataObject.Country_Code__c);
        opportunity.Visitor_ID__c = dataObject.Customer_IP_Address__c;
        opportunity.E2E_Last_Activity__c = dataObject.E2E_Last_Activity__c;
        opportunity.E2E_Step__c = dataObject.Current_Step__c;
        opportunity.Utm_campaign__c = dataObject.Utm_Campaign__c;
        opportunity.Utm_content__c = dataObject.Utm_Content__c;
        opportunity.Utm_medium__c = dataObject.Utm_Medium__c;
        opportunity.Utm_placement__c = dataObject.Utm_Placement__c;
        opportunity.Utm_source__c = dataObject.Utm_Source__c;
        opportunity.Utm_term__c = dataObject.Utm_Term__c;
        opportunity.Utm_url__c = dataObject.Utm_Url__c;
        if (dataObject.Utm_Campaign__c != null && dataObject.Utm_Campaign__c.containsIgnoreCase('monevia')) {
            if (opportunity.Retailer_OBN__c == null) {
                List<Account> moneviaAccountList = [SELECT Id FROM Account WHERE Id = '0013Y00002bKAIqQAO' LIMIT 1];
                opportunity.LeadSource = 'Partner';
                opportunity.Retailer_OBN__c = 'BP005';
                if (! moneviaAccountList.isEmpty()) { opportunity.Retailer_Name__c = moneviaAccountList.get(0).Id; }
            }
        }
        opportunity.E2E_Errors__c = null;

        // stop process
        if (dataObject.E2E_Status__c == 'Finished') {
            opportunity.E2E_Status__c = dataObject.E2E_Status__c;
            opportunity.E2E_Finish_Details__c = dataObject.E2E_Finish_Details__c;
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(ETEGlobalUtils.returnCountry(dataObject.Country_Code__c));
            if (dataObject.StageName__c == 'Closed Won') {
                opportunity.CloseDate = Date.today();
                opportunity.E2E_Step__c = 'Congratulations';
                if (settings.Enable_authorization_non_granted_check__c) {
                    opportunity.Starts_Status__c = '0. Request received';
                }
            } else if (dataObject.StageName__c == 'Closed Lost') {
                opportunity.Kredit_Entscheidung__c = 'Abgelehnt';
            } else {
                if (settings != null && settings.Abandonment_User__c != null) {
                    opportunity.OwnerId = settings.Abandonment_User__c;
                }
            }
            if (dataObject.Payment_Status__c == 'COMPLETED') {
                opportunity.E2E_payment_status__c = 'ACCEPT';
                opportunity.Garantie_other__c = opportunity.Security_Amount_To_Pay__c;
                opportunity.Garantie__c = opportunity.Security_To_Pay__c;
                opportunity.E2E_Step__c = 'Congratulations';
            } else if (dataObject.Payment_Status__c != null) {
                opportunity.E2E_payment_status__c = dataObject.Payment_Status__c;
                opportunity.E2E_Step__c = 'Congratulations';
            }
            if (dataObject.E2E_Finish_Details__c == 'Awaiting Payment' &&
                    dataObject.Payment_Status__c == null) {
                opportunity.E2E_payment_status__c = 'PAYMENT GATEWAY OFF';
            }
        }
        return opportunity;
    }


    public override Map<String, Offer_Item__c> mapOpptyOfferItemsFieldsWithDataOfferItemsFields(E2E_Data_Object__c dataObject,
                                                                                                Opportunity opportunity,
                                                                                                Map<String, E2E_Data_Product__c> eteProductsByParentIdMap,
                                                                                                Map<String, Map<String, Offer_Item__c>> finalBusinessOfferItems,
                                                                                                Map<String, List<E2E_Data_Offer_Item__c>> dataOfferItemsMap) {
        Map<String, Offer_Item__c> offerItemToUpsertMap = new Map<String, Offer_Item__c>();
        List<E2E_Data_Offer_Item__c> allOfferItemsList = new List<E2E_Data_Offer_Item__c>();
        Decimal numberOfCars = 0;
        Decimal numberOfTrucks = 0;
        for (String offerId : dataOfferItemsMap.keySet()) {
            for (E2E_Data_Offer_Item__c dataOfferItem : dataOfferItemsMap.get(offerId)) {
                Offer_Item__c opptyOfferItem = finalBusinessOfferItems.get(offerId).get(dataOfferItem.Id);
                opptyOfferItem.Category_of_products__c = dataOfferItem.Category_Of_Products__c;
                opptyOfferItem.Company_Name__c = dataOfferItem.Company_Name__c;
                opptyOfferItem.Driver_Name__c = dataOfferItem.Driver_Name__c;
                opptyOfferItem.License_plate_number__c = dataOfferItem.License_Plate_Number__c;
                opptyOfferItem.Mileage_data__c = dataOfferItem.Mileage_Data__c;
                opptyOfferItem.Offer_Item_Type__c = dataOfferItem.Offer_Item_Type_Id__c;
                opptyOfferItem.Type_of_Card__c = dataOfferItem.Type_Of_Card__c;
                opptyOfferItem.Type_of_Vehicle__c = dataOfferItem.Type_Of_Vehicle__c;
                opptyOfferItem.Fuel_card_consumption_monthly__c = dataOfferItem.Monthly_Fuel_Consumption__c;
                opptyOfferItem.Monthly_card_limit_value__c = dataOfferItem.Monthly_Fuel_Consumption__c * 5;
                offerItemToUpsertMap.put(dataOfferItem.Id, opptyOfferItem);
                allOfferItemsList.add(dataOfferItem);
                if (dataOfferItem.Type_Of_Vehicle__c == 'PKW') {
                    numberOfCars++;
                } else if (dataOfferItem.Type_Of_Vehicle__c == 'LKW') {
                    numberOfTrucks++;
                }
            }
        }
        opportunity.put('Gasoline_consumption_l_month__c', 0);
        opportunity.put('Derzeitige_Zahlungsmethode__c', 'Barzahlung');
        opportunity.put('Number_of_cars__c', numberOfCars);
        opportunity.put('Number_of_trucks__c', numberOfTrucks);
        opportunity.put('Total_number_of_vehicles__c', numberOfCars + numberOfTrucks);
        return offerItemToUpsertMap;
    }
}