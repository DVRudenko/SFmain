/**
 * Created by Nikita.Mikhailov on 22.05.2019.
 */

public with sharing class GFNI_ExceptionHandler {
    public static void handleCreateByRequestExceptions(Exception e, Opportunity opportunity, String applicationId, String requestId, GFNI_Logger logger, String additionalInfo) {
        System.debug('GFNI_Handler: ' + e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString());
        System.debug('Line number: ' + e.getLineNumber());

        String messageToLog = e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString();
        if (String.isNotBlank(additionalInfo))
            messageToLog += ' : ' + additionalInfo;

        logger.addLog('Error', messageToLog, requestId);

        if (String.isNotBlank(applicationId)) {
            Opportunity opportunityToUpdate = new Opportunity(Id = opportunity.Id, GFNI_ApplicationId__c = applicationId);
            update opportunityToUpdate;
        }

        logger.saveLogs();

        messageToLog = 'Message: ' + e.getMessage() + '\n\nAdditional Info: ' + additionalInfo + '\n\nCause: ' + e.getCause() + '\n\nStackTrace: ' + e.getStackTraceString() + '\n\nMethod: GFNI_Handler.createByRequest' + '\n\nOpportunity: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '\n\nHave a nice day!';
        GFNI_Utils.sendEmail('NCC_' + opportunity.Account.BillingCountryCode + '_Failure_' + opportunity.Name, messageToLog, opportunity.Account.BillingCountryCode);
    }

    public static void handleCheckCardStatusExceptions(Exception e, List<Opportunity> opportunities, String requestId, Map<String, GFNI_Logger> logs) {
        System.debug('GFNI_ApplicationStatusSchedulable: ' + e.getMessage());

        for (Opportunity opportunity : opportunities) {
            logs.get(opportunity.Id).addLog('Error', e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), requestId);
        }

        GFNI_Logger.saveLogsList(logs.values());

        GFNI_Utils.sendEmail('NCC_' + opportunities.get(0).Account.BillingCountryCode + '_Failure_', 'Message: ' + e.getMessage() + '\n\nCause: ' + e.getCause() + '\n\nStackTrace: ' + e.getStackTraceString() + 'Method: GFNI_Handler.checkCardStatus' + '\n\nHave a nice day!', opportunities.get(0).Account.BillingCountryCode);
    }
}