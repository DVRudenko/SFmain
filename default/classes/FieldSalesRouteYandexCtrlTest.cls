@isTest
public with sharing class FieldSalesRouteYandexCtrlTest {

    @isTest
    public static void testMethodInitOpportunity() {
        createCustomSettings();

        List<User> userList = [
                SELECT id
                FROM User
                WHERE Profile.Name = 'Russian Sales Manager'
                AND IsActive = true
                AND UserRole.Name != 'PPR Key Accounts Manager' AND UserRole.Name != 'PPR Teamleader KAM'
                LIMIT 1
        ];
        Id userId = userList.get(0).Id;

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 1000000,
                Phone = '+71234567890', BillingStreet = 'Санкт-Петербург ул. Пестеля, 15', INN__C = '1234567899999', OwnerId = userId,
                RecordTypeId = RecordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = RecordTypeOpp);
        insert opportunity;

        PageReference pageRef = Page.FieldSalesRouteYandex;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);
        FieldSalesRouteYandexCtrl controller = new FieldSalesRouteYandexCtrl();
        controller.init();
        system.assertNotEquals(controller.address, null);
        system.assertNotEquals(controller.territory, null);
    }

    @isTest
    public static void testMethodInitLead() {
        List<User> userList = [
                SELECT id
                FROM User
                WHERE Profile.Name = 'Russian Sales Manager'
                AND IsActive = true
                AND UserRole.Name != 'PPR Key Accounts Manager' AND UserRole.Name != 'PPR Teamleader KAM'
                LIMIT 1
        ];
        Id userId = userList.get(0).Id;

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;

        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321', Street = 'Санкт-Петербург ул. Пестеля, 15',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = userId);
        insert lead;

        PageReference pageRef = Page.FieldSalesRouteYandex;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', lead.Id);
        FieldSalesRouteYandexCtrl controller = new FieldSalesRouteYandexCtrl();
        controller.init();
        system.assertNotEquals(controller.address, null);
        system.assertNotEquals(controller.territory, null);
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}