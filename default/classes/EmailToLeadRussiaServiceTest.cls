@isTest
public class EmailToLeadRussiaServiceTest {
    @isTest  public static void testEmail1(){
        // Create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // Create the plainTextBody and fromAddres for the test
        email.plainTextBody = 'Here is test plainText body of the email\nТелефон 7777777\n';
        email.fromAddress ='anna.rudas@fleetcor.ru';
        email.subject = '##email:test@test.com test';

        List<String> toaddr = new List<String>();
        toaddr.add('sales@petrolplus.ru');
        email.toAddresses = toaddr;

        // Add a Binary attachment
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.body = blob.valueOf('My attachment text');
        binaryAttachment.fileName = 'EmailToLeadBinaryFile.txt';
        binaryAttachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

        // Add a Text attachment
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.body = 'My attachment text';
        textAttachment.fileName = 'EmailToLeadTextFile.txt';
        textAttachment.mimeTypeSubType = 'text2/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment };

        EmailToLeadRussiaService service = new EmailToLeadRussiaService();
        service.handleInboundEmail(email, env);
        List<Lead> leads = [
                SELECT Email, OwnerId
                FROM Lead
                WHERE LastName = 'sales@petrolplus.ru'
                LIMIT 1];
        System.assertEquals(leads.size(), 1);
    }

    @isTest  public static void testEmail2(){
        // Create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // Create the plainTextBody and fromAddres for the test
        email.plainTextBody = 'Here is test plainText body of the email\nТелефон 7777777\n';
        email.fromAddress ='anna.rudas@fleetcor.ru';
        email.subject = '##email:test@test.com test';

        List<String> toaddr = new List<String>();
        toaddr.add('sales@info.pprcard.ru');
        email.toAddresses = toaddr;

        // Add a Binary attachment
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.body = blob.valueOf('My attachment text');
        binaryAttachment.fileName = 'EmailToLeadBinaryFile.txt';
        binaryAttachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

        // Add a Text attachment
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.body = 'My attachment text';
        textAttachment.fileName = 'EmailToLeadTextFile.txt';
        textAttachment.mimeTypeSubType = 'text2/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment };

        EmailToLeadRussiaService service = new EmailToLeadRussiaService();
        service.handleInboundEmail(email, env);
        List<Lead> leads = [
                SELECT Email, OwnerId
                FROM Lead
                WHERE LastName = 'sales@info.pprcard.ru'
                LIMIT 1];
        System.assertEquals(leads.size(), 1);
    }

    @isTest  public static void testEmail3(){
        // Create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // Create the plainTextBody and fromAddres for the test
        email.plainTextBody = 'Here is test plainText body of the email\nТелефон 7777777\n';
        email.fromAddress ='anna.rudas@fleetcor.ru';
        email.subject = '##email:test@test.com test';

        List<String> toaddr = new List<String>();
        toaddr.add('info@petrolcards.ru');
        email.toAddresses = toaddr;

        // Add a Binary attachment
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.body = blob.valueOf('My attachment text');
        binaryAttachment.fileName = 'EmailToLeadBinaryFile.txt';
        binaryAttachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

        // Add a Text attachment
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.body = 'My attachment text';
        textAttachment.fileName = 'EmailToLeadTextFile.txt';
        textAttachment.mimeTypeSubType = 'text2/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment };

        EmailToLeadRussiaService service = new EmailToLeadRussiaService();
        service.handleInboundEmail(email, env);
        List<Lead> leads = [
                SELECT Email, OwnerId
                FROM Lead
                WHERE LastName = 'info@petrolcards.ru'
                LIMIT 1];
        System.assertEquals(leads.size(), 1);
    }

    @isTest
    public static void testEmailSpamFilter(){
        // Create a new email and envelope object
        Messaging.InboundEmail emailFirst = new Messaging.InboundEmail();
        Messaging.InboundEmail emailSecond = new Messaging.InboundEmail();
        Messaging.InboundEmail emailThird = new Messaging.InboundEmail();
        Messaging.InboundEmail emailForth = new Messaging.InboundEmail();
        Messaging.InboundEmail emailFifth = new Messaging.InboundEmail();
        Messaging.InboundEmail emailSixth = new Messaging.InboundEmail();

        insert new Email_to_lead_SPAM_filter__c(Name='word1', SPAM_key_word__c = 'SPAM');
        insert new Email_to_lead_SPAM_filter__c(Name='word2', SPAM_key_word__c = 'filter');
        insert new Email_to_lead_SPAM_filter__c(Name='word3', SPAM_key_word__c = 'key word');

        String systemUrl = 'inbound_leads_russia@l-1nm42g6lbo0jl95nbn13ge8tirpzzww03jbsltg3bago16nwkp.2-ob2eeau.eu9.apex.salesforce.com';

        // First email test. Test unvalid email subject
        emailFirst.plainTextBody = 'Here is test email';
        emailFirst.fromAddress ='anna.rudas@fleetcor.ru';
        emailFirst.subject = '##email:test@test.com SPAM';

        // Second email test. Test unvalid email body
        emailSecond.plainTextBody = 'Here is test SPAM email';
        emailSecond.fromAddress ='anna.rudas@fleetcor.ru';
        emailSecond.subject = '##email:test@test.com test';

        // Third email test. Test unvalid email body
        emailThird.plainTextBody = 'Here is test email with KEY WORD';
        emailThird.fromAddress ='anna.rudas@fleetcor.ru';
        emailThird.subject = '##email:test@test.com test';

        // Forth email test. Test unvalid email with system url
        emailForth.plainTextBody = 'Here is test email with system url ' + systemUrl;
        emailForth.fromAddress ='anna.rudas@fleetcor.ru';
        emailForth.subject = '##email:test@test.com test';

        // Fifth email test. Test valid email
        emailFifth.plainTextBody = 'Here is test plainText body of the email\nТелефон 7777777\n';
        emailFifth.fromAddress ='anna.rudas@fleetcor.ru';
        emailFifth.subject = '##email:test@test.com test';

        // Sixth email test. Test invalid email
        emailSixth.plainTextBody = 'Here is test plainText body of the email\nТелефон 7777777\n';
        emailSixth.fromAddress ='anna.rudas@fleetcor.pl';
        emailSixth.subject = '##email:test@test.com test';

        EmailToLeadRussiaService service = new EmailToLeadRussiaService();

        boolean isFirstEmailValid = service.checkEmailForSpam(emailFirst);
        System.assert(true, isFirstEmailValid);

        boolean isSecondEmailValid = service.checkEmailForSpam(emailSecond);
        System.assert(true, isSecondEmailValid);

        boolean isThirdEmailValid = service.checkEmailForSpam(emailThird);
        System.assert(true, isThirdEmailValid);

        boolean isForthEmailValid = service.checkEmailForSpam(emailForth);
        System.assert(true, isForthEmailValid);

        boolean isFifthEmailValid = service.checkEmailForSpam(emailFifth);
        System.assert(true, isFifthEmailValid);

        boolean isSixthEmailValid = service.checkEmailForSpam(emailSixth);
        System.assertEquals(false, isSixthEmailValid, 'Email domain does not contain postfix .ru');
    }
}