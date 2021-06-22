@isTest
private class BatchCheckingStartsStatusTest {
	public static User u;
    public static Account newAccount;
	public static Opportunity newOpportunity;
	public static EmailTemplate emailTeamplteForOwner;
	public static EmailTemplate emailTeamplteForStartsRep;
	public static EmailTemplate emailTeamplteForBO;
    public static BackOffice_Notifications__c customSettings;


    /*******************************************************************************
    *  Name            : testCheckingStartsStatus1()
    *  Summary         : Checking Starts status delay. Sending notification to back-office    
    *  CreatedDate     : 11/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
   	public static void testCheckingStartsStatus1() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();  
            createEmailTemplates();
            createCustomSetting();

        	BatchCheckingStartsStatus batch = new BatchCheckingStartsStatus();
        	Database.executeBatch(batch);    
        }    
   	}


    /*******************************************************************************
    *  Name            : testCheckingStartsStatus2()
    *  Summary         : Checking Starts status delay. Sending notification to opportunity owner    
    *  CreatedDate     : 11/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckingStartsStatus2() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();  
            createEmailTemplates();
            createCustomSetting();

            newOpportunity.Starts_Status__c = '1. Customer registered in GFN (card issued & delivered)';
            update newOpportunity;

            BatchCheckingStartsStatus batch = new BatchCheckingStartsStatus();
            Database.executeBatch(batch);    
        }    
    }


    /*******************************************************************************
    *  Name            : testCheckingStartsStatus3()
    *  Summary         : Checking Starts status delay. Sending notification to Starts rep    
    *  CreatedDate     : 11/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckingStartsStatus3() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();  
            createEmailTemplates();
            createCustomSetting();

            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell Starts' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newOpportunity.Starts_Status__c = '2.2 First Check: Not Reached';
            update newOpportunity;

            BatchCheckingStartsStatus batch = new BatchCheckingStartsStatus();
            Database.executeBatch(batch);    
        }    
    }


   	@future
    private static void createSalesUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Credit'];         
        u = new User(
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_21112323_test@test.com',
            Alias = 'batman',
            Email='backoffice@fleetcor.de',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(u);    
    }

    private static void createAccount() {
        newAccount = new Account(
            Name = 'test',
            GFN_Nr__c  = '123',
            Type = 'Customer',
            Bundesland__c = 'Germany',
            BillingCountry = 'Germany',
            Beschaeftigte__c = '1-4',
            Strasse_E__c = 'test',
            Hausnummer_E__c = 'test',
            PLZ_E__c = 'test',
            Ort_E__c = 'tet',
            Land_E__c = 'DE',
            Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
            Strasse_und_Hausnummer__c = 'tes',
            PLZ_und_Ort__c = 'test',
            IBAN_des_Zahlungspflichtigen__c = 'tes',                    
            SWIFT_BIC__c = 'test',
            Land__c = 'test land',
            Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
            Kraftstoffverbrauch_Liter_Monat__c = 2);
        insert newAccount;
    }

    private static void createOpportunity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            OwnerId = u.Id,
            RecordTypeId = rt.Id,
            AccountId = newAccount.Id,
            Name = 'test opportunity',
            Starts_Status__c = '0. Request received',
            Starts_Schedule__c = Date.today().addDays(-1),
            Starts_Status_Delay__c = false,
            Anzahl_der_Karten__c = 123,
            Zahlungsart__c = 'Lastschrift',
            Name_of_the_payer_Account_holder__c = 'test payer',
            Angebotsdauer__c = 'test',
            Language_preference__c = 'Polish',
            Product__c = 'Home Station offer (v.1)',
            Home_Station__c = '123test',
            IBAN__c = '23424',
            SWIFT_BIC__c = '23423',
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-50),
            Bevollmaechtigung__c = true
        );
        insert newOpportunity;
    }

    private static void createEmailTemplates() {
        emailTeamplteForOwner = new EmailTemplate(
            Name = 'SLA Overdue to Oppty Owner',
            DeveloperName = 'SLA_Overdue_to_OpptyOwner',
            Subject = 'Notification',
            Body = 'test1',
            TemplateType = 'Text',
            FolderId = UserInfo.getUserId()
        );
        insert emailTeamplteForOwner;

        emailTeamplteForStartsRep = new EmailTemplate(
            Name = 'SLA Overdue to Starts Rep',
            DeveloperName = 'SLA_Overdue_to_StartsRep',
            Subject = 'Notification',
            Body = 'test2',
            TemplateType = 'Text',
            FolderId = UserInfo.getUserId()
        );
        insert emailTeamplteForStartsRep;

        emailTeamplteForBO = new EmailTemplate(
            Name = 'SLA Overdue to BO',
            DeveloperName = 'SLA_Overdue_to_BackOffice',
            Subject = 'Notification',
            Body = 'test3',
            TemplateType = 'Text',
            FolderId = UserInfo.getUserId()
        );
        insert emailTeamplteForBO;
    }

    private static void createCustomSetting() {
        customSettings = new BackOffice_Notifications__c();
        customSettings.Name = 'Germany';
        customSettings.Email__c = 'test@test.com';
        customSettings.Active__c = true;
        insert customSettings;
    }
}