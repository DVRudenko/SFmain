@IsTest
private class FieldSalesDeduplicationScheduleTest {

    @isTest
    static void testScheduleMethod(){
        Test.startTest();
        system.schedule('Test Job - FIELD SALES TERRITORY', '0 0 23 * * ?', new FieldSalesDeduplicationSchedule());
        Test.stopTest();
    }

}