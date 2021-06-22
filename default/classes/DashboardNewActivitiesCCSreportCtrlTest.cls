@isTest
private class DashboardNewActivitiesCCSreportCtrlTest {
    public static User saleRep;
    public static Account newAccount;
    public static Opportunity newOpp;
    public static Contact newContact;
    public static Lead newLead; 
    public static Task newTask1;
    public static Task newTask2;
    public static Event newEvent1;
    public static Event newEvent2;
    public static Event newEvent3;

    @isTest
    public static void testNewActivitiesCCSreport() {  
        Test.startTest();
            createSaleCCSUser();
        Test.stopTest();    

        System.runAs(saleRep) {
            createAccount();
            createOpp();
            createContact();
            createLead();
            createTasks();
            createEvents();

            Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
                insert year;

            Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
                Name = 'November', 
                Start_Date__c = Date.today().addDays(-15),
                End_Date__c = Date.today().addDays(15),
                Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
                Start_Date__c = Date.today().addDays(-3), 
                End_Date__c = Date.today().addDays(4),
                Fleetcor_Calendar_Month__c = month.Id);
            insert week;

            Sales_Plan__c plan = new Sales_Plan__c(User__c = saleRep.Id, Fleetcor_Calendar_Month__c = month.Id);
            insert plan;

            DashboardNewActivitiesCCSreportCtrl controller = new DashboardNewActivitiesCCSreportCtrl();
            ApexPages.currentPage().getParameters().put('userId', saleRep.Id);
            ApexPages.currentPage().getParameters().put('year', String.valueOf(Date.today().year()));
            ApexPages.currentPage().getParameters().put('period', week.Id);
            controller.init();
            controller.getPeriodsList();
            controller.getYearsList();
            controller.returnCurrentYear();
            controller.changeYear();
        }
    }


    @future
    private static void createSaleCCSUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS CZ Telesales'];
        
        saleRep = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_32432_test@test.com',
            Alias = 'saleCCS',
            Email = 'tommy.li_jones@tommyenterprises.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Tommy',
            Lastname = 'Li Jones',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(saleRep);
    }

    private static void createAccount() {
        newAccount = new Account(
            Name = 'test',
            OwnerId = saleRep.Id,
            GFN_Nr__c  = '123',
            Type = 'Customer',
            Bundesland__c = 'Germany',
            BillingStreet = 'test street',
            BillingPostalCode = '1231',
            BillingCity = 'Berlin',
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

    private static void createOpp() {
        newOpp = new Opportunity(
            OwnerId = saleRep.Id, 
            AccountId = newAccount.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Sec_Channel__c = 'Inbound',
            Anzahl_der_Karten__c = 5,
            Gruende_verloren__c = 'test',
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Total_consumption_l_month__c = 123,
            Name_of_the_payer_Account_holder__c = 'test',
            Last_Owner_Change_Date__c = Date.today(),
            Number_of_Vehicles__c = 123,
            Angebotsdauer__c = '3 Monate',
            IBAN__c = '2131',
            SWIFT_BIC__c = '1234124',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            StageName = 'Prospecting',
            Product__c = 'None',
            Name = 'test opp',
            Disable_for_KPI__c = FALSE,
            CloseDate = Date.today());
        insert newOpp;
    }

    private static void createContact() {
        newContact = new Contact(
            Salutation = 'Herr',
            FirstName = 'Bob',
            LastName  = 'Test',
            Email = 'test@test.com',
            MailingCountry = 'Germany',
            MailingStreet = '298 S. Ringo Street',
            MailingCity = 'Little Rock',
            MailingState = 'Berlin',
            MailingPostalCode = '72201'     
        );
        insert newContact;  
    }

    private static void createLead() {
        newLead = new Lead(
            OwnerId = saleRep.Id,
            Country = 'Germany',
            CountryCode = 'DE',
            Company = 'test company',
            Salutation = 'Herr',
            Anzahl_der_Karten_Euroshell__c = 'test',
            Anzahl_der_Fahrzeuge__c = 2, 
            FirstName = 'testName', 
            LastName = 'testFam',  
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Last_Owner_Change_Date__c = Date.today(),
            Quali_Status__c = 'Refused to talk',
            Branche_NACE__c = 'Apotheken - 4773',
            Beschaeftigte__c = '1-4',
            Disable_for_KPI__c = FALSE           
        );
        insert newLead;
    } 

    public static void createTasks() {
        List<Task> tasksToInsertList = new List<Task>();
        newTask1 = new Task(
            OwnerId = saleRep.Id,
            Subject = 'Other',
            Priority= 'Normal',
            Status = 'In Progress',
            Type = 'Anruf',
            WhoId = newLead.Id,
            ActivityDate = Date.today().addDays(-2)
        );
        tasksToInsertList.add(newTask1);

        newTask2 = new Task(
            OwnerId = saleRep.Id,
            Subject = 'Other',
            Priority= 'Normal',
            Status = 'In Progress',
            Type = 'Anruf',
            WhoId = newContact.Id,
            WhatId = newOpp.Id,
            ActivityDate = Date.today().addDays(-2)
        );
        tasksToInsertList.add(newTask2);
        insert tasksToInsertList;
    }

    private static void createEvents() {
        List<Event> eventsToInsertList = new List<Event>();
        newEvent1 = new Event(
            Subject = 'Test Event1',
            OwnerId = saleRep.Id,
            Type = 'První schůzka',
            WhoId = newLead.Id,
            DurationInMinutes = System.now().millisecond() + 1,
            ActivityDateTime = Datetime.now()
        );
        eventsToInsertList.add(newEvent1);

        newEvent2 = new Event(
            Subject = 'Test Event2',
            OwnerId = saleRep.Id,
            Type = 'První schůzka',
            WhoId = newContact.Id,
            WhatId = newOpp.Id,
            DurationInMinutes = System.now().millisecond() + 1,
            ActivityDateTime = Datetime.now()
        );
        eventsToInsertList.add(newEvent2);

        newEvent3 = new Event(
            Subject = 'Test Event3',
            OwnerId = saleRep.Id,
            Type = 'Retence',
            WhoId = newContact.Id,
            WhatId = newAccount.Id,
            DurationInMinutes = System.now().millisecond() + 1,
            ActivityDateTime = Datetime.now()
        );
        eventsToInsertList.add(newEvent3);
        insert eventsToInsertList;
    }
}