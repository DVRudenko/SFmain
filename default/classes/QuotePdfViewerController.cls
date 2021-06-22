public class QuotePdfViewerController {
    public Quote qoute {get; set;}
    private Opportunity oppty;

    public void init() {
        String qouteId = ApexPages.CurrentPage().getparameters().get('id');
        if (qouteId != null) {
            this.qoute = [SELECT OpportunityId, Email, ContactId FROM Quote WHERE Id = :qouteId LIMIT 1];
            this.oppty = [SELECT Name, Registered_Country__c FROM Opportunity WHERE Id = :qoute.OpportunityId LIMIT 1];
        }
    }


    public PageReference savePDF() {
        Attachment attachmentPDF = generatePdfAttachment();
        insert attachmentPDF;
        return new PageReference('/' + this.oppty.Id);
    }


    public PageReference doCancel() {
        return new PageReference('/' + this.qoute.Id);
    }


    private Attachment generatePdfAttachment() {
        PageReference pg = new PageReference('/apex/CreateQuotePDF?id=' + this.qoute.Id);
        Blob blb;
        if (! Test.isRunningTest()) {
            blb = pg.getContent();
        } else {
            blb = Blob.valueOf('Unit.Test');
        }
        Attachment attachmentPDF = new Attachment();
        attachmentPdf.ParentId = this.oppty.Id;
        attachmentPdf.Name = 'Carnet_podsumowanie_zamowienia_' + String.valueOf(System.now()) + '.pdf';
        attachmentPdf.Body = blb;
        return attachmentPDF;
    }
}