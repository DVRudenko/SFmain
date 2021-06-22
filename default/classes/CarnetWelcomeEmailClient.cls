public class CarnetWelcomeEmailClient {
    
    //public static String templateId = '00X1q000000MYw9';
    
    public static String getPlainEmail(Id oppId, Id conId){
    
    String Product = [SELECT Product__c FROM Opportunity WHERE Id = :oppId][0].Product__c;
    
        if(Product == 'Carnet OBD'){
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Carnet_OBD_PL_welcome_email_VF'][0].Id; 
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, conId, oppId);
            return email.plainTextBody;
        }
        else{
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Carnet_PL_welcome_email_VF'][0].Id; 
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, conId, oppId);
            return email.plainTextBody;
        }
    }
    
    public static String getEmailPreview(Id oppId, Id conId){
    
    String Product = [SELECT Product__c FROM Opportunity WHERE Id = :oppId][0].Product__c;
    
        if(Product == 'Carnet OBD'){
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Carnet_OBD_PL_welcome_email_VF'][0].Id; 
                Messaging.SingleEmailMessage email =
                Messaging.renderStoredEmailTemplate(templateId, conId, oppId);
                return email.htmlBody;
        }
        else{
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Carnet_PL_welcome_email_VF'][0].Id; 
            Messaging.SingleEmailMessage email =
                Messaging.renderStoredEmailTemplate(templateId, conId, oppId);
            return email.htmlBody;
        }
    }
    
    public void sendcwEC(List<id> listOfOpportunities){
        CarnetWelcomeEmailClient.sendEmailWithAttachment(listOfOpportunities);
    }
    
    @InvocableMethod(label='Carnet PL Welcome Email - Client')
    public static void sendEmailWithAttachment(List<id> listOfOpportunities)
    {
        String owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'][0].Id;
        String contId = [SELECT ContactID FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityID IN :listOfOpportunities][0].ContactId;
        String Product = [SELECT Product__c FROM Opportunity WHERE Id IN :listOfOpportunities][0].Product__c;
        String opportunityOwner = [SELECT Owner.Email FROM Opportunity WHERE Id IN :listOfOpportunities][0].Owner.Email;

        List<ContentDocument> cdobd = [SELECT Id, FileType, Title, FileExtension FROM ContentDocument WHERE Title = 'FLEETCOR_Carnet_OBD_Warunki_PL'];
        List<ContentVersion> cvobd = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId IN :cdobd];

        List<ContentDocument> cd85 = [SELECT Id, FileType, Title, FileExtension FROM ContentDocument WHERE Title = 'FLEETCOR_Carnet_85_Warunki_PL'];
        List<ContentVersion> cv85 = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId IN :cd85];

        for(Id opportunityId :listOfOpportunities)
           {
               PageReference pref= page.CreateCommercialProposalCarnet;
               pref.getParameters().put('id',(Id)opportunityId);
               pref.setRedirect(true);
               List<String> BccTo = new List<String>();
               BccTo.add(opportunityOwner);

               List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
               if(Product == 'Carnet OBD') {
                   for (ContentDocument docs: cdobd) {
                       for (ContentVersion docVersion: cvobd) {

                           Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();

                           efa.setFileName(docs.Title);
                           efa.setBody(docVersion.VersionData);
                           efa.setContentType('application/pdf');
                           fileAttachments.add(efa);
                       }
                   }
               }
               else{
                   for (ContentDocument docs: cd85) {
                       for (ContentVersion docVersion: cv85) {

                           Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();

                           efa.setFileName(docs.Title);
                           efa.setBody(docVersion.VersionData);
                           efa.setContentType('application/pdf');
                           fileAttachments.add(efa);
                       }
                   }
               }
               
               Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
               email.setSubject('FleetCor Poland - MONITORING POJAZDÓW');
               email.setTargetObjectId(contId);
               email.setOrgWideEmailAddressId(owea);
               email.setReplyTo(opportunityOwner);
               email.setBccAddresses(BccTo);
               email.setWhatId(opportunityId);
               email.setSaveAsActivity(true);
               email.setPlainTextBody(getPlainEmail(opportunityId, contId));
               email.htmlBody = getEmailPreview(opportunityId, contId);
               email.setFileAttachments(fileAttachments);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
           }
    }
}