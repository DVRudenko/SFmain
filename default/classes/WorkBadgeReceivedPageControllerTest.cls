@isTest
public class WorkBadgeReceivedPageControllerTest {

	private static Decimal sourcePoints = 10.0;
	private static Decimal followPoints = 100.0;

	private static void init() {
		Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
		UserRole role = [SELECT Id FROM UserRole WHERE Name =: 'PPR_Fleetcor'];
		User user = new User(
				Username = 'newusertest@fleetcor.de',
				ProfileId = p.Id,
				UserRoleId = role.Id,
				Alias = 'uset@fl',
				Email = 'usertest@fleetcor.de',
				EmailEncodingKey = 'UTF-8',
				Lastname = 'usertest',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimeZoneSidKey = 'America/Chicago',
				Points__c = sourcePoints,
				UserPermissionsWorkDotComUserFeature = true,
				Earned_Points__c = sourcePoints);
		insert user;
	}

	@isTest
	public static void refreshTestSetUserThroughUrl() {
		init();

		User user = ([SELECT Points__c FROM User WHERE Username = 'newusertest@fleetcor.de']);

		Test.StartTest();
			PageReference pageRef = Page.WorkBadgeReceivedPage;
			pageRef.getParameters().put('sfdc.userId', ([SELECT Id FROM User WHERE Username = 'newusertest@fleetcor.de'].Id));
			Test.setCurrentPage(pageRef);
			WorkBadgeReceivedPageController workBadgeReceivedPageController = new WorkBadgeReceivedPageController();
			user.Points__c = followPoints;
			update user;
			workBadgeReceivedPageController.refresh();
		Test.StopTest();
		System.assertEquals(followPoints, workBadgeReceivedPageController.currentUser.endPoints);
	}

	@isTest
	public static void refreshTestSetUserThroughUserInfo() {
		init();

		User user = ([SELECT Points__c FROM User WHERE Username = 'newusertest@fleetcor.de']);

		Test.StartTest();
			WorkBadgeReceivedPageController workBadgeReceivedPageCtl;
			System.runAs(user) {
				workBadgeReceivedPageCtl = new WorkBadgeReceivedPageController();
				user.Points__c = followPoints;
				update user;
				workBadgeReceivedPageCtl.refresh();
			}
		Test.StopTest();
		System.assertEquals(followPoints, workBadgeReceivedPageCtl.currentUser.endPoints);
	}
}