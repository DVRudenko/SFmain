@isTest
public class GFNI_DashboardDaoImplTest {
    public static GFNI_DashboardDaoImpl gfnDashboardDao = new GFNI_DashboardDaoImpl();

    @testSetup
    static void createTestAccountAndCase() {
        Account acc = new Account(
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
                Name = 'Test GFN Account',
                GFN_Nr__c = 'DE12478550',
                ColCo__c = 'DE',
                BillingCountry = 'Germany'
        );
        insert acc;

        Case c = new Case(
                Origin = 'E-Mail',
                RecordTypeId = GlobalUtils.getRecordTypeId('Case', 'Support'),
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject',
                AccountId = acc.Id
        );
        insert c;

        ERP__c erp = new ERP__c (
            GFN_Nr__c = 'DE123456',
            RecordTypeId = GlobalUtils.getRecordTypeId('ERP__c', 'SME'),
            Name = 'test'
        );
        insert erp;
    }

    @isTest
    public static void testGetAccountById() {
        Account acc = [
                SELECT Id, Name, GFN_Nr__c, ColCo__c, OwnerId
                FROM Account
                WHERE GFN_Nr__c = 'DE12478550'
                LIMIT 1
        ];

        Account existingAccount = gfnDashboardDao.getAccountById(acc.Id);
        System.assertEquals(existingAccount.GFN_Nr__c == 'DE12478550', true);
    }

    @isTest
    public static void testCaseAccountById() {
        Case c = [
                SELECT Id, CaseNumber, Account.GFN_Nr__c, Account.ColCo__c
                FROM Case
                LIMIT 1
        ];

        Case existingCase = gfnDashboardDao.getCaseAccountById(c.Id);
        System.assertEquals(existingCase.Account.GFN_Nr__c == 'DE12478550', true);
    }

    @isTest
    public static void testERPById() {
        ERP__c erp = [
                SELECT Id, GFN_Nr__c, Name
                FROM ERP__c
                LIMIT 1
        ];

        ERP__c existingERP = gfnDashboardDao.getERPById(erp.Id);
        System.assertEquals('DE123456', existingERP.GFN_Nr__c);
    }
}