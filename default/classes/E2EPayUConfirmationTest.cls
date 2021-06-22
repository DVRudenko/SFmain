@isTest
private class E2EPayUConfirmationTest {
	@isTest
    static void getPayUInformationTest() {
        Account account = new Account(Name = 'payUTest', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'payUTest', StageName = 'Prospecting', CloseDate = date.today(), Accountid = account.Id, Security_Amount_To_Pay__c = 10);
        insert opportunity;

        Payment_Transaction__c newTransaction = new Payment_Transaction__c();
        newTransaction.amount__c = 10;
        newTransaction.Currency__c = 'PLN';
        newTransaction.opportunityId__c = opportunity.id;
        newTransaction.PayUOrderId__c = 'ZPW8VKNDQJ190527GUEST000P01';
        insert newTransaction;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'https://e2e-e2efleetcor.cs88.force.com/services/apexrest/PayUResult';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        String str = '{"order":{"orderId":"ZPW8VKNDQJ190527GUEST000P01","orderCreateDate":"2019-05-27T11:35:19.137Z","notifyUrl":"https://e2e-e2efleetcor.cs88.force.com/services/apexrest/PayUResult","customerIp":"127.0.0.1","merchantPosId":"356975","description":"Fleetcor market","currencyCode":"PLN","totalAmount":"100","buyer":{"customerId":"guest","email":"john@wick.com","phone":"654111654","firstName":"John","lastName":"Wick","language":"pl"},"payMethod":{"type":"CARD_TOKEN"},"status":"COMPLETED","products":[{"name":"Fleetcor fuel cards","unitPrice":"1000","quantity":"1"}]},"localReceiptDateTime":"2019-05-27T11:35:47.251Z","properties":[{"name":"PAYMENT_ID","value":"74590947"}]}';
        req.requestBody = Blob.valueof(str);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        	E2EPayUConfirmation.getPayUInformation();
        Test.stopTest();

        List<Payment_Transaction__c> paymentTransactionList = [
                SELECT PaymentMethod__c, Status__c, BuyerPhone__c, BuyerLastName__c, BuyerFirstName__c, BuyerEmail__c
                FROM Payment_Transaction__c
                WHERE PayUOrderId__c = :newTransaction.PayUOrderId__c
                LIMIT 1
        ];

        System.assertEquals('COMPLETED', paymentTransactionList.get(0).Status__c);
        System.assertEquals('CARD_TOKEN', paymentTransactionList.get(0).PaymentMethod__c);
        System.assertEquals('654111654', paymentTransactionList.get(0).BuyerPhone__c);
        System.assertEquals('Wick', paymentTransactionList.get(0).BuyerLastName__c);
        System.assertEquals('John', paymentTransactionList.get(0).BuyerFirstName__c);
        System.assertEquals('john@wick.com', paymentTransactionList.get(0).BuyerEmail__c);
    }
}