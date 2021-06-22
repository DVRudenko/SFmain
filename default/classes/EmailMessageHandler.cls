public with sharing class EmailMessageHandler {

    private static final String FLEETCOR_DOMAIN = '@fleetcor';
    private static final String HTML_LINE_BOUNDARY = '<br>';
    private static String supportRecordTypeId = GlobalUtils.getRecordTypeId(Case.class.getName(), GlobalUtils.CaseRecordTypes.Support.name());
    private static String supportCCSRecordTypeId = GlobalUtils.getRecordTypeId(Case.class.getName(), GlobalUtils.CaseRecordTypes.Support_CCS.name());

    /*******************************************************************************
    *  Name            : getRespectiveCaseDataMap
    *  Summary         : gets cases which relate to incoming messages
    *  CreatedDate     : 28/05/2019
    *  Parameters      : List<EmailMessage> messages - incoming messages
    *  Returns         : Map<Id, Case> - Map with cases which relate to incoming messages
    ******************************************************************************/
    private static Map<Id, Case> getRespectiveSupportCases(List<EmailMessage> messages) {
        //create a Set of unique case IDs related to incoming messages
        Set<Id> parentIds = new Set<Id>();
        for (EmailMessage message : messages) {
            parentIds.add(message.ParentId);
        }
        //return a Map based on Set with case IDs and Case objects which related to incoming messages
        return new Map<Id, Case>([
                SELECT Id, AccountId, ContactId, BusinessHoursId, Country__c, Language__c, OwnerId, RecordTypeId, ERP__c, Merchant__c, Terminal__c
                FROM Case
                WHERE Id IN :parentIds
                AND (RecordTypeId = :supportRecordTypeId
                OR RecordTypeId=:supportCCSRecordTypeId)
                AND Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed)
        ]);
    }

    /*******************************************************************************
    *  Name            : processMessagesToClosedCase
    *  Summary         : process messages which was send to Closed cases
    *  CreatedDate     : 22/07/2019
    *  Parameters      : List<EmailMessage> messages - incoming messages
    *  Returns         : -
    ******************************************************************************/
    public static void processMessagesToClosedCase(List<EmailMessage> messages) {
        try {
            //get Support cases with refers to messages and are Closed
            Map<Id, Case> idCaseMap = getRespectiveSupportCases(messages);
            //get already existing open child Cases
            Map<Id, Case> openCaseMap = getOpenChildCaseMap(idCaseMap.keySet());
            Map<String, String> orgWideAddressDisplayName;
            Map<String, Id> queueEmailQueueIdMap;
            //if appropriate cases exist then get information about Support queues and org wide emails
            if ( !idCaseMap.isEmpty()) {
                orgWideAddressDisplayName = getOrgWideEmailsMap();
                queueEmailQueueIdMap = getSupportQueuesMap();
            }
            //Map with original message ID as ID and copy of the original message as Value
            Map<Id, EmailMessage> messageIdMessageCopyMap = new Map<Id, EmailMessage>();
            //Map with original message ID as ID and new cases as Value
            Map<Id, Case> messageIdNewCaseMap = new Map<Id, Case>();
            List<EmailMessage> mesageCopyToOpenCasesList = new List<EmailMessage>();
            Case respectiveClosedSupportCase;
            for (EmailMessage message : messages) {
                respectiveClosedSupportCase = idCaseMap.get(message.ParentId);
                //if message has Closed case with Support record type,
                //message is incoming and not internal fleetcor
                //then create new case with trimmed copy of message in itself
                if (respectiveClosedSupportCase != null && message.Incoming
                        && String.isNotEmpty(message.FromAddress)) {
                    //copy without any references
                    EmailMessage messageCopy = message.clone(false, true, true, true);
                    //cut off redundant history
                    trimEmailHistory(messageCopy, orgWideAddressDisplayName.get(message.ToAddress));
                    //add new case and new message to Maps
                    String newCaseOwner = queueEmailQueueIdMap.get(message.ToAddress.substringBefore(';'));
                    if(String.isEmpty(newCaseOwner)){
                        newCaseOwner = respectiveClosedSupportCase.OwnerId;
                    }
                    if(openCaseMap.get(message.ParentId) == null) {
                        messageIdNewCaseMap.put(
                                message.Id,
                                new Case(
                                        ParentId = respectiveClosedSupportCase.Id,
                                        AccountId = respectiveClosedSupportCase.AccountId,
                                        ContactId = respectiveClosedSupportCase.ContactId,
                                        OwnerId = newCaseOwner,
                                        BusinessHoursId = respectiveClosedSupportCase.BusinessHoursId,
                                        Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new),
                                        Origin = 'Email',
                                        RecordTypeId = respectiveClosedSupportCase.RecordTypeId,
                                        Priority = 'Medium',
                                        SuppliedEmail = message.FromAddress,
                                        Subject = message.Subject,
                                        Description = messageCopy.TextBody,
                                        Country__c = respectiveClosedSupportCase.Country__c,
                                        Language__c = respectiveClosedSupportCase.Language__c,
                                        ERP__c = respectiveClosedSupportCase.ERP__c,
                                        Merchant__c = respectiveClosedSupportCase.Merchant__c,
                                        Terminal__c = respectiveClosedSupportCase.Terminal__c
                                )
                        );
                        messageIdMessageCopyMap.put(message.Id, messageCopy);
                    }
                    else {
                        messageCopy.ParentId = openCaseMap.get(message.ParentId).Id;
                        mesageCopyToOpenCasesList.add(messageCopy);
                    }
                }
            }
            //insert new cases
            insert messageIdNewCaseMap.values();
            //populate new messages with appropriate new case IDs
            for (Id messageId : messageIdNewCaseMap.keySet()) {
                messageIdMessageCopyMap.get(messageId).ParentId = messageIdNewCaseMap.get(messageId).Id;
            }
            for(EmailMessage message: mesageCopyToOpenCasesList) {
                messageIdMessageCopyMap.put(message.Id, message);
            }
            //insert new messages
            insert messageIdMessageCopyMap.values();
        } catch (Exception e) {
            System.debug('ERROR');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : trimEmailHistory
    *  Summary         : cuts off email history related to Closed case
    *  CreatedDate     : 22/07/2019
    *  Parameters      : EmailMessage message
    *  Returns         : -
    ******************************************************************************/
    private static void trimEmailHistory(EmailMessage message, String toName) {
        if (String.isNotBlank(message.HtmlBody) || String.isNotBlank(message.TextBody)) {
            if(String.isNotBlank(message.FromName)){
                //based on that message outgoing or incoming, cut off history.
                String threadId = '';
                Pattern p = Pattern.compile('(ref:.*:ref)');
                Matcher m = p.matcher(message.HtmlBody);
                if(m.find()) {
                    threadId = m.group(1);
                }
                Integer fromNameIndex = message.HtmlBody.indexOf(message.FromName);
                Integer toNameIndex = toName == null ? -1 : message.HtmlBody.indexOf(toName);
                if (fromNameIndex != -1 && toNameIndex != -1) {
                    if (fromNameIndex <= toNameIndex) {
                        message.HtmlBody = message.HtmlBody.substring(0, fromNameIndex).substringBeforeLast(HTML_LINE_BOUNDARY);
                    } else if (fromNameIndex > toNameIndex) {
                        message.HtmlBody = message.HtmlBody.substring(0, toNameIndex).substringBeforeLast(HTML_LINE_BOUNDARY);
                    }
                } else if (fromNameIndex != -1) {
                    message.HtmlBody = message.HtmlBody.substring(0, fromNameIndex).substringBeforeLast(HTML_LINE_BOUNDARY);
                } else if (toNameIndex != -1) {
                    message.HtmlBody = message.HtmlBody.substring(0, toNameIndex).substringBeforeLast(HTML_LINE_BOUNDARY);
                } else {
                    return;
                }
                //compose correct HtmlBody
                message.HtmlBody = message.HtmlBody + HTML_LINE_BOUNDARY + threadId;
            }
        }
    }

    /*******************************************************************************
    *  Name            : getSupportQueuesMap
    *  Summary         : selects queues which marked as Support and returns them in Map
    *  CreatedDate     : 22/07/2019
    *  Parameters      : -
    *  Returns         : Map<String, Id> - Map with queue email as ID and queue ID as value
    ******************************************************************************/
    private static Map<String, Id> getSupportQueuesMap() {
        //selects list of queues
        List<Group> queues = [
                SELECT Id, Email
                FROM Group
                WHERE DeveloperName LIKE '%_Support%'
                AND Type = 'Queue'
        ];
        //convert to Map
        Map<String, Id> queueEmailQueueIdMap = new Map<String, Id>();
        for (Group queue : queues) {
            queueEmailQueueIdMap.put(queue.Email, queue.Id);
        }
        return queueEmailQueueIdMap;
    }

    private static Map<String, String> getOrgWideEmailsMap() {
        //selects list of emails
        List<OrgWideEmailAddress> addresses = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
        ];
        //convert to Map
        Map<String, String> emailAddressDisplayNameMap = new Map<String, String>();
        for (OrgWideEmailAddress address : addresses) {
            emailAddressDisplayNameMap.put(address.Address, address.DisplayName);
        }
        return emailAddressDisplayNameMap;
    }

    /*******************************************************************************
    *  Name            : inputRecipientsAsToEmailAddressesInEmailMessage(List<EmailMessage> messages)
    *  Summary         : find email addresses in email subject to save them as additional recipients
    *  CreatedDate     : 13/09/2019
    *  Parameters      : List<EmailMessage> messages
    *  Returns         : void
    ******************************************************************************/
    public static void inputRecipientsAsToEmailAddressesInEmailMessage(List<EmailMessage> messages) {
        for (EmailMessage message : messages) {
            if (message.Incoming && String.valueOf(message.ParentId).substring(0, 3) == '500') {
                Boolean isRecipientsExist = isAdditionalRecipientsExistInSubject(message.Subject);
                if (isRecipientsExist) {
                    List<String> emailsInSubject = message.Subject.split('; ');
                    String additionalRecipients = emailsInSubject.get(1).substringBetween('(', ')').replace(',', ';');
                    // extract emails addresses if subject contains recipients addresses (Exchange server added them into it)
                    if (additionalRecipients.contains('@')) {
                        message.ToAddress = message.ToAddress + '; ' + additionalRecipients; //add new incoming recipients
                        message.Subject = message.Subject.remove(message.Subject.substringAfter(('; '))).removeEnd('; '); // remove recipients from the subject
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : isAdditionalRecipientsExistInSubject(String subject)
    *  Summary         : check if subject contain additional recipients substring
    *  CreatedDate     : 17/09/2019
    *  Parameters      : String subject
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean isAdditionalRecipientsExistInSubject(String subject) {
        List<String> emailsInSubject = subject != null ? subject.split('; ') : new List<String>();
        if (emailsInSubject.size() > 1) {
            String substring = emailsInSubject.get(1).substringBetween('(', ')');
            if (substring != null) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /*******************************************************************************
    *  Name            : setOwnerByEmailBody(List<EmailMessage> emailList)
    *  Summary         : related case updates. For Email-to-case. 
    *                        1. Automatic assignement according key words
    *                        2. Setting High value in Priority field according mapping
    *                        3. Linking to Account in case with multiple contacts assigned to 1 account
    *  CreatedDate     : 13/11/2019
    *  Parameters      : List<EmailMessage> emailList
    *  Returns         : void
    ******************************************************************************/
    public static void updateRelatedCases(List<EmailMessage> emailList) {
        try{
            Map<Id, Group> targetQueues = getTargetQueuesMap();
            Map<Id, Group> caseOwnerQueueList = getQueueMap();
            Map<String, String> keyWordMap = getKeyWordMap();
            Map<Id,Case> caseMap = getRelatedCaseMap(emailList);
            Map<String,String> userNameMap = getUserNameMap(keyWordMap);
            List<Contact> relatedContactList = getRelatedContactList(emailList);
            List<String> emailAddresses = prepareEmailAddressList();
            List<ERP__c> relatedERPList = getRelatedERPList(relatedContactList);
            Map<String, String> messageToAccountIdMap = getAccountsByEmailSubject(emailList);
            List<Support_Topic_Subtopic_Mapping__mdt> creditReminderMapping = getCreditReminderTopicMapping();

            for (EmailMessage message : emailList) {
                if( !String.isEmpty(message.ParentId) && caseMap.get(message.ParentId)!=null && message.Incoming && String.valueOf(message.ParentId).substring(0, 3) == '500'){
                    //from address = email address of owner(queue) of new Case
                    if(caseMap.get(message.ParentId) != null && caseOwnerQueueList.get(caseMap.get(message.ParentId).OwnerId) != null &&
                    message.FromAddress == caseOwnerQueueList.get(caseMap.get(message.ParentId).OwnerId).Email){
                        caseMap.get(message.ParentId).Status = 'Closed';
                        caseMap.get(message.ParentId).AccountId = messageToAccountIdMap.get(message.Id);
                        setTopicAndSubtopc(caseMap.get(message.ParentId), creditReminderMapping);
                        // caseMap.get(message.ParentId).Topic__c = 'Credit';
                        // caseMap.get(message.ParentId).Sub_topic__c = 'Dunning letters';
                    }
                    if (targetQueues.containsKey(caseMap.get(message.ParentId).OwnerId)) {
                        for(String keyword : keyWordMap.keySet()){
                            if(message.HtmlBody.contains(keyword) || message.TextBody.contains(keyword)){
                                caseMap.get(message.ParentId).OwnerId = userNameMap.get(keyWordMap.get(keyword));
                            }
                        }
                    }
                    if(emailAddresses.contains(message.FromAddress.toLowerCase())) {
                        caseMap.get(message.ParentId).Priority = 'High';
                    }
                    setRelatedAccountAndERP(message, caseMap, relatedContactList, relatedERPList);
                }
            }
            update caseMap.values();
        }catch(Exception e){
            System.debug('ERROR');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());            
        }
    }

    /*******************************************************************************
    *  Name            : getKeyWordMap()
    *  Summary         : return map keyword => user
    *  CreatedDate     : 14/11/2019
    *  Parameters      : Map<String, String>
    *  Returns         : void
    ******************************************************************************/    
    private static Map<String, String> getKeyWordMap(){
        return new Map<String, String>{
            'Ruzickova'=>'Hana Růžičková',
            'Růžičková'=>'Hana Růžičková',
            'Hurtova'=>'Nikola Hurtová',
            'Hurtová'=>'Nikola Hurtová',
            'Fedorisinova'=>'Kristýna Fedorišinová',
            'Fedorišinová'=>'Kristýna Fedorišinová',
            'Valenta'=>'Vlastimil Valenta',
            'Ulrich'=>'Michal Ulrich',
            'Decsiova'=>'Dalma Decsiová',
            'Decsiová'=>'Dalma Decsiová'
        };
    }

    private static List<String> prepareEmailAddressList() {
        List<String> emailAddresses = new List<String>();

        List<High_Priority_Email_Address__c> priorityFromAddressList = [
            SELECT  Id, 
                    Email_Address__c
            FROM    High_Priority_Email_Address__c
        ];

        for(High_Priority_Email_Address__c emailAddress: priorityFromAddressList) {
            emailAddresses.add(emailAddress.Email_Address__c.toLowerCase());
        }

        return emailAddresses;
    }

    private static Map<Id, Group> getTargetQueuesMap() {
        Map<Id, Group> targetQueues = new Map<Id, Group>([
            SELECT  Id, 
                    Name, 
                    Email 
            FROM    Group 
            WHERE   Type = 'Queue' 
            AND     (Email = 'kredit@ccs.sk' 
            OR      Email = 'kredit@ccs.cz')
        ]);
        return targetQueues;
    }

    private static Map<Id, Group> getQueueMap() {
        Map<Id, Group> targetQueues = new Map<Id, Group>([
            SELECT  Id,
                    Name,
                    Email
            FROM    Group
            WHERE   Type = 'Queue'
            AND     Name LIKE '%Credit%'
        ]);
        return targetQueues;
    }

    private static Map<Id, Case> getRelatedCaseMap(List<EmailMessage> emailList) {
        List<Id> emailParentIds = new List<Id>();
        for(EmailMessage message : emailList){
            emailParentIds.add(message.ParentId);
        }
        Map<Id,Case> caseMap = new Map<Id, Case>([
            SELECT Id,
                    OwnerId,
                    AccountId,
                    Account.Name,
                    ERP__c,
                    RecordTypeId,
                    Description
            FROM Case
            WHERE Id IN: emailParentIds
            AND OwnerId != NULL
            AND Status != 'Closed'
        ]);
        return caseMap;
    }

    private static Map<String, String> getUserNameMap(Map<String, String> keyWordMap) {
        Map<String,String> userNameMap = new Map<String,String>();
        List<User> agentList = [
            SELECT  Id,
                    Name
            FROM    User
            WHERE   Name IN: keyWordMap.values()
        ];
        for(User agent : agentList){
            userNameMap.put(agent.Name, agent.Id);
        }
        return userNameMap;
    }

    private static List<Contact> getRelatedContactList(List<EmailMessage> emailList) {
        List<String> internalAccountNames = new List<String>{'FLEETCOR INTERNAL USE ONLY', 'SHELL INTERNAL USE ONLY', 'CCS INTERNAL USE ONLY'};
        List<String> emailAddressList = new List<String>();
        for(EmailMessage message : emailList) {
            emailAddressList.add(message.FromAddress);
        }
        List<Contact> contactList = [
            SELECT  Email,
                    ERP__c,
                    ERP__r.Account__c,
                    ERP__r.Account__r.Name,
                    AccountId,
                    Account.Name
            FROM    Contact
            WHERE   Email IN: emailAddressList
            AND Account.Name NOT IN : internalAccountNames
        ];
        return contactList;
    }

    private static void setRelatedAccountAndERP(EmailMessage message, Map<Id, Case> caseMap, List<Contact> relatedContactList, List<ERP__c> relatedERPList) {
        Case parentCase = caseMap.get(message.ParentId);
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> erpIdSet = new Set<Id>();
        Set<Id> relatedToAccountERPSet = new Set<Id>();
        for(Contact relatedContact : relatedContactList) {
            if( message.FromAddress.equals(relatedContact.Email) ) {
                //erp on contact is empty
                if( String.isEmpty(relatedContact.ERP__c)) {
                    accountIdSet.add(relatedContact.AccountId);
                    //loop through all erps related to Account
                    for(ERP__c erp : relatedERPList) {
                        if(erp.Account__c == relatedContact.AccountId) {
                            erpIdSet.add(erp.Id);
                        }
                    }
                // erp on contact is not empty
                } else {
                    relatedToAccountERPSet.add(relatedContact.ERP__c);
                    if(String.isNotEmpty(relatedContact.ERP__r.Account__c)) {
                        accountIdSet.add(relatedContact.ERP__r.Account__c);
                    }
                }
            }
        }
        //set AccountId
        if( accountIdSet.size() == 1 && String.isEmpty(parentCase.AccountId) ) {
            parentCase.AccountId = new List<Id>(accountIdSet).get(0);
        }
        //set ERP
        if(parentCase.RecordTypeId == supportCCSRecordTypeId) {
            if( erpIdSet.size() == 1) {
                parentCase.ERP__c = new List<Id>(erpIdSet).get(0);
            } else if (relatedToAccountERPSet.size() == 1) {
                parentCase.ERP__c = new List<Id>(relatedToAccountERPSet).get(0);
            }
        }
    }

    private static List<ERP__c> getRelatedERPList(List<Contact> contactList) {
        List<Id> relatedAccountIdList = new List<Id>();
        for(Contact c : contactList) {
            relatedAccountIdList.add(c.AccountId);
        }
        List<ERP__c> relatedERPList = [
            SELECT  Account__c
            FROM    ERP__c
            WHERE   Account__c IN : relatedAccountIdList
        ];
        return relatedERPList;
    }

    private static Map<Id, Case> getOpenChildCaseMap(Set<Id> parentCaseList) {
        Map<Id, Case> openChildCaseMap = new Map<Id, Case>();
        List<Case> openChildCaseList = [
            SELECT  Id,
                    ParentId
            FROM    Case
            WHERE   ParentId IN: parentCaseList
            AND     Status != 'Closed'
        ];
        for(Case openCase: openChildCaseList) {
            openChildCaseMap.put(openCase.ParentId, openCase);
        }
        return openChildCaseMap;
    }


    private static Map<String, String> getAccountsByEmailSubject(List<EmailMessage> emailMessageList) {

        Map<String, String> gfnNumberMap = new Map<String, String>();
        Map<String, String> messageToAccountMap = new Map<String, String>();

        for(EmailMessage message : emailMessageList) {
            if(String.isNotEmpty(message.Subject)) {
                gfnNumberMap.put(message.Subject.substringAfterLast(',').replace(' ', '').replace('.', ''), message.Id);
            }
        }
        List<Account> accountList = [
            SELECT  Id,
                    GFN_Nr__c
            FROM    Account
            WHERE   Gfn_Nr__c IN: gfnNumberMap.keySet()
            AND     Gfn_Nr__c != NULL
        ];

        for(Account acc : accountList) {
            messageToAccountMap.put(gfnNumberMap.get(acc.Gfn_Nr__c), acc.Id);
        }
        return messageToAccountMap;
    }


    private static List<Support_Topic_Subtopic_Mapping__mdt> getCreditReminderTopicMapping() {
        return [ SELECT Active__c,
                        DeveloperName,
                        Field_Type__c,
                        Id,
                        Label,
                        Picklist_Value__c,
                        Parent_Picklist_Value__c,
                        Priority__c,
                        QualifiedApiName,
                        Search_Word__c
                FROM Support_Topic_Subtopic_Mapping__mdt
                WHERE Active__c = TRUE AND Mapping_group__c = : 'Credit Reminders' AND Field_Type__c = : 'Subtopic'
                ORDER BY Priority__c 
                ];
    }


    private static void setTopicAndSubtopc(Case c, List<Support_Topic_Subtopic_Mapping__mdt> creditReminderMapping) {
        for(Support_Topic_Subtopic_Mapping__mdt mapping : creditReminderMapping) {
            if(c.Description.contains(mapping.Search_Word__c)) {
                c.Topic__c = mapping.Parent_Picklist_Value__c;
                c.Sub_topic__c = mapping.Picklist_Value__c;
                break;
            }
        }
    }
}