@isTest
private class UpdateProcessedByOpportunitiesCtrlTest {
	/*******************************************************************************
	*  Name            : createOpportunities()
	*  Summary         : Create list with two Opportunities
	*  CreatedDate     : 01.03.2018
	*  ModifiedDate    : 01.03.2018
	*  Parameters      : 
	*  Returns         : 
	******************************************************************************/
    @testSetup 
    static void createOpportunities() {
        List<Opportunity> testList = new List<Opportunity>();

        Opportunity testOpportunityOne = new Opportunity();
        testOpportunityOne.Name = 'Test Opportunity';
        testOpportunityOne.StageName = 'Prospecting';
        testOpportunityOne.bearbeitet_von__c = 'Vincent Coffa';
        testOpportunityOne.Angebotsdauer__c = '3 Monate';
        testOpportunityOne.CloseDate = Date.today();
        testList.add(testOpportunityOne);

        Opportunity testOpportunityTwo = new Opportunity();
        testOpportunityTwo.Name = 'Test Opportunity1';
        testOpportunityTwo.StageName = 'Value Proposition';
        testOpportunityTwo.bearbeitet_von__c = 'Veronika Coffa';
        testOpportunityTwo.Angebotsdauer__c = '4 Monate';
        testOpportunityTwo.CloseDate = Date.today();
        testList.add(testOpportunityTwo);

        insert testList;
    }


    /*******************************************************************************
    *  Name            : UpdateProcessedByOpportunitiesCtrlTest()
    *  Summary         : Simulate data transfer and check updateOpportunityData function    
    *  CreatedDate     : 01.03.2018
    *  ModifiedDate    : 01.03.2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    @isTest
    static void UpdateProcessedByOpportunitiesCtrlTest() {
    	List<Opportunity> testList = [
    			SELECT Id
    			FROM Opportunity];
    	ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testList);
        stdSetController.setSelected(testList);
        UpdateProcessedByOpportunitiesCtrl ext = new UpdateProcessedByOpportunitiesCtrl(stdSetController);
        ext.init();
        ext.selectedProcessedBy = 'Marek Durkovsky';
        ext.updateProcessedByData();
        List<Opportunity> modifiedTestList = [
        		SELECT bearbeitet_von__c
        		FROM Opportunity];
        for (Opportunity opportunity : modifiedTestList) {
        	System.assertEquals('Marek Durkovsky', opportunity.bearbeitet_von__c);
        }
    }
}