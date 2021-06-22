global class E2EErrorService {
    public static Id createNewErrorMessage(Exception e, Id opportunityId) {
        E2E_Error_message__c newMessage = new E2E_Error_message__c(
            LineNumber__c = e.getLineNumber(),
            Message__c = e.getMessage(),
            StackTraceString__c = e.getStackTraceString(),
            TypeName__c = e.getTypeName(),
            Opportunity__c = opportunityId
        );
        if (e.getCause() != null) {
            newMessage.CausedBy__c = E2EErrorService.createNewErrorMessage(e.getCause(), null);
        }
        insert newMessage;
        return newMessage.Id;
    }
}