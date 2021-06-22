@isTest
private class CreateSalesPlanControllerTest {
    static testMethod void testUserPlan() {
    	Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2016');
    	insert year;
    	Fleetcor_Calendar_Month__c monthJan = new Fleetcor_Calendar_Month__c(
    		Fleetcor_Calendar_Year__c = year.Id,
    		Name = 'January');
    	insert monthJan;
    	Fleetcor_Calendar_Month__c monthFeb = new Fleetcor_Calendar_Month__c(
    		Fleetcor_Calendar_Year__c = year.Id,
    		Name = 'February');
    	insert monthFeb;
        ApexPages.currentPage().getParameters().put('uid', UserInfo.getUserId());
        CreateSalesPlanController controller = new CreateSalesPlanController();
        controller.getYears();
        controller.createPlan();
        controller.cancel(); 
    }
}