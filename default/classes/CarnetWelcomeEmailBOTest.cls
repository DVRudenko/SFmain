@IsTest
private class CarnetWelcomeEmailBOTest {
    @IsTest
    static void testing() {
        Account a = new Account(
                Name = 'test',
                BillingCountry = 'Poland',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69');
        insert a;

        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');
        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name IN ('API Only', 'System Administrator') AND IsActive = true LIMIT 1];

        Account account = new Account(
                Name = 'INTERCODEC4',
                Type = 'Customer',
                RecordTypeId = endkundeAccRecId,
                BillingStreet = 'TESTOVACI 1',
                BillingCity = 'WARSAW',
                BillingState = 'Lower Silesia',
                BillingPostalCode = '12345',
                BillingCountry = 'Poland',
                BillingStateCode = 'DS',
                BillingCountryCode = 'PL',
                ShippingStreet = 'TESTOVACI 2',
                ShippingCity = 'LODZ',
                ShippingState = 'Kuyavia-Pomerania',
                ShippingPostalCode = '12345',
                ShippingCountry = 'Poland',
                ShippingStateCode = 'KP',
                ShippingCountryCode = 'PL',
                Phone = '+420123456789',
                CurrencyIsoCode = 'PLN',
                OwnerId = User.get(0).Id,
                IsExcludedFromRealign = false,
                AccountSource = 'ABVP',
                Gesellschaftsform__c = 'Agency of an Overseas Business',
                GFN_Nr__c = '1',
                Karte_zusenden__c = false,
                Pin_vergessen__c = false,
                CardProcessing_abgeschlossen__c = false,
                Einwilligung_Lastschriftverfahren__c = false,
                Beschaeftigte__c = '1-4',
                Daten_fehlerhaft__c = false,
                AGB_Best_tigt__c = 'Ja',
                Disclosure_Group_FO_Account_SILVER__c = 'FCCI0249',
                Disclosure_Group_FO_Account_PLUS__c = 'FCCI0348',
                Disclosure_Group_FO_Account_GOLD__c = 'FCCI0398',
                Alternate_Disclosure_Group_SILVER__c = 'FCCI0000',
                Alternate_Disclosure_Group_PLUS__c = 'FCCI0099',
                Alternate_Disclosure_Group_GOLD__c = 'FCCI0149',
                Tage_Alternate_Disclosure_Group_SILVER__c = '0',
                Tage_Alternate_Disclosure_Group_PLUS__c = '0',
                Tage_Alternate_Disclosure_Group_GOLD__c = '0',
                Retailer_Status__c = 'aktiv',
                Subaccount__c = false,
                No_Card_fee__c = '0',
                Steuernummer__c = '98765432111',
                E2E__c = false,
                Kartentyp__c = 'FlexKarte',
                Antrag_generieren__c = false,
                Sec_Channel_Acc__c = 'Outbound',
                Aware_of_NoFee_Offer_conditions__c = false,
                Aware_of_retailer_bonus_program__c = false,
                Have_objections__c = false,
                Vouchers_Sent__c = 0.0,
                CCS_Account_Record_Type__c = 'Endkunde',
                Portal_Schreibschutz__c = false,
                Lead_Record_Type__c = 'Endkunde',
                Cold_Lead__c = false,
                Consent_Form_Datatransfer__c = false,
                Active_Change_Owner_Request__c = false,
                Interested_in_cooperation__c = false,
                Agree_to_process_pers_data_for_marketing__c = false,
                Agree_to_receive_comm_info_by_email__c = false,
                Agree_to_telephone_contact__c = false,
                Customer_s_Search_Request__c = 'Общий',
                CCS_account_merge_status__c = false,
                Not_Interessted_Brand_Fleetcor__c = false,
                Positiv_Brand_Fleetcor__c = false,
                Discount_too_low__c = false,
                Fees_too_high__c = false,
                Offer_sounds_interessting__c = false,
                Offer_and_Advantages_explained__c = false,
                Know_the_Retailerportal__c = false,
                E2E_Voucher_sent__c = false);
        insert account;

        Contact c = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = a.Id,
                Email = 'test@test.com');
        insert c;

        Opportunity o = new Opportunity(
                Name = 'test',
                Product__c = 'Carnet Standard 2019',
                AccountId = a.id,
                Primary_Contact__c = c.Id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Form_of_Payment__c = 'Cash on delivery',
                Monthly_Payment_Method__c = 'Bank transfer',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o;

        OpportunityContactRole ocr = new OpportunityContactRole(
                OpportunityId = o.Id,
                ContactId = c.Id,
                IsPrimary = true
        );
        insert ocr;

        String carnetPBRecId = GlobalUtils.returnRecordTypeId('Pricebook2', 'Carnet_Unit');

        Pricebook2 pricebook2 = new Pricebook2(
                Name = 'Carnet Unit 2019',
                CurrencyIsoCode = 'PLN',
                RecordTypeId = '0120O000000XMWb',
                IsActive = true,
                Description = 'Prices for 2019.',
                Standard_Unit_Package__c = 289.0,
                Unit_Activation__c = 0.0,
                Installation__c = 199.0,
                Standard_24__c = 39.0,
                Standard_36__c = 29.0,
                EU_24__c = 44.0,
                EU_36__c = 34.0,
                Driving_Style__c = 1.0,
                Reservations__c = 2.0,
                Archiving__c = 25,
                On_line_position_above_standard__c = 1.0,
                Tariff_World__c = 17.0,
                Web_services__c = 1.0,
                Service_Alarm__c = 1.0,
                Guarding_the_vehicle_one_switch__c = 4.0,
                Guarding_the_vehicle_reader__c = 250.0,
                Button_Panic__c = 10.0,
                Guarding_cargo_space__c = 515.0,
                Reader_Dalas__c = 35.0,
                Reader_RFID_Slim__c = 259.0,
                Reader_Inditag__c = 899.0,
                Reader_Mifare__c = 599.0,
                Reader_Multi_125__c = 599.0,
                Reader_HIDProx__c = 749.0,
                Reader_Multi_ISO__c = 719.0,
                Reader_Legic__c = 879.0,
                Dalas_chip__c = 13.0,
                RFID_fobs__c = 9.0,
                RFID_adhesive_chip__c = 8.0,
                Piezoelectric_siren__c = 7.0,
                Temperature_measurement_in_the_cargo_spa__c = 295.0,
                Calibrating_transducer_PT100__c = 199.0,
                Temperature_sensor_Pt100B_with_cable_1m__c = 36.0,
                Temperature_sensor_Pt100A_with_cable_1m__c = 39.0,
                Temperature_sensor_Dalas__c = 75.0,
                X1_m_cable_to_the_temperature_sensor__c = 3.0,
                X1_m_silicone_cable_to_the_temp_sensor__c = 5.0,
                Plastic_temperature_sensor_holder__c = 6.0,
                Basic_switch__c = 3.0,
                Adhesive_switch_P_S__c = 23.0,
                Adhesive_switch_P_S_with_a_diode_LED__c = 39.0,
                Cable_CAN__c = 5.0,
                CAN_GO_CLICK__c = 99.0,
                Power_supply_power_cable_harnesses__c = 13.0,
                Antenna_GPS_FLAT__c = 39.0,
                Antenna_GPS_Shark__c = 79.0,
                Spare_battery_for_CN85_1_4__c = 65.0,
                Can_Bus_transducer_MCB_02__c = 165.0,
                Microwave_sensor__c = 279.0,
                Acoustic_signaling_with_LED__c = 17.0,
                Button_Panic2__c = 60.0,
                Siren_Alarm__c = 33.0,
                Standard_Unit_Package_6_15__c = 269.0,
                Standard_Unit_Package_16__c = 259.0,
                Custom__c = false);
        insert pricebook2;


        Account_Price_Book__c account_price_book = new Account_Price_Book__c(Name = 'Carnet Unit 2019',
                CurrencyIsoCode = 'PLN',
                Custom__c = false,
                Approval_Status__c = 'Not required',
                Account__c = a.Id,
                Price_Book__c = pricebook2.Id);
        insert account_price_book;

        Carnet_Unit__c carnet_unit = new Carnet_Unit__c(
                CurrencyIsoCode = 'PLN',
                Opportunity__c = o.Id,
                Pricing_Approval_Status__c = 'Not required',
                Number_of_Units__c = 1.0,
                Price_Book__c = pricebook2.Id,
                Account_Price_Book__c = account_price_book.Id,
                isEdited__c = false,
                Contract_term__c = '12 months',
                Monitoring_in_EU__c = false,
                Monitoring_in_other_European_countries__c = true,
                Carnet_Tariff__c = 'Standard 12',
                Driving_Style__c = true,
                Reservations__c = true,
                Archiving__c = true,
                On_line_position_above_standard__c = true,
                Web_services__c = true,
                Service_Alarm__c = true,
                Standard_Unit_Package__c = 289.0,
                Unit_Activation__c = 0.0,
                Installation__c = 199.0,
                Driving_Style_Price__c = 1.0,
                Reservations_Price__c = 2.0,
                Archiving_Price__c = 1.0,
                On_line_position_above_standard_Price__c = 1.0,
                Tariff_World_Price__c = 17.0,
                Web_services_Price__c = 1.0,
                Service_Alarm_Price__c = 1.0,
                Carnet_Tariff_Price__c = 44.0,
                Standard_Unit_Package3__c = 289.0,
                Standard_Unit_Package_16_c__c = 259.0,
                Standard_Unit_Package_6_15_c__c = 269.0,
                BypassValidationForProcessBuilder__c = false);
        insert carnet_unit;

        Carnet_Unit__c c2 = new Carnet_Unit__c(
                CurrencyIsoCode = 'PLN',
                Opportunity__c = o.Id,
                Pricing_Approval_Status__c = 'Not required',
                Number_of_Units__c = 1.0,
                Price_Book__c = pricebook2.Id,
                Account_Price_Book__c = account_price_book.Id,
                isEdited__c = false,
                Contract_term__c = '24 months',
                Monitoring_in_EU__c = false,
                Monitoring_in_other_European_countries__c = true,
                Carnet_Tariff__c = 'EU 24',
                Driving_Style__c = true,
                Reservations__c = true,
                Archiving__c = true,
                On_line_position_above_standard__c = true,
                Web_services__c = true,
                Service_Alarm__c = true,
                Standard_Unit_Package__c = 289.0,
                Unit_Activation__c = 0.0,
                Installation__c = 199.0,
                Driving_Style_Price__c = 1.0,
                Reservations_Price__c = 2.0,
                Archiving_Price__c = 1.0,
                On_line_position_above_standard_Price__c = 1.0,
                Tariff_World_Price__c = 17.0,
                Web_services_Price__c = 1.0,
                Service_Alarm_Price__c = 1.0,
                Carnet_Tariff_Price__c = 44.0,
                Standard_Unit_Package3__c = 289.0,
                Standard_Unit_Package_16_c__c = 259.0,
                Standard_Unit_Package_6_15_c__c = 269.0,
                BypassValidationForProcessBuilder__c = false);
        insert c2;

        Carnet_Unit__c c21 = new Carnet_Unit__c(
                CurrencyIsoCode = 'PLN',
                Opportunity__c = o.Id,
                Pricing_Approval_Status__c = 'Not required',
                Number_of_Units__c = 1.0,
                Price_Book__c = pricebook2.Id,
                Account_Price_Book__c = account_price_book.Id,
                isEdited__c = false,
                Contract_term__c = '24 months',
                Monitoring_in_EU__c = false,
                Monitoring_in_other_European_countries__c = true,
                Carnet_Tariff__c = 'EU 24',
                Driving_Style__c = true,
                Reservations__c = true,
                Archiving__c = true,
                On_line_position_above_standard__c = true,
                Web_services__c = true,
                Service_Alarm__c = true,
                Standard_Unit_Package__c = 289.0,
                Unit_Activation__c = 10.0,
                Installation__c = 1929.0,
                Driving_Style_Price__c = 12.0,
                Reservations_Price__c = 22.0,
                Archiving_Price__c = 12.0,
                On_line_position_above_standard_Price__c = 21.0,
                Tariff_World_Price__c = 127.0,
                Web_services_Price__c = 1.20,
                Service_Alarm_Price__c = 12.0,
                Carnet_Tariff_Price__c = 442.0,
                Standard_Unit_Package3__c = 2289.0,
                Standard_Unit_Package_16_c__c = 2259.0,
                Standard_Unit_Package_6_15_c__c = 2649.0,
                BypassValidationForProcessBuilder__c = false);
        insert c21;

        Carnet_BO_Emails__c setting = new Carnet_BO_Emails__c();
        setting.Name = 'Poland';
        setting.Email__c = 'info@intercodec.cz';
        insert setting;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Carnet_podsumowanie_zamowienia',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                PathOnClient = 'Test.pdf'
        );
        insert contentVersion;

        test.startTest();

        try {
            o.StageName = 'Closed Won';
            update o;
        } catch (Exception error) {

        }

        List<id> listOfOpportunities = new List<Id>();
        listOfOpportunities.add(o.Id);

        CarnetWelcomeEmailBO cwBO = new CarnetWelcomeEmailBO();

        cwBO.sendcwBO(listOfOpportunities);

        test.stopTest();
    }
}