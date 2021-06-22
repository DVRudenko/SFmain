public class ChangeOppStageByCreditCtrl {
    public Opportunity currentOpportunity;
    public String emailTemplateName;
    public String pendingSales;
    public User currentUser;
    

    public ChangeOppStageByCreditCtrl() {     
    }


    public PageReference init() {
        try {
            String userId = UserInfo.getUserId();
            String oppId = ApexPages.currentPage().getParameters().get('id');

            currentUser = [
                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :userId];

            currentOpportunity = [
                SELECT Name, OwnerId, StageName, Registered_Country__c, bearbeitet_von__c, RecordType.Name
                FROM Opportunity
                WHERE Id = :oppId
                LIMIT 1];

            pendingSales = ApexPages.currentPage().getParameters().get('pendingSales');     
            validate(); 
            changeOppStageName();
            sendEmail();
            return new PageReference('/' + currentOpportunity.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }   
    }


    /*******************************************************************************
    *  Name            : changeOppStageName()
    *  Summary         : change Opportunity Stage Name    
    *  CreatedDate     : 25/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeOppStageName() {
        String stage;
        if (pendingSales == 'deposit') {
            stage = 'Pending Sales – Deposit';
            currentOpportunity.bearbeitet_von__c = UserInfo.getName();
        } else if (pendingSales == 'information') {
            stage = 'Pending Sales – Information';
            currentOpportunity.bearbeitet_von__c = UserInfo.getName();
        } else if (pendingSales == 'pitcit') {
            stage = 'Pending Sales – PIT/CIT';
        } else if (pendingSales == 'amldoc') {
            stage = 'Pending Sales – AML doc.'; 
        } else if (pendingSales == 'tokpayment') {
            stage = 'Pending Sales - Token payment'; 
        }
        if (currentOpportunity.RecordType.Name == 'Lotos') {
            currentOpportunity.Credit_Stage__c = stage;
        } else {
            currentOpportunity.StageName = stage;
        }
        update currentOpportunity;
        Approval.unlock(currentOpportunity.Id);
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 25/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {
        Map<String, String> countriesMap = new Map<String, String>{
            'Germany' => 'Germany', 
            'Austria' => 'Austria', 
            'Switzerland-DE' => 'Switzerland-DE'};

        if (pendingSales == 'deposit'){
            if (countriesMap.containsKey(currentOpportunity.Registered_Country__c)){
                this.emailTemplateName = 'Deposit_Required_sales_letter_DE';
            } else {
                this.emailTemplateName = 'Deposit_Required_sales_letter_EN';
            }   
        } else if (pendingSales == 'information') {
            if (countriesMap.containsKey(currentOpportunity.Registered_Country__c)){
                this.emailTemplateName = 'Information_Required_sales_letter_DE';
            } else {
                this.emailTemplateName = 'Information_Required_sales_letter_EN';
            }
        } else if (pendingSales == 'pitcit') {
            this.emailTemplateName = 'PitCit_Required_sales_letter_EN';
        } else if (pendingSales == 'amldoc') {
            this.emailTemplateName = 'AmlDoc_Required_sales_letter_EN';
        } else if (pendingSales == 'tokpayment') {
            this.emailTemplateName = 'Token_payment_required_sales_letter';
        }

        List<Messaging.SingleEmailMessage> emails = preporationEmailsForSending( 
            this.currentOpportunity, 
            this.emailTemplateName);

        if (! Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        } 
    }

    /*******************************************************************************
    *  Name            : preporationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 26/01/2017
    *  Parameters      : Opportunity currentOpportunity, String emailTemplateName
    *  Returns         : all emails
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preporationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName) {
        // getting email template id
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate 
            WHERE DeveloperName = :emailTemplateName
            LIMIT 1];

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(emailTemplate.Id); 
        mail.setTargetObjectId(currentOpportunity.OwnerId);
        mail.setSaveAsActivity(false);
        mail.setWhatId(currentOpportunity.Id);
        allmsg.add(mail);

        return allmsg;
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : check current user and Opporunity StageName    
    *  CreatedDate     : 25/01/2017
    *  ModifiedDate    : 03/09/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        if (currentUser.Profile.Name != 'Credit' && currentUser.Profile.Name != 'System Administrator' &&
            currentUser.Profile.Name != 'Systemadministrator' && currentUser.Profile.Name != 'API Only') {
            throw new StageException('Invalid User Profile. <a href="/' + currentOpportunity.Id + '">back to Opportunity</a>');
        }        
        if (currentOpportunity.StageName == 'Closed Won' || currentOpportunity.StageName == 'Closed Lost') {
            throw new StageException('This Opportunity is already closed. <a href="/' + currentOpportunity.Id + '">back to Opportunity</a>');
        }
        if (pendingSales == 'tokpayment' &&
           currentOpportunity.StageName != 'Pending Credit AML' &&
           currentOpportunity.StageName != 'Pending Credit - Token payment' &&
           currentOpportunity.StageName != 'CreditCheck') {
            throw new StageException('This action is available for Pending Credit AML Opportunity Stage only. <a href="/' + currentOpportunity.Id + '">back to Opportunity</a>');
        }
        if ((pendingSales == 'deposit' || pendingSales == 'information') && 
                (currentOpportunity.bearbeitet_von__c == 'Autoprocessed by Sales' || currentOpportunity.bearbeitet_von__c == 'Autoprocessed by E2E')) {
            throw new StageException('Please update the field “Processed by” before returning the Opportunity to the Sales Team.');
        }
    }

    public class StageException extends Exception {}
}