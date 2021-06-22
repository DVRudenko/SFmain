@isTest
private class RefreshMetricsTest {
	/*******************************************************************************
	*  Name            : createMetric*()
	*  Summary         : Method creates Metric object, sends test http callout mock
	*  CreatedDate     : 23-08-2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
    static testMethod void createMetric() {
       	List<RecordType> rtList = [
		   	SELECT Id, Name
		    FROM RecordType
		    WHERE Name = 'Fortschritt' AND 
		    	SobjectType = 'Metric'
		    LIMIT 1];

	    Goal testGoal = new Goal(
	    	Name = 'New Goal');
	    insert testGoal;

    	Metric metrics = new Metric(
    		GoalId = testGoal.id,
	    	Name = 'test metrics',
			RecordTypeId = rtList.get(0).id,
			TargetValue = 100,
			CurrencyIsoCode = 'EUR');
		insert metrics;   

		MetricDataLink metricDataLinks = new MetricDataLink(
			DatasourceFieldName = 'Test datasource name',
			TargetId = metrics.id);
		insert metricDataLinks;

		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(testGoal);
			RefreshMetricsOnGoalController controller = new RefreshMetricsOnGoalController(sc);
			controller.init();
			Test.setMock(HttpCalloutMock.class, new RefreshMetricsHttpResponseTest());
		Test.stopTest(); 
    }
}