@isTest
private class DashboardCardsAndGPSUnitsSoldCCSctrlTest {
    public static User teamlead;
    public static User saleRep;
    public static Opportunity newOpp;

    @isTest
    public static void testCardsAndGpsUnitsSoldTeamLead() {
        Test.startTest();
            createTeamLeadCCSUser();
            createSaleCCSUser();
        Test.stopTest();

        System.runAs(teamlead) {
            createOpp();

            Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
            insert year;

            Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
                Name = 'October',
                Month_Number__c = 10, 
                Start_Date__c = Date.today().addDays(-10),
                End_Date__c = Date.today().addDays(20),
                Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
                Start_Date__c = Date.today().addDays(-3), 
                End_Date__c = Date.today().addDays(4),
                Fleetcor_Calendar_Month__c = month.Id);
            insert week;    

            DashboardCardsAndGPSUnitsSoldCCSctrl controller = new DashboardCardsAndGPSUnitsSoldCCSctrl();
            controller.init();
            controller.getPeriodsList();
            controller.getYearsList();      
            controller.selectedPeriod = month.Id;
            controller.init();
            controller.changeYear();
        }
    }

    @isTest
    public static void testCardsAndGpsUnitsSoldSaleRep() {
        Test.startTest();
            createSaleCCSUser();
        Test.stopTest();

        System.runAs(saleRep) {
            createOpp();    

            Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
            insert year;

            Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
                Name = 'October',
                Month_Number__c = 10, 
                Start_Date__c = Date.today().addDays(-11),
                End_Date__c = Date.today().addDays(20),
                Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
                Start_Date__c = Date.today().addDays(-3), 
                End_Date__c = Date.today().addDays(4),
                Fleetcor_Calendar_Month__c = month.Id);
            insert week;

            DashboardCardsAndGPSUnitsSoldCCSctrl controller = new DashboardCardsAndGPSUnitsSoldCCSctrl();
            controller.init();
        }
    }

    @future
    private static void createTeamLeadCCSUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Salesteamleiter Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS Telesales Team Lead'];
        
        teamlead = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_23423_test@test.com',
            Alias = 'teamlead',
            Email = 'will.smith_1233@willenterprises.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Will',
            Lastname = 'Smith',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(teamlead);
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

    private static void createOpp() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'CCS Opportunity Layout' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpp = new Opportunity(
            OwnerId = saleRep.Id,
            RecordTypeId = rt.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Name_of_the_payer_Account_holder__c = 'test',
            IBAN__c = '12312412341',
            SWIFT_BIC__c = '123123123',
            Total_consumption_l_month__c = 123,
            Number_of_Vehicles__c = 7,
            Number_of_GPS_units__c = 10,
            Anzahl_der_Karten__c = 5,
            Sec_Channel__c = 'Inbound',
            Product_Solicited__c = 'CCS Business',
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Angebotsdauer__c = 'test',
            StageName = 'Closed Won',
            Name = 'test opp',
            Product__c = 'None',
            Disable_for_KPI__c = FALSE,
            Last_Owner_Change_Date__c = Date.today(),
            CloseDate = Date.today()
        );
        insert newOpp;
    }
}