public class ConvertToE2ECtrl {
    public ConvertToE2ECtrl() {}

    public PageReference init() {
    	try {
    	    String oppId = ApexPages.currentPage().getParameters().get('Id');

    	    List<Opportunity> opportunity = [
	                SELECT Id, OwnerId, Owner.Name, E2E_Assistant__c, StageName, LeadSource, E2E_Encoded_URL__c, E2E_Active_Step__c, CloseDate, 
                            E2E_CF_Reports_Counter__c, Gruende_verloren__c, E2E_Sub_Status__c, Sec_Channel__c, Channel__c, Product__c, E2E__c,
	                		(SELECT Contact.Email, Contact.Name, ContactId FROM OpportunityContactRoles WHERE IsPrimary = true),
                            (SELECT AccountTo.Id, AccountTo.OBN__c, AccountTo.BillingStreet, AccountTo.BillingCity, AccountTo.BillingCountry, AccountTo.Name_des_Mitarbeiters__c FROM Partners
                            WHERE AccountTo.OBN__c != NULL AND AccountTo.BillingStreet != null AND AccountTo.BillingCity != NULL AND AccountTo.BillingCountry != NULL LIMIT 1)
	                FROM Opportunity
	                WHERE Id = :oppId
	                LIMIT 1];

            Integer daysOfCloseDate = (Date.valueOf(opportunity.get(0).CloseDate)).daysBetween(Date.today());

            validate(opportunity, daysOfCloseDate);
            convertToE2E(opportunity);

            return new PageReference('/' + opportunity.get(0).Id);
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
    	}
    }


    /*******************************************************************************
    *  Name            : validate(List<Opportunity> opportunity, Integer daysOfCloseDate)
    *  Summary         : Validate opportunity  
    *  CreatedDate     : 16/07/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> opportunity, Integer daysOfCloseDate
    *  Returns         : void
    ******************************************************************************/
    public void validate(List<Opportunity> opportunity, Integer daysOfCloseDate) {
        if (opportunity.get(0).OwnerId != UserInfo.getUserId()) {
            throw new OpportunityException('You can\'t convert this opportunity to E2E because you aren\'t the owner of the record. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
    	if (opportunity.get(0).StageName != 'Prospecting' && opportunity.get(0).StageName != 'CreditCheck abgelehnt' && opportunity.get(0).StageName != 'Closed Lost') {
            throw new OpportunityException('This action is available for Prospecting, Credit Check Rejected or Closed Lost Opportunity Stage only. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
        if (((opportunity.get(0).StageName == 'CreditCheck abgelehnt') || (opportunity.get(0).StageName == 'Closed Lost' && opportunity.get(0).Gruende_verloren__c == 'Refused Credit')) && daysOfCloseDate < 90) {
            throw new OpportunityException('You can\'t convert this opportunity to E2E because difference between close date and today is less than 90 days. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
        if (opportunity.get(0).OpportunityContactRoles.isEmpty()) {
        	throw new OpportunityException('Contact role is empty or is not primary. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
        if (opportunity.get(0).OpportunityContactRoles.get(0).Contact.Email == null) {
        	throw new OpportunityException('Email is empty. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
        if (opportunity.get(0).E2E__c) {
            throw new OpportunityException('Opportunity is already E2E. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
        if (opportunity.get(0).Sec_Channel__c != 'Inbound' && opportunity.get(0).Sec_Channel__c != 'JITB') {
            throw new OpportunityException('This action is available for Inbound or JITB Sec. Channels. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
        if (opportunity.get(0).Sec_Channel__c == 'JITB' && opportunity.get(0).Channel__c != 'Fax') {
            throw new OpportunityException('This action is available for JITB Sec. Channels with Fax channel. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');
        }
        if (opportunity.get(0).Partners.isEmpty() && opportunity.get(0).Sec_Channel__c == 'JITB' && opportunity.get(0).Channel__c == 'Fax') {
            throw new OpportunityException('Please add partner account with address to the Opportunity. <a href="/' + opportunity.get(0).Id + '">back to Opportunity</a>');    
        }
    }


    /*******************************************************************************
    *  Name            : convertToE2E(List<Opportunity> opportunity)
    *  Summary         : Convert opportunity to e2e    
    *  CreatedDate     : 16/07/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> opportunity
    *  Returns         : void
    ******************************************************************************/
    public void convertToE2E(List<Opportunity> opportunity) {
        if (opportunity.get(0).Sec_Channel__c == 'JITB' && opportunity.get(0).Channel__c == 'Fax') {
            opportunity.get(0).Home_Station__c = opportunity.get(0).Partners.get(0).AccountTo.BillingStreet + ', ' +
                                                 opportunity.get(0).Partners.get(0).AccountTo.BillingCity + ', ' +
                                                 opportunity.get(0).Partners.get(0).AccountTo.BillingCountry;
            opportunity.get(0).ESI__c = opportunity.get(0).Partners.get(0).AccountTo.OBN__c;
            opportunity.get(0).Retailer_OBN__c = opportunity.get(0).Partners.get(0).AccountTo.OBN__c;
            opportunity.get(0).Retailer_Name__c = opportunity.get(0).Partners.get(0).AccountTo.Id;
            opportunity.get(0).Retailer_Employee__c = opportunity.get(0).Partners.get(0).AccountTo.Name_des_Mitarbeiters__c;
            opportunity.get(0).E2E_Short_Link__c = generateShortId(opportunity.get(0).ESI__c, opportunity.get(0).Id);
        }
        opportunity.get(0).E2E_Assistant__c = opportunity.get(0).Owner.Name;
    	opportunity.get(0).E2E__c = true;
    	opportunity.get(0).E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity.get(0), 'E2EForm');
    	opportunity.get(0).E2E_Status__c = 'In progress';
    	opportunity.get(0).E2E_Sales_Type__c = 'Manual upgraded to E2E';
        opportunity.get(0).E2E_Sub_Status__c = '';
    	opportunity.get(0).E2E_Active_Step__c = 0;
        opportunity.get(0).E2E_CF_Reports_Counter__c = 0;

    	update opportunity.get(0);
    }

    private static String generateShortId(String obnNumber, Id oppId) {
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance('Germany');
        String finalParam;
        if (obnNumber != null) {
            finalParam = String.valueOf(obnNumber + oppId);
        } else {
            finalParam = String.valueOf(oppId);
        }
        String shortid = EncodingUtil.urlEncode(
                EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
                        Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
                        Blob.valueOf(finalParam))), 'UTF-8')
                .replace('%', '').substring(1, 7);
        return shortid;
    }

    public class OpportunityException extends Exception {}
}