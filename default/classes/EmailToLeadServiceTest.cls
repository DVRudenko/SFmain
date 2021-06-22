@isTest
public class EmailToLeadServiceTest {
	@isTest
	public static void testEmailAT() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='kontakt@fleetcor.at';
		
		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfileone.txt';
		attachment.mimeTypeSubType = 'text/plain';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

		// add an Text attachment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
		attachmenttext.body = 'my attachment text';
		attachmenttext.fileName = 'textfiletwo3.txt';
		attachmenttext.mimeTypeSubType = 'texttwo/plain';
		email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

		EmailToLeadService serviceObject = new EmailToLeadService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals(l.size(), 1);
	} 

	@isTest
	public static void testEmailDE() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='kontakt@fleetcor.de';

		EmailToLeadService serviceObject = new EmailToLeadService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals(l.size(), 1);
	}

	@isTest
	public static void testNotCreateEmailDE() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test Spam';
		email.fromAddress ='kontakt@fleetcor.de';

		EmailToLeadService serviceObject = new EmailToLeadService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals(l.size(), 1);
	} 

	@isTest
	public static void testEmailCZ() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='retailer@fleetcor.cz';

		EmailToLeadService serviceObject = new EmailToLeadService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 2];
		system.assertEquals(l.size(), 1);
	}

	@isTest
	public static void testEmailSK() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='retailer@fleetcor.sk';

		EmailToLeadService serviceObject = new EmailToLeadService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals(l.size(), 1);
	}

	@isTest
	public static void testEmail_Eugene() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='flash.log@gmail.com';

		EmailToLeadService serviceObject = new EmailToLeadService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> l = [
				SELECT Email
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals(l.size(), 1);
	}

	@isTest
	public static void testEmailBEFR() {
		// Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='contact.fr@fleetcorcards.be';

		EmailToLeadService serviceObject = new EmailToLeadService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> leadList = [
				SELECT Country
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals('Belgium-FR', leadList.get(0).Country);
	} 
}