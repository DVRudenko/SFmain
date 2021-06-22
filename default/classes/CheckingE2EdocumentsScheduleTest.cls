@isTest
private class CheckingE2EdocumentsScheduleTest {
    static testMethod void testJob() {
        Test.startTest();
        CheckingE2EdocumentsSchedule schedule = new CheckingE2EdocumentsSchedule();
        String sch = '0 0 0 15 3 ? 2023'; 
        System.schedule('Test Job Documents', sch, schedule); 
        Test.stopTest();
    }
}