public class BatchCloseResolvedCases implements Database.Batchable<SObject>{

    private final String STATUS_CLOSED;
    private final String STATUS_RESOLVED;
    private final String RECORD_TYPE;
    private final String RECORD_TYPE_CCS;
    private final Date CASE_EXPIRED_DATE;
    private final String QUERY;

    public BatchCloseResolvedCases() {
        try {
            STATUS_CLOSED = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed);
            STATUS_RESOLVED = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.resolved);
            RECORD_TYPE = GlobalUtils.CaseRecordTypes.Support.name();
            RECORD_TYPE_CCS = GlobalUtils.CaseRecordTypes.Support_CCS.name();
            if (Test.isRunningTest()) {
                CASE_EXPIRED_DATE = Date.today();
            } else {
                CASE_EXPIRED_DATE = Date.today() - Case_management_settings__c.getInstance('SettingsEU').Case_expired_days__c.intValue();
            }
            QUERY = 'SELECT Status ' +
                    'FROM Case ' +
                    'WHERE (RecordType.DeveloperName = :RECORD_TYPE OR RecordType.DeveloperName = :RECORD_TYPE_CCS) ' +
                    'AND Status = :STATUS_RESOLVED ' +
                    'AND DAY_ONLY(ClosedDate) <= :CASE_EXPIRED_DATE';
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext context, List<Case> resolvedCases) {
        try {
            if ( !resolvedCases.isEmpty()) {
                for (Case resolvedCase : resolvedCases) {
                    resolvedCase.Status = STATUS_CLOSED;
                }
                //update cases with partial success
                String errors = '';
                for (Database.SaveResult saveResult : Database.update(resolvedCases, false)) {
                    if ( !saveResult.isSuccess()) {
                        errors += String.valueOf(saveResult.getErrors()) + '\n';
                    }
                }
                if ( !String.isEmpty(errors)) ExceptionLogger.sendException(errors, 'in method BatchCloseResolvedCases.execute()\n');
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext context) {}
}