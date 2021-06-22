@isTest
public class DeduplicationServiceTestDataFactory {
    public DeduplicationService.DeduplicationData createDeduplData(String Email, String INN, User owner) {
        DeduplicationService.DeduplicationData deduplicationData = new DeduplicationService.DeduplicationData();
        List<Account> excludedAccounts = new List<Account>();
        excludedAccounts.add(createAccount('3333333333'));
        insert excludedAccounts;
        deduplicationData.excludedAccounts = excludedAccounts;

        List<Contact> excludedContacts = new List<Contact>();
        excludedContacts.add(createContact(excludedAccounts[0].Id, 'test@test.ru'));
        insert excludedContacts;
        deduplicationData.excludedContacts = excludedContacts;  
        
        Opportunity opportunity = createOpportunity('test', excludedAccounts[0].Id, 'Qualified Lead', Date.Today().addDays(15), owner);
        insert opportunity;
        deduplicationData.opportunity = opportunity;

        deduplicationData.INN = INN;
        deduplicationData.Email = Email;
        return deduplicationData;
    }

    public User createUser() {
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR_Fleetcor' AND DeveloperName = 'PPR_Fleetcor'];
        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
        User user = new User(
            ProfileId = p.Id,
            UserRoleId = ur.Id,
            Username = 'new_user_email@email.ru',
            Email = 'new_user_email@email.ru',
            FirstName = 'User',
            LastName = 'Test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Chicago',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        return user;
    }

    public User createAdminUser() {
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Role Up' AND DeveloperName = 'Role_Up'];
        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
        User user = new User(
            Username = 'new_user_admin@Test.com',
            Email = 'admin@test.com',
            FirstName = 'AdminUser',
            LastName = 'admin_tester',
            ProfileId = p.Id,
            UserRoleId = ur.Id,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Moscow',
            EmailEncodingKey = 'UTF-8',
            Alias = 'admin'
        );
        return user;
    }

    public Account createAccount(String INN) {
        Account account = new Account(
            RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Russian'),
            Name = 'Test',
            BillingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
            ShippingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
            Type = 'Customer',
            AccountSource = 'E2E Form RU',
            INN__c = INN,
            Company_Legal_Name1__c = ''
        );
        return account;
    }

    public Contact createContact(Id accountId, String email) {
        Contact contact = new Contact(
            RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
            Salutation = 'Mr.',
            LeadSource = 'E2E Form RU',
            AccountId = accountId,
            FirstName = 'Contact Test',
            LastName = 'LastName',
            Title = 'генеральный директор',
            PD_Avaliable_LastName_Update__c = true,
            Phone = '+49 55455555045',
            MobilePhone = '+49 55455555045',
            Email = email
        );
        return contact;
    }

    public Opportunity createOpportunity(String name, Id accountId, String stageName, Date closeDate, User owner) {
        Opportunity opportunity = new Opportunity(
            Name = name,
            StageName = stageName,
            AccountId = accountId,
            CloseDate = closeDate,
            LeadSource = 'E2E Form RU',
            Lead_Source_TypeOpp__c = 'Webform',
            Source_of_Lead_o__c = 'E2E Form RU',
            Source_if_self_sourced_c__c = 'E2E Form RU',
            PPR_First_Contact_Inbound_Outbound__c = 'Inbound Website',
            Channel__c = 'Internet',
            RecordTypeId = GlobalUtils.getRecordTypeId('Opportunity', 'Russian_Sales'),
            E2E_Active_Substep__c = '',
            E2E_Last_Activity__c = Datetime.now(),
            E2E_Status__c = 'Клиент Активен',
            E2E_Sales_Type__c = 'Чистый e2e',
            Projected_Liters_weekly__c = 88.00,
            Projected_amount_in_rub_month__c = 55535.35,
            Number_of_cars__c = 2,
            Number_of_trucks__c = 1,
            Business_process__c = GlobalUtils.BusinessProcessType.E2EClassic.name(),
            OwnerId = owner.id
        );
        return opportunity;
    }
}