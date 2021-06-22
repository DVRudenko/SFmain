@isTest
public class SharingLeadControllerTest {

    public static Lead newlead;
    public static Task newTask;


    public static void init() {
        createCustomSettings();

        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'
        ];

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;
        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;


        RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Lead' AND
                Name = 'Russian Sales'
                LIMIT 1
        ];

        newlead = new Lead(
                OwnerId = user.Id,
                LastName = 'Test',
                RecordTypeId = rt.Id,
                Company = 'Test',
                Country = 'Russia',
                Status = 'Open',
                Email = 'test@test.com',
                Quali_Status__c = 'test',
                Salutation = 'Herr',
                Anzahl_der_Fahrzeuge__c = 2,
                Region__c = 'Кировская область',
                Send_SEPA_approval_link__c = true,
                Branche_NACE__c = 'Apotheken - 4773',
                INN__c = '1234567891');
        insert newlead;

        newTask = new Task(
                Subject = 'Other',
                Priority = 'Normal',
                Status = 'In Progress',
                WhoId = newlead.Id,
                ActivityDate = Date.today());
        insert newTask;

        LeadHistory createHistory = new LeadHistory(
                LeadId = newlead.Id,
                Field = 'created'
        );
        insert createHistory;

        LeadHistory convertHistory = new LeadHistory(
                LeadId = newlead.Id,
                Field = 'leadConverted'
        );
        insert convertHistory;

    }

    @isTest
    public static void historyWithConvertedTest() {
        init();

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(newlead.id);
        LeadStatus convertStatus = [
                SELECT ApiName, IsConverted, MasterLabel, SystemModstamp
                FROM LeadStatus
                WHERE IsConverted = TRUE
                AND MasterLabel = 'QUALIFIED - Convert to Opportunity'
                LIMIT 1
        ];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(newlead);
        SharingLeadController sharingLeadController = new SharingLeadController(sc);
        Test.stopTest();

        System.assert(sharingLeadController.lead != null);
        System.assert(sharingLeadController.leadHistory.size() == 3);
    }

    @isTest
    public static void historyWithOutConvertedTest() {
        init();

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(newlead);
        SharingLeadController sharingLeadController = new SharingLeadController(sc);
        Test.stopTest();

        System.assert(sharingLeadController.lead != null);
        System.assert(sharingLeadController.leadHistory.size() == 2);
    }

    @isTest(SeeAllData=true)
    public static void historyWithRealData() {
        List<Id> leadIds = new List<Id>();
        for (LeadHistory history : [SELECT LeadId FROM LeadHistory WHERE LeadId != null LIMIT 2]) {
            leadIds.add(history.LeadId);
        }
        List<HistoryUtils.ObjectHistoryLine> listHistory = new List<HistoryUtils.ObjectHistoryLine>();

        Test.startTest();
        HistoryUtils historyUtils = new HistoryUtils();
        for (Id leadId : leadIds) {
            listHistory.addAll(historyUtils.getObjectHistory(leadId));
        }
        Test.stopTest();

        System.assert(!listHistory.isEmpty(), 'Did not give lead history');
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;

        Profile sysAdmin = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Fleetcor_Profile_Info_Settings__c apiOnlySettings = new Fleetcor_Profile_Info_Settings__c(
                Name = sysAdmin.Name,
                ProfileId__c = sysAdmin.Id);
        insert apiOnlySettings;
    }
}