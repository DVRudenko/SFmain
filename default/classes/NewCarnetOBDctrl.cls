public with sharing class NewCarnetOBDctrl {
    public Opportunity opportunity {get; set;}
    public String opportunityId;
    public Carnet_Unit__c CU {get; set;}
    public String carnetunitId;
    public Boolean isntValid {get;set;}
    public Boolean hide {get;set;}

    /*public NewCarnetUnitctrl() {
        CU = new Carnet_Unit__c();
    }*/

    public PageReference init() {
        try {
            this.opportunityId = ApexPages.CurrentPage().getparameters().get('id');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You are creating new <b>Carnet OBD</b> Order.'));

            String carnetOBDRecId = GlobalUtils.returnRecordTypeId('Carnet_Unit__c', 'Carnet OBD');

            CU = new Carnet_Unit__c();
            CU.RecordTypeId = carnetOBDRecId;
            List<Opportunity> OpportunityList = [
                    SELECT Name, Account_Price_Book__c, Account_Price_Book__r.Active__c, Pricing_Approval_Status__c, Account_Price_Book__r.Price_Book__r.Archiving__c, Account_Price_Book__r.Price_Book__r.Tariff_World__c, Account_Price_Book__r.Price_Book__r.Driving_Style__c, Account_Price_Book__r.Price_Book__r.Reservations__c, Account_Price_Book__r.Price_Book__r.On_line_position_above_standard__c, Account_Price_Book__r.Price_Book__r.Web_services__c, Account_Price_Book__r.Price_Book__r.Service_Alarm__c, Account_Price_Book__r.Price_Book__r.Standard_Unit_Package__c, Account_Price_Book__r.Price_Book__r.Unit_Activation__c, Account_Price_Book__r.Price_Book__r.Installation__c, Account_Price_Book__r.Price_Book__r.Standard_Unit_Package_16__c, Account_Price_Book__r.Price_Book__r.Standard_Unit_Package_6_15__c, Account_Price_Book__r.Price_Book__r.Standard_24__c, Account_Price_Book__r.Price_Book__r.Standard_36__c, Account_Price_Book__r.Price_Book__r.EU_24__c, Account_Price_Book__r.Price_Book__r.EU_36__c, Account_Price_Book__r.Price_Book__r.Monitoring_in_EU__c, Account_Price_Book__r.Price_Book__r.Standard_12__c, Account_Price_Book__r.Price_Book__r.Prepaid_12__c, Account_Price_Book__r.Price_Book__r.Prepaid_24__c
                    FROM Opportunity
                    WHERE Id = :this.opportunityId
                    LIMIT 1];

            if (!OpportunityList.isEmpty() ) {
                this.opportunity = OpportunityList.get(0);
                CU.Opportunity__c = this.opportunity.Id;
                CU.Account_Price_Book__c = this.opportunity.Account_Price_Book__c;
                if(CU.Account_Price_Book__c == null){
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
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Opportunity is in an Approval Process, you will need an approval before creating new Carnet Units.'));
                    isntValid = false;
                    hide = true;
                    return null;
                }
                else{
                    isntValid = true;
                    hide = false;
                }
                CU.Account_Price_Book__c = this.opportunity.Account_Price_Book__c;
                CU.Monitoring_in_EU_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Monitoring_in_EU__c;
                CU.Archiving_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Archiving__c;
                CU.Tariff_World_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Tariff_World__c;
                CU.Driving_Style_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Driving_Style__c;
                CU.Reservations_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Reservations__c;
                CU.On_line_position_above_standard_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.On_line_position_above_standard__c;
                CU.Web_services_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Web_services__c;
                CU.Service_Alarm_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Service_Alarm__c;
                CU.Standard_Unit_Package__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Standard_Unit_Package__c;
                CU.Unit_Activation__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Unit_Activation__c;
                CU.Installation__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Installation__c;

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
        String carnetOBDRecId = GlobalUtils.returnRecordTypeId('Carnet_Unit__c', 'Carnet OBD');
        try {
            Carnet_Unit__c newCU = new Carnet_Unit__c();
            newCU.Opportunity__c = this.opportunity.Id;
            newCU.Account_Price_Book__c = this.opportunity.Account_Price_Book__c;
            newCU.Price_Book__c = this.opportunity.Account_Price_Book__r.Price_Book__c;
            newCU.Contract_term__c = CU.Contract_term__c;
            newCU.Number_of_Units__c = CU.Number_of_Units__c;
            newCU.Prepaid__c = CU.Prepaid__c;
            newCU.Monitoring_in_EU__c = CU.Monitoring_in_EU__c;
            newCU.Monitoring_in_EU_Price__c = CU.Monitoring_in_EU_Price__c;
            newCU.Monitoring_in_other_European_countries__c = CU.Monitoring_in_other_European_countries__c;
            newCU.Archiving__c = CU.Archiving__c;
            newCU.Driving_Style__c = CU.Driving_Style__c;
            newCU.Reservations__c = CU.Reservations__c;
            newCU.On_line_position_above_standard__c = CU.On_line_position_above_standard__c;
            newCU.Web_services__c = CU.Web_services__c;
            newCU.Service_Alarm__c = CU.Service_Alarm__c;
            newCU.Driving_Style_Price__c = CU.Driving_Style_Price__c;
            newCU.Reservations_Price__c = CU.Reservations_Price__c;
            newCU.Archiving_Price__c = CU.Archiving_Price__c;
            newCU.On_line_position_above_standard_Price__c = CU.On_line_position_above_standard_Price__c;
            newCU.Web_services_Price__c = CU.Web_services_Price__c;
            newCU.Service_Alarm_Price__c = CU.Service_Alarm_Price__c;
            newCU.Tariff_World_Price__c = CU.Tariff_World_Price__c;
            newCU.Unit_Activation__c = CU.Unit_Activation__c;
            newCU.Installation__c = CU.Installation__c;
            newCU.Standard_Unit_Package__c = CU.Standard_Unit_Package__c;
            newCU.CurrencyIsoCode = 'PLN';
            newCU.RecordTypeId = carnetOBDRecId;
            newCU.Standard_Unit_Package3__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Standard_Unit_Package__c;
            newCU.Standard_Unit_Package_6_15_c__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Standard_Unit_Package_6_15__c;
            newCU.Standard_Unit_Package_16_c__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Standard_Unit_Package_16__c;

            if(newCU.Contract_term__c == '12 months' && newCU.Prepaid__c == false){
                newCU.Carnet_Tariff_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Standard_12__c;
                newCU.Carnet_Tariff_Price_DISCOUNT__c = newCU.Carnet_Tariff_Price__c * CU.Number_of_Units__c;
                newCU.Carnet_Tariff__c = 'Standard 12';
            }
            else if(newCU.Contract_term__c == '12 months' && newCU.Prepaid__c == true){
                newCU.Carnet_Tariff_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Prepaid_12__c;
                newCU.Carnet_Tariff_Price_DISCOUNT__c = newCU.Carnet_Tariff_Price__c * CU.Number_of_Units__c;
                newCU.Carnet_Tariff__c = 'Prepaid 12';
            }
            else if(newCU.Contract_term__c == '24 months' && newCU.Prepaid__c == false){
                newCU.Carnet_Tariff_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Standard_24__c;
                newCU.Carnet_Tariff_Price_DISCOUNT__c = newCU.Carnet_Tariff_Price__c * CU.Number_of_Units__c;
                newCU.Carnet_Tariff__c = 'Standard 24';
            }
            else if(newCU.Contract_term__c == '24 months' && newCU.Prepaid__c == true){
                newCU.Carnet_Tariff_Price__c = this.opportunity.Account_Price_Book__r.Price_Book__r.Prepaid_24__c;
                newCU.Carnet_Tariff_Price_DISCOUNT__c = newCU.Carnet_Tariff_Price__c * CU.Number_of_Units__c;
                newCU.Carnet_Tariff__c = 'Prepaid 24';
            }

            if(CU.Account_Price_Book__c != null){
                insert newCU;

                PageReference pg = new PageReference('/'+ this.opportunityId);
                pg.setRedirect(true);
                return pg;
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Account Price Book on Opportunity.'));
                return null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public class MessageException extends Exception {}

}