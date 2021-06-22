@isTest
public with sharing class DeduplicationServiceTest {
    @testSetup
    static void setup() {
        PublicEmailDomains__c domain = new PublicEmailDomains__c(Name = 'domovoi.ru');
        insert domain;
    }

    @isTest
    public static void testDeduplicationAccountProcess_NoDuplicates() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData deduplicationData = testFactory.createDeduplData('test@domovoi.ru', '222222222', owner);

            Account sfAcc = testFactory.createAccount('222222222');
            insert sfAcc;
            deduplicationData.excludedAccounts.add(sfAcc);

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(deduplicationData);

            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name(), result.statusCode);
            System.assertEquals(false, result.innDuplication);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(null, result.sfAccount);
        }
    }

    ///Account with 0 opportunities was found by INN. Go to E2E case
    @isTest
    public static void testDeduplicationAccountProcess_E2ECase1() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData deduplicationData = testFactory.createDeduplData('test@domovoi.ru', '111111111', owner);

            Account sfAcc = testFactory.createAccount('111111111');
            insert sfAcc;

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(deduplicationData);

            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
            System.assertEquals(true, result.innDuplication);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals(null, result.sfOpportunity);
        }
    }

    ///Account with 1 opportunity was found by INN. Go to E2E case
    @isTest
    public static void testDeduplicationAccountProcess_E2ECase2() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData deduplicationData = testFactory.createDeduplData('test@domovoi.ru', '111111111', owner);

            Account sfAcc = testFactory.createAccount('111111111');
            insert sfAcc;
            Date oppClosedDate = Date.today().addMonths(-7);
            Opportunity sfOpp = testFactory.createOpportunity('TEST', sfAcc.Id, 'Moved to Start', oppClosedDate, owner);
            insert sfOpp;

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(deduplicationData);

            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
            System.assertEquals(true, result.innDuplication);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals(sfOpp.Id, result.sfOpportunity.Id);
        }
    }

    ///Account with 1 opportunity was found by INN. Go to Service case
    @isTest
    public static void testDeduplicationAccountProcess_ServiceByINN() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData deduplicationData = testFactory.createDeduplData('test@domovoi.ru', '111111111', owner);

            Account sfAcc = testFactory.createAccount('111111111');
            insert sfAcc;
            Date oppClosedDate = Date.today();
            Opportunity sfOpp = testFactory.createOpportunity('TEST', sfAcc.Id, 'Moved to Start', oppClosedDate, owner);
            insert sfOpp;

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(deduplicationData);

            System.assertEquals(GlobalUtils.DeduplicationStatus.Service.name(), result.statusCode);
            System.assertEquals(true, result.innDuplication);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals(null, result.sfOpportunity);
        }
    }

    ///Account with 1 opportunity was found by INN. Go to KO case
    @isTest
    public static void testDeduplicationAccountProcess_KOCase1() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData deduplicationData = testFactory.createDeduplData('test@domovoi.ru', '111111111', owner);

            Account sfAcc = testFactory.createAccount('111111111');
            insert sfAcc;
            Date oppClosedDate = Date.today().addMonths(-6);
            Opportunity sfOpp = testFactory.createOpportunity('TEST', sfAcc.Id, 'Awaiting payment', oppClosedDate, owner);
            insert sfOpp;
            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(deduplicationData);

            System.assertEquals(GlobalUtils.DeduplicationStatus.KO.name(), result.statusCode);
            System.assertEquals(true, result.innDuplication);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals(sfOpp.Id, result.sfOpportunity.Id);
        }
    }

    ///Account with 2 not excluded opportunities was found by Contact Domain. Go to Inbound case
    @isTest
    public static void testDeduplicationAccountProcess_InboundCase1() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData deduplicationData = testFactory.createDeduplData('test@test.ru', '111111111', owner);

            Account sfAcc = testFactory.createAccount('22222222');
            insert sfAcc;
            Date oppClosedDate = Date.today();
            Opportunity sfOpp1 = testFactory.createOpportunity('TEST1', sfAcc.Id, 'Договор на проверке', oppClosedDate, owner);
            Opportunity sfOpp2 = testFactory.createOpportunity('TEST2', sfAcc.Id, 'Awaiting payment', oppClosedDate, owner);
            Opportunity sfOpp3 = testFactory.createOpportunity('TEST3', sfAcc.Id, 'Awaiting payment', oppClosedDate, owner);
            insert new List<Opportunity>{ sfOpp1, sfOpp2, sfOpp3 };
            Contact sfCnt = testFactory.createContact(sfAcc.Id, 'test@test.ru');
            insert sfCnt;
            deduplicationData.excludedOpportunities.add(sfOpp3);

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(deduplicationData);

            System.assertEquals(GlobalUtils.DeduplicationStatus.Inbound.name(), result.statusCode);
            System.assertEquals(false, result.innDuplication);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(true, result.isDomainDuplicated);
            System.assertEquals('TEST1', result.sfOpportunity.Name);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
        }
    }

    ///Account with 2 opportunities was found by Contact Email. Go to KO case
    @isTest
    public static void testDeduplicationAccountProcess_KOCase2() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData data = testFactory.createDeduplData('test@domovoi.ru', '111111111', owner);

            Account sfAcc = testFactory.createAccount('22222222');
            insert sfAcc;
            Date oppClosedDate = Date.today().addMonths(-15);
            Opportunity sfOpp1 = testFactory.createOpportunity('TEST1', sfAcc.Id, 'Отказ', oppClosedDate, owner);
            Opportunity sfOpp2 = testFactory.createOpportunity('TEST2', sfAcc.Id, 'Signing of a Contract', oppClosedDate, owner);
            insert new List<Opportunity>{ sfOpp1, sfOpp2 };
            Contact sfCnt = testFactory.createContact(sfAcc.Id, 'test@domovoi.ru');
            insert sfCnt;

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(data);

            System.assertEquals(GlobalUtils.DeduplicationStatus.KO.name(), result.statusCode);
            System.assertEquals(false, result.innDuplication);
            System.assertEquals(true, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals('TEST2', result.sfOpportunity.Name);
        }
    }

    ///Account with 3 opportunities was found by INN and Contact Domain. Go to Inbound case
    @isTest
    public static void testDeduplicationAccountProcess_InboundCase2() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        User otherOwner = testFactory.createAdminUser();
        insert new List<User>{ owner, otherOwner };
        System.runAs(owner) {
            DeduplicationService.DeduplicationData deduplicationData = testFactory.createDeduplData('test@test.ru', '22222222', owner);

            Account sfAcc = testFactory.createAccount('22222222');
            insert sfAcc;
            Date oppClosedDate = Date.today();
            Opportunity sfOpp1 = testFactory.createOpportunity('TEST', sfAcc.Id, 'Signing of a Contract', oppClosedDate, owner);
            Opportunity sfOpp2 = testFactory.createOpportunity('TEST2', sfAcc.Id, 'Signing of a Contract', oppClosedDate, otherOwner);
            Opportunity sfOpp3 = testFactory.createOpportunity('TEST3', sfAcc.Id, 'Signing of a Contract', oppClosedDate, owner);
            insert new List<Opportunity>{ sfOpp1, sfOpp2, sfOpp3 };
            Contact sfCnt = testFactory.createContact(sfAcc.Id, 'test@test.ru');
            insert sfCnt;

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(deduplicationData);

            System.assertEquals(true, result.isDifferentOwnerFoundForOpportunities);
            System.assertEquals(GlobalUtils.DeduplicationStatus.Inbound.name(), result.statusCode);
            System.assertEquals(true, result.innDuplication);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals(null, result.sfOpportunity);
        }
    }

    ///Account with duplicate Contact was found by Contact Domain. Go to Service case
    @isTest
    public static void testDeduplicationAccountProcess_ServiceCase2() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData data = testFactory.createDeduplData('test@test.ru', '11111111', owner);

            Account sfAcc = testFactory.createAccount('22222222');
            sfAcc.Last_pump_date__c = date.today().addYears(1);
            insert sfAcc;
            Contact sfCnt = testFactory.createContact(sfAcc.Id, 'test@test.ru');
            insert sfCnt;

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(
                data.INN,
                data.Email,
                data.excludedAccounts[0].Id,
                data.excludedContacts[0].Id,
                data.Opportunity.Id
            );

            System.assertEquals(GlobalUtils.DeduplicationStatus.Service.name(), result.statusCode);
            System.assertEquals(false, result.innDuplication);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals(false, result.isEmailDuplicated);
            System.assertEquals(true, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals(null, result.sfOpportunity);
        }
    }

    @isTest
    public static void testDeduplicationAccountProcess_E2ECase3() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        System.runAs(owner) {
            DeduplicationService.DeduplicationData data = testFactory.createDeduplData('test@domovoi.ru', '111111111', owner);

            Account sfAcc = testFactory.createAccount('22222222');
            insert sfAcc;
            Date oppClosedDate = Date.today().addMonths(-15);
            Opportunity sfOpp1 = testFactory.createOpportunity('TEST1', sfAcc.Id, 'Предотвращено', oppClosedDate, owner);
            Opportunity sfOpp2 = testFactory.createOpportunity('TEST2', sfAcc.Id, 'Signing of a Contract', oppClosedDate, owner);
            insert new List<Opportunity>{ sfOpp1, sfOpp2 };
            Contact sfCnt = testFactory.createContact(sfAcc.Id, 'test@test.ru');
            sfCnt.Additional_Emails__c = 'test@domovoi.ru';
            insert sfCnt;

            DeduplicationService service = new DeduplicationService();
            E2EFormRuDeduplicationResult result = service.deduplicateAccounts(data);

            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
            System.assertEquals(false, result.innDuplication);
            System.assertEquals(true, result.isEmailDuplicated);
            System.assertEquals(false, result.isDomainDuplicated);
            System.assertEquals(sfAcc.Id, result.sfAccount.Id);
            System.assertEquals('TEST2', result.sfOpportunity.Name);
        }
    }
}