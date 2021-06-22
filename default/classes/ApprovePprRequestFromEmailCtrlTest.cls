@IsTest private class ApprovePprRequestFromEmailCtrlTest {

    static {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        insert new Ru_Admin_Approver__c(
                Name = 'approver@test.ru'
        );
    }

    static testMethod void changeOwnerFromFindDuplicates1() {
        String recordTypeLead = [SELECT id FROM recordtype WHERE name = 'Russian Sales' AND SobjectType = 'Lead'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user2;

        Lead lead = new Lead(Phone = '+79852769431', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = user.id);
        insert lead;

        ApexPages.currentPage().getParameters().put('type', '001');
        ApexPages.currentPage().getParameters().put('idRecord', lead.id);
        ApexPages.currentPage().getParameters().put('idNewOwner', user2.id);
        ApexPages.currentPage().getParameters().put('answer', 'yes');

        ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

        controller.init();
        controller.goToRecord();
        controller.getReasonsForReject();
        //SF-393
        controller.confirmFromFindDuplicates(lead.id, user2.id, 'yes');

        List<Lead> assertListLead = [SELECT id, ownerid from lead where id = :lead.id];

        system.assertEquals(user2.id, assertListLead.get(0).ownerid);

    }


    static testMethod void changeOwnerFromFindDuplicates2() {
        String recordTypeLead = [SELECT id FROM recordtype WHERE name = 'Russian Sales' AND SobjectType = 'Lead'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user2;

        Lead lead = new Lead(Phone = '+79852769431', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = user.id);
        insert lead;

        ApexPages.currentPage().getParameters().put('type', '001');
        ApexPages.currentPage().getParameters().put('idRecord', lead.id);
        ApexPages.currentPage().getParameters().put('idNewOwner', user2.id);
        ApexPages.currentPage().getParameters().put('answer', 'no');

        ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

        controller.init();
        controller.rejectRequest();

        List<Lead> assertListLead = [SELECT id, ownerid from lead where id = :lead.id];

        system.assertEquals(user.id, assertListLead.get(0).ownerid);

    }


    static testMethod void changeOwnerFromFindDuplicates3() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user2;

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user.id);
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                RecordTypeID = RecordTypeOpp, Ownerid = user.id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('type', '001');
        ApexPages.currentPage().getParameters().put('idRecord', opportunity.id);
        ApexPages.currentPage().getParameters().put('idNewOwner', user2.id);
        ApexPages.currentPage().getParameters().put('answer', 'yes');

        ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

        controller.init();
        //SF-393
        controller.confirmFromFindDuplicates(opportunity.id, user2.id, 'yes');

        List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];
        List<Account> assertListAcc = [SELECT id, ownerid FROM Account WHERE id = :Account.id];

        system.assertEquals(user2.id, assertListOpp.get(0).ownerid);
        system.assertEquals(user2.id, assertListAcc.get(0).ownerid);
    }

    static testMethod void changeOwnerFromFindDuplicates4() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user2;

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user.id);
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                RecordTypeID = RecordTypeOpp, Ownerid = user.id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('type', '001');
        ApexPages.currentPage().getParameters().put('idRecord', opportunity.id);
        ApexPages.currentPage().getParameters().put('idNewOwner', user2.id);
        ApexPages.currentPage().getParameters().put('answer', 'no');

        ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

        controller.init();
        controller.rejectRequest();

        List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];
        List<Account> assertListAcc = [SELECT id, ownerid FROM Account WHERE id = :Account.id];

        system.assertEquals(user.id, assertListOpp.get(0).ownerid);
        system.assertEquals(user.id, assertListAcc.get(0).ownerid);
    }

    private static void changeOwnerFromFindDuplicates5() {
        String recordTypeLead = [SELECT id FROM recordtype WHERE name = 'Russian Sales' AND SobjectType = 'Lead'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user2;

        Lead lead = new Lead(Phone = '+79852769431', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = user.id);
        insert lead;

        Profile nonAdminProfile = ([
                SELECT Id
                FROM Profile
                WHERE Name = 'Russian Team Leader'
        ]);
        User nonAdminUser = new User(Username = 'noAdmin@fleetcor.ru', ProfileId = nonAdminProfile.Id, Alias = 'usetgdfg@fl', Email = 'noAdmin@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', LastName = 'usertest3', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert nonAdminUser;

        ApexPages.currentPage().getParameters().put('type', '001');
        ApexPages.currentPage().getParameters().put('idRecord', lead.id);
        ApexPages.currentPage().getParameters().put('idNewOwner', user2.id);
        ApexPages.currentPage().getParameters().put('answer', 'yes');

        System.runAs(nonAdminUser) {
            ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();
            controller.init();
            controller.goToRecord();
            controller.getReasonsForReject();
        }

        System.assertEquals(user2.Id, [SELECT OwnerId FROM Lead WHERE Id = :lead.Id].OwnerId);


    }

    static testMethod void changeOwnerRecordByTeamLead1() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user1 = new User(Username = 'usertest1@fleetcor.ru', ProfileId = p.Id, Alias = 'uset1@fl', Email = 'usertest1@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user1;
        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago',
                ManagerId = user1.id);
        insert user2;
        User user3 = new User(Username = 'usertest3@fleetcor.ru', ProfileId = p.Id, Alias = 'uset3@fl', Email = 'usertest3@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest3', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user3;

        system.runAs(user1) {
            Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user2.id);
            insert account;
            Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                    RecordTypeID = RecordTypeOpp, Ownerid = user2.id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('type', '002');
            ApexPages.currentPage().getParameters().put('idRecord', opportunity.id);
            ApexPages.currentPage().getParameters().put('idNewOwner', user3.id);
            ApexPages.currentPage().getParameters().put('answer', 'yes');

            ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

            controller.init();
            //SF-393
            controller.confirmRecordByTeamLead(opportunity.id, user3.id, 'yes');

            List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];
            List<Account> assertListAcc = [SELECT id, ownerid FROM Account WHERE id = :Account.id];

            system.assertEquals(user3.id, assertListOpp.get(0).ownerid);
            system.assertEquals(user3.id, assertListAcc.get(0).ownerid);
        }
    }

    static testMethod void changeOwnerRecordByTeamLead2() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user1 = new User(Username = 'usertest1@fleetcor.ru', ProfileId = p.Id, Alias = 'uset1@fl', Email = 'usertest1@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user1;
        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago',
                ManagerId = user1.id);
        insert user2;
        User user3 = new User(Username = 'usertest3@fleetcor.ru', ProfileId = p.Id, Alias = 'uset3@fl', Email = 'usertest3@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest3', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user3;

        system.runAs(user1) {
            Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user2.id);
            insert account;
            Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                    RecordTypeID = RecordTypeOpp, Ownerid = user2.id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('type', '002');
            ApexPages.currentPage().getParameters().put('idRecord', opportunity.id);
            ApexPages.currentPage().getParameters().put('idNewOwner', user2.id);
            ApexPages.currentPage().getParameters().put('answer', 'no');

            ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

            controller.init();
            controller.rejectRequest();

            List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];
            List<Account> assertListAcc = [SELECT id, ownerid FROM Account WHERE id = :Account.id];

            system.assertEquals(user2.id, assertListOpp.get(0).ownerid);
            system.assertEquals(user2.id, assertListAcc.get(0).ownerid);
        }
    }

    static testMethod void processingRequestForSecondOpportunity1() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];


        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user2;
        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago',
                ManagerId = user2.id);
        insert user;

        system.runAs(user2) {
            Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user.id);
            insert account;
            Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                    RecordTypeID = RecordTypeOpp, Ownerid = user2.id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('type', '003');
            ApexPages.currentPage().getParameters().put('idRecord', opportunity.id);
            ApexPages.currentPage().getParameters().put('idNewOwner', user.id);
            ApexPages.currentPage().getParameters().put('answer', 'yes');

            ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

            controller.init();
            //SF-393
            controller.confirmForSecondOpportunity(opportunity.id, user.id, 'yes');

            List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];

            system.assertEquals(user.id, assertListOpp.get(0).ownerid);
        }
    }

    static testMethod void processingRequestForSecondOpportunity2() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user2;
        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago',
                ManagerId = user2.id);
        insert user;

        system.runAs(user2) {
            Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user.id);
            insert account;
            Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                    RecordTypeID = RecordTypeOpp, Ownerid = user2.id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('type', '003');
            ApexPages.currentPage().getParameters().put('idRecord', opportunity.id);
            ApexPages.currentPage().getParameters().put('idNewOwner', user.id);
            ApexPages.currentPage().getParameters().put('answer', 'no');

            ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

            controller.init();
            controller.rejectRequest();

            List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];

            system.assertEquals(assertListOpp.size(), 0);
        }
    }

    static testMethod void changeOwnerAccountByTeamLead1() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user1 = new User(Username = 'usertest1@fleetcor.ru', ProfileId = p.Id, Alias = 'uset1@fl', Email = 'usertest1@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user1;
        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago',
                ManagerId = user1.id);
        insert user2;
        User user3 = new User(Username = 'usertest3@fleetcor.ru', ProfileId = p.Id, Alias = 'uset3@fl', Email = 'usertest3@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest3', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user3;

        system.runAs(user1) {
            Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user2.id);
            insert account;
            Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                    RecordTypeID = RecordTypeOpp, Ownerid = user2.id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('type', '004');
            ApexPages.currentPage().getParameters().put('idRecord', opportunity.id);
            ApexPages.currentPage().getParameters().put('idNewOwner', user2.id);
            ApexPages.currentPage().getParameters().put('answer', 'yes');

            ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

            controller.init();
            controller.rejectRequest();

            List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];
            List<Account> assertListAcc = [SELECT id, ownerid FROM Account WHERE id = :Account.id];

            system.assertEquals(user2.id, assertListOpp.get(0).ownerid);
            system.assertEquals(user2.id, assertListAcc.get(0).ownerid);
        }
    }

    static testMethod void changeOwnerAccountByTeamLead2() {

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];

        User user1 = new User(Username = 'usertest1@fleetcor.ru', ProfileId = p.Id, Alias = 'uset1@fl', Email = 'usertest1@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user1;
        User user2 = new User(Username = 'usertest2@fleetcor.ru', ProfileId = p.Id, Alias = 'uset2@fl', Email = 'usertest2@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago',
                ManagerId = user1.id);
        insert user2;
        User user3 = new User(Username = 'usertest3@fleetcor.ru', ProfileId = p.Id, Alias = 'uset3@fl', Email = 'usertest3@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest3', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user3;

        system.runAs(user1) {
            Account account = new Account(Name = 'test1', BillingPostalCode = '1231', RecordTypeID = RecordTypeAcc, Ownerid = user2.id);
            insert account;
            Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                    RecordTypeID = RecordTypeOpp, Ownerid = user2.id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('type', '004');
            ApexPages.currentPage().getParameters().put('idRecord', account.id);
            ApexPages.currentPage().getParameters().put('idNewOwner', user1.id);
            ApexPages.currentPage().getParameters().put('answer', 'yes');

            ApprovePprRequestFromEmailCtrl controller = new ApprovePprRequestFromEmailCtrl();

            controller.init();
            //SF-393
            controller.confirmAccountByTeamLead(account.id, user1.id, 'yes');

            List<Opportunity> assertListOpp = [SELECT id, ownerid FROM Opportunity WHERE id = :Opportunity.id];
            List<Account> assertListAcc = [SELECT id, ownerid FROM Account WHERE id = :Account.id];

            system.assertEquals(user1.id, assertListOpp.get(0).ownerid);
            system.assertEquals(user1.id, assertListAcc.get(0).ownerid);
        }
    }

}