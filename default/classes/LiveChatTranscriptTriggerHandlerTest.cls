@isTest
public class LiveChatTranscriptTriggerHandlerTest {
    @isTest
    public static void updateE2EChatFieldsInOpportunityTest(){
        //
        Test.startTest();
        String accRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');
        String euroshellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');

        Account account = new Account(
                Name = 'AccountTestChat1',
                AccountSource = 'ABVP',
                Type = 'Customer',
                BillingCountry = 'Germany',
                Gesellschaftsform__c = 'AG',
                Beschaeftigte__c = '1-4',
                RecordTypeId = accRecId);
        insert account;

        Opportunity testOppo = new Opportunity(
                Name = 'OpportunityTestChat1',
                AccountId = account.Id,
                Sec_Channel__c = 'JITB',
                LeadSource = 'ABVP',
                Type = 'Existing Business',
                StageName = 'Prospecting',
                Number_of_cars__c = 1,
                Number_of_trucks__c = 1,
                Total_number_of_vehicles__c = 2,
                Gasoline_consumption_l_month__c = 10,
                Diesel_consumption_l_month__c = 10,
                Total_consumption_l_month__c = 20,
                Number_of_Cards__c = 1,
                Derzeitige_Zahlungsmethode__c = 'Stationskarte',
                CloseDate = Date.today() - 1,
                RecordTypeId = euroshellRecId,
                E2E_Chat__c = 'initiated manual');
        insert testOppo;

        LiveChatVisitor testVisitor = new LiveChatVisitor();
        insert testVisitor;

        LiveChatTranscript testChat = new LiveChatTranscript(
                LiveChatVisitorId = testVisitor.Id,
                Opportunity__c = testOppo.Id,
                VisitorMessageCount = 0,
                OperatorMessageCount = 0,
                Mode_of_initialization__c = 'manual',
                Status = 'Completed'
        );
        insert testChat;
        update testChat;

        Test.stopTest();

        Opportunity testOppOld = [SELECT Id, E2E_Chat__c, E2E_Visitor_Message_Count__c FROM Opportunity WHERE Id = :testOppo.Id];
        System.assertEquals('initiated manual', testOppOld.E2E_Chat__c);
        System.assertEquals(0, testOppOld.E2E_Visitor_Message_Count__c);
    }

    @isTest
    public static void updateE2EChatFieldsIfChatAutomaticalTest(){

        Test.startTest();
        String accRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');
        String euroshellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');

        Account account = new Account(
                Name = 'AccountTestChat2',
                AccountSource = 'ABVP',
                Type = 'Customer',
                BillingCountry = 'Germany',
                Gesellschaftsform__c = 'AG',
                Beschaeftigte__c = '1-4',
                RecordTypeId = accRecId);
        insert account;

        Opportunity testOppo = new Opportunity(
                Name = 'OpportunityTestChat2',
                AccountId = account.Id,
                Sec_Channel__c = 'JITB',
                LeadSource = 'ABVP',
                Type = 'Existing Business',
                StageName = 'Prospecting',
                Number_of_cars__c = 1,
                Number_of_trucks__c = 1,
                Total_number_of_vehicles__c = 2,
                Gasoline_consumption_l_month__c = 10,
                Diesel_consumption_l_month__c = 10,
                Total_consumption_l_month__c = 20,
                Number_of_Cards__c = 1,
                Derzeitige_Zahlungsmethode__c = 'Stationskarte',
                CloseDate = Date.today() - 1,
                RecordTypeId = euroshellRecId,
                E2E_Chat__c = 'initiated auto');
        insert testOppo;

        LiveChatVisitor testVisitor = new LiveChatVisitor();
        insert testVisitor;

        LiveChatTranscript testChat = new LiveChatTranscript(
                LiveChatVisitorId = testVisitor.Id,
                Opportunity__c = testOppo.Id,
                VisitorMessageCount = 0,
                OperatorMessageCount = 0,
                Mode_of_initialization__c = 'automatical',
                Status = 'Completed'
        );
        insert testChat;
        update testChat;

        Test.stopTest();
        Opportunity testOppOld = [SELECT Id, E2E_Chat__c, E2E_Visitor_Message_Count__c FROM Opportunity WHERE Id = :testOppo.Id];
        System.assertEquals('auto-not replied', testOppOld.E2E_Chat__c);
        System.assertEquals(0, testOppOld.E2E_Visitor_Message_Count__c);
    }

    @isTest
    public static void updateE2EChatFieldsIfChatAutomatical2Test(){
        Test.startTest();
        String accRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');
        String euroshellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');

        Account account = new Account(
                Name = 'AccountTestChat3',
                AccountSource = 'ABVP',
                BillingCountry = 'Germany',
                Type = 'Customer',
                Gesellschaftsform__c = 'AG',
                Beschaeftigte__c = '1-4',
                RecordTypeId = accRecId);
        insert account;

        Opportunity testOppo = new Opportunity(
                Name = 'OpportunityTestChat3',
                AccountId = account.Id,
                Sec_Channel__c = 'JITB',
                LeadSource = 'ABVP',
                Type = 'Existing Business',
                StageName = 'Prospecting',
                Number_of_cars__c = 1,
                Number_of_trucks__c = 1,
                Total_number_of_vehicles__c = 2,
                Gasoline_consumption_l_month__c = 10,
                Diesel_consumption_l_month__c = 10,
                Total_consumption_l_month__c = 20,
                Number_of_Cards__c = 1,
                Derzeitige_Zahlungsmethode__c = 'Stationskarte',
                CloseDate = Date.today() - 1,
                RecordTypeId = euroshellRecId,
                E2E_Chat__c = 'initiated auto',
                E2E_Visitor_Message_Count__c = 1,
                E2E_Agent_Message_Count__c = 1);
        insert testOppo;

        LiveChatVisitor testVisitor = new LiveChatVisitor();
        insert testVisitor;

        LiveChatTranscript testChat = new LiveChatTranscript(
                LiveChatVisitorId = testVisitor.Id,
                Opportunity__c = testOppo.Id,
                VisitorMessageCount = 3,
                OperatorMessageCount = 5,
                Mode_of_initialization__c = 'automatical',
                Status = 'Completed'
        );
        insert testChat;
        update testChat;
        Test.stopTest();
        Opportunity testOppOld = [SELECT Id, E2E_Chat__c, E2E_Visitor_Message_Count__c FROM Opportunity WHERE Id = :testOppo.Id];
        System.assertEquals('auto-replied', testOppOld.E2E_Chat__c);
        System.assertEquals(3, testOppOld.E2E_Visitor_Message_Count__c);
    }

    @isTest
    public static void testSetTranscriptLookups() {
        String accRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');
        String contRecId = GlobalUtils.returnRecordTypeId('Contact', 'Contact layout');
        String erpRecId = GlobalUtils.returnRecordTypeId('ERP__c', 'CCS');

        Account testAcccount = new Account(
            Name = 'AccountTestChat1',
            AccountSource = 'ABVP',
            Type = 'Customer',
            BillingCountry = 'Germany',
            Gesellschaftsform__c = 'AG',
            Beschaeftigte__c = '1-4',
            RecordTypeId = accRecId
        );
        insert testAcccount;

        Contact testContact = new Contact(
            RecordTypeId = contRecid,
            AccountId = testAcccount.Id,
            LastName = 'testContact',
            Email = 'test@cont.act'
        );
        insert testContact;

        ERP__c testErp = new ERP__c(
            RecordTypeId = erpRecId,
            Name = 'testErp',
            Account__c = testAcccount.Id
        );
        insert testErp;

        LiveChatVisitor testVisitor = new LiveChatVisitor();
        insert testVisitor;

        LiveChatTranscript testChat = new LiveChatTranscript(
            LiveChatVisitorId = testVisitor.Id,
            VisitorMessageCount = 0,
            OperatorMessageCount = 0,
            Mode_of_initialization__c = 'automatical'
        );
        insert testChat;

        Test.startTest();
        testChat.ContactId = testContact.Id;
        update testChat;
        Test.stopTest();

        LiveChatTranscript updatedTranscript = [
            SELECT  AccountId,
                    GFN__c
            FROM    LiveChatTranscript
            WHERE   Id =: testChat.Id
        ];

        System.assertEquals(testAcccount.Id, updatedTranscript.AccountId);
        System.assertEquals(testErp.Id, updatedTranscript.GFN__c);
    }

}