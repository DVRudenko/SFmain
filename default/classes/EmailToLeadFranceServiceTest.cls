@isTest
private class EmailToLeadFranceServiceTest {
	@isTest
	public static void testEmailAT() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Téléphone 123123123\nVolume Total 33m3\nNombre PL 44\nNom du Contact test\nNom test\n';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='eugene.vabishchevich@gmail.com';

		EmailToLeadFranceService serviceObject = new EmailToLeadFranceService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE LastName = 'test'
				LIMIT 1];
		system.assertEquals(l.size(), 1);
	}

	@isTest
	public static void testNotCreateEmailAT() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Téléphone 123123123\nVolume Spam Total 33m3\nNombre PL 44\nNom du Contact test\nNom test\n';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='eugene.vabishchevich@gmail.com';

		EmailToLeadFranceService serviceObject = new EmailToLeadFranceService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE LastName = 'test'
				LIMIT 1];
		system.assertEquals(l.size(), 0);
	}
}