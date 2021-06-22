public class ContentDocumentLinkHandler {

    //STCP1-434
    /*******************************************************************************
    *  Name            : processAttachmentToClosedCase()
    *  Summary         : process attachments which was send to Support case with status Closed
    *  CreatedDate     : 26/09/2019
    *  Parameters      : List<ContentDocumentLink> documentLinks - links to attachments
    *  Returns         : void
    ******************************************************************************/
    public static void processAttachmentsToClosedCase(List<ContentDocumentLink> documentLinks) {
        try {
            //Map with Id and EmailMessage related to message send to Closed case
            Map<Id, EmailMessage> oldIdMessageMap = getClosedCaseEmailMessages(documentLinks);
            //if appropriate original messages for support closed case with attachments found, continue
            if ( !oldIdMessageMap.isEmpty()) {
                //New cases list
                List<Case> newCases = getNewCases(oldIdMessageMap);
                //if new created cases linked to old ones found, continue
                if ( !newCases.isEmpty()) {
                    List<ContentDocumentLink> documentLinksToBeInserted = new List<ContentDocumentLink>();
                    EmailMessage respectiveOldMessage;
                    for (ContentDocumentLink documentLink : documentLinks) {
                        respectiveOldMessage = oldIdMessageMap.get(documentLink.LinkedEntityId);
                        //if appropriate original message for attachment exist
                        if (respectiveOldMessage != null && respectiveOldMessage.ParentId != null) {
                            //search for related new case with new email message
                            for (Case newCase : newCases) {
                                //if found, add copy of original attachment link to related new case
                                if (newCase.ParentId.equals(respectiveOldMessage.ParentId)) {
                                    ContentDocumentLink documentLinkCopy = documentLink.clone(false, true, true, true);
                                    documentLinkCopy.LinkedEntityId = newCase.Id;
                                    documentLinkCopy.ContentDocumentId = documentLink.ContentDocumentId;
                                    documentLinksToBeInserted.add(documentLinkCopy);
                                    break;
                                }
                            }
                        }
                    }
                    insert documentLinksToBeInserted;
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : getClosedCaseEmailMessages()
    *  Summary         : gets original email messages which are related to incoming attachment links
    *  CreatedDate     : 26/09/2019
    *  Parameters      : List<ContentDocumentLink> documentLinks - links to attachments
    *  Returns         : Map<Id, EmailMessage> - Map with Id of message and message itself
    ******************************************************************************/
    private static Map<Id, EmailMessage> getClosedCaseEmailMessages(List<ContentDocumentLink> documentLinks) {
        //create a Set of unique email message IDs related to incoming links
        Set<Id> parentIds = new Set<Id>();
        for (ContentDocumentLink documentLink : documentLinks) {
            parentIds.add(documentLink.LinkedEntityId);
        }
        //return a Map based on Set with original messages IDs and message objects which related to incoming links
        return new Map<Id, EmailMessage>([
                SELECT Id, ParentId
                FROM EmailMessage
                WHERE Id IN :parentIds
                AND Incoming = TRUE
                AND (Parent.RecordType.DeveloperName = :GlobalUtils.CaseRecordTypes.Support.name() 
                OR  Parent.RecordType.DeveloperName = :GlobalUtils.CaseRecordTypes.Support_CCS.name())
                AND Parent.Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed)
        ]);
    }

    /*******************************************************************************
    *  Name            : getNewCases()
    *  Summary         : gets just created new cases to which attachments must be linked
    *  CreatedDate     : 26/09/2019
    *  Parameters      : Map<Id, EmailMessage> oldIdMessageMap - Map with Id of original message and message itself
    *  Returns         : List<Case> - new cases
    ******************************************************************************/
    private static List<Case> getNewCases(Map<Id, EmailMessage> oldIdMessageMap) {
        //create a Set of unique case IDs
        Set<Id> closedCaseIds = new Set<Id>();
        for (EmailMessage message : oldIdMessageMap.values()) {
            closedCaseIds.add(message.ParentId);
        }
        //return a List of new cases
        return new List<Case>([
                SELECT Id, ParentId
                FROM Case
                WHERE (RecordType.DeveloperName = :GlobalUtils.CaseRecordTypes.Support.name()
                OR     RecordType.DeveloperName = :GlobalUtils.CaseRecordTypes.Support_CCS.name())
                AND (Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new)
                OR  Status= :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_updated)
                OR  Status= :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting)
                OR  Status= :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.customer_waiting)
                OR  Status= :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.customer_updated))
                AND ParentId IN :closedCaseIds
                ORDER BY CreatedDate DESC
        ]);
    }

    /*******************************************************************************
    *  Name            : carnetDeleteCDL()
    *  Summary         : before delete ContentDocumentLink check Opportunity Stagename
    *  CreatedDate     : 22/10/2020
    *  Parameters      :
    *  Returns         :
    *  Author          : INTERCODEC
    ******************************************************************************/
    public static void carnetDeleteCDL(List<ContentDocumentLink> cdlList) {
        Id userProfileId = userinfo.getProfileId();
        Map<Id, ContentDocumentLink> cdlMap = new Map<Id, ContentDocumentLink>();
        Set<Id> oppIds = new Set<Id>();
        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'Carnet' AND sObjectType = 'Opportunity'].Id;
        for(ContentDocumentLink cdl : cdlList){
            //Check if CDL is linked with Opportunity
            if(cdl.LinkedEntityId.getSobjectType() == Opportunity.SObjectType){
                cdlMap.put(cdl.LinkedEntityId, cdl);
            }
        }

        //Get Carnet oppties
        List<Opportunity> oppties = [SELECT Id FROM Opportunity WHERE Id IN :cdlMap.keySet() AND RecordTypeId = :recordTypeId AND StageName = 'Closed Won'];

        if(oppties.size() >= 0){
            Set<Id> allowedProfiles = new Set<Id>();
            List<Carnet_Closed_Won_Files_Allowed_Profiles__c> allProfs = [SELECT Name, Profile_Id__c FROM Carnet_Closed_Won_Files_Allowed_Profiles__c];
            for(Carnet_Closed_Won_Files_Allowed_Profiles__c ap : allProfs){
                allowedProfiles.add(ap.Profile_Id__c);
            }
            for(Opportunity opp : oppties){
                oppIds.add(opp.Id);
            }

            for(ContentDocumentLink cdl : cdlList){
                if(oppIds.contains(cdl.LinkedEntityId) && !allowedProfiles.contains(userProfileId)){
                    cdl.addError(Label.Carnet_Closed_Won_Files_Block_Delete);
                }
            }
        }
    }
}