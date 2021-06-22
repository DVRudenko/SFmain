@isTest
public class EmailToLeadAllstarServiceTest {
	@isTest
    public static void testEmailToLeadAllstarService() {
        // Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test';
		email.fromAddress ='nowyklient@fleetcor.pl';
		
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

		EmailToLeadAllstarService serviceObject = new EmailToLeadAllstarService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> leadList = [
				SELECT LeadSource, Channel__c, Country
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals(1, leadList.size());
		system.assertEquals('E-mail', leadList.get(0).Channel__c);
		system.assertEquals('Poland', leadList.get(0).Country);
		system.assertEquals('Inbound Email', leadList.get(0).LeadSource);
    }


    @isTest
    public static void testNotCreateAllstarLead() {
        // Create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.subject = '##email:test@test.com test Spam';
		email.fromAddress ='nowyklient@fleetcor.pl';
		
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

		EmailToLeadAllstarService serviceObject = new EmailToLeadAllstarService();
		serviceObject.handleInboundEmail(email, env);
		List<Lead> leadList = [
				SELECT LeadSource, Channel__c, Country
				FROM Lead
				WHERE Email = 'test@test.com'
				LIMIT 1];
		system.assertEquals(0, leadList.size());
    }
}