@isTest
private class E2EAbandonmentScenarioScheduleTest {

    /*******************************************************************************
    *  Name            : launchScheduleTest()
    *  Summary         : test launch Schedule Test
    *  CreatedDate     : 30/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void launchScheduleTest() {
        Test.startTest();
        System.schedule('testSchedule', '0 0 * ? * *', new E2EAbandonmentScenarioSchedule());
        Test.stopTest();
    }
}