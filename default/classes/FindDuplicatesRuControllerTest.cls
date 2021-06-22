@isTest
public class FindDuplicatesRuControllerTest {

    @isTest
    public static void searchTest() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String recordTypeOppId = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
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

        Contact contt = new Contact(LastName = 'testcontact12345', Phone = '+71234567890', Email = 'test@testcont.ru', AccountId = accountt.Id);
        insert contt;

        Opportunity opportunity = createOpportunity(accountt, recordTypeOppId);
        insert opportunity;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesRuController contr = new FindDuplicatesRuController();

        List<String> fixedSearchResults= new List<String>{ accountt.Id, opportunity.Id, lead.Id };
        Test.setFixedSearchResults(fixedSearchResults);

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        FindDuplicatesRuController controller = new FindDuplicatesRuController();
        controller.isCompanySelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.matchingAccounts.size(), 1);
        System.assertEquals(controller.matchingOpportunities.size(), 1);

    }
    @isTest
    public static void searchTest2() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String recordTypeOppId = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
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

        Opportunity opportunity = createOpportunity(accountt, recordTypeOppId);
        insert opportunity;
        Test.startTest();
        Test.stopTest();

        List<String> fixedSearchResults= new List<String>{ accountt.Id, opportunity.Id, lead.Id };
        Test.setFixedSearchResults(fixedSearchResults);

        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesRuController controller = new FindDuplicatesRuController();
        controller.isCompanySelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.matchingAccounts.size(), 1);
        System.assertEquals(controller.matchingOpportunities.size(), 1);
    }

    @IsTest
    public static void searchForE2EOpportunityTest() {
        createCustomSettings();
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String recordTypeOppId = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
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

        Opportunity opportunity = createOpportunity(accountt, recordTypeOppId);
        insert opportunity;
        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesRuController contr = new FindDuplicatesRuController();

        List<String> fixedSearchResults= new List<String>{ accountt.Id, opportunity.Id, lead.Id };
        Test.setFixedSearchResults(fixedSearchResults);

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        FindDuplicatesRuController controller = new FindDuplicatesRuController();
        controller.isCompanySelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.matchingAccounts.size(), 1);
        System.assertEquals(controller.matchingOpportunities.size(), 1);
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }

    public static Opportunity createOpportunity(Account account, Id recordTypeId) {
        Opportunity opportunity = new Opportunity(
                Name = 'TEST',
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
                RecordTypeId = recordTypeId
        );
        return opportunity;
    }
}
