public with sharing class LeadConversionCCSctrl {
    public Lead lead {get; set;}
    public String leadId;
    public Boolean isFilled;
    public Boolean isOwnerCurrentUser;

    public LeadConversionCCSctrl() {       
    }


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : select lead with required fields to convert 
    *  CreatedDate     : 11/10/2017
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference init() {
        try {
            this.isFilled = true;
            this.isOwnerCurrentUser = true;
            this.leadId = ApexPages.CurrentPage().getparameters().get('id');
            List<Lead> currentLeadList = [
                SELECT OwnerId, Salutation, FirstName, LastName, CCS_number_of_cards__c, Company, Number_of_Vehicles__c,
                    CCS_Company_ID__c, CCS_Number_of_GPS_units__c, ConvertedOpportunityId, Country, Street, City, PostalCode, CCS_Close_Date__c, Opportunity_Type__c, Produkt__c
                FROM Lead 
                WHERE Id = :this.leadId
                LIMIT 1];
            if (! currentLeadList.isEmpty() ) {
                this.lead = currentLeadList.get(0);
            } else {
                throw new MessageException('Neplatný záznam, zkuste ještě jednou.');
            }
            validateRequiredFields();
            if (this.isFilled && this.isOwnerCurrentUser) {
                convertLead();
                if (this.lead.ConvertedOpportunityId != null) {  
                    return new PageReference('/' + this.lead.ConvertedOpportunityId);           
                } else {
                    return null;
                }
            }
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : validateRequiredFields()
    *  Summary         : validate required to convert fields    
    *  CreatedDate     : 11/10/2017
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateRequiredFields() {
        Map<String, String> requiredFieldsMap = new Map<String, String>{
            'Company' => this.lead.Company, 
            'CCS_Company_ID__c' => this.lead.CCS_Company_ID__c, 
            'Country' => this.lead.Country, 
            'Street' => this.lead.Street, 
            'City' => this.lead.City, 
            'PostalCode' => this.lead.PostalCode,
            'FirstName' => this.lead.FirstName,
            'Number_of_Vehicles__c' => String.valueOf(this.lead.Number_of_Vehicles__c),
            'CCS_Close_Date__c' => String.valueOf(this.lead.CCS_Close_Date__c),
            'Opportunity_Type__c' => this.lead.Opportunity_Type__c,
            'Produkt__c' => this.lead.Produkt__c
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Vyplňte prosím všechna pole povinná pro převedení leadu do příležitosti: ' + requiredFieldLabels));
            this.isFilled = false;
        }
        if (this.lead.CCS_number_of_cards__c == null && this.lead.CCS_Number_of_GPS_units__c == null) {      
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Vyplňte prosím "Počet karet” NEBO “Počet GPS jednotek".'));
            this.isFilled = false;
        }
        if (this.lead.OwnerId != UserInfo.getUserId()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Nejste majitelem tohoto leadu. Převeďte si lead na sebe.'));
            this.isOwnerCurrentUser = false;
        }
    }


    /*******************************************************************************
    *  Name            : convertLead()
    *  Summary         : converts lead if all required fields are filled, assigns tasks 
                         from lead to opportunity  
    *  CreatedDate     : 11/10/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void convertLead() {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(this.lead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        this.lead = [
            SELECT OwnerId, Salutation, FirstName, LastName, CCS_number_of_cards__c, Company, CCS_Company_ID__c,
                CCS_Number_of_GPS_units__c, Country, ConvertedAccountId, ConvertedOpportunityId, Number_of_Vehicles__c
            FROM Lead 
            WHERE Id = :this.leadId];
        Account convertedAccount = [
            SELECT BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode
            FROM Account 
            WHERE Id = :this.lead.ConvertedAccountId];

        convertedAccount.ShippingCountry = convertedAccount.BillingCountry;
        convertedAccount.ShippingStreet = convertedAccount.BillingStreet;
        convertedAccount.ShippingCity = convertedAccount.BillingCity;
        convertedAccount.ShippingState = convertedAccount.BillingState;
        convertedAccount.ShippingPostalCode = convertedAccount.BillingPostalCode;
        update convertedAccount;
    }


    /*******************************************************************************
    *  Name            : continueConvert()
    *  Summary         : update required fields and continue convert  
    *  CreatedDate     : 11/10/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference continueConvert() {
        try {
            update this.lead; 
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        return init();
    }


    /*******************************************************************************
    *  Name            : backToLeadWithSavingFields()
    *  Summary         : back to lead with saving fields values   
    *  CreatedDate     : 11/10/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToLeadWithSavingFields() {
        try {
            update this.lead; 
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        return new PageReference('/' + this.lead.Id);
    }


    /*******************************************************************************
    *  Name            : backToLeadWithoutSavingFields()
    *  Summary         : cancel convertation and back to lead without saving fields values
    *  CreatedDate     : 11/10/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToLeadWithoutSavingFields() {
        return new PageReference('/' + this.lead.Id);
    }


    public class MessageException extends Exception {}
}