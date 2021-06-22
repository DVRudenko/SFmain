@IsTest
private class ChooseCarnetUnitctrlTest {
    @testSetup
    static void setup() {

    }
    @IsTest
    static void testingStandard() {

        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
    
        Account a = new Account(
                Name = 'TEST',
                BillingCountry = 'Poland',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69');
        insert a;

        Contact c = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST',
                AccountId = a.Id,
                Email = 'test@test.com');
        insert c;

        Opportunity o = new Opportunity(
                Name = 'TEST',
                Product__c = 'Carnet Standard 2019',
                RecordTypeId = carnetOppoRecId,
                AccountId = a.id,
                Primary_Contact__c = c.Id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Form_of_Payment__c = 'Bank Transfer - after delivery',
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

        Account_Price_Book__c account_price_book = new Account_Price_Book__c(
                Name = 'Carnet Unit 2019',
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
                Contract_term__c = '24 months',
                Monitoring_in_EU__c = false,
                Monitoring_in_other_European_countries__c = true,
                Carnet_Tariff__c = 'Standard 24',
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

        Additional_Hardware__c adx = new Additional_Hardware__c(
                CurrencyIsoCode = 'PLN',
                opportunity__c = o.Id,
                Guarding_the_vehicle_one_switch_Price__c = 1.0,
                Guarding_the_vehicle_reader_Price__c = 250.0,
                Button_Panic_Price__c = 10.0,
                Guarding_cargo_space_Price__c = 515.0,
                Reader_Dalas_Price__c = 35.0,
                Reader_RFID_Slim_Price__c = 259.0,
                Reader_Inditag_Price__c = 899.0,
                Reader_Mifare_Price__c = 599.0,
                Reader_Multi_125_Price__c = 599.0,
                Reader_HIDProx_Price__c = 749.0,
                Reader_Multi_ISO_Price__c = 719.0,
                Reader_Legic_Price__c = 879.0,
                Dalas_chip_Price__c = 13.0,
                RFID_fobs_Price__c = 9.0,
                RFID_adhesive_chip_Price__c = 8.0,
                Piezoelectric_siren_Price__c = 7.0,
                Temperature_measurementCargoSpace_Price__c = 295.0,
                Calibrating_transducer_PT100_Price__c = 199.0,
                Temperature_sensor_Pt100B_Price__c = 36.0,
                Temperature_sensor_Pt100A_Price__c = 39.0,
                Temperature_sensor_Dalas_Price__c = 75.0,
                X1_m_cable_to_the_temperature_Price__c = 3.0,
                X1_m_silicone_cable_temp_sensor_Price__c = 5.0,
                Plastic_temperature_sensor_holder_Price__c = 6.0,
                Basic_switch_Price__c = 3.0,
                Adhesive_switch_P_S_Price__c = 23.0,
                Adhesive_switch_P_S_with_diode_LED_Price__c = 39.0,
                Cable_CAN_Price__c = 5.0,
                CAN_GO_CLICK_Price__c = 99.0,
                Power_supply_power_cable_harnesses_Price__c = 13.0,
                Antenna_GPS_FLAT_Price__c = 39.0,
                Antenna_GPS_Shark_Price__c = 79.0,
                Spare_battery_for_CN85_1_4_Price__c = 65.0,
                Can_Bus_transducer_MCB_02_Price__c = 165.0,
                Microwave_sensor_Price__c = 279.0,
                Acoustic_signaling_with_LED_Price__c = 17.0,
                Button_Panic2_Price__c = 60.0,
                Siren_Alarm_Price__c = 33.0,
                Price_Book__c = pricebook2.Id,
                Account_Price_Book__c = account_price_book.Id,
                Pricing_Approval_Status__c = 'Approval Required',
                X1_m_cable_to_the_temperature_Amount__c = 1,
                X1_m_silicone_cable_temp_sensor_Amount__c = 1,
                Acoustic_signaling_with_LED_Amount__c = 1,
                Adhesive_switch_P_S_Amount__c = 1,
                Adhesive_switch_P_S_withDiode_LED_Amoun__c = 2,
                Antenna_GPS_FLAT_Amount__c = 2,
                Antenna_GPS_Shark_Amount__c = 2,
                Basic_switch_Amount__c = 2,
                Button_Panic_Amount__c = 1.0,
                Button_Panic2_Amount__c = 2,
                Cable_CAN_Amount__c = 2,
                Calibrating_transducer_PT100_Amount__c = 2,
                Can_Bus_transducer_MCB_02_Amount__c = 2,
                CAN_GO_CLICK_Amount__c = 2,
                Dalas_chip_Amount__c = 2,
                Guarding_cargo_space_Amount__c = 1.0,
                Guarding_the_vehicle_one_switch_Amount__c = 1.0,
                Guarding_the_vehicle_reader_Amount__c = 1.0,
                Microwave_sensor_Amount__c = 2,
                Piezoelectric_siren_Amount__c = 3,
                Plastic_temperature_sensor_holder_Amount__c = 5,
                Power_supplyPower_cable_harnesses_Amount__c = 5,
                Reader_Dalas_Amount__c = 5,
                Reader_HIDProx_Amount__c = 5,
                Reader_Inditag_Amount__c = 8,
                Reader_Legic_Amount__c = 8,
                Reader_Mifare_Amount__c = 8,
                Reader_Multi_125_Amount__c = 8,
                Reader_Multi_ISO_Amount__c = 8,
                Reader_RFID_Slim_Amount__c = 8,
                RFID_adhesive_chip_Amount__c = 8,
                RFID_fobs_Amount__c = 8,
                Siren_Alarm_Amount__c = 7,
                Spare_battery_for_CN85_1_4_Amount__c = 7,
                Temperature_measurementCargoSpace_Amount__c =7,
                Temperature_sensor_Dalas_Amount__c = 7,
                Temperature_sensor_Pt100A_Amount__c = 7,
                Temperature_sensor_Pt100B_Amount__c = 7);
            insert adx;


        test.startTest();


        Apexpages.currentPage().getParameters().put('id',o.Id);
        ChooseCarnetUnitctrl ccd = new ChooseCarnetUnitctrl();

        System.assertEquals(null, ccd.opportunity);
        System.assertEquals(null, ccd.opportunityId);

        ccd.opportunity = o;

        System.assertEquals(null, ccd.init());
        System.assertNotEquals(null, ccd.cancel());
        System.assertNotEquals(null, ccd.next());


        Opportunity o2 = new Opportunity(
                Name = 'TEST',
                Product__c = 'Carnet Standard 2019',
                RecordTypeId = carnetOppoRecId,
                AccountId = a.id,
                Primary_Contact__c = c.Id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o2;

        Apexpages.currentPage().getParameters().put('id',o2.Id);
        ChooseCarnetUnitctrl dede = new ChooseCarnetUnitctrl();
    }
    
    @IsTest
    static void testingOBD() {

        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
    
        Account a = new Account(
                Name = 'TEST',
                BillingCountry = 'Poland',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69');
        insert a;

        Contact c = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST',
                AccountId = a.Id,
                Email = 'test@test.com');
        insert c;

        Opportunity o = new Opportunity(
                Name = 'TEST',
                Product__c = 'Carnet OBD',
                RecordTypeId = carnetOppoRecId,
                AccountId = a.id,
                Primary_Contact__c = c.Id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Form_of_Payment__c = 'Bank Transfer - after delivery',
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

        Account_Price_Book__c account_price_book = new Account_Price_Book__c(
                Name = 'Carnet Unit 2019',
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
                Contract_term__c = '24 months',
                Monitoring_in_EU__c = false,
                Monitoring_in_other_European_countries__c = true,
                Carnet_Tariff__c = 'Standard 24',
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

        test.startTest();


        Apexpages.currentPage().getParameters().put('id',o.Id);
        ChooseCarnetUnitctrl ccd = new ChooseCarnetUnitctrl();

        System.assertEquals(null, ccd.opportunity);
        System.assertEquals(null, ccd.opportunityId);

        ccd.opportunity = o;

        System.assertEquals(null, ccd.init());
        System.assertNotEquals(null, ccd.cancel());
        System.assertNotEquals(null, ccd.next());


        Opportunity o2 = new Opportunity(
                Name = 'TEST',
                Product__c = 'Carnet OBD',
                RecordTypeId = carnetOppoRecId,
                AccountId = a.id,
                Primary_Contact__c = c.Id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o2;

        Apexpages.currentPage().getParameters().put('id',o2.Id);
        ChooseCarnetUnitctrl dede = new ChooseCarnetUnitctrl();
    }
}