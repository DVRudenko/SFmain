@isTest
public with sharing class UpdateGfnNumberOfCardsTest {

    @testSetup
    private static void createTestData() {
        GFNI_Batch_Settings__c batchSetting = new GFNI_Batch_Settings__c(
            Name = 'Update_Gfn_Number_of_cards',
            Batch_Size__c = 100,
            Where_Condition__c = 'ColCoID__c != null',
            Query_Limit__c = 1000,
            Active__c = true,
            Error_Message_Reciever__c = 'test@test.test'
        );
        insert batchSetting;

        ERP__c testErp = new ERP__c(
            Name = 'test',
            ColCoID__c = 'DE',
            GFN_Nr__c = 'DE12478550',
            Status__c = 'New',
            RecordTypeId = GlobalUtils.returnRecordTypeId('ERP__c', 'SME'),
            UTA_Cards__c = 10
        );
        insert testErp;

        insert new GFNI_Settings__c(
            API_version__c = '1',
            Client_system__c = 'SME',
            Culture__c = 'en-GB',
            IsForRobot__c = false,
            Name = 'GFN Integration Settings',
            Prod_endpoint__c = 'https://api.test.endpoint',
            Test_endpoint__c = 'https://api.test.endpoint',
            Test_mode__c = false,
            test_x_ibm_client_id__c = '86b094c8-b431-44bd-8925-8909db6b34cf',
            test_x_ibm_client_secret__c = 'J0hE4tJ6wA5dK5nB3aH4fD3wX0iG5wS2uT3vG0mX7eL4rT4mE6',
            x_ibm_client_id__c = '4b4e495e-9b0f-4461-bea4-90bbfb6ea8af',
            x_ibm_client_secret__c = 'M4uT7aP5lC5vT1tG3vQ0rT7gX7lG5nO7lG3iY1mY1nD8sS5bS3'
        );
    }


    @isTest
    private static void testUpdateNumberOfCardsTest() {
        Test.startTest();

        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ScheduleBatchUpdateGfnNumberOfCards m = new ScheduleBatchUpdateGfnNumberOfCards();
        String sch = '0 0 * * * ?';
        String jobID = system.schedule('Update Job', sch, m);
        m.execute(null);

        Test.stopTest();

        List<ERP__c> updatedErpList = [
            SELECT  Uta_Cards__c
            FROM    ERP__c
        ];
        System.assertEquals(1, updatedErpList.size());
        System.assertEquals(0, updatedErpList[0].Uta_Cards__c);
    }


    @isTest
    private static void testUpdateNumberOfcardsErrorTest() {
        Test.startTest();

        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ScheduleBatchUpdateGfnNumberOfCards m = new ScheduleBatchUpdateGfnNumberOfCards();
        String sch = '0 0 * * * ?';
        String jobID = system.schedule('Update Job', sch, m);
        m.execute(null);

        Test.stopTest();

        List<ERP__c> updatedErpList = [
            SELECT  Uta_Cards__c
            FROM    ERP__c
        ];
        System.assertEquals(1, updatedErpList.size());
        System.assertEquals(-1, updatedErpList[0].Uta_Cards__c);
    }
}
