@isTest
private class DashboardStartsSLAoverdueReportCtrlTest {
    public static User saleRep;
    public static Opportunity newOpp;


    /*******************************************************************************
    *  Name            : testTable()
    *  Summary         : Performs the test    
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 17/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testTable() {
        Test.startTest();
            createSaleUser();
        Test.stopTest();

        System.runAs(saleRep) {
            createExpiredOppty();
            Opportunity oppty = [
                SELECT Id, Starts_SLA_Expired__c
                FROM Opportunity
                WHERE Id = :newOpp.Id
                LIMIT 1
            ];

            DashboardStartsSLAoverdueReportCtrl controller = new DashboardStartsSLAoverdueReportCtrl();
            ApexPages.currentPage().getParameters().put('userid', saleRep.Id);
            controller.init();
        }
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
    *  Summary         : Create the opportunity
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