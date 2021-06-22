public class CaseTriggerHandler {

    private static String supportRecordType = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    private static String supportCcsRecordType = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support_CCS.name());

    private static Support_Topic_Subtopic_Mapping__mdt[] topicMappingSettings;
    private static Support_Topic_Subtopic_Mapping__mdt[] subtopicMappingSettings;

    private static List<Support_Topic_Subtopic_Mapping__mdt> topicLanguageMapping;
    private static List<Support_Topic_Subtopic_Mapping__mdt> subtopicLanguageMapping;
    private static List<Language_Mapping__mdt> languageMapping;

    private static Map<String, String> emailDomainLanguageMap = new Map<String, String> {
            'DE' => 'German',
            'AT' => 'German',
            'FR' => 'French',
            'LU' => 'French',
            'NL' => 'Dutch',
            'CZ' => 'Czech',
            'HU' => 'Hungarian',
            'PL' => 'Polish',
            'SK' => 'Slovak',
            'IT' => 'Italian',
            'UK' => 'English',
            'RU' => 'Russia'
    };


    /*******************************************************************************
    *  Name            : processOfflineChatCase
    *  Summary         : update dascription of case by offline chat page message
    *  CreatedDate     : 15/03/2021
    *  Parameters      : List<Case> cases
    *  Returns         : void
    ******************************************************************************/
    public static void processOfflineChatCase(List<Case> caseList) {
        Boolean isChatCaseInsered = false;
        List<Id> contactIdList = new List<Id>();
        for(Case c : caseList) {
            if(!isChatCaseInsered) {
                isChatCaseInsered = (c.Origin == 'Chat');
            }
            contactIdList.add(c.ContactId);
        }
        if(isChatCaseInsered) { //if chat case are in the insert list
            Map<Id, Contact> contactMap = getContactMap(contactIdList);
            Map<Id, List<ERP__c>> contactIdErpMap = getErpMap(contactMap); 

            for(Case c : caseList) {
                if(c.Origin == 'Chat') {
                    if(String.isNotEmpty(c.Message__c) && String.isEmpty(c.Description)) {
                        c.Description = c.Message__c;
                    }
                    setErpOnChatCase(c, contactMap, contactIdErpMap);
                }
            }   
        }
    }


    /*******************************************************************************
    *  Name            : preventCaseCreationForAutoReplyMessage
    *  Summary         : if email message is autoreply according to keywords case is not created
    *  CreatedDate     : 05/04/2021
    *  Parameters      : List<Case> cases 
    *  Returns         : void
    ******************************************************************************/
    public static void preventCaseCreationForAutoReplyMessage(List<Case> caseList) {
        List<Out_Of_Office_keyword__mdt> keywordList = [
            SELECT  Label
            FROM    Out_Of_Office_keyword__mdt
            LIMIT   10000
        ];
        if(keywordList.size() > 0 ) {
            for(Case newCase : caseList) {
                for(Out_Of_Office_keyword__mdt keyword : keywordList) {
                    if(String.isNotEmpty(newCase.Origin) && newCase.Origin.toLowerCase() == 'email' && (newCase.RecordTypeId == Id.valueOf(supportRecordType) || newCase.RecordTypeId == Id.valueOf(supportCcsRecordType))) {
                        if(newCase.Description.contains(keyWord.Label)) {
                            newCase.addError('The case is ooo auto-reply' + newCase.Subject);
                        }
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : defineCaseTopicAndSubtopic
    *  Summary         : find case topic and subtopic for a case using a mapping custom metadata settings
    *  CreatedDate     : 20/05/2019
    *  Parameters      : List<Case> cases
    *  Returns         : void
    ******************************************************************************/
    public static void defineCaseTopicAndSubtopic(List<Case> cases) {
        try {
            Map<Id, Group> supportQueuesMap = new Map<Id, Group>([
                    SELECT Id, DeveloperName, Email, Name, OwnerId, RelatedId, Type
                    FROM Group
                    WHERE Type = 'Queue' AND (DeveloperName LIKE '%Support%' OR DeveloperName = 'SHELL_Premium' OR DeveloperName LIKE '%Credit%')
            ]);
            System.debug('**** SUPPORT QUEUES MAP ' + supportQueuesMap);
            languageMapping = getLanguageMapping();
            for (Case c : cases) {
                if ((c.RecordTypeId == Id.valueOf(supportRecordType))) {
                    System.debug('**** SUPPORT RECORD TYPE ' + supportRecordType);

                    // Get a current queue from the list by owner Id (owner Id = queue Id)
                    Group supportQueue = supportQueuesMap.get(c.OwnerId);

                    if (supportQueue != null) {

                        if(supportQueue.DeveloperName.contains('Credit')) {
                            defineCaseFields(c, supportQueue, 'Credit');
                        }
                        else {
                            defineCaseFields(c, supportQueue, 'Support');
                        }
                    }
                    else {
                        defineCaseLanguage(null, '', c);
                    }
                } else if ((c.RecordTypeId == Id.valueOf(supportCcsRecordType))) {
                    System.debug('**** SUPPORT RECORD TYPE ' + supportCcsRecordType);

                    // Topic mapping for Mapping for standard support process
                    topicMappingSettings = getGroupMappingSettings('Support CCS', 'Topic');

                    // Subtopic Mapping for standard support process
                    subtopicMappingSettings = getGroupMappingSettings('Support CCS', 'Subtopic');

                    // Get a current queue from the list by owner Id (owner Id = queue Id)
                    Group supportQueue = supportQueuesMap.get(c.OwnerId);

                    if (supportQueue != null) {
                        System.debug('**** SUPPORT QUEUE ' + supportQueue);

                        // // Get a language from a queue Developer name (second element)
                        // String emailDomain = supportQueue.Email.substringAfterLast('.').toUpperCase();
                        // String language = emailDomainLanguageMap.get(emailDomain);
                        String language = defineCaseLanguage(supportQueue, 'Support CCS', c);

                        System.debug('**** LANGUAGE = ' + language);
                        defineCaseTopicAndSubtopicInGroupOfMapping(c, language);
                    }
                    else {
                        String language = defineCaseLanguage(null, '', c);
                    }
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('Exception in CaseTriggerHandler.defineCaseTopicAndSubtopic()', String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : getGroupMappingSettings
    *  Summary         : collect case topic or subtopic for different mapping groups
    *  CreatedDate     : 01/11/2019
    *  Parameters      : String mappingGroup, String fieldType
    *  Returns         : Support_Topic_Subtopic_Mapping__mdt[]
    ******************************************************************************/
    private static Support_Topic_Subtopic_Mapping__mdt[] getGroupMappingSettings(String mappingGroup, String fieldType) {

        return [ SELECT Active__c, DeveloperName, Field_Type__c, Id, Label, Picklist_Value__c,
                Parent_Picklist_Value__c, Priority__c, QualifiedApiName, Search_Word__c
        FROM Support_Topic_Subtopic_Mapping__mdt
        WHERE Active__c = TRUE AND Mapping_group__c = :mappingGroup AND Field_Type__c = :fieldType
        ORDER BY Priority__c ];
    }


    private static List<Language_Mapping__mdt> getLanguageMapping() {
        return [
            SELECT  Label,
                    DeveloperName,
                    Language__c
            FROM    Language_Mapping__mdt
            WHERE   Active__c = TRUE
        ];
    }



    /*******************************************************************************
    *  Name            : defineCaseLanguage
    *  Summary         : defines case language by keyword mapping
    *  Created         : 14/12/2020
    *  Parameters      : List<Case> cases
    *  Returns         : void
    ******************************************************************************/
    private static String defineCaseLanguage(Group supportQueue, String recordTypeName, Case newCase) {
        String language;
        if(recordTypeName == 'Support') {
            // Get a language from a queue Developer name (second element)
            String supportQueueName = supportQueue.DeveloperName;
            List<String> elements = supportQueueName.split('_');
            if(emailDomainLanguageMap.values().contains(elements.get(1))) {
                language = elements.get(0) + '_' + elements.get(1);
                newCase.Language__c = elements.get(1);
            }
        }
        else if(recordTypeName == 'Credit') {
            String supportQueueLabel = supportQueue.Name;
            List<String> elements = supportQueueLabel.split('_');
            language = emailDomainLanguageMap.get(elements.get(0));
            newCase.Language__c = language;
        }        
        else if(recordTypeName == 'Support CCS') {
            // Get a language from a queue Developer name (second element)
            String emailDomain = supportQueue.Email.substringAfterLast('.').toUpperCase();
            language = emailDomainLanguageMap.get(emailDomain);
            newCase.Language__c = language;

        }
        if(String.isEmpty(language)) {
            for(Language_Mapping__mdt word : languageMapping) {
                if(searchKeyword(newCase.Description, word.Label)) {
                    language = word.Language__c;
                    newCase.Language__c = language;
                    break;
                }
            }
        }
        return language;
    }

    
    /*******************************************************************************
    *  Name            : defineCaseTopicAndSubtopicInGroupOfMapping
    *  Summary         : define case Topic and Subtopic in mapping collected by group
    *  CreatedDate     : 01/11/2019
    *  Parameters      : Case currentCase, Group supportQueue
    *  Returns         : void
    ******************************************************************************/
    private static void defineCaseTopicAndSubtopicInGroupOfMapping(Case currentCase, String language){
        if(currentCase.Origin.toLowerCase().replace('-', '') == 'email'){
            // Collect by language searching keywords
            topicLanguageMapping = getMappingByLanguage(language, topicMappingSettings);
            subtopicLanguageMapping = getMappingByLanguage(language, subtopicMappingSettings);

            if ((currentCase.Topic__c == null || currentCase.Sub_topic__c == null)) {
                // Find Subtopic and Topic
                if (currentCase.Description != null) {
                    Boolean isSubtopicFound = isSubtopicFound(currentCase, subtopicLanguageMapping, language);
                    // If a Subtopic wasn't sound look for a Topic
                    if (!isSubtopicFound) {
                        Boolean isTopicFound = isTopicFound(currentCase, topicLanguageMapping, language);
                        if (!isTopicFound) {
                            currentCase.Topic__c = '';
                            currentCase.Sub_topic__c = '';
                        }
                    }
                    System.debug('**** Case topic = ' + currentCase.Topic__c + ', subtopic = ' + currentCase.Sub_topic__c);
                } else {
                    // If we haven't a Description, we can't find a Subtopic. Then find only a Topic.
                    System.debug('**** EMAIL DID NOT HAVE DESCRIPTION');
                    if (currentCase.Subject != null) {
                        Boolean isTopicFound = isTopicFound(currentCase, topicLanguageMapping, language);
                        if (!isTopicFound) {
                            currentCase.Topic__c = '';
                            currentCase.Sub_topic__c = '';
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : getMappingByLanguage
    *  Summary         : collect case topic and subtopic for a case using a mapping custom metadata settings by Language
    *  CreatedDate     : 20/05/2019
    *  Parameters      : String language, Support_Topic_Subtopic_Mapping__mdt[] mappingSettings
    *  Returns         : void
    ******************************************************************************/
    private static Support_Topic_Subtopic_Mapping__mdt[] getMappingByLanguage(String language, Support_Topic_Subtopic_Mapping__mdt[] mappingSettings){
        List<Support_Topic_Subtopic_Mapping__mdt> mappingByLanguage = new List<Support_Topic_Subtopic_Mapping__mdt>();
        for (Support_Topic_Subtopic_Mapping__mdt mappingItem : mappingSettings){
            if(mappingItem.DeveloperName.contains(language)){
                mappingByLanguage.add(mappingItem);
            }
        }
        return mappingByLanguage;
    }

    /*******************************************************************************
    *  Name            : isSubtopicFound
    *  Summary         : find case subtopic for a case
    *  CreatedDate     : 20/05/2019
    *  Parameters      : Case c, List<Support_Topic_Subtopic_Mapping__mdt> subtopicLanguageMapping
    *  Returns         : Boolean
    ******************************************************************************/
    private static Boolean isSubtopicFound(Case c, List<Support_Topic_Subtopic_Mapping__mdt> subtopicLanguageMapping, String language){
        // Get SubTopic
        Boolean isSubtopicFound = false;
        for (Support_Topic_Subtopic_Mapping__mdt subtopicMapping : subtopicLanguageMapping) {
            if (c.Description != null && c.Description.containsIgnoreCase(subtopicMapping.Search_Word__c) &&
                    subtopicMapping.Parent_Picklist_Value__c != null) {
                System.debug('*** CASE DESCRIPTION ' + c.Description + ', SEARCHING WORD = ' + subtopicMapping.Search_Word__c);
                c.Topic__c = subtopicMapping.Parent_Picklist_Value__c;
                c.Sub_topic__c = subtopicMapping.Picklist_Value__c;
                isSubtopicFound = true;
                System.debug('**** FOUNDED KEYWORD FOR SUBTOPIC = ' + subtopicMapping.Search_Word__c);
                break;
            }
        }
        // If a Subtopic wasn't found look for a Topic
        System.debug('**** SUBTOPIC WAS FOUND ' + isSubtopicFound + ' = ' + c.Sub_topic__c);
        return isSubtopicFound;
    }

    /*******************************************************************************
    *  Name            : isTopicFound
    *  Summary         : find case topic for a case
    *  CreatedDate     : 20/05/2019
    *  Parameters      : Case c, List<Support_Topic_Subtopic_Mapping__mdt> subtopicLanguageMapping
    *  Returns         : Boolean
    ******************************************************************************/
    private static Boolean isTopicFound(Case c, List<Support_Topic_Subtopic_Mapping__mdt> topicLanguageMapping, String language){
        // Get Topic
        Boolean isTopicFound = false;
        for (Support_Topic_Subtopic_Mapping__mdt topicMapping : topicLanguageMapping) {
            if (c.Subject != null && c.Subject.containsIgnoreCase(topicMapping.Search_Word__c)) {
                c.Topic__c = topicMapping.Picklist_Value__c;
                isTopicFound = true;
                System.debug('**** FOUNDED KEYWORD FOR SUBTOPIC = ' + topicMapping.Search_Word__c);
                break;
            }
        }
        // If we can't find Subtopic and Topic
        System.debug('**** TOPIC WAS FOUND ' + isTopicFound + ' = ' + c.Topic__c);
        return isTopicFound;
    }

    /*******************************************************************************
    *  Name            : trimEmailAddressesInSupportCaseSubject(List<Case> cases)
    *  Summary         : update case subject to cut off the additional recipients in it
    *  CreatedDate     : 13/11/2019
    *  Parameters      : List<Case> cases
    *  Returns         : void
    ******************************************************************************/
    public static void trimEmailAddressesInSupportCaseSubject(List<Case> cases) {
        try {
            for (Case c : cases) {
                if ((supportRecordType.equals(c.RecordTypeId) || supportCcsRecordType.equals(c.RecordTypeId)) && EmailMessageHandler.isAdditionalRecipientsExistInSubject(c.Subject)) {
                    // remove recipients from the subject
                    c.Subject = c.Subject.remove(c.Subject.substringAfter(('; '))).removeEnd('; ');
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : keywordSearch(String inputString, String keywordPhrase)
    *  Summary         : method for finding keyword phrase in string
    *  Created         : 22/01/2020 by Anton Hrytsavets
    *  Parameters      : inputString - the string in which keyword is found,
                         keywordPhrase - the string which is should be found
    *  Returns         : Boolean, is keyword found
    ******************************************************************************/
    private static Boolean searchKeyword(String inputString, String keywordPhrase) {
        if(inputString != null){
            return Pattern.compile('(?i)\\b' + keywordPhrase + '\\b').matcher(inputString).find();
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : updateFieldsForClonedCases(List<Case> newCases)
    *  Summary         : method updates fields for cloned cases
    *  Created         : 27/01/2020 by Anton Hrytsavets
    *  Parameters      : List<Case> newCases - new Cases
    *  Returns         : void
    ******************************************************************************/
    public static void updateFieldsForClonedCases(List<Case> newCases) {
        for(Case newCase : newCases) {
            if(newCase.isClone()){
                newCase.Subject = newCase.Subject + ' CLONE';
                newCase.ParentId = newCase.getCloneSourceId();
            }
        }
    }

    /*******************************************************************************
    *  Name            : unassignFromInternalAccount(List<Case> newCases)
    *  Summary         : method clean Account field if Account is internal
    *  Created         : 11/06/2020 by Anton Hrytsavets
    *  Parameters      : List<Case> newCases - new Cases
    *  Returns         : void
    ******************************************************************************/
    public static void unassignFromInternalAccount(List<Case> newCases) {
        List<String> internalAccountNames = new List<String>{'FLEETCOR INTERNAL USE ONLY', 'SHELL INTERNAL USE ONLY', 'CCS INTERNAL USE ONLY'};
        Set<Id> internalAccountList = new Map<Id, Account>([
            SELECT  Id
            FROM    Account
            WHERE   Name IN : internalAccountNames
        ]).keySet();

        for(Case newCase : newCases) {
            if(newCase.AccountId != null && newCase.Origin == 'Email' && UserInfo.getName() == 'System' &&
                newCase.ParentId == null && internalAccountList.contains(newCase.AccountId) &&
                ((newCase.RecordTypeId == Id.valueOf(supportRecordType)) || (newCase.RecordTypeId == Id.valueOf(supportCcsRecordType)))) 
            {
                newCase.ContactId = null;
                newCase.AccountId = null;
            }
        }
    }


    private static void defineCaseFields(Case c, Group supportQueue, String mappingType) {
        // Topic mapping for Mapping for standard support process
        topicMappingSettings = getGroupMappingSettings(mappingType, 'Topic');

        // Subtopic Mapping for standard support process
        subtopicMappingSettings = getGroupMappingSettings(mappingType, 'Subtopic');

        System.debug('**** SUPPORT QUEUE ' + supportQueue);

        String language = defineCaseLanguage(supportQueue, mappingType, c);

        System.debug('**** LANGUAGE = ' + language);
        defineCaseTopicAndSubtopicInGroupOfMapping(c, language);
    }


    private static Map<Id, Contact> getContactMap(List<Id> contactIdList) {
        return new Map<Id, Contact>([
            SELECT  Id,
                    AccountId,
                    Erp__c
            FROM    Contact
            WHERE   Id IN: contactIdList
        ]);
    }

    private static Map<Id, List<ERP__c>> getErpMap(Map<Id, Contact> contactMap) {
        List<Id> accountIdList = new List<Id>();
        Map<Id, List<ERP__c>> contactErpMap = new Map<Id, List<ERP__c>>();
        for(Contact contactRecord : contactMap.values()) {
            accountIdList.add(contactRecord.AccountId);
        }
        List<ERP__c> erpList = [
            SELECT	Id,
                    Account__c
            FROM	ERP__c
            WHERE   Account__c IN : accountIdList
        ];
        for(Contact contactRecord : contactMap.values()) {
            for (ERP__c erp : erpList) {
                if (erp.Account__c == contactRecord.AccountId) {
                    if(contactErpMap.get(contactRecord.Id) != null){
                        contactErpMap.get(contactRecord.Id).add(erp);
                    }
                    else {
                        contactErpMap.put(contactRecord.Id, new List<ERP__c>{erp});
                    }
                }
            }
        }
        return contactErpMap;
    }


    private static void setErpOnChatCase(Case c, Map<Id, Contact> contactMap, Map<Id, List<ERP__c>> contactIdErpMap) {
        if(contactMap.get(c.ContactId) != null && contactMap.get(c.ContactId).ERP__c != null) {
            c.ERP__c = contactMap.get(c.ContactId).ERP__c;
        }
        else {
            if(contactIdErpMap.get(c.ContactId) != null && contactIdErpMap.get(c.ContactId).size() == 1) {
                c.ERP__c = contactIdErpMap.get(c.ContactId)[0].Id;
            }
        }
    }
}