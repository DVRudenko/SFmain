global class EmailConversionReportRuSchedule implements Schedulable {

    public final static String CRON_EXP = '0 0 13 * * ?';

    global void execute(SchedulableContext sc) {
        IConversionReport currentReportPPRImpl = new ConversionReportPPRImpl(System.Today(), 'xls', 'current');
        System.enqueueJob(new EmailReportQueueable(currentReportPPRImpl));
    }

    public static void run(Date currentDate) {
        IConversionReport currentReportPPRImpl = new ConversionReportPPRImpl(currentDate, 'xls', 'current');
        System.enqueueJob(new EmailReportQueueable(currentReportPPRImpl));
    }
}