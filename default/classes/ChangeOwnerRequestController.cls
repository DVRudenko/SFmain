public class ChangeOwnerRequestController {
    
    public ChangeOwnerRequestController() {}


    public void init() {
        try {
            String requestResult = ApexPages.CurrentPage().getparameters().get('d');
            String newOwnerId = ApexPages.CurrentPage().getparameters().get('newOwnerId');
            String id = ApexPages.CurrentPage().getparameters().get('id');
            if (id == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid account. Please contact your administrator.'));
                return;
            }
            if (newOwnerId == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid Owner Id. Please contact your administrator.'));
                return;
            }
            List<Account> account = [
                    SELECT Name, Active_Change_Owner_Request__c
                    FROM Account
                    WHERE Id = :id];
            if (account.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid account. Please contact your administrator.'));
                return;
            }  
            if ( ! account.get(0).Active_Change_Owner_Request__c ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No active requests.'));
                return;
            }
            if (requestResult == '1') {          
                List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSenderDisplayName('Change owner request has been approved');
                email.saveAsActivity = false;
                String emailBody = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' has approved your request to take ownership of the account: <a href="' + 
                                   URL.getSalesforceBaseUrl().toExternalForm() + '/' + 
                                   account.get(0).Id + '">' + account.get(0).Name + '</a>, all related contacts and open opportunities.';
                email.setHtmlBody(emailBody);
                email.setTargetObjectId(newOwnerId);
                email.setSubject('Change owner request has been approved');
                emailsList.add(email);
                Messaging.sendEmail(emailsList);
                
                account.get(0).OwnerId = newOwnerId;
                account.get(0).Active_Change_Owner_Request__c = false;
                update account;

                SendChangeOwnerRequestController.updateRelatedRecords(account.get(0).Id, newOwnerId);

                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Request has been approved.'));
            } else {
                List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSenderDisplayName('Change owner request has been declined');
                email.saveAsActivity = false;
                String emailBody = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' has declined your request to take ownership of the account: <a href="' + 
                                   URL.getSalesforceBaseUrl().toExternalForm() + '/' + 
                                   account.get(0).Id + '">' + account.get(0).Name + '</a>, all related contacts and open opportunities.';
                email.setHtmlBody(emailBody);
                email.setTargetObjectId(newOwnerId);
                email.setSubject('Change owner request has been declined');
                emailsList.add(email);
                Messaging.sendEmail(emailsList);

                account.get(0).Active_Change_Owner_Request__c = false;
                update account;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Request has been declined.'));
            }   
        } catch (Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }
}