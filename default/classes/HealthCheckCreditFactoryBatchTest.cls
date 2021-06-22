@isTest
private class HealthCheckCreditFactoryBatchTest {


	/*******************************************************************************
	*  Name            : testGermanCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Germany
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testGermanCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'DE',
    		Country__c = 'Germany',
    		Name__c = 'Buchverlagsgesellschaft Druck mbH');
    	insert healthCheck;

    	CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
		insert creditSystem;
		
    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();
    	Test.startTest();
    		Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"totalHits": 164,"companies": [{"companyId": 8688677,"companyName": "BMW Automobilclub Kassel","foundationDate": "19.03.93","formOfOrganisation": "EV","zipCode": "34117","city": "Kassel","branchCode": "9499","registerCourt": "Kassel","traderegisterNumber": "VR 2424","alreadyOnboarded": false,"onboardingDate": ""}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/search/full/detail', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testNetherlandsCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Netherlands
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testNetherlandsCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'NL',
    		Country__c = 'Netherlands',
    		Name__c = 'Test',
    		Id__c = 'NL-X-09094215',
    		Tax_Id__c = '09094215');
    	insert healthCheck;

    	CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockNL());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testBelgiumNLCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Belgium-NL
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testBelgiumNLCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'BENL',
    		Country__c = 'Belgium-NL',
    		Name__c = 'Test',
    		Id__c = 'BE-X-505807092',
    		Tax_Id__c = '505807092');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe', 
            Endpoint__c = 'https://connect.creditsafe.com/v1',
            Username__c = 'test', 
            Password__c = 'test', 
            Supported_Countries__c = 'Belgium-NL');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockBENL());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testBelgiumFRCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Belgium-FR
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testBelgiumFRCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'BEFR',
    		Country__c = 'Belgium-FR',
    		Name__c = 'Test',
    		Id__c = 'BE-X-505807092',
    		Tax_Id__c = '505807092');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe', 
            Endpoint__c = 'https://connect.creditsafe.com/v1',
            Username__c = 'test', 
            Password__c = 'test', 
            Supported_Countries__c = 'Belgium-FR');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockBEFR());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testPolandCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Poland
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testPolandCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'PL',
    		Country__c = 'Poland',
    		Name__c = 'Lambda sp. z o.o. komandytowo-akcyjna',
    		Id__c = '4835372542',
    		Tax_Id__c = '4835372542',
    		Archive_Id__c = '4394000002849121');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Crif',
            Endpoint__c = 'https://demo.deltavista.pl/Search_Soap_Service_PL/services/SearchService,' + 
                'https://demo.deltavista.pl/dvs-soap/services/OrderCheckService,https://demo.deltavista.pl/pdfservice/pdfservlet', 
            Username__c = 'demo_fleetcor_soap', 
            Password__c = 'cvujmHe4',
            Supported_Countries__c = 'Poland');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockPL());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Error_Description__c
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testHungaryCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Hunagary
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testHungaryCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'HU',
    		Country__c = 'Hungary',
    		Name__c = 'M-SÉTÁNY Kereskedelmi, Szolgáltató és Vendéglátó Korlátolt Felelősségű Társaság',
    		Id__c = '81466010',
    		Vat_Number__c = '14066436-2-42');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Coface',
            Endpoint__c = 'https://test.cofacecentraleurope.com/iconwebservices', 
            Username__c = 'Petr.Cermak@fleetcor.eu', 
            Password__c = 'Fleetcor2018',
            Supported_Countries__c = 'Hungary');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockHU());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Error_Description__c
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }
}