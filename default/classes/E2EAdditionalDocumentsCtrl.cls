public class E2EAdditionalDocumentsCtrl {
    public String renderAs {get; set;}
    public String documentName {get;set;}
    public String downloadRenderPDF {get;set;}
    public String contactTitle {get; set;}
    public String contactPhone {get; set;}
    public ID opportunityID {get; set;}
    public String umr {get; set;}

    public Opportunity currentOpportunity {get; set;}
    public String fullName {get; set;}
    public String companyName {get; set;}
    public String dynamicAccountHolder {get; set;}
    public String dynamicIBAN {get;set;}
    public String dynamicSWIFT {get;set;}
    public Map<String, LongFormPage> pagesMapPaymentOptions {get; set;}

    public E2EAdditionalDocumentsCtrl() {
        try {
            this.umr = '';
            if (ApexPages.currentPage().getParameters().get('hash') != null) {
                preparePage(ApexPages.currentPage().getParameters().get('hash'));
            }
        } catch (exception e) {
            ExceptionLogger.sendException('E2EAdditionalDocumentsCtrl ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    public void preparePage(String hash) {
        if (E2EKeysAPI__c.getValues('E2EForm') != null) {
            Blob keyAES256 = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
            hash = hash.replaceAll('(\\s|%2B)', '+');
            String hashDecode = E2EFormEncryption.decodeHashAlgorithmAES256(keyAES256, hash);
            if(hashDecode.contains('opportunityID')){
                opportunityID = id.valueOf(((hashDecode.substringAfter('opportunityID=')).substringBefore('&')).replace('#',''));
                currentOpportunity = [
                        SELECT Id, Name, Account.Name, Name_of_the_payer_Account_holder__c, IBAN__c, SWIFT_BIC__c,
                                Account.BillingCountryCode, Account.Billingcountry, Security_To_Pay__c,
                                Account.Billingstreet,Account.Billingcity, Account.Billingpostalcode, Account.IBAN__c,
                                Account.SWIFT_BIC__c, Security_Amount_To_Pay__c, Account.Steuernummer__c,
                                account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, SEPA_Request_Approval_Date__c,
                                Date_For_Agree_To_Deposit_Agreement__c, Credit_check_date__c, Account.UMR__c,
                                Device_Type__c, Account.Umsatzsteuer_ID__c, Registered_Country__c,
                                Direct_Debit_Mandate_Type__c, Number_of_electric_vehicles__c
                        FROM Opportunity
                        WHERE Id = :opportunityID];

                this.companyName = currentOpportunity.Account.Name;
                if (currentOpportunity.Account.Umr__c != null) {
                    List<String> umrDigitsList = currentOpportunity.Account.Umr__c.split('');
                    for (String d : umrDigitsList) {
                        this.umr += '<span style="width: 20px; float: left;">' + d + '</span>';
                    }
                }

                List<OpportunityContactRole> role = [
                        SELECT Contact.FirstName, Contact.LastName, Contact.Title, Contact.Phone
                        FROM OpportunityContactRole
                        WHERE OpportunityId = :currentOpportunity.Id AND
                        IsPrimary = TRUE
                        LIMIT 1];
                if ( ! role.isEmpty() ) {
                    this.fullName = role.get(0).Contact.FirstName + ' ' + role.get(0).Contact.LastName;
                    this.contactTitle = role.get(0).Contact.Title;
                    this.contactPhone = role.get(0).Contact.Phone;
                }
            }
            if(hashDecode.contains('documentName')){
                documentName = ((hashDecode.substringAfter('documentName=')).substringBefore('&')).replace('#','');
                if ( (documentName == 'PaymentInformation' || documentName == 'howToPayDeposit') && currentOpportunity != null) {
                    preparePaymentInformationBlock(currentOpportunity.Account.Billingcountry, currentOpportunity.Device_Type__c);
                }
            }
            if(hashDecode.contains('pdfDownload')){
                downloadRenderPDF = ((hashDecode.substringAfter('pdfDownload=')).substringBefore('&')).replace('#','');
            }
            if(hashDecode.contains('dynamicAccHolder')){
                dynamicAccountHolder = ((hashDecode.substringAfter('dynamicAccHolder=')).substringBefore('&')).replace('#','');
            }
            if(hashDecode.contains('dynamicIBAN')){
                dynamicIBAN = ((hashDecode.substringAfter('dynamicIBAN=')).substringBefore('&')).replace('#','');
            }
            if(hashDecode.contains('dynamicSWIFT')){
                dynamicSWIFT = ((hashDecode.substringAfter('dynamicSWIFT=')).substringBefore('&')).replace('#','');
            }
        }
        if ((downloadRenderPDF == 'TRUE') && (documentName != null)) {
            renderAs = 'pdf';
            Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + documentName + '.pdf');
        }
    }

    public void preparePaymentInformationBlock(String country, String deviceView) {
        Set<String> longFormPagesSet = new Set<String>{
                'CONGRATULATIONS'
        };
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(country);
        Map<Id, LongForm_Page__c> lfpagesMapPaymentOptions = new Map<Id, LongForm_Page__c>([
                SELECT Name, Type__c, Long_Form__c
                FROM LongForm_Page__c
                WHERE Long_Form__r.Country__c = :country AND
                Name IN :longFormPagesSet AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
                LIMIT 10000
        ]);
        List<LongForm_Element__c> elementsList = [
                SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c,
                       Long_Form_Page__r.Name, Type__c,
                (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
                FROM LongForm_Element__c
                WHERE Long_Form_Page__c IN :lfpagesMapPaymentOptions.keySet()
                LIMIT 10000];

        this.pagesMapPaymentOptions = new Map<String, LongFormPage>();
        Set<String> fieldTypes = new Set<String>{'Text Field', 'Picklist Field', 'Radio-button Field', 'Checkbox Field', 'Slider Field'};
        for (LongForm_Element__c element : elementsList) {
            if (! this.pagesMapPaymentOptions.containsKey(element.Long_Form_Page__r.Name) ) {
                this.pagesMapPaymentOptions.put(element.Long_Form_Page__r.Name, new LongFormPage());
                this.pagesMapPaymentOptions.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongFormElementItem>>();
                this.pagesMapPaymentOptions.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
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
                this.pagesMapPaymentOptions.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (! this.pagesMapPaymentOptions.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name) ) {
                    this.pagesMapPaymentOptions.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongFormElementItem>());
                }

                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    this.pagesMapPaymentOptions.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, lfElementItem);
                }
            }
        }
    }
}