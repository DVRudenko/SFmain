/**
 * Created by Andrei.Moiseev on 23.11.2017.
 */
public class UserPrizeAssociationHandler {

	/*******************************************************************************
	*  Name            : updateAssociationUser()
	*  Summary         : update user points, when user choose a prizes.
	*  CreatedDate     : 23/11/2017
	*  Parameters      : userPrizeAssociationList - new List UserPrizeAssociation__c
	*  Returns         : void
	******************************************************************************/
	public static void updateAssociationUser(List<UserPrizeAssociation__c> userPrizeAssociationList) {
		Set<Id> userIdSet = new Set<Id>();
		Set<Id> prizeIdSet = new Set<Id>();

		for(UserPrizeAssociation__c item : userPrizeAssociationList) {
			userIdSet.add(item.User__c);
			prizeIdSet.add(item.Prize__c);
		}

		if(!userIdSet.isEmpty() && !prizeIdSet.isEmpty()) {
			Map<Id, User> usersMap = new Map<Id, User>([
					SELECT Name, Points__c
					FROM User
					WHERE Id IN :userIdSet
			]);

			Map<Id, Prize__c>  prizesMap = new Map<Id, Prize__c>([
					SELECT Cost__c
					FROM Prize__c
					WHERE Id IN :prizeIdSet
			]);
			List<User> userForUpdateList = new List<User>();

			for(UserPrizeAssociation__c item : userPrizeAssociationList) {
				User currentUser = usersMap.get(item.User__c);
				Prize__c currentPrize = prizesMap.get(item.Prize__c);
				if(currentUser.Points__c < currentPrize.Cost__c) {
					item.addError(Label.RU_0017_NotEnaPoints);
				}
				currentUser.Points__c -= currentPrize.Cost__c;
				userForUpdateList.add(currentUser);
			}
			update userForUpdateList;
		}
	}
}