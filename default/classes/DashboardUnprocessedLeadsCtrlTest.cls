@isTest
public class DashboardUnprocessedLeadsCtrlTest {
 @isTest
    public static void testCharts() {
        ApexPages.currentPage().getParameters().put('key','xn661q8t5s33w1n5X3V42x19WKhJnHi5');
     	Lead l = new Lead(
            LastName = 'Test Name',
            Country = 'Poland',
            CountryCode = 'PL',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            Phone = '123456789',
            Company = 'New Company');
        insert l;  
        
		DashboardUnprocessedLeadsCtrl controller = new DashboardUnprocessedLeadsCtrl();
		controller.init();        
    }
}