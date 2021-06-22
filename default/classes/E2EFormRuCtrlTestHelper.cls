@isTest
public with sharing class E2EFormRuCtrlTestHelper {
    
    public static void setURLParams() {
        Test.setCurrentPageReference(new PageReference('e2eFormRu.page'));
        System.currentPageReference().getParameters().put('deviceType', 'Desktop');
        System.currentPageReference().getParameters().put('cemail', 'test@test.ru');
        System.currentPageReference().getParameters().put('cphone', '89123456789');
        System.currentPageReference().getParameters().put('splitWTL', 'A');
        System.currentPageReference().getParameters().put('suffix', '_CONTRACT');
        System.currentPageReference().getParameters().put('promocodeName', '7E10');
        System.currentPageReference().getParameters().put('promocodeItem', '«Роснефть», «Башнефть», "ТНК»'); //
        System.currentPageReference().getParameters().put('tariffName', 'Тариф');
        System.currentPageReference().getParameters().put('tariffID', 'Оптимальный');
        System.currentPageReference().getParameters().put('productID', 'PetrolPlus_Rover');
        System.currentPageReference().getParameters().put('source', 'Metro');
        System.currentPageReference().getParameters().put('clientId','123456789.123456789');
    }

    public static void initPagesStructure() {
        E2EFormRuTestUtils.createLongFormRU();
        E2EFormRuTestUtils.createContactDetailsStep();
        E2EFormRuTestUtils.createCompanyInformationStep();
        E2EFormRuTestUtils.createOrderStep();
        E2EFormRuTestUtils.createLegalDetailsStep();
        E2EFormRuTestUtils.createPaymentDetailsStep();
    }

    public static void initCustomSettings() {
        E2EFormRuTestUtils.initCustomSettings();

        insert new E2E_Sources__c(
            Name = 'Metro',
            Offer__c = 'PetrolPlus',
            Partner_Transit_Id__c = '',
            Product__c = 'PetrolPlus_Rover',
            Promo__c = 'PIU5'
        );

        insert new CF_Settings__c(Name = 'Russia', Check_on_opportunity_create__c = false, Check_on_opportunity_update__c = false);
    }

    public static UserRole createRole(String NameRole) {
        UserRole rol = new UserRole(Name = NameRole);
        insert rol;
        return rol;
    }

    public static List<Account> createAccounts(Integer numAccts) {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < numAccts; i++) {
            Account a = new Account(Name = 'TestAccount' + i, BillingCountry = 'Russia');
            accts.add(a);
        }
        insert accts;
        return accts;
    }

    public static List<User> createUsers(Integer numUsers, String RoleName) {
        List<User> users = new List<User>();

        for (Integer i = 0; i < numUsers; i++) {
            User a = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only']
                .Id,
                LastName = 'last ' + i,
                Email = 'user000@amamama.com',
                Username = 'user000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = createRole(RoleName).id
            );
            users.add(a);
        }
        insert users;
        return users;
    }

    public static void createOppr(Id AccId, Id OwnerId) {
        Opportunity Oppr = new Opportunity(
            Name = 'testing',
            AccountId = AccId,
            StageName = 'Prospecting',
            OwnerId = OwnerId,
            CloseDate = Date.Today()
        );
        insert Oppr;
    }
    public static E2E_Promocodes__c createPromocodes() {
        E2E_Promocodes__c promocod = new E2E_Promocodes__c(
                Name = '9Е22',
                Product_Name__c = 'Вездеход Online',
                Promocode_Additional_Field__c = '@175',
                Promocode_Description_Body__c = 'Скидка 50 копеек с литра топлива на <a target="_blank" rel="noopener noreferrer"' +
                        ' href="http://www.petrolplus.ru/docs.php?f=rn-bn-tnk">«АЗС Роснефть, Башнефть и ТНК»</a> и в течении 6 календарных месяцев с даты договора.',
                Report_Identifiers__c = '175@31',
                Supplier_Selection__c = 'True',
                Promocode_Classic_Label__c = 'Акция: 50 копеек с литра!'
        );

        insert promocod;
        return promocod;
    }
}
