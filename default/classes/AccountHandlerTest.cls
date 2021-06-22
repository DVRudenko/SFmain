@isTest
private class AccountHandlerTest {

    static {
        insert CFUtilsTest.createCFSettingsForRussia(false);
    }

    @isTest
    public static void testAccountUpper() {
        Account a = new Account(Name = 'test', BillingCountry = 'Germany');
        insert a;
        a.Name = 'test1';
        a.Firmenname2_Zusatz__c = 'test';
        a.BillingStreet = 'test';
        a.ShippingStreet = 'test';
        a.BillingCity = 'test';
        a.ShippingCity = 'test';
        update a;
        Account testAcc = [SELECT Name FROM Account WHERE Id = :a.Id LIMIT 1];
        system.assertEquals('TEST1', testAcc.Name);
    }

    @isTest
    public static void testUpdateLastContactDate() {
        Account parentAccount = new Account(Name = 'parent', BillingCountry = 'Germany');
        insert parentAccount;
        Account childAccount1 = new Account(Name = 'child1', ParentId = parentAccount.Id, BillingCountry = 'Germany');
        insert childAccount1;
        Account childAccount2 = new Account(Name = 'child2', ParentId = parentAccount.Id, BillingCountry = 'Germany');
        insert childAccount2;
        childAccount2.Last_contact_date__c = date.today().addDays(-2);
        update childAccount2;

        Account testParentAccount = [
                SELECT Name, Last_contact_date__c
                FROM Account
                WHERE ParentId = null
        ];
        System.assertEquals(testParentAccount.Last_contact_date__c, date.today().addDays(-2));

        Account testChildAccount = [
                SELECT Name, Last_contact_date__c
                FROM Account
                WHERE Name = 'child1'
        ];
        System.assertEquals(testChildAccount.Last_contact_date__c, date.today().addDays(-2));
    }

    /*******************************************************************************
      *  Name            : testLastDateChangeOwnerRUSAndOpenTaskCheckBox()
      *  Summary         : check for change of field Last_Owner_Change_Date_RUS__c when changing owner
      *  CreatedDate     : 20/11/2017
      *  UpdateDate      : 11/05/2017
      *  UpdateBy        : Nikita Mikhailov
      *  Parameters      : -
      *  Returns         : void
      ******************************************************************************/
    @isTest
    public static void testLastDateChangeOwnerRUSAndOpenTaskCheckBox() {
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'
        ];

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;
        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;

        Id recordTypeId;
        Id recordTypeOpportunity;

        if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские') != null) {
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские').getRecordTypeId();
        } else if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian') != null) {
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId();
        }

        if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
            recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
        } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
            recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        }

        Account account = new Account(Name = 'testt', OwnerId = user.Id, RecordTypeId = recordTypeId, BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Client Negotiations',
                CloseDate = Date.today() - 1,
                Angebotsdauer__c = '3 months',
                OwnerId = user.Id,
                RecordTypeId = recordTypeOpportunity
        );
        insert opportunity;

        account.OwnerId = user2.Id;
        update account;

        Opportunity testOpportunity = [
                SELECT Last_Owner_Change_Date_RUS__c
                FROM Opportunity
                WHERE Name = 'testt'
        ];


        System.assertNotEquals(testOpportunity.Last_Owner_Change_Date_RUS__c,
                opportunity.Last_Owner_Change_Date_RUS__c);
    }


    /*******************************************************************************
    *  Name            : testUpdateCurrencyIsoCode()
    *  Summary         : test checking CurrencyIsoCode after insert and after update
    *  CreatedDate     : 03.03.2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testupdateCurrencyIsoCode() {
        Account account = new Account(
                Name = 'testt',
                BillingCountry = 'Germany'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today() - 100,
                Angebotsdauer__c = '3 months'
        );
        insert opportunity;

        account.BillingCountry = 'Poland';
        update account;

        List<Opportunity> oppList = [
                SELECT CurrencyIsoCode
                FROM Opportunity
                LIMIT 1
        ];

        System.assertEquals('PLN', oppList.get(0).CurrencyIsoCode);
    }


    /*******************************************************************************
    *  Name            : testsetFive9Phone()
    *  Summary         : Testing setFive9Phone() before update and before insert
    *  CreatedDate     : 01/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    private static void testsetFive9Phone() {
        List<Account> accountsToInsertList = new List<Account>();

        Account accountGermany = new Account(
                Phone = '0049 111 22 33',
                Fax = '282245167',
                CM_mobile__c = '0112/33(0)2',
                Phone_Crif__c = '49282245167',
                SM_mobile__c = '(0)282245167',
                TM_mobile__c = '28224/5167',
                BillingCountry = 'Germany',
                BillingCountryCode = 'DE',
                Name = 'test');
        accountsToInsertList.add(accountGermany);
        insert accountsToInsertList;

        Set<Id> idsToTest = new Set<Id>();
        for (Account account : accountsToInsertList) {
            idsToTest.add(account.Id);
        }

        Map<Id, Account> accountsToTestMap = new Map<Id, Account>([
                SELECT Phone, Fax, CM_mobile__c, Phone_Crif__c, SM_mobile__c, TM_mobile__c
                FROM Account
                WHERE Id IN :idsToTest
                LIMIT 10000
        ]);

        // Germany
        System.assertEquals('+491112233', accountsToTestMap.get(accountGermany.Id).Phone);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).Fax);
        System.assertEquals('+491123302', accountsToTestMap.get(accountGermany.Id).CM_mobile__c);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).Phone_Crif__c);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).SM_mobile__c);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).TM_mobile__c);
    }


    /*******************************************************************************
    *  Name            : testFindDuplicateTaxId()
    *  Summary         : Find duplicate Tax ID and add error message if it's true
    *  CreatedDate     : 21/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testFindDuplicateTaxId() {
        RecordType accRecType = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Endkunde'];
        Account account = new Account(
                Name = 'test',
                AccountSource = 'ABVP',
                Beschaeftigte__c = '5-9',
                Steuernummer__c = '1111',
                Gesellschaftsform__c = 'Agency of an Overseas Business',
                Phone = '1111111111',
                Type = 'Customer',
                BillingCountry = 'Belgium-NL',
                BillingCountryCode = 'BENL',
                RecordTypeId = accRecType.Id
        );
        insert account;

        Account duplicateAccountTaxId = new Account(
                Name = 'duplicate',
                AccountSource = 'ABVP',
                Beschaeftigte__c = '5-9',
                Steuernummer__c = '111',
                Gesellschaftsform__c = 'Agency of an Overseas Business',
                Phone = '1111111111',
                Type = 'Customer',
                BillingCountry = 'Belgium-FR',
                BillingCountryCode = 'BEFR',
                RecordTypeId = accRecType.Id
        );
        insert duplicateAccountTaxId;

        try {
            duplicateAccountTaxId.Steuernummer__c = '1111';
            update duplicateAccountTaxId;
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Duplicate Tax ID number is found.') ? true : false;
            System.AssertEquals(true, expectedExceptionThrown);
        }
    }

    /*******************************************************************************
    *  Name            : testChangeAccountOwner()
    *  Summary         : testing sendRussianRequestForChangeAccountOwner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testChangeAccountOwner() {
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Russian Sales Manager'
        ];

        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;
        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ManagerId = user2.id);
        insert user;


        system.runAs(user) {
            Id recordTypeId;
            Id recordTypeOpportunity;
            if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские') != null) {
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские').getRecordTypeId();
            } else if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian') != null) {
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId();
            }

            if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
                recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
            } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
                recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
            }

            Account account = new Account(Name = 'testt', OwnerId = user.Id, RecordTypeId = recordTypeId, INN__c = '1234543215', BillingCountry = 'Russia');
            insert account;
            Opportunity opportunity = new Opportunity(
                    Name = 'testt',
                    AccountId = account.Id,
                    StageName = 'Qualified Lead',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    OwnerId = user.Id,
                    RecordTypeId = recordTypeOpportunity,
                    Source_of_Lead_o__c = 'Сайт petrolplus.ru',
                    Primary_Fueling_Method__c = 'Cash'
            );
            insert opportunity;

            account.OwnerId = user2.Id;
            update account;
        }
        Opportunity testOpportunity = [
                SELECT OwnerId
                FROM Opportunity
                WHERE Name = 'testt'
        ];
        Account testAccount = [
                SELECT OwnerId
                FROM Account
                WHERE Name = 'testt'
        ];

        system.debug(testAccount.OwnerId+' '+ user.id);
        system.debug(testOpportunity.OwnerId+' '+ user.id);
        System.assertEquals(testAccount.OwnerId, user.id);
        System.assertEquals(testOpportunity.OwnerId, user.id);
    }


    /*******************************************************************************
    *  Name            : preventUpdateOfInactiveAccountsTest()
    *  Summary         : Test Preventing update if there is no active Opportunities on Account
    *  CreatedDate     : 11/07/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    /*
    @isTest
    static void preventUpdateOfInactiveAccountsTest() {
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        Inactive_Records_Profiles__c profile = new Inactive_Records_Profiles__c(
            Name = profileName);
        insert profile;

        String accountRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Endkunde' AND SObjectType = 'Account' LIMIT 1].Id;

        Account account = new Account(
                Name = 'test',
                RecordTypeId = accountRecordTypeId,
                BillingCountry = 'Germany');
        insert account;

        String opportunityRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SObjectType = 'Opportunity' LIMIT 1].Id;
        Opportunity opportunity = new Opportunity(
            AccountId = account.Id,
            RecordTypeId = opportunityRecordTypeId,
            Name = 'test',
            StageName = 'Closed Won',
            CloseDate = Date.today());
        insert opportunity;

        Test.setCreatedDate(opportunity.Id, Date.today().addDays(-32));

        try {
            update account;
        } catch (Exception e) {
            System.AssertEquals(true, e.getMessage().contains('You are not allowed to update Accounts linked to closed Opportunities. ' +
                'Please create a new open Opportunity or clone the existing one to be able to update related Account record.'));
        }
    }
     */

    @isTest
    public static void testSetRecordAddressFromOKATO(){
        RecordType recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Russian' AND sObjectType = 'Account' LIMIT 1];
        Account newAccount = new Account(
                Name = 'testt',
                RecordTypeId = recordTypeId.Id,
                INN__c = '1234543215',
                BillingCountry = 'Russia');
        insert newAccount;

        newAccount.Billing_OKATO__c = '65476000000';
        update newAccount;
        Account account = [SELECT Region__c, BillingArea__c FROM Account WHERE Id = :newAccount.Id];
        system.assertEquals(account.Region__c,'Свердловская область');
        system.assertEquals(account.BillingArea__c,'город Нижний Тагил');
    }

    /*******************************************************************************
    *  Name            : testSetShippingAddressCCS()
    *  Summary         : test copy Billing Address to Shipping Address if Shipping is empty on insert
    *  CreatedDate     : 28/01/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSetShippingAddressCCS(){
        RecordType recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'CCS' AND sObjectType = 'Account' LIMIT 1];

        Account newAccount = new Account(
                Name = 'TEST CCS',
                RecordTypeId = recordTypeId.Id,
                Phone = '+420123456789',
                BillingCountry = 'Czech Republic',
                BillingStreet = 'TESTING STR',
                BillingCity = 'Prague',
                BillingState = 'Prague',
                BillingPostalCode = '19000');
        insert newAccount;

        Account account = [SELECT ShippingStreet FROM Account WHERE Id = :newAccount.Id];
        system.assertEquals(account.ShippingStreet,'TESTING STR');
    }


    /*******************************************************************************
    *  Name            : Test All BIZMACHINE
    *  Summary         :
    *  CreatedDate     : 09/09/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/

    @IsTest
    static void testBizmachineRemoveBizTags() {
        BizMachine_Settings__c bs = new BizMachine_Settings__c();
        bs.Name = 'Credentials';
        bs.API_Key__c = '1234';
        bs.Sandbox_Dataset__c = 'asd';
        bs.Production_Dataset__c = 'asd';
        bs.Production_Endpoint__c = 'http://asd.com';
        bs.Sandbox_Endpoint__c = 'http://asd.com';
        insert bs;

        BizMachine_Data_Settings__c bizData = new BizMachine_Data_Settings__c();
        bizData.BizMachine_Tag_UID__c = 'UID';
        bizData.Name = 'Updated';
        bizData.BizMachine_Tag_Name__c = 'Tag Name';
        bizData.BizMachine_Updated_Tag__c = true;
        insert bizData;

        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        List<Account> accs = new List<Account>();
        accs.add(acc);
        Test.startTest();
        AccountTriggerHandler.removeBizMachineTag(accs);
        Test.stopTest();
    }

    @IsTest
    static void testBizmachineRemoveBizTags2() {
        BizMachine_Settings__c bs = new BizMachine_Settings__c();
        bs.Name = 'Credentials';
        bs.API_Key__c = '1234';
        bs.Sandbox_Dataset__c = 'asd';
        bs.Production_Dataset__c = 'asd';
        bs.Production_Endpoint__c = 'http://asd.com';
        bs.Sandbox_Endpoint__c = 'http://asd.com';
        insert bs;

        BizMachine_Data_Settings__c bizData = new BizMachine_Data_Settings__c();
        bizData.BizMachine_Tag_UID__c = 'UID';
        bizData.Name = 'Updated';
        bizData.BizMachine_Tag_Name__c = 'Tag Name';
        bizData.BizMachine_Updated_Tag__c = true;
        insert bizData;

        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        BizMachine_Data_Settings__c bData = new BizMachine_Data_Settings__c();
        bData.BizMachine_Tag_UID__c = 'UID';
        bData.BizMachine_Monitoring_Tag__c = true;
        bData.Name = 'Name2';
        insert bData;

        List<Account> accs = new List<Account>();
        accs.add(acc);
        Test.startTest();
        AccountTriggerHandler.removeBizMachineTag(accs);
        Test.stopTest();
    }

    @IsTest
    static void testBizmachineGetData() {
        BizMachine_Settings__c bs = new BizMachine_Settings__c();
        bs.Name = 'Credentials';
        bs.API_Key__c = '1234';
        bs.Sandbox_Dataset__c = 'asd';
        bs.Production_Dataset__c = 'asd';
        bs.Production_Endpoint__c = 'http://asd.com';
        bs.Sandbox_Endpoint__c = 'http://asd.com';
        insert bs;

        BizMachine_Data_Settings__c bizData = new BizMachine_Data_Settings__c();
        bizData.BizMachine_Tag_UID__c = 'UID';
        bizData.Name = 'Updated';
        bizData.BizMachine_Tag_Name__c = 'Tag Name';
        bizData.BizMachine_Updated_Tag__c = true;
        insert bizData;

        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        BizMachine_Data_Settings__c bData = new BizMachine_Data_Settings__c();
        bData.BizMachine_Tag_UID__c = 'UID';
        bData.BizMachine_Monitoring_Tag__c = true;
        bData.Name = 'Name2';
        insert bData;

        Set<Id> setIds = new Set<Id>();
        setIds.add(acc.Id);
        Test.startTest();
        AccountTriggerHandler.getAccountDataFromBizmachineFutureCall(setIds);
        Test.stopTest();
    }

    @IsTest
    static void testBizmachineEditICO() {
        BizMachine_Settings__c bs = new BizMachine_Settings__c();
        bs.Name = 'Credentials';
        bs.API_Key__c = '1234';
        bs.Sandbox_Dataset__c = 'asd';
        bs.Production_Dataset__c = 'asd';
        bs.Production_Endpoint__c = 'http://asd.com';
        bs.Sandbox_Endpoint__c = 'http://asd.com';
        insert bs;

        BizMachine_Data_Settings__c bizData = new BizMachine_Data_Settings__c();
        bizData.BizMachine_Tag_UID__c = 'UID';
        bizData.Name = 'Updated';
        bizData.BizMachine_Tag_Name__c = 'Tag Name';
        bizData.BizMachine_Updated_Tag__c = true;
        insert bizData;

        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        Account acc2 = [SELECT Id FROM Account WHERE Id = :acc.Id];
        acc2.CCS_Company_ID__c = '27916693';
        Test.startTest();
        update acc2;
        Test.stopTest();
    }

    @IsTest
    static void testBizmachineRemoveTag() {
        BizMachine_Settings__c bs = new BizMachine_Settings__c();
        bs.Name = 'Credentials';
        bs.API_Key__c = '1234';
        bs.Sandbox_Dataset__c = 'asd';
        bs.Production_Dataset__c = 'asd';
        bs.Production_Endpoint__c = 'http://asd.com';
        bs.Sandbox_Endpoint__c = 'http://asd.com';
        insert bs;

        BizMachine_Data_Settings__c bizData = new BizMachine_Data_Settings__c();
        bizData.BizMachine_Tag_UID__c = 'UID';
        bizData.Name = 'Updated';
        bizData.BizMachine_Tag_Name__c = 'Tag Name';
        bizData.BizMachine_Updated_Tag__c = true;
        insert bizData;

        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());

        AccountTriggerHandler.removeBizMachineTagFuture('ic','uid');
    }


    @IsTest
    static void testAccountCreate() {
        BizMachine_Settings__c bs = new BizMachine_Settings__c();
        bs.Name = 'Credentials';
        bs.API_Key__c = '1234';
        bs.Sandbox_Dataset__c = 'asd';
        bs.Production_Dataset__c = 'asd';
        bs.Production_Endpoint__c = 'http://asd.com';
        bs.Sandbox_Endpoint__c = 'http://asd.com';
        insert bs;

        BizMachine_Data_Settings__c bizData = new BizMachine_Data_Settings__c();
        bizData.BizMachine_Tag_UID__c = 'UID';
        bizData.Name = 'Updated';
        bizData.BizMachine_Tag_Name__c = 'Tag Name';
        bizData.BizMachine_Updated_Tag__c = true;
        insert bizData;

        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;

        Test.startTest();
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        insert acc;

        Test.stopTest();
    }
}