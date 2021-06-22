/**
 * Created by Anna.Ananina on 28.01.2019.
 */

public class GfnReportSender {
//    // TODO Anna Rudas: this method would be deprecated when GFN API integration will set in GFNI_Handler apex class
//    @future
//    public static void sendGFNReportToRobot(Set<Id> opportunityIds){
//        System.debug('*** FUTURE CALL for sending Report to Robot ***');
//        Set<Id> euroShellRecordTypesIds = new Set<Id>();
//        if (GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell') != null) euroShellRecordTypesIds.add(GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'));
//        if (GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell Starts') != null) euroShellRecordTypesIds.add(GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell Starts'));
//        List<Messaging.Email> mailsList = new List<Messaging.Email>();
//        List<AccountGfnReportSendingLog> accountGfnReportSendingLogs = new List<AccountGfnReportSendingLog>();
//
//        Map<Id, Opportunity> newOpportunitiesMap = new Map<Id, Opportunity>([
//                SELECT Id,
//                        RecordTypeId,
//                        Starts_Status__c,
//                        AccountId,
//                        LastModifiedById,
//                        Account.GFN_Nr__c
//                FROM Opportunity
//                WHERE Id IN :opportunityIds
//        ]);
//
//        for (Opportunity opportunity : newOpportunitiesMap.values()) {
//            if (euroShellRecordTypesIds.contains(opportunity.RecordTypeId)) {
//                String opportunityId = opportunity.Id;
//                String opportunityAccountId = opportunity.AccountId;
//                String opportunityRecordTypeId = opportunity.RecordTypeId;
//                String opportunityStartsStatus = DomainUtils.blankStringIfNull(opportunity.Starts_Status__c);
//                String newStartsStatus = '0.9 Ready for GFN';
//
//                if (opportunityStartsStatus.equals(newStartsStatus)) {
//                    System.debug('*** PREPARE ACCOUNT REPORT FOR GFN ***');
//                    Account account = [SELECT Name, BillingCountry, Account_Nr__c FROM Account WHERE Id = :opportunityAccountId];
//
//                    Account_GFN_Report_Email_Params__c emailParams = Account_GFN_Report_Email_Params__c.getInstance('Excel');
//                    String address = emailParams.Email__c;
//                    String emailBody = emailParams.Email_body__c;
//                    String format = emailParams.Attach_format__c;
//                    String subject = account.Name + ', ' + account.BillingCountry + ', ' + account.Account_Nr__c;
//                    String fileName = subject + format; // ex. Customer Account name, country, SFDC order number
//
//                    AccountGfnReportTemplate reportTemplate =
//                            new AccountGfnReportTemplate(opportunityId, opportunityRecordTypeId, opportunityAccountId);
//
//                    String htmlTemplate = reportTemplate.generateReportHtmlTemplate();
//                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
//                    Blob excel = Blob.valueOf(htmlTemplate);
//                    attach.setBody(excel);
//                    attach.setFileName(fileName);
//
//                    System.debug('*** SENDING GFN REPORT ***');
//
//                    // add address for debug
//                    Boolean debugMode = emailParams.Test_mode__c;
//                    String debugEmail = '';
//                    if(debugMode){
//                        debugEmail = (emailParams.Test_mode_email__c != null) ? emailParams.Test_mode_email__c : '';
//                    }
//
//                    OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
//                    Messaging.SingleEmailMessage mail =
//                            EmailGenerator.sendHtmlEmailWithAttachment(new String[]{
//                                    address, debugEmail
//                            }, orgEmails, subject, emailBody, attach);
//
//                    mailsList.add(mail);
//                    accountGfnReportSendingLogs.add(new AccountGfnReportSendingLog(opportunityAccountId, opportunityId, address, fileName, opportunity.LastModifiedById));
//                }
//            }
//        }
//
//        if (mailsList.size() > 0) {
//            if (!Test.isRunningTest()) {
//                try {
//                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mailsList);
//                    if (results[0].isSuccess()) {
//                        createMailingLog(accountGfnReportSendingLogs, 'Success');
//                    } else {
//                        createMailingLog(accountGfnReportSendingLogs, 'Failed');
//                    }
//                } catch (Exception e) {
//                    createMailingLog(accountGfnReportSendingLogs, 'Failed');
//                    System.debug('Exception - OpportunityTriggerHandler.sendAccountReportToBackOffice(): ' + e);
//                    ExceptionLogger.sendException(e.getMessage(), String.valueOf(e.getStackTraceString()));
//                }
//            } else {
//                createMailingLog(accountGfnReportSendingLogs, 'Success');
//            }
//        }
//    }
//
//    private static void createMailingLog(List<AccountGfnReportSendingLog> sendingLogs, String status) {
//        List<Mailing_Account_GFN_Report_Log__c> logsForInsert = new List<Mailing_Account_GFN_Report_Log__c>();
//        for (AccountGfnReportSendingLog sendingLog : sendingLogs) {
//            Mailing_Account_GFN_Report_Log__c log = new Mailing_Account_GFN_Report_Log__c(
//                    Account__c = sendingLog.accountId,
//                    Opportunity__c = sendingLog.opportunityId,
//                    Starts_Status_Changed_By__c = sendingLog.userId,
//                    Address__c = sendingLog.address,
//                    File_Name__c = sendingLog.fileName,
//                    Sending_Status__c = status);
//            logsForInsert.add(log);
//        }
//        insert logsForInsert;
//    }
}