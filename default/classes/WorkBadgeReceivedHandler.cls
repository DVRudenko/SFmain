/**
 * Created by Andrei.Moiseev on 24.11.2017.
 */
public without sharing class WorkBadgeReceivedHandler {

	public static Map<String, WorkcomBadgeReceivedProcessorInterface> processorMap = new Map<String, WorkcomBadgeReceivedProcessorInterface> {
			'Russian' => new WorkcomBadgeReceivedProcessorRu(),
			'Russian GPC' => new WorkcomBadgeReceivedProcessorRuGPC(),
			'Germany' => new WorkcomBadgeReceivedProcessorDe()
	};

	/*******************************************************************************
	*  Name            : getWorkBadgeDefinitionMap()
	*  Summary         : get badges by WorkBadges
	*  CreatedDate     : 24/11/2017
	*  Parameters      : workBadgeList - List new WorkBadge
	*  Returns         : Map<Id, WorkBadgeDefinition>
	******************************************************************************/
	private static Map<Id, WorkBadgeDefinition> getWorkBadgeDefinitionMap(List<WorkBadge> workBadgeList) {
		Set<Id> badgeDefinitionIdSet = new Set<Id>();

		for (WorkBadge item : workBadgeList) {
			badgeDefinitionIdSet.add(item.DefinitionId);
		}

		return new Map<Id, WorkBadgeDefinition>([
				SELECT Points__c, If_balance_zero__c, RecordType.Name, RecordTypeId
				FROM WorkBadgeDefinition
				WHERE Id IN :badgeDefinitionIdSet
		]);
	}

	public static Map<String, List<WorkBadge>> splitWorkBadgeByBusiness(List<WorkBadge> workBadgeList) {
		Map<Id, WorkBadgeDefinition> workBadgeDefinitionMap = getWorkBadgeDefinitionMap(workBadgeList);

		Map<String, List<WorkBadge>> businessWorkBadgeMap = new Map<String, List<WorkBadge>>();
		for (WorkBadge item : workBadgeList) {
			WorkBadgeDefinition badge = workBadgeDefinitionMap.get(item.DefinitionId);
			if ( ! businessWorkBadgeMap.containsKey(badge.RecordType.Name) ) {
				businessWorkBadgeMap.put(badge.RecordType.Name, new List<WorkBadge>{ item });
			} else {
				businessWorkBadgeMap.get(badge.RecordType.Name).add(item);
			}
		}
		return businessWorkBadgeMap;
	}

	/*******************************************************************************
   *  Name            : insertWorkcomPackage()
   *  Summary         : insert new Thanks recognition with feed.
   *  CreatedDate     : 24/11/2017
   *  Parameters      : feedItems - map FeedItem , workThankzes = map WorkThanks, workBadges - map WorkBadge
   *  Returns         : void
   ******************************************************************************/
	public static void insertWorkcomPackage(Map<Integer, FeedItem> feedItems,
			Map<Integer, WorkThanks> workThankzes,
			Map<Integer, WorkBadge> workBadges){

		insert workThankzes.values();

		// Completed FeedItem
		for (Integer key : feedItems.keySet()) {
			FeedItem feed = feedItems.get(key);
			WorkThanks thanks = workThankzes.get(key);
			feed.RelatedRecordId = thanks.Id;
		}
		insert feedItems.values();

		// Completed WorkBadge
		for (Integer key : workBadges.keySet()) {
			WorkBadge workBadgeItem = workBadges.get(key);
			WorkThanks workThanksItem = workThankzes.get(key);
			workBadgeItem.SourceId = workThanksItem.Id;
		}
		insert workBadges.values();
	}

	public static void runAfterInsert(List<WorkBadge> workBadgeList) {
		checkBelongingUsersToWorkcom(workBadgeList);
		Map<String, List<WorkBadge>> businessWorkBadgeMap = splitWorkBadgeByBusiness(workBadgeList);


		for (String businessName : processorMap.keySet()) {
			if (businessWorkBadgeMap.containsKey(businessName)) {
				processorMap.get(businessName).executeAfterInsert(businessWorkBadgeMap.get(businessName));
			}

		}
	}

	public static void runBeforeInsert(List<WorkBadge> workBadgeList) {
		checkBelongingUsersToWorkcom(workBadgeList);
		Map<String, List<WorkBadge>> businessWorkBadgeMap = splitWorkBadgeByBusiness(workBadgeList);

		for (String businessName : processorMap.keySet()) {
			if (businessWorkBadgeMap.containsKey(businessName)) {
				processorMap.get(businessName).executeBeforeInsert(businessWorkBadgeMap.get(businessName));
			}
		}
	}

	/*******************************************************************************
	*  Name            : checkBelongingUsersToWorkcom()
	*  Summary         : check that recipients users belong to Work.com
	*  CreatedDate     : 24/11/2017
	*  Parameters      : workBadgeList - List new WorkBadge
	*  Returns         : void
	******************************************************************************/
	public static void checkBelongingUsersToWorkcom(List<WorkBadge> workBadgeList) {
		Set<Id> userIds = new Set<Id>();
		for (WorkBadge badge : workBadgeList) {
			userIds.add(badge.RecipientId);
		}

		List<User> userList = ([
				SELECT Name, UserPermissionsWorkDotComUserFeature
				FROM User
				WHERE Id IN :userIds
				LIMIT 100
		]);

		for (User user : userList) {
			If (user.UserPermissionsWorkDotComUserFeature == false) {
				throw new UserNotMemberWorkDotComException('Sorry, this user is not Work.com member. Please contact your SF administrator.');
			}
		}
	}

	public class UserNotMemberWorkDotComException extends Exception {}
}