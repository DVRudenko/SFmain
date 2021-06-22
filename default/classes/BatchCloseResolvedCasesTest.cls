@IsTest
public class BatchCloseResolvedCasesTest {

    private static final String STATUS_CLOSED = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed);
    private static final String STATUS_RESOLVED = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.resolved);
    private static final String STATUS_NEW = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new);
    private static final String RECORD_TYPE_ID = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    private static final Integer N_RESOLVED = 50;
    private static final Integer N_NEW = 70;
    private static final Integer N_CLOSED = 100;

    private static List<Case> createCases(String status, Integer n) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < n; i++) {
            Case c = new Case(
                    Status = status,
                    Subject = 'test',
                    RecordTypeId = RECORD_TYPE_ID
            );
            cases.add(c);
        }
        return cases;
    }

    private static List<Case> changeStatus(String status, List<Case> cases) {
        for (Case c : cases) {
            c.Status = status;
        }
        return cases;
    }

    @IsTest
    private static void test() {
        List<Case> casesNew = createCases(STATUS_NEW, N_NEW);
        List<Case> casesResolved = createCases(STATUS_NEW, N_RESOLVED);
        List<Case> casesClosed = createCases(STATUS_NEW, N_CLOSED);
        insert casesNew;
        insert casesResolved;
        insert casesClosed;
        update changeStatus(STATUS_RESOLVED, casesResolved);
        update changeStatus(STATUS_CLOSED, casesClosed);

        Integer countClosed = [
                SELECT COUNT()
                FROM Case
                WHERE Status = :STATUS_CLOSED
                AND Subject = 'test'
                AND RecordTypeId = :RECORD_TYPE_ID
        ];
        System.assertEquals(N_CLOSED, countClosed);

        Test.startTest();
        Database.executeBatch(new BatchCloseResolvedCases());
        Test.stopTest();

        countClosed = [
                SELECT COUNT()
                FROM Case
                WHERE Status = :STATUS_CLOSED
                AND Subject = 'test'
                AND RecordTypeId = :RECORD_TYPE_ID
        ];
        System.assertEquals(N_CLOSED + N_RESOLVED, countClosed);

    }

}