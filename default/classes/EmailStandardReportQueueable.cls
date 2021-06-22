public class EmailStandardReportQueueable implements Queueable, Database.AllowsCallouts {
    public Id reportId;
    public Set<Id> setTargetId;
    public List<String> listOtherEmails;
    public Boolean reportToEmailBody;
    public String typeOfReturnFile;
    private final Set<String> typesOfFiles = new Set<String>{
            'xls',
            'csv'
    };

    public EmailStandardReportQueueable(id reportId, Set<Id> setTargetId, List<String> listOtherEmails, String typeOfReturnFile, Boolean reportToEmailBody) {
        this.reportId = reportId;
        this.setTargetId = setTargetId;
        this.listOtherEmails = listOtherEmails;
        if (typesOfFiles.contains(typeOfReturnFile)) {
            this.typeOfReturnFile = typeOfReturnFile;
        } else {
            this.typeOfReturnFile = 'xls';
        }
        this.reportToEmailBody = reportToEmailBody;
    }

    public void execute(QueueableContext context) {
        try {
            List<Report> currentReport = [SELECT id, name FROM Report WHERE id = :reportId];
            if (currentReport.size() != 0) {

                Messaging.EmailFileAttachment reportAttachment = new Messaging.EmailFileAttachment();
                reportAttachment.setFileName(String.valueOf(currentReport.get(0).name).trim() + '.'+ typeOfReturnFile);
                reportAttachment.setContentType('text/'+typeOfReturnFile);

                Blob reportBlobCSV;
                if (this.typeOfReturnFile == 'csv'){
                    String reportCsvURL = System.Url.getSalesforceBaseURL().toExternalForm() + '/' + String.valueOf(reportId) + '?csv=1';
                    ApexPages.PageReference report2 = new ApexPages.PageReference(reportCsvURL);
                    if (! Test.isRunningTest()) {
                        reportBlobCSV = report2.getContent();
                    } else {
                        reportBlobCSV = Blob.valueOf('123');
                    }
                    reportAttachment.setBody(reportBlobCSV);
                }

                Blob reportBlobXLS;
                if ((this.typeOfReturnFile == 'xls') || (this.reportToEmailBody)) {
                    String reportExcelURL = System.Url.getSalesforceBaseURL().toExternalForm() + '/' + String.valueOf(reportId) + '?excel=1';
                    ApexPages.PageReference report = new ApexPages.PageReference(reportExcelURL);
                    if (! Test.isRunningTest()) {
                        reportBlobXLS = report.getContent();
                    } else {
                        reportBlobXLS = Blob.valueOf('123');
                    }
                    if (this.typeOfReturnFile == 'xls'){
                        reportAttachment.setBody(reportBlobXLS);
                    }
                }

                List<OrgWideEmailAddress> orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
                List<Messaging.Email> emails = new List<Messaging.Email>();
                if (this.setTargetId != null) {
                    for (Id targetId : setTargetId) {
                        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                        singleEmail.setTargetObjectId(targetId);
                        if (orgEmails.size() > 0) {
                            singleEmail.setOrgWideEmailAddressId(orgEmails.get(0).id);
                        }
                        singleEmail.setSubject('SalesForce Report "' + currentReport.get(0).name + '"');
                        if ((this.reportToEmailBody) && (reportBlobXLS != null)) {
                            singleEmail.setHtmlBody(reportBlobXLS.toString());
                        } else {
                            singleEmail.setPlainTextBody('Hello, SalesForce Report in Attachment');
                        }
                        singleEmail.setSaveAsActivity(false);
                        singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{ reportAttachment });
                        emails.add(singleEmail);
                    }
                }
                if (this.listOtherEmails != null && this.listOtherEmails.size() > 0){
                    if(String.isNotEmpty(this.listOtherEmails.get(0))){
                        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                        singleEmail.setToAddresses(listOtherEmails);
                        if (orgEmails.size() > 0) {
                            singleEmail.setOrgWideEmailAddressId(orgEmails.get(0).id);
                        }
                        singleEmail.setSubject('SalesForce Report "' + currentReport.get(0).name + '"');
                        if ((this.reportToEmailBody) && (reportBlobXLS != null)) {
                            singleEmail.setHtmlBody(reportBlobXLS.toString());
                        } else {
                            singleEmail.setPlainTextBody('Hello, SalesForce Report in Attachment');
                        }
                        singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{ reportAttachment });
                        emails.add(singleEmail);
                    }
                }
                Messaging.sendEmail(emails);
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }
}