public class E2EFormRuTestUtils {
    public static LongForm__c longFormRU { get; set; }
    public static String INN = '1111111111';
    public static String secondINN = '2222222222';
    public static String email = 'test@test.ru';
    public static String phone = '+79265444341';
    public static String name = 'testCompany';
    public static String domains = 'email.com';

    public static void initCustomSettings() {
        insert new E2E_Form_Ru_General_Settings__c(
                Name = 'E2EFormRu',
                Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Test_Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Middleware_Token__c = 'token',
                AES256_key__c = 'F3kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                Call_Center_Managers__c = 'Andrey Moiseev;',
                Domain_Url__c = 'https://cs85.salesforce.com',
                External_Call_Center_Managers__c = 'test@test.example.ru;',
                External_Inbound_Managers__c = 'test@test.example.ru;',
                External_Main_Managers__c = 'test@test.example.ru;',
                External_Service_Managers__c = 'test@test.example.ru;',
                Inbound_Managers__c = 'Andrey Moiseev;',
                Locator_Gaz_url__c = 'https://locator.transitcard.ru/?product=180',
                Locator_Rover_url__c = 'https://locator.transitcard.ru/?product=170',
                Locator_Shell_url__c = 'https://locator.transitcard.ru/?product=190',
                Main_Managers__c = 'Andrey Moiseev;Anna Rudas;Ilya Ivonin;',
                Number_Of_Cards__c = 10,
                Number_of_Cards_Card__c = 6,
                Prepay_Amount__c = 2000,
                Send_To_Inbound__c = true,
                Service_Managers__c = 'Andrey Moiseev;'
        );

        insert new E2E_Form_Transit_Settings__c(
                Name = 'E2EFormRu',
                Allowed_Debt_Currency__c = 0,
                Allowed_Debt_Sum__c = 50000,
                Article_Oplata_Po_Dogovoru__c = 'Оплата по договору от {0} № {1}-{2}',
                Bez_DS__c = 'N',
                Car_Park_Type__c = 1,
                Car_Park_Vid__c = 0,
                Client_Came_From__c = 11,
                Contract_Form__c = 'CNT_FRM_TYPICAL',
                Contract_Type_Commerce__c = 'CNT_SLS_OFFERS',
                Contract_Type_Fin_Multioffer__c = 16,
                Contract_Type_Fin_Overdraft__c = 17,
                Contract_Type_Service__c = 'CNT_MULTY_OFFER',
                Cont_Rek_Type__c = 0,
                Credit_Percent__c = 0.0900,
                Credit_Type__c = 1,
                Id_Eqv__c = 1,
                Lgotniy_Period__c = 0,
                Notify_By_Email__c = '',
                On_Basis_Svidetelstva__c = 'На основании свидетельства {0} от {1}',
                On_Basis_Ustava__c = 'Устава',
                Order_Of_Conditions_Change__c = '',
                Overdraft_Sum__c = -50000,
                Overdraft_Value__c = -50000,
                Payment_For_Overdue__c = 890,
                Standard_Promos__c = '140;',
                Type_Peni__c = 'PERCENT_RATE_D',
                Usluga_Doveria__c = 'N',
                VAT__c = 0.1800,
                Value_Peni__c = 0.1000
        );

        insert new E2E_Form_MZK_Settings__c(
                Name = 'E2EFormRu',
                Description__c = 'Аи98/Аи95/Аи92/V-Power/Премиум95/Пульсар95/Пульсар92/G-Drive/G98/Премиум92 – 50 литров/сутки общий кошелек ' +
                        'Дт/Дт2/Дт арктика/Дт супер/Дт Евро – 100 литров/сутки общий кошелекСПБТ - 50 литров/сутки индивидуальный кошелек',
                Is_Common__c = '1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0',
                Is_Ruble__c = '0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0',
                Limit_Type_Ids__c = '1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1',
                Limit_Values__c = '50;50;50;50;50;50;50;50;50;50;100;100;100;100;100;50',
                Log_User__c = '93D6ED45932B44A4AE8AF3934AC1C940',
                Service_Groups__c = '1;1;1;1;1;1;1;1;1;1;2;2;2;2;2;3;',
                Service_Ids__c = '3;4;5;51;70;82;97;193;273;296;7;8;33;52;104;47',
                Total_Limit_Type__c = null,
                Total_Limit_Value__c = null,
                Send_Type__c = 3
        );

        insert new E2E_Ru_Product_Settings__c(
                Name = 'PetrolPlus_Rover',
                Chosen_Card__c = 7,
                Chosen_Contract__c = 8,
                Optimal_Card__c = 1,
                Optimal_Contract__c = 2,
                Product_Id__c = 62
        );

        insert new E2E_Form_CRM_Settings__c(
                Name = 'E2EFormRu',
                Task_Case_Origin_Code__c = 2,
                Task_OwnerId__c = '5b5589ec-e1b6-e611-80e2-005056bd4e10',
                Task_SubjectId__c = '628c49df-7dfa-e511-80d5-005056bd4e10',
                Task_Title__c = 'Базовый клиент из e2e'
        );

        insert new E2E_Promocodes__c(
                Name = '7E10',
                Product_Name__c = 'Вездеход Online',
                Promocode_Additional_Field__c = 'Роснефть (вкл.  Башнефть, ТНК)@109;Лукойл@110;Газпромнефть@111;Татнефть@112;Shell@113',
                Promocode_Description_Body__c = 'Условия действуют до истечения 3 (трех) календарных месяцев от даты договора. ' +
                        'Месяц даты договора считается 1 (первым) календарным месяцем для исчисления сроков, даже если он будет не полным.',
                Promocode_Description_Title__c = 'Скидка 1 руб./л топлива на одной из сетей АЗС на Ваш выбор: <br> • ' +
                        '«Роснефть» («Башнефть», ТНК), <br> • «ЛУКОЙЛ», <br> • «Газпромнефть», <br> • «Татнефть», <br> • Shell.<br>',
                Promocode_Label__c = 'Акция «Запас Прочности»',
                Report_Identifiers__c = '110@1;109@2;113@3;111@4;112@6',
                Supplier_Selection__c = 'True',
                Promocode_Classic_Label__c = 'Акция «Запас Прочности»'
        );

        FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365,
                Penalty_for_refusal_Telesales__c = 60
        );
        insert fieldSalesSettings;
    }

    //******* Account ********//

    public static Account createDefaultAccount() {
        Account account = new Account(
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Russian'),
                Name = 'E2E RU Account Test',
                BillingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                ShippingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                Type = 'Customer',
                AccountSource = 'E2E Form RU'
        );
        return account;
    }

    public static Account createAccount(String INN, Date lastPumpDate, Date firstCardTransaction) {
        Account account = createDefaultAccount();
        account.INN__c = INN;
        account.Company_Legal_Name1__c = '';
        account.Last_pump_date__c = lastPumpDate;
        account.Date_first_card_transaction__c = firstCardTransaction;
        return account;
    }

    public static Account insertAccount(Account account) {
        insert account;
        return account;
    }

    public static Account createAccountWithData(Map<String, LongFormPage> pagesMap, E2EFormParams formParams) {
        Account account = createDefaultAccount();

        String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value;
        String INN = pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value;

        account.Name = GlobalUtils.blankStringIfNull(accountName);
        if (formParams.verifiedDecisionCode != '4') { // костыль чтобы не сохранять INN
            account.INN__c = GlobalUtils.blankStringIfNull(INN);
        }

        // Save Address
        account.BillingPostalCode = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
        account.BillingCity = GlobalUtils.blankStringIfNull(formParams.citySpark);
        String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
        String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
        String housing = formParams.housingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.housingSpark);
        String block = formParams.blockSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.blockSpark);
        String room = formParams.roomSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.roomSpark);
        account.BillingStreet = street + building + housing + block + room;
        account.Region__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);

        // Save OKPO
        String OKPO = formParams.okpoSpark;
        account.OKPO_ppr__c = OKPO;

        // Save OGRN, KPP, Organization Type
        if (formParams.isSoleProprietor == true) {
            String OGRNIP = formParams.ogrnipSpark;
            account.OGRN_ppr__c = OGRNIP;
            account.Organization_Type__c = 'ИП';
        } else {
            String OGRN = formParams.ogrnSpark;
            String KPP = formParams.kppSpark;
            account.OGRN_ppr__c = OGRN;
            account.KPP__c = Decimal.valueOf(KPP);
            account.Organization_Type__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(1);
        }


        String codeWord = pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value;

        String legalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value;
        String legalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
        String legalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
        String legalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value;
        String legalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').value;

        String postalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').value;
        String postalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').value + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
        String postalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
        String postalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').value;

        account.OKPO_ppr__c = GlobalUtils.blankStringIfNull(OKPO);
        account.Code_Word__c = GlobalUtils.blankStringIfNull(codeWord);

        // legal address
        account.BillingCountry = GlobalUtils.blankStringIfNull(legalAddressCountry);
        account.BillingCity = GlobalUtils.blankStringIfNull(legalAddressCity);
        account.BillingStreet = GlobalUtils.blankStringIfNull(legalAddressStreet);
        account.BillingPostalCode = GlobalUtils.blankStringIfNull(legalAddressPostalCode);
        account.Region__c = GlobalUtils.blankStringIfNull(legalAddressState);

        // postal address
        account.ShippingCountry = GlobalUtils.blankStringIfNull(postalAddressCountry);
        account.ShippingCity = GlobalUtils.blankStringIfNull(postalAddressCity);
        account.ShippingStreet = GlobalUtils.blankStringIfNull(postalAddressStreet);
        account.ShippingPostalCode = GlobalUtils.blankStringIfNull(postalAddressPostalCode);

        String checkingAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;
        String bank = pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value;
        String BIC = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value;
        String corBankAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;

        account.Checking_Account__c = GlobalUtils.blankStringIfNull(checkingAccount);
        account.Bank__c = GlobalUtils.blankStringIfNull(bank);
        account.SWIFT_BIC__c = GlobalUtils.blankStringIfNull(BIC);
        account.Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(corBankAccount);

        return account;
    }


    //******* Contact ********//

    public static Contact createContact(Id accountId) {
        Contact contact = new Contact(
                RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                Salutation = 'Mr.',
                LeadSource = 'E2E Form RU',
                AccountId = accountId,
                FirstName = 'Contact Test',
                LastName = 'E2E',
                Phone = '+7 9222333322',
                MobilePhone = '+7 9222333322',
                Email = 'e2etest@e2etest.ru',
                Title = 'генеральный директор',
                PD_Avaliable_LastName_Update__c = true
        );
        return contact;
    }

    public static Contact createContact(Id accountId, String phone, String email) {
        Contact contact = createContact(accountId);
        contact.Phone = phone;
        contact.MobilePhone = phone;
        contact.Email = email;
        return contact;
    }

    public static Contact createDefaultContact() {
        Account account = createDefaultAccount();
        insert account;
        return createContact(account.Id);
    }

    public static Contact insertContact(Contact contact) {
        insert contact;
        return contact;
    }

    //******* Opportunity ********//

    public static Opportunity createOpportunity(Id accountId) {
        Opportunity opportunity = new Opportunity(
                Name = 'E2E Opportunity Test',
                StageName = 'Qualified Lead',
                AccountId = accountId,
                CloseDate = GlobalUtils.addBusinessDays(Date.today(), 5),
                LeadSource = 'E2E Form RU',
                Lead_Source_TypeOpp__c = 'Webform',
                Source_of_Lead_o__c = 'E2E Form RU',
                Source_if_self_sourced_c__c = 'E2E Form RU',
                Source_PP__c = 'test',
                PPR_First_Contact_Inbound_Outbound__c = 'Inbound Website',
                Channel__c = 'Internet',
                RecordTypeId = GlobalUtils.getRecordTypeId('Opportunity', 'Russian_Sales'),
                E2E_Active_Substep__c = '',
                E2E_Last_Activity__c = Datetime.now(),
                E2E_Status__c = 'Клиент Активен',
                E2E_Sales_Type__c = 'Чистый e2e',
                Projected_Liters_weekly__c = 88.00,
                Projected_amount_in_rub_month__c = 55535.35,
                Number_of_cars__c = 2,
                Number_of_trucks__c = 1,
                Business_process__c = GlobalUtils.BusinessProcessType.E2EClassic.name(),
                Personal_office_phone__c = '+7 999 111 22 22',
                Product_PPR__c = 'Супер 2020 с карты',
                Transit_ID__c = '123456789'
        );
        return opportunity;
    }

    public static Opportunity createOpportunity(Id accountId, String stageName, Date closeDate) {
        Opportunity opportunity = createOpportunity(accountId);
        opportunity.StageName = stageName;
        opportunity.closeDate = closeDate;
        return opportunity;
    }

    public static Opportunity createOpportunity(Id accountId, String stageName, Date closeDate, User owner) {
        Opportunity opportunity = createOpportunity(accountId);
        opportunity.StageName = stageName;
        opportunity.closeDate = closeDate;
        opportunity.OwnerId = owner.Id;
        return opportunity;
    }

    public static Opportunity createDefaultOpportunity() {
        Account account = createDefaultAccount();
        insert account;
        return createOpportunity(account.Id);
    }

    public static Opportunity insertOpportunity(Opportunity opportunity) {
        insert opportunity;
        return opportunity;
    }

    //******* FormData ********//

    public static E2EFormData__c createDefaultFormData() {
        E2EFormData__c formData = new E2EFormData__c(
                E2E_Contact_Phone__c = '+7 916 222 33 22',
                E2E_Contact_Email__c = 'e2etest@e2etest.ru',
                E2E_Send_Marketing_Email__c = true,
                E2E_Process_Personal_Data__c = true,
                E2E_IP_Address__c = '99.240.174.55',
                E2E_Last_Step__c = GlobalUtils.E2ERuSteps.ContactDetails.name()
        );
        return formData;
    }

    public static E2EFormData__c createFormData(Id accountId, Id contactId, Id opportunityId) {
        E2EFormData__c formDataRecord = createDefaultFormData();
        formDataRecord.E2E_Account_Id__c = accountId;
        formDataRecord.E2E_Contact_Id__c = contactId;
        formDataRecord.E2E_Opportunity_Id__c = opportunityId;
        return formDataRecord;
    }

    public static E2EFormData__c insertFormData(E2EFormData__c formData) {
        insert formData;
        return formData;
    }

    public static E2EFormData__c createFormDataWithData(Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String source) {
        E2EFormData__c formDataRecord = createDefaultFormData();

        // STEP ContactDetails
        String phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value;
        String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
        Boolean sendMarketingEmail = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value);
        Boolean processPersonalData = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value);

        if (processPersonalData) {
            formDataRecord.E2E_Contact_Email__c = email;
        }
        formDataRecord.E2E_Contact_Phone__c = GlobalUtils.blankStringIfNull(phone);
        formDataRecord.E2E_Send_Marketing_Email__c = sendMarketingEmail;
        formDataRecord.E2E_Process_Personal_Data__c = processPersonalData;
        formDataRecord.E2E_Account_Id__c = GlobalUtils.blankStringIfNull(accountId);
        formDataRecord.E2E_Contact_Id__c = GlobalUtils.blankStringIfNull(contactId);
        formDataRecord.E2E_Opportunity_Id__c = GlobalUtils.blankStringIfNull(opportunityId);

        // STEP CompanyInformation
        String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value;
        String INN = pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value;
        Boolean isEntryManual = Boolean.valueOf(pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value);

        if (formParams.isSoleProprietor == true) {
            formDataRecord.E2E_Account_Short_Name__c = formParams.mainCompanyFullNameSpark.removeStart('ИП ');
            formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(formParams.soleProprietorFio) + ', ' + 'Индивидуальный предприниматель';
        } else {
            formDataRecord.E2E_Account_Short_Name__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(0);
            String executiveFio = GlobalUtils.blankStringIfNull(formParams.executiveFio);
            String executivePosition = formParams.executivePosition == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.executivePosition);
            formDataRecord.E2E_Executive_Person__c = executiveFio + executivePosition;
        }

        formDataRecord.E2E_Account_Name__c = GlobalUtils.blankStringIfNull(accountName);
        formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);
        formDataRecord.E2E_INN__c = GlobalUtils.blankStringIfNull(INN);
        formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnSpark);
        formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(formParams.kppSpark);
        formDataRecord.E2E_Manual_Entry__c = isEntryManual;
        formDataRecord.E2E_Spark_Id__c = GlobalUtils.blankStringIfNull(String.valueOf(formParams.sparkId));
        formDataRecord.E2E_Main_Company_Full_Name__c = GlobalUtils.blankStringIfNull(formParams.mainCompanyFullNameSpark);
        formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
        formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);
        formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(formParams.citySpark);
        String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
        String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
        String housing = formParams.housingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.housingSpark);
        String block = formParams.blockSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.blockSpark);
        String room = formParams.roomSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.roomSpark);
        formDataRecord.E2E_Billing_Str__c = street + building;
        formDataRecord.E2E_Billing_Apartment__c = housing + block + room;
        formDataRecord.E2E_Legal_Address__c = GlobalUtils.blankStringIfNull(formParams.legalAddressSpark);
        formDataRecord.E2E_Black_List_Code__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecisionCode);
        formDataRecord.E2E_Black_List__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecision);
        formDataRecord.E2E_Black_List_Limitations__c = GlobalUtils.blankStringIfNull(formParams.verifiedLimitation);
        formDataRecord.E2E_Scoring_Decision_Code__c = GlobalUtils.blankStringIfNull(formParams.scoringDecisionCode);
        formDataRecord.E2E_Scoring_Decision__c = GlobalUtils.blankStringIfNull(formParams.scoringDecision);
        formDataRecord.E2E_Scoring_Date__c = formParams.scoringDate;
        formDataRecord.E2E_Scoring_Expiration_Date__c = formParams.scoringDate == null ? null : formParams.scoringDate.addMonths(3);
        formDataRecord.E2E_Dedup_Status__c = GlobalUtils.blankStringIfNull(formParams.deduplicationStatus);
        formDataRecord.E2E_Dedup_Status_Info__c = GlobalUtils.blankStringIfNull(formParams.deduplicationStatusInfo);
        // STEP Order
        String product = pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value + '';
        String tariff = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').value;
        String tariffId = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value;
        Integer numberOfCards = Integer.valueOf(pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value);
        String promoCode = pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value;
        String paymentCondition = pagesMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').value;
        Boolean needPersonalManager = Boolean.valueOf(pagesMap.get('ORDER').fields.get('PERSONAL MANAGER').elementItemsMap.get('DEFAULT VALUE').value);
        Boolean needDocumentDelivery = Boolean.valueOf(pagesMap.get('ORDER').fields.get('DOCS DELIVERY').elementItemsMap.get('DEFAULT VALUE').value);
        Boolean needPayOverdraft = Boolean.valueOf(pagesMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').value);

        formDataRecord.E2E_Product_Id__c = GlobalUtils.blankStringIfNull(product);
        formDataRecord.E2E_Tariff_Id__c = GlobalUtils.blankStringIfNull(tariffId);
        formDataRecord.E2E_Product__c = GlobalUtils.getE2EProduct(product) + ' ' + GlobalUtils.blankStringIfNull(tariff);
        formDataRecord.E2E_Num_Cards__c = numberOfCards;
        formDataRecord.E2E_Promo_Campaign__c = GlobalUtils.blankStringIfNull(promoCode);
        formDataRecord.E2E_Personal_Manager_srv__c = needPersonalManager;
        formDataRecord.E2E_Document_Delivery_srv__c = needDocumentDelivery;
        formDataRecord.E2E_Overdraft_srv__c = needPayOverdraft;
        formDataRecord.E2E_Payment_Condition__c = GlobalUtils.blankStringIfNull(paymentCondition);
        // STEP LegalDetails
        String OGRN = '';
        String KPP = '';
        if (formParams.isSoleProprietor) {
            OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').value;
        } else {
            OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value;
            KPP = pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value;
        }
        String OKPO = pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value;
        String legalAddress = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
        String legalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').value;
        String legalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').value;
        String legalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value;
        String legalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value;
        String legalAddressHouse = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value;
        String legalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
        String legalAddressApartment = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
        String postalAddress = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
        String postalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').value;
        String postalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STATE').value;
        String postalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').value;
        String postalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').value;
        String postalAddressHouse = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value;
        String postalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').value;
        String postalAddressApartment = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
        String executivePerson = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').value;
        String executivePersonTitle = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').value;
        String chiefAccountant = pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').value;
        String codeWord = pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value;
        String cardsDeliveryInformation = pagesMap.get('LEGAL DETAILS').fields.get('CARDS DELIVERY INFORMATION').elementItemsMap.get('DEFAULT VALUE').value;
        String personalOfficeEmail = pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').value;
        Boolean isManualEntryLegalInfo = Boolean.valueOf(pagesMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').value);

        formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(OGRN);
        formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(KPP);
        formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(OKPO);
        formDataRecord.E2E_Billing_Str__c = GlobalUtils.blankStringIfNull(legalAddressStreet);
        formDataRecord.E2E_Billing_House__c = GlobalUtils.blankStringIfNull(legalAddressHouse);
        formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(legalAddressCity);
        formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(legalAddressState);
        formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(legalAddressPostalCode);
        formDataRecord.E2E_Billing_Country__c = GlobalUtils.blankStringIfNull(legalAddressCountry);
        formDataRecord.E2E_Billing_Apartment__c = GlobalUtils.blankStringIfNull(legalAddressApartment);
        formDataRecord.E2E_Legal_Address__c = GlobalUtils.blankStringIfNull(legalAddress);
        formDataRecord.E2E_Shipping_Str__c = GlobalUtils.blankStringIfNull(postalAddressStreet);
        formDataRecord.E2E_Shipping_House__c = GlobalUtils.blankStringIfNull(postalAddressHouse);
        formDataRecord.E2E_Shipping_City__c = GlobalUtils.blankStringIfNull(postalAddressCity);
        formDataRecord.E2E_Shipping_State__c = GlobalUtils.blankStringIfNull(postalAddressState);
        formDataRecord.E2E_Shipping_Code__c = GlobalUtils.blankStringIfNull(postalAddressPostalCode);
        formDataRecord.E2E_Shipping_Country__c = GlobalUtils.blankStringIfNull(postalAddressCountry);
        formDataRecord.E2E_Shipping_Apartment__c = GlobalUtils.blankStringIfNull(postalAddressApartment);
        formDataRecord.E2E_Post_Address__c = GlobalUtils.blankStringIfNull(postalAddress);
        formDataRecord.E2E_Chief_Accountant__c = GlobalUtils.blankStringIfNull(chiefAccountant);
        formDataRecord.E2E_Code_Word__c = GlobalUtils.blankStringIfNull(codeWord);
        formDataRecord.E2E_Courier_Comments__c = GlobalUtils.blankStringIfNull(cardsDeliveryInformation);
        formDataRecord.E2E_Personal_Office_Email__c = personalOfficeEmail;
        formDataRecord.E2E_Manual_Entry_Legal_Info__c = isManualEntryLegalInfo;

        // Update executive fio only for legal person
        if (formParams.isSoleProprietor == false) {
            formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(executivePerson) + ', ' + GlobalUtils.blankStringIfNull(executivePersonTitle);
        }

        // STEP PaymentDetails
        String checkingAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;
        String bank = pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value;
        String BIC = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value;
        String corBankAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value;
        String prepayAmount = pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').value;

        formDataRecord.E2E_Checking_Account__c = GlobalUtils.blankStringIfNull(checkingAccount);
        formDataRecord.E2E_Bank__c = GlobalUtils.blankStringIfNull(bank);
        formDataRecord.E2E_Bank_Address__c = GlobalUtils.blankStringIfNull(formParams.bankAddress);
        formDataRecord.E2E_Bank_Name_Short__c = GlobalUtils.blankStringIfNull(formParams.bankNameShort);
        formDataRecord.E2E_Bank_OKPO__c = GlobalUtils.blankStringIfNull(formParams.bankOkpo);
        formDataRecord.E2E_Bank_Town__c = GlobalUtils.blankStringIfNull(formParams.bankTown);
        formDataRecord.E2E_BIC__c = GlobalUtils.blankStringIfNull(BIC);
        formDataRecord.E2E_Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(corBankAccount);

        E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        formDataRecord.E2E_Prepay_Amount__c = String.valueOf(Integer.valueOf(prepayAmount) < generalSettings.Prepay_Amount__c ? generalSettings.Prepay_Amount__c : Integer.valueOf(prepayAmount));
        formDataRecord.E2E_Contract_Number__c = (formParams.contractPrefix != null && formParams.contractCounter != null) ? (String.format('{0}-{1}', new List<String>{
                formParams.contractPrefix, formParams.contractCounter
        })) : '';
        formDataRecord.E2E_Req_Num_MZK__c = GlobalUtils.blankStringIfNull(formParams.requestNumMZK);
        formDataRecord.E2E_Transit_Cont_Id__c = GlobalUtils.blankStringIfNull(formParams.transitContId);

        formDataRecord.E2E_Form_URL__c = formParams.generatedUrlWithHash;
        formDataRecord.E2E_Source__c = source;
        formDataRecord.E2E_Process_Status__c = formParams.contactDetails + formParams.sfDeduplication1
                + formParams.sfDeduplication2 + formParams.getSparkData + formParams.checkedInBlackList
                + formParams.scoringPassed + formParams.sfDeduplication3 + formParams.sendCrmRequest
                + formParams.companyDetails + formParams.cardOrderDetails + formParams.legalDetails
                + formParams.paymentDetails + formParams.getReport + formParams.createContInTransit
                + formParams.sendMzkRequest + formParams.saveReport;
        formDataRecord.E2E_Form_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/e2eFormRu?country=Russia&link=' + formParams.encodedURL; // Save client link

        return formDataRecord;
    }

    //******* Lead ********//

    public static Lead createDefaultLead() {
        Lead lead = new Lead(
                Company = 'ООО Ромашка',
                LastName = 'New Lead Contact Form',
                Status = 'Qualified',
                Email = 'leademail@leademail.ru',
                Phone = '+79162223322',
                IsConverted = false,
                Sec_Channel__c = 'Inbound',
                Country = 'Russia',
                RecordTypeId = GlobalUtils.getRecordTypeId('Lead', 'Russian_Sales'));
        return lead;
    }

    public static Document createDefaultDocument() {
        List<Folder> folders = ([
                SELECT Id
                FROM Folder
                WHERE Name = 'Test'
                LIMIT 1
        ]);

        Document document = new Document(
                FolderId = folders.get(0).Id,
                Name = 'Test Default Document',
                Body = Blob.valueOf('Content is here'),
                ContentType = 'application/pdf',
                IsPublic = false,
                Type = 'pdf'
        );
        return document;
    }

    public static User createUser() {
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR_Fleetcor' AND DeveloperName = 'PPR_Fleetcor'];
        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
        User user = new User(
                ProfileId = p.Id,
                UserRoleId = ur.Id,
                Username = 'new_user_email@email.ru',
                Email = 'new_user_email@email.ru',
                FirstName = 'User',
                LastName = 'Test',
                Alias = 'tuser',
                TimeZoneSidKey = 'America/Chicago',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
        );
        return user;
    }

    public static User createAdminUser() {
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Role Up' AND DeveloperName = 'Role_Up'];
        Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
        User user = new User(
                Username = 'new_user_admin@Test.com',
                Email = 'admin@test.com',
                FirstName = 'AdminUser',
                LastName = 'admin_tester',
                ProfileId = p.Id,
                UserRoleId = ur.Id,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow',
                EmailEncodingKey = 'UTF-8',
                Alias = 'admin'
        );
        return user;
    }

    public static User insertUser(User userToInsert) {
        insert userToInsert;
        return userToInsert;
    }

    public static Account getAccountById(Id accountId) {
        Account account = new Account();
        account = ([
                SELECT Id, Name, INN__c, OGRN_ppr__c, KPP__c, OKPO_ppr__c, Code_Word__c, Organization_Type__c,
                        BillingAddress, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                        ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Checking_Account__c,
                        SWIFT_BIC__c, Bank__c, Cor_bank_account__c, Phone, Company_Legal_Name1__c, OwnerId, Transit_ID_a__c,
                        Last_pump_date__c, Date_of_transfer_to_service__c, Region__c, E2E_Special_Marker__c, (
                        SELECT Id, Name, PPR_Lost_Reasons__c, StageName, OwnerId, Owner.Name, Owner.FirstName, Owner.LastName,
                                Owner.Email, CloseDate, INN_Opp__c, Day_transfer__c, Owner.UserRole.Name, MAIN_ID__c, Probability, Transit_ID__c, IsClosed
                        FROM Opportunities
                )
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
        ]);
        return account;
    }

    public static Contact getContactById(Id contactId) {
        Contact contact = new Contact();
        contact = [
                SELECT Id, FirstName, LastName, Email, MobilePhone, AccountId, Title,
                        Agree_to_receive_comm_info_by_email__c,
                        Agree_to_process_pers_data_for_marketing__c, Salutation,
                        Phone
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
        ];
        return contact;
    }

    public static Opportunity getOpportunityById(Id opportunityId) {
        Opportunity opportunity = new Opportunity();
        opportunity = [
                SELECT Id, Name, AccountId, Organization_Type__c, PPR_Lost_Reasons__c, OwnerId, Owner.FirstName, Owner.UserRole.Name,
                Owner.LastName, Owner.Name, Owner.Email, Source_of_Lead_o__c, Source_if_self_sourced_c__c, Lead_Source_TypeOpp__c,
                PPR_First_Contact_Inbound_Outbound__c, Prepay_Amount__c, Scoring_Date__c, Number_of_Cards__c, StageName, e2e_payment_status__c,
                Scoring_Expiration_Date__c, Scoring_Status__c, Manual_Entry__c, MAIN_ID__c, Req_Num_MZK__c, CloseDate, E2E_Errors__c, Personal_office_phone__c,
                E2E_Status__c, E2E_Sub_Status__c, E2E_Sales_Type__c, Day_transfer__c, Probability, Transit_ID__c, IsClosed, Product_PPR__c, Promo_campaign__c, (SELECT Id, ContactId, IsPrimary, Role FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
        ];
        return opportunity;
    }

    public static OpportunityContactRole getOpportunityContactRole(Id contactId, Id opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole = [
                SELECT Id, ContactId, OpportunityId, Role
                FROM OpportunityContactRole
                WHERE ContactId = :contactId AND
                OpportunityId = :opportunityId
                LIMIT 1
        ];
        return opportunityContactRole;
    }

    public static E2EFormData__c getFormDataById(Id formDataRecordId) {
        E2EFormData__c formDataRecord = new E2EFormData__c();
        formDataRecord = [
                SELECT Id, E2E_Account_Id__c, E2E_Contact_Id__c, E2E_Opportunity_Id__c, E2E_Contact_Phone__c,
                        E2E_Contact_Email__c, E2E_Account_Name__c, E2E_INN__c, E2E_Product__c, E2E_Process_Personal_Data__c,
                        E2E_Send_Marketing_Email__c, E2E_Manual_Entry__c, E2E_Num_Cards__c, E2E_Promo_Campaign__c,
                        E2E_Personal_Manager_srv__c, E2E_Document_Delivery_srv__c, E2E_Overdraft_srv__c,
                        E2E_Payment_Condition__c, E2E_OGRN__c, E2E_KPP__c, E2E_OKPO__c, E2E_Legal_Address__c,
                        E2E_Post_Address__c, E2E_Executive_Person__c, E2E_Chief_Accountant__c,
                        E2E_Code_Word__c, E2E_Checking_Account__c, E2E_Bank__c, E2E_BIC__c, E2E_Cor_Bank_Account__c,
                        E2E_Prepay_Amount__c, E2E_Last_Step__c, E2E_IP_Address__c,
                        E2E_Scoring_Date__c, E2E_Scoring_Expiration_Date__c, E2E_Spark_Id__c, E2E_Main_Company_Full_Name__c,
                        E2E_Bank_Name_Short__c, E2E_Bank_Address__c, E2E_Bank_Town__c, E2E_Bank_OKPO__c, E2E_Product_Id__c, E2E_Tariff_Id__c,
                        E2E_Courier_Comments__c, E2E_Shipping_Str__c, E2E_Billing_Code__c, E2E_Billing_State__c, E2E_Billing_City__c,
                        E2E_Black_List_Code__c, E2E_Black_List__c, E2E_Black_List_Limitations__c, E2E_Scoring_Decision_Code__c,
                        E2E_Scoring_Decision__c, E2E_Source__c, E2E_Shipping_State__c,
                        E2E_Shipping_City__c, E2E_Shipping_Country__c, E2E_Shipping_House__c, E2E_Shipping_Code__c,
                        E2E_Billing_House__c, E2E_Billing_Str__c, E2E_Billing_Apartment__c, E2E_Shipping_Apartment__c, E2E_Personal_Office_Email__c, E2E_Reg_Date__c,
                        E2E_Empty_SPARK_OKPO__c
                FROM E2EFormData__c
                WHERE Id = :formDataRecordId
                LIMIT 1
        ];
        return formDataRecord;
    }

    //************ Page Content ************//

    /*******************************************************************************
	*  Name            : initPagesStructure()
	*  Summary         : init pages
	*  CreatedDate     : 11/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    private static void initPagesStructure() {
        createLongFormRU();
        createContactDetailsStep();
        createCompanyInformationStep();
        createOrderStep();
        createLegalDetailsStep();
        createPaymentDetailsStep();
    }

    /*******************************************************************************
	*  Name            : createLongFormRU()
	*  Summary         : Create long form RU
	*  CreatedDate     : 11/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public static void createLongFormRU() {
        longFormRU = new LongForm__c(
                Name = 'LongFormRUTEST',
                Country__c = 'Russia',
                Active__c = true,
                Test_Locator__c = true,
                Test_Payment__c = true,
                Test_Mode__c = false,
                Title__c = 'Order a fuel card online'
        );
        insert longFormRU;
    }

    /*******************************************************************************
    *  Name            : createContactDetailsStep()
    *  Summary         : Create contact details data
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createContactDetailsStep() {
        LongForm_Page__c contactDetails = new LongForm_Page__c(
                Name = 'CONTACT DETAILS',
                Title__c = 'E2E Contact Details',
                System_Error__c = 'Error',
                Type__c = 'Basic',
                Device_View__c = 'Desktop',
                Long_Form__c = longFormRU.Id
        );
        insert contactDetails;

        // **** init Elements *****//
        List<LongForm_Element__c> contactDetailsElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c mobileNumber = new LongForm_Element__c(
                Name = 'MOBILE NUMBER',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(mobileNumber);

        LongForm_Element__c emailAddress = new LongForm_Element__c(
                Name = 'EMAIL ADDRESS',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(emailAddress);

        LongForm_Element__c personalInformation = new LongForm_Element__c(
                Name = 'PERSONAL INFORMATION',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(personalInformation);

        LongForm_Element__c marketingDispatch = new LongForm_Element__c(
                Name = 'MARKETING DISPATCH',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(marketingDispatch);

        LongForm_Element__c personalInformationPolicy = new LongForm_Element__c(
                Name = 'PERSONAL INFORMATION POLICY',
                Type__c = 'Text Field',
                Long_Form_Page__c = contactDetails.Id
        );
        contactDetailsElementsList.add(personalInformationPolicy);

        insert contactDetailsElementsList;

        //****  init Element Items ****//
        List<LongForm_Element_Item__c> contactDetailsElementItemsList = new List<LongForm_Element_Item__c>();

        // Mobile number
        LongForm_Element_Item__c mobileNumberLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Телефон',
                Type__c = 'Label',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberLabel);

        LongForm_Element_Item__c mobileNumberAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberAsterisk);

        LongForm_Element_Item__c mobileNumberDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberDefaultValue);

        LongForm_Element_Item__c mobileNumberPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = '+7 _ _ _ _ _ _ _ _ _ _',
                Type__c = 'Placeholder',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberPlaceholder);

        LongForm_Element_Item__c mobileNumberWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Номер телефона должен состоять из 10 цифр, начиная с кода оператора',
                Type__c = 'Validation Text',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberWarnMessage);

        LongForm_Element_Item__c mobileNumberPopup = new LongForm_Element_Item__c(
                Name = 'POPUP',
                Active__c = true,
                Value__c = '10-значный номер, начиная с кода оператора',
                Type__c = 'Help Text',
                Long_Form_Element__c = mobileNumber.Id
        );
        contactDetailsElementItemsList.add(mobileNumberPopup);

        // Email Address
        LongForm_Element_Item__c emailAddressLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Email Address',
                Type__c = 'Label',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressLabel);

        LongForm_Element_Item__c emailAddressAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressAsterisk);

        LongForm_Element_Item__c emailAddressDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressDefaultValue);

        LongForm_Element_Item__c emailAddressPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'Email',
                Type__c = 'Placeholder',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressPlaceholder);

        LongForm_Element_Item__c emailAddressWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Введите корректный адрес эл. почты',
                Type__c = 'Validation Text',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressWarnMessage);

        LongForm_Element_Item__c emailAddressPopup = new LongForm_Element_Item__c(
                Name = 'POPUP',
                Active__c = true,
                Value__c = 'Адрес электронной почты, на которую будут отправлены документы для оформления заказа',
                Type__c = 'Help Text',
                Long_Form_Element__c = emailAddress.Id
        );
        contactDetailsElementItemsList.add(emailAddressPopup);

        // Personal Information
        LongForm_Element_Item__c personalInformationLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Согласие с политикой по персональным данным.',
                Type__c = 'Label',
                Long_Form_Element__c = personalInformation.Id
        );
        contactDetailsElementItemsList.add(personalInformationLabel);

        LongForm_Element_Item__c personalInformationDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = personalInformation.Id
        );
        contactDetailsElementItemsList.add(personalInformationDefaultValue);

        LongForm_Element_Item__c personalInformationDocumentUrl = new LongForm_Element_Item__c(
                Name = 'DOCUMENT URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = personalInformation.Id
        );
        contactDetailsElementItemsList.add(personalInformationDocumentUrl);

        LongForm_Element_Item__c personalInformationWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Для продолжения оформления вам необходимо согласиться с политикой по персональным данным',
                Type__c = 'Validation Text',
                Long_Form_Element__c = personalInformation.Id
        );
        contactDetailsElementItemsList.add(personalInformationWarnMessage);

        // Marketing Dispatch
        LongForm_Element_Item__c marketingDispatchLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Согласие на маркетинговые рассылки',
                Type__c = 'Label',
                Long_Form_Element__c = marketingDispatch.Id
        );
        contactDetailsElementItemsList.add(marketingDispatchLabel);

        LongForm_Element_Item__c marketingDispatchDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'TRUE',
                Type__c = 'Default Value',
                Long_Form_Element__c = marketingDispatch.Id
        );
        contactDetailsElementItemsList.add(marketingDispatchDefaultValue);

        LongForm_Element_Item__c marketingDispatchDocumentUrl = new LongForm_Element_Item__c(
                Name = 'DOCUMENT URL',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = marketingDispatch.Id
        );
        contactDetailsElementItemsList.add(marketingDispatchDocumentUrl);


        // PERSONAL INFORMATION POLICY
        LongForm_Element_Item__c personalInformationPolicyTitle = new LongForm_Element_Item__c(
                Name = 'TITLE',
                Active__c = true,
                Value__c = 'Согласие на маркетинговые рассылки',
                Type__c = 'Label',
                Long_Form_Element__c = personalInformationPolicy.Id
        );
        contactDetailsElementItemsList.add(personalInformationPolicyTitle);

        LongForm_Element_Item__c personalInformationPolicyBody = new LongForm_Element_Item__c(
                Name = 'BODY',
                Active__c = true,
                Value__c = 'TRUE',
                Type__c = 'Label',
                Long_Form_Element__c = personalInformationPolicy.Id
        );
        contactDetailsElementItemsList.add(personalInformationPolicyBody);

        LongForm_Element_Item__c personalInformationPolicyButton = new LongForm_Element_Item__c(
                Name = 'BUTTON',
                Active__c = true,
                Value__c = '',
                Type__c = 'Label',
                Long_Form_Element__c = personalInformationPolicy.Id
        );
        contactDetailsElementItemsList.add(personalInformationPolicyButton);

        insert contactDetailsElementItemsList;
    }

    /*******************************************************************************
   *  Name            : createCompanyInformationStep()
   *  Summary         : Create company details data
   *  CreatedDate     : 11/07/2018
   *  ModifiedDate    : -
   *  Parameters      : -
   *  Returns         : void
   ******************************************************************************/
    public static void createCompanyInformationStep() {
        LongForm_Page__c companyInformation = new LongForm_Page__c(
                Name = 'COMPANY INFORMATION',
                Title__c = 'E2E Company Information',
                System_Error__c = 'Error',
                Type__c = 'Basic',
                Device_View__c = 'Desktop',
                Long_Form__c = longFormRU.Id
        );
        insert companyInformation;

        // **** init Elements *****//
        List<LongForm_Element__c> companyInformationElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c accountName = new LongForm_Element__c(
                Name = 'ACCOUNT NAME',
                Type__c = 'Text Field',
                Long_Form_Page__c = companyInformation.Id
        );
        companyInformationElementsList.add(accountName);

        LongForm_Element__c inn = new LongForm_Element__c(
                Name = 'INN',
                Type__c = 'Text Field',
                Long_Form_Page__c = companyInformation.Id
        );
        companyInformationElementsList.add(inn);

        LongForm_Element__c manualEntry = new LongForm_Element__c(
                Name = 'IS MANUAL ENTRY',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = companyInformation.Id
        );
        companyInformationElementsList.add(manualEntry);

        insert companyInformationElementsList;

        //****  init Element Items ****//
        List<LongForm_Element_Item__c> companyInformationElementItemsList = new List<LongForm_Element_Item__c>();

        // ACCOUNT NAME
        LongForm_Element_Item__c accountNameLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Название компании',
                Type__c = 'Label',
                Long_Form_Element__c = accountName.Id
        );
        companyInformationElementItemsList.add(accountNameLabel);

        LongForm_Element_Item__c accountNameAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = accountName.Id
        );
        companyInformationElementItemsList.add(accountNameAsterisk);

        LongForm_Element_Item__c accountNameDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = accountName.Id
        );
        companyInformationElementItemsList.add(accountNameDefaultValue);

        LongForm_Element_Item__c accountNamePlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = 'ООО "КОМПАНИЯ"',
                Type__c = 'Placeholder',
                Long_Form_Element__c = accountName.Id
        );
        companyInformationElementItemsList.add(accountNamePlaceholder);

        LongForm_Element_Item__c accountNameWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Номер телефона должен состоять из 10 цифр, начиная с кода оператора',
                Type__c = 'Validation Text',
                Long_Form_Element__c = accountName.Id
        );
        companyInformationElementItemsList.add(accountNameWarnMessage);

        LongForm_Element_Item__c accountNamePopup = new LongForm_Element_Item__c(
                Name = 'POPUP',
                Active__c = true,
                Value__c = 'Введите наименование Вашей компании или Ф.И.О. индивидуального предпринимателя, начиная с организационно-правовой формы (например: ООО, АО, ИП, пр.)',
                Type__c = 'Help Text',
                Long_Form_Element__c = accountName.Id
        );
        companyInformationElementItemsList.add(accountNamePopup);

        // INN
        LongForm_Element_Item__c innLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'ИНН',
                Type__c = 'Label',
                Long_Form_Element__c = inn.Id
        );
        companyInformationElementItemsList.add(innLabel);

        LongForm_Element_Item__c innAsterisk = new LongForm_Element_Item__c(
                Name = 'ASTERISK',
                Active__c = true,
                Value__c = '*',
                Type__c = 'Label',
                Long_Form_Element__c = inn.Id
        );
        companyInformationElementItemsList.add(innAsterisk);

        LongForm_Element_Item__c innDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = inn.Id
        );
        companyInformationElementItemsList.add(innDefaultValue);

        LongForm_Element_Item__c innPlaceholder = new LongForm_Element_Item__c(
                Name = 'PLACEHOLDER',
                Active__c = true,
                Value__c = '2802368082',
                Type__c = 'Placeholder',
                Long_Form_Element__c = inn.Id
        );
        companyInformationElementItemsList.add(innPlaceholder);

        LongForm_Element_Item__c innWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = 'Введите корректный ИНН, номер должен состоять из 10 или 12 цифр',
                Type__c = 'Validation Text',
                Long_Form_Element__c = inn.Id
        );
        companyInformationElementItemsList.add(innWarnMessage);

        // IS MANUAL ENTRY
        LongForm_Element_Item__c manualEntryLabel = new LongForm_Element_Item__c(
                Name = 'LABEL',
                Active__c = true,
                Value__c = 'Заполнить данные вручную',
                Type__c = 'Label',
                Long_Form_Element__c = manualEntry.Id
        );
        companyInformationElementItemsList.add(manualEntryLabel);

        LongForm_Element_Item__c manualEntryDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = manualEntry.Id
        );
        companyInformationElementItemsList.add(manualEntryDefaultValue);

        LongForm_Element_Item__c manualEntryValue = new LongForm_Element_Item__c(
                Name = 'VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'URL',
                Long_Form_Element__c = manualEntry.Id
        );
        companyInformationElementItemsList.add(manualEntryValue);

        insert companyInformationElementItemsList;
    }

    /*******************************************************************************
    *  Name            : createOrderStep()
    *  Summary         : Create order details data
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : 23/10/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createOrderStep() {
        // **** init Page *****//
        LongForm_Page__c order = new LongForm_Page__c(
                Name = 'ORDER',
                Title__c = 'E2E Order',
                System_Error__c = 'Error',
                Type__c = 'Basic',
                Device_View__c = 'Desktop',
                Long_Form__c = longFormRU.Id
        );
        insert order;

        // **** init Elements *****//
        List<LongForm_Element__c> orderElementsList = new List<LongForm_Element__c>();

        LongForm_Element__c products = new LongForm_Element__c(
                Name = 'PRODUCTS',
                Type__c = 'Text Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(products);

        LongForm_Element__c promocodeDescription = new LongForm_Element__c(
                Name = 'PROMOCODE DESCRIPTION',
                Type__c = 'Text Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(promocodeDescription);

        LongForm_Element__c promocode = new LongForm_Element__c(
                Name = 'PROMOCODE',
                Type__c = 'Text Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(promocode);

        LongForm_Element__c amountCard = new LongForm_Element__c(
                Name = 'AMOUNT CARD',
                Type__c = 'Text Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(amountCard);

        LongForm_Element__c docsDelivery = new LongForm_Element__c(
                Name = 'DOCS DELIVERY',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(docsDelivery);

        LongForm_Element__c personalManager = new LongForm_Element__c(
                Name = 'PERSONAL MANAGER',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(personalManager);

        LongForm_Element__c payOverdraft = new LongForm_Element__c(
                Name = 'PAY OVERDRAFT',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(payOverdraft);

        LongForm_Element__c giftList = new LongForm_Element__c(
                Name = 'GIFT LIST',
                Type__c = 'Picklist Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(giftList);


        LongForm_Element__c paymentConditions = new LongForm_Element__c(
                Name = 'PAYMENT CONDITIONS',
                Type__c = 'Text Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(paymentConditions);

        LongForm_Element__c productTariff = new LongForm_Element__c(
                Name = 'PRODUCT TARIFF',
                Type__c = 'Text Field',
                Long_Form_Page__c = order.Id
        );
        orderElementsList.add(productTariff);

        insert orderElementsList;

        // **** init OFFER ****//
        LongForm_Offer__c offer = new LongForm_Offer__c(
                Country__c = 'Russia',
                LongForm_Element__c = products.Id,
                Product__c = 'PetrolPlus'
        );
        insert offer;

        // **** init LongForm_Fleetcor_Product__c **** //
        LongForm_Fleetcor_Product__c productOffer = new LongForm_Fleetcor_Product__c(
                Name = 'PetrolPlus_Rover',
                Active__c = true,
                Long_Form_Offer__c = offer.Id,
                Label__c = 'Вездеход Online'
        );
        insert productOffer;

        // **** LongForm_Tariff__c **** //
        LongForm_Tariff__c tariffProduct = new LongForm_Tariff__c(
                Name = '1OPTIMAL_CONTRACT',
                LongForm_Fleetcor_Product__c = productOffer.Id,
                Label__c = 'Оптимальный',
                Show_Tariff__c = true
        );
        List<LongForm_Tariff__c> tariffs = new List<LongForm_Tariff__c>{
                tariffProduct,
                new LongForm_Tariff__c(
                        Name = '3SUPER_CONTRACT',
                        LongForm_Fleetcor_Product__c = productOffer.Id,
                        Label__c = 'Супер',
                        Show_Tariff__c = true
                ),
                new LongForm_Tariff__c(
                        Name = '2CHOOSEN_CONTRACT',
                        LongForm_Fleetcor_Product__c = productOffer.Id,
                        Label__c = 'Избранный',
                        Show_Tariff__c = true
                ),
                new LongForm_Tariff__c(
                        Name = '4LIGHT_CONTRACT',
                        LongForm_Fleetcor_Product__c = productOffer.Id,
                        Label__c = 'Лайт Договор',
                        Show_Tariff__c = true
                ),
                new LongForm_Tariff__c(
                        Name = 'GAZ_CHOOSEN_CONTRACT',
                        LongForm_Fleetcor_Product__c = productOffer.Id,
                        Label__c = 'Газ Договор',
                        Show_Tariff__c = true
                ),
                new LongForm_Tariff__c(
                        Name = 'DOO_NOT_SHOW',
                        LongForm_Fleetcor_Product__c = productOffer.Id,
                        Label__c = 'не показывать',
                        Show_Tariff__c = false
                )
        };
        insert tariffs;

        // **** LongForm_Property__c **** //
        LongForm_Property__c propertyTariff = new LongForm_Property__c(
                Name = '1SUBSCRIPTION_FEE',
                LongForm_Tariff__c = tariffProduct.Id,
                Value__c = 'Стоимость информационных услуг'
        );
        insert propertyTariff;

        // **** LongForm_Property_Item__c **** //
        List<LongForm_Property_Item__c> propertyItemList = new List<LongForm_Property_Item__c>();

        LongForm_Property_Item__c propertyItem1 = new LongForm_Property_Item__c(
                Name = '1PROPERTY',
                LongForm_Property__c = propertyTariff.Id,
                Value__c = '3 месяца бесплатного обслуживания. <span class="glyphicon glyphicon-gift" style="color:#4fcfcc"></span>'
        );
        propertyItemList.add(propertyItem1);

        LongForm_Property_Item__c propertyItem2 = new LongForm_Property_Item__c(
                Name = '2PROPERTY',
                LongForm_Property__c = propertyTariff.Id,
                Value__c = 'Объем потребления - <b>10 000 л/мес. и менее:</b> 0,95% от оборота, но не менее 895 руб./мес.'
        );
        propertyItemList.add(propertyItem2);

        insert propertyItemList;

        // ****  init Element Items **** //
        List<LongForm_Element_Item__c> orderElementItemsList = new List<LongForm_Element_Item__c>();

        // PRODUCTS
        LongForm_Element_Item__c productsDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'Вездеход Online',
                Type__c = 'Default Value',
                Long_Form_Element__c = products.Id
        );
        orderElementItemsList.add(productsDefaultValue);

        LongForm_Element_Item__c productsID = new LongForm_Element_Item__c(
                Name = 'ID',
                Active__c = true,
                Value__c = 'PetrolPlus_Rover"',
                Type__c = 'Free Text',
                Long_Form_Element__c = products.Id
        );
        orderElementItemsList.add(productsID);

        // Promocode Description
        LongForm_Element_Item__c promocodeDescriptionTitle = new LongForm_Element_Item__c(
                Name = 'PROMOCODE DESCRIPTION TITLE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionTitle);

        LongForm_Element_Item__c promocodeDescriptionBody = new LongForm_Element_Item__c(
                Name = 'PROMOCODE DESCRIPTION BODY',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionBody);

        LongForm_Element_Item__c promocodeDescriptionLabel = new LongForm_Element_Item__c(
                Name = 'PROMOCODE LABEL',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionLabel);

        LongForm_Element_Item__c promocodeDescriptionValue = new LongForm_Element_Item__c(
                Name = 'PROMOCODE VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionValue);

        LongForm_Element_Item__c promocodeDescriptionInvalid = new LongForm_Element_Item__c(
                Name = 'PROMOCODE INVALID',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionInvalid);

        LongForm_Element_Item__c promocodeDescriptionAdditionalField = new LongForm_Element_Item__c(
                Name = 'PROMOCODE ADDITIONAL FIELD',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionAdditionalField);

        LongForm_Element_Item__c promocodeDescriptionProduct = new LongForm_Element_Item__c(
                Name = 'PROMOCODE PRODUCT',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionProduct);

        LongForm_Element_Item__c promocodeDescriptionAdditionalLabel = new LongForm_Element_Item__c(
                Name = 'PROMOCODE ADDITIONAL LABEL',
                Active__c = true,
                Value__c = 'Выберите поставщика',
                Type__c = 'Label',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionAdditionalLabel);

        LongForm_Element_Item__c promocodeDescriptionChoosenField = new LongForm_Element_Item__c(
                Name = 'PROMOCODE CHOOSEN FIELD',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionChoosenField);

        LongForm_Element_Item__c promocodeDescriptionChoosenLabel = new LongForm_Element_Item__c(
                Name = 'PROMOCODE CHOOSEN LABEL',
                Active__c = true,
                Value__c = 'Поставщик',
                Type__c = 'Label',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionChoosenLabel);

        LongForm_Element_Item__c promocodeDescriptionChoosenFieldID = new LongForm_Element_Item__c(
                Name = 'PROMOCODE CHOOSEN FIELD ID',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = promocodeDescription.Id
        );
        orderElementItemsList.add(promocodeDescriptionChoosenFieldID);

        // PROMOCODE
        LongForm_Element_Item__c promocodeDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = promocode.Id
        );
        orderElementItemsList.add(promocodeDefaultValue);

        LongForm_Element_Item__c promocodeWarnMessage = new LongForm_Element_Item__c(
                Name = 'WARN MESSAGE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Validation Text',
                Long_Form_Element__c = promocode.Id
        );
        orderElementItemsList.add(promocodeWarnMessage);

        // PRODUCT TARIFF
        LongForm_Element_Item__c productTariffDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = productTariff.Id
        );
        orderElementItemsList.add(productTariffDefaultValue);

        LongForm_Element_Item__c productTariffID = new LongForm_Element_Item__c(
                Name = 'TARIFF ID',
                Active__c = true,
                Value__c = '1OPTIMAL_CONTRACT',
                Type__c = 'Default Value',
                Long_Form_Element__c = productTariff.Id
        );
        orderElementItemsList.add(productTariffID);

        // GIFT LIST
        LongForm_Element_Item__c giftListItem = new LongForm_Element_Item__c(
                Name = 'LIST',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = giftList.Id
        );
        orderElementItemsList.add(giftListItem);

        // AMOUNT CARD
        LongForm_Element_Item__c amountCardDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = amountCard.Id
        );
        orderElementItemsList.add(amountCardDefaultValue);

        // DOCS DELIVERY
        LongForm_Element_Item__c docsDeliveryDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = docsDelivery.Id
        );
        orderElementItemsList.add(docsDeliveryDefaultValue);

        // PAY OVERDRAFT
        LongForm_Element_Item__c payOverdraftDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = payOverdraft.Id
        );
        orderElementItemsList.add(payOverdraftDefaultValue);

        // PERSONAL MANAGER
        LongForm_Element_Item__c personalManagerDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = personalManager.Id
        );
        orderElementItemsList.add(personalManagerDefaultValue);

        // PAYMENT CONDITIONS
        LongForm_Element_Item__c paymentConditionsDefaultValue = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'Предоплата 100%',
                Type__c = 'Default Value',
                Long_Form_Element__c = paymentConditions.Id
        );
        orderElementItemsList.add(paymentConditionsDefaultValue);

        insert orderElementItemsList;
    }

    /*******************************************************************************
    *  Name            : createLegalDetailsStep()
    *  Summary         : Create legal details data
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createLegalDetailsStep() {
        LongForm_Page__c legalDetails = new LongForm_Page__c(
                Name = 'LEGAL DETAILS',
                Title__c = 'E2E Legal Details',
                System_Error__c = 'Error',
                Type__c = 'Basic',
                Device_View__c = 'Desktop',
                Long_Form__c = longFormRU.Id
        );
        insert legalDetails;

        // **** init Elements *****//
        List<LongForm_Element__c> legalDetailsElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c cardsDeliveryInformation = new LongForm_Element__c(
                Name = 'CARDS DELIVERY INFORMATION',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(cardsDeliveryInformation);

        LongForm_Element__c chiefAccountant = new LongForm_Element__c(
                Name = 'CHIEF ACCOUNTANT',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(chiefAccountant);

        LongForm_Element__c codeWord = new LongForm_Element__c(
                Name = 'CODE WORD',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(codeWord);

        LongForm_Element__c executivePerson = new LongForm_Element__c(
                Name = 'EXECUTIVE PERSON',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(executivePerson);

        LongForm_Element__c executivePersonPosition = new LongForm_Element__c(
                Name = 'EXECUTIVE PERSON POSITION',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(executivePersonPosition);

        LongForm_Element__c kpp = new LongForm_Element__c(
                Name = 'KPP',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(kpp);

        LongForm_Element__c legalAddress = new LongForm_Element__c(
                Name = 'LEGAL ADDRESS',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(legalAddress);

        LongForm_Element__c legalAddressAdditionally = new LongForm_Element__c(
                Name = 'LEGAL ADDRESS ADDITIONALLY',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(legalAddressAdditionally);

        LongForm_Element__c ogrn = new LongForm_Element__c(
                Name = 'OGRN',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(ogrn);

        LongForm_Element__c ogrnip = new LongForm_Element__c(
                Name = 'OGRNIP',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(ogrnip);

        LongForm_Element__c okpo = new LongForm_Element__c(
                Name = 'OKPO',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(okpo);

        LongForm_Element__c passportIssueAuthority = new LongForm_Element__c(
                Name = 'PASSPORT ISSUE AUTHORITY',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(passportIssueAuthority);

        LongForm_Element__c passportIssueAuthorityCode = new LongForm_Element__c(
                Name = 'PASSPORT ISSUE AUTHORITY CODE',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(passportIssueAuthorityCode);

        LongForm_Element__c passportIssueDate = new LongForm_Element__c(
                Name = 'PASSPORT ISSUE DATE',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(passportIssueDate);

        LongForm_Element__c passportNumber = new LongForm_Element__c(
                Name = 'PASSPORT NUMBER',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(passportNumber);

        LongForm_Element__c passportRegistrationAddress = new LongForm_Element__c(
                Name = 'PASSPORT REGISTRATION ADDRESS',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(passportRegistrationAddress);

        LongForm_Element__c passportSeries = new LongForm_Element__c(
                Name = 'PASSPORT SERIES',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(passportSeries);

        LongForm_Element__c postalAddress = new LongForm_Element__c(
                Name = 'POSTAL ADDRESS',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(postalAddress);

        LongForm_Element__c postalAddressAdditionally = new LongForm_Element__c(
                Name = 'POSTAL ADDRESS ADDITIONALLY',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(postalAddressAdditionally);

        LongForm_Element__c postalAddressForCards = new LongForm_Element__c(
                Name = 'POSTAL ADDRESS FOR CARDS',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(postalAddressForCards);

        LongForm_Element__c userAccountEmail = new LongForm_Element__c(
                Name = 'USER ACCOUNT EMAIL',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(userAccountEmail);

        LongForm_Element__c isSoleProprietor = new LongForm_Element__c(
                Name = 'IS SOLE PROPRIETOR',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(isSoleProprietor);

        LongForm_Element__c matchesDocsAddress = new LongForm_Element__c(
                Name = 'MATCHES DOCS ADDRESS',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(matchesDocsAddress);

        LongForm_Element__c matchesLegalAddress = new LongForm_Element__c(
                Name = 'MATCHES LEGAL ADDRESS',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(matchesLegalAddress);

        LongForm_Element__c rewriteDefaultSparkValues = new LongForm_Element__c(
                Name = 'REWRITE DEFAULT SPARK VALUES',
                Type__c = 'Checkbox Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(rewriteDefaultSparkValues);

        LongForm_Element__c userAccountPhone = new LongForm_Element__c(
                Name = 'USER ACCOUNT PHONE',
                Type__c = 'Text Field',
                Long_Form_Page__c = legalDetails.Id
        );
        legalDetailsElementsList.add(userAccountPhone);

        insert legalDetailsElementsList;

        // **** init Elements Items *****//
        List<LongForm_Element_Item__c> legalDetailsElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c cardsDeliveryInformationVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = cardsDeliveryInformation.Id
        );
        legalDetailsElementItemsList.add(cardsDeliveryInformationVal);

        LongForm_Element_Item__c chiefAccountantVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = chiefAccountant.Id
        );
        legalDetailsElementItemsList.add(chiefAccountantVal);

        LongForm_Element_Item__c codeWordVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = codeWord.Id
        );
        legalDetailsElementItemsList.add(codeWordVal);

        LongForm_Element_Item__c executivePersonVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = executivePerson.Id
        );
        legalDetailsElementItemsList.add(executivePersonVal);

        LongForm_Element_Item__c executivePersonPositionVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = executivePersonPosition.Id
        );
        legalDetailsElementItemsList.add(executivePersonPositionVal);

        LongForm_Element_Item__c kppVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = kpp.Id
        );
        legalDetailsElementItemsList.add(kppVal);

        LongForm_Element_Item__c legalAddressVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = legalAddress.Id
        );
        legalDetailsElementItemsList.add(legalAddressVal);

        LongForm_Element_Item__c legalAddressAdditionallyVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = legalAddressAdditionally.Id
        );
        legalDetailsElementItemsList.add(legalAddressAdditionallyVal);

        LongForm_Element_Item__c ogrnVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = ogrn.Id
        );
        legalDetailsElementItemsList.add(ogrnVal);

        LongForm_Element_Item__c ogrnipVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = ogrnip.Id
        );
        legalDetailsElementItemsList.add(ogrnipVal);

        LongForm_Element_Item__c okpoVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = okpo.Id
        );
        legalDetailsElementItemsList.add(okpoVal);

        LongForm_Element_Item__c passportIssueAuthorityVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = passportIssueAuthority.Id
        );
        legalDetailsElementItemsList.add(passportIssueAuthorityVal);

        LongForm_Element_Item__c passportIssueAuthorityCodeVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = passportIssueAuthorityCode.Id
        );
        legalDetailsElementItemsList.add(passportIssueAuthorityCodeVal);

        LongForm_Element_Item__c passportIssueDateVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = passportIssueDate.Id
        );
        legalDetailsElementItemsList.add(passportIssueDateVal);

        LongForm_Element_Item__c passportNumberVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = passportNumber.Id
        );
        legalDetailsElementItemsList.add(passportNumberVal);

        LongForm_Element_Item__c passportRegistrationAddressVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = passportRegistrationAddress.Id
        );
        legalDetailsElementItemsList.add(passportRegistrationAddressVal);

        LongForm_Element_Item__c passportSeriesVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = passportSeries.Id
        );
        legalDetailsElementItemsList.add(passportSeriesVal);

        LongForm_Element_Item__c postalAddressVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = postalAddress.Id
        );
        legalDetailsElementItemsList.add(postalAddressVal);

        LongForm_Element_Item__c postalAddressAdditionallyVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = postalAddressAdditionally.Id
        );
        legalDetailsElementItemsList.add(postalAddressAdditionallyVal);

        LongForm_Element_Item__c postalAddressForCardsVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = postalAddressForCards.Id
        );
        legalDetailsElementItemsList.add(postalAddressForCardsVal);

        LongForm_Element_Item__c userAccountEmailVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = userAccountEmail.Id
        );
        legalDetailsElementItemsList.add(userAccountEmailVal);

        LongForm_Element_Item__c isSoleProprietorVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = isSoleProprietor.Id
        );
        legalDetailsElementItemsList.add(isSoleProprietorVal);

        LongForm_Element_Item__c matchesDocsAddressVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = matchesDocsAddress.Id
        );
        legalDetailsElementItemsList.add(matchesDocsAddressVal);

        LongForm_Element_Item__c matchesLegalAddressVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = matchesLegalAddress.Id
        );
        legalDetailsElementItemsList.add(matchesLegalAddressVal);

        LongForm_Element_Item__c rewriteDefaultSparkValuesVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = 'FALSE',
                Type__c = 'Default Value',
                Long_Form_Element__c = rewriteDefaultSparkValues.Id
        );
        legalDetailsElementItemsList.add(rewriteDefaultSparkValuesVal);

        LongForm_Element_Item__c userAccountPhoneVal = new LongForm_Element_Item__c(
                    Name = 'DEFAULT VALUE',
                    Active__c = true,
                    Value__c = '',
                    Type__c = 'Default Value',
                    Long_Form_Element__c = userAccountPhone.Id
            );
            legalDetailsElementItemsList.add(userAccountPhoneVal);

        insert legalDetailsElementItemsList;

        //**** init elements for Legal Address ****//
        List<LongForm_Element_Item__c> legalAddressElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c legalAddressCityVal = new LongForm_Element_Item__c(
                Name = 'CITY',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = legalAddress.Id
        );
        legalAddressElementItemsList.add(legalAddressCityVal);

        LongForm_Element_Item__c legalAddressStreetVal = new LongForm_Element_Item__c(
                Name = 'STREET',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = legalAddress.Id
        );
        legalAddressElementItemsList.add(legalAddressStreetVal);

        LongForm_Element_Item__c legalAddressPostalCodeVal = new LongForm_Element_Item__c(
                Name = 'POSTAL CODE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = legalAddress.Id
        );
        legalAddressElementItemsList.add(legalAddressPostalCodeVal);

        LongForm_Element_Item__c legalAddressCountryVal = new LongForm_Element_Item__c(
                Name = 'COUNTRY',
                Active__c = true,
                Value__c = 'Russia',
                Type__c = 'Free Text',
                Long_Form_Element__c = legalAddress.Id
        );
        legalAddressElementItemsList.add(legalAddressCountryVal);

        LongForm_Element_Item__c legalAddressHouseNumberVal = new LongForm_Element_Item__c(
                Name = 'HOUSE NUMBER',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = legalAddress.Id
        );
        legalAddressElementItemsList.add(legalAddressHouseNumberVal);

        LongForm_Element_Item__c legalAddressStateVal = new LongForm_Element_Item__c(
                Name = 'STATE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = legalAddress.Id
        );
        legalAddressElementItemsList.add(legalAddressStateVal);

        insert legalAddressElementItemsList;

        //**** init elements for Postal Address ****//
        List<LongForm_Element_Item__c> postalAddressElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c postalAddressCityVal = new LongForm_Element_Item__c(
                Name = 'CITY',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = postalAddress.Id
        );
        postalAddressElementItemsList.add(postalAddressCityVal);

        LongForm_Element_Item__c postalAddressStreetVal = new LongForm_Element_Item__c(
                Name = 'STREET',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = postalAddress.Id
        );
        postalAddressElementItemsList.add(postalAddressStreetVal);

        LongForm_Element_Item__c postalAddressPostalCodeVal = new LongForm_Element_Item__c(
                Name = 'POSTAL CODE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = postalAddress.Id
        );
        postalAddressElementItemsList.add(postalAddressPostalCodeVal);

        LongForm_Element_Item__c postalAddressCountryVal = new LongForm_Element_Item__c(
                Name = 'COUNTRY',
                Active__c = true,
                Value__c = 'Russia',
                Type__c = 'Free Text',
                Long_Form_Element__c = postalAddress.Id
        );
        postalAddressElementItemsList.add(postalAddressCountryVal);

        LongForm_Element_Item__c postalAddressHouseNumberVal = new LongForm_Element_Item__c(
                Name = 'HOUSE NUMBER',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = postalAddress.Id
        );
        postalAddressElementItemsList.add(postalAddressHouseNumberVal);

        LongForm_Element_Item__c postalAddressStateVal = new LongForm_Element_Item__c(
                Name = 'STATE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Free Text',
                Long_Form_Element__c = postalAddress.Id
        );
        postalAddressElementItemsList.add(postalAddressStateVal);

        insert postalAddressElementItemsList;
    }

    /*******************************************************************************
    *  Name            : createPaymentDetailsStep()
    *  Summary         : Create payment details data
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createPaymentDetailsStep() {
        LongForm_Page__c paymentDetails = new LongForm_Page__c(
                Name = 'PAYMENT DETAILS',
                Title__c = 'E2E Payment Details',
                System_Error__c = 'Error',
                Type__c = 'Basic',
                Device_View__c = 'Desktop',
                Long_Form__c = longFormRU.Id
        );
        insert paymentDetails;

        // **** init Elements *****//
        List<LongForm_Element__c> paymentDetailsElementsList = new List<LongForm_Element__c>();
        LongForm_Element__c cardsDeliveryInformation = new LongForm_Element__c(
                Name = 'CARDS DELIVERY INFORMATION',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(cardsDeliveryInformation);

        LongForm_Element__c matchingPaymentDetails = new LongForm_Element__c(
                Name = 'MATCHING PAYMENT DETAILS',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(matchingPaymentDetails);

        LongForm_Element__c freeExpressDelivery = new LongForm_Element__c(
                Name = 'FREE EXPRESS DELIVERY',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(freeExpressDelivery);

        LongForm_Element__c checkingAccount = new LongForm_Element__c(
                Name = 'CHECKING ACCOUNT',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(checkingAccount);

        LongForm_Element__c bankName = new LongForm_Element__c(
                Name = 'BANK NAME',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(bankName);

        LongForm_Element__c bic = new LongForm_Element__c(
                Name = 'BIC',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(bic);

        LongForm_Element__c corrBankAccount = new LongForm_Element__c(
                Name = 'CORR BANK ACCOUNT',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(corrBankAccount);

        LongForm_Element__c prepaymentAmount = new LongForm_Element__c(
                Name = 'PREPAYMENT AMOUNT',
                Type__c = 'Text Field',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(prepaymentAmount);

        LongForm_Element__c contractPreview = new LongForm_Element__c(
                Name = 'CONTRACT PREVIEW',
                Type__c = 'URL',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(contractPreview);

        LongForm_Element__c printBlock = new LongForm_Element__c(
                Name = 'PRINT BLOCK',
                Type__c = 'URL',
                Long_Form_Page__c = paymentDetails.Id
        );
        paymentDetailsElementsList.add(printBlock);

        insert paymentDetailsElementsList;

        // **** init Elements items *****//
        List<LongForm_Element_Item__c> paymentDetailsElementItemsList = new List<LongForm_Element_Item__c>();
        LongForm_Element_Item__c cardsDeliveryInformationVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = cardsDeliveryInformation.Id
        );
        paymentDetailsElementItemsList.add(cardsDeliveryInformationVal);

        LongForm_Element_Item__c matchingPaymentDetailsVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = matchingPaymentDetails.Id
        );
        paymentDetailsElementItemsList.add(matchingPaymentDetailsVal);

        LongForm_Element_Item__c freeExpressDeliveryVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = freeExpressDelivery.Id
        );
        paymentDetailsElementItemsList.add(freeExpressDeliveryVal);

        LongForm_Element_Item__c checkingAccountVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = checkingAccount.Id
        );
        paymentDetailsElementItemsList.add(checkingAccountVal);

        LongForm_Element_Item__c bankNameVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = bankName.Id
        );
        paymentDetailsElementItemsList.add(bankNameVal);

        LongForm_Element_Item__c bicVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = bic.Id
        );
        paymentDetailsElementItemsList.add(bicVal);

        LongForm_Element_Item__c corrBankAccountVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = corrBankAccount.Id
        );
        paymentDetailsElementItemsList.add(corrBankAccountVal);

        LongForm_Element_Item__c prepaymentAmountVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = prepaymentAmount.Id
        );
        paymentDetailsElementItemsList.add(prepaymentAmountVal);

        LongForm_Element_Item__c contractPreviewVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = contractPreview.Id
        );
        paymentDetailsElementItemsList.add(contractPreviewVal);

        LongForm_Element_Item__c printBlockVal = new LongForm_Element_Item__c(
                Name = 'DEFAULT VALUE',
                Active__c = true,
                Value__c = '',
                Type__c = 'Default Value',
                Long_Form_Element__c = printBlock.Id
        );
        paymentDetailsElementItemsList.add(printBlockVal);

        insert paymentDetailsElementItemsList;
    }

    /*******************************************************************************
    *  Name            : createCongratulationsStep()
    *  Summary         : Create congratulation data
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createCongratulationsStep() {
        LongForm_Page__c congratulations = new LongForm_Page__c(
                Name = 'CONGRATULATIONS',
                Title__c = 'E2E congratulations',
                System_Error__c = 'Error',
                Type__c = 'Basic',
                Device_View__c = 'Desktop',
                Long_Form__c = longFormRU.Id
        );
        insert congratulations;
    }

    public static void createSharedResources() {
        LongForm_Page__c sharedResources = new LongForm_Page__c(
                Name = 'SHARED RESOURCES',
                Device_View__c = 'Desktop',
                Long_Form__c = longFormRU.Id
        );

        insert sharedResources;

        //** INIT ELEMENTS **//
        LongForm_Element__c metroHeaders = new LongForm_Element__c(
                Name = 'METRO HEADERS',
                Long_Form_Page__c = sharedResources.Id,
                Type__c = 'Text Field'
        );

        insert metroHeaders;

        //** INIT ELEMETS ITEMS **//
        List<LongForm_Element_Item__c> items = new List<LongForm_Element_Item__c>();

        LongForm_Element_Item__c cardsContract = new LongForm_Element_Item__c(
                Name = 'CARDS CONTRACT',
                Value__c = 'Партнерская топливная программа <br>ППР и METRO',
                Active__c = true,
                Long_Form_Element__c = metroHeaders.Id,
                Type__c = 'Label'
        );

        //cardsContract.add(cardsContract);
        insert cardsContract;
    }

    public static ReportResponseData createDefaultReportResponse() {
        ReportResponseData response = new ReportResponseData();
        response.reportParams = new ReportResponseData.ReportParams();
        response.reportParams.SALESFORCE_CONTRACT_PREFIX = '1234';
        response.reportParams.SALESFORCE_CONTRACT_COUNTER = 'FD';
        response.reportParams.SALESFORCE_INVOICE_PREFIX = '1234';
        response.reportParams.SALESFORCE_INVOICE_COUNTER = 'FD';
        response.reportDocumentList = new List<ReportResponseData.ReportDocument>();
        ReportResponseData.ReportDocument reportDocumentTest = new ReportResponseData.ReportDocument();
        reportDocumentTest.idReport = '2345243';
        reportDocumentTest.reportTypeId = 42532;
        reportDocumentTest.reportTypeDescription = 'description';
        reportDocumentTest.path = new ReportResponseData.DocumentPath();
        reportDocumentTest.path.pdf = 'path';
        response.reportDocumentList.add(reportDocumentTest);
        return response;
    }

    public static E2EFormParams createDefaultFormParams() {
        E2EFormParams formParams = new E2EFormParams();
        formParams.mainContactPhone = '88005553535';
        formParams.mainContactEmail = 'zabuza@ddd.ct';
        formParams.numOfCards = 10;
        formParams.product = 'Вездеход Online "Избранный +" Карты';
        formParams.companyName = 'TEST';
        formParams.companyInn = '1234567890';
        formParams.okpo = '00196533';
        formParams.isSoleProprietor = false;
        formParams.ogrn = '1022402056324';
        formParams.kpp = '246201001';
        formParams.normName = 'AOO, test';
        formParams.codeWord = 'ваываы';
        formParams.companyLegalAddressCountry = 'Russia';
        formParams.companyLegalAddressCity = 'г Красноярск';
        formParams.companyLegalAddressState = 'Красноярский край';
        formParams.companyLegalAddressStreet = 'Транспортный проезд';
        formParams.companyLegalAddressPostalCode = '660123';
        formParams.postalAddressCountry = 'Russia';
        formParams.postalAddressCity = 'г Красноярск';
        formParams.postalAddressStreet = '1022402056324';
        formParams.postalAddressPostalCode = '660123';
        formParams.companyLegalAddressHouse = '1';
        formParams.legalAddressAdditionally = 'fsdfd';
        formParams.postalAddressHouse = '2';
        formParams.postalAddressAdditionally = 'проезд';
        formParams.checkingAccount = '34534645645645645645';
        formParams.bankNameShort = 'ВЗАИМОДЕЙСТВИЕ';
        formParams.corBankAccount = '30101810250040000760';
        formParams.bankBic = '045004760';
        formParams.prepayAmount = '42344';
        formParams.sendToInbound = false;
        formParams.productId = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
        formParams.emailForPersonalOffice = 'fsdf@test.df';
        formParams.product = 'product';
        formParams.deliveryComments = 'ccc';
        formParams.executiveFio = 'executiveFio';
        formParams.executivePosition = 'executivePosition';
        return formParams;
    }

    public static void initTestDataForReportRequest(Account account, Opportunity opportunity, E2EFormData__c formDataRecord) {
        E2EFormRuTestUtils.initCustomSettings();

        account = createAccount('1234567890', System.today(), System.today());
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

        opportunity = createOpportunity(account.Id);
        insert opportunity;

        formDataRecord = createDefaultFormData();
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
    }
}
