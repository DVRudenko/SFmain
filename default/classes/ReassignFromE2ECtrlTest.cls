@IsTest
private class ReassignFromE2ECtrlTest {
    @IsTest
    static void testReassign() {
        User u = [SELECT Id FROM User WHERE Name = 'Integration Administrator'];

        Account acc = new Account(Name = 'Test company', BillingCountry = 'Poland', OwnerId = u.Id);
        insert acc;

        Opportunity opp = new Opportunity(
                OwnerId = u.Id,
                Name = 'Test company',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                E2E_2__c = true);
        insert opp;

        Contact con = new Contact(
                Salutation = 'Herr',
                OwnerId = u.Id,
                LastName = 'test',
                AccountId = acc.Id
        );
        insert con;

        OpportunityContactRole role = new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = opp.Id,
                IsPrimary = true
        );
        insert role;

        User testUser = [SELECT FirstName, LastName FROM User WHERE Profile.Name = 'Sales Inbound' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            ReassignFromE2ECtrl ctrl = new ReassignFromE2ECtrl();
            Apexpages.currentPage().getParameters().put('id', opp.Id);
            ctrl.init();
            ctrl.opp.Owner_Change_Reason__c = 'test123';
            ctrl.save();
        }
        Test.stopTest();

        Opportunity testOpp = [SELECT OwnerId, Owner_Change_Reason__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(testUser.Id, testOpp.OwnerId, 'New owner is not correct');
        System.assertEquals('test123', testOpp.Owner_Change_Reason__c, 'Invalid owner change reason');
    }


    @IsTest
    static void testOwnerReason() {
        User u = [SELECT Id FROM User WHERE Name = 'Integration Administrator'];

        Account acc = new Account(Name = 'Test company', BillingCountry = 'Poland', OwnerId = u.Id);
        insert acc;

        Opportunity opp = new Opportunity(
                OwnerId = u.Id,
                Name = 'Test company',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                E2E_2__c = true);
        insert opp;

        Contact con = new Contact(
                Salutation = 'Herr',
                OwnerId = u.Id,
                LastName = 'test',
                AccountId = acc.Id
        );
        insert con;

        OpportunityContactRole role = new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = opp.Id,
                IsPrimary = true
        );
        insert role;

        User testUser = [SELECT FirstName, LastName FROM User WHERE Profile.Name = 'Sales Inbound' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            ReassignFromE2ECtrl ctrl = new ReassignFromE2ECtrl();
            Apexpages.currentPage().getParameters().put('id', opp.Id);
            ctrl.init();
            ctrl.save();
        }
        Test.stopTest();

        System.assertEquals(Apexpages.getMessages().get(0).getDetail(), 'Please provide a reason for changing Owner from E2E Integration User to you.', 'Invalid owner change reason');
    }


    @IsTest
    static void testInvalidId() {
        Test.startTest();
        ReassignFromE2ECtrl ctrl = new ReassignFromE2ECtrl();
        ctrl.init();
        Test.stopTest();

        System.assertEquals(Apexpages.getMessages().get(0).getDetail(), 'Invalid id', 'Id validation is incorrect');
    }


    @IsTest
    static void testNonE2E() {
        User u = [SELECT Id FROM User WHERE Name = 'Integration Administrator'];

        Account acc = new Account(Name = 'Test company', BillingCountry = 'Poland', OwnerId = u.Id);
        insert acc;

        Opportunity opp = new Opportunity(
                OwnerId = u.Id,
                Name = 'Test company',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today());
        insert opp;

        Contact con = new Contact(
                Salutation = 'Herr',
                OwnerId = u.Id,
                LastName = 'test',
                AccountId = acc.Id
        );
        insert con;

        OpportunityContactRole role = new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = opp.Id,
                IsPrimary = true
        );
        insert role;

        User testUser = [SELECT FirstName, LastName FROM User WHERE Profile.Name = 'Sales Inbound' AND IsActive = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            ReassignFromE2ECtrl ctrl = new ReassignFromE2ECtrl();
            Apexpages.currentPage().getParameters().put('id', opp.Id);
            ctrl.init();
        }
        Test.stopTest();

        System.assertEquals(Apexpages.getMessages().get(0).getDetail(), 'Change owner feature is available for E2E 2.0 only.', 'Invalid E2E 2.0 Opportunity');
    }


    @IsTest
    static void testExistingOwner() {
        Account acc = new Account(Name = 'Test company', BillingCountry = 'Poland');
        insert acc;

        Opportunity opp = new Opportunity(
                Name = 'Test company',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                E2E_2__c = true);
        insert opp;

        Contact con = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = acc.Id
        );
        insert con;

        OpportunityContactRole role = new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = opp.Id,
                IsPrimary = true
        );
        insert role;

        Test.startTest();
        ReassignFromE2ECtrl ctrl = new ReassignFromE2ECtrl();
        Apexpages.currentPage().getParameters().put('id', opp.Id);
        ctrl.init();
        Test.stopTest();

        System.assertEquals(Apexpages.getMessages().get(0).getDetail(), 'This opportunity is already assigned to you.', 'Invalid Opportunity assignment');
    }


    @IsTest
    static void testCancel() {
        Account acc = new Account(Name = 'Test company', BillingCountry = 'Poland');
        insert acc;

        Opportunity opp = new Opportunity(
                Name = 'Test company',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                E2E_2__c = true);
        insert opp;

        Contact con = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = acc.Id
        );
        insert con;

        OpportunityContactRole role = new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = opp.Id,
                IsPrimary = true
        );
        insert role;

        Test.startTest();
        ReassignFromE2ECtrl ctrl = new ReassignFromE2ECtrl();
        Apexpages.currentPage().getParameters().put('id', opp.Id);
        ctrl.init();
        ctrl.cancel();
        Test.stopTest();
    }
}