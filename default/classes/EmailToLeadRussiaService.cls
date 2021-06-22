global class EmailToLeadRussiaService implements Messaging.InboundEmailHandler {

    //private static final String PPR_NEW_EMAIL_LEAD_PHONE = '1111111111'; // fake phone number for email lead
    private static final String PPR_COUNTRY = 'Russia';
    private static final String PPR_COUNTRY_CODE = 'RU';
    private static final String EMAIL_TO_LEAD_OWNER = 'PPR Email-to-Lead';

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
        System.debug('Email To Lead ===' + email);
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String htmlTextBody = email.htmlBody;
        String plainTextBody = email.plainTextBody;

        RecordType leadRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Lead'];

        // Get queue as owner for PPR email lead
        Group queue = [
                SELECT id
                FROM Group
                WHERE Type = 'Queue' AND Name = :EMAIL_TO_LEAD_OWNER];

        Lead newLead = new Lead(
                RecordTypeId = leadRecordType.Id,
                Country = PPR_COUNTRY,
                CountryCode = PPR_COUNTRY_CODE,
                LeadSource = 'Inbound Email');

        if (String.valueOf(email.toAddresses).contains('info@petrolcards.ru')) {
            newlead.Source_if_Self_Sourced__c = 'Petrolcards.ru - АГГРЕГАТОР';
            newLead.LastName = 'info@petrolcards.ru';
            newLead.Source_of_Lead__c = 'Petrolcards.ru - АГГРЕГАТОР';
        } else if (String.valueOf(email.toAddresses).contains('sales@info.pprcard.ru')) {
            newLead.LastName = 'sales@info.pprcard.ru';
            newLead.Source_of_Lead__c = 'Email рассылка';
        } else if (String.valueOf(email.toAddresses).contains('sales@petrolplus.ru')) {
            newLead.LastName = 'sales@petrolplus.ru';
            newLead.Source_of_Lead__c = 'Сайт Petrolplus.ru';
            newLead.Utm_source__c = 'yandex_direct';
            newLead.Utm_campaign__c = 'static_email';            
        } else if (String.valueOf(email.toAddresses).contains('info@gpc-store.ru')) {
            newLead.LastName = 'info@gpc-store.ru';
            newLead.Source_of_Lead__c = 'Сайт GPC-store.ru';       
        } else {
            newLead.LastName = 'not defined';
        }

        newLead.Company = email.fromAddress;
       // newLead.Phone = PPR_NEW_EMAIL_LEAD_PHONE;
        newLead.Email = email.fromAddress;
        newLead.Status = 'NEW - Not Yet Contacted';
        newLead.Lead_Source_Type__c = 'Email';
        newLead.First_Contact_Inbound_Outbound__c = 'Inbound Mail';
        newLead.Date_of_First_Contact_Inbound_Outbound__c = Date.today();
        newLead.Description = plainTextBody;
        newLead.OwnerId = queue.Id;

        // If email doesn't pass the check for SPAM, lead won't create
        if (checkEmailForSpam(email)) {
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
                System.debug('New EmailToLead exception: ' + e);
            }
        }

        // Set the result to true, no need to send an email back to the user
        // with an error message
        result.success = true;

        // Return the result for the Force.com Email Service
        return result;
    }

    /*******************************************************************************
    *  Name            : checkEmailForSpam(Messaging.inboundEmail email)
    *  Summary         : checks email's subject and body for SPAM words before create lead in SF
    *  CreatedDate     : 18/09/2017
    *  Parameters      : Messaging.inboundEmail email - inbound email
    *  Returns         : boolean
    ******************************************************************************/
    @TestVisible
    private boolean checkEmailForSpam(Messaging.inboundEmail email) {
        String emailSubject = email.subject;
        String emailBody = email.plainTextBody;

        boolean emailIsValid = true;

        //Exclude error email from mail boxe
        List<EmailServicesAddress> emailServicesAddresses = [
                SELECT Id, EmailDomainName
                FROM EmailServicesAddress
                WHERE Function.FunctionName = 'Inbound Leads Russia'
        ];
        for (EmailServicesAddress emailservices : emailServicesAddresses) {
            if (emailBody.contains(emailservices.EmailDomainName)) {
                emailIsValid = false;
            }
        }

        // Get SPAM words list
        List<Email_to_lead_SPAM_filter__c> spamWords = Email_to_lead_SPAM_filter__c.getAll().values();
        if (!spamWords.isEmpty()) {
            for (Email_to_lead_SPAM_filter__c word : spamWords) {
                String keyWord = word.SPAM_key_word__c;
                System.debug('Email subject: ' + emailSubject.toLowerCase());
                System.debug('Email body: ' + emailBody.toLowerCase());
                if (emailSubject.toLowerCase().contains(keyWord.toLowerCase()) ||
                        emailBody.toLowerCase().contains(keyWord.toLowerCase())) {
                    emailIsValid = false;
                }
            }
        } else {
            System.debug('SPAM list for Email to lead is empty');
        }

        // Blocking lead witch does not contained in domain postfix '.ru'
        if ( ! email.fromAddress.toLowerCase().endsWith('.ru') ) {
            emailIsValid = false;
        }

        return emailIsValid;
    }
}