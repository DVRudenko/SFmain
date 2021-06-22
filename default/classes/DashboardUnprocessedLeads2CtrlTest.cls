@isTest
private class DashboardUnprocessedLeads2CtrlTest {
	/*******************************************************************************
	*  Name            : testCharts()
	*  Summary         : check open leads for certain countries   
	*  CreatedDate     : 27/02/2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
    static testMethod void testCharts() {
    	List<Lead> leadsList = new List<Lead>();
        ApexPages.currentPage().getParameters().put('key','xn661q8t5s33w1n5X3V42x19WKhJnHi5');
     	Lead lead = new Lead(
			LastName = 'Test Name',
			Country = 'Poland',
			CountryCode = 'PL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '123456789',
			Company = 'New Company',
			Status = 'Open');
        insert lead;  
        leadsList.add(lead);
		DashboardUnprocessedLeads2Ctrl controller = new DashboardUnprocessedLeads2Ctrl();
		controller.init();  
		controller.generateDataForInboundLeads(leadsList);
		controller.generateDataForJITBLeads(leadsList);
		System.assertEquals(controller.finalLeadsMapInbound.get('PL'), 1);
    }
}