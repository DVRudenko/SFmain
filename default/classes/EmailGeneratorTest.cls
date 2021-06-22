@IsTest private class EmailGeneratorTest {

    static testMethod void testBehavior1() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;
        EmailGenerator.sendHtmlEmail(user.id, 'Test', 'Test');
    }

    static testMethod void testBehavior2() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;
        List<id> emailsUserTest = new List<id>();
        emailsUserTest.add(user.id);
        EmailGenerator.sendHtmlEmail(emailsUserTest, 'Test', 'Test');
    }

    @isTest
    private static void testgetemail() {
        String[] address = new String[]{
                'usertest@fleetcor.ru'
        };
        OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
        String subject = 'Test subject';
        String emailBody = 'Test Body';
        String htmlTemplate = '<head><META http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>\n' +
                '<table>' +
                '<tr><th filter=all>Account #</th></tr>\n' +
                '<tr><td>FC-001152661</td></tr>\n' +
                '</table>';

        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        Blob excel = Blob.valueOf(htmlTemplate);
        attach.setBody(excel);

        Messaging.SingleEmailMessage email = EmailGenerator.prepareHtmlEmailToTarget(address, subject, emailBody);
        System.assertEquals(true, email != null);
    }

    @isTest
    private static void testgetEmail2() {
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
                TimeZoneSidKey = 'America/Chicago');
        insert user;
        OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
        String subject = 'Test subject';
        String emailBody = 'Test Body';
        String htmlTemplate = '<head><META http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>\n' +
                '<table>' +
                '<tr><th filter=all>Account #</th></tr>\n' +
                '<tr><td>FC-001152661</td></tr>\n' +
                '</table>';

        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        Blob excel = Blob.valueOf(htmlTemplate);
        attach.setBody(excel);

        Messaging.SingleEmailMessage email = EmailGenerator.prepareHtmlEmailToTarget (user.id, subject, emailBody);
        System.assertEquals(true, email != null);
    }

    @isTest
    private static void testSendEmailWithAttachment() {
        String[] address = new String[]{
                'usertest@fleetcor.ru'
        };
        OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
        String subject = 'Test subject';
        String emailBody = 'Test Body';
        String htmlTemplate = '<head><META http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>\n' +
                '<table>' +
                '<tr><th filter=all>Account #</th></tr>\n' +
                '<tr><td>FC-001152661</td></tr>\n' +
                '</table>';

        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        Blob excel = Blob.valueOf(htmlTemplate);
        attach.setBody(excel);

        Messaging.SingleEmailMessage email = EmailGenerator.sendHtmlEmailWithAttachment(address, orgEmails, subject, emailBody, attach);
        System.assertEquals(true, email != null);
    }

    @IsTest
    public static void testTemplateDisqualificationLead() {
        User[] receivers = ([SELECT Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 3]);
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            Lead lead = new Lead(
                    LastName = 'Duplicated Lead ' + i, Email = 'duplicatedLead@test.ru',
                    Phone = '1234567', IsConverted = false, INN__c = '0000555511',
                    Country = 'Germany', CountryCode = 'DE', Company = 'Test company', OwnerId = receivers[i].Id
            );
            leads.add(lead);
        }
        insert leads;
        leads = ([
                SELECT Name, INN__c, Phone
                FROM Lead
                WHERE Name LIKE '%Duplicated Lead %'
                LIMIT 3
        ]);

        Map<Set<Id>, Map<String, Object>> emailParams = new Map<Set<Id>, Map<String, Object>>();
        String domainUrl = Url.getOrgDomainUrl().toExternalForm();
        Integer i = 0;
        for (Lead lead : leads) {
            emailParams.put(
                    new Set<Id>{
                            receivers[i].Id
                    },
                    new Map<String, Object>{
                            '/$lead.Owner.Name$/' => receivers[i].Name,
                            '/$domainUrl$/' => domainUrl,
                            '/$lead.Id$/' => lead.Id,
                            '/$lead.Name$/' => lead.Name,
                            '/$lead.INN__c$/' => lead.INN__c,
                            '/$lead.Phone$/' => lead.Phone
                    }
            );
            i++;
        }
        try {
            Map<Set<Id>, EmailTemplate> templatesByIds = EmailGenerator.getEmailTemplatesMap(GlobalUtils.EmailTemplateDevName.E2E_RU_Disqualification_Lead, emailParams);
            for (Set<Id> ids : templatesByIds.keySet()) {
                System.debug('SUBJECT AFTER REPLACING: ' + templatesByIds.get(ids).Subject);
                System.debug('BODY AFTER REPLACING:' + templatesByIds.get(ids).HtmlValue);
            }
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateRefusingOpportunity() {

        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            Opportunity opportunity = new Opportunity(Name = 'Test opportunity ' + i, StageName = 'Propose', CloseDate = Date.today());
            opportunities.add(opportunity);
        }
        insert opportunities;

        Map<Set<Id>, Map<String, Object>> emailParams = new Map<Set<Id>, Map<String, Object>>();
        String domainUrl = Url.getOrgDomainUrl().toExternalForm();
        User[] receivers = ([SELECT Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 3]);
        Integer i = 0;
        for (Opportunity opportunity : opportunities) {
            emailParams.put(
                    new Set<Id>{
                            receivers[i].Id
                    },
                    new Map<String, Object>{
                            '/$domainUrl$/' => domainUrl,
                            '/$opportunity.Id$/' => opportunity.Id
                    }
            );
            i++;
        }
        try {
            Map<Set<Id>, EmailTemplate> templatesByIds = EmailGenerator.getEmailTemplatesMap(GlobalUtils.EmailTemplateDevName.E2E_RU_Refusing_Opportunity, emailParams);
            for (Set<Id> ids : templatesByIds.keySet()) {
                System.debug('SUBJECT AFTER REPLACING: ' + templatesByIds.get(ids).Subject);
                System.debug('BODY AFTER REPLACING:' + templatesByIds.get(ids).HtmlValue);
            }
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateTransferToService() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opportunity = new Opportunity(Name = 'Test opportunity' + i, StageName = 'Propose', CloseDate = Date.today());
            opportunities.add(opportunity);
        }
        insert opportunities;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Service,
                    new Map<String, Object>{
                            '/$opportunities$/' => opportunities
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateTransferToKoINN() {
        Account sfAccount = new Account();
        sfAccount.INN__c = '1234567890';
        sfAccount.Name = 'Test acc';
        sfAccount.BillingCountry = 'Germany';
        insert sfAccount;

        Contact e2eContact = new Contact();
        e2eContact.MobilePhone = '88005553535';
        e2eContact.Email = 'BetterCallThan@TakeALoan.ru';
        e2eContact.LastName = 'Surname';
        insert e2eContact;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Ko_With_INN,
                    new Map<String, Object>{
                            '/$domainUrl$/' => Url.getOrgDomainUrl().toExternalForm(),
                            '/$sfAccount.INN__c$/' => sfAccount.INN__c,
                            '/$sfAccount.Id$/' => sfAccount.Id,
                            '/$sfAccount.Name$/' => sfAccount.Name,
                            '/$e2eContact.MobilePhone$/' => e2eContact.MobilePhone,
                            '/$e2eContact.Email$/' => e2eContact.Email
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateTransferToKoEmail() {

        Account sfAccount = new Account();
        sfAccount.Name = 'Salesforce account';
        sfAccount.BillingCountry = 'Germany';
        insert sfAccount;

        Account e2eAccount = new Account();
        e2eAccount.Name = 'E2E account';
        e2eAccount.BillingCountry = 'Germany';
        insert e2eAccount;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Ko_With_Email,
                    new Map<String, Object>{
                            '/$domainUrl$/' => Url.getOrgDomainUrl().toExternalForm(),
                            '/$sfAccount.Id$/' => sfAccount.Id,
                            '/$sfAccount.Name$/' => sfAccount.Name,
                            '/$e2eAccount.Id$/' => e2eAccount.Id,
                            '/$e2eAccount.Name$/' => e2eAccount.Name
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateTransferToInbound() {

        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opportunity = new Opportunity(Name = 'Test opportunity' + i, StageName = 'Propose', CloseDate = Date.today());
            opportunities.add(opportunity);
        }
        insert opportunities;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Inbound,
                    new Map<String, Object>{
                            '/$opportunities$/' => opportunities
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateCoordinationRiskManagementDepartment() {

        Opportunity opportunity = new Opportunity(Name = 'Test opportunity', StageName = 'Propose', CloseDate = Date.today());
        insert opportunity;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Coordination_With_Risk_Management_Department,
                    new Map<String, Object>{
                            '/$domainUrl$/' => Url.getOrgDomainUrl().toExternalForm(),
                            '/$opportunity.Id$/' => opportunity.Id
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateReseller() {

        Opportunity opportunity = new Opportunity(Name = 'Test opportunity', StageName = 'Propose', CloseDate = Date.today());
        insert opportunity;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Reseller,
                    new Map<String, Object>{
                            '/$domainUrl$/' => Url.getOrgDomainUrl().toExternalForm(),
                            '/$opportunity.Id$/' => opportunity.Id
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateWarningNotificationCallCenter() {

        Opportunity opportunity = new Opportunity(Name = 'Test opportunity', StageName = 'Propose', CloseDate = Date.today());
        insert opportunity;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Warning_Notification_Call_Center,
                    new Map<String, Object>{
                            '/$domainUrl$/' => Url.getOrgDomainUrl().toExternalForm(),
                            '/$opportunity.Id$/' => opportunity.Id,
                            '/$opportunity.Name$/' => opportunity.Name
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateTransferToKOManualEntry() {

        Opportunity opportunity = new Opportunity(Name = 'Test opportunity', StageName = 'Propose', CloseDate = Date.today());
        insert opportunity;

        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_KO_Manual_Entry,
                    new Map<String, Object>{
                            '/$domainUrl$/' => Url.getOrgDomainUrl().toExternalForm(),
                            '/$opportunity.Id$/' => opportunity.Id
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testTemplateTransferToKOMore10Cards() {

        Opportunity opportunity = new Opportunity(Name = 'Test opportunity', StageName = 'Propose', CloseDate = Date.today());
        insert opportunity;

        Boolean isManualEntry = false;
        Integer cardsNumber = 11;
        try {
            EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                    GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_KO_More_10_Cards,
                    new Map<String, Object>{
                            '/$domainUrl$/' => Url.getOrgDomainUrl().toExternalForm(),
                            '/$opportunity.Id$/' => opportunity.Id,
                            '/$isManualEntry$/' => isManualEntry ? 'Да' : 'Нет',
                            '/$cardsNumber$/' => cardsNumber
                    }
            );
            System.debug('SUBJECT AFTER REPLACING: ' + emailTemplate.Subject);
            System.debug('BODY AFTER REPLACING:' + emailTemplate.HtmlValue);
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }
    }
}