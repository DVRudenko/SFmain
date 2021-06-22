@isTest
private class DashboardStartsSLAoverdueCtrlTest {
    public static User teamlead;
    public static User saleRep;
    public static Opportunity newOpp;


    /*******************************************************************************
    *  Name            : testTeamLeadDashboard()
    *  Summary         : Performs the test for the team leader    
    *  CreatedDate     : 16/01/2018  
    *  ModifiedDate    : 17/01/2018  
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testTeamLeadDashboard() {
        Test.startTest();
            createSaleUser();
            createTeamLeadUser();
        Test.stopTest();

        System.runAs(teamlead) {
            createExpiredOppty();
            
            DashboardStartsSLAoverdueCtrl controller = new DashboardStartsSLAoverdueCtrl();
            controller.init();
        }
    }


    /*******************************************************************************
    *  Name            : testSalesTeamDashboard()
    *  Summary         : Performs the test for the salespoeple    
    *  CreatedDate     : 16/01/2018  
    *  ModifiedDate    : 17/01/2018  
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSalesTeamDashboard() {
        Test.startTest();
            createSaleUser();
            createTeamLeadUser();
        Test.stopTest();

        System.runAs(saleRep) {
            createExpiredOppty();
            
            DashboardStartsSLAoverdueCtrl controller = new DashboardStartsSLAoverdueCtrl();
            controller.init();
        }
    }


    /*******************************************************************************
    *  Name            : createTeamLeadUser()
    *  Summary         : Create the team leader user    
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 17/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @future
    private static void createTeamLeadUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'API Only'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Starts Team Manager'];
        
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


    /*******************************************************************************
    *  Name            : createSaleUser()
    *  Summary         : Create the sales user    
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 17/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @future
    private static void createSaleUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'API Only'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Starts Team Rep'];
        
        saleRep = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_32432_test@test.com',
            Alias = 'sale',
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


    /*******************************************************************************
    *  Name            : createExpiredOppty()
    *  Summary         : Create the expired opportunity
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 17/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createExpiredOppty() {
        String rtypeId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        newOpp = new Opportunity(
            RecordTypeId = rtypeId,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            OwnerId = saleRep.Id,
            Anzahl_der_Karten__c = 5,
            Sec_Channel__c = 'Inbound',
            Channel__c = 'E-mail',
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
            CloseDate = Date.today().addDays(2),
            Starts_Schedule__c = Date.today().addDays(-2),
            Starts_Status__c = '0.5 Missing information',
            Disable_for_KPI__c = FALSE
        );
        insert newOpp;
    }
}