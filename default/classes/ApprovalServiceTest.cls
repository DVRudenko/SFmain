@isTest
public with sharing class ApprovalServiceTest {
    @isTest
    private static void testLaunchApprovalProcess() {
        Opportunity defaultOpportunity = ApprovalServiceDataTestFactory.createDefaultOpportunity();
        insert defaultOpportunity;

        Boolean result = ApprovalService.launchApprovalProcess(defaultOpportunity.id, ApprovalServiceDataTestFactory.createProcessName());
        System.assertEquals(true, result);

        Boolean resultBlank = ApprovalService.launchApprovalProcess(defaultOpportunity.id, '');
        System.assertEquals(false, resultBlank);

        result = ApprovalService.launchApprovalProcess(null, null);
        System.assertEquals(false, result);
    }

    @isTest
    private static void testIsRecordLockedByApprovalProces() {
        Opportunity defaultOpportunity = ApprovalServiceDataTestFactory.createDefaultOpportunity();
        insert defaultOpportunity;

        Boolean recordLocked = ApprovalService.isRecordLockedByApprovalProces(defaultOpportunity.Id);
        System.assertEquals(false, recordLocked);

        recordLocked = ApprovalService.isRecordLockedByApprovalProces(null);
        System.assertEquals(null, recordLocked);

        ApprovalService.launchApprovalProcess(defaultOpportunity.id, ApprovalServiceDataTestFactory.createProcessName());

        recordLocked = ApprovalService.isRecordLockedByApprovalProces(defaultOpportunity.Id);
        System.assertEquals(true, recordLocked);
    }

    @isTest
    private static void testGetApprovalProcesses() {
        Opportunity defaultOpportunity = ApprovalServiceDataTestFactory.createDefaultOpportunity();
        insert defaultOpportunity;

        ApprovalService.launchApprovalProcess(defaultOpportunity.id, ApprovalServiceDataTestFactory.createProcessName());

        Map<String, String> result = ApprovalService.getApprovalProcesses(defaultOpportunity.id);

        System.assertNotEquals(null, result);
    }

    @isTest
    private static void testCheckForApproval() {
        Opportunity defaultOpportunity = ApprovalServiceDataTestFactory.createDefaultOpportunity();
        insert defaultOpportunity;
        ApprovalService.launchApprovalProcess(defaultOpportunity.id, ApprovalServiceDataTestFactory.createProcessName());

        Boolean result = ApprovalService.checkForApproval(defaultOpportunity.id, ApprovalServiceDataTestFactory.createListProcessName());

        List<ProcessInstance> processInstance = ApprovalServiceDataTestFactory.processInstance(defaultOpportunity.id);

        System.assertEquals(false, result);
        System.assertEquals('Pending', processInstance[0].Status);

        result = ApprovalService.checkForApproval(null, null);
        System.assertEquals(null, result);
    }
}