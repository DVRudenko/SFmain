@isTest
private class RefreshMetricsOnGoalControllerTest {
	/*******************************************************************************
	*  Name            : createMetric*()
	*  Summary         : Method creates Metric object
	*  CreatedDate     : 20-09-2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
    static testMethod void createMetric() {
       List<RecordType> rtList = [
	   	SELECT Id, Name
	    FROM RecordType
	    WHERE Name = 'Fortschritt' AND SobjectType = 'Metric'
	    LIMIT 1];

    	Metric metrics = new Metric(
    	Name = 'test metrics',
		RecordTypeId = rtList.get(0).id,
		TargetValue = 100,
		CurrencyIsoCode = 'EUR'
		//Status = 'Not Started'
		);
		insert metrics;

		MetricDataLink metricDataLinks = new MetricDataLink(
		DatasourceFieldName = 'Test datasource name',
		TargetId = metrics.id);

		insert metricDataLinks;

  		Test.StartTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(metrics);
			RefreshMetricsOnGoalController controller = new RefreshMetricsOnGoalController(sc);
			controller.init();
		Test.StopTest();
    }
}