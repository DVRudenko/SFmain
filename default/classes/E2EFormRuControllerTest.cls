@IsTest
public with sharing class E2EFormRuControllerTest {
    private static E2EFormRuCtrl ctrl;
    private static String companySparkInfoJson = '{ "sparkID": 9560558, "inn": "6670429075", "ogrn": "1146670028350", "okpo": "44138461", "fullName": "ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ ТУ ПАК ЖИВ", "address": "Свердловская обл, г. Екатеринбург, ул. Ботаническая, д. 19 офис 75", "industry": "Торговля розничная чаем, кофе, какао в специализированных магазинах", "regionCode": null, "regionName": "Свердловская область", "manager": " Чухланцев Павел Вячеславович", "okopfname": "Общества с ограниченной ответственностью", "extendedReport": { "sparkID": 9560558, "companyType": 1, "status": { "date": "2019-06-13T21:00:00.000+0000", "type": "Действующее", "code": 24 }, "isActing": "true", "dateFirstReg": "2014-10-13T21:00:00.000+0000", "shortNameRus": "ООО ТУ ПАК ЖИВ", "shortNameEn": "OOO TU PAK ZHIV", "fullNameRus": "ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ ТУ ПАК ЖИВ", "normName": "ТУ ПАК ЖИВ, ООО", "guid": "954A5D8546614FAFAE2C6DF8755940A3", "inn": "6670429075", "kpp": "667001001", "ogrn": "1146670028350", "okpo": "44138461", "bik": null, "okato": { "code": "65401373000", "regionName": "Свердловская область", "regionCode": 65 }, "oktmo": { "code": "65701000001" }, "okogu": { "code": "4210014", "name": "Организации, учрежденные юридическими лицами или гражданами, или юридическими лицами и гражданами совместно" }, "okfs": { "code": "16", "name": "Частная собственность" }, "okopf": { "code": "65", "name": "Общества с ограниченной ответственностью", "codeNew": "12300" }, "charterCapital": "10000", "leaderList": { "leader": [ { "actualDate": "2014-10-13T21:00:00.000+0000", "fio": "Чухланцев Павел Вячеславович", "position": "директор", "inn": "663005160505" } ] }, "legalAddresses": { "address": { "postCode": "620137", "address": "Свердловская обл, г. Екатеринбург, ул. Ботаническая, д. 19 офис 75", "region": "Свердловская обл.", "rayon": null, "city": "г. Екатеринбург", "streetname": "ул. Ботаническая", "buildingnumber": "дом 19", "fiasGUID": "1b7c4d9d-0b2c-4f37-b39b-357a3d754753", "fiasCode": "660000010000000016500000000", "fiasRegion": "66", "fiasArea": "000", "fiasCity": "001", "fiasPlace": "000", "fiasPlan": "0000", "fiasStreet": "0165", "actualDate": "2018-11-20T21:00:00.000+0000", "housing": null, "block": null, "room": "офис 75", "businessCenterName": null } }, "email": null, "www": null, "workersRange": "0 .. 5", "egrpoincluded": "true", "fcsmcode": null } }';
    private static String soleProprietorInfoJson = '{ "sparkID": 33784591, "status": { "isActing": true, "text": "Действующее", "code": 24, "date": "2004-12-03T21:00:00.000+0000" }, "dateReg": "2004-12-03T21:00:00.000+0000", "fullNameRus": "Михайлова Наталья Александровна", "inn": "550408324470", "ogrnip": "304550733900043", "okpo": "0119951444", "okato": { "code": "52401382000", "regionName": "Омская область", "regionCode": 52 }, "birthDate": "1967-09-25T21:00:00.000+0000", "birthPlace": "Казахстан г. Кокчетав", "okvedlist": null }';
    private static String scoreDecision = '{"decision":1,"points":4,"sfrequestId":"';
    private static String leaderListJson = '{ "leader": [ { "actualDate": "2014-10-13T21:00:00.000+0000", "fio": "Чухланцев Павел Вячеславович", "position": "директор", "inn": "663005160505", "legalCapacityEndDate": null, "managementCompany": null, "managementCompanyINN": null, "disqualification": [] } ] }';
    private static String verificationDecision = '{"decision":0,"limitation":0,"blackListType":[],"sfrequestId":"';

    public static testMethod void testGoToCompanyDetailsOnly() {
        list<User> usr = E2EFormRuCtrlTestHelper.createUsers(1, 'PPR FieldTerritory_Call Center');
        User testUser = usr[0];
        System.runAs(testUser) {
            E2EFormRuCtrlTestHelper.setURLParams();
            E2EFormRuCtrlTestHelper.initCustomSettings();
            E2EFormRuCtrlTestHelper.initPagesStructure();
            System.currentPageReference().getParameters().put('cphone', '+79123456789');
            List<Account> testAcc = E2EFormRuCtrlTestHelper.createAccounts(1);
            E2EFormRuCtrlTestHelper.createOppr(testAcc[0].id, usr[0].id);
            ctrl = new E2EFormRuCtrl();
            ctrl.init();
            ctrl.goToCompanyDetails();
            ctrl.backToContactDetails();
            System.assertEquals(Apexpages.currentPage().getParameters().get('clientId'), ctrl.formParams.clientId);
        }
    }

    public static testMethod void testGoToOrderInformationOnly() {
        list<User> usr = E2EFormRuCtrlTestHelper.createUsers(1, 'PPR FieldTerritory_Call Center');
        User testUser = usr[0];
        System.runAs(testUser) {
            E2EFormRuCtrlTestHelper.setURLParams();
            E2EFormRuCtrlTestHelper.initCustomSettings();
            E2EFormRuCtrlTestHelper.initPagesStructure();
            List<Account> testAcc = E2EFormRuCtrlTestHelper.createAccounts(1);
            E2EFormRuCtrlTestHelper.createOppr(testAcc[0].id, usr[0].id);
            ctrl = new E2EFormRuCtrl();
            ctrl.init();
            ctrl.goToOrderInformation();
        }
    }

    public static testMethod void testGoToSummaryOrderOnly() {
        list<User> usr = E2EFormRuCtrlTestHelper.createUsers(1, 'PPR FieldTerritory_Call Center');
        User testUser = usr[0];
        System.runAs(testUser) {
            E2EFormRuCtrlTestHelper.setURLParams();
            E2EFormRuCtrlTestHelper.initCustomSettings();
            E2EFormRuCtrlTestHelper.initPagesStructure();
            List<Account> testAcc = E2EFormRuCtrlTestHelper.createAccounts(1);
            E2EFormRuCtrlTestHelper.createOppr(testAcc[0].id, usr[0].id);
            ctrl = new E2EFormRuCtrl();
            ctrl.init();
            ctrl.goToSummaryOrder();
        }
    }

    public static testMethod void testGoToLegalDetailsOnly() {
        list<User> usr = E2EFormRuCtrlTestHelper.createUsers(1, 'PPR FieldTerritory_Call Center');
        User testUser = usr[0];
        System.runAs(testUser) {
            E2EFormRuCtrlTestHelper.setURLParams();
            E2EFormRuCtrlTestHelper.initCustomSettings();
            E2EFormRuCtrlTestHelper.initPagesStructure();
            List<Account> testAcc = E2EFormRuCtrlTestHelper.createAccounts(1);
            E2EFormRuCtrlTestHelper.createOppr(testAcc[0].id, usr[0].id);
            ctrl = new E2EFormRuCtrl();
            ctrl.init();
            ctrl.goToLegalDetails();
        }
    }

    public static testMethod void testGoToPaymentDetailsOnly() {
        list<User> usr = E2EFormRuCtrlTestHelper.createUsers(1, 'PPR FieldTerritory_Call Center');
        User testUser = usr[0];
        System.runAs(testUser) {
            E2EFormRuCtrlTestHelper.setURLParams();
            E2EFormRuCtrlTestHelper.initCustomSettings();
            E2EFormRuCtrlTestHelper.initPagesStructure();
            List<Account> testAcc = E2EFormRuCtrlTestHelper.createAccounts(1);
            E2EFormRuCtrlTestHelper.createOppr(testAcc[0].id, usr[0].id);
            ctrl = new E2EFormRuCtrl();
            ctrl.init();
            ctrl.goToPaymentDetails();
        }
    }

    public static testMethod void testGoToCongratulationsrOnly() {
        list<User> usr = E2EFormRuCtrlTestHelper.createUsers(1, 'PPR FieldTerritory_Call Center');
        User testUser = usr[0];
        System.runAs(testUser) {
            E2EFormRuCtrlTestHelper.setURLParams();
            E2EFormRuCtrlTestHelper.initCustomSettings();
            E2EFormRuCtrlTestHelper.initPagesStructure();
            List<Account> testAcc = E2EFormRuCtrlTestHelper.createAccounts(1);
            E2EFormRuCtrlTestHelper.createOppr(testAcc[0].id, usr[0].id);
            ctrl = new E2EFormRuCtrl();
            ctrl.init();
            ctrl.goToCongratulations();
        }
    }

    @IsTest
    public static void testGoToCompanyDetailsAndBackToContactDetails() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();
        System.currentPageReference().getParameters().put('cphone', '+79123456789');
        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();
        ctrl.backToContactDetails();
        System.assertNotEquals(null, ctrl.currentPage);
        System.assertEquals(null, ctrl.product);
        System.assertEquals(null, E2EFormRuCtrl.companyInfoSpark);
        System.assertEquals(null, E2EFormRuCtrl.soleInfoSpark);
        System.assertEquals(null, ctrl.blackListDecision);
        System.assertEquals(null, ctrl.scoringPassed);
        System.assertEquals(null, E2EFormRuCtrl.scoringRefused);
    }

    @IsTest
    public static void testGoToOrderInformationAndBackToCompanyDetail() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '6670429075';
        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ООО "ТУ ПАК ЖИВ"';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '6';

        ctrl.backToCompanyInformation();
    }

    @IsTest
    public static void testGoToSummaryOrderAndBackToOrderInformation() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '6670429075';
        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ООО "ТУ ПАК ЖИВ"';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '6';
        ctrl.pagesContentMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления,Email-уведомления,Личный кабинет,Мобильное приложение для держателей карт,Полный пакет отчетных документов ,Круглосуточная линия поддержки для руководителей и держателей карт,Предупреждения о подозрительных операциях';

        ctrl.goToSummaryOrder();

        ctrl.backToOrderInformation();
    }

    @IsTest
    public static void testGoToLegalDetailsAndBackToSummaryOrder() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '6670429075';
        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ООО "ТУ ПАК ЖИВ"';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '6';
        ctrl.pagesContentMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления,Email-уведомления,Личный кабинет,Мобильное приложение для держателей карт,Полный пакет отчетных документов ,Круглосуточная линия поддержки для руководителей и держателей карт,Предупреждения о подозрительных операциях';

        ctrl.goToSummaryOrder();

        ctrl.goToLegalDetails();
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = '667001001';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = '1146670028350';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = '44138461';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value = 'test@test.ru';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value = 'кодовое слово';

        ctrl.returnDataSpark();

        ctrl.backToSummaryOrder();
    }

    @IsTest
    public static void testGoToLegalDetailsIP() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '550408324470';
        ctrl.pagesContentMap.get('COMPANY INFORMATION')
            .fields.get('ACCOUNT NAME')
            .elementItemsMap.get('DEFAULT VALUE')
            .value = 'Михайлова Наталья Александровна';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '6';
        ctrl.pagesContentMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления,Email-уведомления,Личный кабинет,Мобильное приложение для держателей карт,Полный пакет отчетных документов ,Круглосуточная линия поддержки для руководителей и держателей карт,Предупреждения о подозрительных операциях';

        ctrl.goToSummaryOrder();

        ctrl.goToLegalDetails();
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = '304550733900043';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = '0119951444';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value = 'test@test.ru';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value = 'кодовое слово';

        ctrl.returnDataSpark();
    }

    @IsTest
    public static void testGoToPaymentDetailsAndBackToLegalDetails() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '6670429075';
        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ООО "ТУ ПАК ЖИВ"';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '6';
        ctrl.pagesContentMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления,Email-уведомления,Личный кабинет,Мобильное приложение для держателей карт,Полный пакет отчетных документов ,Круглосуточная линия поддержки для руководителей и держателей карт,Предупреждения о подозрительных операциях';

        ctrl.goToSummaryOrder();

        ctrl.goToLegalDetails();
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = '667001001';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = '1146670028350';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = '44138461';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value = 'test@test.ru';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT PHONE').elementItemsMap.get('DEFAULT VALUE').value = '+7 999 111 22 22';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value = 'кодовое слово';

        Test.startTest();
        ctrl.goToPaymentDetails();

        ctrl.backToLegalDetails();
        Test.stopTest();

        System.assertEquals(
                ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT PHONE').elementItemsMap.get('DEFAULT VALUE').value,
                ctrl.formParams.personalOfficePhone
        );
        System.assertEquals(
                ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value,
                ctrl.formParams.emailForPersonalOffice
        );
    }

    @IsTest
    public static void testGoToCongratulationsWithManyCardsNotification() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '6670429075';
        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ООО "ТУ ПАК ЖИВ"';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '100';
        ctrl.pagesContentMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления,Email-уведомления,Личный кабинет,Мобильное приложение для держателей карт,Полный пакет отчетных документов ,Круглосуточная линия поддержки для руководителей и держателей карт,Предупреждения о подозрительных операциях';

        ctrl.goToSummaryOrder();

        ctrl.goToLegalDetails();
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = '667001001';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = '1146670028350';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = '44138461';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value = 'test@test.ru';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value = 'кодовое слово';

        Test.startTest();
        ctrl.goToPaymentDetails();
        ctrl.pagesContentMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ПАО СБЕРБАНК';
        ctrl.pagesContentMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value = '044525225';
        ctrl.pagesContentMap.get('PAYMENT DETAILS')
            .fields.get('CORR BANK ACCOUNT')
            .elementItemsMap.get('DEFAULT VALUE')
            .value = '30101810400000000225';
        ctrl.pagesContentMap.get('PAYMENT DETAILS')
            .fields.get('CHECKING ACCOUNT')
            .elementItemsMap.get('DEFAULT VALUE')
            .value = '11111111111111111111';

        ctrl.goToCongratulations();
        Test.stopTest();
    }

    @IsTest
    public static void testGoToCongratulationsWithManualEntryNotification() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '6670429075';
        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ООО "ТУ ПАК ЖИВ"';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '6';
        ctrl.pagesContentMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления,Email-уведомления,Личный кабинет,Мобильное приложение для держателей карт,Полный пакет отчетных документов ,Круглосуточная линия поддержки для руководителей и держателей карт,Предупреждения о подозрительных операциях';

        ctrl.goToSummaryOrder();

        ctrl.goToLegalDetails();
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = '667001001';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = '1146670028350';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = '44138461';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value = 'test@test.ru';
        ctrl.pagesContentMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value = 'кодовое слово';

        Test.startTest();
        ctrl.goToPaymentDetails();
        ctrl.pagesContentMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ПАО СБЕРБАНК';
        ctrl.pagesContentMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value = '044525225';
        ctrl.pagesContentMap.get('PAYMENT DETAILS')
            .fields.get('CORR BANK ACCOUNT')
            .elementItemsMap.get('DEFAULT VALUE')
            .value = '30101810400000000225';
        ctrl.pagesContentMap.get('PAYMENT DETAILS')
            .fields.get('CHECKING ACCOUNT')
            .elementItemsMap.get('DEFAULT VALUE')
            .value = '11111111111111111111';

        ctrl.formParams.isManualEntry = true;

        ctrl.goToCongratulations();
        Test.stopTest();
    }

    @IsTest
    public static void testGoToCompanyDetailsException() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();
        ctrl.pagesContentMap = null;
        ctrl.goToCompanyDetails();
    }

    @IsTest
    public static void testMidStepsExceptions() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();
        ctrl.goToOrderInformation();
        ctrl.goToSummaryOrder();
        ctrl.goToLegalDetails();
        ctrl.goToPaymentDetails();
    }

    @IsTest
    public static void testGoToCongratulationException() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();
        ctrl.goToCongratulations();
    }

    @IsTest
    public static void testGoBackExceptionsFirstSteps() {
        ctrl = new E2EFormRuCtrl();

        ctrl.backToContactDetails();
        ctrl.backToCompanyInformation();
    }

    @IsTest
    public static void testGoBackExceptionsOtherSteps() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();
        ctrl.goToCompanyDetails();

        ctrl.pagesContentMap = null;
        ctrl.backToLegalDetails();
        ctrl.backToSummaryOrder();
        ctrl.backToOrderInformation();
    }

    @IsTest
    public static void testRemoteActions() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();
        ctrl.goToCompanyDetails();

        // String body = '{"decision":1,"points":4,"sfrequestId":"' + ctrl.opportunityId + '"}';
        // SingleRequestMock mockGetScore = new SingleRequestMock(200, 'Complete', body, null);
        // Test.setMock(HttpCalloutMock.class, mockGetScore);
        // E2EFormRuCtrl.getScore(false, '6670429075', '9560558', ctrl.opportunityId, verificationDecision + ctrl.opportunityId + '"}');
        String body = '[{"sparkID":9560558,"inn":"6670429075","ogrn":"1146670028350","okpo":"44138461","fullName":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \"ТУ ПАК ЖИВ\"","address":"Свердловская обл, г. Екатеринбург, ул. Ботаническая, д. 19 офис 75","industry":"Торговля розничная чаем, кофе, какао в специализированных магазинах","regionCode":null,"regionName":"Свердловская область","manager":"Чухланцев Павел Вячеславович","okopfname":"Общества с ограниченной ответственностью","okopfcode":12300}]';
        SingleRequestMock mockCompanyList = new SingleRequestMock(200, 'Complete', body, null);

        Test.setMock(HttpCalloutMock.class, mockCompanyList);
        E2EFormRuCtrl.remoteGetCompanySparkInfoByInn('6670429075');

        E2EFormRuCtrl.remoteGetEntrepreneurShortReportByInn('6670429075');
        E2EFormRuCtrl.remoteUpdateCompanySparkInfo(companySparkInfoJson, ctrl.formDataId, ctrl.opportunityId, '6670429075');
        E2EFormRuCtrl.remoteUpdateEntrepreneurShortReport(soleProprietorInfoJson, ctrl.formDataId);
        E2EFormRuCtrl.updateScoreDecision(ctrl.formDataId, ctrl.opportunityId, scoreDecision + ctrl.opportunityId + '"}');
        E2EFormRuCtrl.remoteCreateExecutiveEmployee(ctrl.formDataId, leaderListJson);

        E2EFormRuCtrl.updateVerifiedDecision(ctrl.formDataId, ctrl.opportunityId, '6670429075', verificationDecision + ctrl.opportunityId + '"}');

        // String body = '{"decision":0,"limitation":0,"blackListType":[],"sfrequestId":"' + ctrl.opportunityId + '"}'
        // SingleRequestMock mockChekCompany = new SingleRequestMock(200, 'Complete', body, null);
        // Test.setMock(HttpCalloutMock.class, mockChekCompany);
        // E2EFormRuCtrl.checkCompany(false, '6670429075', '9560558', ctrl.opportunityId);
        E2EFormRuCtrl.checkCompany(false, '', '', ctrl.opportunityId);
    }

    @IsTest
    public static void testParamMethods() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.setDeviceType();

        ctrl.printAgreement();
        ctrl.closeModal();
        ctrl.showPreAgreement();
        ctrl.showPersonalInfoPolicy();
        ctrl.showSalesPromotion();
        ctrl.showWarningBeforeGoToCongratulations();
        ctrl.activateViewContract();
        ctrl.activatePreviewContract();

        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '6670429075';
        ctrl.pagesContentMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ООО "ТУ ПАК ЖИВ"';
        ctrl.goToOrderInformation();
        ctrl.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').value = E2EFormRuCtrlTestHelper.createPromocodes().Product_Name__c;
        ctrl.checkPromocode();

        Map<String, LongFormTariff> msl = ctrl.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(ctrl.offer).products.get(ctrl.formParams.productSplitTesting).tariffs;
        for (String tariffName : msl.keySet()) {
            LongFormTariff tariff = msl.get(tariffName);
            tariff.showTariff  = true;
        }
        ctrl.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(ctrl.offer).products.get(ctrl.formParams.productSplitTesting).tariffs = msl;

        ctrl.getTariffsOnCards();
        ctrl.setTariff();

        System.assertEquals(5, ctrl.tariffs.size());

        ctrl.pagesContentMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления,Email-уведомления,Личный кабинет,Мобильное приложение для держателей карт,Полный пакет отчетных документов ,Круглосуточная линия поддержки для руководителей и держателей карт,Предупреждения о подозрительных операциях';
        ctrl.setProduct();

        ctrl.pagesContentMap.get('ORDER')
            .fields.get('PROMOCODE DESCRIPTION')
            .elementItemsMap.get('PROMOCODE ADDITIONAL FIELD')
            .value = '«Роснефть», «Башнефть», "ТНК»@156;';
        ctrl.setPromocodeItem();

        String testContractContent = ctrl.previewContractContent;
    }

    @IsTest
    public static void testOther() {
        E2EFormRuCtrlTestHelper.setURLParams();
        E2EFormRuCtrlTestHelper.initCustomSettings();
        E2EFormRuCtrlTestHelper.initPagesStructure();

        ctrl = new E2EFormRuCtrl();
        ctrl.init();

        ctrl.sendExceptionEmail('method name', new GlobalException('exception'));
        E2EFormRuCtrl.getScore(false, '6670429075', '9560558', ctrl.opportunityId, verificationDecision + ctrl.opportunityId + '"}');
        ctrl.createMzkProposal();
    }

    @IsTest
    public static void testSetClientIdMethods() {
        ApexPages.currentPage().getParameters().put('clientId','');
        ctrl = new E2EFormRuCtrl();
        ctrl.init();
        ApexPages.currentPage().getParameters().put('clientId','123456789.123456789');
        ctrl.setClientId();
        System.assertNotEquals(null, ctrl.formParams.clientId);
    }

    @IsTest
    public static void testSetLeadIdMethods() {
        ApexPages.currentPage().getParameters().put('leadId', null);
        ctrl = new E2EFormRuCtrl();
        ctrl.init();
        System.assertEquals(null, ctrl.formParams.leadId);

        ApexPages.currentPage().getParameters().put('leadId','00Q3Y00001EsBIiQWE');
        ctrl.init();
        System.assertNotEquals(null, ctrl.formParams.leadId);
        System.assertEquals('00Q3Y00001EsBIiQWE', ctrl.formParams.leadId);
    }

    //TODO: getReportIdsForContract - mock public ReportResponseData getReportIdsFromCreditFactory(ReportRequestData requestData) {
}
