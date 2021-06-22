public with sharing class LeadConversionCarnetctrl {
    public Lead lead {get; set;}
    public String leadId;
    public Boolean isFilled;

    public LeadConversionCarnetctrl() {       
    }

    public PageReference init() {
        try {
            this.isFilled = true;
            this.leadId = ApexPages.CurrentPage().getparameters().get('id');
            
            List<Lead> currentLeadList = [
                SELECT OwnerId, CCS_Opportunity_Record_Type__c, Company, Street, City, PostalCode, StateCode, CountryCode, Steuernummer__c, Branche_NACE__c, Beschaeftigte__c, FirstName, LastName, Phone, Email, CCS_Close_Date__c, Opportunity_Type__c, CCS_Number_of_GPS_units__c, Product__c, Account_Status__c, Salutation, Anzahl_der_Fahrzeuge__c, Monatlicher_Kraftstoffverbrauch_in_Liter__c, CCS_number_of_cards__c
                FROM Lead 
                WHERE Id = :this.leadId
                LIMIT 1];
            if (! currentLeadList.isEmpty() ) {
                this.lead = currentLeadList.get(0);
            }
            validateRequiredFields();
            if (this.isFilled) {
                convertLead();
            }
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public void validateRequiredFields() {
        Map<String, String> requiredFieldsMap = new Map<String, String>{
            'Company' => this.lead.Company
        };
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Lead');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        String requiredFieldLabels = '';
        for (String field : requiredFieldsMap.keySet()) {
            if (requiredFieldsMap.get(field) == '' || requiredFieldsMap.get(field) == null) {
                requiredFieldLabels += fieldMap.get(field).getDescribe().getLabel() + ', ';
            }
        }
        requiredFieldLabels = requiredFieldLabels.removeEnd(', ');

        if (requiredFieldLabels != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter all mandatory fields: ' + requiredFieldLabels));
            this.isFilled = false;
        }
    }

    public PageReference convertLead() {
        try {
            update this.lead; 
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        return new PageReference('/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId=' + this.lead.Id + '&id=' + this.lead.Id + '&nooppti=0');
    }


    public PageReference cancel() {
        return new PageReference('/' + this.lead.Id);
    }
    
    public PageReference next() {
        try {
            update this.lead; 
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        if (this.lead.Product__c.contains ('Shell')){
        return new PageReference('/apex/LeadConversion2?id=' + this.lead.Id);
        }
        else {
        return new PageReference('/apex/LeadConversionCarnet2?id=' + this.lead.Id);
        }   
    }

    public class MessageException extends Exception {}
}