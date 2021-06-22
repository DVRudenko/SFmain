@isTest
private class SalesDashboardApprovalRateCCSctrlTest {
    public static User saleTelesales;
    public static User teamleaderTelesales;
    public static Opportunity closedWonOpp;
    public static Opportunity notDuplicateOpp;

    static testMethod void telesalesTeamLeadApprovalRateTest() {
        Test.startTest();
            createSalesUser();
            createLeadUser();
        Test.stopTest();  

        System.runAs(teamleaderTelesales) {
            createOpps();

            Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
            insert year;

            Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
                Name = 'January', 
                Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
                End_Date__c = Date.newInstance(Date.today().year(), 1, 30),
                Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
                Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
                End_Date__c = Date.newInstance(Date.today().year(), 1, 7),
                Fleetcor_Calendar_Month__c = month.Id);
            insert week;

            Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
            insert plan;

            //next year
            Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
            insert nextYear;

            Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
                Name = 'January', 
                Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
                End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 30),
                Fleetcor_Calendar_Year__c = nextYear.Id);
            insert monthOfNextYear;

            Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
                Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
                End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 7),
                Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
            insert weekOfNextYear;

            Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
            insert planOfNextYear;

            SalesDashboardApprovalRateCCSctrl controller = new SalesDashboardApprovalRateCCSctrl();
            controller.init();
            controller.changeYear();
            controller.getYears();
            controller.getcurrentWeeks();
        }   
    }

    static testMethod void telesalesApprovalRateTest() {
        Test.startTest();
            createSalesUser();
            createLeadUser();
        Test.stopTest();  

        System.runAs(saleTelesales) {
            createOpps();

            Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
            insert year;

            Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
                Name = 'January', 
                Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
                End_Date__c = Date.newInstance(Date.today().year(), 1, 30),
                Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
                Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
                End_Date__c = Date.newInstance(Date.today().year(), 1, 7),
                Fleetcor_Calendar_Month__c = month.Id);
            insert week;

            Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
            insert plan;

            //next year
            Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
            insert nextYear;

            Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
                Name = 'January', 
                Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
                End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 30),
                Fleetcor_Calendar_Year__c = nextYear.Id);
            insert monthOfNextYear;

            Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
                Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
                End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 7),
                Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
            insert weekOfNextYear;

            Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
            insert planOfNextYear;

            SalesDashboardApprovalRateCCSctrl controller = new SalesDashboardApprovalRateCCSctrl();
            controller.init();
        }   
    }

    @future
    private static void createSalesUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS CZ Telesales'];
        
        saleTelesales = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_233121_test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(saleTelesales);    
    }

    @future
    private static void createLeadUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Salesteamleiter Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS Telesales Team Lead'];
        
        teamleaderTelesales = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_23423_test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(teamleaderTelesales);
    }

    private static void createOpps() {
        List<Opportunity> opptiesToUpdateList = new List<Opportunity>();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'CCS Opportunity Layout' AND sObjectType = 'Opportunity' LIMIT 1];
        closedWonOpp = new Opportunity(
            RecordTypeId = rt.Id,
            OwnerId = saleTelesales.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Anzahl_der_Karten__c = 5,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'E-mail',
            LeadSource = 'CCS ČSOBL',
            Product_Solicited__c = 'test',
            Number_of_Vehicles__c = 123,
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Angebotsdauer__c = 'test',
            StageName = 'Closed Won',
            Name = 'test opp',
            Product__c = 'None',
            CloseDate = Date.today().addDays(5),
            Disable_for_KPI__c = FALSE
        );
        opptiesToUpdateList.add(closedWonOpp);

        notDuplicateOpp = new Opportunity(
            RecordTypeId = rt.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 3,
            OwnerId = saleTelesales.Id,
            Anzahl_der_Karten__c = 7,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'E-mail',
            LeadSource = 'CCS ČSOBL',
            Number_of_Vehicles__c = 123,
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Angebotsdauer__c = 'test',
            StageName = 'Prospecting',
            Name = 'test opp',
            Product__c = 'None',
            CloseDate = Date.today().addDays(5),
            Disable_for_KPI__c = FALSE
        );
        opptiesToUpdateList.add(notDuplicateOpp);

        insert opptiesToUpdateList;
    }
}