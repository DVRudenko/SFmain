public with sharing class ApprovalService {
    private static final String APPROVED = 'Approved';

    /*******************************************************************************
     *  Name            : launchApprovalProcess(Id recordId, String approvalProcessName)
     *  Summary         : launch the selected approval process
     *  CreatedDate     : 23-04-2021
     *  ModifiedDate    : -
     *  Parameters      : Id recordId, String approvalProcessName
     *  Returns         : Boolean
     ******************************************************************************/
    @AuraEnabled
    public static Boolean launchApprovalProcess(Id recordId, String approvalProcessName) {
        if (approvalProcessName != null && recordId != null) {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setObjectId(recordId);
            approvalRequest.setProcessDefinitionNameOrId(approvalProcessName);
            approvalRequest.setSkipEntryCriteria(true);
            try {
                Approval.process(approvalRequest);
                return true;
            } catch (Exception ex) {
                String notificationMessage =
                    '<br/>Мethod launchApprovalProcess: recordId = ' +
                    recordId +
                    '. Message: ' +
                    String.valueOf(ex.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(ex.getStackTraceString()));
            }
        }
        return false;
    }

    /*******************************************************************************
     *  Name            : isRecordLockedByApprovalProces(Id id)
     *  Summary         : checks the record is locked by approval or not
     *  CreatedDate     : 23-04-2021
     *  ModifiedDate    : -
     *  Parameters      : Id id
     *  Returns         : Boolean
     ******************************************************************************/
    @AuraEnabled
    public static Boolean isRecordLockedByApprovalProces(Id id) {
        return id != null ? Approval.isLocked(id) : null;
    }

    /*******************************************************************************
     *  Name            : getApprovalProcesses(Id id)
     *  Summary         : selects all approval processes from the database for the specified ID
     *  CreatedDate     : 23-04-2021
     *  ModifiedDate    : -
     *  Parameters      : Id id
     *  Returns         : Map<String, String>
     ******************************************************************************/
    @AuraEnabled
    public static Map<String, String> getApprovalProcesses(Id id) {
        List<ProcessInstance> processInstance = [SELECT ProcessDefinition.Name, Status, CreatedDate FROM ProcessInstance  WHERE TargetObjectId = :id ORDER BY CreatedDate ASC];
        Map<String, String> result = new Map<String, String>();
        for (ProcessInstance resultMap : processInstance) {
            result.put(resultMap.ProcessDefinition.Name, resultMap.Status);
        }
        return result;
    }

    /*******************************************************************************
     *  Name            : checkForApproval(Id targetId, List<String> processNames)
     *  Summary         : compares the submitted list with the names of the process approvals with the map
     *  CreatedDate     : 23-04-2021
     *  ModifiedDate    : -
     *  Parameters      : Id targetId, List<String> processNames
     *  Returns         : Boolean
     ******************************************************************************/
    @AuraEnabled
    public static Boolean checkForApproval(Id targetId, List<String> processNames) {
        if (targetId != null && new DefaultValidator().listIsEmpty(processNames) == false) {
            Map<String, String> allApprovalProcesses = getApprovalProcesses(targetId);
            for (String processName : allApprovalProcesses.keySet()) {
                if (processNames.contains(processName) && allApprovalProcesses.get(processName) == APPROVED) {
                    return true;
                }
            }
            return false;
        } else {
            return null;
        }
    }
}