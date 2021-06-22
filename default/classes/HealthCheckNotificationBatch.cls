public class HealthCheckNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static Integer HEALTH_STARTTIME = 9;
    public static Integer HEALTH_ENDTIME = 21;

    private static String HEALTH_CHECK_NAME = 'NoOpportunity';
    private static String HEALTH_CHECK_ERROR = 'No E2E Opportunity';

    private static Id noReplayEmailId = null;

    private String query;
    private Datetime previousHourStart;
    private Datetime previousHourEnd;
    private Map<String, HealthEmails> emails;
    private Set<String> countries;

    private Set<String> withOpportunities;

    public HealthCheckNotificationBatch() {
        this.query = 'SELECT Registered_Country__c ' +
                     'FROM Opportunity ' +
                     'WHERE E2E__c = TRUE AND Registered_Country__c IN :countries ' +
                        'AND CreatedDate >= :previousHourStart AND CreatedDate <= :previousHourEnd';

        this.emails = getHealthCheckNotificationSettings();
        this.countries = this.emails.keySet();

        this.withOpportunities = new Set<String>();

        this.previousHourStart = this.getPreviousHourStartDatetime();
        this.previousHourEnd = this.getPreviousHourEndDatetime();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer hours = Datetime.now().hour(); 
        if ((hours >= HEALTH_STARTTIME && hours <= HEALTH_ENDTIME) || Test.isRunningTest()) {
            return Database.getQueryLocator(this.query);            
        }
        return Database.getQueryLocator('SELECT Id FROM Opportunity WHERE CreatedDate < 1990-05-22T21:05:36.000+0000 LIMIT 1'); 
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        for (Opportunity opp : scope) {
            this.withOpportunities.add(opp.Registered_Country__c.toUpperCase());
        }
    }

    public void finish(Database.BatchableContext BC) {
        Integer hours = Datetime.now().hour(); 
        if ((hours >= HEALTH_STARTTIME && hours <= HEALTH_ENDTIME) || Test.isRunningTest()) {
            List<Health_Check__c> healthChecks = new List<Health_Check__c>();
            List<Messaging.SingleEmailMessage> emailsTo = new List<Messaging.SingleEmailMessage>();

            this.populateNoReplayEmail();

            for (String country : this.emails.keySet()) {
                if ( ! this.withOpportunities.contains(country.toUpperCase()) ) {
                    emailsTo.add(this.buildEmail(
                        this.emails.get(country).emails,
                        this.emails.get(country).emailSubject,
                        this.emails.get(country).emailBody
                    ));

                    healthChecks.add(new Health_Check__c(
                        Name=HEALTH_CHECK_NAME,
                        Country__c=country,
                        Error__c=HEALTH_CHECK_ERROR,
                        Error_Description__c=this.getErrorDescription()
                    ));
                }
            }

            if ( ! healthChecks.isEmpty() ) {
                insert healthChecks;

                this.sendEmails(emailsTo);
            }
        }                    
    }

    public Map<String, HealthEmails> getHealthCheckNotificationSettings() {
        Map<String, HealthEmails> resultMap = new Map<String, HealthEmails>();

        List<Health_Check_Notification__c> settings = [
                SELECT Country__c, Emails__c, Email_Subject__c, Email_Body__c 
                FROM Health_Check_Notification__c 
                WHERE Active__c = TRUE
        ];

        for (Health_Check_Notification__c setting : settings) {
            if ( ! resultMap.containsKey(setting.Country__c) ) {
                resultMap.put(
                    setting.Country__c,
                    new HealthEmails(
                        setting.Country__c, setting.Email_Subject__c, setting.Email_Body__c, setting.Emails__c
                    )
                );
            }

            resultMap.get(setting.Country__c).populateData(
                setting.Email_Subject__c, setting.Email_Body__c, setting.Emails__c
            );
        }

        return resultMap;
    }

    private Datetime getPreviousHourStartDatetime() {
        Datetime previousHourDatetime = Datetime.now().addHours(-1);
        return Datetime.newInstance(
            previousHourDatetime.year(),
            previousHourDatetime.month(),
            previousHourDatetime.day(),
            previousHourDatetime.hour(),
            0,
            0
        );
    }

    private Datetime getPreviousHourEndDatetime() {
        Datetime previousHourDatetime = Datetime.now().addHours(-1);
        return Datetime.newInstance(
            previousHourDatetime.year(),
            previousHourDatetime.month(),
            previousHourDatetime.day(),
            previousHourDatetime.hour(),
            59,
            59
        );
    }

    private void populateNoReplayEmail() {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
        if (owea.size() > 0) {
            noReplayEmailId = owea[0].Id;
        }
    }

    private Messaging.SingleEmailMessage buildEmail(Set<String> emails, String subject, String body) {
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        
        if (noReplayEmailId != null) {
            singleEmail.setOrgWideEmailAddressId(noReplayEmailId);
        }

        singleEmail.setSubject(subject);
        singleEmail.setToAddresses(new List<String>(emails));
        singleEmail.setPlainTextBody(body);

        return singleEmail;
    }

    private void sendEmails(List<Messaging.SingleEmailMessage> emails) {
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }

    private String getErrorDescription() {
        return 'No E2E Opportunity from ' + this.previousHourStart.formatGMT('yyyy-MM-dd\'T\'HH:mm:ssZ') + 
               ' to ' + this.previousHourEnd.formatGMT('yyyy-MM-dd\'T\'HH:mm:ssZ');
    }

    public class HealthEmails {

        public String country {get;set;}
        public String emailSubject {get;set;}
        public String emailBody {get;set;}
        public Set<String> emails {get;set;}

        public HealthEmails(String country, String emailSubject, String emailBody, String emails) {
            this.country = country;
            this.emailSubject = emailSubject;
            this.emailBody = emailBody;
            this.emails = this.parseEmails(emails);
        }

        public void populateData(String subject, String body, String emails) {
            this.populateEmailInfo(subject, body);
            this.addEmails(emails);
        }

        private void addEmails(String emails) {
            this.emails.addAll(this.parseEmails(emails));
        }

        private void populateEmailInfo(String subject, String body) {
            if (String.isNotBlank(subject)) {
                this.emailSubject = subject;
            }
            if (String.isNotBlank(body)) {
                this.emailBody = body;
            }
        }

        private Set<String> parseEmails(String emails) {
            Set<String> result = new Set<String>();
            for (String email : emails.split(',')) {
                if (String.isNotBlank(email.trim())) {
                    result.add(email.trim());
                }
            }
            return result;
        }
    }
}