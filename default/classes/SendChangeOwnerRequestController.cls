public class SendChangeOwnerRequestController {
    public SendChangeOwnerRequestController() {}


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : send link to approval page to account owner's manager and redirect to account
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : 17/06/2021
    *  Parameters      : 
    *  Returns         : PageReference – return to account
    ******************************************************************************/
    public void init() {
        try {
            String accountId = ApexPages.CurrentPage().getparameters().get('id');
            if (accountId == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid account id. Please try again.'));
                return;
            }
            List<Account> accountToUpdate = [
                    SELECT Name, Active_Change_Owner_Request__c, OwnerId, Owner.IsActive, Owner.Name
                    FROM Account 
                    WHERE Id = :accountId];
            if (accountToUpdate.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid account. Please contact your administrator.'));
                return;
            } 
            if (accountToUpdate.get(0).Active_Change_Owner_Request__c && accountToUpdate.get(0).Owner.IsActive == true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Request was already sent.'));
                return;
            }
            List<Profile> profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
            if (profile.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid profile.'));
            return;
            } else if ( ! profile.get(0).Name.equals('CCS KAM') &&  ! profile.get(0).Name.equals('CCS LAM')
                        && ! profile.get(0).Name.equals('CCS SME') && ! profile.get(0).Name.equals('Altevida CCS Telesales')
                        && ! profile.get(0).Name.equals('Sales Inbound') && ! profile.get(0).Name.equals('TR Callcenter')
                        && ! profile.get(0).Name.equals('System Administrator') && ! profile.get(0).Name.equals('CCS System Administrator')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Your profile is not allowed to use this button. Please contact your SFDC Administrator.'));
                return;
            }

            if (accountToUpdate.get(0).Owner.IsActive == false) {
                accountToUpdate.get(0).OwnerId = UserInfo.getUserId();
                accountToUpdate.get(0).Active_Change_Owner_Request__c = false;
                update accountToUpdate;

                updateRelatedRecords(accountToUpdate.get(0).Id, UserInfo.getUserId());

                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Request has been approved. <a href="/' + accountId +'">Back to account</a>.'));
            } else {
                if (accountToUpdate.get(0).Owner.Name == 'Integration Administrator' || accountToUpdate.get(0).Owner.Name == 'E2E Site Guest User') {
                    List<User> user = [SELECT ManagerId, Manager.IsActive, Manager.DelegatedApproverId FROM User WHERE Id = :UserInfo.getUserId()];
                    // if Manager isEmpty or inActive - send Email to sales.operations@fleetcor.eu
                    if (user.get(0).ManagerId == null || (String) user.get(0).ManagerId == '' || user.get(0).Manager.IsActive == false) {
                        sendEmail('sales.operations@fleetcor.eu', null, accountToUpdate);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The approval process for change Account Owner has been generated. Please wait for approval <a href="/' + accountId + '">Back to account</a>.'));
                    } else {
                        List<User> delegatedUser;
                        if (user.get(0).Manager.DelegatedApproverId != null && (String) user.get(0).Manager.DelegatedApproverId != '') {
                            delegatedUser = [SELECT Id, Email, IsActive FROM User WHERE Id = :user.get(0).Manager.DelegatedApproverId];
                        }
                        // if Manager isActive and Manager's delegated approver isEmpty or inActive - send Email to user's Manager only
                        if (delegatedUser == null || delegatedUser.get(0).Id == null || (String) delegatedUser.get(0).Id == '' || delegatedUser.get(0).IsActive == false) {
                            sendEmail(user.get(0).ManagerId, null, accountToUpdate);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The approval process for change Account Owner has been generated. Please wait for approval <a href="/' + accountId + '">Back to account</a>.'));
                        } else {
                            // if Manager isActive and Manager's delegated approver isActive - send Email to user's Manager and to Manager's delegated approver
                            sendEmail(user.get(0).ManagerId, delegatedUser.get(0).Email, accountToUpdate);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The approval process for change Account Owner has been generated. Please wait for approval <a href="/' + accountId + '">Back to account</a>.'));
                        }
                    }
                } else {
                    // if Account owner not Integration Administrator or E2E Site Guest User - send email to account's owner
                    sendEmail(accountToUpdate.get(0).OwnerId, null, accountToUpdate);
                    System.debug('Account owner not Integration Administrator or E2E Site Guest User - send email to account\'s owner');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The approval process for change Account Owner has been generated. Please wait for approval <a href="/' + accountId + '">Back to account</a>.'));
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please contact your administrator. ' + e.getMessage()));
        }
    }

    public static void sendEmail(String targetObject, String cc, List<Account> accountToUpdate) {
        String accountId = accountToUpdate.get(0).Id;

        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSenderDisplayName('Change Owner Request');
        email.saveAsActivity = false;
        String emailBody = '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + UserInfo.getUserId() + '">' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() +'</a>'
                + ' has requested to take ownership of the account: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + accountId + '">' + accountToUpdate.get(0).Name + '</a>.<br/><br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/changeownerrequest?id=' + accountId + '&d=1&newOwnerId=' + UserInfo.getUserId() + '">Approve</a><br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/changeownerrequest?id=' + accountId + '&d=0&newOwnerId=' + UserInfo.getUserId() + '">Reject</a>';
        email.setHtmlBody(emailBody);
        if (targetObject.toLowerCase().equals('sales.operations@fleetcor.eu')) {
            List<String> toAddresses = new List<String> {targetObject.toLowerCase()};
            email.setToAddresses(toAddresses);
        } else if (cc != null) {
            List<String> ccAddresses = new List<String> {cc.toLowerCase()};
            email.setTargetObjectId((Id)targetObject);
            email.setCcAddresses(ccAddresses);
        } else {
            email.setTargetObjectId((Id)targetObject);
        }
        email.setSubject('Change Owner Request');
        emailsList.add(email);
        Messaging.sendEmail(emailsList);
        accountToUpdate.get(0).Active_Change_Owner_Request__c = true;
        update accountToUpdate;
    }

    public static void updateRelatedRecords(String accountId, String newOwnerId){
        List<Contact> contactsList = [
                SELECT Id
                FROM Contact
                WHERE AccountId = :accountId
                LIMIT 1000];
        if ( ! contactsList.isEmpty() ) {
            for (Contact contact : contactsList) {
                contact.OwnerId = newOwnerId;
            }
            update contactsList;
        }

        List<Opportunity> opportunitiesList = [
                SELECT Id
                FROM Opportunity
                WHERE AccountId = :accountId AND
                StageName != 'Closed Won' AND
                StageName != 'Closed Lost'
                LIMIT 1000];
        if ( ! opportunitiesList.isEmpty() ) {
            for (Opportunity opp  : opportunitiesList) {
                opp.OwnerId = newOwnerId;
            }
            update opportunitiesList;
        }
    }
}