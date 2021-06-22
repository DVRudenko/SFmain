/**
 * Created by pavel.bukarev on 02.08.2019.
 */

@IsTest
private class E2EMoveToStartCtrlTest {

    //проверки метода init()
    @IsTest
    public static void testInit() {
        User u = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(u) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunity.CategoryContract__c = 'МО';
            opportunity.StageName = 'Signing of a Contract';
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            test.startTest();
            ctrl.init();
            test.stopTest();
            System.assertEquals(false, ctrl.hasPageError, 'Error occurred on the page. hasPageError = false was expected.');
            System.assertEquals(false, ctrl.isStartButtonEnabled, 'button is available with current status'); //проверяем, что дошли до checkOpportunityStage
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, ctrl.formParams.creditDecision);

            Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
            report.RU_Client_Choice__c = true;
            insert report;
            ctrl.formParams.freeOverdraft = true;

            ctrl.init();
            System.assertEquals(String.valueOf(report.Id), ctrl.formParams.creditDecision);
            System.assertEquals(2, ctrl.creditDecisionList.size());
            System.assertEquals(false, ctrl.formParams.freeOverdraft);
            E2E_business_settings__c russianSetting = E2EMoveToStartDataTestFactory.createBusinessSetting(true);
            russianSetting.Company_age__c = 10;
            insert russianSetting;
            E2EBusiness_Free_Overdraft_Permission__c permissionSetting = E2EMoveToStartDataTestFactory.createFreeOverdraftPermissionSetting('Russian Call Center', 'PPR Telesales (mentor)');
            insert permissionSetting;
            E2EFormData__c formData = [SELECT Id FROM E2EFormData__c WHERE E2E_Opportunity_Id__c =: opportunity.Id];
            formData.E2E_Reg_Date__c = Datetime.now().addMonths(-12).format('dd.MM.yyyy');
            update formData;

            ctrl = new E2EMoveToStartCtrl();
            ctrl.init();
            System.assertEquals(3, ctrl.creditDecisionList.size());
            Boolean freeOverdraftInList = false;
            for (SelectOption creditOption: ctrl.creditDecisionList) {
                if (creditOption.getValue() == E2EMoveToStartService.FREE_OVERDRAFT) {
                    freeOverdraftInList = true;
                    break;
                }
            }
            System.assert(freeOverdraftInList);

            formData.E2E_Reg_Date__c = Datetime.now().addMonths(-4).format('dd.MM.yyyy');
            update formData;

            ctrl.init();
            System.assertEquals(2, ctrl.creditDecisionList.size());

            Boolean freeOverdraftNotInList = true;
            for (SelectOption creditOption: ctrl.creditDecisionList) {
                if (creditOption.getValue() == E2EMoveToStartService.FREE_OVERDRAFT) {
                    freeOverdraftNotInList = false;
                    break;
                }
            }
            System.assert(freeOverdraftNotInList);

            report.RU_Client_Choice__c = false;
            update report;
            ctrl.init();
            System.assertEquals(E2EMoveToStartService.WITHOUT_CREDIT, ctrl.formParams.creditDecision);
        }
    }
	
	//SF-1313
    @IsTest
    public static void testDeduplicationAccountsReanimated() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        E2EFormRuTestUtils.initCustomSettings();

        //аккаунт и прочие записи, с которыми будем работать
        Account account1 = E2EFormRuTestUtils.createDefaultAccount();
        account1.INN__c = '1111111111';
        insert account1;

        Opportunity opportunity1 = E2EFormRuTestUtils.createOpportunity(account1.Id);
        opportunity1.Promo_Code1__c = 'реанимация';
        insert opportunity1;

        E2EFormData__c formData1 = E2EFormRuTestUtils.createDefaultFormData();
        formData1.E2E_Account_Id__c = account1.Id;
        formData1.E2E_Opportunity_Id__c = opportunity1.Id;
        insert formData1;

        Contact contact1 = E2EFormRuTestUtils.createContact(account1.Id, '+78005553535', 'test@email.com');
        insert contact1;

        //аккаунт и прочие записи - "дубликаты"
        Account account2 = E2EFormRuTestUtils.createDefaultAccount();
        account2.INN__c = '1111111666';
        insert account2;

        Opportunity opportunity2 = E2EFormRuTestUtils.createOpportunity(account1.Id);
        insert opportunity2;

        E2EFormData__c formData2 = E2EFormRuTestUtils.createDefaultFormData();
        formData2.E2E_Account_Id__c = account1.Id;
        formData2.E2E_Opportunity_Id__c = opportunity2.Id;
        insert formData2;

        Contact contact2 = E2EFormRuTestUtils.createContact(account1.Id, '+78005553666', 'test@email.com');
        //insert contact2;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account1;
        ctrl.formData = formData1;
        ctrl.formDataId = formData1.Id;
        ctrl.oppty = opportunity1;
        ctrl.opportunityId = opportunity1.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account1.INN__c;
        ctrl.opportunityId = opportunity1.Id;
        ctrl.formParams.companyName = 'Ааааааааа!';
        ctrl.formParams.mainContactEmail = 'test@email.com';
        ctrl.opportunityId = opportunity1.Id;
        ctrl.formParams.creditDecision = E2EMoveToStartService.FREE_OVERDRAFT;
        ctrl.formParams.contactFullName = 'Владислав';

        insert new PublicEmailDomains__c(Name = 'email.com');

        Test.startTest();
        ctrl.moveToStart();
        Test.stopTest();

        System.assertNotEquals('Обнаружен дубль по email!', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary());

        formData1 = [SELECT Free_overdraft__c FROM E2EFormData__c WHERE Id = :formData1.Id];
        System.assert(formData1.Free_overdraft__c);
    }	

    @IsTest
    public static void testInitOppIdIsNull() {
        User u = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        System.runAs(u) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunity.CategoryContract__c = 'МО';
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', null);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            test.startTest();
            ctrl.init();
            test.stopTest();
            System.assertEquals(true, ctrl.hasPageError, 'Wrong error status on the page. hasPageError = true was expected.');
            System.assertEquals('Ошибка. Вы пытаетесь открыть страницу без указания Возможности.', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary(), 'Wrong error message.');

        }

    }

    @IsTest
    public static void testInitFormDataExist() {
        User u = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        System.runAs(u) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunity.CategoryContract__c = 'МО';
            opportunity.StageName = 'Signing of a Contract';
            opportunity.Virtual_cards__c = true;
            insert opportunity;

            E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
            formData.E2E_Opportunity_Id__c = opportunity.Id;
            insert formData;

            System.debug(opportunity.E2EFormRuData__r);

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            Test.startTest();
            ctrl.init();
            Test.stopTest();
            System.assertEquals(false, ctrl.hasPageError, 'Error occurred on the page. hasPageError = false was expected.');
            System.assertEquals(false, ctrl.isStartButtonEnabled, 'button is available with current status'); //проверяем, что дошли до checkOpportunityStage
            System.assertEquals(formData.Id, ctrl.formDataId, 'Form Data Id changed'); //проверям то же самое, что и в testInit(), но ещё добавляется проверка, того, что используется текущая form data, а не создаётся новая
            System.assertEquals(true, ctrl.formParams.virtualCards);
        }
    }

    @IsTest
    public static void testCheckOpportunityStage() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;
        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.isSaveButtonEnabled = true;

        String[] statuses = new String[]{
            GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead),
            GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations),
            GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Check_Credit_History),
            GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions),
                GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AwaitingPayment)
        };

        Opportunity qualifiedLeadOpp = createOpportunityWithStatus('opp', statuses[0], account.Id);
        Opportunity clientNegotiationsOpp = createOpportunityWithStatus('opp 1', statuses[1], account.Id);
        Opportunity checkCreditHistoryOpp = createOpportunityWithStatus('opp 2', statuses[2], account.Id);
        Opportunity agreementTermsAndConditionsOpp = createOpportunityWithStatus('opp 3', statuses[3], account.Id);
        Opportunity awaitingPaymentOpp = createOpportunityWithStatus('opp 4', statuses[4], account.Id);

        insert new List<Opportunity> {
            qualifiedLeadOpp, clientNegotiationsOpp, checkCreditHistoryOpp, agreementTermsAndConditionsOpp, awaitingPaymentOpp
        };

        Test.startTest();

        ctrl.checkOpportunityStage(agreementTermsAndConditionsOpp);
        System.assert(ctrl.isSaveButtonEnabled);
        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(0, messages.size());

        ctrl.checkOpportunityStage(qualifiedLeadOpp);
        System.assert(ctrl.isSaveButtonEnabled);
        messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        ApexPages.Message message = messages.get(0);
        System.assertEquals(String.format(E2EMoveToStartCtrl.MOVE_TO_START_WARNING_WRONG_STAGE, new List<String>{statuses[0]}), message.getDetail());

        ctrl.checkOpportunityStage(clientNegotiationsOpp);
        System.assert(ctrl.isSaveButtonEnabled);
        ctrl.checkOpportunityStage(checkCreditHistoryOpp);
        System.assert(ctrl.isSaveButtonEnabled);
        ctrl.checkOpportunityStage(awaitingPaymentOpp);
        System.assertEquals(false, ctrl.isSaveButtonEnabled);

        Test.stopTest();
    }


    //проверки CheckAccessibility
    @IsTest
    public static void testCheckAccessibilityBadUser() {
        User owner = createUser();
        User currUser = createUser2();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(currUser) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunity.CategoryContract__c = 'МО';
            opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions);
            insert opportunity;

            account.OwnerId = owner.Id;
            opportunity.OwnerId = owner.Id;
            update account;
            update opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            try {
                test.startTest();
                ctrl.init();
                test.stopTest();
            } catch (Exception e) {
                System.assertEquals('List has no rows for assignment to SObject', e.getMessage(), 'Пользователь, не владеющий записью, получил доступ к записи.');
            }
            System.assertNotEquals(account.INN__c, ctrl.formDataInn, 'form data inn changed');//тут проверяем, что метод init пошел по правильной "ветке"
        }
    }

    @IsTest
    public static void testCheckAccessibilityWrongContractCategory() {
        User owner = createUser();
        User currUser = createAdminUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(currUser) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            account.OwnerId = owner.Id;
            insert account;

            Opportunity opptWrongCategory = E2EFormRuTestUtils.createOpportunity(account.Id);
            opptWrongCategory.CategoryContract__c = 'О';
            opptWrongCategory.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions);
            opptWrongCategory.OwnerId = owner.Id;

            insert opptWrongCategory;

            ApexPages.currentPage().getParameters().put('Id', opptWrongCategory.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            test.startTest();
            ctrl.init();
            test.stopTest();
            System.assertNotEquals(account.INN__c, ctrl.formDataInn, 'form data inn changed');//тут проверяем, что метод init пошел по правильной "ветке"
            System.assertEquals('Договор не является мультиофертным.', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary(), 'Wrong error message.');
        }
    }

    @IsTest
    public static void testCheckAccessibilityNoContractCategory() {
        User owner = createUser();
        User currUser = createAdminUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(currUser) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            account.OwnerId = owner.Id;
            insert account;

            Opportunity opptNoCategory = E2EFormRuTestUtils.createOpportunity(account.Id);
            opptNoCategory.CategoryContract__c = null;
            opptNoCategory.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions);
            opptNoCategory.OwnerId = owner.Id;

            insert opptNoCategory;

            ApexPages.currentPage().getParameters().put('Id', opptNoCategory.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            test.startTest();
            ctrl.init();
            test.stopTest();
            System.assertNotEquals(account.INN__c, ctrl.formDataInn, 'form data inn changed');//тут проверяем, что метод init пошел по правильной "ветке"
            System.assertEquals('Договор не является мультиофертным.', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary(), 'Wrong error message.');
        }
    }

    @IsTest
    public static void testCheckAccessibilityNoTransitId() {
        User user = createUser();
        user.User_Transit_Id__c = null;
        update user;
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunity.CategoryContract__c = 'МО';
            opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            test.startTest();
            ctrl.init();
            test.stopTest();
            System.assertNotEquals(account.INN__c, ctrl.formDataInn, 'form data inn changed');//тут проверяем, что метод init пошел по правильной "ветке"
            System.assertEquals('Ошибка. У Вас некорректный transit GUID. Пожалуйста, обратитесь к администратору.', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary(), 'Wrong error message.');
        }
    }

    @IsTest
    public static void testCheckAccessibilityIncorrectTransitId() {
        User user = createUser();
        user.User_Transit_Id__c = '1111111111111111111111111111111'; //на один символ короче чем нужно
        update user;
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunity.CategoryContract__c = 'МО';
            opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            test.startTest();
            ctrl.init();
            test.stopTest();
            System.assertNotEquals(account.INN__c, ctrl.formDataInn, 'form data inn changed');//тут проверяем, что метод init пошел по правильной "ветке"
            System.assertEquals('Ошибка. У Вас некорректный transit GUID. Пожалуйста, обратитесь к администратору.', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary(), 'Wrong error message.');
        }
    }

    //проверки getPromocode
    @IsTest
    public static void testGetPromocodeNullCodes() {
        User user = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();

            Test.startTest();
            ctrl.getPromocode(null, null);
            //Ожидаемый результат: если в getPromocode передали null вместо корректного промокода, то метод "ничего не вернёт", т.е. promoCodeIdInTransit и promocodeName не будут заполнены.
            //Что и проверяется в assertEquals.
            //Если метод "что-то вернёт" (чего не должно быть), то assertEquals отображит соответствующее сообщение.
            System.assertEquals(null, ctrl.formParams.promoCodeIdInTransit, 'Для null промокода нашелся транзитовский ID');
            System.assertEquals('', ctrl.formParams.promocodeName, 'Для null промокода нашлось имя');

            System.assertEquals(null, ctrl.formParams.addPromoCodeIdInTransit, 'Для null дополнительного промокода нашелся транзитовский ID');
            System.assertEquals(null, ctrl.formParams.addPromocodeName, 'Для null дополнительного промокода нашлось имя');

            ctrl.getPromocode('', '');
            //Ожидаемый результат: если в getPromocode передали пустую строку вместо корректного промокода, то метод "ничего не вернёт", т.е. promoCodeIdInTransit и promocodeName не будут заполнены.
            //Что и проверяется в assertEquals.
            //Если метод "что-то вернёт" (чего не должно быть), то assertEquals отображит соответствующее сообщение.
            System.assertEquals(null, ctrl.formParams.promoCodeIdInTransit, 'Для пустого промокода нашелся транзитовский ID');
            System.assertEquals('', ctrl.formParams.promocodeName, 'Для пустого промокода нашлось имя');

            System.assertEquals(null, ctrl.formParams.addPromoCodeIdInTransit, 'Для пустого дополнительного промокода нашелся транзитовский ID');
            System.assertEquals(null, ctrl.formParams.addPromocodeName, 'Для пустого дополнительного промокода нашлось имя');
            Test.stopTest();
        }
    }

    @IsTest
    public static void testGetPromocodeBadCodes() {
        User user = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();

            Test.startTest();
            ctrl.getPromocode('0000000', '0000000');
            Test.stopTest();
            //Ожидаемый результат: если в getPromocode передали несуществующий промокод вместо корректного , то метод "ничего не вернёт", т.е. promoCodeIdInTransit и promocodeName не будут заполнены.
            //Что и проверяется в assertEquals.
            //Если метод "что-то вернёт" (чего не должно быть), то assertEquals отображит соответствующее сообщение.
            System.assertEquals(null, ctrl.formParams.promoCodeIdInTransit, 'Для несуществующего промокода нашелся транзитовский ID');
            System.assertEquals('', ctrl.formParams.promocodeName, 'Для несуществующего промокода нашлось имя');

            System.assertEquals(null, ctrl.formParams.addPromoCodeIdInTransit, 'Для несуществующего дополнительного промокода нашелся транзитовский ID');
            System.assertEquals(null, ctrl.formParams.addPromocodeName, 'Для несуществующего дополнительного промокода нашлось имя');
        }
    }

    @IsTest
    public static void testGetPromocodeOKCodes() {
        User user = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            insertSomePromocodes();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();

            Test.startTest();
            ctrl.getPromocode('7E10', 'test02');
            Test.stopTest();
            System.assertEquals('109', ctrl.formParams.promoCodeIdInTransit, 'Для корректного промокода был найден неправильный транзитовский ID');
            System.assertEquals('7E10', ctrl.formParams.promocodeName, 'Для корректного промокода не нашлось имя');

            System.assertEquals('666', ctrl.formParams.addPromoCodeIdInTransit, 'Для корректного дополнительного промокода был найден неправильный транзитовский ID');
            System.assertEquals('test02', ctrl.formParams.addPromocodeName, 'Для корректного дополнительного промокода не нашлось имя');
        }
    }

    @IsTest
    public static void testGetPromocodeFirstOKSecondNotFound() {
        User user = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            insertSomePromocodes();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();

            Test.startTest();
            ctrl.getPromocode('7E10', '8800');
            Test.stopTest();
            System.assertEquals('109', ctrl.formParams.promoCodeIdInTransit, 'Для корректного промокода был найден неправильной транзитовский ID');
            System.assertEquals('7E10', ctrl.formParams.promocodeName, 'Для корректного промокода не нашлось имя');

            System.assertEquals(null, ctrl.formParams.addPromoCodeIdInTransit, 'Для несуществующего дополнительного промокода нашелся транзитовский ID');
            System.assertEquals(null, ctrl.formParams.addPromocodeName, 'Для несуществующего дополнительного промокода нашлось имя');
        }
    }

    @IsTest
    public static void testGetPromocodeSecondOKFirstNotFound() {
        User user = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            insertSomePromocodes();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();

            Test.startTest();
            ctrl.getPromocode('000000', 'test02');
            Test.stopTest();
            System.assertEquals(null, ctrl.formParams.promoCodeIdInTransit, 'Для несуществующего промокода был найден транзитовский ID');
            System.assertEquals('', ctrl.formParams.promocodeName, 'Для несуществующего промокода не нашлось имя');

            System.assertEquals('666', ctrl.formParams.addPromoCodeIdInTransit, 'Для корректного дополнительного промокода был найден неправильный транзитовский ID');
            System.assertEquals('test02', ctrl.formParams.addPromocodeName, 'Для корректного дополнительного промокода не нашлось имя');
        }
    }

    //нельзя добавить дополнительный промокод без основного, поэтому в этом тесте для обоих кодов "возвращается" null
    @IsTest
    public static void testGetPromocodeSecondOKFirstNull() {
        User user = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            insertSomePromocodes();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();

            Test.startTest();
            ctrl.getPromocode(null, 'test02');
            Test.stopTest();
            System.assertEquals(null, ctrl.formParams.promoCodeIdInTransit, 'Для null промокода был найден транзитовский ID');
            System.assertEquals('', ctrl.formParams.promocodeName, 'Для null промокода не нашлось имя');

            System.assertEquals(null, ctrl.formParams.addPromoCodeIdInTransit, 'Для дополнительного промокода был найден неправильный транзитовский ID, при отсутствии основного промокода');
            System.assertEquals(null, ctrl.formParams.addPromocodeName, 'Для дополнительного промокода нашлось имя, при отсутствии основного промокода');
        }
    }

    @IsTest
    public static void testGetPromocodeFirstOKSecondNull() {
        User user = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(user) {
            E2EFormRuTestUtils.initCustomSettings();
            insertSomePromocodes();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();

            Test.startTest();
            ctrl.getPromocode('7E10', null);
            Test.stopTest();
            System.assertEquals('109', ctrl.formParams.promoCodeIdInTransit, 'Для корректного промокода был найден неправильной транзитовский ID');
            System.assertEquals('7E10', ctrl.formParams.promocodeName, 'Для корректного промокода не нашлось имя');

            System.assertEquals(null, ctrl.formParams.addPromoCodeIdInTransit, 'Для null дополнительного промокода нашелся транзитовский ID');
            System.assertEquals(null, ctrl.formParams.addPromocodeName, 'Для null дополнительного промокода нашлось имя');
        }
    }

    //проверки back
    @IsTest
    public static void testBack() {
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);
        PageReference expectedResult = new PageReference('/' + opportunity.Id);
        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        Test.startTest();
        PageReference actualResult = ctrl.back();
        Test.stopTest();
        System.assertEquals(expectedResult.getUrl(), actualResult.getUrl(), 'method returned incorrect reference');
    }

    //проверки updateScoreDecision
    @IsTest
    public static void testUpdateScoreDecisionNull() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        test.startTest();
        E2EMoveToStartCtrl.updateScoreDecision(formData.Id, opportunity.Id, null);
        test.stopTest();

        //из-за того что тестируемый метод @RemoteAction, локальные переменные не меняются. По этому запрашиваем formData из бд.
        formData = [select Id, E2E_Scoring_Decision_Code__c, E2E_Scoring_Decision__c, E2E_Scoring_Date__c, E2E_Scoring_Expiration_Date__c from E2EFormData__c where Id = :formData.Id LIMIT 1];
        System.assertEquals(null, formData.E2E_Scoring_Decision_Code__c);
        System.assertEquals(null, formData.E2E_Scoring_Decision__c);
        System.assertEquals(null, formData.E2E_Scoring_Date__c);
        System.assertEquals(null, formData.E2E_Scoring_Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateScoreDecisionEmpty() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        test.startTest();
        E2EMoveToStartCtrl.updateScoreDecision(formData.Id, opportunity.Id, '');
        test.stopTest();

        //из-за того что тестируемый метод @RemoteAction, локальные переменные не меняются. По этому запрашиваем formData из бд.
        formData = [select Id, E2E_Scoring_Decision_Code__c, E2E_Scoring_Decision__c, E2E_Scoring_Date__c, E2E_Scoring_Expiration_Date__c from E2EFormData__c where Id = :formData.Id LIMIT 1];
        System.assertEquals(null, formData.E2E_Scoring_Decision_Code__c);
        System.assertEquals(null, formData.E2E_Scoring_Decision__c);
        System.assertEquals(null, formData.E2E_Scoring_Date__c);
        System.assertEquals(null, formData.E2E_Scoring_Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateScoreDecision() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        test.startTest();
        E2EMoveToStartCtrl.updateScoreDecision(formData.Id, opportunity.Id, '{"decision":"1","sfRequestId":"3","points":"22"}');
        test.stopTest();

        //из-за того что тестируемый метод @RemoteAction, локальные переменные не меняются. По этому запрашиваем formData из бд.
        formData = [select Id, E2E_Scoring_Decision_Code__c, E2E_Scoring_Decision__c, E2E_Scoring_Date__c from E2EFormData__c where Id = :formData.Id LIMIT 1];

        System.assertEquals('1', formData.E2E_Scoring_Decision_Code__c);
        System.assertEquals('Предоплата', formData.E2E_Scoring_Decision__c);
        System.assertEquals(Date.today(), formData.E2E_Scoring_Date__c);
    }

    //проверки updateVerifiedDecision
    @IsTest
    public static void testUpdateVerifiedDecisionEmpty() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        try {
            test.startTest();
            E2EMoveToStartCtrl.updateVerifiedDecision(formData.Id, opportunity.Id, account.INN__c, '');
            test.stopTest();
        } catch (Exception e) {
            String mesg = e.getMessage();
            System.assertEquals('**** Error: updateVerifiedDecision verificationScoring is null', mesg);
        }

        //из-за того что тестируемый метод @RemoteAction, локальные переменные не меняются. По этому запрашиваем formData и opportunity из бд.
        formData = [select Id, E2E_Black_List_Code__c, E2E_Black_List__c, E2E_Black_List_Limitations__c from E2EFormData__c where Id = :formData.Id LIMIT 1];
        opportunity = [select Id, E2E_Sub_Status__c, E2E_Sales_Type__c, StageName, PPR_Lost_Reasons__c, E2E_Status__c from Opportunity where Id = :opportunity.Id LIMIT 1];

        E2EFormData__c expectedFormData = E2EFormRuTestUtils.createDefaultFormData();
        System.assertEquals(expectedFormData.E2E_Black_List_Code__c, formData.E2E_Black_List_Code__c);
        System.assertEquals(expectedFormData.E2E_Black_List__c, formData.E2E_Black_List__c);
        System.assertEquals(expectedFormData.E2E_Black_List_Limitations__c, formData.E2E_Black_List_Limitations__c);

        Opportunity expectedOpportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        System.assertEquals(expectedOpportunity.E2E_Sub_Status__c, opportunity.E2E_Sub_Status__c);
        System.assertEquals(expectedOpportunity.E2E_Sales_Type__c, opportunity.E2E_Sales_Type__c);
        System.assertEquals(expectedOpportunity.StageName, opportunity.StageName);
        System.assertEquals(expectedOpportunity.PPR_Lost_Reasons__c, opportunity.PPR_Lost_Reasons__c);
        System.assertEquals(expectedOpportunity.E2E_Status__c, opportunity.E2E_Status__c);
    }


    @IsTest
    public static void testUpdateVerifiedDecision() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        String scoreDecision = '{"decision":3,"limitation":14,"blackListType":[2, 5],"sfRequestId":"' + opportunity.Id + '"}';

        test.startTest();
        E2EMoveToStartCtrl.updateVerifiedDecision(formData.Id, opportunity.Id, account.INN__c, scoreDecision);
        test.stopTest();

        //из-за того что тестируемый метод @RemoteAction, локальные переменные не меняются. По этому запрашиваем formData и opportunity из бд.
        formData = [select Id, E2E_Black_List_Code__c, E2E_Black_List__c, E2E_Black_List_Limitations__c from E2EFormData__c where Id = :formData.Id LIMIT 1];
        opportunity = [select Id, E2E_Sub_Status__c, E2E_Sales_Type__c, StageName, PPR_Lost_Reasons__c, E2E_Status__c from Opportunity where Id = :opportunity.Id LIMIT 1];

        System.assertEquals('3', formData.E2E_Black_List_Code__c);
        System.assertEquals('Отказ', formData.E2E_Black_List__c);
        System.assertEquals('14', formData.E2E_Black_List_Limitations__c);

        System.assertEquals('Чёрный список', opportunity.E2E_Sub_Status__c);
        System.assertEquals('Отклонен', opportunity.E2E_Sales_Type__c);
        System.assertEquals('Отказ', opportunity.StageName);
        System.assertEquals('Клиент завершил', opportunity.E2E_Status__c);
    }

    //проверки remoteCreateExecutiveEmployee
    @IsTest
    public static void testRemoteCreateExecutiveEmployeeEmpty() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        String leaderList = '';

        test.startTest();
        String result = E2EMoveToStartCtrl.remoteCreateExecutiveEmployee(formData.Id, leaderList);
        test.stopTest();
        System.assertEquals(null, result);
    }
    // такая ситуация не обрабатывается корректно
    /* @IsTest
     public static void testRemoteCreateExecutiveEmployeeNull() {
         E2EFormRuTestUtils.initCustomSettings();
         Account account = E2EFormRuTestUtils.createDefaultAccount();
         account.INN__c = '1111111111';
         insert account;

         Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
         insert opportunity;

         E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
         formData.E2E_Account_Id__c = account.Id;
         insert formData;


         String leaderList = null;

         test.startTest();
         String result = E2EMoveToStartCtrl.remoteCreateExecutiveEmployee(formData.Id, leaderList);
         test.stopTest();
         System.assertEquals(null, result);
     }*/

    //leaders не будет null, и getCompanyActualLeader тоже null не вернёт.
    /*@IsTest
    public static void testRemoteCreateExecutiveEmployeeEmptyList() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        //String leaderList = '{"leader":[]}';
        String leaderList = '{"some":"stuff"}';

        test.startTest();
        String result = E2EMoveToStartCtrl.remoteCreateExecutiveEmployee(formData.Id, leaderList);
        test.stopTest();
        System.assertEquals(null, result);
    }*/

    @IsTest
    public static void testRemoteCreateExecutiveEmployee() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        String leaderList = '{"leader":[{"actualDate":"2014-08-20T21:00:00.000+0000","fio":"Тменов Александр Владимирович","position":"генеральный директор","inn":"330500526800","legalCapacityEndDate":null,"managementCompany":null,"managementCompanyINN":null,"disqualification":[]},' +
                '{"actualDate":"2002-08-20T21:00:00.000+0000","fio":"Bdfyjd Александр Владимирович","position":"troll директор","inn":"333555526888","legalCapacityEndDate":null,"managementCompany":null,"managementCompanyINN":null,"disqualification":[]}]}';

        test.startTest();
        String result = E2EMoveToStartCtrl.remoteCreateExecutiveEmployee(formData.Id, leaderList);
        test.stopTest();
        System.assertNotEquals(null, result, 'Contact was not created');
        Contact resContact = [select Id, accountId, LastName, title from Contact where Id = :result LIMIT 1];
        System.assertEquals(account.Id, resContact.accountId, 'Contact have wrong account ID');
        System.assertEquals('Тменов Александр Владимирович', resContact.LastName, 'Contact have wrong Name');
        System.assertEquals('генеральный директор', resContact.title, 'Contact have wrong title');

    }

    //проверки remoteUpdateCompanySparkInfo

    //проверки для строки = null не будут работать, т.к. метод упадёт в самом начале.
    @IsTest
    public static void testRemoteUpdateCompanySparkInfoEmpty() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        String companyData = '';

        try {
            test.startTest();
            E2EMoveToStartCtrl.remoteUpdateCompanySparkInfo(companyData, formData.Id, opportunity.Id, account.INN__c);
            test.stopTest();
        } catch (Exception e) {
            System.assertEquals('Error: remoteUpdateCompanySparkInfo - inn: 1111111111, opportunity ID ' + opportunity.Id, e.getMessage());
        }
    }

    @IsTest
    public static void testRemoteUpdateCompanySparkInfo() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        String companyData = '{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430",' +
                '"fullName":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                '"address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                '"industry":"Торговля розничная компьютерами, периферийными устройствами к ним и программным обеспечением в специализированных магазинах",' +
                '"regionCode":null,"regionName":"Москва","manager":"Управляющая компания ТД НКТ, ООО",' +
                '"okopfname":"Общества с ограниченной ответственностью","okopfcode":12300,"extendedReport":' +
                '{"sparkID":6329708,"companyType":1,"status":{"date":"2018-07-31T21:00:00.000+0000","type":"Действующее","code":24},' +
                '"isActing":"true","dateFirstReg":"2008-01-28","shortNameRus":"ООО \\"НКТ СОФТВЭР\\"","shortNameEn":"OOO \\"NKT SOFTVER\\"",' +
                '"fullNameRus":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                '"normName":"НКТ СОФТВЭР, ООО","inn":"7743676000","kpp":"771301001","ogrn":"1087746118162",' +
                '"okpo":"84763430","rts":null,"okato":{"code":"45277586000","regionName":"Москва","regionCode":45},' +
                '"okogu":{"code":"4210011","name":"Хозяйственные общества и товарищества с участием иностранных юридических и (или) физических лиц, а также лиц без гражданства"},' +
                '"okfs":{"code":"34","name":"Совместная частная и иностранная собственность"},' +
                '"okopf":{"code":"65","name":"Общества с ограниченной ответственностью","codeNew":"12300"},' +
                '"charterCapital":"500000","leaderList":{"leader":[{"actualDate":"2012-11-05T21:00:00.000+0000",' +
                '"fio":"Кремнев Антон Юрьевич","position":"президент","inn":null},{"actualDate":"2009-07-19T21:00:00.000+0000",' +
                '"fio":"Лаврентьев Леонид Геннадьевич","position":"генеральный директор","inn":null},' +
                '{"actualDate":"2008-01-27T21:00:00.000+0000","fio":"Еремин Игорь Юрьевич","position":"генеральный директор",' +
                '"inn":"502408806323"}]},"legalAddresses":{"address":{"postCode":"127287","address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                '"actualDate":"2018-04-27T21:00:00.000+0000","region":"г. Москва","rayon":null,"city":"г. Москва",' +
                '"streetname":"ул. Хуторская 2-Я","buildingnumber":"дом 38А"}},"adjustAddress":null,' +
                '"previousAddress":{"address":[{"postCode":"125195","address":"г. Москва, ул. Смольная, д. 20А",' +
                '"actualDate":"2016-07-21T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Пяловская, д. 7 стр. 3",' +
                '"actualDate":"2008-08-24T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Дегунинская, д. 10",' +
                '"actualDate":"2008-01-27T21:00:00.000+0000"}]},"phoneList":{"phone":[{"code":"495","number":7887921,"status":null},' +
                '{"code":"495","number":7887922,"status":null}]},"faxList":null,"email":null,"www":null,"workersRange":null,' +
                '"includeInList":{"listName":[{"value":"Компании, отсутствующие по юр. адресу по данным ФНС","id":13,"isNegative":1}]},' +
                '"creditRisk":null,"failureScore":{"failureScoreValue":"85","failureScoreDesc":"Средний риск"},' +
                '"paymentIndex":null,"federalTaxRegistration":{"regDate":"2008-01-27T21:00:00.000+0000",' +
                '"regAuthority":"Межрайонная инспекция ФНС России №46 по г.Москве","regAuthorityAddress":"125373,Москва г,Походный проезд, домовладение 3, стр.2"},' +
                '"structureInfo":{"countCoownerFCSM":0,"countCoownerRosstat":2,"countCoownerEGRUL":2,"countBranch":0,' +
                '"countBranchRosstat":0,"countAffiliatedCompanyFCSM":0,"countAffiliatedCompanyRosstat":0,' +
                '"countAffiliatedCompanyEGRUL":0,"nonprofitOrganizationRosstat":0},"vestnikMessage":null,' +
                '"bankruptcyMessage":null,"accessibleFinData":{"period":[{"name":"2017","endDate":"2017-12-30T21:00:00.000+0000",' +
                '"idperiod":547},{"name":"2016","endDate":"2016-12-30T21:00:00.000+0000","idperiod":543},' +
                '{"name":"2008","endDate":"2008-12-30T21:00:00.000+0000","idperiod":323}]},' +
                '"finance":{"finPeriod":[{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы",' +
                '"code":"1110","value":"589000"},{"form":"Баланс","section":"Актив","name":"Основные средства","code":"1150","value":"1064000"},' +
                '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                '{"form":"Отчет о прибыли и убытках","section":"Операционные доходы и расходы","name":"Чистая прибыль (убыток)","code":"2400","value":"124078000"}]},' +
                '"periodName":"2016","dateBegin":"2015-12-31T21:00:00.000+0000","dateEnd":"2016-12-30T21:00:00.000+0000"},' +
                '{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы","code":"1110","value":"144000"},' +
                '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                '{"form":"Отчет о прибыли и убытках","section":"Доходы и расходы по обычным видам деятельности","name":"Выручка","code":"2110","value":"58467000"}]},' +
                '"periodName":"2017","dateBegin":"2016-12-31T21:00:00.000+0000","dateEnd":"2017-12-30T21:00:00.000+0000"}]},' +
                '"companyWithSameInfo":{"telephoneCount":{"value":26,"phoneCode":"495","phoneNumber":"7887922"},' +
                '"addressCount":12,"managerCountInCountry":0,"managerCountInRegion":0},' +
                '"indexOfDueDiligence":{"index":"1","indexDesc":"Низкий риск"},"companySize":{"revenue":"58,50","description":"Микропредприятие"},' +
                '"eventsList":null,"boardOfDirectors":null,"executiveBody":{"member":[{"name":"ТД НКТ, ООО","inn":"7743857461",' +
                '"birthdayYear":null,"position":{"name":"Внешний исполнительный орган","code":0},"sharePart":null}],' +
                '"actualDate":"2012-11-05T21:00:00.000+0000"},"personsWithoutWarrant":null,"stateContracts":{"federalLaw94":null,' +
                '"federalLaw223":{"year":[{"tenders":{"admittedNumber":0,"notAdmittedNumber":0,"winnerNumber":0},' +
                '"contracts":{"signedNumber":1,"sum":"1980645"},"year":2016},{"tenders":{"admittedNumber":8,"notAdmittedNumber":0,"winnerNumber":8},' +
                '"contracts":{"signedNumber":2,"sum":"1928417"},"year":2015}]}},' +
                '"arbitrationCases":{"year":[{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":2,"sum":"42854"},' +
                '"thirdOrOtherPerson":{"casesNumber":0},"year":"2017"},{"plaintiff":{"casesNumber":0,"sum":"0"},' +
                '"defendant":{"casesNumber":2,"sum":"1259266"},"thirdOrOtherPerson":{"casesNumber":0},"year":"2014"},' +
                '{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},"thirdOrOtherPerson":{"casesNumber":1},' +
                '"year":"2013"},{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},' +
                '"thirdOrOtherPerson":{"casesNumber":0},"year":"2011"}]},"egrullikvidation":null,' +
                '"okvedlist":{"okved":[{"code":"52.48.13","name":"Розничная торговля компьютерами, программным обеспечением и периферийными устройствами","isMain":true},' +
                '{"code":"30.02","name":"Производство электронных вычислительных машин и прочего оборудования для обработки информации","isMain":null},' +
                '{"code":"51.14.2","name":"Деятельность агентов по оптовой торговле прочими видами машин и оборудования","isMain":null},' +
                '{"code":"51.43.22","name":"Оптовая торговля техническими носителями информации (с записями и без записей)","isMain":null},' +
                '{"code":"72.2","name":"Разработка программного обеспечения и консультирование в этой области","isMain":null},' +
                '{"code":"72.3","name":"Обработка данных","isMain":null},' +
                '{"code":"74.3","name":"Технические испытания, исследования и сертификация","isMain":null}]},"egrpoincluded":"true","fcsmcode":null}'
                + '}';

        test.startTest();
        E2EMoveToStartCtrl.remoteUpdateCompanySparkInfo(companyData, formData.Id, opportunity.Id, account.INN__c);
        test.stopTest();

        account = [select Id, BillingPostalCode, Region__c, BillingCity, Organization_Type__c from Account where Id = :account.Id LIMIT 1];
        formData = [
            select Id, E2E_Spark_Id__c, E2E_Main_Company_Full_Name__c, E2E_Reg_Date__c, E2E_Executive_Person__c, E2E_OKPO__c, E2E_OGRN__c,
            E2E_KPP__c, E2E_Billing_Code__c, E2E_Billing_State__c,E2E_Billing_City__c, E2E_Legal_Address__c, E2E_Account_Short_Name__c,
            E2E_Empty_SPARK_OKPO__c
            from E2EFormData__c where Id = :formData.Id LIMIT 1];

        System.assertEquals('6329708', formData.E2E_Spark_Id__c);
        System.assertEquals('ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"', formData.E2E_Main_Company_Full_Name__c);
        System.assertEquals('28.01.2008', formData.E2E_Reg_Date__c);
        System.assertEquals('Кремнев Антон Юрьевич, президент', formData.E2E_Executive_Person__c);
        System.assertEquals('84763430', formData.E2E_OKPO__c);
        System.assertEquals(false, formData.E2E_Empty_SPARK_OKPO__c);
        System.assertEquals('1087746118162', formData.E2E_OGRN__c);
        System.assertEquals('771301001', formData.E2E_KPP__c);
        System.assertEquals('127287', formData.E2E_Billing_Code__c);
        System.assertEquals('г. Москва', formData.E2E_Billing_State__c);
        System.assertEquals('г. Москва', formData.E2E_Billing_City__c);
        System.assertEquals('г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15', formData.E2E_Legal_Address__c);
        System.assertEquals('НКТ СОФТВЭР', formData.E2E_Account_Short_Name__c);

        System.assertEquals('127287', account.BillingPostalCode);
        System.assertEquals('г. Москва', account.Region__c);
        System.assertEquals('Г. МОСКВА', account.BillingCity);
        System.assertEquals('ООО', account.Organization_Type__c);
    }

    @IsTest
    public static void testRemoteUpdateCompanySparkInfo2ndExeption() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        String companyData = '{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430",' +
                '"fullName":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                '"address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                '"industry":"Торговля розничная компьютерами, периферийными устройствами к ним и программным обеспечением в специализированных магазинах",' +
                '"regionCode":null,"regionName":"Москва","manager":"Управляющая компания ТД НКТ, ООО",' +
                '"okopfname":"Общества с ограниченной ответственностью","okopfcode":12300, "extendedReport":null }';

        try {
            test.startTest();
            E2EMoveToStartCtrl.remoteUpdateCompanySparkInfo(companyData, formData.Id, opportunity.Id, account.INN__c);
            test.stopTest();
        } catch (Exception e) {
            System.assertEquals('Error: remoteUpdateCompanySparkInfo - inn: 1111111111, opportunity ID ' + opportunity.Id, e.getMessage());
        }
    }

    //gatherPromos
    @IsTest
    public static void testGatherPromos() {
        User u = createUser();
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(u) {
            E2EFormRuTestUtils.initCustomSettings();
            Account account = E2EFormRuTestUtils.createDefaultAccount();
            account.INN__c = '1111111111';
            insert account;

            Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
            opportunity.CategoryContract__c = 'МО';
            opportunity.StageName = 'Signing of a Contract';
            insert opportunity;

            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();
            ctrl.formParams.tariffId = '7E10';

            test.startTest();
            ctrl.gatherPromos();
            test.stopTest();

            System.assert(ctrl.promoCodeList.isEmpty(), 'Список промокодов не пуст.');
        }
    }

    //заполнение промокодов
    @IsTest
    public static void testGatherPromosNotEmpty() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = 'Signing of a Contract';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.formParams.tariffId = '7E10';

        insertSomePromocodes();

        test.startTest();
        ctrl.gatherPromos();
        test.stopTest();

        System.assertEquals(2, ctrl.promoCodeList.size(), 'Неправильное количество промокодов. Ожидалось 2');
        System.assert(!ctrl.promoCodeList.contains(new SelectOption('test01', 'Акция «Запас Прочности»')), 'Этого промо (test01) не должно быть');
        System.assert(ctrl.promoCodeList.contains(new SelectOption('test02', 'test02 - Акция «Запас Прочности»')), 'Это промо (test02) должно быть');
        System.assert(ctrl.promoCodeList.contains(new SelectOption('test03', 'test03 - Акция «Запас Прочности»')), 'Это промо (test03) должно быть');
    }

    //getSparkData
    @IsTest
    public static void testGetSparkDataException() {

        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '0123456789';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.formParams.isSoleProprietor = true;
        ctrl.formParams.companyInn = account.INN__c;

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(new Map<String, String>());
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            Test.startTest();
            ctrl.getSparkData(account.INN__c, false);
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('<br/>E2EMoveToStartCtrl method getSparkData(): SparkWebServiceImpl getEntrepreneurShortReportByInn() - Error 3: null nullcontent null', e.getMessage());
        }

    }

    //SOLE PROPRIETOR; verificationDecision.decision == 3
    @IsTest
    public static void testGetSparkDataSolePropBL3() {

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"'
        };

        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.formParams.isSoleProprietor = true;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;

        input.put('opportunityId', opportunity.Id);

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        ctrl.getSparkData(account.INN__c, false);
        Test.stopTest();

        System.assertEquals('Sole Proprietor in BlackList verification failed: inn=1111111111, sparkId=6329708', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary());

    }

    //Не является SOLE PROPRIETOR; verificationDecision.decision == 3
    @IsTest
    public static void testGetSparkDataNotSolePropBL3() {

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"'
        };

        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;

        input.put('opportunityId', opportunity.Id);

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        ctrl.getSparkData(account.INN__c, false);
        Test.stopTest();

        System.assertEquals('COMPANY VERIFICATION DECISION: verificationDecision=CompanyVerificationScoring:[blackListType=(10), decision=3, limitation=0, sfRequestId=0066E0000058YwnQAE], verificationDecision.decision=3', ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary());
    }


    //saveSObjects
    @IsTest
    public static void TestSaveSObjects() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
                'opportunityId' => opportunity.Id
        };

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = formData.Id;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';
        ctrl.formParams.contactFullName = 'Владислав';

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        ctrl.saveSObjects();
        Test.stopTest();

        account = [select Id, OKPO_ppr__c from Account where Id = :account.Id LIMIT 1];
        opportunity = [select Id, Name from Opportunity where Id = :opportunity.Id LIMIT 1];
        formData = [select Id, E2E_Executive_Person__c from E2EFormData__c where Id = :formData.Id LIMIT 1];

        System.assertEquals('84763430', account.OKPO_ppr__c);
        System.assertEquals('Кремнев Антон Юрьевич, президент', formData.E2E_Executive_Person__c);
        System.assertEquals(ctrl.formParams.ogrnSpark, ctrl.formParams.ogrn);
        System.assertEquals(false, ctrl.formParams.emptySparkOkpo);
    }

    @IsTest
    public static void TestSaveSObjectsSoleProp() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        Contact contact = E2EFormRuTestUtils.createContact(account.Id, '+7 8005553535', 'test@email.com');
        insert contact;

        OpportunityContactRole contactRole = E2EFormRuTestUtils.getOpportunityContactRole(contact.Id, opportunity.Id);
        contactRole.isPrimary = true;
        update contactRole;

        opportunity = new E2EFormRuDaoImpl().getOpportunityById(opportunity.Id);

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
                'opportunityId' => opportunity.Id
        };

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = formData.Id;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = true;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';
        ctrl.formParams.promoCode = '7E10';
        ctrl.formParams.mainContactEmail = contact.Email;
        ctrl.formParams.mainContactPhone = contact.Phone;
        ctrl.formParams.contactFullName = 'Владислав';

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        ctrl.saveSObjects();
        Test.stopTest();

        account = [select Id, OKPO_ppr__c from Account where Id = :account.Id LIMIT 1];
        opportunity = [select Id, Name from Opportunity where Id = :opportunity.Id LIMIT 1];
        formData = [select Id, E2E_Executive_Person__c from E2EFormData__c where Id = :formData.Id LIMIT 1];

        System.assertEquals('0116896779', account.OKPO_ppr__c);
        System.assertEquals('Иванов Иван Иванович, Индивидуальный предприниматель', formData.E2E_Executive_Person__c);
        System.assertEquals('309774623800678', ctrl.formParams.ogrn);
        System.assertEquals(ctrl.formParams.ogrnipSpark, ctrl.formParams.ogrn);
    }

    //moveToStart
    @IsTest
    public static void testMoveToStartOpptWrongStatus() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
                'opportunityId' => opportunity.Id
        };

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = formData.Id;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';
        ctrl.formParams.contactFullName = 'Владислав';


        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        ctrl.moveToStart();
        Test.stopTest();

        account = [select Id, OKPO_ppr__c from Account where Id = :account.Id LIMIT 1];
        opportunity = [select Id, StageName from Opportunity where Id = :opportunity.Id LIMIT 1];
        formData = [select Id, E2E_Executive_Person__c from E2EFormData__c where Id = :formData.Id LIMIT 1];

        System.assertEquals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractChecking), opportunity.StageName);
    }

    @IsTest
    public static void testMoveToStartException() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = null;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';

        addLoggerRecipient();

        Test.startTest();
        ctrl.moveToStart();
        Test.stopTest();

        System.assertEquals('Системная ошибка!', ctrl.executionStatus, 'Не возникло сообщения об ошибке.');
        System.assert(ExceptionLogger.mail.getHtmlBody().contains('<br/>E2E Business method moveToStart(): inn=' + account.INN__c), 'Неверное содержимое письма об ошибке');
    }

    @IsTest
    public static void testMoveToStartButtonStartBlocked() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        E2E_business_settings__c settings = new E2E_business_settings__c(
                Name = GlobalUtils.FleetcorCountries.Russia.name(),
                Block_start_button__c = true,
                DaData_Token__c = 'test_token'
        );
        insert settings;

        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AgreementTermsAndConditions);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();

        Boolean assert = false;
        for (Integer i = 0; i < ApexPages.getMessages().size(); i++) {
            if (ApexPages.getMessages().get(i).getSummary().equals(Label.E2E_business_start_blocked)) {
                assert = true;
            }
        }
        System.assert(assert);

        System.assertEquals('test_token', ctrl.daDataToken);
    }

    //moveToStart и deduplicationAccount.
    @IsTest
    public static void testDeduplicationAccountsToService() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        E2EFormRuTestUtils.initCustomSettings();

        //аккаунт и прочие записи, с которыми будем работать
        Account account1 = E2EFormRuTestUtils.createDefaultAccount();
        account1.INN__c = '1111111111';
        insert account1;

        Opportunity opportunity1 = E2EFormRuTestUtils.createOpportunity(account1.Id);
        opportunity1.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity1;

        E2EFormData__c formData1 = E2EFormRuTestUtils.createDefaultFormData();
        formData1.E2E_Account_Id__c = account1.Id;
        formData1.E2E_Opportunity_Id__c = opportunity1.Id;
        insert formData1;

        Contact contact1 = E2EFormRuTestUtils.createContact(account1.Id, '+78005553535', 'test@email.com');
        insert contact1;

        //аккаунт и прочие записи - "дубликаты"
        Account account2 = E2EFormRuTestUtils.createDefaultAccount();
        account2.INN__c = '1111111666';
        account2.Last_pump_date__c = Date.today().addYears(-1);
        insert account2;

        Opportunity opportunity2 = E2EFormRuTestUtils.createOpportunity(account2.Id);
        opportunity2.StageName = 'Moved to Start';
        opportunity2.CloseDate = Date.today().addMonths(-6);
        insert opportunity2;

        E2EFormData__c formData2 = E2EFormRuTestUtils.createDefaultFormData();
        formData2.E2E_Account_Id__c = account2.Id;
        formData2.E2E_Opportunity_Id__c = opportunity2.Id;
        insert formData2;

        Contact contact2 = E2EFormRuTestUtils.createContact(account2.Id, '+78005553666', 'test@email.com');
        insert contact2;
        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        insert setting;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account1;
        ctrl.formData = formData1;
        ctrl.formDataId = formData1.Id;
        ctrl.oppty = opportunity1;
        ctrl.opportunityId = opportunity1.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account1.INN__c;
        ctrl.opportunityId = opportunity1.Id;
        ctrl.formParams.companyName = 'Ааааааааа!';
        ctrl.formParams.mainContactEmail = 'test@email.com';
        ctrl.opportunityId = opportunity1.Id;
        ctrl.formParams.contactFullName = 'Владислав';


        Test.startTest();
        ctrl.moveToStart();
        Test.stopTest();

        System.assertEquals(System.Label.SendToService, ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary());
    }

    @IsTest
    public static void testDeduplicationAccountsEmailDomainDupl() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());
        User currUser = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createAdminUser());
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(owner) {
            E2EFormRuTestUtils.initCustomSettings();
            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            //аккаунт и прочие записи, с которыми будем работать
            Account account1 = E2EFormRuTestUtils.createDefaultAccount();
            account1.INN__c = E2EFormRuTestUtils.INN;
            account1.OwnerId = currUser.id;
            insert account1;

            Opportunity opportunity1 = E2EFormRuTestUtils.createOpportunity(account1.Id);
            opportunity1.OwnerId = currUser.id;
            insert opportunity1;

            E2EFormData__c formData1 = E2EFormRuTestUtils.createDefaultFormData();
            formData1.E2E_Account_Id__c = account1.Id;
            formData1.E2E_Opportunity_Id__c = opportunity1.Id;
            insert formData1;

            Contact contact1 = E2EFormRuTestUtils.createContact(account1.Id, E2EFormRuTestUtils.phone, E2EFormRuTestUtils.email);
            insert contact1;

            //аккаунт и прочие записи - "дубликаты"
            Account account2 = E2EFormRuTestUtils.createDefaultAccount();
            account2.INN__c = E2EFormRuTestUtils.secondINN;
            insert account2;

            Opportunity opportunity2 = E2EFormRuTestUtils.createOpportunity(account2.Id);
            insert opportunity2;

            E2EFormData__c formData2 = E2EFormRuTestUtils.createDefaultFormData();
            formData2.E2E_Account_Id__c = account2.Id;
            formData2.E2E_Opportunity_Id__c = opportunity2.Id;
            insert formData2;

            Contact contact2 = E2EFormRuTestUtils.createContact(account2.Id, E2EFormRuTestUtils.phone, E2EFormRuTestUtils.email);
            insert contact2;

            E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
            insert setting;

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();
            ctrl.Account = account1;
            ctrl.formData = formData1;
            ctrl.formDataId = formData1.Id;
            ctrl.oppty = opportunity1;
            ctrl.opportunityId = opportunity1.Id;
            ctrl.formParams.isSoleProprietor = false;
            ctrl.formParams.companyInn = account1.INN__c;
            ctrl.opportunityId = opportunity1.Id;
            ctrl.formParams.companyName = E2EFormRuTestUtils.name;
            ctrl.formParams.mainContactEmail = E2EFormRuTestUtils.email;
            ctrl.opportunityId = opportunity1.Id;
            ctrl.formParams.contactFullName = 'Владислав';

            Test.startTest();
            ctrl.moveToStart();
            Test.stopTest();

            System.assertEquals(System.Label.SendToAdmin, ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary());
        }
    }

    @IsTest
    public static void testDeduplicationAccountsEmailDupl() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());
        User currUser = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createAdminUser());
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        System.runAs(owner) {
            E2EFormRuTestUtils.initCustomSettings();

            //аккаунт и прочие записи, с которыми будем работать
            Account account1 = E2EFormRuTestUtils.createDefaultAccount();
            account1.INN__c = E2EFormRuTestUtils.INN;
            account1.OwnerId = currUser.id;
            insert account1;

            Opportunity opportunity1 = E2EFormRuTestUtils.createOpportunity(account1.Id);
            opportunity1.OwnerId = currUser.id;
            insert opportunity1;

            E2EFormData__c formData1 = E2EFormRuTestUtils.createDefaultFormData();
            formData1.E2E_Account_Id__c = account1.Id;
            formData1.E2E_Opportunity_Id__c = opportunity1.Id;
            insert formData1;

            Contact contact1 = E2EFormRuTestUtils.createContact(account1.Id, E2EFormRuTestUtils.phone, E2EFormRuTestUtils.email);
            insert contact1;

            //аккаунт и прочие записи - "дубликаты"
            Account account2 = E2EFormRuTestUtils.createDefaultAccount();
            account2.INN__c = E2EFormRuTestUtils.secondINN;
            insert account2;

            Opportunity opportunity2 = E2EFormRuTestUtils.createOpportunity(account2.Id);
            insert opportunity2;

            E2EFormData__c formData2 = E2EFormRuTestUtils.createDefaultFormData();
            formData2.E2E_Account_Id__c = account2.Id;
            formData2.E2E_Opportunity_Id__c = opportunity2.Id;
            insert formData2;

            Contact contact2 = E2EFormRuTestUtils.createContact(account2.Id, E2EFormRuTestUtils.phone, E2EFormRuTestUtils.email);
            insert contact2;

            E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
            insert setting;

            E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
            ctrl.init();
            ctrl.Account = account1;
            ctrl.formData = formData1;
            ctrl.formDataId = formData1.Id;
            ctrl.oppty = opportunity1;
            ctrl.opportunityId = opportunity1.Id;
            ctrl.formParams.isSoleProprietor = false;
            ctrl.formParams.companyInn = account1.INN__c;
            ctrl.opportunityId = opportunity1.Id;
            ctrl.formParams.companyName = E2EFormRuTestUtils.name;
            ctrl.formParams.mainContactEmail = E2EFormRuTestUtils.email;
            ctrl.opportunityId = opportunity1.Id;
            ctrl.formParams.contactFullName = 'Владислав';

            insert new PublicEmailDomains__c(Name = E2EFormRuTestUtils.domains);

            Test.startTest();
            ctrl.moveToStart();
            Test.stopTest();

            System.assertEquals(System.Label.SendToAdmin, ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getSummary());
        }
    }

    //getPreviewContract
    @IsTest
    public static void testGetPreviewContractPrevFalse() {
        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        String expectedResult = '';
        Test.startTest();
        String result = ctrl.previewContractContent;
        Test.stopTest();
        System.assertEquals(expectedResult, result);
    }

    @IsTest
    public static void testGetPreviewContractException() {
        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.activatePreviewContract();
        Test.startTest();
        String preview = ctrl.previewContractContent;
        Test.stopTest();
        System.assertEquals('Системная ошибка!', ctrl.executionStatus);
    }

    @IsTest
    public static void testGetPreviewContract() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
                'opportunityId' => opportunity.Id
        };

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = formData.Id;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';
        ctrl.formParams.companyInn = '1111111111';
        ctrl.formParams.prepayAmount = '1234';


        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ctrl.activatePreviewContract();
        Test.startTest();
        String preview = ctrl.previewContractContent;
        Test.stopTest();
//        System.assertEquals(EncodingUtil.Base64Encode(Blob.valueOf('Blob')), preview);
    }

    //remoteGetCompanyData
    @IsTest
    public static void testRemoteGetCompanyData() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
                'opportunityId' => opportunity.Id
        };

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        CompanySpark result = E2EMoveToStartCtrl.remoteGetCompanyData(account.INN__c);
        Test.stopTest();
        CompanySpark expectedResult = (CompanySpark) JSON.deserialize('{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430",' +
                '"fullName":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                '"address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                '"industry":"Торговля розничная компьютерами, периферийными устройствами к ним и программным обеспечением в специализированных магазинах",' +
                '"regionCode":null,"regionName":"Москва","manager":"Управляющая компания ТД НКТ, ООО",' +
                '"okopfname":"Общества с ограниченной ответственностью","okopfcode":12300}}', CompanySpark.class);
        System.assertEquals(expectedResult.sparkID, result.sparkID);
        System.assertEquals(expectedResult.ogrn, result.ogrn);
        System.assertEquals(expectedResult.okpo, result.okpo);
        System.assertEquals(expectedResult.industry, result.industry);
        System.assertEquals(expectedResult.regionName, result.regionName);
    }

    @IsTest
    public static void testRemoteGetCompanyDataException() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        addLoggerRecipient();

        Test.startTest();
        CompanySpark result = E2EMoveToStartCtrl.remoteGetCompanyData('1111111111');
        Test.stopTest();

        System.assert(ApexPages.getMessages()[0].getSummary().contains('Ошибка при получении данных из СПАРК!'));
        System.assert(ExceptionLogger.mail.getHtmlBody().contains('<br/>E2E Remote Action remoteGetCompanyData(): '), 'Неверное содержимое письма об ошибке');
        System.assertEquals(null, result, 'Некорректное значение verificationDecision. Ожидался null.');
    }

    //remoteGetEntrepreneurData
    @IsTest
    public static void testRemoteGetEntrepreneurData() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
                'opportunityId' => opportunity.Id
        };

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        SoleProprietorSpark result = E2EMoveToStartCtrl.remoteGetEntrepreneurData(account.INN__c);
        Test.stopTest();

        System.assertEquals(6329708, result.sparkID, 'Неправильный спарк id');
        System.assertEquals('770605086143', result.inn, 'Неправильный inn');
        System.assertEquals('Иванов Иван Иванович', result.fullNameRus, 'Неправильное имя');
    }

    @IsTest
    public static void testRemoteGetEntrepreneurDataException() {
        String innForBrokenResp = '8005553535';

        E2EFormRuTestUtils.initCustomSettings();
        addLoggerRecipient();
        String expectedException = '<br/>E2E Remote Action remoteGetEntrepreneurData(): Methods defined as TestMethod do not support Web service callouts';
        Test.startTest();
        SoleProprietorSpark result = E2EMoveToStartCtrl.remoteGetEntrepreneurData(innForBrokenResp);
        Test.stopTest();
        System.assert(ExceptionLogger.mail.getHtmlBody().contains(expectedException), 'Неверное содержимое письма об ошибке');
        System.assertEquals(null, result, 'Некорректное значение verificationDecision. Ожидался null.');
    }

    //remoteUpdateEntrepreneurShortReport
    //OK
    @IsTest
    public static void testRemoteUpdateEntrepreneurShortReport() {

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        String soleProprietorInfoJson = '{"sparkID":6329708,"status":{"isActing":true,"text":"Действующее","code":24},"dateReg":"2009-08-25T21:00:00.000+0000","fullNameRus":"Иванов Иван Иванович","inn":"770605086143","ogrnip":"309774623800678","okpo":"0116896779","okato":{"code":"45286596000","regionName":"Москва","regionCode":45},"birthDate":"1979-03-12T21:00:00.000+0000","birthPlace":"г. Москва","okvedlist":{"okved":[{"code":"74.14","name":"Консультирование по вопросам коммерческой деятельности и управления","isMain":true},{"code":"51.16","name":"Деятельность агентов по оптовой торговле текстильными изделиями, одеждой, обувью, изделиями из кожи и меха","isMain":null},{"code":"51.42","name":"Оптовая торговля одеждой, включая нательное белье, и обувью","isMain":null},{"code":"51.47","name":"Оптовая торговля прочими непродовольственными потребительскими товарами","isMain":null},{"code":"52.4","name":"Прочая розничная торговля в специализированных магазинах","isMain":null},{"code":"52.42","name":"Розничная торговля одеждой","isMain":null},{"code":"52.48.39","name":"Специализированная розничная торговля прочими непродовольственными  товарами, не включенными в другие группировки","isMain":null},{"code":"52.61.2","name":"Розничная торговля, осуществляемая непосредственно при помощи телевидения, радио, телефона и Интернет","isMain":null},{"code":"74.40","name":"Рекламная деятельность","isMain":null},{"code":"80.42","name":"Образование для взрослых и прочие виды образования, не включенные в другие группировки","isMain":null}]}}';

        Test.startTest();
        E2EMoveToStartCtrl.remoteUpdateEntrepreneurShortReport(soleProprietorInfoJson, formData.Id);
        Test.stopTest();

        formData = [
            select Id, E2E_Spark_Id__c, E2E_Executive_Person__c, E2E_Account_Short_Name__c, E2E_Main_Company_Full_Name__c, E2E_Reg_Date__c, E2E_OGRN__c, E2E_OKPO__c, E2E_Empty_SPARK_OKPO__c
            from E2EFormData__c where Id = :formData.Id LIMIT 1];
        //в assert'ы можно вставить форм дату, т.к. в ней должны обновиться значения.
        System.assertEquals('6329708', String.valueOf(formData.E2E_Spark_Id__c));
        System.assertEquals('Иванов Иван Иванович, Индивидуальный предприниматель', formData.E2E_Executive_Person__c);
        System.assertEquals('Иванов Иван Иванович', formData.E2E_Account_Short_Name__c);
        System.assertEquals('ИП Иванов Иван Иванович', formData.E2E_Main_Company_Full_Name__c);
        System.assertEquals(String.valueOf(((DateTime) Json.deserialize('"2009-08-25T21:00:00.000+0000"', DateTime.class)).format('dd.MM.yyyy')), formData.E2E_Reg_Date__c);
        System.assertEquals('309774623800678', formData.E2E_OGRN__c);
        System.assertEquals('0116896779', formData.E2E_OKPO__c);
        System.assertEquals(false, formData.E2E_Empty_SPARK_OKPO__c);
    }

    @IsTest
    public static void testRemoteUpdateEntrepreneurShortReportNoSparkId() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        String soleProprietorInfoJson = '{"status":{"isActing":true,"text":"Действующее","code":24},"dateReg":"2009-08-25T21:00:00.000+0000","fullNameRus":"Иванов Иван Иванович","inn":"770605086143","ogrnip":"309774623800678","okpo":"0116896779","okato":{"code":"45286596000","regionName":"Москва","regionCode":45},"birthDate":"1979-03-12T21:00:00.000+0000","birthPlace":"г. Москва","okvedlist":{"okved":[{"code":"74.14","name":"Консультирование по вопросам коммерческой деятельности и управления","isMain":true},{"code":"51.16","name":"Деятельность агентов по оптовой торговле текстильными изделиями, одеждой, обувью, изделиями из кожи и меха","isMain":null},{"code":"51.42","name":"Оптовая торговля одеждой, включая нательное белье, и обувью","isMain":null},{"code":"51.47","name":"Оптовая торговля прочими непродовольственными потребительскими товарами","isMain":null},{"code":"52.4","name":"Прочая розничная торговля в специализированных магазинах","isMain":null},{"code":"52.42","name":"Розничная торговля одеждой","isMain":null},{"code":"52.48.39","name":"Специализированная розничная торговля прочими непродовольственными  товарами, не включенными в другие группировки","isMain":null},{"code":"52.61.2","name":"Розничная торговля, осуществляемая непосредственно при помощи телевидения, радио, телефона и Интернет","isMain":null},{"code":"74.40","name":"Рекламная деятельность","isMain":null},{"code":"80.42","name":"Образование для взрослых и прочие виды образования, не включенные в другие группировки","isMain":null}]}}';

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(new Map<String, String>());
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        E2EMoveToStartCtrl.remoteUpdateEntrepreneurShortReport(soleProprietorInfoJson, formData.Id);
        Test.stopTest();

        formData = [select Id, E2E_Spark_Id__c, E2E_Executive_Person__c, E2E_Account_Short_Name__c, E2E_Main_Company_Full_Name__c, E2E_Reg_Date__c, E2E_OGRN__c, E2E_OKPO__c from E2EFormData__c where Id = :formData.Id LIMIT 1];
        E2EFormData__c expectedFormData = E2EFormRuTestUtils.createDefaultFormData();

        System.assertEquals(String.valueOf(expectedFormData.E2E_Spark_Id__c), String.valueOf(formData.E2E_Spark_Id__c));
        System.assertEquals(expectedFormData.E2E_Executive_Person__c, formData.E2E_Executive_Person__c);
        System.assertEquals(expectedFormData.E2E_Account_Short_Name__c, formData.E2E_Account_Short_Name__c);
        System.assertEquals(expectedFormData.E2E_Main_Company_Full_Name__c, formData.E2E_Main_Company_Full_Name__c);
        System.assertEquals(expectedFormData.E2E_Reg_Date__c, formData.E2E_Reg_Date__c);
        System.assertEquals(expectedFormData.E2E_OGRN__c, formData.E2E_OGRN__c);
        System.assertEquals(expectedFormData.E2E_OKPO__c, formData.E2E_OKPO__c);
    }

    @IsTest
    public static void testRemoteUpdateEntrepreneurShortReportExeption() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        String soleProprietorInfoJson = '';

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(new Map<String, String>());
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try {
            Test.startTest();
            E2EMoveToStartCtrl.remoteUpdateEntrepreneurShortReport(soleProprietorInfoJson, formData.Id);
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('Error: remoteUpdateEntrepreneurShortReport', e.getMessage());
        }


        formData = [select Id, E2E_Spark_Id__c, E2E_Executive_Person__c, E2E_Account_Short_Name__c, E2E_Main_Company_Full_Name__c, E2E_Reg_Date__c, E2E_OGRN__c, E2E_OKPO__c from E2EFormData__c where Id = :formData.Id LIMIT 1];
        E2EFormData__c expectedFormData = E2EFormRuTestUtils.createDefaultFormData();

        System.assertEquals(String.valueOf(expectedFormData.E2E_Spark_Id__c), String.valueOf(formData.E2E_Spark_Id__c));
        System.assertEquals(expectedFormData.E2E_Executive_Person__c, formData.E2E_Executive_Person__c);
        System.assertEquals(expectedFormData.E2E_Account_Short_Name__c, formData.E2E_Account_Short_Name__c);
        System.assertEquals(expectedFormData.E2E_Main_Company_Full_Name__c, formData.E2E_Main_Company_Full_Name__c);
        System.assertEquals(expectedFormData.E2E_Reg_Date__c, formData.E2E_Reg_Date__c);
        System.assertEquals(expectedFormData.E2E_OGRN__c, formData.E2E_OGRN__c);
        System.assertEquals(expectedFormData.E2E_OKPO__c, formData.E2E_OKPO__c);

    }

    //проверки CheckCompany
    @IsTest
    public static void testCheckCompanyBadData() {
        E2EFormRuTestUtils.initCustomSettings();
        addLoggerRecipient();
        Test.startTest();
        CompanyVerificationScoring res = E2EMoveToStartCtrl.checkCompany(false, '123', '', '123');
        Test.stopTest();
        System.assertEquals('Exception in \n' + '<br/>E2E RU RemoteAction SPARK DATA IS EMPTY for inn = 123 sparkId = ', ExceptionLogger.mail.getHtmlBody(), 'Неверное содержимое письма об ошибке');
        System.assertEquals(null, res, 'Некорректное значение verificationDecision. Ожидался null.');
    }

    @IsTest
    public static void testCheckCompany() {
        E2EFormRuTestUtils.initCustomSettings();

        Map<String, String> input = new Map<String, String>{
                'inn' => '123',
                'sparkId' => '6329708',
                'opportunityId' => '0066E0000058ZwnQAE'
        };

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        CompanyVerificationScoring res = E2EMoveToStartCtrl.checkCompany(false, '123', '6329708', '0066E0000058ZwnQAE');
        Test.stopTest();System.assertEquals(3, res.decision, 'Некорректное значение verificationDecision. Ожидалось 3.');
    }

    //проверки getScore
    //decision = null
    @IsTest
    public static void testGetScoreEmpty() {
        E2EFormRuTestUtils.initCustomSettings();

        Test.startTest();
        DecisionScoring res = E2EMoveToStartCtrl.getScore('123', '6329708', '0066E0000058ZwnQAE', '');
        Test.stopTest();
        System.assertEquals(null, res, 'Некорректное значение DecisionScoring. Ожидался null.');
    }

    //decision = 3
    @IsTest
    public static void testGetScoreDis3() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);
        E2EFormRuTestUtils.initCustomSettings();

        String verificationDecision = '{"decision":3,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}';

        Test.startTest();
        DecisionScoring res = E2EMoveToStartCtrl.getScore('123', '6329708', '0066E0000058ZwnQAE', verificationDecision);
        Test.stopTest();
        System.assertEquals(null, res, 'Некорректное значение DecisionScoring. Ожидался null.');
    }

    //decision = OK
    @IsTest
    public static void testGetScoreOK() {
        E2EFormRuTestUtils.initCustomSettings();

        String verificationDecision = '{"decision":1,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}';

        Map<String, String> input = new Map<String, String>{
                'inn' => '123',
                'sparkId' => '6329708',
                'opportunityId' => '0066E0000058ZwnQAE'
        };

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        DecisionScoring res = E2EMoveToStartCtrl.getScore('123', '6329708', '0066E0000058ZwnQAE', verificationDecision);
        Test.stopTest();
        System.assertEquals(3, res.decision, 'Некорректное значение decision. Ожидалось 3.');
        System.assertEquals('0066E0000058ZwnQAE', res.sfRequestId, 'Некорректное значение sfRequestId. Ожидалось 0066E0000058ZwnQAE.');
    }

    //проверка getVerification. В тестируемом методе нет никаких условных операторов. Можно обойтись одним тестовом методом.
    @IsTest
    public static void testGetVerification() {
        E2EFormRuTestUtils.initCustomSettings();
        Test.startTest();
        String res = E2EMoveToStartCtrl.getVerification((CompanyVerificationScoring) (JSON.deserialize('{"decision":4,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}', CompanyVerificationScoring.class)));
        Test.stopTest();
        System.assertEquals('Согласование перекупщика', res, 'Некорректный статус');
    }

    //проверка getDecision. В тестируемом методе нет никаких условных операторов. Можно обойтись одним тестовом методом.
    @IsTest
    public static void testGetDecision() {
        E2EFormRuTestUtils.initCustomSettings();
        Test.startTest();
        String res = E2EMoveToStartCtrl.getDecision((DecisionScoring) (JSON.deserialize('{"decision":0,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}', DecisionScoring.class)));
        Test.stopTest();
        System.assertEquals('Платный овердрафт', res, 'Некорректный статус');
    }

    @IsTest
    public static void testSendDataToPDServiceNullNotActive() {
        PD_Setting__c sett = E2EMoveToStartDataTestFactory.createPDSetting(true);
        insert sett;
        Contact cont = E2EMoveToStartDataTestFactory.createContact();
        insert cont;

        E2EMoveToStartCtrl.sendDataToPDService(null);
        E2EMoveToStartCtrl.sendDataToPDService(cont.Id);
    }

    @IsTest
    public static void testSendDataToPDService() {
        PD_Setting__c sett = E2EMoveToStartDataTestFactory.createPDSetting(true);
        insert sett;
        Contact cont = E2EMoveToStartDataTestFactory.createContact();
        insert cont;

        String pdId = '539d7263-1bdc-4093-a025-b09c60c6102b';
        String responseBody = '{"status":"ok", "error": null, "result": {"id": "' + pdId + '"}}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', responseBody, null));

        Test.startTest();
        E2EMoveToStartCtrl.sendDataToPDService(cont.Id);
        Test.stopTest();

        Contact contFromDB = [SELECT PD_ExternalId__c FROM Contact WHERE id =: cont.Id];
        
        System.assertEquals(pdId, contFromDB.PD_ExternalId__c);
    }

    @IsTest
    public static void testCreateContactsInPD() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        PD_Setting__c sett = E2EMoveToStartDataTestFactory.createPDSetting(true);
        insert sett;

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = formData.Id;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';
        ctrl.formParams.executiveFioManual = 'Ivan Ivanovich Ivanov';
        ctrl.formParams.executivePositionManual = 'CTO';
        ctrl.formParams.mainContactPhone = '+71111111111';
        ctrl.formParams.mainContactEmail = 'testmaincontact@test.com';
        ctrl.formParams.contactFullName = 'Владислав Максимчик';        

        String pdId = '539d7263-1bdc-4093-a025-b09c60c6102b';
        String responseBody = '{"status":"ok", "error": null, "result": {"id": "' + pdId + '"}}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', responseBody, null));

        Test.startTest();
        ctrl.saveSObjects();
        Test.stopTest();

        Contact contactExecutive = [SELECT Id, PD_ExternalId__c FROM Contact WHERE Title = 'CTO'];
        Contact contactMain = [SELECT Id, LastName, FirstName, PD_ExternalId__c FROM Contact WHERE Email = 'testmaincontact@test.com'];
        
        System.assertEquals(contactExecutive.Id, ctrl.formParams.executiveId);
        System.assertEquals(contactMain.LastName, 'Владислав');
        System.assertEquals(contactMain.FirstName, 'Максимчик');
        System.assertEquals(pdId, contactExecutive.PD_ExternalId__c);
        System.assertEquals(pdId, contactMain.PD_ExternalId__c);
    }

    @isTest
    public static void testOrgRMDApprove() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractSigning);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        insert setting;

        Map<String, String> input = new Map<String, String> {
            'inn' => '1111111111',
            'sparkId' => '6329708',
            'entrepreneurInn' => '1111111111',
            'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
            'opportunityId' => opportunity.Id
        };

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = formData.Id;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = false;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        SingleRequestMock scoringRMDDecision1 = new SingleRequestMock(200, 'Complete', 
            '{"statusCode":200,"message":"Scoring Integration","content":{"decision":1,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}}', null); 
        responses.put('http://99.240.174.55/PPRMiddleware/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunity.Id + '&inn=1111111111&sparkId=6329708', scoringRMDDecision1);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        ctrl.moveToStart();
        Test.stopTest();

        account = [select Id, OKPO_ppr__c from Account where Id = :account.Id LIMIT 1];
        System.assertEquals(null, account.OKPO_ppr__c);
    }

    @IsTest
    public static void testSolePropRMDApprove() {
        PageReference pageReference = Page.e2eMoveToStart;
        Test.setCurrentPage(pageReference);

        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        insert formData;

        Contact contact = E2EFormRuTestUtils.createContact(account.Id, '+7 8005553535', 'test@email.com');
        insert contact;

        OpportunityContactRole contactRole = E2EFormRuTestUtils.getOpportunityContactRole(contact.Id, opportunity.Id);
        contactRole.isPrimary = true;
        update contactRole;

        E2E_business_settings__c setting = E2EMoveToStartDataTestFactory.createBusinessSetting(false);
        insert setting;

        opportunity = E2EFormRuTestUtils.getOpportunityById(opportunity.Id);

        Map<String, String> input = new Map<String, String>{
                'inn' => '1111111111',
                'sparkId' => '6329708',
                'entrepreneurInn' => '1111111111',
                'companyName' => 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"',
                'opportunityId' => opportunity.Id
        };

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        ctrl.init();
        ctrl.Account = account;
        ctrl.formData = formData;
        ctrl.formDataId = formData.Id;
        ctrl.oppty = opportunity;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.isSoleProprietor = true;
        ctrl.formParams.companyInn = account.INN__c;
        ctrl.opportunityId = opportunity.Id;
        ctrl.formParams.companyName = 'Ааааааааа';
        ctrl.formParams.promoCode = '7E10';
        ctrl.formParams.mainContactEmail = contact.Email;
        ctrl.formParams.mainContactPhone = contact.Phone;

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock(input);
        SingleRequestMock scoringRMDDecision1 = new SingleRequestMock(200, 'Complete', 
            '{"statusCode":200,"message":"Scoring Integration","content":{"decision":1,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}}', null); 
        responses.put('http://99.240.174.55/PPRMiddleware/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunity.Id + '&inn=1111111111&sparkId=6329708', scoringRMDDecision1);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        ctrl.moveToStart();
        Test.stopTest();

        account = [select Id, OKPO_ppr__c from Account where Id = :account.Id LIMIT 1];
        System.assertEquals(null, account.OKPO_ppr__c);
    }

    //вспомогательные методы
    private static User createUser() {
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Telesales (mentor)'];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Call Center'];
        User user = new User(
                Username = 'Test' + Crypto.getRandomInteger() + '@Test321.com',
                Email = 'test@test.com',
                FirstName = 'Test',
                LastName = 'Test',
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                User_Transit_Id__c = '11111111111111111111111111111111',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow',
                EmailEncodingKey = 'UTF-8',
                Alias = 'Test');
        insert user;
        return user;
    }

    private static User createUser2() {
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Telesales (mentor)'];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Call Center'];
        User user = new User(
                Username = 'oooooo@Test321.com',
                Email = 'ooooooo@test.com',
                FirstName = 'oooooo',
                LastName = 'Test',
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                User_Transit_Id__c = '11111111111111111111111111112222',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow',
                EmailEncodingKey = 'UTF-8',
                Alias = 'ooooooo');
        insert user;
        return user;
    }

    private static User createAdminUser() {
        /*UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Telesales (mentor)'];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Call Center'];*/
        User user = new User(
                Username = 'admin@Test321.com',
                Email = 'admin@test.com',
                FirstName = 'admin',
                LastName = 'admin',
                UserRoleId = '00E0O0000023vGQUAY',
                ProfileId = '00e20000001nSOBAA2',
                User_Transit_Id__c = '44441111111111111111111111111111',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow',
                EmailEncodingKey = 'UTF-8',
                Alias = 'admin');
        insert user;
        return user;
    }

    private static User createInboundUser() {
        // Как сказал Герман формой для бизнеса будут пользоваться 'Livadina (Sidartsova)', 'Korenkova', 'Burenok'
        // Создаём пользователя с подходящими параметрами
        User user = new User(
                Username = 'inbound01@test123.com',
                Email = 'inbound01@test123.com',
                FirstName = 'inbound01',
                LastName = 'inbound01',
                UserRoleId = '00E0O0000023vG5UAI',
                ProfileId = '00e0O000001pje1QAA',
                User_Transit_Id__c = 'C1999BDF65BA4B4784142C8C7063E666', //C19B7BDF65BA4B4784142C8C7063EB48
                LanguageLocaleKey = 'ru',
                LocaleSidKey = 'ru_RU',
                TimeZoneSidKey = 'Europe/Moscow',
                EmailEncodingKey = 'UTF-8',
                Alias = 'inb01');
        insert user;
        return user;
    }

    private static Opportunity createOpportunityWithStatus(String name, String status, Id accId) {
        Opportunity oppt = E2EFormRuTestUtils.createOpportunity(accId);
        oppt.Name = name;
        oppt.StageName = status;
        oppt.CategoryContract__c = 'МО';
        return oppt;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock(Map<String, String> input) {

        String URL = 'http://99.240.174.55/PPRMiddleware';
        String TOKEN = 'token';

        //проверяем передали ли значения, если нет, то подставляем значения по умолчанию
        String inn = input.containsKey('inn') ? input.get('inn') : '1111111111';
        String sparkId = input.containsKey('sparkId') ? input.get('sparkId') : '6329708';
        String entrepreneurInn = input.containsKey('inn') ? input.get('inn') : '1111111111';
        String companyName = input.containsKey('companyName') ? input.get('companyName') : 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"';
        String opportunityId = input.containsKey('opportunityId') ? input.get('opportunityId') : '0066E0000058ZwnQAE';

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        //для отчета
        Map<String, String> responseHeadersPost = new Map<String, String>{
                'Authorization' => TOKEN,
                'Content-Type' => 'application/json',
                'Content-Disposition' => 'attachment; filename=merged.pdf'
        };
        SingleRequestMock getJSONGeneratedReport = new SingleRequestMock(
                200, 'Complete', 'Blob', responseHeaders);

        SingleRequestMock getJSONCompanyList = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430",' +
                        '"fullName":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                        '"address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                        '"industry":"Торговля розничная компьютерами, периферийными устройствами к ним и программным обеспечением в специализированных магазинах",' +
                        '"regionCode":null,"regionName":"Москва","manager":"Управляющая компания ТД НКТ, ООО",' +
                        '"okopfname":"Общества с ограниченной ответственностью","okopfcode":12300}]}',
                responseHeaders);

        SingleRequestMock getJSONEntrepreneurShortReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":{"sparkID":6329708,"status":{"isActing":true,"text":"Действующее","code":24},' +
                        '"dateReg":"2009-08-25T21:00:00.000+0000","fullNameRus":"Иванов Иван Иванович",' +
                        '"inn":"770605086143","ogrnip":"309774623800678","okpo":"0116896779",' +
                        '"okato":{"code":"45286596000","regionName":"Москва","regionCode":45},' +
                        '"birthDate":"1979-03-12T21:00:00.000+0000","birthPlace":"г. Москва",' +
                        '"okvedlist":{"okved":[{"code":"74.14","name":"Консультирование по вопросам коммерческой деятельности и управления","isMain":true},' +
                        '{"code":"51.16","name":"Деятельность агентов по оптовой торговле текстильными изделиями, одеждой, обувью, изделиями из кожи и меха","isMain":null},' +
                        '{"code":"51.42","name":"Оптовая торговля одеждой, включая нательное белье, и обувью","isMain":null},' +
                        '{"code":"51.47","name":"Оптовая торговля прочими непродовольственными потребительскими товарами","isMain":null},' +
                        '{"code":"52.4","name":"Прочая розничная торговля в специализированных магазинах","isMain":null},' +
                        '{"code":"52.42","name":"Розничная торговля одеждой","isMain":null},' +
                        '{"code":"52.48.39","name":"Специализированная розничная торговля прочими непродовольственными  товарами, не включенными в другие группировки","isMain":null},' +
                        '{"code":"52.61.2","name":"Розничная торговля, осуществляемая непосредственно при помощи телевидения, радио, телефона и Интернет","isMain":null},' +
                        '{"code":"74.40","name":"Рекламная деятельность","isMain":null},' +
                        '{"code":"80.42","name":"Образование для взрослых и прочие виды образования, не включенные в другие группировки","isMain":null}]}}}',
                responseHeaders);

        SingleRequestMock getJSONAccountReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API","content":[{"sparkID":6329708,' +
                        '"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430","shortName":"ООО \\"НКТ СОФТВЭР\\"",' +
                        '"period":{"form":[{"value":[{"value":65401,"code":"4110","name":"Поступления - всего","column":3},' +
                        '{"value":59395,"code":"4111","name":"от продажи продукции, товаров, работ и услуг","column":3},' +
                        '{"value":6006,"code":"4119","name":"прочие поступления","column":3},' +
                        '{"value":128394,"code":"4120","name":"Платежи - всего","column":3},' +
                        '{"value":692,"code":"4129","name":"прочие платежи","column":3},' +
                        '{"value":-62993,"code":"4100","name":"Сальдо денежных потоков от текущих операций","column":3},' +
                        '{"value":42585,"code":"4210","name":"Поступления - всего","column":3},' +
                        '{"value":20000,"code":"4310","name":"Поступления - всего","column":3},' +
                        '{"value":20000,"code":"4311","name":"получение кредитов и займов","column":3},' +
                        '{"value":20000,"code":"4300","name":"Сальдо денежных потоков от финансовых операций","column":3},' +
                        '{"value":-408,"code":"4400","name":"Сальдо денежных потоков за отчетный период","column":3},' +
                        '{"value":617,"code":"4490","name":"Величина влияния изменений курса иностранной валюты по отношению к рублю","column":3}],' +
                        '"id":4,"power":1000},{"value":[{"value":500,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":3},' +
                        '{"value":0,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":4},' +
                        '{"value":0,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":5},' +
                        '{"value":500,"code":"3300","name":"Величина капитала на 31 декабря отчетного года","column":3},' +
                        '{"value":0,"code":"3300","name":"Величина капитала на 31 декабря отчетного года","column":4},' +
                        '{"value":0,"code":"3300","name":"Величина капитала на 31 декабря отчетного года","column":5},' +
                        '{"value":30246,"code":"3600","name":"Чистые активы","column":3},' +
                        '{"value":83663,"code":"3600","name":"Чистые активы","column":4}],' +
                        '"id":3,"power":1000},{"value":[{"value":58467,"code":"2110","name":"Выручка","column":3},' +
                        '{"value":70261,"code":"2110","name":"Выручка","column":4},' +
                        '{"value":42,"code":"2120","name":"Себестоимость продаж","column":3},' +
                        '{"value":35,"code":"2120","name":"Себестоимость продаж","column":4},' +
                        '{"value":58425,"code":"2100","name":"Валовая прибыль (убыток)","column":3},' +
                        '{"value":124178,"code":"2220","name":"Управленческие расходы","column":4},' +
                        '{"value":-67977,"code":"2200","name":"Прибыль (убыток) от продаж","column":3},' +
                        '{"value":-53952,"code":"2200","name":"Прибыль (убыток) от продаж","column":4},' +
                        '{"value":-65676,"code":"2300","name":"Прибыль (убыток) до налогообложения","column":3},' +
                        '{"value":12257,"code":"2450","name":"Изменение отложенных налоговых активов","column":3},' +
                        '{"value":9735,"code":"2450","name":"Изменение отложенных налоговых активов","column":4},' +
                        '{"value":-53419,"code":"2400","name":"Чистая прибыль (убыток)","column":3},' +
                        '{"value":-45012,"code":"2400","name":"Чистая прибыль (убыток)","column":4},' +
                        '{"value":-53419,"code":"2500","name":"Совокупный финансовый результат периода","column":3},' +
                        '{"value":-45012,"code":"2500","name":"Совокупный финансовый результат периода","column":4}],' +
                        '"id":2,"power":1000},{"value":[{"value":144,"code":"1110","name":"Нематериальные активы","column":3},' +
                        '{"value":186,"code":"1110","name":"Нематериальные активы","column":4},' +
                        '{"value":30010,"code":"1180","name":"Отложенные налоговые активы","column":3},' +
                        '{"value":17753,"code":"1180","name":"Отложенные налоговые активы","column":4},' +
                        '{"value":8,"code":"1190","name":"Прочие внеоборотные активы","column":3},' +
                        '{"value":30246,"code":"1300","name":"Итого по разделу III","column":3},' +
                        '{"value":83663,"code":"1300","name":"Итого по разделу III","column":4},' +
                        '{"value":33,"code":"1420","name":"Отложенные налоговые обязательства","column":3},' +
                        '{"value":0,"code":"1420","name":"Отложенные налоговые обязательства","column":4},' +
                        '{"value":33,"code":"1400","name":"Итого по разделу IV","column":3},' +
                        '{"value":103041,"code":"1700","name":"БАЛАНС (пассив)","column":4}],' +
                        '"id":1,"power":1000}],"periodName":"2017","dateEnd":"2017-12-30T21:00:00.000+0000","dateBegin":"2016-12-31T21:00:00.000+0000"},' +
                        '"egrpoincluded":"true","egrullikvidation":null}]}',
                responseHeaders);

        SingleRequestMock getJSONExtendedReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":{"sparkID":6329708,"companyType":1,"status":{"date":"2018-07-31T21:00:00.000+0000","type":"Действующее","code":24},' +
                        '"isActing":"true","dateFirstReg":"2008-01-28","shortNameRus":"ООО \\"НКТ СОФТВЭР\\"","shortNameEn":"OOO \\"NKT SOFTVER\\"",' +
                        '"fullNameRus":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                        '"normName":"НКТ СОФТВЭР, ООО","inn":"7743676000","kpp":"771301001","ogrn":"1087746118162",' +
                        '"okpo":"84763430","rts":null,"okato":{"code":"45277586000","regionName":"Москва","regionCode":45},' +
                        '"okogu":{"code":"4210011","name":"Хозяйственные общества и товарищества с участием иностранных юридических и (или) физических лиц, а также лиц без гражданства"},' +
                        '"okfs":{"code":"34","name":"Совместная частная и иностранная собственность"},' +
                        '"okopf":{"code":"65","name":"Общества с ограниченной ответственностью","codeNew":"12300"},' +
                        '"charterCapital":"500000","leaderList":{"leader":[{"actualDate":"2012-11-05T21:00:00.000+0000",' +
                        '"fio":"Кремнев Антон Юрьевич","position":"президент","inn":null},{"actualDate":"2009-07-19T21:00:00.000+0000",' +
                        '"fio":"Лаврентьев Леонид Геннадьевич","position":"генеральный директор","inn":null},' +
                        '{"actualDate":"2008-01-27T21:00:00.000+0000","fio":"Еремин Игорь Юрьевич","position":"генеральный директор",' +
                        '"inn":"502408806323"}]},"legalAddresses":{"address":{"postCode":"127287","address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                        '"actualDate":"2018-04-27T21:00:00.000+0000","region":"г. Москва","rayon":null,"city":"г. Москва",' +
                        '"streetname":"ул. Хуторская 2-Я","buildingnumber":"дом 38А"}},"adjustAddress":null,' +
                        '"previousAddress":{"address":[{"postCode":"125195","address":"г. Москва, ул. Смольная, д. 20А",' +
                        '"actualDate":"2016-07-21T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Пяловская, д. 7 стр. 3",' +
                        '"actualDate":"2008-08-24T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Дегунинская, д. 10",' +
                        '"actualDate":"2008-01-27T21:00:00.000+0000"}]},"phoneList":{"phone":[{"code":"495","number":7887921,"status":null},' +
                        '{"code":"495","number":7887922,"status":null}]},"faxList":null,"email":null,"www":null,"workersRange":null,' +
                        '"includeInList":{"listName":[{"value":"Компании, отсутствующие по юр. адресу по данным ФНС","id":13,"isNegative":1}]},' +
                        '"creditRisk":null,"failureScore":{"failureScoreValue":"85","failureScoreDesc":"Средний риск"},' +
                        '"paymentIndex":null,"federalTaxRegistration":{"regDate":"2008-01-27T21:00:00.000+0000",' +
                        '"regAuthority":"Межрайонная инспекция ФНС России №46 по г.Москве","regAuthorityAddress":"125373,Москва г,Походный проезд, домовладение 3, стр.2"},' +
                        '"structureInfo":{"countCoownerFCSM":0,"countCoownerRosstat":2,"countCoownerEGRUL":2,"countBranch":0,' +
                        '"countBranchRosstat":0,"countAffiliatedCompanyFCSM":0,"countAffiliatedCompanyRosstat":0,' +
                        '"countAffiliatedCompanyEGRUL":0,"nonprofitOrganizationRosstat":0},"vestnikMessage":null,' +
                        '"bankruptcyMessage":null,"accessibleFinData":{"period":[{"name":"2017","endDate":"2017-12-30T21:00:00.000+0000",' +
                        '"idperiod":547},{"name":"2016","endDate":"2016-12-30T21:00:00.000+0000","idperiod":543},' +
                        '{"name":"2008","endDate":"2008-12-30T21:00:00.000+0000","idperiod":323}]},' +
                        '"finance":{"finPeriod":[{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы",' +
                        '"code":"1110","value":"589000"},{"form":"Баланс","section":"Актив","name":"Основные средства","code":"1150","value":"1064000"},' +
                        '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                        '{"form":"Отчет о прибыли и убытках","section":"Операционные доходы и расходы","name":"Чистая прибыль (убыток)","code":"2400","value":"124078000"}]},' +
                        '"periodName":"2016","dateBegin":"2015-12-31T21:00:00.000+0000","dateEnd":"2016-12-30T21:00:00.000+0000"},' +
                        '{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы","code":"1110","value":"144000"},' +
                        '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                        '{"form":"Отчет о прибыли и убытках","section":"Доходы и расходы по обычным видам деятельности","name":"Выручка","code":"2110","value":"58467000"}]},' +
                        '"periodName":"2017","dateBegin":"2016-12-31T21:00:00.000+0000","dateEnd":"2017-12-30T21:00:00.000+0000"}]},' +
                        '"companyWithSameInfo":{"telephoneCount":{"value":26,"phoneCode":"495","phoneNumber":"7887922"},' +
                        '"addressCount":12,"managerCountInCountry":0,"managerCountInRegion":0},' +
                        '"indexOfDueDiligence":{"index":"1","indexDesc":"Низкий риск"},"companySize":{"revenue":"58,50","description":"Микропредприятие"},' +
                        '"eventsList":null,"boardOfDirectors":null,"executiveBody":{"member":[{"name":"ТД НКТ, ООО","inn":"7743857461",' +
                        '"birthdayYear":null,"position":{"name":"Внешний исполнительный орган","code":0},"sharePart":null}],' +
                        '"actualDate":"2012-11-05T21:00:00.000+0000"},"personsWithoutWarrant":null,"stateContracts":{"federalLaw94":null,' +
                        '"federalLaw223":{"year":[{"tenders":{"admittedNumber":0,"notAdmittedNumber":0,"winnerNumber":0},' +
                        '"contracts":{"signedNumber":1,"sum":"1980645"},"year":2016},{"tenders":{"admittedNumber":8,"notAdmittedNumber":0,"winnerNumber":8},' +
                        '"contracts":{"signedNumber":2,"sum":"1928417"},"year":2015}]}},' +
                        '"arbitrationCases":{"year":[{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":2,"sum":"42854"},' +
                        '"thirdOrOtherPerson":{"casesNumber":0},"year":"2017"},{"plaintiff":{"casesNumber":0,"sum":"0"},' +
                        '"defendant":{"casesNumber":2,"sum":"1259266"},"thirdOrOtherPerson":{"casesNumber":0},"year":"2014"},' +
                        '{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},"thirdOrOtherPerson":{"casesNumber":1},' +
                        '"year":"2013"},{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},' +
                        '"thirdOrOtherPerson":{"casesNumber":0},"year":"2011"}]},"egrullikvidation":null,' +
                        '"okvedlist":{"okved":[{"code":"52.48.13","name":"Розничная торговля компьютерами, программным обеспечением и периферийными устройствами","isMain":true},' +
                        '{"code":"30.02","name":"Производство электронных вычислительных машин и прочего оборудования для обработки информации","isMain":null},' +
                        '{"code":"51.14.2","name":"Деятельность агентов по оптовой торговле прочими видами машин и оборудования","isMain":null},' +
                        '{"code":"51.43.22","name":"Оптовая торговля техническими носителями информации (с записями и без записей)","isMain":null},' +
                        '{"code":"72.2","name":"Разработка программного обеспечения и консультирование в этой области","isMain":null},' +
                        '{"code":"72.3","name":"Обработка данных","isMain":null},' +
                        '{"code":"74.3","name":"Технические испытания, исследования и сертификация","isMain":null}]},"egrpoincluded":"true","fcsmcode":null}}',
                responseHeaders);

        SingleRequestMock getJSONCompanyAccountingReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430","shortName":"ООО \\"НКТ СОФТВЭР\\"",' +
                        '"period":{"form":[{"value":[{"value":65401,"code":"4110","name":"Поступления - всего","column":3},' +
                        '{"value":617,"code":"4490","name":"Величина влияния изменений курса иностранной валюты по отношению к рублю","column":3}],' +
                        '"id":4,"power":1000},{"value":[{"value":500,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":3},' +
                        '{"value":83663,"code":"3600","name":"Чистые активы","column":4}],' +
                        '"id":3,"power":1000},{"value":[{"value":58467,"code":"2110","name":"Выручка","column":3},' +
                        '{"value":-45012,"code":"2500","name":"Совокупный финансовый результат периода","column":4}],' +
                        '"id":2,"power":1000},{"value":[{"value":144,"code":"1110","name":"Нематериальные активы","column":3},' +
                        '{"value":103041,"code":"1700","name":"БАЛАНС (пассив)","column":4}],' +
                        '"id":1,"power":1000}],"periodName":"2017","dateEnd":"2017-12-30T21:00:00.000+0000",' +
                        '"dateBegin":"2016-12-31T21:00:00.000+0000"},"egrpoincluded":"true","egrullikvidation":null}]}',
                responseHeaders);

        SingleRequestMock getJSONCompanyVerification = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"decision":3,"limitation":0,"blackListType":[10],"sfrequestId":"0066E0000058YwnQAE"}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecision = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"decision":3,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}}',
                responseHeaders);


        //для отчёта
        SingleRequestMock getJSONReportIdsFromCreditFactory = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode": 200,"message": "Reports Integration",' +
                        '"content": {"reportDocumentList": [' +
                        '{"idReport": "10007", "reportTypeDescription": "Договор-оферта", "reportTypeId": "1", "path": {"PDF": "8897506c-a5f9-421e-ac40-53347a59c9b3"}}],' +
                        '"reportParams": {"WARRANT_NUM": "21-01/18","WARRANT_FIO": "Козлова Марина Михайловна",' +
                        '"WARRANT_DATE": "01.01.2018","USERNAME": "sdfsdfsd@sadsd.ru","SUPPLIER": "",' +
                        '"SPECIAL_OFFER_NAME": "","SECURITY_PHRASE": "ываыва","SALESFORCE_CONTRACT_PREFIX": "4",' +
                        '"SALESFORCE_CONTRACT_COUNTER": "500","PROMOCODE": "","PRODUCT_NAME": "Вездеход Online Избранный",' +
                        '"NUMBER_OF_CARDS_TEXT": "Десять","NUMBER_OF_CARDS": "7","HAS_PERSONAL_MANAGER": "1",' +
                        '"HAS_OVERDRAFT": "1","HAS_COURIER": "1","EXTRA_INFO": " ","EXT_CLIENT_ID": "0066E000005OzgbQAC",' +
                        '"CONTRACT_NUM": null,"CONTRACT_DATE": "«11» сентября 2018 г.","CONSIGNEE_PHONE": "ГП+7495112",' +
                        '"CONSIGNEE_OKPO": "ГП_ОКПО","CONSIGNEE_OGRN": "ГП_ОГРН","CONSIGNEE_NAME": "ГП_НАЗВАНИЕ",' +
                        '"CONSIGNEE_MOB_PHONE_INFO": "ГП+77778944","CONSIGNEE_MOB_PHONE_FIN": "ГП+71112233",' +
                        '"CONSIGNEE_LEGAL_ADDRESS": "ул. ГП-ю","CONSIGNEE_KPP": "ГП_КПП","CONSIGNEE_INN": "ГП_ИНН",' +
                        '"CONSIGNEE_EMAIL": "gp@mail.ru","CONSIGNEE_CURRENT_ACCOUNT": "ГП_РС","CONSIGNEE_COR_ACCOUNT": "КС_ГП",' +
                        '"CONSIGNEE_BIK": "ГП_BIC","CONSIGNEE_BANK_NAME": "ГП СБЕР","CONSIGNEE_ADDRESS": "ул. ГП-ф",' +
                        '"CLIENT_SIGNER_POST": "генеральный директор","CLIENT_SIGNER_FIO": "Самсонов Борис Павлович",' +
                        '"CLIENT_PHONE": "+7 (574) 645-64-53","CLIENT_OKPO": "03341078","CLIENT_OGRN": "1078602000443",' +
                        '"CLIENT_NAME": "ОТКРЫТОЕ АКЦИОНЕРНОЕ ОБЩЕСТВО СУРГУТСКИЙ ПРОИЗВОДСТВЕННО-НАУЧНЫЙ ИНСТИТУТ ИНЖЕНЕРНЫХ ИЗЫСКАНИЙ В СТРОИТЕЛЬСТВЕ",' +
                        '"CLIENT_MOB_PHONE_INFO": "+7 (574) 645-64-53","CLIENT_MOB_PHONE_FIN": "+7 (574) 645-64-53",' +
                        '"CLIENT_LEGAL_ADDRESS": "Ханты-Мансийский Автономный Округ - Югра окр, г. Сургут, ул. 30 Лет Победы, д. 29 корп. Б",' +
                        '"CLIENT_KPP": "860201001","CLIENT_INN": "8602024490","CLIENT_EMAIL": "sdfsdfsd@sadsd.ru",' +
                        '"CLIENT_CURRENT_ACCOUNT": "23412341234323333333","CLIENT_COR_ACCOUNT": "30101810400000000225",' +
                        '"CLIENT_BIK": "044525225","CLIENT_BANK_NAME": "ПАО СБЕРБАНК",' +
                        '"CLIENT_ADDRESS": "Ханты-Мансийский Автономный Округ - Югра окр, г. Сургут, ул. 30 Лет Победы, д. 29 корп. Б",' +
                        '"CLIENT_ACCOUNTER_FIO": "ываываыва","BUSINESSMAN_REGISTERED_ADDRESS": "","BUSINESSMAN_PASSPORT_SERIES": "",' +
                        '"BUSINESSMAN_PASSPORT_NUM": "","BUSINESSMAN_PASSPORT_ISSUING_NUMBER": "","BUSINESSMAN_PASSPORT_ISSUING": "",' +
                        '"BUSINESSMAN_PASSPORT_DATE": "","BUSINESSMAN_OGRNIP": "","BIRTH_YEAR": "","BIRTH_PLACE": "","BILL_SUM": "14000",' +
                        '"ATTACHMENT_NUM": "1","ADDITIONAL_CONTRACT_DATE": "«11» сентября 2018 г.","PAY_ACCOUNT": "40702810500030004523",' +
                        '"SIGNATORY_ACCOUNTANT_WARRANT": " на осн. доверенности №21-01/18 от 01.01.2018","IS_GPN_FROM_CARD": "0",' +
                        '"SIGNATORY_LEADER_WARRANT": " на осн. доверенности №21-01/18 от 01.01.2018",' +
                        '"SELLER_LEGAL_ADDRESS": "127287, Россия, г. Москва, ул. 2-я Хуторская, д. 38А, стр. 8",' +
                        '"SIGNATORY_ACCOUNTANT_FIO": "Козлова М.М.","IS_VEZDEHOD_CHOSEN_FROM_CARD": "0","ROOT_DIR": "",' +
                        '"STAMP_FILE": "","SIGNATORY_LEADER_POST": "Старший специалист","SALESFORCE_INVOICE_PREFIX": "444",' +
                        '"SALESFORCE_INVOICE_COUNTER": "401","SELLER_KPP": "771301001","IS_SHELL_FROM_CARD": "0",' +
                        '"SELLER_INN": " 7743036465","SIGNATURE_FILE": "","HAS_CREDIT": "1","IS_VEZDEHOD_CHOSEN_FROM_CONTRACT": "1",' +
                        '"NEED_SIGNATURE": "0","SIGNATORY_LEADER_FIO": "Козлова М.М.","WARRANT_FIO_R": "Козловой Марины Михайловны",' +
                        '"IS_SHELL_FROM_CONTRACT": "0","SIGNATORY_ACCOUNTANT_POST": "Старший специалист","IS_VEZDEHOD_OPTIMAL_FROM_CONTRACT": "0",' +
                        '"IS_VEZDEHOD_OPTIMAL_FROM_CARD": "0","SELLER_NAME": "ООО ППР","IS_GPN_FROM_CONTRACT": "0","ATTACHMENTS_COUNT": "4"}}}',
                responseHeadersPost);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();

        //ссылки для корректный ответов. Результат скоринга 3.
        responses.put(URL + '/spark/company-list?inn=' + inn + '&onlyMain=true', getJSONCompanyList);
        responses.put(URL + '/spark/entrepreneur-short-report?inn=' + entrepreneurInn, getJSONEntrepreneurShortReport);
        responses.put(URL + '/spark/company-accounting-report?inn=' + inn + '&sparkId=' + sparkId, getJSONAccountReport);
        responses.put(URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId, getJSONExtendedReport);
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONCompanyVerification);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONScoringDecision);

        //для отчета
        responses.put(URL + '/reporting/prepare-reports', getJSONReportIdsFromCreditFactory);
        /*responses.put(URL + '/reporting/get-generated-report?ids=8897506c-a5f9-421e-ac40-53347a59c9b3,' +
                '3fafee10-6910-4d20-970e-eb7b8b0feb85,9694ad3b-9b3c-4531-aa91-c286868cd948,3028408c-b5fb-41b8-96e7-9bb0692065f8,' +
                'a30c2d25-0183-4a26-b8fb-066917bd4be4,a9843c26-5047-4790-b1c4-5b883c8b49a6,02bbb8b3-4516-4f84-8f79-c3076a2ce1cb', getJSONGeneratedReport);*/
        responses.put(URL + '/reporting/get-generated-report?ids=8897506c-a5f9-421e-ac40-53347a59c9b3', getJSONGeneratedReport);


        return responses;
    }

    private static void addLoggerRecipient() {
        insert new Logger_Recipient__c(
                Active__c = true,
                Name = '0050O000006erZE'
        );
    }

    private static void insertSomePromocodes() {
        insert new E2E_Promocodes__c(
                Name = 'test01',
                Product_Name__c = 'Не будет в списке',
                Promocode_Additional_Field__c = 'Роснефть (вкл.  Башнефть, ТНК)@109;Лукойл@110;Газпромнефть@111;Татнефть@112;Shell@113',
                Promocode_Description_Body__c = 'Условия действуют до истечения 3 (трех) календарных месяцев от даты договора. ' +
                        'Месяц даты договора считается 1 (первым) календарным месяцем для исчисления сроков, даже если он будет не полным.',
                Promocode_Description_Title__c = 'Скидка 1 руб./л топлива на одной из сетей АЗС на Ваш выбор: <br> • ' +
                        '«Роснефть» («Башнефть», ТНК), <br> • «ЛУКОЙЛ», <br> • «Газпромнефть», <br> • «Татнефть», <br> • Shell.<br>',
                Promocode_Label__c = 'Акция «Запас Прочности»',
                Report_Identifiers__c = '110@1;109@2;113@3;111@4;112@6',
                Supplier_Selection__c = 'True',
                Apply_to_tariffs__c = '1234;4444;3333;3334'
        );

        insert new E2E_Promocodes__c(
                Name = 'test02',
                Product_Name__c = 'Будет в списке 02',
                Promocode_Additional_Field__c = 'Роснефть (вкл.  Башнефть, ТНК)@666;Лукойл@110;Газпромнефть@111;Татнефть@112;Shell@113',
                Promocode_Description_Body__c = 'Условия действуют до истечения 3 (трех) календарных месяцев от даты договора. ' +
                        'Месяц даты договора считается 1 (первым) календарным месяцем для исчисления сроков, даже если он будет не полным.',
                Promocode_Description_Title__c = 'Скидка 1 руб./л топлива на одной из сетей АЗС на Ваш выбор: <br> • ' +
                        '«Роснефть» («Башнефть», ТНК), <br> • «ЛУКОЙЛ», <br> • «Газпромнефть», <br> • «Татнефть», <br> • Shell.<br>',
                Promocode_Label__c = 'Акция «Запас Прочности»',
                Report_Identifiers__c = '110@1;109@2;113@3;111@4;112@6',
                Supplier_Selection__c = 'True',
                Apply_to_tariffs__c = '7E10'
        );

        insert new E2E_Promocodes__c(
                Name = 'test03',
                Product_Name__c = 'Будет в списке 03',
                Promocode_Additional_Field__c = 'Роснефть (вкл.  Башнефть, ТНК)@109;Лукойл@110;Газпромнефть@111;Татнефть@112;Shell@113',
                Promocode_Description_Body__c = 'Условия действуют до истечения 3 (трех) календарных месяцев от даты договора. ' +
                        'Месяц даты договора считается 1 (первым) календарным месяцем для исчисления сроков, даже если он будет не полным.',
                Promocode_Description_Title__c = 'Скидка 1 руб./л топлива на одной из сетей АЗС на Ваш выбор: <br> • ' +
                        '«Роснефть» («Башнефть», ТНК), <br> • «ЛУКОЙЛ», <br> • «Газпромнефть», <br> • «Татнефть», <br> • Shell.<br>',
                Promocode_Label__c = 'Акция «Запас Прочности»',
                Report_Identifiers__c = '110@1;109@2;113@3;111@4;112@6',
                Supplier_Selection__c = 'True',
                Apply_to_tariffs__c = '1234;4444;7E10;3334'
        );
    }
}
