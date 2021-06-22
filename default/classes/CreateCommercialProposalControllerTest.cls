@isTest
private class CreateCommercialProposalControllerTest {
    static testMethod void checkCommercialProposal() {
        Account a = new Account(
        	Name = 'test',
        	BillingCountry = 'Germany',
        	BillingCity = 'BERG',
        	BillingStreet = 'LUDWIGSTRASSE 69');
        insert a;

        Contact c = new Contact(
        	Salutation = 'Herr',
        	LastName = 'test',
        	AccountId = a.Id,
        	Email = 'test@test.com');
        insert c;

        Opportunity o = new Opportunity(
        	Name = 'test',
        	Product__c = 'Home Station offer (v.1)',
        	AccountId = a.id,
        	CloseDate = Date.today(),
        	StageName = 'Prospecting');
        insert o;

        Commercial_Proposal_Template__c template = new Commercial_Proposal_Template__c(
        	Name = 'Home Station offer (v.1)',
        	PDF_body__c = '123',
            Country__c = 'Germany');
        insert template;

        Folder f = [SELECT Id FROM Folder WHERE Name = 'Email PDFs' LIMIT 1];
        Document doc = new Document(
        	Name = 'AGB Fleetcor Deutschland GmbH.pdf',
        	Body = Blob.valueOf('123'),
        	FolderId = f.Id);
        insert doc;

        Document doc2 = new Document(
        	Name = 'Gebührenübersicht Home Station Offer (2015).pdf',
        	Body = Blob.valueOf('123'),
        	FolderId = f.Id);
        insert doc2;
 
        Apexpages.currentPage().getParameters().put('id',o.Id);

    	Test.startTest();
    	    Test.setMock(HttpCalloutMock.class, new CommercialProposalResponse());          
	        CreateCommercialProposalController controller = new CreateCommercialProposalController();
            CreateCommercialProposalUtils utilsController = new CreateCommercialProposalUtils();
	        controller.init();
	        controller.selectedContact = c.Id;
	        controller.getRadius();
	        controller.getAdditionalServices();
	        controller.getProducts();
	        controller.getBrands();
            controller.getTranslateFillingStationColumnsMap();
	        controller.sendEmail();
	    Test.stopTest();
    }
}