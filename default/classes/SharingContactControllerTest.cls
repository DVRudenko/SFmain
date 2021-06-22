@isTest
public class SharingContactControllerTest {
	public static Contact newContact;

	public static void init() {
		newContact = new Contact(
				Salutation = 'Herr',
				FirstName = 'Bob',
				LastName = 'Test',
				Email = 'test@test.com',
				MailingCountry = 'Germany',
				MailingStreet = '298 S. Ringo Street',
				MailingCity = 'Little Rock',
				MailingState = 'Berlin',
				MailingPostalCode = '72201'
		);
		insert newContact;

		ContactHistory createHistory = new ContactHistory(
				ContactId = newContact.Id,
				Field = 'created'
		);
		insert createHistory;

		ContactHistory convertHistory = new ContactHistory(
				ContactId = newContact.Id,
				Field = 'contactCreatedFromLead'
		);
		insert convertHistory;
	}

	@isTest
	public static void historyTest() {
		init();

		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(newContact);
			SharingContactController sharingContactController = new SharingContactController(sc);
		Test.stopTest();

		System.assert(sharingContactController.contact != null);
		System.assert(sharingContactController.contactHistory.size() == 2);
	}
}