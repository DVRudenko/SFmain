/**
 * Created by Yury on 06.10.2020.
 */
@isTest
public with sharing class EmarsysContactRunQueueableTest {

    public static void initSettings() {
        Emarsys_Contact_Subscriptions__c customSetting = new Emarsys_Contact_Subscriptions__c(
                Last_Update_Segment_Date__c = Datetime.now(),
                Segment_Id__c = '16578',
                Name = 'Test'
        );
        insert customSetting;
    }

    @isTest
    public static void testQueueableRunId() {
        initSettings();
        List<Emarsys_Contact_Subscriptions__c> blankList;
        list<Emarsys_Contact_Subscriptions__c> EmarsysContactSubscriptions = Emarsys_Contact_Subscriptions__c.getAll().values();

        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new EmarsysRunIdMock());
        System.Test.stopTest();
        System.enqueueJob(new EmarsysContactRunQueueable(EmarsysContactSubscriptions, blankList));
        System.assertEquals('Test', EmarsysContactSubscriptions[0].Name);
        System.assertEquals(Null, blankList);


    }
}