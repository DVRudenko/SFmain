public class SepaDataApprovalController {
    public Opportunity convertOpp {get; set;}
    public String accountHolderName {get; set;}
    public String iban {get; set;}
    public String swift {get; set;}
    public Boolean isApproved;
    public String errorMessage {get; set;}
    public String confirmMessage {get; set;}

    public SepaDataApprovalController() {     
    }


    public void init() {
        String oppId = ApexPages.currentPage().getParameters().get('id');
        this.errorMessage = '';
        if (oppId != null) {
            this.convertOpp = [
                SELECT OwnerId, Owner.Email, Account.Name, Account.BillingCountry, StageName, Name_of_the_payer_Account_holder__c, IBAN__c, SWIFT_BIC__c, Zahlungsart__c
                FROM Opportunity
                WHERE Id = :oppId
                LIMIT 1];

            this.accountHolderName = this.convertOpp.Name_of_the_payer_Account_holder__c;
            this.iban = this.convertOpp.IBAN__c;
            this.swift = this.convertOpp.SWIFT_BIC__c;
        }
    }


    public void doDataApproval() {
        try {
            this.errorMessage = '';
            this.confirmMessage = '';
            if (! validateData()) {
                return;
            }
            doUpdateOpportunity();
            sendEmail();
            this.confirmMessage = isApprovedMessageTranslateMap.get((this.convertOpp.Account != null && 
                    isApprovedMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ? this.convertOpp.Account.BillingCountry : 'Germany');
        } catch (Exception e) {
            this.errorMessage = systemErrorsTranslateMap.get(this.convertOpp.Account.BillingCountry);
            ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.convertOpp.Id, String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Name            : doUpdateOpportunity()
    *  Summary         : update opportunity field    
    *  CreatedDate     : 26/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateOpportunity() {
        Transaction__c sysTransOpportunityUpdate = new Transaction__c (Record_Id__c = this.convertOpp.Id, 
                                                                       Object_API__c = 'Opportunity',
                                                                       DML_type__c = 'update',
                                                                       Processing__c = true);
        insert sysTransOpportunityUpdate;

        List<Transaction_Field__c> fieldsToUpdateList = new List<Transaction_Field__c>();
        Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                              API_Field_Name__c = 'Name_of_the_payer_Account_holder__c',
                                                              Value__c = this.accountHolderName);
        fieldsToUpdateList.add(stf1);

        Transaction_Field__c stf2 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                              API_Field_Name__c = 'IBAN__c',
                                                              Value__c = this.iban);
        fieldsToUpdateList.add(stf2);

        Transaction_Field__c stf3 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                              API_Field_Name__c = 'SWIFT_BIC__c',
                                                              Value__c = this.swift);
        fieldsToUpdateList.add(stf3);

        if (this.convertOpp.StageName == 'Closed Won') {
            Transaction_Field__c stf4 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                                  API_Field_Name__c = 'Starts_Payment_method__c',
                                                                  Value__c = 'Direct debit');
            fieldsToUpdateList.add(stf4);
        } else {
            Transaction_Field__c stf5 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                                  API_Field_Name__c = 'Zahlungsart__c',
                                                                  Value__c = 'Lastschrift');
            fieldsToUpdateList.add(stf5);
        }

        Transaction_Field__c stf6 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                              API_Field_Name__c = 'Einwilligung_Lastschriftverfahren__c',
                                                              Value__c = 'true');
        fieldsToUpdateList.add(stf6);

        Transaction_Field__c stf7 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                              API_Field_Name__c = 'SEPA_Request_Approved__c',
                                                              Value__c = 'true');
        fieldsToUpdateList.add(stf7);

        insert fieldsToUpdateList;
        update sysTransOpportunityUpdate;
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : notification of data approval to the user
    *  CreatedDate     : 27/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {    
        Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>([
            SELECT Id, Subject, HtmlValue, Body, DeveloperName
            FROM EmailTemplate 
            WHERE DeveloperName = 'Notification_of_data_approval_to_sales' OR 
                  DeveloperName = 'SEPA_Approval_Data_notify_Backoffice'
            LIMIT 2
        ]);

        Map<String, Messaging.SingleEmailMessage> messagesMap = new Map<String, Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> allmsgTemp = new List<Messaging.SingleEmailMessage>();
        for (EmailTemplate template : templatesMap.values()) {
            Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage(); 
            mailTemp.setTemplateID(template.Id);
            mailTemp.setTargetObjectId(this.convertOpp.OwnerId);
            mailTemp.setWhatId(this.convertOpp.Id);
            mailTemp.setSaveAsActivity(false);
            mailTemp.setCharset('UTF-8');
            allmsgTemp.add(mailTemp);

            messagesMap.put(template.Id, mailTemp);
        }
        
        Savepoint sp = Database.setSavepoint();
        if ( ! Test.isRunningTest() && ! allmsgTemp.isEmpty()) {
            Messaging.sendEmail(allmsgTemp);
            Database.rollback(sp);
        }

        Map<String, BackOffice_Notifications__c> backOfficeNotifyCustomSettingMap = BackOffice_Notifications__c.getAll();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (String templateId : messagesMap.keySet()) {
            if (templatesMap.get(templateId).DeveloperName == 'Notification_of_data_approval_to_sales' && this.convertOpp.Owner.Email != null) {
                List<String> emailAddressesList = new List<String>{this.convertOpp.Owner.Email};           
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Data is approved');
                mail.setHtmlBody(messagesMap.get(templateId).getHtmlBody());  
                mail.setToAddresses(emailAddressesList);
                mail.setSaveAsActivity(false);
                mail.setCharset('UTF8');
                allmsg.add(mail);
            }

            if (templatesMap.get(templateId).DeveloperName == 'SEPA_Approval_Data_notify_Backoffice' && this.convertOpp.StageName == 'Closed Won') {
                List<String> emailAddressesList = new List<String>();
                if (this.convertOpp.Account.BillingCountry != null && 
                    backOfficeNotifyCustomSettingMap.get(this.convertOpp.Account.BillingCountry) != null &&
                    backOfficeNotifyCustomSettingMap.get(this.convertOpp.Account.BillingCountry).Active__c == true) {
                    emailAddressesList.add(backOfficeNotifyCustomSettingMap.get(this.convertOpp.Account.BillingCountry).Email__c);
                } else if (backOfficeNotifyCustomSettingMap.get('Germany') != null &&
                           backOfficeNotifyCustomSettingMap.get('Germany').Active__c == true) {
                     emailAddressesList.add(backOfficeNotifyCustomSettingMap.get('Germany').Email__c);
                }

                if (! emailAddressesList.isEmpty()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSubject(this.convertOpp.Account.Name + ' approved SEPA form');
                    mail.setHtmlBody(messagesMap.get(templateId).getHtmlBody());  
                    mail.setToAddresses(emailAddressesList);
                    mail.setSaveAsActivity(false);
                    mail.setCharset('UTF8');
                    allmsg.add(mail);
                }
            }    
        }

        if (! Test.isRunningTest() && ! allmsg.isEmpty()) {
            Messaging.sendEmail(allmsg);       
        }   
    }


    /*******************************************************************************
    *  Name            : validateData()
    *  Summary         : validation filling of mandatory fields    
    *  CreatedDate     : 26/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public Boolean validateData() {
        this.isApproved = [SELECT SEPA_Request_Approved__c FROM Opportunity WHERE Id = :this.convertOpp.Id LIMIT 1].SEPA_Request_Approved__c;
        if (this.isApproved == true) {
            this.errorMessage = isApprovedMessageTranslateMap.get((this.convertOpp.Account != null && isApprovedMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ? 
                    this.convertOpp.Account.BillingCountry : 'Germany');
            return false;
        }
        if (this.accountHolderName == null || this.accountHolderName == '') {
            this.errorMessage = accountHolderNameTranslateMap.get((this.convertOpp.Account != null && accountHolderNameTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ? 
                    this.convertOpp.Account.BillingCountry : 'Germany');
            return false;
        }
        if (this.iban == null || this.iban == '') {
            this.errorMessage = ibanMessageTranslateMap.get((this.convertOpp.Account != null && ibanMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ? 
                    this.convertOpp.Account.BillingCountry : 'Germany');
            return false;
        }
        if (this.swift == null || this.swift == '') {
            this.errorMessage = swiftMessageTranslateMap.get((this.convertOpp.Account != null && swiftMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ? 
                    this.convertOpp.Account.BillingCountry : 'Germany');
            return false;
        }
        if ( ! SEPA_Toolkit.SEPAUtilities.ValidateIBAN((String)this.iban)) {
            this.errorMessage = ibanSEPAMessageTranslateMap.get((this.convertOpp.Account != null && ibanSEPAMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ? 
                    this.convertOpp.Account.BillingCountry : 'Germany');
            return false;
        }
        return true;
    }

    private final Map<String, String> isApprovedMessageTranslateMap = new Map<String, String> {
        'Germany' => 'Danke, Ihre Daten wurden erfolgreich übertragen.',
        'Netherlands' => 'Bedankt, uw gegevens zijn succesvol doorgevoerd.',
        'Belgium-NL' => 'Bedankt, uw gegevens zijn succesvol doorgevoerd.',
        'France' => 'Merci, vos données ont été transférées avec succès.',
        'Belgium-FR' => 'Merci, vos données ont été transférées avec succès.'

    };

    private final Map<String, String> accountHolderNameTranslateMap = new Map<String, String> {
        'Germany' => 'Bitte füllen Sie das Feld "Name des Zahlungspflichtigen" aus.',
        'Netherlands' => 'Vul het veld "Naam van de betaler" in.',
        'Belgium-NL' => 'Vul het veld "Naam van de betaler" in.',
        'France' => 'Veuillez remplir le champ "Nom du payeur".',
        'Belgium-FR' => 'Veuillez remplir le champ "Nom du payeur".'
    };

    private final Map<String, String> ibanMessageTranslateMap = new Map<String, String> {
        'Germany' => 'Bitte füllen Sie das Feld "IBAN" aus.',
        'Netherland' => 'Vul het veld "IBAN" in.',
        'Belgium-NL' => 'Vul het veld "IBAN" in.',
        'France' => 'Veuillez compléter le champ "IBAN".',
        'Belgium-FR' => 'Veuillez compléter le champ "IBAN".'
    };

    private final Map<String, String> swiftMessageTranslateMap = new Map<String, String> {
        'Germany' => 'Bitte füllen Sie das Feld "SWIFT BIC" aus.',
        'Netherlands' => 'Vul het veld "SWIFT BIC" in.',
        'Belgium-NL' => 'Vul het veld "SWIFT BIC" in.',
        'France' => 'Veuillez compléter le champ "SWIFT BIC".',
        'Belgium-FR' => 'Veuillez compléter le champ "SWIFT BIC".'
    };

    private final Map<String, String> ibanSEPAMessageTranslateMap = new Map<String, String> {
        'Germany' => 'Die eingegebene IBAN ist nicht korrekt. Bitte überprüfen Sie diese.',
        'Netherlands' => 'De ingevoerde IBAN is niet juist. Controleer dit alsjeblieft.',
        'Belgium-NL' => 'De ingevoerde IBAN is niet juist. Controleer dit alsjeblieft.',
        'France' => 'L\'IBAN entré n\'est pas correct. Veuillez vérifier ceci.',
        'Belgium-FR' => 'L\'IBAN entré n\'est pas correct. Veuillez vérifier ceci.'
    };

    private final Map<String, String> systemErrorsTranslateMap = new Map<String, String> {
        'Germany' => 'Fehler bei der Datenaktualisierung. Bitte kontaktieren Sie Ihren Kundenbetreuer.',
        'Netherlands' => 'Een fout is opgetreden bij het updaten van de gegevens. Neem contact op met uw accountmanager.',
        'Belgium-NL' => 'Een fout is opgetreden bij het updaten van de gegevens. Neem contact op met uw accountmanager.',
        'France' => 'Message erreur s’est produit durant la mise à jour des données. Veuillez contacter votre Account Manager.',
        'Belgium-FR' => 'Message erreur s’est produit durant la mise à jour des données. Veuillez contacter votre Account Manager.'
    };

    public class MessageException extends Exception {}
}