public class ConversionReportUpload implements IConversionReport {
    private Map<Id, ConversionReportPPRCtrl.ClassForUpload> uploadListAssignment {get; set;}
    private String csvName {get; set;}
    private String[] emailsList {get; set;}

    public ConversionReportUpload(Map<Id, ConversionReportPPRCtrl.ClassForUpload> uploadListAssignment, String csvName, String[] emailsList) {
        this.uploadListAssignment = uploadListAssignment;
        this.csvName = csvName;
        this.emailsList = emailsList;
    }

    public List<Messaging.SingleEmailMessage> getMails() {
        String reportBody = 'OpportunityId, OwnerId , Assignment Date, Closed Date \n';
        for ( Id key :this.uploadListAssignment.keySet()) {
            ConversionReportPPRCtrl.ClassForUpload cl = this.uploadListAssignment.get(key);
            String resultStr = cl.oppId + '; ' + cl.ownerId + '; ' + cl.assignmentDate + '; ' + cl.closeDate + '\n';
            reportBody += resultStr;
        }

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(reportBody);
        csvAttc.setFileName(this.csvName);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('CSV');
        email.setToAddresses( emailsList );
        email.setPlainTextBody('See Attach');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{ csvAttc });
        return new List<Messaging.SingleEmailMessage>{email};
    }

    public String getFileType() {
        return 'xls';
    }
}