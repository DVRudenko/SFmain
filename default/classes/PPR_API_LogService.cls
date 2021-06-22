public with sharing class PPR_API_LogService {
    public static Custom_log__c createLog(E2EFormParams formparams) {
        Custom_log__c newLog = new Custom_log__c(
            E2E_Form_Ru_Data__c = formparams.formDataId,
            Errors__c = formparams.errors,
            External_user__c = formparams.externalUser,
            INN__c = formparams.companyInn,
            Source__c = formparams.source
        );
        insert newLog;
        return newLog;
    }

    public static Custom_log__c createLog(String inn, String source, Exception e) {
        Custom_log__c newLog = new Custom_log__c(
                Errors__c = e.getMessage() + '\n' + e.getStackTraceString(),
                INN__c = inn,
                Source__c = source
        );
        insert newLog;
        return newLog;
    }

    public static void updateLog(String logId, E2EFormParams formparams) {
        Custom_log__c updatedLog = new Custom_log__c(Id = logId);
        if (formparams.formDataId != null) updatedLog.E2E_Form_Ru_Data__c = formparams.formDataId;
        if (formparams.errors != null) updatedLog.Errors__c = formparams.errors;
        if (formparams.externalUser != null) updatedLog.External_user__c = formparams.externalUser;
        if (formparams.companyInn != null) updatedLog.INN__c = formparams.companyInn;
        if (formparams.source != null) updatedLog.Source__c = formparams.source;
        update updatedLog;
    }

    public static Custom_log__c getLogByInnAndSource(String inn, String source) {
        List<Custom_log__c> logs;
        if (inn != null && inn != '' && source != null && source != '') {
            logs = [
                SELECT 
                    Name, 
                    Errors__c, 
                    External_user__c, 
                    INN__c, 
                    E2E_Form_Ru_Data__c, 
                    Source__c 
                FROM 
                    Custom_log__c 
                WHERE 
                    INN__c = :inn AND 
                    Source__c = :source 
                ORDER BY CreatedDate DESC LIMIT 1];
            if (logs.size() > 0){
                if (logs[0].E2E_Form_Ru_Data__c != null) {
                    E2EFormRuDao formRuDao = new E2EFormRuDaoImpl();
                    logs[0].E2E_Form_Ru_Data__r = formRuDao.getFormDataById(logs[0].E2E_Form_Ru_Data__c);
                }
                return logs[0];
            }
        }
        return null;
    }
}