@isTest
public class EmarsysRusLogsUpdateScheduleTest {

    /*******************************************************************************
    *  Name            : launchScheduleTest()
    *  Summary         : test launch Schedule Test
    *  CreatedDate     : 20/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void launchScheduleTest() {
        Test.startTest();
            System.schedule('Test EmarsysRusLogsUpdateSchedule', '20 0 8-18 ? * MON-FRI', new EmarsysRusLogsUpdateSchedule());
        Test.stopTest();
    }
}