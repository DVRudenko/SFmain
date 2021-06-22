@IsTest
private class LFChatServiceTest {

    public static testMethod void createData() {
        LongForm__c longForm = new LongForm__c(
                Country__c = 'Germany',
                Title__c = 'test'
        );
        insert longForm;

        LongForm_Page__c longFormPage = new LongForm_Page__c(
                Name = 'CHAT',
                Title__c = 'CHAT',
                System_Error__c = 'error',
                Type__c = 'Basic',
                Long_Form__c = longForm.Id
        );
        insert longFormPage;

        LongForm_Element__c longFormElement = new LongForm_Element__c(
                Name = 'SALUTATION',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = longFormPage.Id
        );
        insert longFormElement;

        LongForm_Element_Item__c longFormElementItem = new LongForm_Element_Item__c(
                Name = 'test',
                Active__c = true,
                Type__c = 'Options',
                Long_Form_Element__c = longFormElement.Id,
                Value__c = 'test'
        );
        insert longFormElementItem;
    }

    static testMethod void testMethod1() {
        createData();
        Account account = new Account(
                Name = 'test',
                Partnertyp__c = 'Retailer',
                BillingCountry = 'Germany',
                Email_retailer__c = 'test@test.com');
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;
        LFChatService chatService = new LFChatService();
        chatService.setPageMap('Germany');
        chatService.setContact(contact);
        chatService.getPagesMap();
    }

    static testMethod void setFlagChatToOpportunityTest() {
        Opportunity opp = new Opportunity(
                Name = 'Test',
                CloseDate = Date.today(),
                Home_Station__c = 'test',
                StageName = 'Closed Won',
                Angebotsdauer__c = 'test',
                E2E_Chat_Step__c = '');
        insert opp;

        E2E_Chat_Setup__c e2eChatSetup = new E2E_Chat_Setup__c(
                Name = 'Germany',
                chatButtonId__c = '5730O000000byby',
                chatURL__c = 'https://d.la1-c1cs-frf.salesforceliveagent.com/chat',
                DeploymentJS__c = '/resource/1525433079000/e2eLiveAgentDeployment',
                chatDeploymentId__c = '5720O000000byvg'
        );
        insert e2eChatSetup;

        LFChatService.setFlagChatToOpportunity(opp.Id,'manual',2,'currentstep');

        List<opportunity> testlist = [SELECT ID,E2E_Chat__c,E2E_Chat_Step__c FROM Opportunity where id = :opp.id];
        system.assertEquals(testlist.get(0).E2E_Chat__c,'initiated manual');
        system.assertNotEquals(testlist.get(0).E2E_Chat_Step__c,'');


        LFChatService.setFlagChatToOpportunity(opp.Id,'automatical',2,'currentstep');
        List<opportunity> testlist2 = [SELECT ID, E2E_Chat__c, E2E_Chat_Step__c FROM Opportunity where id = :opp.id];
        system.assertEquals(testlist2.get(0).E2E_Chat__c,'initiated manual');
        system.assertNotEquals(testlist2.get(0).E2E_Chat_Step__c,'');
    }

    static testMethod void saveOfflineChatLogTest(){
        Opportunity opp = new Opportunity(
                Name = 'Test',
                CloseDate = Date.today(),
                Home_Station__c = 'test',
                StageName = 'Closed Won',
                Angebotsdauer__c = 'test');
        insert opp;


        LFChatService.saveOfflineChatLog('test','0.0.0.0',1,'stepnumber1','Germany',opp.id,null);
        List<LiveChatTranscript> testlist = [SELECT id FROM LiveChatTranscript WHERE Opportunity__c = :opp.id LIMIT 1];
        system.assertEquals(testlist.size(),1);

        LFChatService.saveOfflineChatLog('test2','0.0.0.0',1,'stepnumber1','Germany',opp.id,null);
        List<LiveChatTranscript> testlist2 = [SELECT id,body FROM LiveChatTranscript WHERE Opportunity__c = :opp.id LIMIT 1];
        system.assertEquals(testlist2.get(0).body.contains('test2'),true);
    }


    static testMethod void setFlagChatToOpportunityTest2() {
        Opportunity opp = new Opportunity(
                Name = 'Test',
                CloseDate = Date.today(),
                Home_Station__c = 'test',
                StageName = 'Closed Won',
                Angebotsdauer__c = 'test',
                E2E_Chat_Step__c = '');
        insert opp;

        E2E_Chat_Setup__c e2eChatSetup = new E2E_Chat_Setup__c(
                Name = 'Germany',
                chatButtonId__c = '5730O000000byby',
                chatURL__c = 'https://d.la1-c1cs-frf.salesforceliveagent.com/chat',
                DeploymentJS__c = '/resource/1525433079000/e2eLiveAgentDeployment',
                chatDeploymentId__c = '5720O000000byvg'
        );
        insert e2eChatSetup;

        LFChatService.setFlagChatToOpportunity(opp.id, 'manual',2,'currentstep');
        List<opportunity> testlist = [SELECT ID,E2E_Chat__c,E2E_Chat_Step__c FROM Opportunity where id = :opp.id];
        system.assertEquals(testlist.get(0).E2E_Chat__c,'initiated manual');
        system.assertNotEquals(testlist.get(0).E2E_Chat_Step__c,'');

        LFChatService.setFlagChatToOpportunity(opp.id, 'automatical',2,'currentstep');
        List<opportunity> testlist2 = [SELECT ID, E2E_Chat__c, E2E_Chat_Step__c FROM Opportunity where id = :opp.id];
        system.assertEquals(testlist2.get(0).E2E_Chat__c,'initiated manual');
        system.assertNotEquals(testlist2.get(0).E2E_Chat_Step__c,'');
    }

    static testMethod void saveOfflineChatLogTest2(){
        Account account = new Account(
                Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN',
                BillingStreet = 'Dichterweg 27',
                ShippingStreet = 'Dichterweg 27',
                BillingPostalCode = '99423',
                ShippingPostalCode = '99423',
                BillingCity = 'Weimar',
                ShippingCity = 'Weimar',
                BillingCountry = 'Germany',
                BillingCountryCode = 'DE',
                Type = 'Customer',
                Beschaeftigte__c = '1-4',
                Gesellschaftsform__c = 'AG',
                Steuernummer__c = '234154542',
                Umsatzsteuer_ID__c = 'DE821235454');
        insert account;
        Opportunity opp = new Opportunity(
                Name = 'Test',
                CloseDate = Date.today(),
                Home_Station__c = 'test',
                StageName = 'Closed Won',
                AccountId = account.id,
                Angebotsdauer__c = 'test');
        insert opp;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Ochsenkott KTO',
                FirstName = 'Oswald',
                AccountId = account.Id,
                Phone = '123123123',
                MailingCountry = 'Germany',
                MailingCountryCode = 'DE'
                );
        insert contact;

        LFChatService chatService = new LFChatService();
        chatService.setChatDefaultSettings('Germany');

        LFChatService.saveOfflineChatLog('test','0.0.0.0',1,'stepnumber','Germany',opp.Id,contact.id);
        List<LiveChatTranscript> testlist = [SELECT id FROM LiveChatTranscript WHERE Opportunity__c = :opp.id LIMIT 1];
        system.assertEquals(testlist.size(),1);

        LFChatService.saveOfflineChatLog('test2','0.0.0.0',1,'stepnumber2','Germany',opp.Id,contact.id);
        List<LiveChatTranscript> testlist2 = [SELECT id,body FROM LiveChatTranscript WHERE Opportunity__c = :opp.id LIMIT 1];
        system.assertEquals(testlist2.get(0).body.contains('test2'),true);
    }

    static testMethod  void getFirstChatMessageTest(){
        Opportunity opp = new Opportunity(
                Name = 'Test',
                CloseDate = Date.today(),
                Home_Station__c = 'test',
                StageName = 'Closed Won',
                Angebotsdauer__c = 'test');
        insert opp;

        LFChatService chatService = new LFChatService();
        chatService.setOpportunity(opp);

        String chatFirstMessage = chatService.getFirstChatMessage('Germany', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Germany', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Netherlands', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-NL', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Belgium-FR', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Russia', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Hungary', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Poland', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Poland', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('France', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('France', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-DE', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Switzerland-FR', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');


        chatFirstMessage = chatService.getFirstChatMessage('Austria', 0, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 1, 'Search company', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 1, 'Set total consumption', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 1, 'Calculating credit score', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 2, 'Card configuration', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 2, 'Choosing offer', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 2, 'Technical parameters', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 3, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 4, 'DirectDebit', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', 4, 'Congratulations', 'testname');
        system.assertNotEquals(chatFirstMessage,'');

        chatFirstMessage = chatService.getFirstChatMessage('Austria', -1, '', 'testname');
        system.assertNotEquals(chatFirstMessage,'');
    }

}