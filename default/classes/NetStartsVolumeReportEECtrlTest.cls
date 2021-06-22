@isTest
public class NetStartsVolumeReportEECtrlTest {

    public static User user;

    public static void initData() {
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'
        ];

        UserRole ur1 = ([
                SELECT Id
                FROM UserRole
                WHERE Name = 'PPR_Fleetcor'
                LIMIT 1
        ]);

        UserRole ur2 = ([
                SELECT Id
                FROM UserRole
                WHERE Name = 'PPR SME'
                LIMIT 1
        ]);

        user = new User(
                Username = 'utesttest1@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'ut1@fl',
                Email = 'ut1@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'utest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                UserRoleId = ur1.Id
        );
        insert user;

        User user2 = new User(
                Username = 'utesttest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'ut2@fl',
                Email = 'utest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'utest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                UserRoleId = ur2.Id
        );
        insert user2;

        System.runAs(user2) {
            Account account = new Account(
                    Name = 'test',
                    BillingCountry = 'Russia',
                    BillingCountryCode = 'RU',
                    OwnerId = user.Id
            );
            insert account;

            Opportunity opportunity = new Opportunity(
                    Name = 'test',
                    StageName = 'Moved to start',
                    CloseDate = Date.today(),
                    Angebotsdauer__c = '3 months',
                    Starts_Rep__c = user.Id,
                    AccountId = account.Id,
                    Transit_ID__c = '123123123123',
                    PPR_Transit_Expected_Volume__c = 1000,
                    Number_Business_CARD__c = 2,
                    PPR_Transit_Number_of_cards__c = 2,
                    Projected_Liters_weekly__c = 20
            );
            insert opportunity;

            List<Starts__c> starts = new List<Starts__c>();
            Integer k;
            for (k = 1; k <= 10; k++) {
                Starts__c start = new Starts__c(
                        Account__c = account.Id,
                        Opportunity__c = opportunity.Id,
                        client_week_number__c = k,
                        volume__c = k + 1,
                        starts__c = k + 2,
                        Transit_ID__c = '234234234' + k
                );
                starts.add(start);
            }
            insert starts;
        }
    }

    @isTest
    public static void testReportApi() {
        initData();

        System.runAs(user) {
            NetStartsVolumeReportEECtrl controller = new NetStartsVolumeReportEECtrl();
            PageReference pageRef = Page.NetStartsVolumeReportEE;
            Test.setCurrentPage(pageRef);

            System.assertNotEquals('', controller.reportApi.labelTranslateJson);
            System.assertNotEquals('', controller.reportApi.reportFieldsJson);
        }
    }

    @isTest
    public static void testPagination() {
        initData();

        System.runAs(user) {
            NetStartsVolumeReportEECtrl controller = new NetStartsVolumeReportEECtrl();
            PageReference pageRef = Page.NetStartsVolumeReportEE;
            Test.setCurrentPage(pageRef);

            controller.reportApi.next();
            controller.reportApi.previous();
            controller.reportApi.first();
            controller.reportApi.last();

            System.assertEquals(false, controller.reportApi.hasNext);
            System.assertEquals(false, controller.reportApi.hasPrevious);
        }
    }

    @isTest
    public static void testSelector() {
        initData();

        System.runAs(user) {
            NetStartsVolumeReportEECtrl controller = new NetStartsVolumeReportEECtrl();
            PageReference pageRef = Page.NetStartsVolumeReportEE;
            Test.setCurrentPage(pageRef);

            pageRef.getParameters().put('filterParams', '{"country":["Russia"],"dateFrom":' + '"2018-3-6","dateTo":"2018-3-6"}');
            controller.passFilterParams();

            System.assertNotEquals('', controller.reportApi.selectTable);
        }
    }

    @isTest
    public static void testHtmlGenerator() {
        initData();

        Test.startTest();
        System.runAs(user) {
            NetStartsVolumeReportEECtrl controller = new NetStartsVolumeReportEECtrl();
            PageReference pageRef = Page.NetStartsVolumeReportEE;
            Test.setCurrentPage(pageRef);
            controller.reportApi.getHtmlDataTable();
        }
        Test.stopTest();
    }

    @isTest
    public static void testSendExcel() {
        initData();

        Test.startTest();
        System.runAs(user) {
            NetStartsVolumeReportEECtrl controller = new NetStartsVolumeReportEECtrl();
            PageReference pageRef = Page.NetStartsVolumeReportEE;
            Test.setCurrentPage(pageRef);
            controller.reportApi.sendExcelReportToEmail();
        }
        Test.stopTest();
    }

    @isTest
    public static void testSendCSV() {
        initData();

        Test.startTest();
        System.runAs(user) {
            NetStartsVolumeReportEECtrl controller = new NetStartsVolumeReportEECtrl();
            PageReference pageRef = Page.NetStartsVolumeReportEE;
            Test.setCurrentPage(pageRef);
            controller.reportApi.sendCSVReportToEmail();
        }
        Test.stopTest();
    }

    @isTest
    public static void testProcessingData() {
        initData();

        Test.startTest();
        System.runAs(user) {
            NetStartVolumeReportSettings reportSettings = new NetStartVolumeReportSettings(
                    NetStartVolumeReportSettings.BusinessType.EastEurope,
                    NetStartVolumeReportSettings.ReportType.Onboarding
            );

            NetStartVolumeDataProcessingInterface dataProcessing = new NetStartsVolumeDataProcessing(
                    NetStartsVolumeFilterGenerator.resolverFilters(new Map<String, List<Object>>(), reportSettings.defaultFilters),
                    reportSettings.userRoleMap,
                    reportSettings.userMap,
                    reportSettings.netStartsWeeksCount,
                    reportSettings.volumeWeeksCount,
                    reportSettings.weeksCount
            );

            ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(dataProcessing.getSoqlRequest()));
            setCon.setPageSize(200);

            dataProcessing.initTotalData();
            dataProcessing.updateFilters('');
            dataProcessing.processingData(setCon.getRecords());
        }
        Test.stopTest();
    }


}