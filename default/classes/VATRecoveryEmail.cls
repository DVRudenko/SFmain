public class VATRecoveryEmail {
    public static String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'VAT_Recovery_activation'][0].Id;
    
    public static String getPlainEmail(Id oppId, Id userId){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, userId, oppId);
        return email.plainTextBody;
    }
    
    public static String getEmailPreview(Id oppId, Id userId){
        Messaging.SingleEmailMessage email =
                Messaging.renderStoredEmailTemplate(templateId, userId, oppId);
        return email.htmlBody;
    }
    
    public static String getSubject(Id oppId, Id userId){
        String subject =
                Messaging.renderStoredEmailTemplate(templateId, userId, oppId).getSubject();
        return subject;
    }
    
    public void sendVAT(List<id> listOfOpportunities){
        VATRecoveryEmail.sendEmail(listOfOpportunities);
    }
    
    @InvocableMethod(label='VAT Recovery')
    public static void sendEmail(List<id> listOfOpportunities)
    {
           for(Id opportunityId :listOfOpportunities)
           {
               String userId = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC'][0].Id;
               String owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'][0].Id;
               String rc = [SELECT Registered_Country__c FROM Opportunity WHERE Id = :opportunityId][0].Registered_Country__c;
               
               Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
               
               if(rc == 'Austria'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Austria');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Poland'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Poland');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Germany'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Germany');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Netherlands'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Netherlands');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Belgium-NL'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Belgium-NL');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Belgium-FR'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Belgium-FR');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'France'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('France');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Luxembourg'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Luxembourg');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Hungary'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Hungary');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Czech Republic'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Czech Republic');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               else if(rc == 'Slovakia'){
               VAT_Recovery_Emails__c mc = VAT_Recovery_Emails__c.getValues('Slovakia');
               String toAddress = mc.Email__c;
               email.setToAddresses(new String[]{toAddress});
               }
               
               email.setOrgWideEmailAddressId(owea);
               
               email.setSubject(getSubject(opportunityId, userId));
               email.setWhatId(opportunityId);

               email.setPlainTextBody(getPlainEmail(opportunityId, userId));
               email.htmlBody = getEmailPreview(opportunityId, userId);
               
               email.setSaveAsActivity(false);
               
               Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
           }
    }
}