@isTest
class HealthCheckNotificationBatchTest {
    
    @isTest
    static void testScheduler() {
        Test.startTest();

        String sch = '0 1 21 * * ? *';
        String schName = 'Health Check Notification 09 PM';
        
        String jobId = System.schedule(schName, sch, new HealthCheckNotificationScheduler());
        
        Test.stopTest();

        CronTrigger ct = [
            SELECT CronExpression
            FROM CronTrigger WHERE Id = :jobId
        ];
        System.assertEquals(sch, ct.CronExpression);
    }

    @isTest
    static void testHealthNotifications() {
        initData();

        Test.startTest();
        Database.executeBatch(new HealthCheckNotificationBatch());
        Test.stopTest();

        List<Health_Check__c> checks = [
                SELECT Country__c, Error__c, Error_Description__c
                FROM Health_Check__c
        ];

        System.assertEquals(1, checks.size());
        System.assertEquals('Germany', checks[0].Country__c);
    }

    static void initData() {
        List<Health_Check_Notification__c> settings = new List<Health_Check_Notification__c>{
            new Health_Check_Notification__c(
                Name='DE1',
                Country__c='germany',
                Emails__c='test1@test.com,test2@test.com',
                Email_Subject__c='DE Subject',
                Email_Body__c='DE Body'
            ),
            new Health_Check_Notification__c(
                Name='DE2',
                Country__c='germany',
                Emails__c='test3@test.com,test4@test.com',
                Email_Subject__c='DE Subject',
                Email_Body__c='DE Body'
            ),
            new Health_Check_Notification__c(
                Name='NE1',
                Country__c='netherlands',
                Emails__c='test5@test.com,test6@test.com',
                Email_Subject__c='NE Subject',
                Email_Body__c='NE Body',
                Active__c=false
            ),
            new Health_Check_Notification__c(
                Name='NE2',
                Country__c='netherlands',
                Emails__c='test7@test.com,test8@test.com',
                Email_Subject__c='NE Subject',
                Email_Body__c='NE Body',
                Active__c=false
            )
        };
        insert settings;

        List<Account> accounts = new List<Account>{
            // Germany
            new Account(
                Name='DE Account',
                GFN_Nr__c  = '123',
                Type='Customer',
                Bundesland__c='Germany',
                BillingCountry='Germany',
                Beschaeftigte__c='1-4',
                Strasse_E__c='test1',
                Hausnummer_E__c='test1',
                PLZ_E__c='test1',
                Ort_E__c='te1',
                Land_E__c='DE',
                Name_Zahlungspflichtigen_Kontoinhaber__c='test1',
                Strasse_und_Hausnummer__c='test1',
                PLZ_und_Ort__c='test1',
                IBAN_des_Zahlungspflichtigen__c='test1',
                SWIFT_BIC__c='test1',
                Land__c='test1 land',
                Gruende_fuer_Tankkarten__c='vereinfachte Abrechnung 1',
                Kraftstoffverbrauch_Liter_Monat__c=2
            ),
            // Netherlands
            new Account(
                Name='NE Account',
                GFN_Nr__c  = '1232',
                Type='Customer',
                Bundesland__c='Netherlands',
                BillingCountry='Netherlands',
                Beschaeftigte__c='1-4',
                Strasse_E__c='test2',
                Hausnummer_E__c='test2',
                PLZ_E__c='test2',
                Ort_E__c='te2',
                Land_E__c='NE',
                Name_Zahlungspflichtigen_Kontoinhaber__c='test2',
                Strasse_und_Hausnummer__c='test2',
                PLZ_und_Ort__c='test2',
                IBAN_des_Zahlungspflichtigen__c='test2',
                SWIFT_BIC__c='test2',
                Land__c='test2 land',
                Gruende_fuer_Tankkarten__c='vereinfachte Abrechnung 2',
                Kraftstoffverbrauch_Liter_Monat__c=2
            ),
            // Poland
            new Account(
                Name='PL Account',
                GFN_Nr__c  = '1233',
                Type='Customer',
                Bundesland__c='Poland',
                BillingCountry='Poland',
                Beschaeftigte__c='1-4',
                Strasse_E__c='test3',
                Hausnummer_E__c='test3',
                PLZ_E__c='test3',
                Ort_E__c='te3',
                Land_E__c='PL',
                Name_Zahlungspflichtigen_Kontoinhaber__c='test3',
                Strasse_und_Hausnummer__c='test3',
                PLZ_und_Ort__c='test3',
                IBAN_des_Zahlungspflichtigen__c='test3',
                SWIFT_BIC__c='test3',
                Land__c='test3 land',
                Gruende_fuer_Tankkarten__c='vereinfachte Abrechnung 3',
                Kraftstoffverbrauch_Liter_Monat__c=2
            )
        };
        insert accounts;

        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        List<Opportunity> opps = new List<Opportunity>{
            // Germany
            new Opportunity(
                RecordTypeId=rt.Id,
                AccountId=accounts[0].Id,
                Name='test opportunity ge',
                Starts_Status__c='0. Request received',
                Starts_Schedule__c=Date.today().addDays(-1),
                Starts_Status_Delay__c=false,
                Anzahl_der_Karten__c=123,
                Zahlungsart__c='Lastschrift',
                Name_of_the_payer_Account_holder__c='test payer',
                Angebotsdauer__c='test',
                Language_preference__c='Polish',
                Product__c='Home Station offer (v.1)',
                Home_Station__c='123test',
                IBAN__c='23424',
                SWIFT_BIC__c='23423',
                Derzeitige_Zahlungsmethode__c='Barzahlung',
                Requested_monthly_Company_Credit_Spend__c=12345,
                AGB_Datenschutzhinweise_Richtigkeit__c=true,
                Data_Protection_Act_1998__c=true,
                Umsatz__c='123', 
                StageName='Closed Won',
                CloseDate=Date.today().addDays(-50),
                Bevollmaechtigung__c=true,
                E2E__c=true
            ),
            // Netherlands
            new Opportunity(
                RecordTypeId=rt.Id,
                AccountId=accounts[1].Id,
                Name='test opportunity ne',
                Starts_Status__c='0. Request received',
                Starts_Schedule__c=Date.today().addDays(-1),
                Starts_Status_Delay__c=false,
                Anzahl_der_Karten__c=123,
                Zahlungsart__c='Lastschrift',
                Name_of_the_payer_Account_holder__c='test payer',
                Angebotsdauer__c='test',
                Language_preference__c='Polish',
                Product__c='Home Station offer (v.1)',
                Home_Station__c='123test',
                IBAN__c='23424',
                SWIFT_BIC__c='23423',
                Derzeitige_Zahlungsmethode__c='Barzahlung',
                Requested_monthly_Company_Credit_Spend__c=12345,
                AGB_Datenschutzhinweise_Richtigkeit__c=true,
                Data_Protection_Act_1998__c=true,
                Umsatz__c='123', 
                StageName='Closed Won',
                CloseDate=Date.today().addDays(-50),
                Bevollmaechtigung__c=true,
                E2E__c=false
            ),
            // Poland
            new Opportunity(
                RecordTypeId=rt.Id,
                AccountId=accounts[2].Id,
                Name='test opportunity pl',
                Starts_Status__c='0. Request received',
                Starts_Schedule__c=Date.today().addDays(-1),
                Starts_Status_Delay__c=false,
                Anzahl_der_Karten__c=123,
                Zahlungsart__c='Lastschrift',
                Name_of_the_payer_Account_holder__c='test payer',
                Angebotsdauer__c='test',
                Language_preference__c='Polish',
                Product__c='Home Station offer (v.1)',
                Home_Station__c='123test',
                IBAN__c='23424',
                SWIFT_BIC__c='23423',
                Derzeitige_Zahlungsmethode__c='Barzahlung',
                Requested_monthly_Company_Credit_Spend__c=12345,
                AGB_Datenschutzhinweise_Richtigkeit__c=true,
                Data_Protection_Act_1998__c=true,
                Umsatz__c='123', 
                StageName='Closed Won',
                CloseDate=Date.today().addDays(-50),
                Bevollmaechtigung__c=true,
                E2E__c=true
            )
        };
        insert opps;
    }
}