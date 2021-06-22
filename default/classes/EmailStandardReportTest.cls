@IsTest private class EmailStandardReportTest {

    @isTest(SeeAllData=True) static void testSchedule1() {
        Report scheduleReport = [SELECT id, name FROM Report LIMIT 1];
        Set<id> usersIds = new Set<id>{ UserInfo.getUserId() };
        List<String> otherEmails = new List<String>{'yayaya@gmail.com'};

        Test.startTest();
        system.schedule('Test Job Reaction', '0 0 23 * * ?',  new EmailStandardReportSchedule(scheduleReport.id, usersIds,otherEmails,'xls',true));
        system.schedule('Test Job Reaction2', '0 0 23 * * ?',  new EmailStandardReportSchedule(scheduleReport.id, usersIds,otherEmails,'csv',false));
        Test.stopTest();
    }

}