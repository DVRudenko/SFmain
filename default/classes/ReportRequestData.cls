public class ReportRequestData {
    // Credit Factory parameters
    public String inn { get; set; }                       // Инн клиента
    public String companyName { get; set; }               // Название компании клиента
    public String sFRequestId { get; set; }               // OpportunityId (Id SF объекта)
    public boolean useDebugTemplate = false;       // Тест шаблонов договоров

    /* 1. В кредитную фабрику необходимо отправить индентификатор продукта для Кредитной фабрики
    *  Список идентификаторов (Id, Name):
    *   1,'Вездеход онлайн'
    *   2,'карты ГАЗПРОМ'
    *   3,'карты ШЕЛЛ' */
    public String productId { get; set; }

    /* 2. Необходимо отправить идентификатор тарифа для Кредитной фабрики
    *  Список идентификаторов (Id, Name):
    *   1,'Оптимальный с договора'
    *   2,'Оптимальный с карты'
    *   3,'Избранный с договора'
    *   4,'Избранный с карты'
    *   5,'ГЭС  с договора'
    *   6,'ГЭС с карты'
    *   7,'ШЕЛЛ'
    *   8, Избранный+ с договора
    *   9, Избранный+ с карты
    *   10, Супер с договора
    *   11, Супер с карты
    *   12, Лайт с договора
    *   13, Лайт с карты
    * */
    public String tariffId { get; set; }

    /* 3. Необходимо передать идентификатор промокода для Кредитной фабрики
    *   Список идентификаторов (Id, Name):
    *   1,'Лукойл  и  Статойл, Транзитсити '
    *   2,'(РН, Башнефть, ТНК) и Статойл, Транзитсити '
    *   3,'Шелл и Статойл, Транзитсити '
    *   4,'ГПН и Статойл, Транзитсити'
    *   5,' Скидка 50 коп/л. топлива при заправке на АЗС «Роснефть», "ТНК», «Лукойл», «Газпромнефть»,  "Статойл" , "Транзит Сити".'
    *   6,'Татнефть и Статойл, Транзитсити '
    *   7,'«Отмена платных транзакций вне сети "ГЭС»'
    *   8,'Надежный выбор' */
    public String specialOfferId { get; set; }


    public Boolean hasPersonalManager { get; set; }       // Выбран ли персональный менеджер
    public Boolean hasCredit { get; set; }                // Выбран ли Овердрафт
    public Boolean hasExpressDelivery { get; set; }       // Выбрана ли экспресс доставка
    public Boolean preview { get; set; }                  // Предпросмотр документов
    public Integer amount { get; set; }                   // Сумма платежа
    public String bikBank { get; set; }                   // БИК банка клиента
    public List<String> mailList { get; set; }            // список рассылки подписанного ЭЦП договора
    public String mailType {get; set;}                    // тип сообщения (TEXT или HTML)
    public String mailSubject {get; set;}                 // Тема письма для отправки
    public String mailBody {get; set;}                    // Текст письма для отправки
    public Boolean specPartner { get; set; }              // Флаг, определяющий партнера да/нет

    /* Роль, которая указана у отправителя заявки
    *   Список идентификаторов (Id, Name):
    *   0 - ППР
    *   4 - GPC */
    public Integer businessType { get; set; } 
    /* Список идентификаторов (Id, Name):
    *   1 - ППР
    *   26 - GPC */
    public Integer idEqv { get; set; } 
	
    // Флаг, определяющий нужно ли создавать документ для ППР Пей
    public Boolean createPPRPayContract { get; set; }	
    public Boolean createPrescoringDocument { get; set; }

    // Report service parameters
    public ReportRequestData.ReportParams reportParams { get; set; }


    public class ReportParams {
        public String CONTRACT_DATE { get; set; }                         // Дата создания договора
        public String CONTRACT_NUM { get; set; }                          // Номер договора
        public String PAY_UNTIL_DATE {get; set;}                          // Дата создания договора + 1 месяц


        public String NUMBER_OF_CARDS { get; set; }                       // Количество карт
        public String NUMBER_OF_CARDS_TEXT { get; set; }                  // Количество карт (числительные)
        public String SECURITY_PHRASE { get; set; }                       // Кодовое слово
        public String USERNAME { get; set; }                              // Имя пользоватле (почтовый адрес)
        public String PRODUCT_NAME { get; set; }                          // Название продукта
        public Boolean HAS_OVERDRAFT { get; set; }                        // платный овердрафт
        public String OVERDRAFT_SUM { get; set; }                         // сумма овердрафта текст цифрами
        public String OVERDRAFT_SUM_TEXT { get; set; }                    // сумма овердрафта текст словами
        public Boolean HAS_COURIER { get; set; }                          // Экспресс доставка отчетных документов
        public Boolean HAS_PERSONAL_MANAGER { get; set; }                 // Платный персональный менеджер
        public Integer BILL_SUM { get; set; }                             // Сумма счета для предоплатных клиентов
        public String EXT_CLIENT_ID { get; set; }                         // Код возможности SF
        public Integer IS_VEZDEHOD_CHOSEN_PLUS_FROM_CARD { get; set; }    // Тариф Избранный+ с карты
        public Integer IS_VEZDEHOD_CHOSEN_PLUS_FROM_CONTRACT { get; set; } // Тариф Избранный+ с договора

        public String CLIENT_INN { get; set; }                            // ИНН
        public String CLIENT_KPP { get; set; }                            // КРР
        public String CLIENT_OGRN { get; set; }                           // ОГРН
        public String CLIENT_OKPO { get; set; }                           // ОКПО
        public String CLIENT_LEGAL_ADDRESS { get; set; }                  // Юридический адрес
        public String CLIENT_ADDRESS { get; set; }                        // Почтовый адрес
        public String CLIENT_CURRENT_ACCOUNT { get; set; }                // Расчетный счет
        public String CLIENT_COR_ACCOUNT { get; set; }                    // Корреспонденский счет
        public String CLIENT_BANK_NAME { get; set; }                      // Имя Банка
        public String CLIENT_BIK { get; set; }                            // БИК
        public String CLIENT_PHONE { get; set; }                          // Номер телефона клиента
        public String CLIENT_EMAIL { get; set; }                          // Почтоый адрес клиента
        public String CLIENT_NAME { get; set; }                           // Полное название компании
        public String CLIENT_MOB_PHONE_FIN { get; set; }                  // Номер телефона
        public String CLIENT_MOB_PHONE_INFO { get; set; }                 // Номер телефона
        public String CLIENT_SIGNER_POST { get; set; }                    // Должностное лицо подписывающего договор
        public String CLIENT_SIGNER_FIO { get; set; }                     // ФИО подписанта(полностью)
        public String CLIENT_ACCOUNTER_FIO { get; set; }                  // ФИО Главного бухгалтера
        public String EXTRA_INFO { get; set; }                            // Информация для куръеркской службы

        // Promocode
        public String PROMOCODE { get; set; }                             // Код промокода
        public String SPECIAL_OFFER_NAME { get; set; }                    // Наименование промокода
        public String SUPPLIER { get; set; }                              // Поставщик

        // Сейчас передаются пустыми (не используются)
        public String CONSIGNEE_NAME { get; set; }                        // Имя получателя
        public String CONSIGNEE_INN { get; set; }                         // ИНН получателя
        public String CONSIGNEE_KPP { get; set; }                         // КПП получателя
        public String CONSIGNEE_OGRN { get; set; }                        // ОГРН получателя
        public String CONSIGNEE_OKPO { get; set; }                        // ОКПО получателя
        public String CONSIGNEE_LEGAL_ADDRESS { get; set; }               // Юридический адрес получателя
        public String CONSIGNEE_ADDRESS { get; set; }                     // Почтоый адрес получателя
        public String CONSIGNEE_CURRENT_ACCOUNT { get; set; }             // Расчетный счет получателя
        public String CONSIGNEE_BANK_NAME { get; set; }                   // Наименование банка получателя
        public String CONSIGNEE_COR_ACCOUNT { get; set; }                 // Корреспондентский счет банка получателя
        public String CONSIGNEE_BIK { get; set; }                         // БИК получателя
        public String CONSIGNEE_PHONE { get; set; }                       // Телефон получателя
        public String CONSIGNEE_EMAIL { get; set; }                       // Email получателя
        public String CONSIGNEE_MOB_PHONE_FIN { get; set; }               // Телефон фин. отдела получателя
        public String CONSIGNEE_MOB_PHONE_INFO { get; set; }              // Дополнительный телефон получателя
        public String PARTNER_NAME { get; set; }                          // Имя партнера


        public String ADDITIONAL_CONTRACT_DATE { get; set; }              // Дополнительная дата
        public String ATTACHMENT_NUM { get; set; }

        //VS SF-1422
        public String SELLER_NAME { get; set; }                           // Полное наименование продавца
        public String SELLER_SITE { get; set; }                           // Сайт продавца

        public String CREDIT_CONDITIONS { get; set; }                     // Кредитное решение в шаблоне реквизитов
        public String CREDIT_PERIOD { get; set; }                         // Срок кредита прописью
        public String DUE_DATE { get; set; }                              // Срок оплаты
        public String DUE_DATE_IN_WORDS { get; set; }                     // Срок оплаты пропиьсю
        public String CREDIT_LIMIT { get; set; }                          // Максимальный объём кредита
        public String CREDIT_LIMIT_IN_WORDS { get; set; }                 // Максимальный объём кредита прописью
        public String PERSONAL_OFFICE_EMAIL { get; set; }
        public String PERSONAL_OFFICE_PHONE { get; set; }

        public ReportParams() {

            this.CONTRACT_DATE = '';
            this.PAY_UNTIL_DATE = '';
            this.NUMBER_OF_CARDS = '';
            this.NUMBER_OF_CARDS_TEXT = '';
            this.SECURITY_PHRASE = '';
            this.CREDIT_CONDITIONS = '';
            this.USERNAME = '';
            this.PRODUCT_NAME = '';
            this.BILL_SUM = 0;
            this.EXT_CLIENT_ID = '';
            this.HAS_PERSONAL_MANAGER = false;
            this.HAS_OVERDRAFT = false;
            this.HAS_COURIER = false;

            this.CLIENT_INN = '';
            this.CLIENT_KPP = '';
            this.CLIENT_OGRN = '';
            this.CLIENT_OKPO = '';
            this.CLIENT_LEGAL_ADDRESS = '';
            this.CLIENT_ADDRESS = '';
            this.CLIENT_CURRENT_ACCOUNT = '';
            this.CLIENT_COR_ACCOUNT = '';
            this.CLIENT_BANK_NAME = '';
            this.CLIENT_BIK = '';
            this.CLIENT_PHONE = '';
            this.CLIENT_EMAIL = '';
            this.CLIENT_MOB_PHONE_FIN = '';
            this.CLIENT_MOB_PHONE_INFO = '';
            this.CLIENT_NAME = '';
            this.CLIENT_SIGNER_POST = '';
            this.CLIENT_SIGNER_FIO = '';
            this.CLIENT_ACCOUNTER_FIO = '';
            this.EXTRA_INFO = '';
            this.CREDIT_PERIOD = '';
            this.DUE_DATE = '';
            this.DUE_DATE_IN_WORDS = '';
            this.CREDIT_LIMIT  = '';
            this.CREDIT_LIMIT_IN_WORDS = '';
            this.PERSONAL_OFFICE_EMAIL = '';
            this.PERSONAL_OFFICE_PHONE = '';

            // TODO: убрать эту инициализацию после того, как Леша М. добавит логику у себя в фабрике
            this.IS_VEZDEHOD_CHOSEN_PLUS_FROM_CARD = 0;
            this.IS_VEZDEHOD_CHOSEN_PLUS_FROM_CONTRACT = 0;


            // Promocode
            this.PROMOCODE = '';
            this.SPECIAL_OFFER_NAME = '';
            this.SUPPLIER = '';

            // Дополнительно
            this.ADDITIONAL_CONTRACT_DATE = '';
            this.ATTACHMENT_NUM = '';
        }
    }
}
