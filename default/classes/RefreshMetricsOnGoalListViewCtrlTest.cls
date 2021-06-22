@isTest
private class RefreshMetricsOnGoalListViewCtrlTest {
	/*******************************************************************************
	*  Name            : createMetric*()
	*  Summary         : Method creates Metric object
	*  CreatedDate     : 19-09-2017
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

		List<Metric> metricsList = new List<Metric>();
		metricsList.add(metrics);

  		Test.StartTest();
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(metricsList);
			sc.setSelected(metricsList); 
			RefreshMetricsOnGoalListViewCtrl controller = new RefreshMetricsOnGoalListViewCtrl(sc);
			controller.init();
		Test.StopTest();
    }


	/*******************************************************************************
	*  Name            : createMetric*()
	*  Summary         : Method creates Metric object without any selected record
	*  CreatedDate     : 20-09-2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	static testMethod void createMetric2() {
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

		List<Metric> metricsList = new List<Metric>();

  		Test.StartTest();
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(metricsList);
			sc.setSelected(metricsList); 
			RefreshMetricsOnGoalListViewCtrl controller = new RefreshMetricsOnGoalListViewCtrl(sc);
			controller.init();
		Test.StopTest();
	}	
}