@IsTest
private class SwitchLeadToE2EQueueableTest {
    @isTest
    public static void testShellEmailDuplicateBEFR() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Belgium-FR',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
                Name = 'Belgium-FR',
                E2E_Form_Url__c = 'https://online.fleetcorcards.be/etebefr',
                E2E_JITB_Form_Url__c = 'https://online.fleetcor.nl/etejitblocator',
                Private_Key__c = 'P83U8MmjgIBU0V4l',
                Short_Url__c = 'https://online.fleetcorcards.be/i'
        );
        insert shortUrlSettings;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Belgium-FR', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        List<Lead> leadList = new List<Lead>();
        Lead duplicateLead = new Lead(
                LastName = 'test',
                FirstName = 'test',
                Email = 'test@test.com',
                Company = 'test',
                Phone = '1111111111',
                LeadSource = 'Shell Email',
                CCS_number_of_cards__c = 1,
                Country = 'Belgium-FR',
                CountryCode = 'BEFR');
        leadList.add(duplicateLead);

        Lead lead = new Lead(
                LastName = 'test',
                FirstName = 'test',
                Email = 'test@test.com',
                Company = 'test',
                Phone = '1111111111',
                LeadSource = 'Shell Email',
                CCS_number_of_cards__c = 1,
                Contact_Email_Body__c = LeadTriggerTestShellEmails.SHELL_EMAIL_BEFR,
                Country = 'Belgium-FR',
                CountryCode = 'BEFR');
        leadList.add(lead);
        insert leadList;

        Test.startTest();
            System.enqueueJob(new SwitchLeadToE2EQueueable(lead.Id, false));
        Test.stopTest();

        Lead testLead = [SELECT Status, Quali_Status__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Disqualified', testLead.Status);
        System.assertEquals('Auto-detect (E2E)', testLead.Quali_Status__c);
    }

    @isTest
    public static void testShellEmailNoDuplicateNL() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Netherlands',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
                Name = 'Netherlands',
                E2E_Form_Url__c = 'https://online.fleetcor.nl/etenl',
                E2E_JITB_Form_Url__c = 'https://online.fleetcor.nl/etejitblocator',
                Private_Key__c = 'P83U8MmjgIBU0V4l',
                Short_Url__c = 'https://online.fleetcor.nl/i'
        );
        insert shortUrlSettings;

        List<User> e2eUser = [SELECT Id, ProfileId FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Netherlands', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        Fleetcor_Profile_Info_Settings__c profilesSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'E2E Profile',
                ProfileId__c = e2eUser.get(0).ProfileId);
        insert profilesSettings;

        Lead lead = new Lead(
                LastName = 'test',
                FirstName = 'test',
                Email = 'test@test.com',
                Company = 'test',
                LeadSource = 'Shell Email',
                Phone = '1111111111',
                CCS_number_of_cards__c = 2,
                Contact_Email_Body__c = LeadTriggerTestShellEmails.SHELL_EMAIL_NL,
                Country = 'Netherlands',
                CountryCode = 'NL');
        insert lead;

        List<User> salesUsers = [SELECT Id FROM User WHERE Profile.Name = 'E2E Profile' AND IsActive = true LIMIT 1];
        System.runAs(salesUsers.get(0)) {
            Test.startTest();
                System.enqueueJob(new SwitchLeadToE2EQueueable(lead.Id, false));
            Test.stopTest();
        }

        Lead testLead = [SELECT Quali_Status__c FROM Lead WHERE Id = :lead.Id];
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
}