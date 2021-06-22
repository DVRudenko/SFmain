@isTest
private class GoogleSpeedAnalystBatchTest {

    @isTest
    private static void googleSpeedServiceTest() {
        Test.startTest();
            createGoogleSpeedSettigns();
            String json = '{' +
                '"lighthouseResult": {' +
                    '"audits": {' +
                        '"metrics": {' +
                            '"details": {' +
                                '"items": [{' +
                                    '"speedIndex": 2627,' +
                                    '"observedFirstContentfulPaint": 2848' +
                                '}]' +
                            '}' +
                        '}' +
                    '},' +
                    '"categories": {' +
                        '"performance": {' +
                            '"score": 0.73' +
                        '}' +
                    '},' +
                    '"configSettings": {' +
                        '"emulatedFormFactor": "desktop"' +
                    '}' +
                '}' +
            '}';
            SingleRequestMock response = new SingleRequestMock(200, 'Complete', json, null);
            Test.setMock(HttpCalloutMock.class, response);
            GoogleSpeedAnalystBatch batch = new GoogleSpeedAnalystBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }

    private static void createGoogleSpeedSettigns() {
        List<E2E_Google_Speed_Analyst_Settings__c> settingsList = new List<E2E_Google_Speed_Analyst_Settings__c>();
        E2E_Google_Speed_Analyst_Settings__c settingsDE = new E2E_Google_Speed_Analyst_Settings__c(
            Name = 'Germany',
            End_Point__c = 'https://www.googleapis.com/pagespeedonline/v5/runPagespeed',
            Key__c = 'AIzaSyBuPJ0Pi6iUCoZQM_6rQHrhnIS4Pq6OliY',
            Desktop_Site_Url__c = 'https://test.de/e2eform?country=Germany',
            Mobile_Site_Url__c = 'https://test.de/e2eformmob?country=Germany'
        );
        insert settingsDE;
    }
}