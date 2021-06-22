public class EmailReportQueueable implements Queueable, Database.AllowsCallouts {
    private IConversionReport report;

    public EmailReportQueueable(IConversionReport report) {
        this.report = report;
    }

    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> listEmails = this.report.getMails();

        if(listEmails != null && !listEmails.isEmpty()) {
            Messaging.sendEmail(listEmails);
        }
    }
}