@isTest
public class WorkcomRatingTableControllerTest {

	@testSetup static void init() {
		Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
		User user = new User(
				Username = 'newusertest@fleetcor.de',
				ProfileId = p.Id,
				Alias = 'uset@fl',
				Email = 'usertest@fleetcor.de',
				EmailEncodingKey = 'UTF-8',
				Lastname = 'usertest',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimeZoneSidKey = 'America/Chicago',
				UserPermissionsWorkDotComUserFeature = true,
				Points__c = 10,
				Earned_Points__c = 10);
		insert user;
	}

	@isTest
	public static void paginationTest(){
		User user = ([
				SELECT Points__c
				FROM User
				WHERE Username = 'newusertest@fleetcor.de'
		]);

		WorkcomRatingTableController workcomRatingTableController = new WorkcomRatingTableController();
		workcomRatingTableController.next();
		workcomRatingTableController.previous();
		workcomRatingTableController.first();
		workcomRatingTableController.last();
		Boolean hasNext = workcomRatingTableController.hasNext;
		Boolean hasPrevious = workcomRatingTableController.hasPrevious;

	}


}