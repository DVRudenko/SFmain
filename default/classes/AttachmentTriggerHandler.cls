public class AttachmentTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean isCreditFactory = false;

    /*******************************************************************************
    *  Name            : processAttachmentToClosedCase()
    *  Summary         : process attachment which was send to Support case with status Closed
    *  CreatedDate     : 25/07/2019
    *  Parameters      : List<Attachment> attachments
    *  Returns         : void
    ******************************************************************************/
//    public static void processAttachmentToClosedCase(List<Attachment> attachments) {
//        try {
//            //Map with Id and EmailMessage related to message send to Closed case
//            Map<Id, EmailMessage> oldIdMessageMap = getClosedCaseEmailMessages(attachments);
//            //Map with Id and Case related to new case created from original case
//            Map<Id, Case> newIdCaseMap = getNewCasesWithNewMessageMap(oldIdMessageMap);
//            List<Attachment> attachmentsToBeInserted = new List<Attachment>();
//            EmailMessage respectiveOldMessage;
//            for (Attachment attachment : attachments) {
//                respectiveOldMessage = oldIdMessageMap.get(attachment.ParentId);
//                //if appropriate original message for attachment exist
//                if (respectiveOldMessage != null && respectiveOldMessage.ParentId != null) {
//                    //search for related new case with new email message
//                    for (Case newCase : newIdCaseMap.values()) {
//                        //if found, add copy of original attachment to related new email message
//                        if (newCase.ParentId.equals(respectiveOldMessage.ParentId)) {
//                            Attachment attachmentCopy = attachment.clone(false, true, true, true);
//                            attachmentCopy.ParentId = newCase.EmailMessages.get(0).Id;
//                            attachmentsToBeInserted.add(attachmentCopy);
//                            break;
//                        }
//                    }
//                }
//            }
//            insert attachmentsToBeInserted;
//        } catch (Exception e) {
//            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
//        }
//    }
    /*******************************************************************************
    *  Name            : getClosedCaseEmailMessages()
    *  Summary         : gets original email messages which are related to incoming attachments
    *  CreatedDate     : 25/07/2019
    *  Parameters      : List<Attachment> attachments
    *  Returns         : Map<Id, EmailMessage> - Map with Id of message and message itself
    ******************************************************************************/
//    private static Map<Id, EmailMessage> getClosedCaseEmailMessages(List<Attachment> attachments) {
//        //create a Set of unique email message IDs related to incoming attachments
//        Set<Id> parentIds = new Set<Id>();
//        for (Attachment attachment : attachments) {
//            parentIds.add(attachment.ParentId);
//        }
//        //return a Map based on Set with original messages IDs and message objects which related to incoming attachments
//        return new Map<Id, EmailMessage>([
//                SELECT Id, ParentId, Subject
//                FROM EmailMessage
//                WHERE Id IN :parentIds
//                AND Incoming = TRUE
//                AND Parent.RecordType.DeveloperName = :GlobalUtils.CaseRecordTypes.Support.name()
//                AND Parent.Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed)
//        ]);
//    }
    /*******************************************************************************
    *  Name            : getNewCasesWithNewMessageMap()
    *  Summary         : gets original email messages which are related to incoming attachments
    *  CreatedDate     : 25/07/2019
    *  Parameters      : Map<Id, EmailMessage> idMessageMap - Map with Id original of message and message itself
    *  Returns         : Map<Id, Case> - Map with Id of new case and case itself
    ******************************************************************************/
//    private static Map<Id, Case> getNewCasesWithNewMessageMap(Map<Id, EmailMessage> oldIdMessageMap) {
//        //create a Set of unique case IDs related to original messages
//        Set<Id> closedCaseIds = new Set<Id>();
//        for (EmailMessage message : oldIdMessageMap.values()) {
//            closedCaseIds.add(message.ParentId);
//        }
//        //return a Map based on Set with new case IDs and new cases objects which related to original messaged
//        return new Map<Id, Case>([
//                SELECT Id, ParentId, (
//                        SELECT Id, ParentId, Subject
//                        FROM EmailMessages
//                        WHERE Incoming = TRUE
//                        ORDER BY CreatedDate DESC
//                        LIMIT 1
//                )
//                FROM Case
//                WHERE RecordType.DeveloperName = :GlobalUtils.CaseRecordTypes.Support.name()
//                AND Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new)
//                AND ParentId IN :closedCaseIds
//                ORDER BY CreatedDate DESC
//        ]);
//    }

    /*******************************************************************************
    *  Name            : creditFactoryDeleteReport(List<Attachment> oldList)
    *  Summary         :  Display error if report has been deleted by non-admin or non-credit user
    *  CreatedDate     : 01/08/2017
    *  Parameters      : oldList - old trigger list of Attachments
    *  Returns         : void
    ******************************************************************************/
    public static void creditFactoryDeleteReport(List<Attachment> oldList) {
        if (isCreditFactory) return;
        Map<Id, Profile> availableProfilesMap = new Map<Id, Profile>([
                SELECT Id
                FROM Profile
                WHERE Name IN :availableProfileNamesSet
        ]);
        for (Attachment attachment : oldList) {
            if (attachment.Name == 'CrefoReport.pdf' || attachment.Name == 'CreditsafeReport.pdf' || attachment.Name == 'CofaceReport.pdf' ||
                    attachment.Name == 'CrifReport.pdf' || attachment.Name == 'CrediconnectReport.pdf' || attachment.Name == 'SchufaReport.pdf') {
                if (! availableProfilesMap.containsKey(UserInfo.getProfileId())) {
                    attachment.addError('Unable to delete CreditFactory report.');
                }
            }
        }
    }

    public static Set<String> availableProfileNamesSet = new Set<String>{
            'API Only',
            'In-house Developer',
            'System Administrator', //TODO: remove this
            'E2E Profile',
            'E2E PL Profile',
            'Credit',
            'Administrador del sistema',
            'Administrateur système',
            'Amministratore del sistema',
            'Systemadministratör',
            'Administrador do sistema',
            'Systeembeheerder',
            'Systemadministrator',
            'Järjestelmän pääkäyttäjä',
            'Системный администратор',
            'Správce systému',
            'Administrator systemu',
            'Rendszergazda'
    };

    /*******************************************************************************
*  Name            : updateActivitiesWithAttachmentExist(List<Attachment> oldAttachments, List<Attachment> newAttachments)
*  Summary         : update field  Task.Is_Exist_Attachment__c , "True" if Task had attachment
*  CreatedDate     : 14/12/2017
*  Returns         : void
******************************************************************************/
    public static void updateActivitiesWithAttachmentExist(List<Attachment> oldAttachments, List<Attachment> newAttachments) {
        Set<Id> parentTaskIds = new Set<id>();
        Set<Id> parentEventIds = new Set<id>();
        if (oldAttachments != null) {
            for (Attachment attachment : oldAttachments) {
                if (String.valueOf(attachment.ParentId).startsWith('00T')) {
                    parentTaskIds.add(attachment.parentId);
                }
                if (String.valueOf(attachment.ParentId).startsWith('00U')) {
                    parentEventIds.add(attachment.parentId);
                }
            }
        }
        if (newAttachments != null) {
            for (Attachment attachment : newAttachments) {
                if (String.valueOf(attachment.ParentId).startsWith('00T')) {
                    parentTaskIds.add(attachment.parentId);
                }
                if (String.valueOf(attachment.ParentId).startsWith('00U')) {
                    parentEventIds.add(attachment.parentId);
                }
            }
        }
        if (parentTaskIds.size() != 0) {
            List<Task> parentTaskList = [
                    SELECT id, Attachments_Exist__c, (SELECT id FROM Attachments)
                    FROM Task
                    WHERE id IN :parentTaskIds AND RecordType.Name = 'Russian Sales'
            ];
            if (parentTaskList.size() != 0) {
                List<Task> taskForUpdate = new List<Task>();
                for (Task task : parentTaskList) {
                    if (task.Attachments.size() != 0 && task.Attachments_Exist__c != true) {
                        task.Attachments_Exist__c = true;
                        taskForUpdate.add(task);
                    } else if (task.Attachments.size() == 0 && task.Attachments_Exist__c != false) {
                        task.Attachments_Exist__c = false;
                        taskForUpdate.add(task);
                    }
                }
                if (taskForUpdate.size() != 0) {
                    update taskForUpdate;
                }
            }
        }

        if (parentEventIds.size() != 0) {
            List<Event> parentEventList = [
                    SELECT id, Attachments_Exist__c, (SELECT id FROM Attachments)
                    FROM Event
                    WHERE id IN :parentEventIds
                    AND RecordType.Name = 'Russian Sales Event'
                    AND (Event_Status__c = null OR Event_Status__c = 'In Progress')
            ];
            if (parentEventList.size() != 0) {
                List<Event> eventForUpdate = new List<Event>();
                for (Event event : parentEventList) {
                    if (event.Attachments.size() != 0 && event.Attachments_Exist__c != true) {
                        event.Attachments_Exist__c = true;
                        eventForUpdate.add(event);
                    } else if (event.Attachments.size() == 0 && event.Attachments_Exist__c != false) {
                        event.Attachments_Exist__c = false;
                        eventForUpdate.add(event);
                    }
                }
                if(eventForUpdate.size() != 0){
                    update eventForUpdate;
                }
            }
        }

    }
}