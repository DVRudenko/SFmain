global class EmailStandardReportSchedule implements Schedulable {
    public Id reportId;
    public Set<Id> setTargetId;
    public List<String> listOtherEmails;
    public Boolean reportToEmailBody;
    public String typeOfReturnFile;
/* Example of Execute:
Report scheduleReport = [SELECT id, name FROM Report WHERE Name like '%Account%' LIMIT 1];
Set<id> usersIds = new Set<id>{ UserInfo.getUserId() };
List<String> otherEmails = new List<String>{'yayaya@gmail.com'};

if (scheduleReport != null) {
    String scheduleName = String.valueOf('EmailStandardReportSchedule "' + scheduleReport.name + '" to '+usersIds+' &&& '+otherEmails).left(255);
    System.schedule(scheduleName,
            '0 0 8 ? * MON-FRI',
            new EmailStandardReportSchedule(scheduleReport.id, usersIds,otherEmails,'xls',true));
}
*/
    public EmailStandardReportSchedule(id reportId, Set<Id> setTargetId, List<String> listOtherEmails, String typeOfReturnFile, Boolean reportToEmailBody) {
        this.reportId = reportId;
        this.setTargetId = setTargetId;
        this.listOtherEmails = listOtherEmails;
        this.typeOfReturnFile = typeOfReturnFile;
        this.reportToEmailBody = reportToEmailBody;
    }
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new EmailStandardReportQueueable(this.reportId, this.setTargetId, this.listOtherEmails, this.typeOfReturnFile, this.reportToEmailBody));
    }

}