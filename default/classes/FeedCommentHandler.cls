public class FeedCommentHandler {

    private static Map<Id, Case> supportCaseIdSupportCaseMap;
    private static Case respectiveSupportCase;
    //feed items related to Support Cases and incoming feed comments
    private static Map<Id, FeedItem> idFeedItemMap;
    private static FeedItem respectiveFeedItem;
    private static Set<Id> supportProfileIds;
    private static Set<String> supportProfileNames = new Set<String>{'Service Agent', 'Service Manager', 'CCS Service Agent', 'CCS Service Manager', 'Retention Agent', 'Retention Manager'};


    /*******************************************************************************
    *  Name            : initRespectiveSupportCases
    *  Summary         : selects cases with Support record type which relate to incoming feedComments
    *  CreatedDate     : 18/06/2019
    *  Parameters      : List<FeedComment> feedComments - incoming feedComments
    *  Returns         : -
    ******************************************************************************/
    public static void initRespectiveSupportCases(List<FeedComment> feedComments) {
        try {
            //create a Set of unique case IDs related to incoming feed comments
            Id caseSupportRecordTypeId = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
            Id caseSupportCCSRecordTypeId = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support_CCS.name());
            Set<Id> ids = new Set<Id>();
            for (FeedComment feedComment : feedComments) {
                ids.add(feedComment.ParentId);
            }
            //return a Map based on Set with case IDs and Case objects which related to incoming feed comments
            supportCaseIdSupportCaseMap = new Map<Id, Case>([
                    SELECT Id, Status
                    FROM Case
                    WHERE Id IN :ids
					AND (RecordTypeId = :caseSupportRecordTypeId
					OR RecordTypeId=:caseSupportCCSRecordTypeId)
            ]);
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : initRespectiveFeedItems
    *  Summary         : selects feed items which refers to related Cases with Support record type and incoming feedComments
    *  CreatedDate     : 04/07/2019
    *  Parameters      : List<FeedComment> feedComments, Set<Id> respectiveCaseIds - related Cases with Support record type
    *  Returns         : -
    ******************************************************************************/
    public static void initRespectiveFeedItems(List<FeedComment> feedComments) {
        try {
            //create a Set of unique feedItem IDs related to incoming feed comments
            Set<Id> ids = new Set<Id>();
            for (FeedComment feedComment : feedComments) {
                ids.add(feedComment.FeedItemId);
            }
            //return a Map based on both Set with respective feedItem IDs and respective Support Cases IDs
            idFeedItemMap = new Map<Id, FeedItem>([
                    SELECT Id, CreatedById
                    FROM FeedItem
                    WHERE Id IN :ids
                    AND ParentId IN :supportCaseIdSupportCaseMap.keySet()
            ]);
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : checkPermissionCommentInCase
    *  Summary         : checks permission for comment to be inserted
    *  CreatedDate     : 18/06/2019
    *  Parameters      : List<FeedComment> feedComments - incoming feedComments
    *  Returns         : -
    ******************************************************************************/
    public static void checkPermissionCommentInCase(List<FeedComment> feedComments) {
        try {
            for (FeedComment newFeedComment : feedComments) {
                respectiveSupportCase = supportCaseIdSupportCaseMap.get(newFeedComment.ParentId);
                //check if case with Support record type for this comment exists
                if (respectiveSupportCase != null) {
                    //if case status is closed then action is forbidden
                    if (respectiveSupportCase.Status.equals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed))) {
                        newFeedComment.addError(System.Label.No_comments_in_closed_case);
                    }
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : updateCaseStatus
    *  Summary         : updates case status to appropriate one
    *  CreatedDate     : 27/06/2019
    *  Parameters      : List<FeedComment> feedComments - incoming feedComments
    *  Returns         : -
    ******************************************************************************/
    public static void updateCaseStatus(List<FeedComment> feedComments) {
        try {
            List<Case> recordsToBeUpdated = new List<Case>();
            for (FeedComment newFeedComment : feedComments) {
                respectiveSupportCase = supportCaseIdSupportCaseMap.get(newFeedComment.ParentId);
                respectiveFeedItem = idFeedItemMap.get(newFeedComment.FeedItemId);
                //if case with Support record type and related to it feed item for this comment exist,
                //and if comment on post sent not by actual post owner (reply not to yourself) then update status
                if (respectiveSupportCase != null && respectiveFeedItem != null && !newFeedComment.CreatedById.equals(respectiveFeedItem.CreatedById)) {
                    if (caseStatusToBeUpdated()) {
                        respectiveSupportCase.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_updated);
                        recordsToBeUpdated.add(respectiveSupportCase);
                    }
                }
            }
            //update affected cases
            update recordsToBeUpdated;
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    private static Boolean caseStatusToBeUpdated() {
        return !respectiveSupportCase.Status.equals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new))
                && !respectiveSupportCase.Status.equals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_updated))
                && !respectiveSupportCase.Status.equals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed));
    }

}