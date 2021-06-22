@isTest
public class FindDuplicatesCtrlTest {

    @IsTest
    public static void searchTestPublicDomainEmail() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'test@gmail.com', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = 'testadd@gmail.com');
        insert lead;
        Lead lead2 = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = '434454@gmail.com', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = '4234add@gmail.com');
        insert lead2;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesCtrl contr = new FindDuplicatesCtrl();
        contr.idForRequest = lead.Id;
        contr.sendRequestForChangeOwner();

        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.init();
        controller.isINNSelected = false;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = false;
        controller.searchPage();

        System.assertEquals(1, controller.leadsResult.size());
    }

    @IsTest
    public static void searchTestPublicDomainAdditionalEmails() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'test@gmail.com', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = 'testadd@gmail.com');
        insert lead;
        Lead lead2 = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = '434454@gmail.com', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = '4234add@gmail.com');
        insert lead2;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesCtrl contr = new FindDuplicatesCtrl();
        contr.idForRequest = lead.Id;
        contr.sendRequestForChangeOwner();

        //additional emails
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = false;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = false;
        controller.init();
        controller.sEmail = 'testadd@gmail.com';
        controller.searchPage();

        System.assertEquals(2, controller.leadsResult.size());
    }

    @IsTest
    public static void searchTestNotPublicDomainEmail() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'test@test.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = 'testadd@test.ru');
        insert lead;
        Lead lead2 = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = '423423@test.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = '4234add@test.ru');
        insert lead2;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesCtrl contr = new FindDuplicatesCtrl();
        contr.idForRequest = lead.Id;
        contr.sendRequestForChangeOwner();

        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.init();
        controller.isINNSelected = false;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = false;
        controller.searchPage();

        System.assertEquals(2, controller.leadsResult.size());

    }

    @IsTest
    public static void searchTestNotPublicDomainAdditionalEmails() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'test@test.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = 'testadd@test.ru');
        insert lead;
        Lead lead2 = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = '423423@test.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL, Additional_Emails__c = '4234add@test.ru');
        insert lead2;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesCtrl contr = new FindDuplicatesCtrl();
        contr.idForRequest = lead.Id;
        contr.sendRequestForChangeOwner();

        //additional emails
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = false;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = false;
        controller.init();
        controller.sEmail = 'testadd@test.ru';
        controller.searchPage();

        System.assertEquals(2, controller.leadsResult.size());
    }

    @isTest
    public static void searchTest() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        String RecordTypeCon = [select id from recordtype where name = 'Russian' and SobjectType = 'Contact'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL);
        insert lead;

        Account accountt = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Phone = '+71234567891',
                INN__C = '1234567899999',
                RecordTypeId = RecordTypeAcc);
        insert accountt;

        Contact contt = new Contact(
                LastName = 'testcontact12345',
                Phone = '+71234567891',
                Email = 'Email12345678910@gggmail.ru',
                AccountId = accountt.Id,
                RecordTypeId = RecordTypeCon);
        insert contt;

        Opportunity opportunity = createOpportunity(accountt);
        insert opportunity;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesCtrl contr = new FindDuplicatesCtrl();
        contr.idForRequest = opportunity.Id;
        contr.sendRequestForChangeOwner();

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = true;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.accResult.size(), 1);
        System.assertEquals(controller.accResult[0].oppList.size(), 1);
        Id currentUserId = UserInfo.getUserId();
        System.assertEquals(controller.accResult[0].oppList[0].owner.Id, currentUserId);
        System.assertEquals(controller.accResult[0].owner.Id, currentUserId);
        //SF-1456 - check for LeadSource and OppSource
		System.assertEquals('Сайт Petrolplus.ru', controller.leadsResult.get(0).record.Source_of_Lead__c);
		System.assertEquals('E2E Form RU', controller.accResult[0].oppList[0].record.Source_of_Lead_o__c);
	}

    @isTest
    public static void searchTest2() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Lead lead = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead);
        insert lead;
        Account accountt = new Account(Name = 'pro567verkaAAAAAAA567', BillingPostalCode = '123', Phone = '+71098765432',
                INN__C = '1234567888888',
                RecordTypeiD = RecordTypeAcc);
        insert accountt;

        Opportunity opportunity = createOpportunity(accountt);
        insert opportunity;

        Test.startTest();
        Test.stopTest();
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = true;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.accResult.size(), 1);
        System.assertEquals(controller.accResult[0].oppList.size(), 1);
    }

    @isTest
    public static void searchTest3() {
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;

        Profile p = ([
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                OR Name = 'Системный администратор'
        ]);

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        Lead lead = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = user.id);
        insert lead;
        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;

        Test.startTest();
        Test.stopTest();

        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();

        controller.idForRequest = lead.id;
        controller.commentForRequest = 'Comment';
        controller.sendRequestForChangeOwner();
    }

    @IsTest
    public static void searchForE2EOpportunityTest() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else
                RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = Date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'E2E Form RU',
                RecordTypeId = RecordTypeLead, ownerid = RWL);
        insert lead;
        Account accountt = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Phone = '+71234567891',
                INN__C = '1234567899999',
                RecordTypeId = RecordTypeAcc);
        insert accountt;

        Contact contt = new Contact(LastName = 'testcontact12345', Phone = '+71234567890', Email = 'test@testcont.ru', AccountId = accountt.Id);
        insert contt;

        Opportunity opportunity = createOpportunity(accountt);
        insert opportunity;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesCtrl contr = new FindDuplicatesCtrl();
        contr.idForRequest = opportunity.Id;
        contr.sendRequestForChangeOwner();
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = true;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = true;
        controller.init();
        controller.searchPage();
        Boolean tmpBoolean = controller.isInboundUserRole;

        System.assertEquals(controller.accResult.size(), 1);
        System.assertEquals(controller.accResult[0].oppList.size(), 1);
    }

    @isTest
    public static void test_searchForE2EOpportunity_OnlyEmail() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Lead lead = new Lead(LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead);
        insert lead;
        Account accountt = new Account(Name = 'pro567verkaAAAAAAA567', BillingPostalCode = '123', Phone = '+71098765432',
                INN__C = '1234567888888',
                RecordTypeiD = RecordTypeAcc);
        insert accountt;

        Opportunity opportunity = createOpportunity(accountt);
        insert opportunity;

        Test.startTest();
        Test.stopTest();
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = false;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = false;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.accResult.size(), 1);
        System.assertEquals(controller.accResult[0].oppList.size(), 1);
    }

    @IsTest
    public static void searchFromSidebarTest() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else
                RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = Date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'E2E Form RU',
                RecordTypeId = RecordTypeLead, ownerid = RWL);
        insert lead;
        Account accountt = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Phone = '+71234567891',
                INN__C = '1234567899999',
                RecordTypeId = RecordTypeAcc);
        insert accountt;

        Contact contt = new Contact(LastName = 'testcontact12345', Phone = '+71234567890', Email = 'test@testcont.ru', AccountId = accountt.Id);
        insert contt;

        Opportunity opportunity = createOpportunity(accountt);
        insert opportunity;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesCtrl contr = new FindDuplicatesCtrl();
        contr.idForRequest = opportunity.Id;
        contr.sendRequestForChangeOwner();
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.searchString = '1234567899999';
        controller.isINNSelected = true;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.accResult.size(), 1);
    }

    @IsTest
    public static void otherTests() {
        FindDuplicatesCtrl.isInboundUserRole();
        FindDuplicatesCtrl ctrl = new FindDuplicatesCtrl();
        ctrl.backToRecord();
    }

    // 200+ lead records
    @isTest
    public static void searchBigAmountOfRecordsTest() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        Profile p = ([
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                OR Name = 'Системный администратор'
        ]);
        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        List<Lead> leadList = new List<Lead>();

        Test.startTest();

        for (Integer i = 0; i < 202; i++) {
            Lead lead = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = user.id);
            leadList.add(lead);
        }
        
        insert leadList;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;

        ApexPages.currentPage().getParameters().put('id', leadList.get(0).Id);
        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(40, controller.leadsResult.size());

        Test.stopTest();
    }

    @isTest
    public static void setPhoneValueTest() {
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeCon = [select id from recordtype where name = 'Russian' and SobjectType = 'Contact'].id;
        Profile profile = ([
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                OR Name = 'Системный администратор'
        ]);
        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = profile.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        // account part

        Account acc = new Account(
            Name = 'test12345678910987654321',
            BillingPostalCode = '123',
            Phone = '+71234567890', 
            RecordTypeId = RecordTypeAcc,
            INN__C = '1234567899999'
        );
        insert acc;
        String str = null;
        FindDuplicatesCtrl.AccountWrapper accWrapper = new FindDuplicatesCtrl.AccountWrapper(acc);
        accWrapper.setPhoneValue(str);

        System.assertEquals(false, accWrapper.phoneMatched);
        System.assertEquals(acc.Phone, accWrapper.phone);

        str = '99';
        accWrapper.setPhoneValue(str);

        System.assertEquals(false, accWrapper.phoneMatched);
        System.assertEquals(acc.Phone, accWrapper.phone);

        acc.Phone = null;
        update acc;
        accWrapper.setPhoneValue(str);

        System.assertEquals(false, accWrapper.phoneMatched);
        System.assertEquals('', accWrapper.phone);

        // Lead part

        Lead lead = new Lead(LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = user.id);
        insert lead;
        String phone = null;
        FindDuplicatesCtrl.LeadWrapper leadrapper = new FindDuplicatesCtrl.LeadWrapper('1234567888888', phone, 'mail123456@gmail.com', lead);
        
        System.assertEquals(false, leadrapper.phoneMatched);
        System.assertEquals('', leadrapper.phone);

        lead.Phone = '+71098765432';
        update lead;

        leadrapper.record = lead;
        leadrapper.setPhoneValue(phone);

        System.assertEquals(false, leadrapper.phoneMatched);
        System.assertEquals(lead.Phone, leadrapper.phone);

        phone = '99';
        leadrapper.setPhoneValue(phone);

        System.assertEquals(false, leadrapper.phoneMatched);
        System.assertEquals(lead.Phone, leadrapper.phone);

        // Contact part

        Contact cont = new Contact(LastName = 'testcontact12345', Email = 'test@testcont.ru', AccountId = acc.Id,
                RecordTypeId = RecordTypeCon, Owner = user);
        insert cont;

        phone = null;
        FindDuplicatesCtrl.ContactWrapper contWrapper = new FindDuplicatesCtrl.ContactWrapper(phone, 'test@testcont.ru', cont);
        
        System.assertEquals(false, contWrapper.phoneMatched);
        System.assertEquals('', contWrapper.phone);
        System.assertEquals(user.Id, contWrapper.owner.Id);

        cont.Phone = '+71234567890';
        contWrapper.setPhoneValue(phone, cont);

        System.assertEquals(false, contWrapper.phoneMatched);
        System.assertEquals(cont.Phone, contWrapper.phone);

        phone = '99';
        contWrapper.setPhoneValue(phone, cont);

        System.assertEquals(false, contWrapper.phoneMatched);
        System.assertEquals(cont.Phone, contWrapper.phone);
    }

    @isTest
    public static void getExtendedInfoTest() {
        createCustomSettings();
        String RecordTypeLead = LeadHandler.leadRecordTypes.get(
                GlobalUtils.LeadRecordTypes.Russian_Sales.name()
        ).recordTypeId;
        String RecordTypeAcc = ([
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian'
                AND SobjectType = :Account.class.getName()
        ].Id);
        String RecordTypeCon = ContactTriggerHandler.contactRecordTypes.get(
                GlobalUtils.ContactRecordTypes.Russian.name()
        ).recordTypeId;
        Profile p = ([
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                OR Name = 'Системный администратор'
        ]);
        User user = new User(
                Username = 'usertest@fleetcor.ru',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8',
                LastName = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        insert user;

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = Date.today(), Country = 'Russia', INN__c = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_Lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, OwnerId = user.Id);
        insert lead;

        Account accountt = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123',
                Phone = '+71234567891', INN__c = '1234567899999', RecordTypeId = RecordTypeAcc, ownerid = user.Id);
        insert accountt;

        Contact contt = new Contact(
                LastName = 'testcontact12345',
                Phone = '+71234567891',
                Email = 'Email12345678910@gggmail.ru',
                AccountId = accountt.Id,
                RecordTypeId = RecordTypeCon,
                OwnerId = user.Id);
        insert contt;

        Opportunity opportunity = createOpportunity(accountt);
        insert opportunity;

        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isINNSelected = true;
        controller.sInn = '1234567899999';
        controller.isEmailSelected = true;
        controller.sEmail = 'Email12345678910@gggmail.ru';
        controller.isPhoneSelected = false;
        controller.init();
        controller.searchPage();

        Test.startTest();
        controller.idToGetExtendedInfo = lead.Id;
        controller.getExtendedInfo();

        controller.idToGetExtendedInfo = accountt.Id;
        controller.getExtendedInfo();

        controller.idToGetExtendedInfo = contt.Id;
        controller.getExtendedInfo();

        controller.idToGetExtendedInfo = opportunity.Id;
        controller.getExtendedInfo();
        Test.stopTest();
    }

    @isTest
    public static void testSearchPage_PublicEmailDomain() {
		PublicEmailDomains__c publicEmailDomain = new PublicEmailDomains__c(Name = 'google.com');
		insert publicEmailDomain;

        FindDuplicatesCtrl controller = new FindDuplicatesCtrl();
        controller.isEmailSelected = true;
        controller.sEmail = PublicEmailDomains__c.getall().values().get(0).Name;
		controller.init();
        controller.searchPage();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean errorMessageExisted = false;
        for (Apexpages.Message msg : msgs) {
			if (msg.getDetail().contains(Label.FindDuplicates_no_public_domains)) {
				errorMessageExisted = true;
				break;
			}
        }
        System.assert(errorMessageExisted);
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
        PublicEmailDomains__c publicEmailDomains = new PublicEmailDomains__c(Name = 'gmail.com');
        insert publicEmailDomains;
    }

    public static Opportunity createOpportunity(Account account) {
        Opportunity opportunity = new Opportunity(
                Name = 'test12345678910987654321',
                CloseDate = Date.today()+1,
                CreatedDate = Date.today()-1,
                AccountId = account.Id,
                StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead),
                Projected_Liters_weekly__c = 1000,
                Primary_Fueling_Method__c = 'Cash',
                Insurance__c = 'Agree',
                Area_Traveled__c = 'Local',
                Number_of_cars__c = 10,
                Source_of_Lead_o__c = 'E2E Form RU',
                RecordTypeId = GlobalUtils.returnRecordTypeId('Opportunity', 'Russian Sales')
        );
        return opportunity;
    }
}
