@isTest
private class ETEDataGeneratorTest {
    @IsTest
    private static void getETEFormNameWithNumberTest() {
        String clientNumber = '+4811234123';
        Test.startTest();
            String name = ETEDataGenerator.getETEFormName(clientNumber, null);
        Test.stopTest();
        System.assert(name.contains(clientNumber));
    }


    @IsTest
    private static void getETEFormNameWithObnTest() {
        String obn = 'q1224';
        Test.startTest();
            String name = ETEDataGenerator.getETEFormName(null, obn);
        Test.stopTest();
        System.assert(name.contains(obn));
    }


    @IsTest
    private static void getRetailerAccountTest() {
        String country = 'Poland';
        String obn = 'PR003';
        Account retailerAccount = new Account(
                Name = 'test',
                BillingCountry = country,
                OBN__c = obn
        );
        insert retailerAccount;

        Test.startTest();
            List<Account> acc = ETEDataGenerator.getRetailerAccount(country, obn);
        Test.stopTest();
        System.assertEquals(acc.get(0).OBN__c, retailerAccount.OBN__c);
    }


    @IsTest
    private static void insertAccountTest() {
        String recordTypeName = 'Lotos';
        String country = 'Poland';
        String formName = 'NEW E2E CUSTOMER';
        Test.startTest();
            Account account = ETEDataGenerator.insertAccount(recordTypeName, country, formName);
        Test.stopTest();
        System.assert(account != null);
    }


    @IsTest
    private static void insertE2EDataObjectTest() {
        String step = 'contacts';
        String stageName = 'Qualify';
        String recordTypeName = 'Poland Lotos';
        Test.startTest();
            E2E_Data_Object__c dataObject = ETEDataGenerator.insertE2EDataObject(step, stageName, recordTypeName, null, null, null, 'pl', 'pl', null,null, null);
        Test.stopTest();
        System.assertEquals(step, dataObject.Current_Step__c);
        System.assertEquals(stageName, dataObject.StageName__c);
    }


    @IsTest
    private static void insertE2EDataLogTest() {
        String step = 'contacts';
        String stageName = 'Qualify';
        String recordTypeName = 'Poland Lotos';
        Test.startTest();
            E2E_Data_Object__c dataObject = ETEDataGenerator.insertE2EDataObject(step, stageName, recordTypeName, null, null, null, 'pl', 'pl', null,null, null);
            E2E_Data_Log__c dataLog = ETEDataGenerator.insertE2EDataLog('Job Status', dataObject.Id, 'Completed', 'checkBusinessObjects');
        Test.stopTest();
        System.assert(dataLog != null);
    }


    @IsTest
    private static void insertContactTest() {
        Account account = new Account(Name = 'test', BillingCountry = 'Poland');
        insert account;
        Test.startTest();
            Contact contact = ETEDataGenerator.insertContact('NEW E2E CUSTOMER', 'Endkunde', account.Id, '+4812838512', 'Poland');
        Test.stopTest();
        System.assert(contact != null);
    }


    @IsTest
    private static void insertOpportunityContactRoleTest() {
        Opportunity opportunity = new Opportunity(Name = 'NEW E2E CUSTOMER', StageName = 'Prospecting', CloseDate = Date.today());
        insert opportunity;
        Contact contact = new Contact(LastName = 'JOHN', Salutation = 'Mr.');
        insert contact;
        Test.startTest();
            ETEDataGenerator.insertOpportunityContactRole(opportunity.Id, contact.Id);
        Test.stopTest();
        List<OpportunityContactRole> opportunityContactRole = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND ContactId = :contact.Id];
        System.assert( ! opportunityContactRole.isEmpty() );
    }


    @IsTest
    private static void setPartnerRelationshipTest() {
        List<Account> accList = new List<Account>();
        Account retailerAccount = new Account(
                Name = 'test',
                BillingCountry = 'Poland',
                OBN__c = 'PR003'
        );
        accList.add(retailerAccount);
        insert accList;
        Opportunity opportunity = new Opportunity(Name = 'NEW E2E CUSTOMER', StageName = 'Prospecting', CloseDate = Date.today());
        insert opportunity;
        Test.startTest();
            ETEDataGenerator.setPartnerRelationship(accList, opportunity.Id);
        Test.stopTest();
        List<Partner> partnerList = [SELECT Id FROM Partner WHERE AccountToId = :accList.get(0).Id AND OpportunityId =:opportunity.Id];
        System.assert( ! partnerList.isEmpty() );
    }


    @IsTest private static void insertOpportunityTest() {
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(Name = 'E2EFormPL', AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=', paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp', PSPID__c = 'fleetcorTEST', SHA_KeyIn__c = 'FleetcorTest!12@', SHA_KeyOut__c = 'IngenFleetTest1!');
        insert e2eKeysApi;
        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(Name = 'Poland', E2E_Form_Url__c = 'https://online.fleetcor.pl/', E2E_JITB_Form_Url__c = 'https://online.fleetcor.pl/e2ejitblocator', Private_Key__c = 'P83U8MmjgIBU0V4l', Short_Url__c = 'https://online.fleetcor.pl/i');
        insert shortUrlSettings;
        List<Account> retailerAccountList = new List<Account>();
        Account retailerAccount = new Account(Name = 'test', BillingCountry = 'Poland', OBN__c = 'PR003', BillingStreet = 'test', BillingCity = 'test');
        retailerAccountList.add(retailerAccount);
        insert retailerAccountList;
        Account account = new Account(Name = 'NEW E2E CUSTOMER', BillingCountry = 'Poland');
        insert account;
        E2E_Data_Object__c dataObject = ETEDataGenerator.insertE2EDataObject('contacts', 'Qualify', 'Poland Lotos', null, null, null, 'pl', 'pl', null,null, null);
        Test.startTest();
            Opportunity opportunity = ETEDataGenerator.insertOpportunity('NEW E2E CUSTOMER', retailerAccountList, account.Id, 'Lotos', 'Prospecting', 'Poland', '+4845683434', 'JITB', 'PR003', dataObject.Id, 'JITB');
        Test.stopTest();
        System.assert(opportunity != null);
    }
}