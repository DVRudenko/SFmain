/**
 * Created by ilja.garin on 27.07.2017.
 */
public class LeadConversionRusCtrl {
    public Lead lead {get; set;}
    public String leadId;

/*******************************************************************************
*  Name            : init()
*  Summary         : select lead with required fields to convert
*  CreatedDate     : 31/08/2017
*  Parameters      :
*  Returns         : PageReference
******************************************************************************/
    public PageReference init() {
        Boolean isFilled = true;
        Boolean isOwnerCurrentUser = true;
        this.leadId = ApexPages.currentPage().getparameters().get('id');
        lead = [
                SELECT  INN__c, Phone, Email, Company, OwnerId, FirstName, LastName, ConvertedOpportunityId, ConvertedAccountId
                FROM Lead
                WHERE Id = :this.leadId];
        List<String> requiredFieldsList = new List<String>{ Lead.INN__c, String.ValueOf(Lead.Phone), String.ValueOf(Lead.Email), Lead.Company};

        for (String requiredField : requiredFieldsList) {
            if (! validateRequiredFields(requiredField)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RU_0005_FillAllFields));
                isFilled = false;
                break;
            }
        }

        if (lead.OwnerId != UserInfo.getUserId()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.RU_0006_NotLeadOwner));
            isOwnerCurrentUser = false;
        }

        if (isFilled && isOwnerCurrentUser) {
            convertLead();
            if (lead.ConvertedOpportunityId != null) {
                return new PageReference('/' + lead.ConvertedOpportunityId);
            } else {
                return null;
            }
        } else {
            if (String.valueOf(lead.OwnerId).subString(0, 3) != '005') {
                lead.OwnerId = UserInfo.getUserId();
            }
            return null;
        }
    }

/*******************************************************************************
*  Name            : validateRequiredFields(String field)
*  Summary         : validate required to convert fields
*  CreatedDate     : 31/08/2017
*  Parameters      :
*  Returns         : Boolean
******************************************************************************/
    public Boolean validateRequiredFields(String field) {
        if (field != null && field != '') {
            return true;
        } else {
            return false;
        }
    }

/*******************************************************************************
*  Name            : convertLead()
*  Summary         : converts lead if all required fields are filled, assigns tasks
                    from lead to opportunity
*  CreatedDate     : 31/08/2017
*  Parameters      :
*  Returns         : void
******************************************************************************/
    public void convertLead() {
        try {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.id);

            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel LIKE 'QUALIFIED%' LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);

            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            lead = [
                    SELECT  INN__c, Phone, Email, Company, ConvertedOpportunityId, ConvertedAccountId, FirstName, LastName
                    FROM Lead
                    WHERE Id = :this.leadId];
            /*Opportunity recordType = [SELECT Id, RecordType.Name, RecordType.Id FROM Opportunity WHERE RecordType.Name = 'Russian Sales' LIMIT 1];
            Opportunity convertedOpportunity = [SELECT Id, RecordType.Id, RecordType.Name FROM Opportunity WHERE Id = :Lead.ConvertedOpportunityId];
            convertedOpportunity.RecordType.Id = recordType.RecordType.Id;
            convertedOpportunity.RecordType.Name = recordType.RecordType.Name;
            update convertedOpportunity;*/
            Account convertedAccount = [
                    SELECT BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode
                    FROM Account
                    WHERE Id = :lead.ConvertedAccountId];
            convertedAccount.ShippingCountry = convertedAccount.BillingCountry;
            convertedAccount.ShippingStreet = convertedAccount.BillingStreet;
            convertedAccount.ShippingCity = convertedAccount.BillingCity;
            convertedAccount.ShippingState = convertedAccount.BillingState;
            convertedAccount.ShippingPostalCode = convertedAccount.BillingPostalCode;
            update convertedAccount;
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
        }
    }

    /*******************************************************************************
    *  Name            : continueConvert()
    *  Summary         : update required fields and continue convert
    *  CreatedDate     : 31/08/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference continueConvert() {
        try {
            update lead;
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        return init();
    }


    /*******************************************************************************
    *  Name            : backToLeadWithSavingFields()
    *  Summary         : back to lead with saving fields values
    *  CreatedDate     : 31/08/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToLeadWithSavingFields() {
        try {
            update lead;
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        return new PageReference('/' + lead.Id);
    }

    /*******************************************************************************
    *  Name            : backToLeadWithoutSavingFields()
    *  Summary         : cancel convertation and back to lead without saving fields values
    *  CreatedDate     : 31/08/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToLeadWithoutSavingFields() {
        return new PageReference('/' + lead.Id);
    }
}