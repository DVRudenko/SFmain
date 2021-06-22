public class FeedItemHandler {
	// Regex string for parser input stirng
	private static final String regex = '^Date=\'([0-9]{1,2}).([0-9]{1,2}).([0-9]{4})\'\\s*(.+)$';
	private static  Map<Id, Case> supportCaseIdSupportCaseMap;
	private static Case respectiveSupportCase;
	private static Set<String> usersPostTypes;

	static {
		usersPostTypes = new Set<String> {
				GlobalUtils.FeedItemType.ContentPost.name(),
				GlobalUtils.FeedItemType.LinkPost.name(),
				GlobalUtils.FeedItemType.TextPost.name()
		};
	}

	/*******************************************************************************
	*  Name            : parserFeedItemBody()
	*  Summary         : parser body field from FeedItem and separates the date and message
	*  CreatedDate     : 28/11/2017
	*  Parameters      : newFeedItemList - new List FeedItem
	*  Returns         : void
	******************************************************************************/
	public static void parserFeedItemBody(List<FeedItem> newFeedItemList) {

		Pattern regexPattern = Pattern.compile(regex);

		for(FeedItem item : newFeedItemList) {
			//if feed item refers to case with Support record type, skip this processing
			if (supportCaseIdSupportCaseMap.get(item.ParentId) != null) continue;
			String body = item.Body;
			Matcher regexMatcher = regexPattern.matcher(body);

			if(regexMatcher.find()) {
				item.Body = regexMatcher.group(4);
			}
		}
	}

	/*******************************************************************************
    *  Name            : initRespectiveSupportCases
    *  Summary         : selects cases with Support record type which relate to incoming feedItems
    *  CreatedDate     : 18/06/2019
    *  Parameters      : List<FeedItem> feedItems - incoming feedItems
    *  Returns         : -
    ******************************************************************************/
	public static void initRespectiveSupportCases(List<FeedItem> feedItems) {
		try {
			//create a Set of unique case IDs related to incoming feed items
			Id caseSupportRecordTypeId = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
			Id caseSupportCCSRecordTypeId = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support_CCS.name());
			Set<Id> ids = new Set<Id>();
			for (FeedItem feedItem : feedItems) {
				ids.add(feedItem.ParentId);
			}
			//return a Map based on Set with case IDs and Case objects which related to incoming feed items
			supportCaseIdSupportCaseMap = new Map<Id, Case>([
					SELECT Id, Status, OwnerId, PostsByOwner__c
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
    *  Name            : updateCaseStatus
    *  Summary         : updates case status to appropriate one
    *  CreatedDate     : 18/06/2019
    *  Parameters      : List<FeedItem> feedItems - incoming feedItems
    *  Returns         : -
    ******************************************************************************/
	public static void updateCaseStatus(List<FeedItem> feedItems) {
		try {
			List<Case> recordsToBeUpdated = new List<Case>();
			for (FeedItem newFeedItem : feedItems) {
				respectiveSupportCase = supportCaseIdSupportCaseMap.get(newFeedItem.ParentId);
				//check if feed item is user's post,
				//if case with Support record type for this post exists
				//and if post sent by case owner
				if (respectiveSupportCase != null && newFeedItem.CreatedById.equals(respectiveSupportCase.OwnerId) && usersPostTypes.contains(newFeedItem.Type)) {
					//increase posts counter field
					respectiveSupportCase.PostsByOwner__c++;
					//update status
					if (caseStatusToBeUpdated()) respectiveSupportCase.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting);
					recordsToBeUpdated.add(respectiveSupportCase);
				}
			}
			//update affected cases
			update recordsToBeUpdated;
		} catch (Exception e) {
			ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
		}
	}

    private static Boolean caseStatusToBeUpdated() {
        return !respectiveSupportCase.Status.equals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting))
                && !respectiveSupportCase.Status.equals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed));
    }

	/*******************************************************************************
    *  Name            : checkPermissionPostInCase
    *  Summary         : checks permission for post to be inserted
    *  CreatedDate     : 18/06/2019
    *  Parameters      : List<FeedItem> feedItems - incoming feedItems
    *  Returns         : -
    ******************************************************************************/
	public static void checkPermissionPostInCase(List<FeedItem> feedItems) {
		try {
			for (FeedItem newFeedItem : feedItems) {
				respectiveSupportCase = supportCaseIdSupportCaseMap.get(newFeedItem.ParentId);
				//if feed item is user's post and case with Support record type for this post exists
				//then check permission to make post
				if (respectiveSupportCase != null && usersPostTypes.contains(newFeedItem.Type)) {
					//if post owner is not the case owner or case is closed, add error
					if ( !newFeedItem.CreatedById.equals(respectiveSupportCase.OwnerId)) {
						newFeedItem.addError(System.Label.No_posts_in_not_owned_case);
					} else if (respectiveSupportCase.Status.equals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed))) {
						newFeedItem.addError(System.Label.No_posts_in_closed_case);
					}
				}
			}
		} catch (Exception e) {
			ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
		}
	}

}