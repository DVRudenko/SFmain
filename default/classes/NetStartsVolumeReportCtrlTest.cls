@isTest
public class NetStartsVolumeReportCtrlTest {
	public Static Opportunity newOpp;

	@isTest
	public static void createAccount() {

		Profile p = [
				SELECT Id
				FROM Profile
				WHERE Name = 'API Only'];

		User user = new User(
		Username = 'utest@fleetcor.de',
		ProfileId = p.Id,
		Alias = 'utest@fl',
		Email='utest@fleetcor.de',
		EmailEncodingKey='UTF-8',
		Lastname='utest',
		LanguageLocaleKey='en_US',
		LocaleSidKey='en_US',
		TimeZoneSidKey='America/Chicago'//,
		//UserRoleId = ur.Id
		);
		insert user;

		System.runAs(user) {
			Account account = new Account(
					Name = 'test',
					BillingCountry = 'Germany',
					BillingCountryCode = 'DE',
					OwnerId = user.Id
			);
			insert account;

			Opportunity opportunity = new Opportunity(
					Name = 'test',
					StageName = 'Closed Won',
					CloseDate = Date.today() - 1,
					Angebotsdauer__c = '3 months',
					Starts_Rep__c = user.Id,
					AccountId = account.Id
			);
			insert opportunity;

			Integer k;
			for (k = 1; k <= 10; k++) {
				Starts__c starts = new Starts__c(
						Account__c = account.Id,
						client_week_number__c = k,
						volume__c = k + 1,
						starts__c = k + 2
				);
				insert starts;
			}

			NetStartsVolumeReportCtrl controller = new NetStartsVolumeReportCtrl();

			PageReference pageRef = Page.NetStartsVolumeReport;
			pageRef.getParameters().put('userRoleId', UserInfo.getUserRoleId());
			Test.setCurrentPage(pageRef);

			controller = new NetStartsVolumeReportCtrl();
			controller.countries = 'DE';
			controller.accountOwner = user.Id;
			controller.firstPumpDate = 'not null';

			List<SelectOption> tsetCountryItems;
			tsetCountryItems = controller.getCountryItems();
			System.assertEquals(tsetCountryItems[0].getLabel(), 'All');

			List<SelectOption> tsetSecChannel;
			tsetSecChannel = controller.getSecChannelItems();
			System.assertEquals(tsetSecChannel[0].getLabel(), 'All');

			System.assertNotEquals(null, controller.setCon);

			controller.okButton();

			controller.first();
			controller.last();
			controller.previous();
			controller.next();

			Boolean hn = controller.hasNext;
			Boolean hp = controller.hasPrevious;
			Integer pn = controller.pageNumber;

			System.assertEquals(controller.setCon.getPageNumber(), 1);
		}

	}
}