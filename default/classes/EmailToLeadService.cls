global class EmailToLeadService implements Messaging.InboundEmailHandler {
    private static String htmlTextBody = '';
    private static String plainTextBody = '';

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
        // // Create an inboundEmailResult object for returning
        // // the result of the Force.com Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        // Add the email plain text into the local variable
        plainTextBody = email.plainTextBody;

        if (email.htmlBody == null) {
            htmlTextBody = email.plainTextBody;
        } else {
            htmlTextBody = email.htmlBody;
        }

        htmlTextBody = 'Subject: ' + email.subject + '<br/>' + htmlTextBody;
        if (htmlTextBody.contains('Spam') || htmlTextBody.contains('spam')) {
            htmlTextBody = 'POSSIBLE SPAM AUTO-DETECTED' + '<br/>' + htmlTextBody;
        }
        htmlTextBody = 'From FLEETCOR Address: ' + email.fromAddress + '<br/>' + htmlTextBody;
        Integer maxBodyLength = Schema.Lead.getSObjectType().getDescribe().fields.getMap().get('Contact_Email_Body__c').getDescribe().length - 500;
        if(htmlTextBody.length() >= maxBodyLength){
            htmlTextBody = 'The end of email body was cut off. Reason: max field length was exceeded. <br/>' + htmlTextBody;
            htmlTextBody = htmlTextBody.left(maxBodyLength);
        }

        Lead newLead = createLeadWithParse(email.fromAddress, plainTextBody, email.subject);
        System.debug(newLead.Name);

        try {
            //insert newLead;
            String leadId = insertLeadViaApp(newLead);

            // Save attachments, if any
            if (leadId != null) {
                List<Attachment> attachmentsToInsert = new List<Attachment>();
                if (email.textAttachments != null) {
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        Attachment attachment = new Attachment();

                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = leadId;
                        attachmentsToInsert.add(attachment);
                    }
                }

                if (email.binaryAttachments != null) {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        Attachment attachment = new Attachment();

                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = leadId;
                        attachmentsToInsert.add(attachment);
                    }
                }
                insert attachmentsToInsert;
            }
        } catch (System.StringException e) {
            ExceptionLogger.sendException('EmailToLeadService ' + (String) e.getMessage(), (String) e.getStackTraceString());
        }

        // Set the result to true, no need to send an email back to the user
        // with an error message
        result.success = true;
        // Return the result for the Force.com Email Service
        return result;
    }

    private static Lead createLeadWithParse(String fromEmail, String emailBody, String emailSubject) {
        Lead newLead = new Lead();
        newLead.Country = getCountry(fromEmail);
        //set default values for lead fields

        //This part of code is commended because of https://petrolplus.atlassian.net/browse/SFG-611 Task being frozen by Maksim Simonov
        //Do not delete!

//		String fromCustomerEmailAddress;
//		if((fromEmail == 'kundewerden@fleetcor.de') &&
//				!String.isBlank(emailBody) && emailBody.contains('Von:')) {
//			fromCustomerEmailAddress = emailBody.substringBetween('Von:', '<').trim();
//		}
//
//		if ((fromEmail == 'kundewerden@fleetcor.de') &&
//				!String.isBlank(fromCustomerEmailAddress) && fromCustomerEmailAddress == 'no-reply@shell.com'){
//			switch on emailBody.substringBetween('Aus wievielen Fahrzeugen besteht Ihre Flotte?:\n\n', '\n\n'){
//				when '1 bis 6' {
//					newLead.Anzahl_der_Fahrzeuge__c = 3;
//				}
//				when '7 - 20' {
//					newLead.Anzahl_der_Fahrzeuge__c = 13;
//				}
//				when 'über 20', 'uber 20' {
//					newLead.Anzahl_der_Fahrzeuge__c = 25;
//				}
//			}
//
//			newLead.Company = emailBody.substringBetween('Name:\n\n', '\n\n');
//			newLead.Sec_Channel__c = 'Inbound';
//			newLead.Channel__c = 'Internet';
//			newLead.LeadSource = 'Shell Email';
//			newLead.LastName = emailBody.substringBetween('Name:\n\n', '\n\n');
//			newLead.Email = emailBody.substringBetween('E-Mail:\n\n', '<');
//			newLead.Phone = emailBody.substringBetween('Telefon:\n\n', '\n\n').trim();
//			newLead.Contact_Email_Body__c = htmlTextBody;
//			newLead.Description = emailBody.substringBetween('brand new shell card:\n\n', '\n\n');

//		} else {
        newLead.Company = 'New Inbound Lead';
        newLead.Contact_Email_Body__c = htmlTextBody;
        newLead.Channel__c = 'E-mail';

        if (fromEmail == 'retailer@fleetcor.cz' || fromEmail == 'retailer@fleetcor.sk') {
            newLead.LastName = 'New Lead JITB Email';
            newLead.Sec_Channel__c = 'JITB';
        } else {
            newLead.LastName = 'New Lead Contact Form';
            newLead.Sec_Channel__c = 'Inbound';
        }

        if (htmlTextBody != null && htmlTextBody.containsIgnoreCase('Formstack')) {
            newLead.LeadSource = 'Shell Email';
        } else {
            newLead.LeadSource = 'Inbound Email';
        }

        if (!String.isBlank(emailSubject)) {
            String fromEmailAddress = emailSubject.substringBetween('##email:', ' ');
            if (!String.isBlank(fromEmailAddress)) {
                newLead.Email = fromEmailAddress;
            }
        }

        Map<String, RecordTypeInfo> leadRecordTypes = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName();
        if (fromEmail == 'karta.lotos@fleetcor.pl') {
            newLead.RecordTypeId = leadRecordTypes.get('Lotos').getRecordTypeId();
        } else {
            newLead.RecordTypeId = leadRecordTypes.get('Endkunde').getRecordTypeId();
        }
//		}
        return newLead;
    }

    private static String getCountry(String fromEmail) {
        String result;
        if (fromEmail == 'kontakt@fleetcor.at') result = 'Austria';
        else if (fromEmail == 'kontakt@fleetcor.de') result = 'Germany';
        else if (fromEmail == 'kundewerden@fleetcor.de') result = 'Germany';
        else if (fromEmail == 'contact@fleetcor.nl') result = 'Netherlands';
        else if (fromEmail == 'contact@fleetcorcards.be') result = 'Belgium-NL';
        else if (fromEmail == 'contact.fr@fleetcorcards.be') result = 'Belgium-FR';
        else if (fromEmail == 'contact@fleetcor.fr') result = 'France';
        else if (fromEmail == 'nowyklient@fleetcor.pl') result = 'Poland';
        else if (fromEmail == 'ujugyfel@fleetcor.hu') result = 'Hungary';
        else if (fromEmail == 'contact@fleetcor.ch') result = 'Switzerland-DE';
        else if (fromEmail == 'contact-fr@fleetcor.ch') result = 'Switzerland-FR';
        else if (fromEmail == 'contact-it@fleetcor.ch') result = 'Switzerland-IT';
        else if (fromEmail == 'contact@fleetcor.lu') result = 'Luxembourg';
        else if (fromEmail == 'kontakt@fleetcor.cz') result = 'Czech Republic';
        else if (fromEmail == 'kontakt@fleetcor.sk') result = 'Slovakia';
        else if (fromEmail == 'flash.log@gmail.com') result = 'Belgium-FR';
        else if (fromEmail == 'eugene.vabishchevich@enway.com') result = 'Belgium-NL';
        else if (fromEmail == 'karta.lotos@fleetcor.pl') result = 'Poland';
        else if (fromEmail == 'retailer@fleetcor.cz') result = 'Czech Republic';
        else if (fromEmail == 'retailer@fleetcor.sk') result = 'Slovakia';

        return result;
    }

    private static String insertLeadViaApp(Lead newLead) {
        CustomDeduplicationActionResult result = CustomDeduplicationAPI.executeActions(newLead, 'EU_Email_To_Lead');
        for (CustomDeduplicationActionResult.ActionResult actionResult : result.allResults) {
            for (CustomDeduplicationActionResult.ActResult actResult : actionResult.actResults) {
                for (String operation : actResult.performedOperations.keyset()) {
                    if (operation.contains('CREATE_OPERATION')) {
                        for (SObject record : actResult.performedOperations.get(operation)) {
                            if (String.valueOf(record.get('Id')).startsWith('00Q')) {
                                return String.valueOf(record.get('Id'));
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
}