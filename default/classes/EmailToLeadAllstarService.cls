global class EmailToLeadAllstarService implements Messaging.InboundEmailHandler {
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
		// // Create an inboundEmailResult object for returning 
		// // the result of the Force.com Email Service
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		String htmlTextBody = '';

		// Add the email plain text into the local variable
		htmlTextBody = email.htmlBody;
		htmlTextBody = 'Subject: ' + email.subject + '<br/>' + htmlTextBody;
		if (htmlTextBody.contains('Spam') || htmlTextBody.contains('spam')) {
			return null;
		}
		String fromEmailAddress = '';

		if ( ! String.isBlank(email.subject)) {
			fromEmailAddress = email.subject.substringBetween('##email:', ' ');
		}

		RecordType leadRecordType = [
				SELECT Id
				FROM RecordType
				WHERE Name = 'AllStar' AND SobjectType = 'Lead'];

		Lead newLead = new Lead(
			RecordTypeId = leadRecordType.Id,
			Company = 'New Inbound Lead',
			Contact_Email_Body__c = htmlTextBody,
			LeadSource = 'Inbound Email',
			Country = 'Poland',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'E-mail',
			LastName = 'New Lead Contact Form'
		);

		if ( ! String.isBlank(fromEmailAddress)) {
			newLead.Email = fromEmailAddress;
		}

		try {
			insert newLead;

			// Save attachments, if any
			List<Attachment> attachmentsToInsert = new List<Attachment>();
			if (email.textAttachments != null) {
				for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
					Attachment attachment = new Attachment();

					attachment.Name = tAttachment.fileName;
					attachment.Body = Blob.valueOf(tAttachment.body);
					attachment.ParentId = newLead.Id;
					attachmentsToInsert.add(attachment);
				}				
			}

			if (email.binaryAttachments != null) {
				for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
					Attachment attachment = new Attachment();

					attachment.Name = bAttachment.fileName;
					attachment.Body = bAttachment.body;
					attachment.ParentId = newLead.Id;
					attachmentsToInsert.add(attachment);
				}
			}
			insert attachmentsToInsert;
		} catch (System.StringException e) {
			system.debug('newLead exception: ' + e);
		}

		// Set the result to true, no need to send an email back to the user
		// with an error message
		result.success = true;

		// Return the result for the Force.com Email Service
		return result;
	}
}