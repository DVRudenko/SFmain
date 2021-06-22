@isTest
public with sharing class E2EFormRuDataTestFactory {
    public static String INN = '1111111111';
    public static String email = 'test@domovoi.ru';
    public static String phone = '+79265444341';

    public static void initPagesStructure() {
        E2EFormRuTestUtils.createLongFormRU();
        E2EFormRuTestUtils.createContactDetailsStep();
        E2EFormRuTestUtils.createCompanyInformationStep();
        E2EFormRuTestUtils.createOrderStep();
        E2EFormRuTestUtils.createLegalDetailsStep();
        E2EFormRuTestUtils.createPaymentDetailsStep();
        E2EFormRuTestUtils.createCongratulationsStep();
    }

    public static void initE2EFormParamsData(E2EFormParams formParams) {
        formParams.sparkId = 123456;
        formParams.postCodeSpark = '123456';
        formParams.citySpark = 'Moscow';
        formParams.streetSpark = 'Lenina';
        formParams.buildingSpark = '2';
        formParams.housingSpark = '3';
        formParams.blockSpark = '';
        formParams.roomSpark = '';
        formParams.regionSpark = 'Moscow region';
        formParams.deviceType = 'Desktop';
        formParams.ipAddress = '192.168.1.2';

        // SoleProprietor
        formParams.isSoleProprietor = false;
        formParams.soleProprietorFio = 'Lebedev Ivan Nikola';
        formParams.ogrnipSpark = '231111111';
        formParams.registrationDateSpark = '2014-15-15T00:00:00.000';
        formParams.mainCompanyFullNameSpark = 'ИП Lebedev';

        // legal person
        formParams.executiveFio = 'Lebedev Ivan Nikola';
        formParams.okpoSpark = '333333333';
        formParams.normName = 'Ромашка Inc, ОАО';
        formParams.ogrnSpark = '45634563456';
        formParams.kppSpark = '43523456456';

        // contract
        formParams.contractPrefix = '4';
        formParams.contractCounter = '171';

        // bank info
        formParams.bankNameShort = 'Сбербанк';
        formParams.bankBic = '56435634';
        formParams.bankTown = 'Moscow';
        formParams.bankAddress = 'Vavilova street';

        // scoring
        formParams.scoringDecisionCode = '0';
        formParams.scoringDecision = 'Ok';
        formParams.scoringDate = System.Today();
        formParams.verifiedDecisionCode = '3';
        formParams.opportunityLostReason = 'Test Reason';

        formParams.promocodeName = '7E10';
        formParams.product = 'PetrolPlus_Rover';
        formParams.promocodeIdInTransit = '112';
        formParams.requestNumMZK = '123456';
        formParams.transitContId = '3452345234512341234';

        formParams.businessProcess = GlobalUtils.BusinessProcessType.E2EClassic.name();
    }

    public static void initContentMap(Map<String, LongFormPage> pagesMap) {
        pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value = 'Test Company Name';
        pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '1111111111';
        pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value = 'FALSE';

        pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').value = '1137847243028';
        pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value = '1137847243028';
        pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value = '43523456456';
        pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value = '27464154';
        pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value = 'йцукен';
        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value = 'Ivanov Ivan Ivanovich';
        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value = 'Decision maker';
        pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').value = 'Pertova Maria Ivanovna';
        pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value = 'test@test.ru';
        pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT PHONE').elementItemsMap.get('DEFAULT VALUE').value = '+7 999 111 22 22';

        // legal address
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value = 'г. Санкт-Петербург';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value = 'ул. Свеаборгская';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value = ', дом 4, литера А';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = '';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value = '196105';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value = 'г. Санкт-Петербург';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').value = 'Russia';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = 'улица Пушкина, дом Колотушкина';

        // postal address
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').value = 'г. Санкт-Петербург';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').value = 'ул. Свеаборгская';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value = ', дом 10, литера А';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value = '';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').value = '196105';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').value = 'Russia';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STATE').value = '';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = 'улица Пушкина, дом Колотушкина';

        pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value = '44444444444444444444';
        pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value = 'ПАО СБЕРБАНК';
        pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value = '044525235';
        pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value = '30101810400000020225';
        pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value = '2000';

        // phone and email
        pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value = '+7 925 651 31 27';
        pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value = 'test@test.ru';
        pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value = 'TRUE';

        // order
        pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value = 'Оптимальный';
        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value = '1OPTIMAL_CARDS';
        pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value = '1';
        pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value = '7E10';
        pagesMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value = 'TRUE';
        pagesMap.get('ORDER')
            .fields.get('GIFT LIST')
            .elementItemsMap.get('LIST')
            .value = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления';
    }

    public static Transit_Contract_Type_Mapping__c createTransitContractTypeMapping(Decimal creditPeriod, Decimal contractType) {
        Transit_Contract_Type_Mapping__c transitContractTypeMapping = new Transit_Contract_Type_Mapping__c();
        transitContractTypeMapping.Name = 'test';
        transitContractTypeMapping.Credit_Period__c = creditPeriod;
        transitContractTypeMapping.Contract_Type__c = contractType;
        
        return transitContractTypeMapping;
    }
}