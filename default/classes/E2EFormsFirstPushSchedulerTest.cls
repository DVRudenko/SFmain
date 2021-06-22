@isTest
private class E2EFormsFirstPushSchedulerTest {

	/******************************************************************************
	*  Name            : testE2EFormsFirstPushRequest()
	*  Summary         : test request to E2E Form (mobile and desktop versions)    
	*  CreatedDate     : 02/11/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @isTest
    static void testE2EFormsFirstPushRequest() {
    	E2E_Form_General_Settings__c settings = new E2E_Form_General_Settings__c();
    	settings.Name = 'Germany';
    	settings.Payment_URL__c = URL.getSalesforceBaseUrl().toExternalForm();
    	insert settings;

    	Test.startTest();
    		String schedule = datetime.now().addMinutes(5).second() + ' ' + datetime.now().addMinutes(5).minute() + ' *' + ' ?' + ' *' + ' *';
	     	String jobId = System.schedule('testBasicScheduledApex', schedule, new E2EFormsFirstPushScheduler());

	     	Test.setMock(HttpCalloutMock.class, new E2EFormsFirstPushMock());
	        E2EFormsFirstPushScheduler.sendRequestToE2E(URL.getSalesforceBaseUrl().toExternalForm() + '/e2e');
    	Test.stopTest();
    }
}