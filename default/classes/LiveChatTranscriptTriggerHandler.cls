public class LiveChatTranscriptTriggerHandler {


    /*******************************************************************************
    *  Name            : setLookupFields(List<LiveChatTranscript> newList)
    *  Summary         : set AccountId and GFN__c field
    *  CreatedDate     : 26.04.2021
    *  Returns         : void
    ******************************************************************************/
    public static void setLookupFields(List<LiveChatTranscript> newList, Map<Id, LiveChatTranscript> oldMap) {
        List<Id> relatedContactIdList = new List<Id>();
        List<Id> relatedAccountIdList = new List<Id>();
        for(LiveChatTranscript transcript : newList) {
            relatedContactIdList.add(transcript.ContactId);
            relatedAccountIdList.add(transcript.AccountId);
            transcript.Country__c = transcript.ContactId;
        }

        List<AccountContactRelation> acoountContactRelationList = [
            SELECT  AccountId,
                    ContactId,
                    Contact.ERP__c,
                    Contact.ERP__r.Account__c
            FROM    AccountContactRelation
            WHERE   ContactId IN : relatedContactIdList
            AND     ContactId != NULL
        ];

        for(AccountContactRelation relation : acoountContactRelationList) {
            relatedAccountIdList.add(relation.AccountId);
        }

        List<ERP__c> erpList = [
            SELECT  Id,
                    Account__c
            FROM    ERP__c
            WHERE   Account__c IN : relatedAccountIdList
            AND     Account__c != NULL
        ];
        
        for(LiveChatTranscript transcript : newList) {
            //set null in ContactId field if ICO is filled and account is found
            if(transcript.AccountId != null && String.isNotEmpty(transcript.Tax_ID__c)) {
                transcript.ContactId = null;
                setErpField(transcript, erpList);
            }
            if(transcript.ContactId != null && oldMap.get(transcript.Id).ContactId == null){
                Set<Id> accountIdSet = new Set<Id>();
                for(AccountContactRelation relation : acoountContactRelationList) {
                    if(transcript.ContactId == relation.ContactId) {
    
                        if(transcript.GFN__c == null && relation.Contact != null) {
                            transcript.GFN__c = relation.Contact.ERP__c;
                        }
    
                        if(transcript.AccountId == null) {
                            if(transcript.GFN__c != null && relation.Contact.ERP__r.Account__c != null) {
                                transcript.AccountId = relation.Contact.ERP__r.Account__c;
                            }
                            else {
                                // transcript.AccountId = relation.AccountId;
                                accountIdSet.add(relation.AccountId);
                            }
                        }
                    }
                }
                if(accountIdSet.size() == 1 && transcript.AccountId == null) {
                    transcript.AccountId = new List<Id>(accountIdSet).get(0);
                }
                setErpField(transcript, erpList);
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateE2EChatFieldsInOpportunity(List<LiveChatTranscript> newList)
    *  Summary         : update Opportunities E2E_Chat__c, E2E_Agent_Message_Count__c, E2E_Visitor_Message_Count__c fields
    *                    with relevant information form LiveChatTranscript
    *  CreatedDate     : 10.09.2018
    *  ModifiedDate    : 22.10.2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void updateE2EChatFieldsInOpportunity(List<LiveChatTranscript> newList) {
        try {
            Set<Id> opportunityIds = new Set<Id>();
            for ( LiveChatTranscript chat : newList ) {
                if ( chat.Opportunity__c != null && chat.Status == 'Completed' ) {
                    opportunityIds.add(chat.Opportunity__c);
                }
            }

            if ( !opportunityIds.isEmpty() ) {
                updateChatFieldsInFuture(opportunityIds);
            }

        } catch (Exception e){
            String notificationMessage = '<br/>LiveChatTranscriptTriggerHandler Exception: updateE2EChatFieldsInOpportunity ' + String.valueOf(e.getMessage());
            System.debug(String.valueOf(e.getMessage()));
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    @future
    private static  void updateChatFieldsInFuture(Set<Id> opportunityIds){
        try {
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            for (Opportunity oppToUpdate : [
                    SELECT Id, E2E_Chat__c, E2E_Agent_Message_Count__c, E2E_Visitor_Message_Count__c, E2E_Sales_Type__c,
                    ( SELECT Id, Name, Type__c, Mode_of_initialization__c, VisitorMessageCount, OperatorMessageCount  FROM Live_Chat_Transcripts__r )
                    FROM Opportunity
                    WHERE Id IN :opportunityIds AND IsClosed != true
            ]) {
                List<LiveChatTranscript> liveChatTranscripts = oppToUpdate.Live_Chat_Transcripts__r;
                if (liveChatTranscripts.size() != 0) {
                    Boolean manualChatExist = false;
                    Boolean autoChatExist = false;
                    Integer visitorMessageCount = 0;
                    Integer operatorMessageCount = 0;
                    String newChatUsage = '';
                    //Find Chat with messages
                    LiveChatTranscript firsActiveChat;
                    for (Integer i = 0; i <= liveChatTranscripts.size() - 1; i ++) {
                        if (liveChatTranscripts.get(i).VisitorMessageCount > 0) {
                            if (firsActiveChat == null) {
                                firsActiveChat = liveChatTranscripts.get(i);
                            } else if (liveChatTranscripts.get(i).Name < firsActiveChat.Name) {
                                firsActiveChat = liveChatTranscripts.get(i);
                            }
                            visitorMessageCount += liveChatTranscripts.get(i).VisitorMessageCount;
                        }
                        if (liveChatTranscripts.get(i).OperatorMessageCount > 0) {
                            operatorMessageCount += liveChatTranscripts.get(i).OperatorMessageCount;
                        }
                        if (liveChatTranscripts.get(i).Mode_of_initialization__c == 'manual') {
                            manualChatExist = true;
                        }
                        if (liveChatTranscripts.get(i).Mode_of_initialization__c == 'automatical') {
                            autoChatExist = true;
                        }
                        system.debug(liveChatTranscripts.get(i).Name+ '  operator='+operatorMessageCount + '    ' + 'visitor='+visitorMessageCount);
                    }

                    if (firsActiveChat != null) {
                        if (firsActiveChat.Mode_of_initialization__c == 'manual') {
                            oppToUpdate.E2E_Chat__c = 'initiated manual';
                        } else if (firsActiveChat.Mode_of_initialization__c == 'automatical') {
                            newChatUsage = 'auto-replied';
                        }
                    } else if (manualChatExist) {
                        newChatUsage = 'initiated manual';
                    } else if (autoChatExist) {
                        newChatUsage = 'auto-not replied';
                    }

                    if (oppToUpdate.E2E_Chat__c != newChatUsage ||
                            oppToUpdate.E2E_Visitor_Message_Count__c != visitorMessageCount ||
                            oppToUpdate.E2E_Agent_Message_Count__c != operatorMessageCount) {
                        if (newChatUsage != '') {
                            oppToUpdate.E2E_Chat__c = newChatUsage;
                        }
                        oppToUpdate.E2E_Visitor_Message_Count__c = visitorMessageCount;
                        oppToUpdate.E2E_Agent_Message_Count__c = operatorMessageCount;
                        if(!opportunitiesToUpdate.contains(oppToUpdate)){
                            opportunitiesToUpdate.add(oppToUpdate);
                        }
                    }

                    if (oppToUpdate.E2E_Visitor_Message_Count__c != 0 && oppToUpdate.E2E_Sales_Type__c == 'Чистый e2e') {
                        oppToUpdate.E2E_Sales_Type__c = 'Чистый e2e + помощь КЦ';
                        if(!opportunitiesToUpdate.contains(oppToUpdate)){
                            opportunitiesToUpdate.add(oppToUpdate);
                        }
                    }
                }
            }
            if (! opportunitiesToUpdate.isEmpty()) {
                System.debug('DEBUG ******* opportunitiesToUpdate' + opportunitiesToUpdate);
                update opportunitiesToUpdate;
            }
        } catch (Exception e){
            String notificationMessage = '<br/>LiveChatTranscriptTriggerHandler Exception: updateChatFieldsInFuture ' + String.valueOf(e.getMessage());
            System.debug(String.valueOf(e.getMessage()));
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }


    private static void setErpField(LiveChatTranscript transcript, List<ERP__c> erpList) {
        if(transcript.GFN__c == null) {
            Set<Id> relatedErpSet = new Set<Id>();
            for(ERP__c erp : erpList) {
                if(erp.Account__c == transcript.AccountId) {
                    relatedErpSet.add(erp.Id);
                }
            }
            if(relatedErpSet.size() == 1) {
                transcript.GFN__c = new List<Id>(relatedErpSet).get(0);
            }
        }
    }

}