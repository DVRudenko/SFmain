/**
 * Created by marekhaken on 11/01/2020.
 */

public with sharing class ExcelRobotCCSController {
    public String getId  = System.currentPageReference().getParameters().get('Id');

    public class ExcelInfo{
        public String Type {get;set;}
        public String Queue {get;set;}

        // **************************************************
        // CCS Order

        public Id OrderId {get;set;}
        public String OrderName {get;set;}
        public String OrderOwner {get;set;}
        public String AccidentInsurance {get;set;}
        public String AccountNumber {get;set;}
        public String AccountPrefix {get;set;}
        public String BankName {get;set;}
        public String BankSortCode {get;set;}
        public Decimal BasicConfigurationPrice {get;set;}
        public String BICSWIFT {get;set;}
        public String BillingCompanyIndividualName {get;set;}
        public String BillingStreet {get;set;}
        public String BillingHouseNumber {get;set;}
        public String BillingPostalCode {get;set;}
        public String BillingCity {get;set;}
        public String BillingCountry {get;set;}
        public String BulkCharging {get;set;}
        public Decimal CardIssuancePrice {get;set;}
        public String CCSMerlinID {get;set;}
        //public String City {get;set;}
        public Decimal CollectionLimit {get;set;}
        //public String CompanyIndividualName {get;set;}
        public String CompanyNumber {get;set;}
        public String Cribis {get;set;}
        public String CribisOffer {get;set;}
        //public String Description {get;set;}
        public String EcoFee {get;set;}
        public Decimal FinancialCredit {get;set;}
        //public String HouseNumber {get;set;}
        public String MerlinLicense {get;set;}
        public String MerlinPartner {get;set;}
        public String IBAN {get;set;}
        public String CCSDDAccountNumber {get;set;}
        public String MOLDiscount {get;set;}
        public String MonthlyBillEmail {get;set;}
        public String MonthlyBillPost {get;set;}
        public Decimal MonthlyFixedCardPayment {get;set;}
        public String NameontheCards {get;set;}
        public String NoteCC {get;set;}
        public String NoteCCS {get;set;}
        public Decimal NumberofCards {get;set;}
        public Decimal NumberofCardVariants {get;set;}
        public Decimal NumberofVehicles {get;set;}
        public String OfferType {get;set;}
        public String OrderNote {get;set;}
        public String OZNumber {get;set;}
        //public Decimal PostalCode {get;set;}
        public String Product {get; set;}
        public String SelectedPetrolStations {get; set;}
        public String ShippingCompanyIndividualName {get;set;}
        public String ShippingStreet {get;set;}
        public String ShippingHouseNumber {get;set;}
        public String ShippingPostalCode {get;set;}
        public String ShippingCity {get;set;}
        public String ShippingCountry {get;set;}
        //public String Street {get; set;}
        public String TCAgree {get;set;}
        public Decimal TotalMonthlyPayment {get;set;}
        public Decimal Price {get;set;}
        public String CurrencyIsoCode {get;set;}
        public String ProductCountry {get;set;}
        public String VAT {get;set;}
        public String PaymentType {get;set;}

        public Opportunity opp{get;set;}
        public Account acc{get;set;}

        // **************************************************
        // CCS Contact

        public String Email {get;set;}
        public String Primary {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String Phone {get;set;}
        public String Role {get;set;}
        public String AccountAdministrator {get;set;}
        public String AuthorisedSignatory {get;set;}

        // **************************************************
        // Karta CCS Bonus

        public Decimal FinancninabojkartyvKc {get;set;}
        //public String Narozeninovedarkovebaleni {get;set;}
        public Decimal Pocetkaretstimtonastavenim {get;set;}
        //public String Vanocnidarkovebaleni {get;set;}

        // **************************************************
        // Karta CCS Bonus Fleet

        public Decimal DennilimitvKc {get;set;}
        public Decimal MesicnilimitvKc {get;set;}
        public String Povolenekodyzbozi {get;set;}
        public String Povoleneskupinyzbozi {get;set;}
        public String RZvozidlanebojmenoridice {get;set;}
        public Decimal TydennilimitvKc {get;set;}

        // **************************************************
        // Karta CCS Bonus Limit

        public String Aktivovatzadavanistavukilometru {get;set;}
        public String EVCharging {get;set;}
        public String Poznamkakobjednavce {get;set;}
        public String Typvozidla {get;set;}
        public String ZablokovatzmenuPINkodu {get;set;}
        //Limity jsou jiz nadefinovane u "Karta CCS Bonus Fleet"

        // **************************************************
        // Vozidlo CCS Carnet

        public String IMEI {get;set;}
        public String GPRSRoaming {get;set;}
        //public Decimal GPRSRoamingFee {get;set;}
        public String GPRSProfi {get;set;}
        //public Decimal GPRSProfiFee {get;set;}
        public Decimal GPRSFee {get;set;}
        public Decimal MonthlyFee {get;set;}
        public Decimal UnitFee {get;set;}
        public Decimal ContractTerm {get;set;}

        // **************************************************
        // CCS Additional HW

        public Decimal CANReader {get;set;}
        public Decimal CANReaderFee {get;set;}
        public Decimal CANReaderContactless {get;set;}
        public Decimal CANReaderContactlessFee {get;set;}
        public Decimal DallasReader {get;set;}
        public Decimal DallasReaderFee {get;set;}
        public Decimal DallasChip {get;set;}
        public Decimal DallasChipFee {get;set;}
        public Decimal RFIDReader {get;set;}
        public Decimal RFIDReaderFee {get;set;}
        public Decimal RFIDChip {get;set;}
        public Decimal RFIDChipFee {get;set;}
        public Decimal RFIDCard {get;set;}
        public Decimal RFIDCardFee {get;set;}
        public Decimal ExternalAntenna {get;set;}
        public Decimal ExternalAntennaFee {get;set;}
        public Decimal UnitInstallation {get;set;}
        public Decimal UnitInstallationFee {get;set;}
    }

    public List<ExcelInfo> excelList {get;set;}
    public ExcelRobotCCSController (){
        excelList = new List<ExcelInfo>();

        List<CCS_Order__c> ordrList = [SELECT Id, Name, Owner.Name, Accident_Insurance__c, Account_Number__c, Account_Prefix__c, Bank_Name__c, Bank_Sort_Code__c, Basic_Configuration_Price__c, BIC_SWIFT__c, Billing_Company_Individual_Name__c, Billing_City__c, Billing_Street__c, Billing_House_Number__c, Billing_Postal_Code__c, Billing_Country__c, Bulk_Charging__c, Card_Issuance_Price__c, CCS_MerlinID__c, City__c, Collection_Limit__c, Company_Individual_Name__c, Company_Number__c, Cribis__c, Cribis_Offer__c, Note_CC__c, Note_CCS__c, Eco_Fee__c, Financial_Credit__c, House_Number__c, IBAN__c, CCS_DD_Account_Number__c, Merlin_License__c, Merlin_Partner__c, MOL_Discount__c, Monthly_Bill_Email__c, Monthly_Bill_Post__c, Monthly_Fixed_Card_Payment__c, Name_on_the_Cards__c, Number_of_Cards__c, Number_of_Card_Variants__c, Number_of_Vehicles__c, Offer_Type__c, Order_Note__c, OZ_Number__c, Postal_Code__c, Product__c, Selected_Petrol_Stations__c, Shipping_Company_Individual_Name__c, Shipping_City__c, Shipping_Street__c, Shipping_House_Number__c, Shipping_Postal_Code__c, Shipping_Country__c, Street__c, T_C_Agree__c, Total_Monthly_Payment__c, Price__c, VAT__c, Payment_Type__c, CurrencyIsoCode, Product_Country__c, Opportunity__c, Opportunity__r.Id, Opportunity__r.AccountId FROM CCS_Order__c WHERE Opportunity__c = :getId];
        //List<CCS_Order__c> ordrList = [SELECT Id, Name, Accident_Insurance__c, Bank_Name__c, Basic_Configuration_Price__c, BIC_SWIFT__c, Billing_Company_Individual_Name__c, Billing_City__c, Billing_Street__c, Billing_House_Number__c, Billing_Country__c, Bulk_Charging__c, Card_Issuance_Price__c, CCS_MerlinID__c, City__c, Collection_Limit__c, Company_Individual_Name__c, Cribis__c, Cribis_Offer__c, Financial_Credit__c, House_Number__c, IBAN__c, MOL_Discount__c, Monthly_Bill_Email__c, Monthly_Bill_Post__c, Monthly_Fixed_Card_Payment__c, Name_on_the_Cards__c, Number_of_Cards__c, Number_of_Card_Variants__c, Number_of_Vehicles__c, Offer_Type__c, OZ_Number__c, Postal_Code__c, Shipping_Company_Individual_Name__c, Shipping_City__c, Shipping_Street__c, Shipping_House_Number__c, Shipping_Country__c, Street__c, T_C_Agree__c, Total_Monthly_Payment__c, Price__c, VAT__c, CurrencyIsoCode, Opportunity__c, Opportunity__r.Id, Opportunity__r.AccountId FROM CCS_Order__c WHERE Opportunity__c = :getId];


        //List<CCS_Order__c> ordrList = [SELECT Id, Name FROM CCS_Order__c WHERE Opportunity__c = '0061X000005k09Q'];

        if(ordrList.size() > 0){
            CCS_Order__c ordr = ordrList[0];

            ExcelInfo ei = new ExcelInfo();
            ei.Type = 'Order';
            ei.OrderName = ordr.Name;
            ei.OrderOwner = ordr.Owner.Name;
            ei.OrderId = ordr.Id;
            ei.AccidentInsurance = String.valueOf(ordr.Accident_Insurance__c);
            ei.AccountNumber = ordr.Account_Number__c;
            ei.AccountPrefix = ordr.Account_Prefix__c;
            ei.BankName = ordr.Bank_Name__c;
            ei.BankSortCode = ordr.Bank_Sort_Code__c;
            ei.BasicConfigurationPrice = ordr.Basic_Configuration_Price__c;
            ei.BICSWIFT = ordr.BIC_SWIFT__c;
            ei.BillingCompanyIndividualName = ordr.Billing_Company_Individual_Name__c;
            ei.BillingStreet = ordr.Billing_Street__c;
            ei.BillingHouseNumber = ordr.Billing_House_Number__c;
            ei.BillingPostalCode = ordr.Billing_Postal_Code__c;
            ei.BillingCity = ordr.Billing_City__c;
            ei.BillingCountry = ordr.Billing_Country__c;
            ei.BulkCharging = String.valueOf(ordr.Bulk_Charging__c);
            ei.CardIssuancePrice = ordr.Card_Issuance_Price__c;
            ei.CCSMerlinID = ordr.CCS_MerlinID__c;
            //ei.City = ordr.City__c;
            ei.CollectionLimit = ordr.Collection_Limit__c;
            //ei.CompanyIndividualName = ordr.Company_Individual_Name__c;
            ei.CompanyNumber = ordr.Company_Number__c;
            ei.Cribis = ordr.Cribis__c;
            ei.CribisOffer = ordr.Cribis_Offer__c;
            ei.EcoFee = String.valueOf(ordr.Eco_Fee__c);
            ei.FinancialCredit = ordr.Financial_Credit__c;
            //ei.GPRSProfi = String.valueOf(ordr.GPRS_Profi__c);
            //ei.GPRSRoaming = String.valueOf(ordr.GPRS_Roaming__c);
            //ei.HouseNumber = ordr.House_Number__c;
            ei.IBAN = ordr.IBAN__c;
            ei.CCSDDAccountNumber = ordr.CCS_DD_Account_Number__c;
            ei.MerlinLicense = ordr.Merlin_License__c;
            ei.MerlinPartner = ordr.Merlin_Partner__c;
            ei.MOLDiscount = String.valueOf(ordr.MOL_Discount__c);
            ei.MonthlyBillEmail = String.valueOf(ordr.Monthly_Bill_Email__c);
            ei.MonthlyBillPost = String.valueOf(ordr.Monthly_Bill_Post__c);
            ei.MonthlyFixedCardPayment = ordr.Monthly_Fixed_Card_Payment__c;
            ei.NameontheCards = ordr.Name_on_the_Cards__c;
            ei.NumberofVehicles = ordr.Number_of_Vehicles__c;
            if(ordr.Note_CC__c == null){
                ei.NoteCC = ordr.Note_CC__c;
            }
            else {
                ei.NoteCC = ordr.Note_CC__c.escapeHtml4();
            }

            if(ordr.Note_CCS__c == null){
                ei.NoteCCS = ordr.Note_CCS__c;
            }
            else {
                ei.NoteCCS = ordr.Note_CCS__c.escapeHtml4();
            }
            ei.NumberofCards = ordr.Number_of_Cards__c;
            ei.NumberofCardVariants = ordr.Number_of_Card_Variants__c;
            ei.OfferType = ordr.Offer_Type__c;
            if(ordr.Order_Note__c == null){
                ei.OrderNote = ordr.Order_Note__c;
            }
            else {
                ei.OrderNote = ordr.Order_Note__c.escapeHtml4();
            }
            ei.OZNumber = ordr.OZ_Number__c;
            //ei.PostalCode = ordr.Postal_Code__c;
            ei.Product = ordr.Product__c;
            ei.SelectedPetrolStations = ordr.Selected_Petrol_Stations__c;
            ei.ShippingCompanyIndividualName = ordr.Shipping_Company_Individual_Name__c;
            ei.ShippingStreet = ordr.Shipping_Street__c;
            ei.ShippingHouseNumber = ordr.Shipping_House_Number__c;
            ei.ShippingPostalCode = ordr.Shipping_Postal_Code__c;
            ei.ShippingCity = ordr.Shipping_City__c;
            ei.ShippingCountry = ordr.Shipping_Country__c;
            ei.CurrencyIsoCode = ordr.CurrencyIsoCode;
            ei.ProductCountry = ordr.Product_Country__c;
            //ei.Street = ordr.Street__c;
            ei.TCAgree = String.valueOf(ordr.T_C_Agree__c);
            ei.TotalMonthlyPayment = ordr.Total_Monthly_Payment__c;
            ei.Price = ordr.Price__c;
            ei.VAT = ordr.VAT__c;
            ei.PaymentType = ordr.Payment_Type__c;
            ei.opp = [SELECT Id, AccountId, CCS_GFN_number__c, Type  FROM Opportunity WHERE Id = :ordr.Opportunity__c];
            ei.acc = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry FROM Account WHERE Id = :ei.opp.AccountId];

            switch on ei.CurrencyIsoCode {
                when 'CZK' {
                    ei.Queue = 'CZ';
                }
                when 'EUR' {
                    ei.Queue = 'SK';
                }
            }
            excelList.add(ei);

            /* CCS CONTACT */
            List<CCS_Contact__c> conList = [SELECT Email__c, First_Name__c, Last_Name__c, Phone__c, Primary__c, Role__c, Account_administrator__c, Authorised_signatory__c FROM CCS_Contact__c WHERE CCS_Order__c = :ordr.Id ORDER BY Primary__c DESC];

            if(conList.size() > 0){
                Integer i = 1;
                for(CCS_Contact__c con : conList){
                    ei = new ExcelInfo();
                    ei.Type = 'Contact'+i;
                    ei.Email = con.Email__c;
                    ei.FirstName = con.First_Name__c;
                    ei.LastName = con.Last_Name__c;
                    ei.Phone = con.Phone__c;
                    ei.Role = con.Role__c;
                    ei.AccountAdministrator = String.valueOf(con.Account_administrator__c);
                    ei.AuthorisedSignatory = String.valueOf(con.Authorised_signatory__c);
                    ei.Primary = String.valueOf(con.Primary__c);

                    excelList.add(ei);
                    i++;
                }
            }

            /* Karta CCS Bonus */
            List<Karta_CCS_Bonus__c> bonusList = [SELECT Financni_naboj_karty_v_Kc__c, Pocet_karet_s_timto_nastavenim__c, CurrencyIsoCode FROM Karta_CCS_Bonus__c WHERE CCS_Order__c = :ordr.Id];

            if(bonusList.size() > 0){
                Integer i = 1;
                for(Karta_CCS_Bonus__c karta : bonusList){
                    ei = new ExcelInfo();
                    ei.Type = 'Card'+i;
                    ei.CurrencyIsoCode = karta.CurrencyIsoCode;
                    ei.FinancninabojkartyvKc = karta.Financni_naboj_karty_v_Kc__c;
                    //ei.Narozeninovedarkovebaleni = String.valueOf(karta.Narozeninove_darkove_baleni__c);
                    ei.Pocetkaretstimtonastavenim = karta.Pocet_karet_s_timto_nastavenim__c;
                    //ei.Vanocnidarkovebaleni = String.valueOf(karta.Vanocni_darkove_baleni__c);

                    excelList.add(ei);
                    i++;
                }
            }

            /* Karta CCS Bonus Fleet */
            List<Karta_CCS_Bonus_Fleet__c> bonusFleetList = [SELECT Denni_limit_v_Kc__c, Mesicni_limit_v_Kc__c, Povolene_kody_zbozi__c, Povolene_skupiny_zbozi__c, RZ_vozidla_nebo_jmeno_ridice__c, Tydenni_limit_v_Kc__c, CurrencyIsoCode FROM Karta_CCS_Bonus_Fleet__c WHERE CCS_Order__c = :ordr.Id];

            if(bonusFleetList.size() > 0){
                Integer i = 1;
                for(Karta_CCS_Bonus_Fleet__c karta : bonusFleetList){
                    ei = new ExcelInfo();
                    ei.Type = 'Card'+i;
                    ei.CurrencyIsoCode = karta.CurrencyIsoCode;
                    ei.DennilimitvKc = karta.Denni_limit_v_Kc__c;
                    ei.MesicnilimitvKc = karta.Mesicni_limit_v_Kc__c;
                    ei.TydennilimitvKc = karta.Tydenni_limit_v_Kc__c;
                    ei.Povolenekodyzbozi = karta.Povolene_kody_zbozi__c;
                    ei.Povoleneskupinyzbozi = karta.Povolene_skupiny_zbozi__c;
                    ei.RZvozidlanebojmenoridice = karta.RZ_vozidla_nebo_jmeno_ridice__c;
                    excelList.add(ei);
                    i++;
                }
            }

            /* Karta CCS Limit */
            List<Karta_CCS_Limit__c> bonusLimitList = [SELECT Aktivovat_zadavani_stavu_kilometru__c, EV_Charging__c, Denni_limit_v_Kc__c, Mesicni_limit_v_Kc__c, Povolene_kody_zbozi__c, Povolene_skupiny_zbozi__c, Poznamka_k_objednavce__c, RZ_vozidla_nebo_jmeno_ridice__c, Typ_vozidla__c, Zablokovat_zmenu_PIN_kodu__c, CurrencyIsoCode FROM Karta_CCS_Limit__c WHERE CCS_Order__c = :ordr.Id];

            if(bonusLimitList.size() > 0){
                Integer i = 1;
                for(Karta_CCS_Limit__c karta : bonusLimitList){
                    ei = new ExcelInfo();
                    ei.Type = 'Card'+i;
                    ei.CurrencyIsoCode = karta.CurrencyIsoCode;
                    ei.DennilimitvKc = karta.Denni_limit_v_Kc__c;
                    ei.MesicnilimitvKc = karta.Mesicni_limit_v_Kc__c;
                    ei.Povolenekodyzbozi = karta.Povolene_kody_zbozi__c;
                    ei.Povoleneskupinyzbozi = karta.Povolene_skupiny_zbozi__c;
                    ei.RZvozidlanebojmenoridice = karta.RZ_vozidla_nebo_jmeno_ridice__c;
                    ei.Aktivovatzadavanistavukilometru = String.valueOf(karta.Aktivovat_zadavani_stavu_kilometru__c);
                    ei.EVCharging = String.valueOf(karta.EV_Charging__c);
                    if(karta.Poznamka_k_objednavce__c == null){
                        ei.Poznamkakobjednavce = karta.Poznamka_k_objednavce__c;
                    }
                    else {
                        ei.Poznamkakobjednavce = karta.Poznamka_k_objednavce__c.escapeHtml4();
                    }
                    ei.Typvozidla = karta.Typ_vozidla__c;
                    ei.ZablokovatzmenuPINkodu = String.valueOf(karta.Zablokovat_zmenu_PIN_kodu__c);
                    excelList.add(ei);
                    i++;
                }
            }

            /* Vozidlo CCS Carnet */
            List<Vozidlo_CCS_Carnet__c> vozidloList = [SELECT Contract_Term__c, GPRS_Profi__c, GPRS_Roaming__c, GPRS_Fee__c, IMEI__c, Monthly_Fee__c, Unit_Fee__c FROM Vozidlo_CCS_Carnet__c WHERE CCS_Order__c = :ordr.Id];

            if(vozidloList.size() > 0){
                Integer i = 1;
                for(Vozidlo_CCS_Carnet__c voz : vozidloList){
                    ei = new ExcelInfo();
                    ei.Type = 'Vehicle'+i;
                    ei.IMEI = voz.IMEI__c;
                    ei.GPRSRoaming = String.valueOf(voz.GPRS_Roaming__c);
                    //ei.GPRSRoamingFee = voz.GPRS_Roaming_Fee__c;
                    ei.GPRSProfi = String.valueOf(voz.GPRS_Profi__c);
                    //ei.GPRSProfiFee = voz.GPRS_Profi_Fee__c;
                    ei.GPRSFee = voz.GPRS_Fee__c;
                    ei.MonthlyFee = voz.Monthly_Fee__c;
                    ei.UnitFee = voz.Unit_Fee__c;
                    ei.ContractTerm = voz.Contract_Term__c;
                    excelList.add(ei);
                    i++;
                }
            }

            /* CCS Additional HW */
            List<CCS_Additional_HW__c> additionalHWList = [SELECT CAN_Reader_contactless_Fee__c, CAN_Reader_contactless__c, CAN_Reader_Fee__c, CAN_Reader__c, Dallas_Chip_Fee__c, Dallas_Chip__c, Drivers_ID_Dallas_Reader_Fee__c, Drivers_ID_Dallas_Reader__c, Drivers_ID_RFID_Reader_Fee__c, Drivers_ID_RFID_Reader__c, External_Antenna_Fee__c, External_Antenna__c, Unit_Installation__c, Unit_Installation_Fee__c, RFID_Card_Fee__c, RFID_Card__c, RFID_Chip_Fee__c, RFID_Chip__c FROM CCS_Additional_HW__c WHERE CCS_Order__c = :ordr.Id];

            if(additionalHWList.size() > 0){
                Integer i = 1;
                for(CCS_Additional_HW__c additionalHW : additionalHWList){
                    ei = new ExcelInfo();
                    ei.Type = 'AdditionalHW'+i;
                    ei.CANReader = additionalHW.CAN_Reader__c;
                    ei.CANReaderFee = additionalHW.CAN_Reader_Fee__c;
                    ei.CANReaderContactless = additionalHW.CAN_Reader_contactless__c;
                    ei.CANReaderContactlessFee = additionalHW.CAN_Reader_contactless_Fee__c;
                    ei.DallasReader = additionalHW.Drivers_ID_Dallas_Reader__c;
                    ei.DallasReaderFee = additionalHW.Drivers_ID_Dallas_Reader_Fee__c;
                    ei.DallasChip = additionalHW.Dallas_Chip__c;
                    ei.DallasChipFee = additionalHW.Dallas_Chip_Fee__c;
                    ei.RFIDReader = additionalHW.Drivers_ID_RFID_Reader__c;
                    ei.RFIDReaderFee = additionalHW.Drivers_ID_RFID_Reader_Fee__c;
                    ei.RFIDChip = additionalHW.RFID_Chip__c;
                    ei.RFIDChipFee = additionalHW.RFID_Chip_Fee__c;
                    ei.RFIDCard = additionalHW.RFID_Card__c;
                    ei.RFIDCardFee = additionalHW.RFID_Card_Fee__c;
                    ei.ExternalAntenna = additionalHW.External_Antenna__c;
                    ei.ExternalAntennaFee = additionalHW.External_Antenna_Fee__c;
                    ei.UnitInstallation = additionalHW.Unit_Installation__c;
                    ei.UnitInstallationFee = additionalHW.Unit_Installation_Fee__c;
                    excelList.add(ei);
                    i++;
                }
            }
        }
    }
}