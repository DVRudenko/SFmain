public without sharing class ExceptionLogger {
    @TestVisible static Messaging.SingleEmailMessage mail;


    /*******************************************************************************
    *  Name            : sendException(String stackTraceString)
    *  Summary         : send Email with Exception to addresses from custom setting
    *  CreatedDate     : 18/03/2017
    *  Parameters      : String exceptionDescription - description of exception we need to send,
                        String stackTraceString - place where exception has occured
    *  Returns         : void
    ******************************************************************************/
    public static void sendException(String exceptionDescription, String stackTraceString) {
        Map<String,  Logger_Recipient__c> recipientsEmailsMap = Logger_Recipient__c.getAll();
        List<String> idsToAddresses = new List<String>();
        for (String id : recipientsEmailsMap.keySet()) {
            if (recipientsEmailsMap.get(id).Active__c == true) {
                idsToAddresses.add(id);
            }
        }

        List<Messaging.Email> mailsList = new List<Messaging.Email>();
        for (String id : idsToAddresses) {
            mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(id);
            mail.setSenderDisplayName('SFDC');
            mail.setSubject('Exception Logger '+String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()).substringAfter('//'));
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            String body;
            if (! stackTraceString.startsWith('()')) {
                body = 'Exception in ' + stackTraceString + '\n' + exceptionDescription;
            }
            else {
                body = exceptionDescription;
            }
            
            mail.setHtmlBody(body);
            mailsList.add(mail);
        }
        Messaging.sendEmail(mailsList);
    }
}
