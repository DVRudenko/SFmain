public with sharing class CaseController {

    @AuraEnabled
    public static Case getCase(Id recordId) {
        Case currentCase = [SELECT Id, IsClosed, Status FROM Case WHERE Id = :recordId];
        return currentCase;
    }

    @AuraEnabled
    public static void updateCase(Case caseForUpdate){
        caseForUpdate.Status = 'Resolved';
        try{
            update caseForUpdate;
        } catch (DmlException e){
            System.debug('**** ERROR MESSAGE = ' + e.getMessage());
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                throw new AuraHandledException(e.getMessage().substringBetween('EXCEPTION, ', ':'));
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
}