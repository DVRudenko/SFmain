@isTest
private class E2ESystemErrorControllerTest {
    @isTest
    static void testGermanySystemError () {
        E2ELongFormUtilsTest.createLongForm('Germany');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Germany', 'E2EForm', 'Creditreform', UserInfo.getUserId());
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createSystemErrorPage('Desktop');

        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Cookie testCookie = new Cookie('e2esource',opportunity.E2E_Encoded_URL__c, null, 315569260, false);
        ApexPages.currentPage().setCookies(new Cookie[]{testCookie});
        E2ESystemErrorController controller = new E2ESystemErrorController();
        controller.init();

        List<Opportunity> oppsToTest = [SELECT E2E_Errors__c, Owner.Name FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];
        System.assert( ! oppsToTest.isEmpty() );
        System.assertEquals('System Error', oppsToTest.get(0).E2E_Errors__c);
        System.assertEquals(UserInfo.getUserId(), oppsToTest.get(0).OwnerId);
    }

    @isTest
    static void testNetherlandsSystemError () {
        E2ELongFormUtilsTest.createLongForm('Netherlands');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Netherlands', 'E2EForm', 'Creditreform', UserInfo.getUserId());
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createSystemErrorPage('Desktop');

        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Netherlands';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.Product__c = '';
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Cookie testCookie = new Cookie('e2esource',opportunity.E2E_Encoded_URL__c, null, 315569260, false);
        ApexPages.currentPage().setCookies(new Cookie[]{testCookie});
        E2ESystemErrorController controller = new E2ESystemErrorController();
        controller.init();

        List<Opportunity> oppsToTest = [SELECT E2E_Errors__c, Owner.Name FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];
        System.assert( ! oppsToTest.isEmpty() );
        System.assertEquals('System Error', oppsToTest.get(0).E2E_Errors__c);
        System.assertEquals(UserInfo.getUserId(), oppsToTest.get(0).OwnerId);
    }

    @isTest
    static void testSlovakiaSystemError () {
        E2ELongFormUtilsTest.createLongForm('Germany');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Germany', 'E2EForm', 'Creditreform', UserInfo.getUserId());
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createSystemErrorPage('Desktop');

        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Slovakia';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.Product__c = '';
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Cookie testCookie = new Cookie('e2esource',opportunity.E2E_Encoded_URL__c, null, 315569260, false);
        ApexPages.currentPage().setCookies(new Cookie[]{testCookie});
        E2ESystemErrorController controller = new E2ESystemErrorController();
        controller.init();

        List<Opportunity> oppsToTest = [SELECT E2E_Errors__c, Owner.Name FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];
        System.assert( ! oppsToTest.isEmpty() );
        System.assertEquals('System Error', oppsToTest.get(0).E2E_Errors__c);
        System.assertEquals(UserInfo.getUserId(), oppsToTest.get(0).OwnerId);
    }


    @isTest
    static void testGermany() {
        E2ELongFormUtilsTest.createLongForm('Germany');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Germany', 'E2EForm', 'Creditreform', UserInfo.getUserId());
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createSystemErrorPage('Desktop');
                
        E2ESystemErrorController controller = new E2ESystemErrorController();
        controller.init();
    }    
}