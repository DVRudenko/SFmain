public class RestServiceUtils {

    public static final String VALIDATION_ERROR_MESSAGE = 'Required field is missing: ';

    /*******************************************************************************
    *  Name            : setJSONRestResponse()
    *  Summary         : sets parameters for RestResponse with JSON body
    *  CreatedDate     : 20.06.2019
    *  Parameters      : RestResponse response, String recordId - ID of created record,
    *                  : Boolean success, Integer statusCode, List<String> errors
    *  Returns         :  -
    ******************************************************************************/
    public static void setJSONRestResponse(RestResponse response, String recordId, Boolean success, Integer statusCode, List<String> errors) {
        response.addHeader('Content-Type', 'application/json;charset=UTF-8');
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(JSON.serialize(new ResponseBody(success, recordId, errors)));
    }

    /*******************************************************************************
    *  Name            : base64DecodeQueryParams()
    *  Summary         : decodes query parameter's values from base64
    *  CreatedDate     : 24.06.2019
    *  Parameters      : Map<String, String> queryParams - parameters with base64 encoded values
    *  Returns         : -
    ******************************************************************************/
    public static void base64DecodeQueryParams(Map<String, String> queryParams) {
        for (String paramName : queryParams.keySet()) {
            queryParams.put(paramName, EncodingUtil.base64Decode(GlobalUtils.blankStringIfNull(queryParams.get(paramName))).toString());
        }
    }

    /*******************************************************************************
    *  Name            : base64EncodeQueryParams()
    *  Summary         : Encodes query parameter's values into base64
    *  CreatedDate     : 24.06.2019
    *  Parameters      : Map<String, String> queryParams - query parameters to be encoded
    *  Returns         : -
    ******************************************************************************/
    public static void base64EncodeQueryParams(Map<String, String> queryParams) {
        for (String paramName : queryParams.keySet()) {
            queryParams.put(paramName, EncodingUtil.base64Encode(Blob.valueOf(GlobalUtils.blankStringIfNull(queryParams.get(paramName)))));
        }
    }

    /*******************************************************************************
    *  Name            : validateRequiredFields()
    *  Summary         : validates required fields
    *  CreatedDate     : 17.06.2019
    *  Parameters      : Map<String, String> requiredFieldsMap - mandatory fields from JSON
    *  Returns         : List<String> - errors if any
    ******************************************************************************/
    public static List<String> validateRequiredFields(Map<String, String> requiredFieldsMap) {
        List<String> errors = new List<String>();
        for (String fieldName : requiredFieldsMap.keySet()) {
            if (String.isBlank(requiredFieldsMap.get(fieldName))) errors.add(VALIDATION_ERROR_MESSAGE + fieldName);
        }
        return errors;
    }

    /*******************************************************************************
    *  Name            : createAttachment()
    *  Summary         : creates an Attachment
    *  CreatedDate     : 25.06.2019
    *  Parameters      : Id parentId - ID of record to which Attachment will be attached,
    *                  : Map<String, String> fieldNameFieldValueMap - Attachment properties,
    *                  : Blob content - binary file content
    *  Returns         : Attachment - created Attachment
    ******************************************************************************/
    public static Attachment createAttachment(Id parentId, Map<String, String> params, Blob content) {
        //change filename to correct format
        String fileName = params.get('fileName');
        fileName = fileName.substringBeforeLast('.') + '.' + fileName.substringAfterLast('.').toLowerCase();
        //create attachment
        Attachment newAttachment = new Attachment(
                ParentId = parentId,
                Name = fileName,
                ContentType = params.get('fileContentType'),
                Body = content
        );
        return newAttachment;
    }

    /*******************************************************************************
    *  Name            : createCase()
    *  Summary         : creates a new Case with Support record type
    *  CreatedDate     : 25.06.2019
    *  Parameters      : Map<String, String> params - Case properties
    *  Returns         : Case - created Case
    ******************************************************************************/
    public static Case createCase(Map<String, String> params, String status, String origin, String priority, Boolean isCCSSiteWebform) {
        //init default fields
        Case newCase = new Case();
        newCase.RecordTypeId = isCCSSiteWebform ? GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support_CCS.name()) : 
                                                GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
        newCase.Status = status;
        newCase.Origin = origin;
        newCase.Priority = priority;

        //fill up params provided by web form
        //required params
        if ( isCCSSiteWebform ) {
            Map<String, String> topicMap = new Map<String, String> {
                'moje karta/y' => 'My Card(s)',
                'můj účet' => 'Update my account details',
                'faktury a platby' => 'Invoices & Payments',
                'carnet' => 'My Carnet unit(s)',
                'produkty a služby' => 'Products & Services',
                'obchodní síť' => 'Others',
                'ostatní' => 'Others',

                'moja karta/y' => 'My Card(s)',
                'moj účet' => 'Update my account details',
                'faktúry a platby' => 'Invoices & Payments',
                'produkty a služby' => 'Products & Services',
                'obchodná sieť' => 'Others',
                'ostatné' => 'Others'
            };
            newCase.Topic__c = topicMap.get(params.get('topic').toLowerCase());
        } else {
            newCase.Topic__c = params.get('topic');
        }
        newCase.SuppliedEmail = params.get('email');
        newCase.SuppliedName = params.get('fullName');
        newCase.Country__c = params.get('country');
        newCase.Language__c = params.get('language');
        newCase.Description = params.get('description');
        newCase.Sub_topic__c = params.get('subTopic');
        newCase.Subject = params.get('subject');
        //optional params
        newCase.Customer_ID__c = params.get('customerId');
        newCase.SuppliedPhone = params.get('phoneNumber');
        newCase.CCS_Company_ID__c = params.get('ico');
        Map<String, Id> accountAndContact = getAccountAndContact(params.get('email'));
        newCase.AccountId = accountAndContact.get('Account');
        newCase.ContactId = accountAndContact.get('Contact');
        setOwner(newCase, params.get('topic').toLowerCase());
        return newCase;
    }

    /*******************************************************************************
    *  Name            : createMessage()
    *  Summary         : creates a new incoming message with content of original request from Web
    *  CreatedDate     : 26.07.2019
    *  Parameters      : Case createdCase - original created Case
    *  Returns         : void
    ******************************************************************************/
    public static EmailMessage createMessage(Case createdCase, Boolean isCCSSiteWebform) {
        //compose appropriate queue developer name
        //get queue
        String queueEmail;
        List<Group> selectedQueues = new List<Group>();
        if ( isCCSSiteWebform ) {
            selectedQueues = new List<Group>([
                SELECT  Id, 
                        Email
                FROM    Group
                WHERE   Id =: createdCase.OwnerId
                LIMIT   1
            ]);
            
        }
        else {
            String queueDeveloperName = createdCase.Country__c + '_' + createdCase.Language__c + '_Support';
            selectedQueues = ([
                    SELECT Id, Email
                    FROM Group
                    WHERE DeveloperName = :queueDeveloperName
                    AND Type = 'Queue'
            ]);
        }
        if( selectedQueues.size()>0 ){
            queueEmail = selectedQueues.get(0).Email;
        }
        //create message
        EmailMessage message = new EmailMessage(
                ParentId = createdCase.Id,
                TextBody = createdCase.Description,
                HtmlBody = createdCase.Description.replace('\n', '<br>'),
                Subject = createdCase.Subject,
                FromName = createdCase.SuppliedName,
                FromAddress = createdCase.SuppliedEmail,
                ToAddress = queueEmail,
                Incoming = true
        );
        return message;
    }

    /*******************************************************************************
    *  Summary         : set case owner according case topic
    *  Created         : 08.01.2020 Anton Hrytsavets
    *  Parameters      : Case newCase - case which Owner should be changed
    *  Returns         : void
    ******************************************************************************/
    private static void setOwner(Case newCase, String topicFromSite) {
        Map<String, String> topicToOwnerMapping = new Map<String, String>{
            'moje karta/y' => 'Zákaznická podpora',
            'můj účet' => 'Zákaznická podpora',
            'Môj účet' => 'Zákaznická podpora',
            'faktury a platby' => 'Zákaznická podpora',
            'carnet' => 'Carnet',
            'produkty a služby' => 'Market',
            'obchodní síť' => 'Provoz',
            'ostatní' => 'Market',

            'moja karta/y' => 'Zákaznické',
            'moj účet' => 'Zákaznické',
            'faktúry a platby' => 'Zákaznické',
            'produkty a služby' => 'Zákaznické',
            'obchodná sieť' => 'Zákaznické',
            'ostatné' => 'Zákaznické'
        };
        List<Group> groups = [
            SELECT  Id
            FROM    Group
            WHERE   Name =: topicToOwnerMapping.get(topicFromSite)
        ];
        if(groups != null && groups.size()>0){
            newCase.OwnerId = groups[0].Id;
        }
    }

    /*******************************************************************************
    *  Summary         : get Account By email address. Returns null if multiple accounts are found
    *  Created         : 21.01.2020 Anton Hrytsavets
    *  Parameters      : String emailAddress - email address from AT/DE/CZ/SK webform
    *  Returns         : Id - Id of Account record which was selected
    ******************************************************************************/
    private static Map<String, Id> getAccountAndContact(String emailAddress) {
        Map<String, Id> contactAndAccount = new Map<String, Id>();
        List<Id> accountIdList = new List<Id>();
        List<Contact> contactList = [
            SELECT  Id,
                    AccountId
            FROM    Contact
            WHERE   Email =: emailAddress
        ];
        for(Contact selectedContact : contactList) {
            if(selectedContact.AccountId != null) {
                accountIdList.add(selectedContact.AccountId);
            }
        }
        if(new Set<Id>(accountIdList).size() == 1) {
            contactAndAccount.put('Account', accountIdList.get(0));
        }
        if(contactList.size() == 1){
            contactAndAccount.put('Contact', contactList[0].Id);
        }
        return contactAndAccount;
    }
}