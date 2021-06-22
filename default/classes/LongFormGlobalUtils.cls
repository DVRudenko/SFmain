public class LongFormGlobalUtils {
    public static final String EMAIL_REGEX = '^\\w+([.-]\\w+)*@\\w+([.-]\\w+)*(\\.\\w{2,4})+$';
    public static final String EMAIL_REGEX_RU = '^\\w+([.-]\\w+)*@\\w+([.-]\\w+)*(\\.\\w{2,7})+$';
    public static final String SWIFT_REGEX = '^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$';
    public static final String LETTERS_SPACES_REGEX = '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]+$';
    public static final String FIRST_NAME = '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]{1,30}$';
    public static final String COMPANY_NAME_REGEX = '^.{1,120}$';
    public static final String CITY_REGEX = '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'.-]+$';
    public static final String CARD_COMPANY_DE = '^[0-9a-zA-Z\\s]+$';
    public static final String PHONE_DE_REGEX = '^([0-9+]{13,15})$';
    public static final String PHONE_BENL_REGEX = '^([0-9+]{11,13})$';
    public static final String PHONE_BEFR_REGEX = '^([0-9+]{11,13})$';
    public static final String PHONE_RU_REGEX = '^(8|\\+7)\\s{1}(\\d{10})$';
    public static final String TAXID_AT_REGEX = '^([0-9]{2}[0-9]{7})+$';
    public static final String TAXID_CHDE_REGEX = '/^([Cc]{1}[Hh]{1}[Ee]{1}[0-9]{9})+$/';


    /*******************************************************************************
    *  Name            : validateEmailFormatRu(String email)
    *  Summary         : email format validation for Russia
    *  CreatedDate     : 12/08/2020
    *  ModifiedDate    : -
    *  Parameters      : String email
    *  Returns         : Boolean isValid
    ******************************************************************************/
    public static Boolean validateEmailFormatRu(String email) {
        Boolean isValid = true;
        Pattern myPattern = Pattern.compile(EMAIL_REGEX_RU);
        Matcher myMatcher = myPattern.matcher(email);
        if (!myMatcher.matches()) isValid = false;
        return isValid;
    }


    /*******************************************************************************
    *  Name            : validatePhone(String phoneNumber, String country)
    *  Summary         : phone format validation
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 26/11/2018 by Ivan: was added Hungary
    *  Parameters      : String phoneNumber, String country
    *  Returns         : Boolean isValid
    ******************************************************************************/
    public static Boolean validatePhone(String phoneNumber, String country) {
        Boolean isValid = true;
        String phoneRegex = '';
        if (country == 'Russia') {
            phoneRegex = PHONE_RU_REGEX;
        }
        Pattern myPattern = Pattern.compile(phoneRegex);
        Matcher myMatcher = myPattern.matcher(phoneNumber);

        if (!myMatcher.matches()) isValid = false;
        return isValid;
    }


    /*******************************************************************************
    *  Name            : getUserIPAddress()
    *  Summary         : get user ip address
    *  CreatedDate     : 16/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static String getUserIPAddress() {
        String ipAddress = '';
        // True-Client-IP has the value when the request is coming via the caching integration.
        ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');

        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ipAddress == '' || ipAddress == null) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }// get IP address when no caching (sandbox, dev, secure urls)

        if (ipAddress == '' || ipAddress == null) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
        return ipAddress;
    }


    /*******************************************************************************
    *  Name            : generateOppWithEncodedUrl(Opportunity opportunity, String e2eKeysApiName)
    *  Summary         : based on opportunity id and step generate unique id
    *  CreatedDate     : 01/06/18
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity, String e2eKeysApiName
    *  Returns         : String - encoded parameter
    ******************************************************************************/
    public static String generateOppWithEncodedUrl(Opportunity opportunity, String e2eKeysApiName) {
        // update opportunity with e2e encoded id
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eKeysApiName).AES256_Key__c);
        // generate link to e2e last active step
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);

        return encodedStringUrl;
    }


    /*******************************************************************************
    *  Name            : generateOppWithSepaUrl(Opportunity opportunity, String e2eKeysApiName)
    *  Summary         : based on opportunity id and generate unique sepa param
    *  CreatedDate     : 01/06/18
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity, String e2eKeysApiName
    *  Returns         : String - encoded sepa url
    ******************************************************************************/
    public static String generateOppWithSepaUrl(Opportunity opportunity, String e2eKeysApiName) {
        // generate link to SEPA MANDATE
        String sepaStringToEncode = 'documentName=SEPAMandate&opportunityID=' + opportunity.Id + '&pdfDownload=TRUE';
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eKeysApiName).AES256_Key__c);
        String sepaEncodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, sepaStringToEncode);

        return sepaEncodedStringUrl;
    }


    /*******************************************************************************
    *  Name            : findAndProcessDuplicateLead()
    *  Summary         : Find duplicate Lead
    *  CreatedDate     : 11/10/2018
    *  ModifiedDate    : -
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    public static void findAndProcessDuplicateLead(String firstName, String lastName, String email, String phone,
            String country, String recordTypeName) {
        if (System.isFuture() || System.isBatch()) {
            System.enqueueJob(new DuplicateLeadQueueuable(firstName, lastName, email, phone, country, recordTypeName));
        } else {
            findAndProcessDuplicateLeadFuture(firstName, lastName, email, phone, country, recordTypeName);
        }
    }


    /*******************************************************************************
    *  Name            : findAndProcessDuplicateLead()
    *  Summary         : Find duplicate Lead
    *  CreatedDate     : 11/10/2018
    *  ModifiedDate    : -
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @future
    public static void findAndProcessDuplicateLeadFuture(String firstName, String lastName, String email, String phone,
            String country, String recordTypeName) {
        try {
            String emailDomain = '%' + email.substringAfter('@');

            List<Lead> duplicateLeadsList = [
                    SELECT Status, FirstName, LastName, Company, OwnerId,
                            Owner.FirstName, Owner.LastName, Owner.Email
                    FROM Lead
                    WHERE (Email = :email OR Phone = :phone OR
                    (FirstName = :firstName AND LastName = :lastName AND Email LIKE :emailDomain)) AND
                    Country = :country AND
                    RecordType.Name = :recordTypeName AND
                    Status != 'Disqualified' AND
                    IsConverted = FALSE
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            if (!duplicateLeadsList.isEmpty()) {
                String oldStatus = duplicateLeadsList.get(0).Status;
                duplicateLeadsList.get(0).Status = 'Disqualified';
                duplicateLeadsList.get(0).Quali_Status__c = 'Switched to E2E';
                Database.SaveResult sRdupLead = Database.update(duplicateLeadsList.get(0), false);
                if (!sRdupLead.isSuccess()) {
                    String error = '';
                    for (Database.Error err : sRdupLead.getErrors()) {
                        error += err.getMessage();
                    }
                    throw new LongFormException(error);
                }

                String ownerId = duplicateLeadsList.get(0).OwnerId;
                if (ownerId.substring(0, 3) == '00G') {
                    // WHAT TO DO WITH QUEUE?
                } else {
                    String body = 'Dear , ' + duplicateLeadsList.get(0).Owner.FirstName + ' ' + duplicateLeadsList.get(0).Owner.LastName + '<br/>' +
                            'Status of your current lead ' + duplicateLeadsList.get(0).FirstName + ' ' + duplicateLeadsList.get(0).LastName + ' / ' +
                            duplicateLeadsList.get(0).Company + 'was changed from ' + oldStatus + ' to ' + duplicateLeadsList.get(0).Status +
                            ' because your customer started e2e Application and tries to order cards online.<br/>' +
                            '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + duplicateLeadsList.get(0).Id + '" target="_blank">Current Lead</a><br/>' +
                            'No actions are required at the moment.<br/>' +
                            'Thanks and best regards.';
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setSubject('E2E Notification');
                    message.setHtmlBody(body);
                    message.setToAddresses(new List<String>{
                            duplicateLeadsList.get(0).Owner.Email
                    });
                    Messaging.sendEmail(new List<Messaging.Email>{
                            message
                    });
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('LongFormGlobalUtils.findAndProcessDuplicateLeadFuture', String.valueOf(e.getStackTraceString()));
        }
    }


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 29/10/2018
    *  ModifiedDate    : by Artem Voitik
    *  Parameters      : String encryptedParams, String e2eFormName
    *  Returns         : String - Opportunity ID
    ******************************************************************************/
    public static String doDecryptParams(String encryptedParams, String e2eFormName) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues(e2eFormName) == null) throw new LongFormException('The link is corrupted.');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eFormName).AES256_Key__c);
        Blob dest = EncodingUtil.base64Decode(encryptedParams);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
        String decryptedParams = decrypted.toString();
        if (decryptedParams != null) {
            String opptyId = decryptedParams.substringBefore('-');
            return opptyId;
        } else {
            return null;
        }
    }


    public static Map<String, LongFormPage> returnErrorPage(String country, String deviceView) {
        if (!availableCountriesSet.contains(country)) country = 'Germany';
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(country);
        Map<Id, LongForm_Page__c> errorPageMap = new Map<Id, LongForm_Page__c>([
                SELECT Name, Type__c, Long_Form__c
                FROM LongForm_Page__c
                WHERE Long_Form__r.Country__c = :country AND
                (Name = 'SYSTEM ERROR' OR Name = 'VOUCHER' OR
                Name = 'HEADER' OR Name = 'FOOTER') AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
                LIMIT 4
        ]);

        List<LongForm_Element__c> elementsList = [
                SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c, (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
                FROM LongForm_Element__c
                WHERE Long_Form_Page__c IN :errorPageMap.keySet()
                LIMIT 10000
        ];

        Map<String, LongFormPage> pagesMapErrors = new Map<String, LongFormPage>();
        for (LongForm_Element__c element : elementsList) {
            if (!pagesMapErrors.containsKey(element.Long_Form_Page__r.Name)) {
                pagesMapErrors.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMapErrors.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongFormElementItem>>();
            }
            if (!pagesMapErrors.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name)) {
                pagesMapErrors.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongFormElementItem>());
            }
            for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                LongFormElementItem lfElementItem = new LongFormElementItem();
                lfElementItem.value = elementItem.Value__c;
                pagesMapErrors.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, lfElementItem);
            }
        }
        return pagesMapErrors;
    }


    /*******************************************************************************
    *  Name            : isSandbox()
    *  Summary         : Returns true if sandbox     
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : 
    *  Parameters      : 
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }


    public static Set<String> mobileDevicesSet = new Set<String>{
            'Android',
            'webOS',
            'iPhone',
            'iPad',
            'iPod',
            'BlackBerry',
            'IEMobile',
            'Opera Mini'
    };

    public static Set<String> availableCountriesSet = new Set<String>{
            'Germany',
            'Austria',
            'Netherlands',
            'Belgium-NL',
            'Belgium-FR',
            'France',
            'Poland',
            'Hungary',
            'Switzerland-DE',
            'Switzerland-FR'
    };
}