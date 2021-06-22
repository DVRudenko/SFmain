/**
 * E2E Form params class for processes logic
 */
public class E2EFormParams {

    /* For analytics fields */
    public String utmCampaign { get; set; }                     // рекламная кампания
    public String utmContent { get; set; }                      // тип объявления
    public String utmMedium { get; set; }                       // тип трафика
    public String utmTerm { get; set; }                         // ключевое слово, которое инициировало показ объявления
    public String utmSource { get; set; }                       // рекламная система
    public String utmUrl { get; set; }
    public String utmIp { get; set; }
    public String utmRegion { get; set; }
    public String websitePageForm { get; set; }                 // полный url
    Public String splitWTL { get; set; }                        // Разбивка клиентов на разный способ попадания в E2E с Web-To-Lead формы сайта
    public String splitTesting {
        get;
        set {
            if (value != null && value != '') {
                E2E_Split_Testing__c splitObject = E2E_Split_Testing__c.getValues(value);
                if (splitObject != null) {
                    this.splitTesting = splitObject.Name;
                    this.productSplitTesting = splitObject.Target__c;
                } else {
                    this.splitTesting = '';
                    this.productSplitTesting = this.product;
                }
            } else {
                this.splitTesting = '';
                this.productSplitTesting = this.product;
            }
        }
    }                    // ABC-тест

    public String productSplitTesting { get; set; }                 // продукт для ABC-теста

    public Boolean sendToInbound {                              // признак отправки в Инбаунд
        get {
            if (this.sendToInbound == null) {
                return false;
            } else {
                return this.sendToInbound;
            }
        }

        set {
            if (value == true) {
                this.sendToInbound = true;
            }
        }
    }

    public Id opportunityId { get; set; }
    public Id contactId { get; set; }
    public Id accountId { get; set; }
    public Id formDataId { get; set; }
    public String externalUser { get; set; }                    // name of the user from external system

    public String clientId { get; set; }                      // Client Id (получаемый из гугл аналитики или URL)

    public String leadId { get; set; }                       // lead Id (получаемый из  URL)

    public boolean useDebugTemplate { get; set; }

    public String encodedURL { get; set; }                      // закодированный url
    public String generatedUrlWithHash { get; set; }            // полная ссылка с доменом и сгенерированным hash

    public String businessProcess { get; set; }                 // тип бизнес процесса (-> GlobalUtils)
    public String processStatus { get; set; }                   // status of the process
    public String errors { get; set; }                          // errors & exceptions
    public Boolean isSoleProprietor { get; set; }               // признак, что клиент является ИП
    public String deduplicationStatus { get; set; }             // статус процесса дедубликации
    public String deduplicationStatusInfo { get; set; }         // расшифровка статуса дедубликации
    public Datetime deduplicationDatetime { get; set; }          // дата и время дедубликации

    public String companyFullNameDadata { get; set; }           // полное название компании, которое приходит из Dadata
    public String bankNameShort { get; set; }                   // короткое название банка из Dadata
    public String bankName { get; set; }                        // полное название банка из Dadata
    public String bankAddress { get; set; }                     // адрес банка из Dadata
    public String bankTown { get; set; }                        // город банка из Dadata
    public String bankOkpo { get; set; }                        // окпо банка
    public String bankBic { get; set; }                         // БИК банка
    public Boolean isBankInformationInvalid { get; set; }         // Проверка совпадения "Наименования банка"/"БИК банка"/"КС банка" с данными из Dadata


    public String verification {
        get;
        set {
            this.verification = value;
            ScoringWebService scoringWebService = new ScoringWebServiceImpl();
            CompanyVerificationScoring verificationScoring;
            if (value != null && value != '') {
                verificationScoring = (CompanyVerificationScoring) System.JSON.deserialize(value, CompanyVerificationScoring.class);
                if (verificationScoring != null) {
                    this.verifiedDecision = scoringWebService.prepareBlackListDecisionForSF(verificationScoring.decision);
                    this.verifiedDecisionCode = String.valueOf(verificationScoring.decision);
                    this.verifiedLimitation = String.valueOf(verificationScoring.limitation);
                } else {
                    throw new E2EFormRuException('**** Error: Setter verificationScoring is null');
                }
            }
        }
    }

    public String decision {
        get;
        set {
            this.decision = value;
            DecisionScoring decision;
            ScoringWebService scoringWebService = new ScoringWebServiceImpl();
            if (value != null && value != '') {
                decision = (DecisionScoring) System.JSON.deserialize(value, DecisionScoring.class);
                if (decision != null) {
                    this.scoringDecision = scoringWebService.prepareScoringDecisionForSF(decision.decision);
                    this.scoringDecisionCode = String.valueOf(decision.decision);
                    this.scoringDate = Date.today();
                } else {
                    throw new E2EFormRuException('**** Error: Setter decisionScoring is null');
                }
            }
        }
    }

    public String companyInfoSpark {
        get;
        set {
            this.companyInfoSpark = value;
            if (value != null && value != '') {
                CompanySpark companySpark = (CompanySpark) System.JSON.deserialize(value, CompanySpark.class);

                if (companySpark.extendedReport != null) {
                    SparkWebService sparkWebService = new SparkWebServiceImpl();
                    ExtendedReportSpark.Leader actualLeader = sparkWebService.getCompanyActualLeader(companySpark.extendedReport.LeaderList.leader);
                    this.sparkId = companySpark.sparkID;
                    this.mainCompanyFullNameSpark = companySpark.fullName;
                    this.registrationDateSpark = String.valueOf(((DateTime) Json.deserialize('"' + companySpark.extendedReport.dateFirstReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                    this.executiveFio = actualLeader.fio;
                    this.executivePosition = actualLeader.position;
                    this.okpoSpark = companySpark.extendedReport.okpo;
                    this.emptySparkOkpo = String.isBlank(companySpark.extendedReport.okpo);
                    this.ogrnSpark = companySpark.extendedReport.ogrn;
                    this.kppSpark = companySpark.extendedReport.kpp;
                    this.companyCountry = 'Россия';
                    this.postCodeSpark = companySpark.extendedReport.LegalAddresses.address.postCode;
                    this.regionSpark = companySpark.extendedReport.LegalAddresses.address.region;
                    this.citySpark = companySpark.extendedReport.LegalAddresses.address.city;
                    this.streetSpark = companySpark.extendedReport.LegalAddresses.address.streetName;
                    this.buildingSpark = companySpark.extendedReport.LegalAddresses.address.buildingNumber;
                    this.housingSpark = companySpark.extendedReport.LegalAddresses.address.housing;
                    this.blockSpark = companySpark.extendedReport.LegalAddresses.address.block;
                    this.roomSpark = companySpark.extendedReport.LegalAddresses.address.room;
                    this.legalAddressSpark = companySpark.extendedReport.LegalAddresses.address.address;
                    this.normName = companySpark.extendedReport.normName;
                    //this.companyInn = companyInn;
                } else {
                    throw new E2EFormRuException('Error: Setter CompanySparkInfo - extendedReport is null');
                }
            }
        }
    }
    public String soleInfoSpark {
        get;
        set {
            this.soleInfoSpark = value;
            if (value != null && value != '') {
                SoleProprietorSpark soleProprietorSpark = (SoleProprietorSpark) System.JSON.deserialize(value, SoleProprietorSpark.class);
                if (soleProprietorSpark != null && soleProprietorSpark.sparkID != null) {
                    this.sparkId = soleProprietorSpark.sparkID;
                    this.companyInn = soleProprietorSpark.inn;
                    this.soleProprietorFio = soleProprietorSpark.fullNameRus;
                    this.mainCompanyFullNameSpark = 'ИП ' + soleProprietorSpark.fullNameRus;
                    this.registrationDateSpark = String.valueOf(((DateTime) Json.deserialize('"' + soleProprietorSpark.dateReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                    this.ogrnipSpark = soleProprietorSpark.ogrnip;
                    this.okpoSpark = soleProprietorSpark.okpo;
                    this.emptySparkOkpo = String.isBlank(soleProprietorSpark.okpo);
                } else {
                    throw new E2EFormRuException('Error: Setter EntrepreneurShortReport - soleProprietorSpark or sparkID is null');
                }
            }
        }
    }

// SPARK params
    public Decimal sparkId { get; set; }                        // идентификатор компании из СПАРКа
    public Boolean isActing = null;                             // флаг действующей организации
    public String registrationDateSpark { get; set; }           // дата регистрации компании из СПАРКа
    public String mainCompanyFullNameSpark { get; set; }        // полное название компании из СПАРКа
    public String postCodeSpark { get; set; }                   // индекс из СПАРКа
    public String companyCountry { get; set; }                  // страна (в СПАРКе ее нет, дефолтно Россия)
    public String regionSpark { get; set; }                     // регион из СПАРКа
    public String citySpark { get; set; }                       // город из СПАРКа
    public String streetSpark { get; set; }                     // улица из СПАРКа
    public String buildingSpark { get; set; }                   // номер дома из СПАРКа
    public String housingSpark { get; set; }                    // корпус из СПАРКа
    public String blockSpark { get; set; }                      // строение из СПАРКа
    public String roomSpark { get; set; }                       // квартира/офис/помещение из СПАРКа
    public String legalAddressSpark { get; set; }               // полный адрес компании из СПАРКа
    public String opportunityLostReason { get; set; }           // причина потери возможности
    public String normName { get; set; }                        //  normName из спарка
    public String billingApartment { get; set; }                //

    public String ogrnSpark { get; set; }                       // ОГРН из СПАРКа
    public String ogrnipSpark { get; set; }                     // ОГРНИП (для ИП) из СПАРКа
    public String okpoSpark { get; set; }                       // ОКПО из СПАРКа
    public Boolean emptySparkOkpo { get; set; }                 // ОКПО в СПАРК нет
    public String okvedSpark { get; set; }                      // ОКВЭД из СПАРК
    public String kppSpark { get; set; }                        // КПП из СПАРКа
    public String executiveFio { get; set; }                    // ФИО руководителя из СПАРКа
    public String executiveFioManual { get; set; }              // ФИО руководителя
    public String executivePosition { get; set; }               // должность руководителя из СПАРКа
    public String executivePositionManual { get; set; }         // должность руководителя
    public String executiveId { get; set; }                     // Id контакта для руководителя
    public String executivePhone {get; set; }                   // телефон

    public String soleProprietorFio { get; set; }               // ФИО для ИП

    // SCORING params
    public String verifiedDecision { get; set; }                // тип решения проверки по ЧЧС в Скоринге
    public String verifiedDecisionCode { get; set; }            // код типа решения проверки по ЧЧС в Скоринге
    public String verifiedLimitation { get; set; }              // максимальный срок отсрочки платежа, если ответ на проверку «ограничение по отсрочке»
    public String scoringDecision { get; set; }                 // тип решения в Скоринге
    public String scoringDecisionCode { get; set; }             // код типа решения в Скоринге
    public Date scoringDate { get; set; }                       // дата скоринга
    public String scoringDateString { get; set; }               // дата скоринга (строка для отображения на форме)
    public Date scoringExpirationDate { get; set; }             // дата когда скоринг будет не действителен
    public String scoringExpirationDateString { get; set; }     // дата когда скоринг будет не действителен (строка для отображения на форме)
    public String overdraftSum { get; set; }                    // овердрафт предоставленный клиенту

    // MZK params
    public String requestNumMZK { get; set; }                   // номер заявки в МЗК (Модуль Заказа Карт)

    // Transit Cont Id
    public String transitContId { get; set; }                   // Cont Id который приходит из транзита
    public String transitManagerId { get; set; }                // Id менеджера в транзите
    public Integer businessType { get; set; }
    public Integer idEqv { get; set; }
	//VS SF-1429
    public String electronicDocumentManagement { get; set; }    // Подключение "ЭДО"

    // Promocode
    public String promoCodeName { get; set; }                   // наименование промокода
    public String promoCodeIdInTransit { get; set; }            // индификатор промокода в транзите
    public String addPromoCodeName { get; set; }                // наименование дополнительного промокода
    public String addPromoCodeIdInTransit { get; set; }         // индификатор дополнительного промокода в транзите

    // Contract
    public String contractType { get; set; }                    // тип договора
    public String contractPrefix { get; set; }                  // префикс договора (отправляется в транзит)
    public String contractCounter { get; set; }                 // номер договора (отправляется в транзит)
    public String invoicePrefix { get; set; }                   // Префикс номера счета
    public String invoiceCounter { get; set; }                  // Счетчик номера счета

    // Form process statuses
    public String contactDetails { get; set; }                  // пройден шаг Контактные данные
    public String sfDeduplication1 { get; set; }                // пройден 1 этап дедубликации
    public String sfDeduplication2 { get; set; }                // пройден 2 этап дедубликации
    public String getSparkData { get; set; }                    // получены данные из СПАРК
    public String checkedInBlackList { get; set; }              // пройдена проверка по ЧЧС
    public String scoringPassed { get; set; }                   // пройден Скорин
    public String sfDeduplication3 { get; set; }                // пройден 3 этап дедубликации
    public String sendCrmRequest { get; set; }                  // отправлена заявка в CRM
    public String companyDetails { get; set; }                  // пройден шаг Данные о компании
    public String cardOrderDetails { get; set; }                // пройден шаг Заказ карт
    public String legalDetails { get; set; }                    // пройден шаг Реквизитов компании
    public String paymentDetails { get; set; }                  // пройден шаг Платежных реквизитов
    public String getReport { get; set; }                       // получены шаблоны документов
    public String createContInTransit { get; set; }             // создан контрагент в Транзит
    public String sendMzkRequest { get; set; }                  // отправлена заявка в МЗК
    public String saveReport { get; set; }                      // документы были сохранены
    public Boolean isManualEntry { get; set; }                  // указатель на ручной ввод данных о компании
    public Boolean isNumberOfCardsLimit { get; set; }           // количество кард превышает лимит для inbound
    public Integer numberOfCardsEntered { get; set; }           // введенное количество карт

    //formData
    public String formDataName { get; set; }

    public String contactFirstName { get; set; }                // имя контакта
    public String contactLastName { get; set; }                 // фамилия контакта
    public String contactFullName { get; set; }                 // полное имя контакта
    public String mainContactEmail { get; set; }                // email основного контакта
    public String mainContactPhone { get; set; }                // телефон основного контакта
    public String companyName { get; set; }                     // название компани
    public String companyInn { get; set; }                      // ИНН
    public Decimal numOfCards { get; set; }                     // количество карт
    public List<String> cards { get; set; }                     //список номеров карт
    public Boolean virtualCards { get; set; }                   // услуга ППР Pay
    public Boolean hasPersonalManager { get; set; }            // услуга персональный консультант
    public Boolean hasDocumentDelivery { get; set; }            // услуга экспресс-доставка отчетных документов
    public String creditDecision { get; set; }                  // кредитное решение
    public Boolean freeOverdraft { get; set; }                  // услуга БЕЗплатный овердрафт
    public String ogrn { get; set; }                            // ОГРН
    public String okpo { get; set; }                            // ОКПО
    public String kpp { get; set; }                            // КПП
    public String companyLegalAddress { get; set; }             // юридический адрес компании
    public String companyLegalAddressCountry { get; set; }      // юридический адрес страна
    public String companyLegalAddressCity { get; set; }         // юридический адрес город
    public String companyLegalAddressStreet { get; set; }       // юридический адрес улица
    public String companyLegalAddressPostalCode { get; set; }   // юридический адрес код
    public String companyLegalAddressHouse { get; set; }        // юридический адрес дом
    public String companyLegalAddressState { get; set; }        // юридический адрес область/район
    public String legalAddressAdditionally { get; set; }        // дополнительная информация по юридическому адресу
    public String postalAddress { get; set; }                   // адрес для доставки
    public String postalAddressCountry { get; set; }            // почтовый адрес страна
    public String postalAddressCity { get; set; }               // почтовый адрес город
    public String postalAddressStreet { get; set; }             // почтовый адрес улица
    public String postalAddressPostalCode { get; set; }         // почтовый адрес код
    public String postalAddressHouse { get; set; }              // почтовый адрес дом
    public String postalAddressState { get; set; }              // почтовый адрес область/район
    public String postalAddressAdditionally { get; set; }       // дополнительная информация по адрес для доставки
    public Boolean isLegalAddressCorrespondWithPostAddress { get; set; } // адрес доставки совпадает с юридическим адресом
    public String codeWord { get; set; }                        // кодовое слово
    public String emailForPersonalOffice { get; set; }          // email для личного кабинета
    public String personalOfficePhone { get; set; }             // мобильный телефон для личного кабинета
    public String deliveryComments { get; set; }                // дополнительная информация по доставке карт
    public String checkingAccount { get; set; }                 // рассчетный счет
    public String corBankAccount { get; set; }                  // корреспондентский счет
    public String prepayAmount { get; set; }                    // нициирующий платеж
    public Datetime lastLaunch { get; set; }                    // Дата последнего запуска из E2E Бизнес
    public String promoCode { get; set; }                       // промокод
    public String addPromoCode { get; set; }                    // дополнительный промокод

    public String product {
        get;
        set {
            this.product = value;
            if (String.isNotEmpty(value)) {
                Map<String, Object> mapping = PPRProductSettingsUtils.getTariffMapping(value);
                if (mapping != null) {
                    this.tariffId = String.valueOf(mapping.get('tariff'));
                    this.productId = String.valueOf(mapping.get('product'));
                }
            }
        }
    }                         // продукт
    public String productId { get; set; }                       // продукт Id
    public String tariffId { get; set; }                        // тариф Id
    public String deviceType { get; set; }                      // тип устройства, с которого заходили
    public String source { get; set; }                          // ресурс, с которого заходили
    public String sourcePP { get; set; }
    public String sourceIfSelfSourced { get; set; }
    public String offer { get; set; }                           // оффер
    public String ipAddress { get; set; }                       // ip адрес
    public String sourceLead { get; set; }                      // Source of Lead

    public String numberOfTariffsDependency { get; set; }
    public Boolean matchExecutiveSpark { get; set; }

    public E2EFormParams() {
        this.useDebugTemplate = false;

        this.contactFirstName = '';
        this.contactLastName = '';
        this.mainContactEmail = '';
        this.mainContactPhone = '';
        this.companyName = '';
        this.companyInn = '';
        this.numOfCards = 0;
        this.virtualCards = false;
        this.hasPersonalManager = false;
        this.hasDocumentDelivery = false;
        this.creditDecision = '';
        this.freeOverdraft = false;
        this.ogrn = '';
        this.okpo = '';
        this.kpp = '';
        this.companyLegalAddress = '';
        this.legalAddressAdditionally = '';
        this.postalAddress = '';
        this.postalAddressAdditionally = '';
        this.isLegalAddressCorrespondWithPostAddress = false;
        this.codeWord = '';
        this.emailForPersonalOffice = '';
        this.personalOfficePhone = null;
        this.deliveryComments = '';
        this.checkingAccount = '';
        this.corBankAccount = '';
        this.prepayAmount = '';

        this.sparkId = null;
        this.mainCompanyFullNameSpark = '';
        this.bankNameShort = '';
        this.bankAddress = '';
        this.bankTown = '';
        this.bankOkpo = '';
        this.isBankInformationInvalid = false;
        this.verifiedDecisionCode = '';
        this.verifiedDecision = '';
        this.verifiedLimitation = '';
        this.scoringDecision = '';
        this.scoringDecisionCode = '';
        this.scoringDateString = '';
        this.scoringExpirationDateString = '';
        this.contactDetails = '';
        this.sfDeduplication1 = '';
        this.sfDeduplication2 = '';
        this.getSparkData = '';
        this.checkedInBlackList = '';
        this.scoringPassed = '';
        this.sfDeduplication3 = '';
        this.sendCrmRequest = '';
        this.companyDetails = '';
        this.cardOrderDetails = '';
        this.legalDetails = '';
        this.paymentDetails = '';
        this.getReport = '';
        this.createContInTransit = '';
        this.sendMzkRequest = '';
        this.saveReport = '';
        this.sendToInbound = false;
        this.isSoleProprietor = false;
        this.opportunityLostReason = '';
        this.isManualEntry = false;
        this.isNumberOfCardsLimit = false;
        this.numberOfCardsEntered = 0;
        this.businessProcess = '';

        this.ogrnSpark = '';
        this.ogrnipSpark = '';
        this.okpoSpark = '';
        this.emptySparkOkpo = false;
        this.kppSpark = '';
        this.executiveFio = '';
        this.executivePosition = '';
        this.executiveId = null;
        this.executivePhone = '';

        this.formDataName = '';

        this.requestNumMZK = '';
        this.transitContId = '';

        this.contractType = '';
        this.promoCode = '';
        this.product = '';
        this.deviceType = '';
        this.source = '';
        this.sourcePP = '';
        this.sourceIfSelfSourced = '';
        this.offer = '';
        this.ipAddress = '';
        this.sourceLead = '';

        this.numberOfTariffsDependency = '';
        this.websitePageForm = '';
        this.splitTesting = '';
        this.productSplitTesting = '';
        this.splitWTL = '';

        this.matchExecutiveSpark = false;
        this.overdraftSum = null;
    }
}
