public class CarnetWelcomeEmailBO {
    public static String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'New_Order'][0].Id;
    //public static String templateId = '00X1q000000MboS';
    
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
    
    public void sendcwBO(List<id> listOfOpportunities){
        CarnetWelcomeEmailBO.sendEmailWithAttachment(listOfOpportunities);
    }
    
    @InvocableMethod(label='Carnet PL Welcome Email - BO')
    public static void sendEmailWithAttachment(List<id> listOfOpportunities)
    {
        Set<Id> cdlId = new Set<Id>();

        String owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'][0].Id;
        String userId = [SELECT OwnerId FROM Opportunity WHERE Id IN :listOfOpportunities][0].OwnerId;

        List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :listOfOpportunities];

        for (ContentDocumentLink docLinks: cdl) {
            cdlId.add(docLinks.ContentDocumentId);
        }

        List<ContentDocument> cd = [SELECT Id, FileType, Title, FileExtension FROM ContentDocument WHERE Id IN :cdlId AND Title LIKE 'Carnet_podsumowanie_zamowienia%'];
        List<ContentVersion> cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId IN :cdlId AND IsLatest = true];

           for(Id opportunityId :listOfOpportunities)
           {
               PageReference pref= page.CreateCommercialProposalCarnet;
               pref.getParameters().put('id',(Id)opportunityId);
               pref.setRedirect(true);
               
               List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                for (ContentDocumentLink docLinks: cdl) {
                   for (ContentDocument docs: cd) {
                       for (ContentVersion docVersion : cv) {
            
                           Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();

                           efa.setFileName(docs.Title);
                           efa.setBody(docVersion.VersionData);
                           fileAttachments.add(efa);
                       }
                   }
                }
                
               Carnet_BO_Emails__c BOe = Carnet_BO_Emails__c.getValues('Poland');
               String toAddress = BOe.Email__c;
               
               Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
               Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
               email.setOrgWideEmailAddressId(owea);
               email.setSubject(getSubject(opportunityId, userId));
               email.setToAddresses(new String[]{toAddress});
               email.setWhatId(opportunityId);
               email.setSaveAsActivity(true);
               email.setFileAttachments(fileAttachments);
               email.setPlainTextBody(getPlainEmail(opportunityId, userId));
               email.htmlBody = getEmailPreview(opportunityId, userId);
               email.setFileAttachments(fileAttachments);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
           }
    }
}