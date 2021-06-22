@IsTest
private class SendChangeOwnerRequestControllerTest {
    public static User activeIntegrationAdministrator;
    public static User testUserWithManager;
    public static User inActiveUser;
    public static User testUser;

    @IsTest
    static void testSendRequestIntegrationAdministratorWithoutManager() {
        Test.startTest();
        createActiveUserWithoutManager();
        Test.stopTest();
        Account account;
        System.runAs(activeIntegrationAdministrator) {
             account = new Account(
                    Name = 'test',
                    BillingCountry = 'Germany',
                    OwnerId = activeIntegrationAdministrator.Id);
            insert account;
            ApexPages.CurrentPage().getparameters().put('id', account.Id);
        }
        System.runAs(testUser) {
            SendChangeOwnerRequestController controller = new SendChangeOwnerRequestController();
            controller.init();
            Account testAcc = [SELECT OwnerId, Active_Change_Owner_Request__c FROM Account WHERE Id = :account.Id];
            System.assert(testAcc.Active_Change_Owner_Request__c);
            System.assertEquals(activeIntegrationAdministrator.Id, testAcc.OwnerId);
        }
    }

    @IsTest
    static void testSendRequestIntegrationAdministratorWithManager() {
        Test.startTest();
        createActiveUserWithoutManager();
        Test.stopTest();
        Account account;
        System.runAs(activeIntegrationAdministrator) {
            account = new Account(
                    Name = 'test',
                    BillingCountry = 'Germany',
                    OwnerId = activeIntegrationAdministrator.Id);
            insert account;
            ApexPages.CurrentPage().getparameters().put('id', account.Id);
        }
        System.runAs(testUserWithManager) {
            SendChangeOwnerRequestController controller = new SendChangeOwnerRequestController();
            controller.init();
            Account testAcc = [SELECT OwnerId, Active_Change_Owner_Request__c FROM Account WHERE Id = :account.Id];
            System.assert(testAcc.Active_Change_Owner_Request__c);
            System.assertEquals(activeIntegrationAdministrator.Id, testAcc.OwnerId);
        }
    }

    @IsTest
    static void testSendRequestAnotherUser() {
        Test.startTest();
        createActiveUserWithoutManager();
        Test.stopTest();
        Account account;
        System.runAs(testUserWithManager) {
            User user = [SELECT ManagerId, Manager.Name FROM User WHERE Id = :UserInfo.getUserId()];
            System.debug(user.ManagerId);
            System.debug(user.Manager.Name);
            account = new Account(
                    Name = 'test',
                    BillingCountry = 'Germany',
                    OwnerId = testUserWithManager.Id);
            insert account;
            ApexPages.CurrentPage().getparameters().put('id', account.Id);
        }
        System.runAs(testUser) {
            SendChangeOwnerRequestController controller = new SendChangeOwnerRequestController();
            controller.init();
            Account testAcc = [SELECT OwnerId, Active_Change_Owner_Request__c FROM Account WHERE Id = :account.Id];
            System.assert(testAcc.Active_Change_Owner_Request__c);
            System.assertEquals(testUserWithManager.Id, testAcc.OwnerId);
        }
    }

    @IsTest
    static void testSendRequestInActiveUser() {
        Test.startTest();
        createActiveUserWithoutManager();
        Test.stopTest();
        Account account;
        Contact contact;
        Opportunity opportunity;
        System.runAs(testUser) {
            account = new Account(
                    Name = 'test',
                    BillingCountry = 'Germany',
                    OwnerId = inActiveUser.Id);
            insert account;
            opportunity = new Opportunity(
                    StageName = 'Prospecting',
                    CloseDate = Date.today(),
                    Name = 'test',
                    AccountId = account.Id);
            insert opportunity;
            contact = new Contact(
                    Salutation = 'Mr',
                    LastName = 'test lastname',
                    AccountId = account.Id);
            insert contact;
            ApexPages.CurrentPage().getparameters().put('id', account.Id);
        }
        System.runAs(testUser) {
            SendChangeOwnerRequestController controller = new SendChangeOwnerRequestController();
            controller.init();
            Account testAcc = [SELECT OwnerId, Active_Change_Owner_Request__c FROM Account WHERE Id = :account.Id];
            Contact testContact = [SELECT OwnerId  FROM Contact WHERE Id = :contact.Id];
            Opportunity testOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
            System.assert(!testAcc.Active_Change_Owner_Request__c);
            System.assertEquals(testUser.Id, testAcc.OwnerId);
            System.assertEquals(testUser.Id, testContact.OwnerId);
            System.assertEquals(testUser.Id, testOpp.OwnerId);
        }
    }


    @IsTest
    static void testInvalidAccountIdSendRequest() {
        Test.startTest();
        createActiveUserWithoutManager();
        Test.stopTest();
        System.runAs(activeIntegrationAdministrator) {
            SendChangeOwnerRequestController controller = new SendChangeOwnerRequestController();
            controller.init();
        }
    }


    @Future
    private static void createActiveUserWithoutManager() {
        List<User> users = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CCS SME'];
        Profile psa = [SELECT Id FROM Profile WHERE Name = 'CCS System Administrator'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS SK SME'];
        Integer rand = Math.round(Math.random() * 100000);

        testUser = new User(
                UserRoleId = ur.Id,
                ProfileId = psa.Id,
                Username = 'jkljlkj' + '@' + rand + 'test.com',
                Alias = 'batman',
                Email = 'bruce.wayne_' + rand + '@wayneenterprises.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Bruce',
                LastName = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        insert testUser;

        activeIntegrationAdministrator = new User(
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = 'dasda' + '@' + rand + 'test.com',
                Alias = 'batman',
                Email = 'bruce.wayne_' + rand + '@wayneenterprises.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Integration',
                LastName = 'Administrator',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                DelegatedApproverId = testUser.Id
        );
        users.add(activeIntegrationAdministrator);

        inActiveUser = new User(
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = 'zxczzc' + '@' + rand + 'test.com',
                Alias = 'batman',
                Email = 'bruce.wayne_' + rand + '@wayneenterprises.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Bruce',
                LastName = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                IsActive = false
        );
        users.add(inActiveUser);

        insert users;

        testUserWithManager = new User(
                UserRoleId = ur.Id,
                ProfileId = psa.Id,
                Username = 'qweqweqw' + '@' + rand + 'test.com',
                Alias = 'batman',
                Email = 'bruce.wayne_' + rand + '@wayneenterprises.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Bruce',
                LastName = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ManagerId = activeIntegrationAdministrator.Id,
                DelegatedApproverId = testUser.Id
        );
        insert testUserWithManager;
    }
}