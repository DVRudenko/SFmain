public with sharing class CreateCommercialProposalCarnetController {
    public Opportunity opportunity {get; set;}
    public Contact contact {get; set;}
    public User user {get; set;}
    public String myText{get;set;}
    public String fileId;
    public String opportunityId;
    public String contactId;
    public Boolean isFilled;
    public Boolean isntValid {get;set;}
    Opportunity oppToUpdate;
    Id idProfile =  userinfo.getProfileId();
    Boolean check = false;
    
    String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Carnet_PL_order_confirmation'][0].Id; 
    //public String templateId = '00X0O0000035Wkd';
    String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');


    //Řeší po kliknutí na "preview" Neudělá se refresh (rerender) PDFka, ale stačí, aby se udělal refresh celé stránky... Takže kdyžtak apk pořešit!
    /*
    public void controllerMethod()
    {
        //Aktualizace opportunity
        update opportunity;
        myText = getEmailPreview(opportunity.Id, contact.Id);
        //assign text field values
    }
*/
    public String getEmailPreview(Id oppId, Id conId){
        Messaging.SingleEmailMessage email =
                Messaging.renderStoredEmailTemplate(templateId, conId, oppId);
        return email.htmlBody;
    }

    public String getPlainEmail(Id oppId, Id conId){
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, conId, oppId);
        return email.plainTextBody;
    }

    public void generatePDF(Blob pdf){
        String base64Data = EncodingUtil.base64Encode(pdf);
        ContentVersion file = new ContentVersion();
        file.ContentLocation = 'S';
        file.VersionData = EncodingUtil.base64Decode(base64Data);
        file.Title = 'Carnet_podsumowanie_zamowienia_' + string.valueOf(System.now()) + '.pdf';
        file.PathOnClient = 'Carnet_podsumowanie_zamowienia_' + string.valueOf(System.now()) + '.pdf';
        insert file;

        //uložení fileId do proměnné
        fileId = file.Id;
        system.debug(file.Id);

        String asd = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: file.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = asd;
        cdl.LinkedEntityId = opportunityId;
        cdl.ShareType = 'I';
        insert cdl;
    }
   
     public PageReference init() {
        try {
            this.opportunityId = ApexPages.CurrentPage().getparameters().get('id');
            
            oppToUpdate = [SELECT Account_Price_Book__c, Account_Status_from_Account__c, Form_of_Payment__c, Number_of_GPS_units__c, isClosed, RecordTypeId FROM Opportunity WHERE Id = :this.opportunityId];
            
            AggregateResult[] carnetUnits;
            carnetUnits = [SELECT sum(Number_of_Units__c) sum FROM Carnet_Unit__c WHERE Opportunity__c = :this.opportunityId];
            
            Decimal count = (Decimal) carnetUnits[0].get('sum');
            
            if (oppToUpdate.Account_Price_Book__c == null) {
                    oppToUpdate.addError(Label.carnetMissingAccountPriceBook, false);
                    isntValid = false;
                    return null;
            }

            if (oppToUpdate.RecordTypeId == carnetOppoRecId && oppToUpdate.isClosed == true) {
                List<Profile> profileName = [Select Name from Profile where Id = :idProfile];
                if (!profileName.isEmpty()) {
                    for(Carnet_Profiles_Approval__c field : Carnet_Profiles_Approval__c.getAll().values()) {
                        for(Profile profile : profileName){
                            if (field.Field_Name__c == profile.Name) {
                                check = true;
                            }
                        }
                    }
                }
                if (!check) {
                    oppToUpdate.addError(Label.carnetCreateOrderStop, false);
                    isntValid = false;
                    return null;
                }
            }
            
            
            if (count == null && oppToUpdate.isClosed == false){
                oppToUpdate.Number_of_GPS_units__c = 0;
                update oppToUpdate;
            }
            else if (oppToUpdate.isClosed == false) {
                oppToUpdate.Number_of_GPS_units__c = count;
                update oppToUpdate;
            }
            
            if (oppToUpdate.Account_Status_from_Account__c <> null && (oppToUpdate.Account_Status_from_Account__c == 'Prospect' || oppToUpdate.Account_Status_from_Account__c == 'Former Customer') && oppToUpdate.isClosed == false){
                oppToUpdate.Form_of_Payment__c = 'Advanced payment';
                update oppToUpdate;
            }
            /*else if (oppToUpdate.Account_Status_from_Account__c <> null && oppToUpdate.Account_Status_from_Account__c == 'Customer' && oppToUpdate.isClosed == false){
                oppToUpdate.Form_of_Payment__c = 'Bank Transfer - after delivery';
                update oppToUpdate;
            }*/

            List<OpportunityContactRole> OppContactRoleList = [SELECT ContactID FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityID = :opportunityId];

            if(OppContactRoleList.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to create Primary Contact Role under Opportunity. Please, go back.'));
                isntValid = false;
                return null;
            }
            this.contactId = [SELECT ContactID FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityID = :opportunityId][0].ContactId;

            system.debug(contactId);
            this.contact = [SELECT Name, Email FROM Contact WHERE Id = :contactId LIMIT 1][0];
            myText = getEmailPreview(opportunityId, contact.Id);
            this.isFilled = true;
            List<Opportunity> currentOpportunityList = [SELECT Name,Number_of_GPS_units__c,Number_of_Add_HW__c,Pricing_Approval_Status__c, Form_of_Payment__c, Total_One_time_Payment__c, Account_Status_from_Account__c FROM Opportunity WHERE Id = :this.opportunityId LIMIT 1];
            if (! currentOpportunityList.isEmpty() ) {
                this.opportunity = currentOpportunityList.get(0);
            } else {
                throw new MessageException('Wrong record, try again.');
            }
            
            if(this.opportunity.Form_of_Payment__c == null && this.opportunity.Total_One_time_Payment__c != 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to add Order Payment Method. Please, go back.'));
                isntValid = false;
                return null;
            }
            else if((count == 0 || count == null) && this.opportunity.Number_of_Add_HW__c == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need to create Carnet Unit or Additional Hardware to be able to generate and send PDFs. Please, go back.'));
                isntValid = false;
                return null;
            }
            else if(this.opportunity.Pricing_Approval_Status__c == 'Approval Required' || this.opportunity.Pricing_Approval_Status__c == 'Pending Approval')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Opportunity needs to be Approved, then you can generate and send PDFs. Please, go back.'));
                isntValid = false;
                return null;
            }
            else if(this.opportunity.Pricing_Approval_Status__c == 'Declined')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Opportunity is Declined. Change prices and Ask for Approval again. Please, go back.'));
                isntValid = false;
                return null;
            }
            else if(this.opportunity.Account_Status_from_Account__c == null){
                this.opportunity.addError(System.Label.AccountStatusOpportunityCarnet, false);
                isntValid = false;
                return null;
            }
            
            isntValid = true;
            
            String userName = UserInfo.getUserName();
            user = [Select Name, Email From User where Username = : userName limit 1];

            return null;
        } catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public Blob getBlob(){
        String pagereference = '/apex/OpportunityCreateCommercialCarnetPDF?id='+opportunityId;
        PageReference pageRef = new PageReference(pagereference);
        pageRef.setRedirect(false);
        if(Test.isRunningTest()) {
            return Blob.valueOf('Unit.Test');
        } else {
            return pageRef.getContent();
        }


    }
    public PageReference sendEmail() {

        //Zde se musí nejprve uložit a vygenerovat PDFko
        Blob PDF = getBlob();

        //Volání metody, která vytvoří PDF a uloží ho k souborům
        generatePDF(PDF);

        //Vytvoření a přiložení PDFka k mejlu
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(opportunity.Name + '_' + date.today().format() + '.pdf');
        efa.setBody(PDF);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        //Komu jde!
        List<String> sendTo = new List<String>();
        sendTo.add(contact.Email);
        email.setToAddresses(sendTo);

        //Od koho email jde?
        email.setReplyTo(user.Email);
        email.setSenderDisplayName(user.Name);

        //Lze nastavit bcc
        /*
        String bccAddress = 'emailtosalesforce@'+[SELECT EmailDomainName FROM EmailServicesAddress WHERE IsActive=true AND CreatedById = :user.Id LIMIT 1][0].EmailDomainName;
        List<String> ccTo = new List<String>();
        ccTo.add(bccAddress);
        email.setCcAddresses(ccTo);
        */

        //Přiřazení subject
        email.setSubject('Carnet Order - FLEETCOR');

        email.setPlainTextBody(getPlainEmail(opportunity.Id, contact.Id));
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        email.setTargetObjectId(contact.Id);
        email.setWhatId(opportunity.Id);
        email.setSaveAsActivity(true);
        email.htmlBody = getEmailPreview(opportunityId, contactId);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        return new PageReference('/' + this.opportunity.Id);
    }
    
    public PageReference savePDF() {

        //Zde se musí nejprve uložit a vygenerovat PDFko
        Blob PDF = getBlob();

        //Volání metody, která vytvoří PDF a uloží ho k souborům
        generatePDF(PDF);

        return new PageReference('/' + this.opportunity.Id);
    }
    
    public PageReference cancel() {
        return new PageReference('/' + this.opportunityId);
    }
    
    public class MessageException extends Exception {}
}