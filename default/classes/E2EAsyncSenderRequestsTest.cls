@isTest private class E2EAsyncSenderRequestsTest {

    @isTest
    static void testMethod1() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuDataTestFactory.initPagesStructure();
        Map<String, LongFormPage> pagesContentMap = new  Map<String, LongFormPage>();
        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        formService.collectContent('Russia','PaymentDetails',pagesContentMap, GlobalUtils.DeviceType.Desktop);
        pagesContentMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value = '123';

        Account account = E2EFormRuTestUtils.createAccount('123',system.today(),system.today());
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        E2EFormParams formParams = new E2EFormParams();
        formParams.sendToInbound = false;
        String source ='';

        Test.startTest();
        System.enqueueJob(new E2EAsyncSenderRequests(formData.Id, formParams, pagesContentMap, GlobalUtils.BusinessProcessType.E2EClassic));
        Test.stopTest();
    }

    @IsTest
    static void testAsyncCalloutsE2EProcess() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormRuTestUtils.initCustomSettings();

        Account account = E2EFormRuTestUtils.createAccount('1234567890',System.today(),System.today());
        account.Name = 'Test acc';
        account.Organization_Type__c = 'ООО';
        account.ShippingPostalCode = '123456';
        account.BillingPostalCode = '123456';
        account.ShippingStreet = 'ул Автомобилистов';
        account.KPP__c = 330401001;
        account.Checking_Account__c = '88794484848484848484';
        account.Code_Word__c = 'КОДВОРД';
        account.OKPO_ppr__c = '00288679';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.createDefaultFormData();
        formDataRecord.E2E_INN__c = account.INN__c;
        formDataRecord.E2E_Account_Id__c = account.Id;
        formDataRecord.E2E_Opportunity_Id__c = opportunity.Id;
        formDataRecord.E2E_Personal_Manager_srv__c = true;
        formDataRecord.E2E_Document_Delivery_srv__c = true;
        formDataRecord.E2E_Product_Id__c = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
        formDataRecord.E2E_Num_Cards__c = 1;
        formDataRecord.E2E_Tariff_Id__c = '1OPTIMAL_CARDS';
        formDataRecord.E2E_Scoring_Decision_Code__c = '0';
        formDataRecord.E2E_Overdraft_srv__c = true;
        formDataRecord.E2E_Code_Word__c = account.Code_Word__c;
        formDataRecord.E2E_Personal_Office_Email__c = 'test@test.te';
        formDataRecord.E2E_Product__c = 'Вездеход Online Оптимальный';
        formDataRecord.E2E_KPP__c = '330401001';
        formDataRecord.E2E_OGRN__c = '1033300200383';
        formDataRecord.E2E_OKPO__c = '00288679';
        formDataRecord.E2E_Legal_Address__c = 'Владимирская обл, г. Гусь-Хрустальный, проспект 50 Лет Советской Власти, д. 8';
        formDataRecord.E2E_Post_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        formDataRecord.E2E_Main_Company_Full_Name__c = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "ЛЕС РУК"';
        formDataRecord.E2E_Executive_Person__c = 'Фархатдинова Лиана Игоревна, генеральный директор';
        formDataRecord.E2E_Billing_Code__c = '123456';
        formDataRecord.E2E_Account_Short_Name__c = 'ГЛОБУС';
        formDataRecord.E2E_Prepay_Amount__c = '14892';
        formDataRecord.E2E_BIC__c = '044525974';
        formDataRecord.E2E_Bank__c = 'АО "ТИНЬКОФФ БАНК"';
        formDataRecord.E2E_Cor_Bank_Account__c = '13131313131341341341';
        formDataRecord.E2E_Bank_OKPO__c = '00288679';
        formDataRecord.E2E_Bank_Town__c = 'г Волжский';
        formDataRecord.E2E_Bank_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        insert formDataRecord;

        E2EFormParams formParams = new E2EFormParams();
        formParams.sendToInbound = false;
        formParams.prepayAmount = formDataRecord.E2E_Prepay_Amount__c;
        formParams.bankBic = formDataRecord.E2E_BIC__c;
        formParams.checkingAccount = account.Checking_Account__c;
        formParams.corBankAccount = formDataRecord.E2E_Cor_Bank_Account__c;
        formParams.bankNameShort = 'БАНК';
        formParams.transitManagerId = '1234567890QWERTYUIOPASDFGHJKLZXC';
        formParams.transitContId = '1234567890QWERTYUIOPASDFGHJKLZXC';
        formParams.requestNumMZK = '12345';

        String source ='';

        Test.startTest();
        System.enqueueJob(new E2EAsyncSenderRequests(formDataRecord.Id, formParams, null, GlobalUtils.BusinessProcessType.E2EBusiness));
        Test.stopTest();
    }

    @IsTest
    static void testAsyncCalloutsInbound() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormRuTestUtils.initCustomSettings();

        Account account = E2EFormRuTestUtils.createAccount('1234567890',System.today(),System.today());
        account.Name = 'Test acc';
        account.Organization_Type__c = 'ООО';
        account.ShippingPostalCode = '123456';
        account.BillingPostalCode = '123456';
        account.ShippingStreet = 'ул Автомобилистов';
        account.KPP__c = 330401001;
        account.Checking_Account__c = '88794484848484848484';
        account.Code_Word__c = 'КОДВОРД';
        account.OKPO_ppr__c = '00288679';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.createDefaultFormData();
        formDataRecord.E2E_INN__c = account.INN__c;
        formDataRecord.E2E_Account_Id__c = account.Id;
        formDataRecord.E2E_Opportunity_Id__c = opportunity.Id;
        formDataRecord.E2E_Personal_Manager_srv__c = true;
        formDataRecord.E2E_Document_Delivery_srv__c = true;
        formDataRecord.E2E_Product_Id__c = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
        formDataRecord.E2E_Num_Cards__c = 1;
        formDataRecord.E2E_Tariff_Id__c = '1OPTIMAL_CARDS';
        formDataRecord.E2E_Scoring_Decision_Code__c = '0';
        formDataRecord.E2E_Overdraft_srv__c = true;
        formDataRecord.E2E_Code_Word__c = account.Code_Word__c;
        formDataRecord.E2E_Personal_Office_Email__c = 'test@test.te';
        formDataRecord.E2E_Product__c = 'Вездеход Online Оптимальный';
        formDataRecord.E2E_KPP__c = '330401001';
        formDataRecord.E2E_OGRN__c = '1033300200383';
        formDataRecord.E2E_OKPO__c = '00288679';
        formDataRecord.E2E_Legal_Address__c = 'Владимирская обл, г. Гусь-Хрустальный, проспект 50 Лет Советской Власти, д. 8';
        formDataRecord.E2E_Post_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        formDataRecord.E2E_Main_Company_Full_Name__c = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "ЛЕС РУК"';
        formDataRecord.E2E_Executive_Person__c = 'Фархатдинова Лиана Игоревна, генеральный директор';
        formDataRecord.E2E_Billing_Code__c = '123456';
        formDataRecord.E2E_Account_Short_Name__c = 'ГЛОБУС';
        formDataRecord.E2E_Prepay_Amount__c = '14892';
        formDataRecord.E2E_BIC__c = '044525974';
        formDataRecord.E2E_Bank__c = 'АО "ТИНЬКОФФ БАНК"';
        formDataRecord.E2E_Cor_Bank_Account__c = '13131313131341341341';
        formDataRecord.E2E_Bank_OKPO__c = '00288679';
        formDataRecord.E2E_Bank_Town__c = 'г Волжский';
        formDataRecord.E2E_Bank_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        insert formDataRecord;

        E2EFormParams formParams = new E2EFormParams();
        formParams.sendToInbound = true;
        formParams.prepayAmount = formDataRecord.E2E_Prepay_Amount__c;
        formParams.bankBic = formDataRecord.E2E_BIC__c;
        formParams.checkingAccount = account.Checking_Account__c;
        formParams.corBankAccount = formDataRecord.E2E_Cor_Bank_Account__c;
        formParams.bankNameShort = 'БАНК';

        String source ='';

        E2EFormRuServiceImpl.isScoringTrue = true;

        Test.startTest();
        System.enqueueJob(new E2EAsyncSenderRequests(formDataRecord.Id, formParams, null, GlobalUtils.BusinessProcessType.E2EBusiness));
        Test.stopTest();
        if (Boolean.valueOf(CFUtils.getScoringSettings('active'))) {
            System.assertEquals(1, [SELECT Id FROM Credit_Factory_Report__c WHERE Opportunity__c = :formParams.opportunityId].size());
        }
    }
}
