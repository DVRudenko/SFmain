@isTest
private class E2ETestDataCleanerCtrlTest {
    private static Account account;
    private static Contact contact;

    @isTest
    private static void deleteE2EdataTest() {
        createTestData();
        ApexPages.CurrentPage().getparameters().put('key', 'b023ewewe');
        E2ETestDataCleanerCtrl cleaner = new E2ETestDataCleanerCtrl();
        cleaner.searchParam = contact.Email;
        cleaner.doSearch();
        ApexPages.CurrentPage().getparameters().put('accid', account.Id);
        cleaner.deleteRecords();
    }

    private static void createTestData() {
        E2E_Data_Object__c dataObject = new E2E_Data_Object__c(
                Name = 'test'
        );
        insert dataObject;

        account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Data_Object__c = dataObject.Id;
        insert opportunity;

        contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        List<SObject> sobjectsToInsertList = new List<SObject>();
        OpportunityContactRole ocr = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        sobjectsToInsertList.add(ocr);

        Health_Check__c healthCheck = new Health_Check__c(
			Name = 'E2E Load Time Tracking',
			Country__c = 'Germany',
			Description__c = 'test description',
			Device__c = 'Mobile',
			From_Step__c = 'step 1',
			Opportunity__c = opportunity.Id,
			Start_Action__c = Datetime.now(),
			Time_execution__c = 1000,
			To_Step__c = 'step 1'
		);
    	sobjectsToInsertList.add(healthCheck);

        Payment_Transaction__c paymentTransaction = E2ELongFormUtilsTest.createPaymentTransaction(opportunity.Id);
        sobjectsToInsertList.add(paymentTransaction);

        Credit_Factory_Report__c cfreport = new Credit_Factory_Report__c(
            Name = 'Test Report',
            Opportunity__c = opportunity.Id
        );
        sobjectsToInsertList.add(cfreport);

        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        sobjectsToInsertList.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        sobjectsToInsertList.add(card2);

        Attachment attach = E2ELongFormUtilsTest.createAttachment('test_attach', opportunity.Id);
        sobjectsToInsertList.add(attach);

        E2E_Data_Log__c dataLog = new E2E_Data_Log__c(
                Job_Status__c = 'Completed',
                E2E_Data_Object__c = dataObject.Id
        );
        sobjectsToInsertList.add(dataLog);

        E2E_Data_Offer_Item__c dataOfferItem = new E2E_Data_Offer_Item__c(
                Offer_Name__c = 'test',
                E2E_Data_Object__c = dataObject.Id
        );
        sobjectsToInsertList.add(dataOfferItem);

        E2E_Data_Additional_Service__c dataAdditionalService = new E2E_Data_Additional_Service__c(
                Name = 'test',
                E2E_Data_Object__c = dataObject.Id
        );
        sobjectsToInsertList.add(dataAdditionalService);

        insert sobjectsToInsertList;

        E2E_Test_Data_Cleaner_Settings__c settings = new E2E_Test_Data_Cleaner_Settings__c(
            Name = contact.Email,
            Encryption_Key__c = 'b023ewewe'
        );
        insert settings;
    }
}