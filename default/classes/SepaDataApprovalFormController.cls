public class SepaDataApprovalFormController {
    public Opportunity convertOpp {get; set;}
    public String accountHolderName {get; set;}
    public String iban {get; set;}
    public String swift {get; set;}
    public Boolean isApproved {get; set;}
    public String errorMessage {get; set;}
    public Map<String, LongFormPage> stepPagesMap {get; set;}
    public String sepaDownloadURL {get; set;}
    public String country {get; set;}
    public Boolean isIBANValid {get; set;}
    public String oppId {get; set;}

    public SepaDataApprovalFormController() {
    }


    public void init() {
        this.oppId = ApexPages.currentPage().getParameters().get('id');
        this.errorMessage = '';
        this.isApproved = false;
        if (oppId == null) return;

        selectOpportunity();

        returnstepPagesMap('Desktop', this.convertOpp.Account.BillingCountry);
        if (this.convertOpp.SEPA_Request_Approved__c) {
            this.isApproved = true;
            return;
        }
        this.country = this.convertOpp.Account.BillingCountry;
        this.accountHolderName = this.convertOpp.Name_of_the_payer_Account_holder__c;
        this.iban = this.convertOpp.IBAN__c;
        this.swift = this.convertOpp.SWIFT_BIC__c;
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT SEPA').elementItemsMap.get('VALUE').value = String.valueOf(this.convertOpp.SEPA_Request_Approved__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').value = String.valueOf(this.convertOpp.AGB_Datenschutzhinweise_Richtigkeit__c);

        if (! this.convertOpp.OpportunityContactRoles.isEmpty()) {
            if (this.accountHolderName == null) {
                this.accountHolderName = this.convertOpp.OpportunityContactRoles.get(0).Contact.FirstName + ' ' + this.convertOpp.OpportunityContactRoles.get(0).Contact.LastName;
            }
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
            this.stepPagesMap.get('PAYMENT OPTIONS').elements.get('DD SEPA').get('IFRAME URL').value = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(this.convertOpp.Id) + '&' +
                            'dynamicAccHolder=' + this.convertOpp.OpportunityContactRoles.get(0).Contact.FirstName + ' ' + this.convertOpp.OpportunityContactRoles.get(0).Contact.LastName + '&');

            this.sepaDownloadURL = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(this.convertOpp.Id) +'&pdfDownload=TRUE&');
        }
    }

    public void doDataApproval() {
        try {
            this.errorMessage = '';
            if (! validateData()) return;
            attachSepaPdf(this.convertOpp.Id, this.accountHolderName, this.iban, this.swift);
            saveData();
            sendEmail();
            this.isApproved = true;
        } catch (Exception e) {
            this.errorMessage = systemErrorsTranslateMap.get(this.convertOpp.Account.BillingCountry);
            ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.convertOpp.Id, String.valueOf(e.getStackTraceString()));
        }
    }

    public void updateSepaDownloadURL(){
        if (E2EKeysAPI__c.getValues('E2EForm') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
            this.sepaDownloadURL = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(convertOpp.Id) + '&pdfDownload=TRUE&' +
                            'dynamicAccHolder=' +   this.accountHolderName  + '&' +
                            'dynamicIBAN=' +   this.iban  + '&' +
                            'dynamicSWIFT=' +    this.swift  );
        }
    }


    /*******************************************************************************
    *  Name            : saveData()
    *  Summary         : save data
    *  CreatedDate     : 06/02/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveData() {
        selectOpportunity();
        this.convertOpp.Name_of_the_payer_Account_holder__c = this.accountHolderName;
        this.convertOpp.IBAN__c = this.iban;
        this.convertOpp.SWIFT_BIC__c = this.swift;
        this.convertOpp.Send_SEPA_approval_link__c = true;
        this.convertOpp.SEPA_Request_Approved__c = Boolean.valueOf(this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT SEPA').elementItemsMap.get('VALUE').value);
        this.convertOpp.Einwilligung_Lastschriftverfahren__c = true;
        this.convertOpp.SEPA_Request_Approval_Date__c = Datetime.now();
        this.convertOpp.AGB_Datenschutzhinweise_Richtigkeit__c = Boolean.valueOf(this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').value);
        if (this.convertOpp.StageName == 'Closed Won') {
            this.convertOpp.Starts_Payment_method__c = 'Direct debit';
        } else {
            this.convertOpp.Zahlungsart__c = 'Lastschrift';
        }
        update this.convertOpp;
    }


    /*******************************************************************************
    *  Name            : selectOpportunity()
    *  Summary         : Select Opportunity from database
    *  CreatedDate     : 22/10/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void selectOpportunity() {
        this.convertOpp = [
                SELECT OwnerId, Owner.Email, Account.Name, Account.BillingCountry, SEPA_Request_Approved__c, Einwilligung_Lastschriftverfahren__c,
                        StageName, Name_of_the_payer_Account_holder__c, IBAN__c, AGB_Datenschutzhinweise_Richtigkeit__c, SEPA_Request_Approval_Date__c,
                        SWIFT_BIC__c, Zahlungsart__c, Direct_Debit_Mandate_Type__c, Send_SEPA_approval_link__c, Starts_Payment_method__c, Account.Id,
                (SELECT Contact.FirstName, Contact.LastName FROM OpportunityContactRoles WHERE IsPrimary = TRUE LIMIT 1)
                FROM Opportunity
                WHERE Id = :oppId
                LIMIT 1];
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : notification of data approval to the user
    *  CreatedDate     : 27/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Map<String, BackOffice_Notifications__c> backOfficeNotifyCustomSettingMap = BackOffice_Notifications__c.getAll();
        if (this.convertOpp.StageName == 'Closed Won' && this.convertOpp.Account.BillingCountry != null &&
                backOfficeNotifyCustomSettingMap.get(this.convertOpp.Account.BillingCountry) != null &&
                backOfficeNotifyCustomSettingMap.get(this.convertOpp.Account.BillingCountry).Active__c == true) {
            allmsg.add(prepareEmailForGFN(backOfficeNotifyCustomSettingMap));
        }
        allmsg.add(prepareEmailForSales());

        if (! Test.isRunningTest() && ! allmsg.isEmpty()) {
            Messaging.sendEmail(allmsg);
        }
    }


    private Messaging.SingleEmailMessage prepareEmailForSales() {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String body = 'SEPA Data was approved by customer. <br/>' +
                'Opportunity: <a href="' + getBaseUrl() + '/' + this.convertOpp.Id + '" target="_blank">Link</a><br/>';

        message.setSubject('Data is approved');
        message.setHtmlBody(body);
        message.setToAddresses(new List<String>{this.convertOpp.Owner.Email});

        return message;
    }


    private Messaging.SingleEmailMessage prepareEmailForGFN(Map<String, BackOffice_Notifications__c> customSettings) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String subject = this.convertOpp.Account.Name + ' approved SEPA form';
        String body = 'Dear Back Office colleagues, <br/><br/>' +
                'Closed Won Customer <br/>' +
                'has approved SEPA form with the following data: <br/><br/>' +
                'Name of the payer: ' + this.accountHolderName + ' <br/>' +
                'IBAN: ' + this.iban + ' <br/>' +
                'SWIFT BIC: ' + this.swift + ' <br/><br/>' +
                'Please change the payment method in GFN to direct debit. <br/><br/>' +
                'Opportunity: <a href="' + getBaseUrl() + '/' + this.convertOpp.Id + '" target="_blank">Link</a><br/>' +
                'Account: <a href="' + getBaseUrl() + '/' + this.convertOpp.Account.Id + '" target="_blank">Link</a><br/><br/>' +
                'Thanks and best regards.';
        String toAdresses = customSettings.get(this.convertOpp.Account.BillingCountry).Email__c;

        message.setSubject(subject);
        message.setHtmlBody(body);
        message.setToAddresses(new List<String>{toAdresses});

        return message;
    }


    public static String getBaseUrl() {
        return String.valueOf(System.Url.getOrgDomainUrl()).substringAfter('=').remove(']');
    }


    /*******************************************************************************
    *  Name            : validateData()
    *  Summary         : validation filling of mandatory fields    
    *  CreatedDate     : 26/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public Boolean validateData() {
        Pattern myPattern;
        if (fieldValidationRulesMap.containsKey(this.convertOpp.Account.BillingCountry)) {
            this.isApproved = [SELECT SEPA_Request_Approved__c FROM Opportunity WHERE Id = :this.convertOpp.Id LIMIT 1].SEPA_Request_Approved__c;
            if (this.isApproved) {
                this.errorMessage = isApprovedMessageTranslateMap.get((this.convertOpp.Account != null && isApprovedMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ?
                        this.convertOpp.Account.BillingCountry : 'Germany');
                return false;
            }

            myPattern = Pattern.compile(fieldValidationRulesMap.get(this.convertOpp.Account.BillingCountry).get('ACCOUNT HOLDER RGX'));
            if (! myPattern.matcher(this.accountHolderName).matches()) {
                this.errorMessage = accountHolderNameTranslateMap.get((this.convertOpp.Account != null && accountHolderNameTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ?
                        this.convertOpp.Account.BillingCountry : 'Germany');
                return false;
            }

            myPattern = Pattern.compile(fieldValidationRulesMap.get(this.convertOpp.Account.BillingCountry).get('IBAN RGX'));
            if (! myPattern.matcher(this.iban).matches()) {
                this.errorMessage = ibanMessageTranslateMap.get((this.convertOpp.Account != null && ibanMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ?
                        this.convertOpp.Account.BillingCountry : 'Germany');
                return false;
            }

            if ( ! SEPA_Toolkit.SEPAUtilities.ValidateIBAN((String)this.iban)) {
                this.errorMessage = ibanSEPAMessageTranslateMap.get((this.convertOpp.Account != null && ibanSEPAMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ?
                        this.convertOpp.Account.BillingCountry : 'Germany');
                return false;
            }

            myPattern = Pattern.compile(fieldValidationRulesMap.get(this.convertOpp.Account.BillingCountry).get('SWIFT RGX'));
            if (! myPattern.matcher(this.swift).matches()) {
                this.errorMessage = swiftMessageTranslateMap.get((this.convertOpp.Account != null && swiftMessageTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ?
                        this.convertOpp.Account.BillingCountry : 'Germany');
                return false;
            }

            if (this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT SEPA').elementItemsMap.get('VALUE').value == 'false' ||
                    this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').value == 'false') {
                this.errorMessage = systemErrorsTranslateMap.get((this.convertOpp.Account != null && systemErrorsTranslateMap.containsKey(this.convertOpp.Account.BillingCountry)) ?
                        this.convertOpp.Account.BillingCountry : 'Germany');
                return false;
            }
            return true;
        }
        return false;
    }

    public void returnstepPagesMap(String deviceView, String country) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(country);

        Map<Id, LongForm_Page__c> lfstepPagesMap = new Map<Id, LongForm_Page__c>([
                SELECT Name, Type__c, Long_Form__c
                FROM LongForm_Page__c
                WHERE Long_Form__r.Country__c = :country AND
                Name IN :paymentOptionsPagesSet AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
                LIMIT 10000
        ]);

        List<LongForm_Element__c> elementsList = [
                SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c,
                (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
                FROM LongForm_Element__c
                WHERE Long_Form_Page__c IN :lfstepPagesMap.keySet()
                LIMIT 10000];

        this.stepPagesMap = new Map<String, LongFormPage>();
        Set<String> fieldTypes = new Set<String>{'Text Field', 'Picklist Field', 'Radio-button Field', 'Checkbox Field', 'Slider Field'};
        for (LongForm_Element__c element : elementsList) {
            if (! this.stepPagesMap.containsKey(element.Long_Form_Page__r.Name) ) {
                this.stepPagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                this.stepPagesMap.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                this.stepPagesMap.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
                this.stepPagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongFormElementItem>>();
                this.stepPagesMap.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
            }

            if (fieldTypes.contains(element.Type__c) && ! element.Long_Form_Element_Items__r.isEmpty()) {
                LongFormField field = new LongFormField();
                field.options = new List<SelectOption>();
                field.elementItemsMap = new Map<String, LongFormElementItem>();
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    if (elementItem.Type__c == 'Options') {
                        lfElementItem.value = elementItem.Value__c.deleteWhitespace();
                        lfElementItem.value = elementItem.Value__c.replaceAll('_', ' ');
                        List<String> optionsList = elementItem.Value__c.split(';');
                        for (String option : optionsList) {
                            option = option.trim();
                            field.options.add(new SelectOption(option.substringBefore('=>'), option.substringAfter('=>')));
                        }
                    }
                    field.elementItemsMap.put(elementItem.Name, lfElementItem);
                }
                this.stepPagesMap.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (! this.stepPagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name) ) {
                    this.stepPagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongFormElementItem>());
                }

                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    this.stepPagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, lfElementItem);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : attachSepaPdf()
    *  Summary         : save SEPA Mandate PDF
    *  CreatedDate     : 06/02/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // @future(callout=true)
    private static void attachSepaPdf(Id opportunityId, String accountHolder, String iban, String swift) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Germany');

        String fileName = 'SEPAMandate';
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        String baseUrl = settings.Files_Generator_Url__c;
        PageReference sepaMandatePage = new PageReference(
                baseUrl + '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(
                                key256AES, 'documentName=' + fileName + '&' + 'opportunityID=' + opportunityId + '&pdfDownload=TRUE' +
                                        '&dynamicAccHolder=' + accountHolder + '&dynamicIBAN=' +  iban + '&dynamicSWIFT=' + swift + '&'
                        )
        );
        Blob pdfContent;
        if (Test.IsRunningTest()) {
            pdfContent = Blob.valueOf('test');
        } else {
            pdfContent = sepaMandatePage.getContentAsPDF();
        }

        fileName = fileName + '.pdf';
        List<Attachment> attachmentCheck = [
                SELECT Body FROM
                        Attachment
                WHERE ParentId = :opportunityId AND Name = :fileName];
        if ( ! attachmentCheck.isEmpty() ) {
            delete attachmentCheck;
        }
        Attachment attachment = new Attachment(ParentId = opportunityId, Body = pdfContent, Name = fileName);
        insert attachment;
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

    private final Map<String, Map<String, String>> fieldValidationRulesMap = new Map<String, Map<String, String>> {
            'Germany' => new Map<String, String>{
                    'ACCOUNT HOLDER RGX' => '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]+$',
                    'IBAN RGX' => '(^[Dd]{1}[Ee]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{2}?$|^[Aa]{1}[Tt]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Ll]{1}[Uu]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Nn]{1}[Ll]{1}[0-9]{2}[A-Za-z]{4}[0-9]{10}?$|^[Bb]{1}[Ee]{1}[0-9]{14}?$|^[Ff]{1}[Rr]{1}[0-9]{12}[A-Za-z0-9]{11}[0-9]{2}?$)',
                    'SWIFT RGX' => '^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$'
            },
            'Netherlands' => new Map<String, String>{
                    'ACCOUNT HOLDER RGX' => '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]+$',
                    'IBAN RGX' => '(^[Dd]{1}[Ee]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{2}?$|^[Aa]{1}[Tt]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Ll]{1}[Uu]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Nn]{1}[Ll]{1}[0-9]{2}[A-Za-z]{4}[0-9]{10}?$|^[Bb]{1}[Ee]{1}[0-9]{14}?$|^[Ff]{1}[Rr]{1}[0-9]{12}[A-Za-z0-9]{11}[0-9]{2}?$)',
                    'SWIFT RGX' => '^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$'
            },
            'Belgium-NL' => new Map<String, String>{
                    'ACCOUNT HOLDER RGX' => '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]+$',
                    'IBAN RGX' => '(^[Dd]{1}[Ee]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{2}?$|^[Aa]{1}[Tt]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Ll]{1}[Uu]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Nn]{1}[Ll]{1}[0-9]{2}[A-Za-z]{4}[0-9]{10}?$|^[Bb]{1}[Ee]{1}[0-9]{14}?$|^[Ff]{1}[Rr]{1}[0-9]{12}[A-Za-z0-9]{11}[0-9]{2}?$)',
                    'SWIFT RGX' => '^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$'
            },
            'France' => new Map<String, String>{
                    'ACCOUNT HOLDER RGX' => '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]+$',
                    'IBAN RGX' => '(^[Dd]{1}[Ee]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{2}?$|^[Aa]{1}[Tt]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Ll]{1}[Uu]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Nn]{1}[Ll]{1}[0-9]{2}[A-Za-z]{4}[0-9]{10}?$|^[Bb]{1}[Ee]{1}[0-9]{14}?$|^[Ff]{1}[Rr]{1}[0-9]{12}[A-Za-z0-9]{11}[0-9]{2}?$)',
                    'SWIFT RGX' => '^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$'
            },
            'Belgium-FR' => new Map<String, String>{
                    'ACCOUNT HOLDER RGX' => '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]+$',
                    'IBAN RGX' => '(^[Dd]{1}[Ee]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{2}?$|^[Aa]{1}[Tt]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Ll]{1}[Uu]{1}[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{4}[0-9]{4}?$|^[Nn]{1}[Ll]{1}[0-9]{2}[A-Za-z]{4}[0-9]{10}?$|^[Bb]{1}[Ee]{1}[0-9]{14}?$|^[Ff]{1}[Rr]{1}[0-9]{12}[A-Za-z0-9]{11}[0-9]{2}?$)',
                    'SWIFT RGX' => '^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$'
            }
    };

    public static Set<String> paymentOptionsPagesSet = new Set<String>{
            'PAYMENT OPTIONS',
            'HEADER',
            'SEPA APPROVE SUCCESS'
    };

    public class MessageException extends Exception {}
}