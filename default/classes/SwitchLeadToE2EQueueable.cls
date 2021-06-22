global class SwitchLeadToE2EQueueable implements Queueable {
    private String leadId;
    private Boolean isSwitchToE2E;

    global SwitchLeadToE2EQueueable(String leadId, Boolean isSwitchToE2E) {
        this.leadId = leadId;
        this.isSwitchToE2E = isSwitchToE2E;
    }

    /*******************************************************************************
     *  Summary         : Find duplicate lead and automatically switch to e2e
     *  Created         : 13/02/2020 by Artem Voitik
     *  Parameters      : QueueableContext context
     *  Returns         : void
    ******************************************************************************/
    global void execute(QueueableContext context) {
        try {
            Lead lead = [SELECT Salutation, RecordType.Name, Partner_OBN__c, LeadSource, CCS_number_of_cards__c, Status, Contact_Email_Body__c, Country, Company, LastName, FirstName, Phone, Email, (SELECT NewValue FROM Histories LIMIT 100) FROM Lead WHERE Id = :this.leadId LIMIT 1];
            System.debug(lead);

            List<Lead> checkDuplicatesList = [
                    SELECT Id
                    FROM Lead
                    WHERE ((FirstName = :lead.FirstName AND LastName = :lead.LastName AND Email = :lead.Email) OR
                    (FirstName = :lead.FirstName AND LastName = :lead.LastName AND Phone = :lead.Phone) OR
                    (Company = :lead.Company AND Phone = :lead.Phone) OR
                    (Company = :lead.Company AND Email = :lead.Email)) AND
                    Country = :lead.Country AND
                    (Quali_Status__c != 'Auto-detect (E2E)' OR Quali_Status__c != 'Auto-detect') AND
                    Status != 'Disqualified' AND
                    Id != :lead.Id
                    LIMIT 1];
            if ( ! checkDuplicatesList.isEmpty() ) {
                this.isSwitchToE2E = false;
                lead.Status = 'Disqualified';
                lead.Quali_Status__c = 'Auto-detect (E2E)';
                update lead;

                return;
            }

            for (LeadHistory leadhistory : lead.Histories) {
                if (String.valueOf(leadhistory.NewValue) == 'Switched to E2E') {
                    return;
                }
            }

            E2E_Form_General_Settings__c e2eGeneralSettings = E2E_Form_General_Settings__c.getInstance(lead.Country);
            if (e2eGeneralSettings == null) {
                return;
            }
            if (lead.Salutation == null || lead.Salutation == '') {
                lead.Salutation = 'Mr.';
            }
            lead.OwnerId = e2eGeneralSettings.Integration_Admin_Id__c;
            lead.E2E_Short_Link__c = generateShortId(lead.Id, lead.Country);
            lead.Quali_Status__c = 'Switched to E2E';
            lead.E2E_Adoption_Status__c = 'Adoption Email Sent';
            lead.E2E_Adoption_Date__c = Date.today();

            if (lead.Company != null && lead.Company.containsIgnoreCase('[nicht vorhanden]') || lead.Company == null) {
                lead.Company = 'LONGFORM: ' + (lead.FirstName != null ? lead.FirstName + ' ' : '') + lead.LastName;
            }
            update lead;
        } catch (Exception e) {
            ExceptionLogger.sendException('SwitchLeadToE2EQueueable.execute line of the error: ', String.valueOf(e.getStackTraceString()) + ', message: ' + e.getMessage());
        }
    }

    private static String generateShortId(String leadId, String country) {
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
        String finalParam = String.valueOf(leadId);
        String shortid = EncodingUtil.urlEncode(
                EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
                        Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
                        Blob.valueOf(finalParam))), 'UTF-8')
                .replace('%', '').substring(1, 7);
        return shortid;
    }
}