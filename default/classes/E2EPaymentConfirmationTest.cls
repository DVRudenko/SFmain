@IsTest
private class E2EPaymentConfirmationTest {

    static testMethod void testPaymentConfirmation1(){

        insert new E2EKeysAPI__c(Name ='E2EForm', 	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c='https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c='fleetcorTEST', SHA_KeyIn__c='FleetcorTest!12@', SHA_KeyOut__c='IngenFleetTest1!');

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(),
                Accountid = account.id, Angebotsdauer__c='test',Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c newTransaction = new Payment_Transaction__c();
        newTransaction.amount__c = 10;
        newTransaction.Currency__c='EUR';
        newTransaction.opportunityId__c = opportunity.id;
        insert newTransaction;

        List<Payment_Transaction__c> listOfTransactions = [
                SELECT Id, 	OrderID__c, Currency__c, amount__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'https://www.salesforce.com/services/apexrest/PaymentResult';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('currency',listOfTransactions.get(0).Currency__c);
        req.addParameter('amount', String.valueof(listOfTransactions.get(0).amount__c));
        req.addParameter('orderID',listOfTransactions.get(0).OrderID__c);
        req.addParameter('STATUS','9');
        req.addParameter('SHASIGN',E2EFormEncryption.getHashAlgorithmStringSHA1(
                        'AMOUNT='   + String.valueof(listOfTransactions.get(0).amount__c) + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'CURRENCY=' + listOfTransactions.get(0).Currency__c               + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'ORDERID='  + listOfTransactions.get(0).OrderID__c                + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'STATUS='   + '9'                                                 + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c ));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        E2EPaymentConfirmation.getPaymentInformation();
        Test.stopTest();

        List<Payment_Transaction__c> testList = [
                SELECT Id, 	Authorized__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        System.assertEquals(testList.get(0).Authorized__c, true);
    }

    static testMethod void testPaymentConfirmation2(){

        insert new E2EKeysAPI__c(Name ='E2EForm', 	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c='https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c='fleetcorTEST', SHA_KeyIn__c='FleetcorTest!12@', SHA_KeyOut__c='IngenFleetTest1!');

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(),
                Accountid = account.id, Angebotsdauer__c='test',Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c newTransaction = new Payment_Transaction__c();
        newTransaction.amount__c = 10;
        newTransaction.Currency__c='EUR';
        newTransaction.opportunityId__c = opportunity.id;
        insert newTransaction;

        List<Payment_Transaction__c> listOfTransactions = [
                SELECT Id, 	OrderID__c, Currency__c, amount__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'https://www.salesforce.com/services/apexrest/PaymentResult';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('currency',listOfTransactions.get(0).Currency__c);
        req.addParameter('amount', String.valueof(listOfTransactions.get(0).amount__c));
        req.addParameter('orderID',listOfTransactions.get(0).OrderID__c);
        req.addParameter('STATUS','1');
        req.addParameter('SHASIGN',E2EFormEncryption.getHashAlgorithmStringSHA1(
                'AMOUNT='   + String.valueof(listOfTransactions.get(0).amount__c) + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'CURRENCY=' + listOfTransactions.get(0).Currency__c               + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'ORDERID='  + listOfTransactions.get(0).OrderID__c                + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'STATUS='   + '1'                                                 + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c ));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        E2EPaymentConfirmation.getPaymentInformation();
        Test.stopTest();

        List<Payment_Transaction__c> testList = [
                SELECT Id, 	Authorized__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        System.assertEquals(testList.get(0).Authorized__c, true);
    }

    static testMethod void testPaymentConfirmation3(){

        insert new E2EKeysAPI__c(Name ='E2EForm', 	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c='https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c='fleetcorTEST', SHA_KeyIn__c='FleetcorTest!12@', SHA_KeyOut__c='IngenFleetTest1!');

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(),
                Accountid = account.id, Angebotsdauer__c='test',Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c newTransaction = new Payment_Transaction__c();
        newTransaction.amount__c = 10;
        newTransaction.Currency__c='EUR';
        newTransaction.opportunityId__c = opportunity.id;
        insert newTransaction;

        List<Payment_Transaction__c> listOfTransactions = [
                SELECT Id, 	OrderID__c, Currency__c, amount__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'https://www.salesforce.com/services/apexrest/PaymentResult';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('currency',listOfTransactions.get(0).Currency__c);
        req.addParameter('amount', String.valueof(listOfTransactions.get(0).amount__c));
        req.addParameter('orderID',listOfTransactions.get(0).OrderID__c);
        req.addParameter('STATUS','2');
        req.addParameter('SHASIGN',E2EFormEncryption.getHashAlgorithmStringSHA1(
                'AMOUNT='   + String.valueof(listOfTransactions.get(0).amount__c) + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'CURRENCY=' + listOfTransactions.get(0).Currency__c               + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'ORDERID='  + listOfTransactions.get(0).OrderID__c                + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'STATUS='   + '2'                                                 + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c ));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        E2EPaymentConfirmation.getPaymentInformation();
        Test.stopTest();

        List<Payment_Transaction__c> testList = [
                SELECT Id, 	Authorized__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        System.assertEquals(testList.get(0).Authorized__c, true);
    }

    static testMethod void testPaymentConfirmation4(){

        insert new E2EKeysAPI__c(Name ='E2EForm', 	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c='https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c='fleetcorTEST', SHA_KeyIn__c='FleetcorTest!12@', SHA_KeyOut__c='IngenFleetTest1!');

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(),
                Accountid = account.id, Angebotsdauer__c='test',Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c newTransaction = new Payment_Transaction__c();
        newTransaction.amount__c = 10;
        newTransaction.Currency__c='EUR';
        newTransaction.opportunityId__c = opportunity.id;
        insert newTransaction;

        List<Payment_Transaction__c> listOfTransactions = [
                SELECT Id, 	OrderID__c, Currency__c, amount__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'https://www.salesforce.com/services/apexrest/PaymentResult';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('currency',listOfTransactions.get(0).Currency__c);
        req.addParameter('amount', String.valueof(listOfTransactions.get(0).amount__c));
        req.addParameter('orderID',listOfTransactions.get(0).OrderID__c);
        req.addParameter('STATUS','12');
        req.addParameter('SHASIGN',E2EFormEncryption.getHashAlgorithmStringSHA1(
                'AMOUNT='   + String.valueof(listOfTransactions.get(0).amount__c) + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'CURRENCY=' + listOfTransactions.get(0).Currency__c               + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'ORDERID='  + listOfTransactions.get(0).OrderID__c                + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'STATUS='   + '12'                                                 + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c ));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        E2EPaymentConfirmation.getPaymentInformation();
        Test.stopTest();

        List<Payment_Transaction__c> testList = [
                SELECT Id, 	Authorized__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        System.assertEquals(testList.get(0).Authorized__c, true);
    }

    static testMethod void testPaymentConfirmation5(){

        insert new E2EKeysAPI__c(Name ='E2EForm', 	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c='https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c='fleetcorTEST', SHA_KeyIn__c='FleetcorTest!12@', SHA_KeyOut__c='IngenFleetTest1!');

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(),
                Accountid = account.id, Angebotsdauer__c='test',Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c newTransaction = new Payment_Transaction__c();
        newTransaction.amount__c = 10;
        newTransaction.Currency__c='EUR';
        newTransaction.opportunityId__c = opportunity.id;
        insert newTransaction;

        List<Payment_Transaction__c> listOfTransactions = [
                SELECT Id, 	OrderID__c, Currency__c, amount__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'https://www.salesforce.com/services/apexrest/PaymentResult';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('currency',listOfTransactions.get(0).Currency__c);
        req.addParameter('amount', String.valueof(listOfTransactions.get(0).amount__c));
        req.addParameter('orderID','INCORRECT ORDER ID');
        req.addParameter('STATUS','12');
        req.addParameter('SHASIGN',E2EFormEncryption.getHashAlgorithmStringSHA1(
                'AMOUNT='   + String.valueof(listOfTransactions.get(0).amount__c) + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'CURRENCY=' + listOfTransactions.get(0).Currency__c               + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'ORDERID='  + listOfTransactions.get(0).OrderID__c                + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'STATUS='   + '12'                                                + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c ));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        E2EPaymentConfirmation.getPaymentInformation();
        Test.stopTest();

        List<Payment_Transaction__c> testList = [
                SELECT Id, 	Authorized__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        System.assertEquals(testList.get(0).Authorized__c, false);
    }

    static testMethod void testPaymentConfirmation6(){

        insert new E2EKeysAPI__c(Name ='E2EForm', 	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c='https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c='fleetcorTEST', SHA_KeyIn__c='FleetcorTest!12@', SHA_KeyOut__c='IngenFleetTest1!');

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(),
                Accountid = account.id, Angebotsdauer__c='test',Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c newTransaction = new Payment_Transaction__c();
        newTransaction.amount__c = 10;
        newTransaction.Currency__c='EUR';
        newTransaction.opportunityId__c = opportunity.id;
        insert newTransaction;

        List<Payment_Transaction__c> listOfTransactions = [
                SELECT Id, 	OrderID__c, Currency__c, amount__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'https://www.salesforce.com/services/apexrest/PaymentResult';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('currency',listOfTransactions.get(0).Currency__c);
        req.addParameter('amount', String.valueof(listOfTransactions.get(0).amount__c));
        req.addParameter('orderID',listOfTransactions.get(0).OrderID__c);
        req.addParameter('STATUS','12');
        req.addParameter('SHASIGN',E2EFormEncryption.getHashAlgorithmStringSHA1(
                'AMOUNT='   + String.valueof(listOfTransactions.get(0).amount__c) + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'CURRENCY=' + listOfTransactions.get(0).Currency__c               + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'ORDERID='  + 'INCORRECT ORDER ID'                + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c +
                        'STATUS='   + '12'                                                 + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyOut__c ));
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        E2EPaymentConfirmation.getPaymentInformation();
        Test.stopTest();

        List<Payment_Transaction__c> testList = [
                SELECT Id, 	Authorized__c
                FROM Payment_Transaction__c
                WHERE id = :newTransaction.id
        ];

        System.assertEquals(testList.get(0).Authorized__c, false);
    }
}