@isTest
private class LeadTriggerTest {

    private static final Id RU_LEAD_RECORD_TYPE = LeadHandler.leadRecordTypes.get(GlobalUtils.LeadRecordTypes.Russian_Sales.name()).getRecordTypeId();
    private static final String DELIMITER = PhoneNumberUtils.PHONE_NUMBER_DELIMITER;

    public Static User u;

    static {
        insert CFUtilsTest.createCFSettingsForRussia(false);
    }

    //SF-1249
    @isTest
    public static void chatLeadsAssignTest() {
        List<User> currentUser = [SELECT Id, Email FROM User WHERE Name = 'Integration Administrator'];

        Lead newLead= new Lead(
                Lead_Source_Type__c = 'Chat',
                Chatter__c = 'Test Chatter',
                Operator__c = currentUser[0].Email,
                FirstName = 'FirstName',
                LastName = 'LastName',
                Company = 'Company',
                Number_of_Vehicles__c = 2,
                City = 'Test City',
                Country = 'Russia',
                Region__c = 'Test Region',
                Source_of_Lead__c = 'Test Source of Lead',
                Source_if_Self_Sourced__c = 'Test if Self Sourced'
        );

        Test.startTest();
        insert newLead;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        List<Lead> leadList = [SELECT Id, OwnerId FROM Lead WHERE Id = :newLead.Id];
//        System.assertEquals(currentUser[0].Id, leadList[0].OwnerId);
        System.assertEquals(1, invocations);
    }

    @IsTest
    private static void testUnifyPhoneNumbers() {
        Lead lead1 = new Lead(
                LastName = 'test 1',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+7 435 545 34 65#54',
                MobilePhone = '+7 999 54443 23',
                PPR_Contact_Phone__c = '+88005553535#23',
                Additional_Phones__c = '+434545445423.+79999992334#33'
        );
        Lead lead2 = new Lead(
                LastName = 'test 2',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+8 8005553535#33',
                MobilePhone = '',
                PPR_Contact_Phone__c = '+1111 222 33 44',
                Additional_Phones__c = ''
        );
        Lead lead3 = new Lead(
                LastName = 'test 3',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '',
                MobilePhone = '',
                PPR_Contact_Phone__c = '',
                Additional_Phones__c = '+125453435454#34'
        );
        Lead lead4 = new Lead(
                LastName = 'test 3',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                Sec_Channel__c = 'JITB',
                LeadSource = 'ABVP',
                Status = 'Open',
                RecordTypeId = LeadHandler.leadRecordTypes.get(GlobalUtils.LeadRecordTypes.Carnet.name()).getRecordTypeId(),
                Phone = '+8 800 555 35 35#23',
                Country = 'Russia'
        );
        List<Lead> leads = new List<Lead>{
                lead1, lead2, lead3, lead4
        };
        insert leads;
        update leads;

        lead1 = ([
                SELECT Id, Formatted_phones_additional__c, Formatted_phones__c
                FROM Lead
                WHERE Id = :lead1.Id
                LIMIT 1
        ]);
        System.assertEquals(
                '4355453465' + DELIMITER + '9995444323' + DELIMITER + '8005553535',
                lead1.Formatted_phones__c
        );
        System.assertEquals('4545445423' + DELIMITER + '9999992334', lead1.Formatted_phones_additional__c);
        lead2 = ([
                SELECT Id, Formatted_phones_additional__c, Formatted_phones__c
                FROM Lead
                WHERE Id = :lead2.Id
                LIMIT 1
        ]);
        System.assertEquals('8005553535' + DELIMITER + '1112223344', lead2.Formatted_phones__c);
        System.assert(String.isEmpty(lead2.Formatted_phones_additional__c));
        lead3 = ([
                SELECT Id, Formatted_phones_additional__c, Formatted_phones__c
                FROM Lead
                WHERE Id = :lead3.Id
                LIMIT 1
        ]);
        System.assertEquals('5453435454', lead3.Formatted_phones_additional__c);
        System.assert(String.isEmpty(lead3.Formatted_phones__c));
        lead4 = ([
                SELECT Id, Formatted_phones_additional__c, Formatted_phones__c
                FROM Lead
                WHERE Id = :lead4.Id
                LIMIT 1
        ]);
        System.assert(String.isEmpty(lead4.Formatted_phones__c));
        System.assert(String.isEmpty(lead4.Formatted_phones_additional__c));
    }

    /*******************************************************************************
    *  Name            : testNumberOfcardsFacebook()
    *  Summary         : test setting Record Type before insert
    *  CreatedDate     : 05.09.2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testNumberOfcardsFacebook() {
        Lead lead = new Lead(
                LastName = 'test',
                Company = 'test',
                CountryCode = 'DE',
                Number_of_Cards_facebook__c = '5+',
                LeadSource = 'Facebook');
        insert lead;

        Lead testLead = [SELECT Number_of_Cards_facebook__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        System.assertEquals(testLead.Number_of_Cards_facebook__c, '5');
    }

    /*******************************************************************************
    *  Name            : testSetRecordType()
    *  Summary         : test setting Record Type before insert
    *  CreatedDate     : 05.09.2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetRecordType() {
        Lead lead = new Lead(
                LastName = 'test',
                Company = 'test',
                CountryCode = 'RU',
                LeadSource = 'Facebook');
        insert lead;

        RecordType russianRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND sObjectType = 'Lead'
                LIMIT 1
        ];
        List<Lead> leadsList = [
                SELECT Id
                FROM Lead
                WHERE RecordTypeId = :russianRecordType.Id
        ];
        System.assertEquals(leadsList.size(), 1);
    }


    @isTest
    public static void testLeadOwner() {
        Lead newLead = new Lead(LastName = 'test', Company = 'test', Country = 'Germany');
        insert newLead;
        update newLead;

        List<Lead> testLeadList = [SELECT LastName FROM Lead WHERE Id = :newLead.Id LIMIT 1];
        system.assertEquals(testLeadList.size(), 1);
        system.assertEquals(testLeadList.get(0).LastName, newLead.LastName);
    }

    @isTest
    public static void testDisqualifiedLeadFields() {
        Lead newLead = new Lead(
                LastName = 'test',
                Company = 'test',
                Country = 'Germany',
                Status = 'Open',
                Quali_Status__c = 'Not interested',
                warum_kein_Interesse__c = 'Financial: card fees',
                Service_Sonstiges_specific__c = 'test',
                OLD_Quali_Status__c = '',
                OLD_Service_Other_specific__c = '',
                OLD_Why_not_interested__c = ''
        );

        insert newLead;
        newLead.Status = 'Disqualified';
        update newLead;

        List<Lead> testLeadList = [SELECT OLD_Quali_Status__c, OLD_Service_Other_specific__c, OLD_Why_not_interested__c FROM Lead WHERE Id = :newLead.Id LIMIT 1];
        System.assertEquals(testLeadList.get(0).OLD_Quali_Status__c.toUpperCase(), newLead.Quali_Status__c.toUpperCase());
        System.assertEquals(testLeadList.get(0).OLD_Service_Other_specific__c.toUpperCase(), newLead.Service_Sonstiges_specific__c.toUpperCase());
        System.assertEquals(testLeadList.get(0).OLD_Why_not_interested__c.toUpperCase(), newLead.warum_kein_Interesse__c.toUpperCase());
    }

    @isTest
    public static void testLeadConversion() {
        Account newAccount = new Account(
                Name = 'test',
                OBN__c = '12312312',
                BillingCountry = 'Germany');
        insert newAccount;

        Lead newLead = new Lead();
        newLead.Salutation = 'Herr';
        newLead.LastName = 'Test LastName';
        newLead.LeadSource = 'Partner';
        newLead.Company = 'test';
        newLead.Country = 'Germany';
        newLead.CountryCode = 'DE';
        newLead.Anzahl_der_Fahrzeuge__c = 5;
        newLead.Phone = '123123123';
        newLead.Partner__c = newAccount.Id;
        newLead.Partner_OBN__c = '123123';
        newLead.Branche_NACE__c = 'Apotheken - 4773';
        newLead.Beschaeftigte__c = '1-4';
        newLead.Sec_Channel__c = 'Inbound';
        insert newLead;

        Database.LeadConvert lc = new database.LeadConvert();

        lc.setLeadId(newLead.Id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        // Make sure conversion was successful
        System.assert(lcr.isSuccess());

        Lead testLead = [SELECT ConvertedOpportunityId FROM Lead WHERE Id = :newLead.Id LIMIT 1];

        system.assertNotEquals(testLead.ConvertedOpportunityId, null);

        List<Partner> testPartnerList = [SELECT Id FROM Partner WHERE OpportunityId = :testLead.ConvertedOpportunityId];
        system.assertEquals(testPartnerList.size(), 1);
    }

    @isTest
    public static void testMergeChatLeads() {
        Lead newLead = new Lead(
                LastName = 'test', Company = 'test', Country = 'Germany', CountryCode = 'DE',
                LeadSource = 'Online_chat', Email = 'test@test.com',
                Phone = '1231231231', Status = 'Open');
        insert newLead;

        system.assert(newLead.Id != null);

        Lead newLead2 = new Lead(
                LastName = 'test', Company = 'test', Country = 'Germany', CountryCode = 'DE',
                LeadSource = 'Online_chat', Email = 'test@test.com',
                Phone = '1231231231', Status = 'Open');
        insert newLead2;

        List<Lead> testMergeList = [
                SELECT Id
                FROM Lead
                WHERE Id = :newLead2.Id
        ];
        system.assertEquals(0, testMergeList.size());
    }

    @isTest
    public static void testMakeACall() {
        Lead newLead = new Lead(
                LastName = 'test', Company = 'test', CountryCode = 'CZ',
                Email = 'noreply.websiteexperts@account-join.biz', Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet', Branche_NACE__c = 'test',
                Phone = '1231231231', Status = 'Open');
        insert newLead;

        system.assert(newLead.Id != null);

        Task newTask = new Task(
                Status = 'In Bearbeitung',
                Type = 'Anruf',
                ActivityDate = Date.today(),
                Subject = 'test',
                WhoId = newLead.Id);
        insert newTask;

        newLead.Status = 'Contacted';
        newLead.OwnerId = UserInfo.getUserId();
        update newLead;

        List<Lead> testList = [
                SELECT First_Call__c, OwnerId
                FROM Lead
                WHERE Id = :newLead.Id
        ];
        system.assertEquals(1, testList.size());
        system.assert(testList.get(0).First_Call__c != null);
    }

    @isTest
    public static void testCCSConvert() {
        Lead tst = new Lead();
        tst.Salutation = 'Herr';
        tst.Anzahl_der_Fahrzeuge__c = 1;
        tst.FirstName = 'dads';
        tst.Company = 'da';
        tst.LastName = 'dafsdfg';
        tst.Branche_NACE__c = 'Beherbergung - 5500';
        tst.Beschaeftigte__c = '1-4';
        tst.CCS_Company_ID__c = '56987452';
        tst.Street = 'ddasfs';
        tst.cislo_popisne__c = '59';
        tst.City = 'dcasdo';
        tst.PostalCode = '96584';
        tst.Phone = '548785456';
        tst.Email = 'dasfsf@adfsd.cz';
        tst.Country = 'Germany';
        tst.CountryCode = 'DE';
        Test.startTest();
        insert tst;

        string leadId = [SELECT Id FROM Lead WHERE CCS_Company_ID__c = '56987452'][0].Id;

        CCS_Bonus__c bonus = new CCS_Bonus__c();
        bonus.Lead__c = leadId;
        bonus.Name = 'dagbf';
        insert bonus;

        CCS_Limit__c ccslimit = new CCS_Limit__c();
        ccslimit.Lead__c = leadId;
        ccslimit.Name = 'dagdfg';
        insert ccslimit;

        CCS_Carnet__c carnet = new CCS_Carnet__c();
        carnet.Lead__c = leadId;
        carnet.Name = 'dadasfasfsaf';
        insert carnet;

        CCS_Order__c order = new CCS_Order__c();
        order.Lead__c = leadId;
        order.Name = 'test';
        insert order;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(tst.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
    }

    @isTest
    public static void testCCSTelesalesLeadOwnerTestClass() {
        Test.startTest();
        createUser();
        Test.stopTest();

        system.runAs(u) {
            RecordType ccsRecordType = [
                    SELECT Id
                    FROM RecordType
                    WHERE Name = 'CCS Sales process' AND sObjectType = 'Lead'
                    LIMIT 1
            ];

            Lead tst = new Lead();
            tst.FirstName = 'dads';
            tst.Company = 'da';
            tst.LastName = 'dafsdfg';
            tst.CCS_Company_ID__c = '56987452';
            tst.Street = 'ddasfs';
            tst.Cislo_popisne__c = '59';
            tst.City = 'dcasdo';
            tst.Branche_NACE__c = 'Beherbergung - 5500';
            tst.Beschaeftigte__c = '1-4';
            tst.PostalCode = '96584';
            tst.Phone = '548785456';
            tst.Email = 'dasfsf@adfsd.cz';
            tst.Country = 'Germany';
            tst.CountryCode = 'DE';
            tst.RecordTypeId = ccsRecordType.Id;
            insert tst;
            Lead ld = new Lead(Id = [SELECT Id FROM Lead WHERE CCS_Company_ID__c = '56987452'][0].Id);
            ld.CCS_Telesales_Operator__c = null;
            update ld;
            String telesalesId = [SELECT CCS_Telesales_Operator__c FROM Lead WHERE CCS_Company_ID__c = '56987452'][0].CCS_Telesales_Operator__c;
            System.assertEquals(UserInfo.getUserId(), telesalesId);
        }
    }

    @future
    private static void createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS CZ Telesales'];
        Integer rand = Math.round(Math.random() * 100000);
        u = new User(
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = rand + '@' + rand + 'test.com',
                Alias = 'batman',
                Email = 'bruce.wayne_' + rand + '@wayneenterprises.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(u);
    }


    /*******************************************************************************
      *  Name            : testLastDateChangeOwnerRUS()
      *  Summary         : check for change of field Last_Owner_Change_Date_RUS__c when changing owner
      *  CreatedDate     : 20/11/2017
      *  Parameters      : -
      *  Returns         : void
      ******************************************************************************/
    @isTest
    private static void testLastDateChangeOwnerRUS() {
        Account newAccount = new Account(
                Name = 'test1',
                OBN__c = '12312312',
                BillingCountry = 'Russia');
        insert newAccount;

        Id recordType;

        if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи') != null) {
            recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
        } else if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales') != null) {
            recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        }

        Lead newLead = new Lead();
        newLead.Salutation = 'Herr1';
        newLead.LastName = 'Test LastName';
        newLead.LeadSource = 'Partner';
        newLead.Company = 'test1';
        newLead.Country = 'Russia';
        newLead.Anzahl_der_Fahrzeuge__c = 5;
        newLead.Phone = '+71231231231';
        newLead.Partner__c = newAccount.Id;
        newLead.Partner_OBN__c = '123123';
        newLead.Branche_NACE__c = 'Apotheken - 4773';
        newLead.Beschaeftigte__c = '1-4';
        newLead.Sec_Channel__c = 'Inbound';
        newLead.Region__c = 'Кировская область';
        newLead.RecordTypeId = recordType;
        newLead.INN__c = '234234123423';
        insert newLead;

        Database.LeadConvert lc = new database.LeadConvert();

        lc.setLeadId(newLead.Id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel LIKE 'QUALIFIED%' LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Lead testLead = [SELECT ConvertedOpportunityId, Last_Owner_Change_Date_RUS__c FROM Lead WHERE Id = :newLead.Id LIMIT 1];

        Opportunity testopportunity = [SELECT Id, Last_Owner_Change_Date_RUS__c FROM Opportunity WHERE Id = :testLead.ConvertedOpportunityId LIMIT 1];

        System.assertEquals(testOpportunity.Last_Owner_Change_Date_RUS__c, testLead.Last_Owner_Change_Date_RUS__c);
    }


    @isTest
    private static void testAllStarShortFormLeadDuplicates() {
        Account newAccount = new Account(
                Name = 'test',
                NIP__c = '1234567891',
                BillingCountry = 'Germany');
        insert newAccount;

        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('AllStar').getRecordTypeId();
        Lead masterLead = new Lead(
                LeadSource = 'Inbound Email',
                RecordTypeId = recTypeId,
                Lastname = 'test_MasterLead',
                Status = 'Open',
                NIP__c = '1234567891',
                Company = 'Company',
                Country = 'Germany',
                IsConverted = false,
                Email = 'masteremail@gmail.com');
        insert masterLead;

        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AllStar').getRecordTypeId();
        Opportunity newOpp = new Opportunity(
                RecordTypeId = recordTypeId,
                AccountId = newAccount.Id,
                Anzahl_der_Karten__c = 5,
                Zahlungsart__c = 'Lastschrift',
                Zahlungsziel__c = '7',
                Product__c = 'None',
                StageName = 'Prospecting',
                Name = 'test opp',
                Angebotsdauer__c = '3 Monate',
                CloseDate = Date.today());
        insert newOpp;

        Lead duplicateLead = new Lead(
                LeadSource = 'Allstar Mondo Web Short Form',
                RecordTypeId = recTypeId,
                Lastname = 'test_duplcate',
                NIP__c = '1234567891',
                Company = 'Company name',
                Country = 'Germany',
                Status = 'Open',
                IsConverted = false,
                Email = 'duplicate@gmail.com');
        insert duplicateLead;
    }


    /******************************************************************************
    *  Name            : testValidateMobilePhone()
    *  Summary         : test checking phone prefix
    *  CreatedDate     : 27/11/2017
    *  ModifiedDate    : 27/11/2017
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    static void testValidateMobilePhone() {
        Mobile_Phone_Prefixes__c testPrefix = new Mobile_Phone_Prefixes__c(
                Name = 'PL_50');
        insert testPrefix;

        Lead testLead = new Lead(
                LastName = 'test',
                Company = 'test',
                CountryCode = 'PL',
                Phone = '50123123123');
        insert testLead;

        List<Lead> testLeadsList = [
                SELECT Is_Mobile_Phone_Valid__c
                FROM Lead
                WHERE Id = :testLead.Id
        ];
        System.assertEquals(true, testLeadsList.get(0).Is_Mobile_Phone_Valid__c);

        Lead testLead2 = new Lead(
                LastName = 'test2',
                Company = 'test',
                CountryCode = 'PL');
        insert testLead2;

        testLeadsList = [
                SELECT Is_Mobile_Phone_Valid__c
                FROM Lead
                WHERE Id = :testLead2.Id
        ];
        System.assertEquals(false, testLeadsList.get(0).Is_Mobile_Phone_Valid__c);

        testLead2.Phone = '50321321321';
        update testLead2;

        testLeadsList = [
                SELECT Is_Mobile_Phone_Valid__c
                FROM Lead
                WHERE Id = :testLead2.Id
        ];
        System.assertEquals(true, testLeadsList.get(0).Is_Mobile_Phone_Valid__c);
    }


    /*******************************************************************************
    *  Name            : testDisqualifySpecificLeads()
    *  Summary         : test of disqualification leads with specific email addresses
    *  CreatedDate     : 30/11/2017
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testDisqualifySpecificLeads() {
        DisqualifiedEmailAddressesOfLead__c customSettings = new DisqualifiedEmailAddressesOfLead__c(
                Name = 'test setting',
                Email__c = 'test@test.com');
        insert customSettings;

        Lead testLead = new Lead(
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                CountryCode = 'DE',
                Phone = '7777777',
                Email = 'test@test.com');
        insert testLead;

        Lead disqualifiedLead = [SELECT Status FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals('Disqualified', disqualifiedLead.Status);
    }


    /*******************************************************************************
    *  Name            : testSetPrimaryContactPhoneField()
    *  Summary         : test of set Primary_Contact_Phone__c field in Opportunity during conversion lead
    *  CreatedDate     : 19/12/2017
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testSetPrimaryContactPhoneField() {
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        Lead testLead = new Lead(
                Salutation = 'Herr',
                RecordTypeId = recTypeId,
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '1234567891',
                Anzahl_der_Fahrzeuge__c = 2,
                CountryCode = 'DE',
                Region__c = 'Кировская область',
                Phone = '+77777777777',
                Email = 'test@test.com');
        insert testLead;

        Test.startTest();
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);
        LeadStatus convertStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel = 'QUALIFIED - Convert to Opportunity' LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        List<Lead> leadList = [
                SELECT ConvertedOpportunity.Primary_Contact_Phone__c, Phone
                FROM Lead
                WHERE Id = :testLead.Id
                LIMIT 1
        ];
        System.assertEquals(leadList.get(0).Phone, leadList.get(0).ConvertedOpportunity.Primary_Contact_Phone__c);
        Test.stopTest();
    }


    /*******************************************************************************
    *  Name            : testActiveLeadRelocationBatchChecker()
    *  Summary         : test checking active Lead Relocation Batch if changing lead status from "Open"
    *  CreatedDate     : 03/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testActiveLeadRelocationBatchChecker() {
        Lead testLead = new Lead(
                Salutation = 'Herr',
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '12345',
                Anzahl_der_Fahrzeuge__c = 2,
                CountryCode = 'DE',
                Phone = '7777777',
                Email = 'test@test.com');
        insert testLead;

        Task newTask = new Task(
                Status = 'In Bearbeitung',
                Type = 'Anruf',
                ActivityDate = Date.today(),
                Subject = 'test',
                WhoId = testLead.Id);
        insert newTask;

        Test.startTest();
        String myCustomError = Label.Lead_Reassign_Active_Job_Error;
        try {
            Database.executeBatch(new LeadRelocationBatch(), 1);
            testLead.Status = 'Contacted';
            update testLead;
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(myCustomError);
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }


    /*******************************************************************************
    *  Name            : testupdateCurrencyIsoCode()
    *  Summary         : test checking CurrencyIsoCode before insert and before update
    *  CreatedDate     : 02-03-2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testupdateCurrencyIsoCode() {
        Lead testLead = new Lead(
                Salutation = 'Herr',
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '12345',
                Anzahl_der_Fahrzeuge__c = 2,
                Phone = '7777777',
                Email = 'test@test.com',
                CountryCode = 'CZ'
        );
        insert testLead;

        List<Lead> leadInsertList = [SELECT Id, CurrencyIsoCode FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('CZK', leadInsertList.get(0).CurrencyIsoCode);

        testLead.CountryCode = 'PL';
        update testLead;

        List<Lead> leadUpdateList = [SELECT Id, CurrencyIsoCode FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('PLN', leadUpdateList.get(0).CurrencyIsoCode);
    }

    /*******************************************************************************
    *  Name            : testupdateLeadShellAZSone()
    *  Summary         : test shell station
    *  CreatedDate     : 05/03/2018
    *  ModifiedDate    : 05/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testupdateLeadShellAZSone() {
        ShellTerminalAZS__c shellTerminal = new ShellTerminalAZS__c(Name = '11002', TerminalList__c = '2005/1805');
        insert shellTerminal;

        RecordType russianRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND sObjectType = 'Lead'
                LIMIT 1
        ];

        Lead newLead = new Lead(
                LastName = 'test', Company = 'test', CountryCode = 'CZ',
                Email = 'test@test.com', Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet', Branche_NACE__c = 'test',
                PPR_AZS_Retailer__c = shellTerminal.name,
                RecordTypeId = russianRecordType.Id,
                Phone = '+4201231231231',
                RecordType = russianRecordType,
                Status = 'Open');
        insert newLead;

        List<Lead> testList = [
                SELECT id, AZS_with_Discount_1_address__c,PPR_AZS_Retailer__c
                FROM Lead
                WHERE Id = :newLead.Id
        ];

        system.debug(testList.get(0).AZS_with_Discount_1_address__c + ' ' + testList.get(0).PPR_AZS_Retailer__c);
        system.assert(testList.get(0).AZS_with_Discount_1_address__c != null);
    }

    /*******************************************************************************
    *  Name            : testupdateLeadShellAZSTwo()
    *  Summary         : test shell station
    *  CreatedDate     : 05/03/2017
    *  ModifiedDate    : 05/03/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testupdateLeadShellAZSTwo() {
        ShellTerminalAZS__c shellTerminal = new ShellTerminalAZS__c(Name = '11002', TerminalList__c = '2005/1805');
        insert shellTerminal;

        RecordType russianRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND sObjectType = 'Lead'
                LIMIT 1
        ];

        Lead newLead = new Lead(
                LastName = 'test', Company = 'test', CountryCode = 'CZ',
                Email = 'test@test.com', Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet', Branche_NACE__c = 'test',
                RecordTypeId = russianRecordType.Id,
                Phone = '+4201231231231',
                RecordType = russianRecordType,
                Status = 'Open');
        insert newLead;

        newLead.AZS_with_Discount_2_address__c = shellTerminal.name;
        update newLead;

        List<Lead> testList = [
                SELECT id, AZS_with_Discount_2__c
                FROM Lead
                WHERE Id = :newLead.Id
        ];

        List<ShellTerminalAZS__c> newShellTerminalAZS = [
                SELECT name, TerminalList__c
                FROM ShellTerminalAZS__c
                WHERE name = :shellTerminal.name
        ];

        system.assertEquals(testList.get(0).AZS_with_Discount_2__c, newShellTerminalAZS.get(0).TerminalList__c);
    }

    /*******************************************************************************
    *  Name            : testIfTasksAreClosedAfterLeadIsClosed()
    *  Summary         : The test checks if Tasks's Status is changed to 'Completed' after Lead changed its status to 'Disqualified'
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testIfTasksAreClosedAfterLeadIsClosed() {
        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        String taskRecId = GlobalUtils.returnRecordTypeId('Task', 'Layout Tasks');

        Lead testLead = new Lead(
                Salutation = 'Herr',
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '12345',
                Anzahl_der_Fahrzeuge__c = 2,
                CountryCode = 'DE',
                Phone = '7777777',
                Email = 'test@test.com',
                RecordTypeId = endkundeRecId);
        insert testLead;

        Task testTask = new Task(
                Status = 'In Bearbeitung',
                Type = 'Anruf',
                ActivityDate = Date.today(),
                Subject = 'test',
                WhoId = testLead.Id,
                RecordTypeId = taskRecId);
        insert testTask;

        Test.startTest();
        testLead.Status = 'Disqualified';
        LeadHandler.isLeadClosed = true;
        update testLead;
        Test.stopTest();

        List<Task> testTasks = [SELECT Id FROM Task WHERE WhoId = :testLead.Id AND Status = 'Completed'];
        System.assertEquals(1, testTasks.size());
    }

    /*******************************************************************************
    *  Name            : testUpdateOpenTaskCheckbox()
    *  Summary         : test updateOpenTaskCheckbox method
    *  CreatedDate     : 07/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testUpdateOpenTaskCheckbox() {
        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        String taskRecId = GlobalUtils.returnRecordTypeId('Task', 'Layout Tasks');

        Lead testLead = new Lead(
                Salutation = 'Herr',
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '12345',
                Anzahl_der_Fahrzeuge__c = 2,
                CountryCode = 'DE',
                Phone = '7777777',
                Email = 'test@test.com',
                RecordTypeId = endkundeRecId);
        insert testLead;

        User user = [SELECT Id FROM User WHERE Id != :testLead.OwnerId LIMIT 1];

        Task testTask = new Task(
                Status = 'In Progress',
                Type = 'Anruf',
                ActivityDate = Date.today(),
                Subject = 'test',
                WhoId = testLead.Id,
                OwnerId = user.Id,
                RecordTypeId = taskRecId);
        insert testTask;

        testLead.OwnerId = user.Id;

        update testLead;

        Lead resLead = [SELECT Id, Open_Task__c FROM Lead WHERE Id = :testLead.Id];

        System.assertEquals(true, resLead.Open_Task__c);
    }


    /*******************************************************************************
    *  Name            : testJITBChannelLeadConvertionOnCreate()
    *  Summary         : test JITBChannelLead Convertion lead creation
    *  CreatedDate     : 29/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // @isTest
    static void testJITBChannelLeadConvertionOnCreate() {
        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';

        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Germany';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/e2eform?country=Germany';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/e2ejitbde';
        insert settingsE2EShortUrl;

        Test.startTest();
        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');

        insert new E2EKeysAPI__c(
                Name = 'E2EForm',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );

        Account newAccount = new Account(
                Name = 'test',
                OBN__c = '12312312',
                BillingCountry = 'Germany',
                BillingStreet = 'test street',
                BillingCity = 'test city'
        );
        insert newAccount;

        Lead testLead = new Lead(
                Salutation = 'Herr',
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Anzahl_der_Fahrzeuge__c = 2,
                CountryCode = 'DE',
                Country = 'Germany',
                Street = 'test street',
                City = 'test city',
                Phone = '7777777',
                Email = 'test@test.com',
                RecordTypeId = endkundeRecId,
                Steuernummer__c = '0',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Internet',
                LeadSource = 'Partner',
                Partner__c = newAccount.Id,
                Partner_OBN__c = '123123'
        );
        insert testLead;
        Test.stopTest();

        Lead convertedLead = [
                SELECT IsConverted, ConvertedOpportunityId, ConvertedAccountId, LeadSource, Phone
                FROM Lead
                WHERE Id = :testLead.Id
        ];

        System.assertEquals(true, convertedLead.IsConverted);

        Account convertedAccount = [
                SELECT ShippingCountry, BillingCountry, ShippingStreet, BillingStreet, ShippingCity, BillingCity,
                        ShippingState, BillingState, ShippingPostalCode, BillingPostalCode, AccountSource, Type
                FROM Account
                WHERE Id = :convertedLead.ConvertedAccountId
        ];

        System.assertEquals(convertedAccount.BillingCountry, convertedAccount.ShippingCountry);
        System.assertEquals(convertedAccount.BillingStreet, convertedAccount.ShippingStreet);
        System.assertEquals(convertedAccount.BillingCity, convertedAccount.ShippingCity);
        System.assertEquals(convertedAccount.BillingState, convertedAccount.ShippingState);
        System.assertEquals(convertedAccount.BillingPostalCode, convertedAccount.ShippingPostalCode);
        System.assertEquals(convertedLead.LeadSource, convertedAccount.AccountSource);
        System.assertEquals('Customer', convertedAccount.Type);

        Opportunity convertedOpportunity = [
                SELECT Primary_Contact_Phone__c, E2E_Active_Step__c, E2E_Active_Substep__c, Language_preference__c,
                        LeadSource, AGB_Datenschutzhinweise_Richtigkeit__c, E2E_Form_of_Business__c, Eco_Fee__c,
                        E2E_Encoded_URL__c, SEPA_Mandate_URL__c, E2E__c
                FROM Opportunity
                WHERE Id = :convertedLead.ConvertedOpportunityId
        ];

        System.assertEquals(convertedLead.Phone, convertedOpportunity.Primary_Contact_Phone__c);
        System.assertEquals(0, convertedOpportunity.E2E_Active_Step__c);
        System.assertEquals('Contact details', convertedOpportunity.E2E_Active_Substep__c);
        System.assertEquals('German', convertedOpportunity.Language_preference__c);
        System.assertEquals(true, convertedOpportunity.E2E__c);
        System.assertEquals(false, convertedOpportunity.AGB_Datenschutzhinweise_Richtigkeit__c);
        System.assertEquals('Company', convertedOpportunity.E2E_Form_of_Business__c);
        System.assertEquals(false, convertedOpportunity.Eco_Fee__c);
        System.assertNotEquals(null, convertedOpportunity.E2E_Encoded_URL__c);
        System.assertNotEquals(null, convertedOpportunity.SEPA_Mandate_URL__c);

        List<Tankkarten__c> cardsList = [SELECT Id FROM Tankkarten__c];
        System.assertEquals(2, cardsList.size());
    }


    @isTest
    public static void testShellEmailBEFR() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Belgium-FR',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Belgium-FR', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
                Name = 'Belgium-FR',
                E2E_Form_Url__c = 'https://online.fleetcorcards.be/etebefr',
                E2E_JITB_Form_Url__c = 'https://online.fleetcor.nl/etejitblocator',
                Private_Key__c = 'P83U8MmjgIBU0V4l',
                Short_Url__c = 'https://online.fleetcorcards.be/i'
        );
        insert shortUrlSettings;

        Lead lead = new Lead(
                LastName = 'test',
                Company = 'test',
                LeadSource = 'Shell Email',
                Contact_Email_Body__c = LeadTriggerTestShellEmails.SHELL_EMAIL_BEFR,
                Country = 'Belgium-FR', CountryCode = 'BEFR');
        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead testLead = [
                SELECT LastName, Company, CCS_number_of_cards__c,
                        LeadSource, Phone, Email, Status, Quali_Status__c
                FROM Lead
                WHERE Id = :lead.Id];

        System.assert(testLead.LastName == 'test user');
        System.assert(testLead.Company == 'test company');
        System.assert(testLead.Email == 'testemail123@gmail.com');
        System.assert(testLead.Phone == '+3247123333333');
        System.assert(testLead.CCS_number_of_cards__c == 1);
        System.assert(testLead.Quali_Status__c == 'Switched to E2E');
    }


    @isTest
    public static void testShellEmailBENL() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Belgium-NL',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        List<User> e2eUser = [SELECT Id, ProfileId FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Belgium-NL', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
                Name = 'Belgium-NL',
                E2E_Form_Url__c = 'https://online.fleetcorcards.be/etebenl',
                E2E_JITB_Form_Url__c = 'https://online.fleetcor.nl/etejitblocator',
                Private_Key__c = 'P83U8MmjgIBU0V4l',
                Short_Url__c = 'https://online.fleetcorcards.be/i'
        );
        insert shortUrlSettings;

        Lead lead = new Lead(
                LastName = 'test',
                Company = 'test',
                LeadSource = 'Shell Email',
                Contact_Email_Body__c = LeadTriggerTestShellEmails.SHELL_EMAIL_BENL,
                Country = 'Belgium-NL', CountryCode = 'BENL');
        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead testLead = [
                SELECT LastName, Company, CCS_number_of_cards__c,
                        LeadSource, Phone, Email, Status, Quali_Status__c
                FROM Lead
                WHERE Id = :lead.Id];

        System.assert(testLead.LastName == 'test userbenl');
        System.assert(testLead.Company == 'test companybenl');
        System.assert(testLead.Email == 'testbenl@test.com');
        System.assert(testLead.Phone == '+32481123332');
        System.assert(testLead.CCS_number_of_cards__c == 2);
        System.assert(testLead.Quali_Status__c == 'Switched to E2E');
    }


    @isTest
    public static void testShellEmailNL() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Netherlands',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        List<User> e2eUser = [SELECT Id, ProfileId FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Netherlands', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
                Name = 'Netherlands',
                E2E_Form_Url__c = 'https://online.fleetcor.nl/etenl',
                E2E_JITB_Form_Url__c = 'https://online.fleetcor.nl/etejitblocator',
                Private_Key__c = 'P83U8MmjgIBU0V4l',
                Short_Url__c = 'https://online.fleetcor.nl/i'
        );
        insert shortUrlSettings;

        Lead lead = new Lead(
                LastName = 'test',
                Company = 'test',
                LeadSource = 'Shell Email',
                Contact_Email_Body__c = LeadTriggerTestShellEmails.SHELL_EMAIL_NL,
                Country = 'Netherlands', CountryCode = 'NL');
        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead testLead = [
                SELECT LastName, Company, CCS_number_of_cards__c,
                        LeadSource, Phone, Email, Status, Quali_Status__c
                FROM Lead
                WHERE Id = :lead.Id];

        System.assert(testLead.LastName == 'test usernl');
        System.assert(testLead.Company == 'test companynl');
        System.assert(testLead.Email == 'testnl@test.com');
        System.assert(testLead.Phone == '+316512312333');
        System.assert(testLead.CCS_number_of_cards__c == 1);
        System.assert(testLead.Quali_Status__c == 'Switched to E2E');
    }


    public static E2E_Form_General_Settings__c generateE2EGeneralSettings(String country, String userId, String intAdminId) {
        E2E_Form_General_Settings__c e2eGeneralSettings = new E2E_Form_General_Settings__c(
                Name = country,
                Abandonment_User__c = userId,
                E2E_Guest_User_Id__c = userId,
                Integration_Admin_Id__c = intAdminId,
                Enable_authorization_non_granted_check__c = false,
                Files_Generator_Url__c = 'http://e2e-e2efleetcor.cs108.force.com',
                Payment_URL__c = 'https://e2e-e2efleetcor.cs108.force.com',
                Set_GFN_Status__c = false,
                Test_Mode__c = false
        );
        return e2eGeneralSettings;
    }

    @isTest
    static void testLeadLilnkLead(){

        List <User> salesUser = [ Select Id From User Where Manager.Email != '' Limit 2];
        Lead leadTest1 = new Lead(
                LastName = 'Lead Test',
                Company = 'Lead Test Company',
                Phone = '+78888888888',
                Country = 'Russia',
                OwnerId = salesUser.get(0).Id
        );
        insert leadTest1;
        Test.startTest();
        Lead LeadTest2 = new Lead(
                LastName = 'Lead Test2',
                Company = 'Lead Test2 Company',
                Phone = '+78888888888',
                Country = 'Russia',
                Status = 'Disqualified',
                Lead_Status_Specific__c = 'Возврат в воронку',
                CCS_First_Contact_Inbound_Outbound__c = 'Не контактировали',
                Lead_and_Opp_For_Dedublication__c = leadTest1.Id,
                Date_of_First_Contact_Inbound_Outbound__c = Date.today(),
                Source_of_Lead__c = 'Прочая БД',
                OwnerId = salesUser.get(1).Id
        );
        insert leadTest2;
        LeadTest2.Phone = '+78888888467';
        update leadTest2;
        System.assertEquals(leadTest1.Id, LeadTest2.Lead_and_Opp_For_Dedublication__c);
        Test.stopTest();
    }

    @isTest
    static void testOppoLinkLead() {

        List <User> salesUser = [ Select Id From User Where Manager.Email != null AND UserRole.Name != null Limit 2];
        Opportunity oppoTest1 = new Opportunity(
                Name = 'Oppo Test',
                StageName = 'Qualified Lead',
                CloseDate = Date.today().addDays(7),
                Starts_Status__c = '0.9 Ready for GFN',
                OwnerId = salesUser.get(0).Id
        );
        insert oppoTest1;
        Test.startTest();
        Lead LeadTest3 = new Lead(
                LastName = 'Lead Test',
                Company = 'Lead Test Company',
                Phone = '+78888888888',
                Country = 'Russia',
                Status = 'Disqualified',
                Lead_Status_Specific__c = 'Возврат в воронку',
                CCS_First_Contact_Inbound_Outbound__c = 'Не контактировали',
                Date_of_First_Contact_Inbound_Outbound__c = Date.today(),
                Lead_and_Opp_For_Dedublication__c = oppoTest1.Id,
                Source_of_Lead__c = 'Прочая БД',
                OwnerId = salesUser.get(1).Id
        );
        insert leadTest3;
        leadTest3.Phone = '+78888888877';
        update leadTest3;
        System.assertEquals(oppoTest1.Id, LeadTest3.Lead_and_Opp_For_Dedublication__c);
        Test.stopTest();
    }

    @isTest
    static void testsetPenaltyRating_fs(){
        FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365,
                Penalty_for_refusal_Telesales__c = 60
        );
        insert fieldSalesSettings;

        Id recordType;
        if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи') != null) {
            recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
        } else if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales') != null) {
            recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        }

        List<PermissionSetAssignment> permissionSetAssignments = [
                SELECT Id, AssigneeId
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'FieldSalesTerritory_Field_Manager' AND Assignee.IsActive = true LIMIT 1
        ];

        User fieldManager = [SELECT Id FROM  User WHERE Id = :permissionSetAssignments.get(0).AssigneeId];

        Lead newLead = new Lead();
        newLead.Salutation = 'Herr1';
        newLead.LastName = 'Test LastName';
        newLead.LeadSource = 'Partner';
        newLead.Company = 'test1';
        newLead.Country = 'Russia';
        newLead.Anzahl_der_Fahrzeuge__c = 5;
        newLead.Phone = '+71231111111';
        newLead.Partner_OBN__c = '123123';
        newLead.Branche_NACE__c = 'Apotheken - 4773';
        newLead.Beschaeftigte__c = '1-4';
        newLead.Sec_Channel__c = 'Inbound';
        newLead.Region__c = 'Кировская область';
        newLead.RecordTypeId = recordType;
        newLead.INN__c = '234234123423';
        newLead.OwnerId = fieldManager.Id;
        newLead.Street = 'САНКТ-ПЕТЕРБУРГ';
        newLead.Rating_FS__c = 20;

        insert newLead;

        system.runAs(fieldManager){
            newLead.Status = 'Disqualified';
            update newLead;
        }

        Map<Id, Lead> leadsMap = new Map <Id, Lead> (
        [SELECT Id, SummaryScoringRu__c
        FROM Lead
        WHERE Id = :newLead.Id
        ]);
        system.debug('leadsMap: '+ leadsMap);
        system.assertEquals(leadsMap.get(newLead.Id).SummaryScoringRu__c, -18230);
    }

    @isTest
    static void testsetPenaltyRating_buddy(){
        FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365,
                Penalty_for_refusal_Telesales__c = 60
        );
        insert fieldSalesSettings;

        Id recordType;
        if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи') != null) {
            recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
        } else if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales') != null) {
            recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        }

        User buddy = [SELECT Id FROM  User
        WHERE Id IN (SELECT AssigneeId
        FROM PermissionSetAssignment
        WHERE PermissionSet.Name = 'FieldSalesTerritory_buddy')
        LIMIT 1];

        Lead newLead = new Lead();
        newLead.Salutation = 'Herr1';
        newLead.LastName = 'Test LastName2';
        newLead.LeadSource = 'Partner';
        newLead.Company = 'test2';
        newLead.Country = 'Russia';
        newLead.Anzahl_der_Fahrzeuge__c = 5;
        newLead.Phone = '+72231111111';
        newLead.Partner_OBN__c = '223223';
        newLead.Branche_NACE__c = 'Apotheken - 4773';
        newLead.Beschaeftigte__c = '1-4';
        newLead.Sec_Channel__c = 'Inbound';
        newLead.Region__c = 'Кировская область';
        newLead.RecordTypeId = recordType;
        newLead.INN__c = '234234123422';
        newLead.OwnerId = buddy.Id;
        newLead.Street = 'САНКТ-ПЕТЕРБУРГ';
        newLead.Rating_FS__c = 20;

        insert newLead;

        system.runAs(buddy){
            newLead.Status = 'Disqualified';
            update newLead;
        }
        Map<Id, Lead> leadsMap = new Map <Id, Lead> (
        [SELECT Id, SummaryScoringRu__c
        FROM Lead
        WHERE Id = :newLead.Id
        ]);
        system.assertEquals(leadsMap.get(newLead.Id).SummaryScoringRu__c, -18230);
    }

    @isTest
    static void testsetPenaltyRating_telesalesQueue(){
        FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365,
                Penalty_for_refusal_Telesales__c = 60
        );
        insert fieldSalesSettings;

        User telesale;

        List <Group> queues = [SELECT Id, Type, Name, DeveloperName FROM Group WHERE DeveloperName = 'PPR_Queue_Stock_DISQUALIFIED'];

        if (!queues.isEmpty()) {
            List <User> telesalesUsers =
            [SELECT Id FROM User
            WHERE Id IN (SELECT UserOrGroupId
            FROM GroupMember
            WHERE Group.Id = :queues[0].Id)];
            if (!telesalesUsers.isEmpty()) telesale = telesalesUsers[0];
        } else {
            List <User> telesalesUsers =
            [SELECT Id FROM  User
            WHERE Profile.Name = 'Russian Call Center'];
            if (!telesalesUsers.isEmpty()) telesale = telesalesUsers[0];
        }

        if (telesale != null) {
            Id recordType;
            if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи') != null) {
                recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
            } else if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales') != null) {
                recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
            }

            Lead newLead = new Lead();
            newLead.Salutation = 'Herr1';
            newLead.LastName = 'Test LastName2';
            newLead.LeadSource = 'Partner';
            newLead.Company = 'test2';
            newLead.Country = 'Russia';
            newLead.Anzahl_der_Fahrzeuge__c = 5;
            newLead.Phone = '+72231111111';
            newLead.Partner_OBN__c = '223223';
            newLead.Branche_NACE__c = 'Apotheken - 4773';
            newLead.Beschaeftigte__c = '1-4';
            newLead.Sec_Channel__c = 'Inbound';
            newLead.Region__c = 'Кировская область';
            newLead.RecordTypeId = recordType;
            newLead.INN__c = '234234123422';
            newLead.OwnerId = telesale.Id;
            newLead.Street = 'САНКТ-ПЕТЕРБУРГ';
            newLead.Rating_FS__c = 20;

            insert newLead;

            system.runAs(telesale){
                newLead.Status = 'Disqualified';
                update newLead;
            }
            Map<Id, Lead> leadsMap = new Map <Id, Lead> (
            [SELECT Id, SummaryScoringRu__c
            FROM Lead
            WHERE Id = :newLead.Id
            ]);
            system.assertEquals(leadsMap.get(newLead.Id).SummaryScoringRu__c, -2980);
        }
    }

    @isTest
    static void testSetCCSSalesProcessRecordType(){
        Lead lead = new Lead(
                LastName = 'test',
                Company = 'test',
                CountryCode = 'DE',
                Number_of_Cards_facebook__c = '1',
                LeadSource = 'CCS WEB Telesales FB');
        insert lead;
        LIst<Lead> leads = [SELECT RecordTypeId FROM Lead WHERE Id =: lead.Id];
        List<RecordType> recordTypeList = [
                SELECT Name
                FROM RecordType
                WHERE Name = 'CCS Sales process' AND sObjectType = 'Lead'
        ];
        System.assertEquals(recordTypeList[0].Id, leads[0].RecordTypeId);
    }

    @isTest
    static void testSetRecordAddressFromOKATO(){
        RecordType russianRecordType = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Lead' LIMIT 1];
        Lead newLead = new Lead(
                LastName = 'test', Company = 'test', CountryCode = 'CZ',
                Email = 'test@test.com', Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet', Branche_NACE__c = 'test',
                RecordTypeId = russianRecordType.Id,
                Phone = '+71231231231',
                RecordType = russianRecordType,
                Status = 'Open',
                OKATO__C = '65401000000'
        );
        insert newLead;

        Lead lead = [SELECT Region__c, Area__c FROM Lead WHERE Id = :newLead.Id];
        system.assertEquals(lead.Region__c,'Свердловская область');
        system.assertEquals(lead.Area__c,'город Екатеринбург');

        newLead.OKATO__c = '65476000000';
        update newLead;
        lead = [SELECT Region__c, Area__c FROM Lead WHERE Id = :newLead.Id];
        system.assertEquals(lead.Region__c,'Свердловская область');
        system.assertEquals(lead.Area__c,'город Нижний Тагил');
    }

    @isTest
    static void testCalculateProcessingTime() {
        Id recordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        Lead testLead = new Lead(
                Salutation = 'Herr',
                RecordTypeId = recordTypeId,
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Unprocessed',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '12345',
                Anzahl_der_Fahrzeuge__c = 2,
                CountryCode = 'RU',
                Region__c = 'Кировская область',
                Phone = '+79852769431',
                Email = 'test@test.com');
        insert testLead;

        testLead.Status = 'NEW - Not Yet Contacted';
        update testLead;

        List<Lead> leadList = [
                SELECT Lead_Processing_Time__c
                FROM Lead
                WHERE Id = :testLead.Id
                LIMIT 1
        ];
        System.assertNotEquals(leadList.get(0).Lead_Processing_Time__c,null);
    }

    /*******************************************************************************
    *  Name            : testCheckOzNumberUpdateOwner()
    *  Summary         : test Check OZ number with data in custom settings Oz_number_checker__c .
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckOzNumberUpdateOwner() {
        String leadRecId = GlobalUtils.returnRecordTypeId('Lead', 'CCS Sales process');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];
        List<User> UserOwnerNew = [SELECT Id, ProfileId FROM User WHERE UserRole.Name = 'Altevida CCS Telesales' AND IsActive = true LIMIT 1];

        Oz_number_checker__c OZ = new Oz_number_checker__c(
                Name = 'TEST',
                OZ_Number__c = '123456789',
                UserId__c = User.get(0).Id);
        insert OZ;

        Oz_number_checker__c OZ2 = new Oz_number_checker__c(
                Name = 'TEST2',
                OZ_Number__c = 'A01',
                UserId__c = UserOwnerNew.get(0).Id);
        insert OZ2;

        Lead newLead = new Lead(
                LastName = 'test', Company = 'test', CountryCode = 'CZ', Country = 'Czech Republic',
                Email = 'test@test.com',
                Salutation = 'Herr',
                OwnerId = User.get(0).Id,
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                Branche_NACE__c = 'test',
                RecordTypeId = leadRecId,
                Phone = '1231231231',
                Status = 'Open',
                CCS_OZ_Number__c = '123456789',
                Anzahl_der_Fahrzeuge__c = 2
        );
        insert newLead;

        System.runAs(User.get(0)) {
            newLead.CCS_OZ_Number__c = 'A01';
            update newLead;
        }
    }


    /*******************************************************************************
     *  Summary         : Test setPartnerRelationship(List<Lead> newList) method from LeadHandler controller
     *  Created         : 07/04/2020 by Artem Voitik
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void setPartnerRelationshipTest() {
        Account partnerAccount = new Account(
                Name = 'partnr station',
                OBN__c = '777',
                BillingCountry = 'Poland',
                BillingCountryCode = 'PL'
        );
        insert partnerAccount;

        Lead lead = new Lead(
                LastName = 'test',
                Company = 'test',
                LeadSource = 'Shell Email',
                Country = 'Poland',
                CountryCode = 'PL',
                Retailer_Account_ID__c = partnerAccount.Id
        );
        insert lead;

        List<Lead> leadList = [SELECT Partner__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(leadList.get(0).Partner__c, partnerAccount.Id);
    }

    @isTest
    static void testSetAccountHomeStation() {
        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        Lead testLead = new Lead(
                Salutation = 'Herr',
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '12345',
                Anzahl_der_Fahrzeuge__c = 2,
                CountryCode = 'DE',
                Phone = '7777777',
                Email = 'test@test.com',
                RecordTypeId = endkundeRecId);
        insert testLead;

        String accountRecordTypeId = GlobalUtils.returnRecordTypeId('Account', 'Retailer');
        Account account = new Account(
                Name = 'test',
                RecordTypeId = accountRecordTypeId,
                ESI__c = '12345',
                BillingCountry = 'Germany');
        insert account;

        Test.startTest();
        testLead.Account_Home_Station__c = account.Id;
        update testLead;
        Test.stopTest();

        List<Lead> result = [SELECT Id, Tankstellen_ID__c, Shell_Tankstelle__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(account.ESI__c, result.get(0).Tankstellen_ID__c);
        System.assertNotEquals('', result.get(0).Shell_Tankstelle__c);
    }

    
    /*******************************************************************************
     *  Summary         : test calculate Total Consumption or Amount fields according to fuel prices
     *  Created         : 01/02/2020
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @IsTest
    public static void testCalculateTotalConsumptionBasedOnAmount() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Endkunde' AND SObjectType = 'Lead' LIMIT 1];
        
        Fuel_Price__c fuelPrice = new Fuel_Price__c(
                Name = 'Austria',
                Index__c = 1
        );
        insert fuelPrice;
        
        Lead lead = new Lead(
                RecordTypeId = rt.Id,
                LastName = 'test',
                Company = 'test',
                CountryCode = 'AT',
                Country = 'Austria',
                Monatlicher_Kraftstoffverbrauch_in_Liter__c = 300
        );
        insert lead;
        
        lead = [SELECT Amount__c FROM Lead LIMIT 1];
        
        lead.Amount__c = 500;
        update lead;
        
        lead = [SELECT Monatlicher_Kraftstoffverbrauch_in_Liter__c FROM Lead LIMIT 1];
    
        System.assertEquals(500, lead.Monatlicher_Kraftstoffverbrauch_in_Liter__c);
    }
}