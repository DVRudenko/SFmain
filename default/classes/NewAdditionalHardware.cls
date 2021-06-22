public class NewAdditionalHardware {
    public Opportunity opportunity {get; set;}
    public String opportunityId;
    public Additional_Hardware__c AHW {get; set;}
    public String ahwId;
    public Boolean isntValid {get;set;}
    public Boolean hide {get;set;}
    
    public NewAdditionalHardware() {   
    
    AHW = new Additional_Hardware__c();
       
    }
    
    public PageReference init() {
        try {
            this.opportunityId = ApexPages.CurrentPage().getparameters().get('id');
            
            List<Opportunity> OpportunityList = [
                SELECT Name, Pricing_Approval_Status__c, Account_Price_Book__r.Active__c, Account_Price_Book__c, Account_Price_Book__r.Price_Book__r.Guarding_the_vehicle_one_switch__c, Account_Price_Book__r.Price_Book__r.Guarding_the_vehicle_reader__c,
                    Account_Price_Book__r.Price_Book__r.Button_Panic__c,
                    Account_Price_Book__r.Price_Book__r.Guarding_cargo_space__c,
                    Account_Price_Book__r.Price_Book__r.Reader_Dalas__c,
                    Account_Price_Book__r.Price_Book__r.Reader_RFID_Slim__c,
                    Account_Price_Book__r.Price_Book__r.Reader_Inditag__c,
                    Account_Price_Book__r.Price_Book__r.Reader_Mifare__c,
                    Account_Price_Book__r.Price_Book__r.Reader_Multi_125__c,
                    Account_Price_Book__r.Price_Book__r.Reader_HIDProx__c,
                    Account_Price_Book__r.Price_Book__r.Reader_Multi_ISO__c,
                    Account_Price_Book__r.Price_Book__r.Reader_Legic__c,
                    Account_Price_Book__r.Price_Book__r.Dalas_chip__c,
                    Account_Price_Book__r.Price_Book__r.RFID_fobs__c,
                    Account_Price_Book__r.Price_Book__r.RFID_adhesive_chip__c,
                    Account_Price_Book__r.Price_Book__r.Piezoelectric_siren__c,
                    Account_Price_Book__r.Price_Book__r.Temperature_measurement_in_the_cargo_spa__c,
                    Account_Price_Book__r.Price_Book__r.Calibrating_transducer_PT100__c,
                    Account_Price_Book__r.Price_Book__r.Temperature_sensor_Pt100B_with_cable_1m__c,
                    Account_Price_Book__r.Price_Book__r.Temperature_sensor_Pt100A_with_cable_1m__c,
                    Account_Price_Book__r.Price_Book__r.Temperature_sensor_Dalas__c,
                    Account_Price_Book__r.Price_Book__r.X1_m_cable_to_the_temperature_sensor__c,
                    Account_Price_Book__r.Price_Book__r.X1_m_silicone_cable_to_the_temp_sensor__c,
                    Account_Price_Book__r.Price_Book__r.Plastic_temperature_sensor_holder__c,
                    Account_Price_Book__r.Price_Book__r.Basic_switch__c,
                    Account_Price_Book__r.Price_Book__r.Adhesive_switch_P_S__c,
                    Account_Price_Book__r.Price_Book__r.Adhesive_switch_P_S_with_a_diode_LED__c,
                    Account_Price_Book__r.Price_Book__r.Cable_CAN__c,
                    Account_Price_Book__r.Price_Book__r.CAN_GO_CLICK__c,
                    Account_Price_Book__r.Price_Book__r.Power_supply_power_cable_harnesses__c,
                    Account_Price_Book__r.Price_Book__r.Antenna_GPS_FLAT__c,
                    Account_Price_Book__r.Price_Book__r.Antenna_GPS_Shark__c,
                    Account_Price_Book__r.Price_Book__r.Spare_battery_for_CN85_1_4__c,
                    Account_Price_Book__r.Price_Book__r.Can_Bus_transducer_MCB_02__c,
                    Account_Price_Book__r.Price_Book__r.Microwave_sensor__c,
                    Account_Price_Book__r.Price_Book__r.Acoustic_signaling_with_LED__c,
                    Account_Price_Book__r.Price_Book__r.Button_Panic2__c,
                    Account_Price_Book__r.Price_Book__r.Siren_Alarm__c
                FROM Opportunity 
                WHERE Id = :this.opportunityId
                LIMIT 1];
                
            if (! OpportunityList.isEmpty() ) {
                this.opportunity = OpportunityList.get(0);
                AHW.Opportunity__c = this.opportunity.Id;
                AHW.Account_Price_Book__c = this.opportunity.Account_Price_Book__c;
                AHW.Guarding_the_vehicle_one_switch_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Guarding_the_vehicle_one_switch__c;
                AHW.Guarding_the_vehicle_reader_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Guarding_the_vehicle_reader__c;
                AHW.Button_Panic_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Button_Panic__c;
                AHW.Guarding_cargo_space_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Guarding_cargo_space__c;
                AHW.Reader_Dalas_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_Dalas__c;
                AHW.Reader_RFID_Slim_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_RFID_Slim__c;
                AHW.Reader_Inditag_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_Inditag__c;
                AHW.Reader_Mifare_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_Mifare__c;
                AHW.Reader_Multi_125_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_Multi_125__c;
                AHW.Reader_HIDProx_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_HIDProx__c;
                AHW.Reader_Multi_ISO_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_Multi_ISO__c;
                AHW.Reader_Legic_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reader_Legic__c;
                AHW.Dalas_chip_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Dalas_chip__c;
                AHW.RFID_fobs_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.RFID_fobs__c;
                AHW.RFID_adhesive_chip_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.RFID_adhesive_chip__c;
                AHW.Piezoelectric_siren_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Piezoelectric_siren__c;
                AHW.Temperature_measurementCargoSpace_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Temperature_measurement_in_the_cargo_spa__c;
                AHW.Calibrating_transducer_PT100_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Calibrating_transducer_PT100__c;
                AHW.Temperature_sensor_Pt100B_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Temperature_sensor_Pt100B_with_cable_1m__c;
                AHW.Temperature_sensor_Pt100A_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Temperature_sensor_Pt100A_with_cable_1m__c;
                AHW.Temperature_sensor_Dalas_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Temperature_sensor_Dalas__c;
                AHW.X1_m_cable_to_the_temperature_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.X1_m_cable_to_the_temperature_sensor__c;
                AHW.X1_m_silicone_cable_temp_sensor_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.X1_m_silicone_cable_to_the_temp_sensor__c;
                AHW.Plastic_temperature_sensor_holder_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Plastic_temperature_sensor_holder__c;
                AHW.Basic_switch_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Basic_switch__c;
                AHW.Adhesive_switch_P_S_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Adhesive_switch_P_S__c;
                AHW.Adhesive_switch_P_S_with_diode_LED_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Adhesive_switch_P_S_with_a_diode_LED__c;
                AHW.Cable_CAN_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Cable_CAN__c;
                AHW.CAN_GO_CLICK_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.CAN_GO_CLICK__c;
                AHW.Power_supply_power_cable_harnesses_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Power_supply_power_cable_harnesses__c;
                AHW.Antenna_GPS_FLAT_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Antenna_GPS_FLAT__c;
                AHW.Antenna_GPS_Shark_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Antenna_GPS_Shark__c;
                AHW.Spare_battery_for_CN85_1_4_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Spare_battery_for_CN85_1_4__c;
                AHW.Can_Bus_transducer_MCB_02_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Can_Bus_transducer_MCB_02__c;
                AHW.Microwave_sensor_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Microwave_sensor__c;
                AHW.Acoustic_signaling_with_LED_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Acoustic_signaling_with_LED__c;
                AHW.Button_Panic2_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Button_Panic2__c;
                AHW.Siren_Alarm_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Siren_Alarm__c;
                
                AHW.Account_Price_Book__c = this.opportunity.Account_Price_Book__c;
                if(AHW.Account_Price_Book__c == null){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Account Price Book on Opportunity.'));
                   isntValid = false;
                    hide = true;
                   return null;
                }

                if(this.opportunity.Account_Price_Book__r.Active__c == False){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Carnet_Inactive_Price_Book));
                    isntValid = false;
                    hide = true;
                    return null;
                }
                
                if(this.opportunity.Pricing_Approval_Status__c == 'Pending Approval'){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Opportunity is in an Approval Process, you will need an approval before creating new Additional Hardware.'));
                    isntValid = false;
                    hide = true;
                    return null;
                }
                else{
                    isntValid = true;
                    hide = false;
                }
                
            } else {
                throw new MessageException('Wrong record, try again.');
            }
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public PageReference cancel() {
        return new PageReference('/' + this.opportunity.Id);
    }
    
    public PageReference save() {
        try {
        
        Additional_Hardware__c newAHW = new Additional_Hardware__c();
        newAHW.Opportunity__c = this.opportunity.Id;
        newAHW.Account_Price_Book__c = this.opportunity.Account_Price_Book__c;
        newAHW.Price_Book__c = this.opportunity.Account_Price_Book__r.Price_Book__c;
        newAHW.Guarding_the_vehicle_one_switch_Amount__c = AHW.Guarding_the_vehicle_one_switch_Amount__c;
        newAHW.Guarding_the_vehicle_reader_Amount__c = AHW.Guarding_the_vehicle_reader_Amount__c;
        newAHW.Button_Panic_Amount__c = AHW.Button_Panic_Amount__c;
        newAHW.Guarding_cargo_space_Amount__c = AHW.Guarding_cargo_space_Amount__c;
        newAHW.Reader_Dalas_Amount__c = AHW.Reader_Dalas_Amount__c;
        newAHW.Reader_RFID_Slim_Amount__c = AHW.Reader_RFID_Slim_Amount__c;
        newAHW.Reader_Inditag_Amount__c = AHW.Reader_Inditag_Amount__c;
        newAHW.Reader_Mifare_Amount__c = AHW.Reader_Mifare_Amount__c;
        newAHW.Reader_Multi_125_Amount__c = AHW.Reader_Multi_125_Amount__c;
        newAHW.Reader_HIDProx_Amount__c = AHW.Reader_HIDProx_Amount__c;
        newAHW.Reader_Multi_ISO_Amount__c = AHW.Reader_Multi_ISO_Amount__c;
        newAHW.Reader_Legic_Amount__c = AHW.Reader_Legic_Amount__c;
        newAHW.Dalas_chip_Amount__c = AHW.Dalas_chip_Amount__c;
        newAHW.RFID_fobs_Amount__c = AHW.RFID_fobs_Amount__c;
        newAHW.RFID_adhesive_chip_Amount__c = AHW.RFID_adhesive_chip_Amount__c;
        newAHW.Piezoelectric_siren_Amount__c = AHW.Piezoelectric_siren_Amount__c;
        newAHW.Temperature_measurementCargoSpace_Amount__c = AHW.Temperature_measurementCargoSpace_Amount__c;
        newAHW.Calibrating_transducer_PT100_Amount__c = AHW.Calibrating_transducer_PT100_Amount__c;
        newAHW.Temperature_sensor_Pt100B_Amount__c = AHW.Temperature_sensor_Pt100B_Amount__c;
        newAHW.Temperature_sensor_Pt100A_Amount__c = AHW.Temperature_sensor_Pt100A_Amount__c;
        newAHW.Temperature_sensor_Dalas_Amount__c = AHW.Temperature_sensor_Dalas_Amount__c;
        newAHW.X1_m_cable_to_the_temperature_Amount__c = AHW.X1_m_cable_to_the_temperature_Amount__c;
        newAHW.X1_m_silicone_cable_temp_sensor_Amount__c = AHW.X1_m_silicone_cable_temp_sensor_Amount__c;
        newAHW.Plastic_temperature_sensor_holder_Amount__c = AHW.Plastic_temperature_sensor_holder_Amount__c;
        newAHW.Basic_switch_Amount__c = AHW.Basic_switch_Amount__c;
        newAHW.Adhesive_switch_P_S_Amount__c = AHW.Adhesive_switch_P_S_Amount__c;
        newAHW.Adhesive_switch_P_S_withDiode_LED_Amoun__c = AHW.Adhesive_switch_P_S_withDiode_LED_Amoun__c;
        newAHW.Cable_CAN_Amount__c = AHW.Cable_CAN_Amount__c;
        newAHW.CAN_GO_CLICK_Amount__c = AHW.CAN_GO_CLICK_Amount__c;
        newAHW.Power_supplyPower_cable_harnesses_Amount__c = AHW.Power_supplyPower_cable_harnesses_Amount__c;
        newAHW.Antenna_GPS_FLAT_Amount__c = AHW.Antenna_GPS_FLAT_Amount__c;
        newAHW.Antenna_GPS_Shark_Amount__c = AHW.Antenna_GPS_Shark_Amount__c;
        newAHW.Spare_battery_for_CN85_1_4_Amount__c = AHW.Spare_battery_for_CN85_1_4_Amount__c;
        newAHW.Can_Bus_transducer_MCB_02_Amount__c = AHW.Can_Bus_transducer_MCB_02_Amount__c;
        newAHW.Microwave_sensor_Amount__c = AHW.Microwave_sensor_Amount__c;
        newAHW.Acoustic_signaling_with_LED_Amount__c = AHW.Acoustic_signaling_with_LED_Amount__c;
        newAHW.Button_Panic2_Amount__c = AHW.Button_Panic2_Amount__c;
        newAHW.Siren_Alarm_Amount__c = AHW.Siren_Alarm_Amount__c;
        newAHW.Guarding_the_vehicle_one_switch_Price__c = AHW.Guarding_the_vehicle_one_switch_Price__c;
        newAHW.Guarding_the_vehicle_reader_Price__c = AHW.Guarding_the_vehicle_reader_Price__c;
        newAHW.Button_Panic_Price__c = AHW.Button_Panic_Price__c;
        newAHW.Guarding_cargo_space_Price__c = AHW.Guarding_cargo_space_Price__c;
        newAHW.Reader_Dalas_Price__c = AHW.Reader_Dalas_Price__c;
        newAHW.Reader_RFID_Slim_Price__c = AHW.Reader_RFID_Slim_Price__c;
        newAHW.Reader_Inditag_Price__c = AHW.Reader_Inditag_Price__c;
        newAHW.Reader_Mifare_Price__c = AHW.Reader_Mifare_Price__c;
        newAHW.Reader_Multi_125_Price__c = AHW.Reader_Multi_125_Price__c;
        newAHW.Reader_HIDProx_Price__c = AHW.Reader_HIDProx_Price__c;
        newAHW.Reader_Multi_ISO_Price__c = AHW.Reader_Multi_ISO_Price__c;
        newAHW.Reader_Legic_Price__c = AHW.Reader_Legic_Price__c;
        newAHW.Dalas_chip_Price__c = AHW.Dalas_chip_Price__c;
        newAHW.RFID_fobs_Price__c = AHW.RFID_fobs_Price__c;
        newAHW.RFID_adhesive_chip_Price__c = AHW.RFID_adhesive_chip_Price__c;
        newAHW.Piezoelectric_siren_Price__c = AHW.Piezoelectric_siren_Price__c;
        newAHW.Temperature_measurementCargoSpace_Price__c = AHW.Temperature_measurementCargoSpace_Price__c;
        newAHW.Calibrating_transducer_PT100_Price__c = AHW.Calibrating_transducer_PT100_Price__c;
        newAHW.Temperature_sensor_Pt100B_Price__c = AHW.Temperature_sensor_Pt100B_Price__c;
        newAHW.Temperature_sensor_Pt100A_Price__c = AHW.Temperature_sensor_Pt100A_Price__c;
        newAHW.Temperature_sensor_Dalas_Price__c = AHW.Temperature_sensor_Dalas_Price__c;
        newAHW.X1_m_cable_to_the_temperature_Price__c = AHW.X1_m_cable_to_the_temperature_Price__c;
        newAHW.X1_m_silicone_cable_temp_sensor_Price__c = AHW.X1_m_silicone_cable_temp_sensor_Price__c;
        newAHW.Plastic_temperature_sensor_holder_Price__c = AHW.Plastic_temperature_sensor_holder_Price__c;
        newAHW.Basic_switch_Price__c = AHW.Basic_switch_Price__c;
        newAHW.Adhesive_switch_P_S_Price__c = AHW.Adhesive_switch_P_S_Price__c;
        newAHW.Adhesive_switch_P_S_withDiode_LED_Amoun__c = AHW.Adhesive_switch_P_S_withDiode_LED_Amoun__c;
        newAHW.Adhesive_switch_P_S_with_diode_LED_Price__c = AHW.Adhesive_switch_P_S_with_diode_LED_Price__c;
        newAHW.Cable_CAN_Price__c = AHW.Cable_CAN_Price__c;
        newAHW.CAN_GO_CLICK_Price__c = AHW.CAN_GO_CLICK_Price__c;
        newAHW.Power_supply_power_cable_harnesses_Price__c = AHW.Power_supply_power_cable_harnesses_Price__c;
        newAHW.Antenna_GPS_FLAT_Price__c = AHW.Antenna_GPS_FLAT_Price__c;
        newAHW.Antenna_GPS_Shark_Price__c = AHW.Antenna_GPS_Shark_Price__c;
        newAHW.Spare_battery_for_CN85_1_4_Price__c = AHW.Spare_battery_for_CN85_1_4_Price__c;
        newAHW.Can_Bus_transducer_MCB_02_Price__c = AHW.Can_Bus_transducer_MCB_02_Price__c;
        newAHW.Microwave_sensor_Price__c = AHW.Microwave_sensor_Price__c;
        newAHW.Acoustic_signaling_with_LED_Price__c = AHW.Acoustic_signaling_with_LED_Price__c;
        newAHW.Button_Panic2_Price__c = AHW.Button_Panic2_Price__c;
        newAHW.Siren_Alarm_Price__c = AHW.Siren_Alarm_Price__c;
        newAHW.CurrencyIsoCode = 'PLN';
        
        if(AHW.Account_Price_Book__c != null){
        insert newAHW;
        
        PageReference pg = new PageReference('/'+ this.opportunityId);
        pg.setRedirect(true);
        return pg;
        }
        else{
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Account Price Book on Opportunity.'));
        return null;
        }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public class MessageException extends Exception {}
}