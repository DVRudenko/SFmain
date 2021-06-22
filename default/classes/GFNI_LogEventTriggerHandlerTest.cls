/**
 * Created by Nikita.Mikhailov on 19.10.2020.
 */

@IsTest
public with sharing class GFNI_LogEventTriggerHandlerTest {
    @IsTest
    static void storeLogsTest() {
        GFNI_Log__e logEvent = new GFNI_Log__e (
                IsFirst__c = 1,
                LogType__c = '1',
                LookupObjectId__c = '',
                Message__c = 'Hello World',
                RecordDateTime__c = Datetime.now(),
                Request_Id__c = '00241706-cc50-49cb-8f8a-ca318ade0dcb'
        );

        Test.startTest();

        Database.SaveResult sr = EventBus.publish(logEvent);

        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }
}