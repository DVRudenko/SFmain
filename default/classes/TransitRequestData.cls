public class TransitRequestData {
    public TransitRequestData.Cont Cont { get; set; }
    public TransitRequestData.ContMonitoring ContMonitoring;
    public TransitRequestData.EDMInfo EDMInfo { get; set; }
    public List<TransitRequestData.Personal> Personal { get; set; }
    public List<TransitRequestData.Address> Address { get; set; }

    public class Cont {
        public String transitManagerId { get; set; }          // GUID менеджера в транзите
        public String companyName { get; set; }               // Наименование контрагента
        public String opportunityId { get; set; }             // Id Opportunity
        public String companyType { get; set; }               // Тип (ООО, ИП, ОАО)
        public String contractNumber { get; set; }            // Номер договора
        public String inn { get; set; }                       // ИНН контрагента
        public String kpp { get; set; }                       // КПП контрагента
        public String okpo { get; set; }                      // ОКПО
        public String ogrn { get; set; }                      // ОГРН
        public String checkingAccount { get; set; }           // Номер расчетного счета
        public Integer eqv { get; set; }                      // ID эквайрера
        public String contractType2 { get; set; }             // Коммерческая инфомарция -> Договор -> Тип договора
        public Integer carParkType { get; set; }              // Коммерческая информация -> Автопарк -> Тип автопарка
        public Integer clientFrom { get; set; }               // Коммерческая информация -> Маркетинговая информация -> Тип канала поиска
        public String partnerAlias { get; set; }              // Сервисная информация -> Договоры -> Партнерская программа (псевдоним партнёра в транзите)
        public Integer carParkForm { get; set; }              // Коммерческая информация -> Автопарк -> Вид автопарка
        public String codeWord { get; set; }                  // Сервисная информация -> Кодовое слово
        public Integer tarif { get; set; }                    // Тариф!! Сервисная информация -> Договоры -> Тип абоненской платы
        public String ruleChangeType { get; set; }            // Сервисная информация -> Договоры -> Порядок изменения условий
        public Integer promoCode { get; set; }                // Акция
        public String contractForm { get; set; }              // Сервисная информация -> Договоры -> Форма договора
        public String contractType1 { get; set; }             // Сервисная информация -> Договоры -> Тип договора
        public Integer personalManager { get; set; }          // Сервисная информация -> Платные услуги -> Персональный менеджер
        public Integer curierDelivery { get; set; }           // Сервисная информация -> Платные услуги -> Курьерская доставка (1, 0)
        public Integer factProsrochki { get; set; }           // Финансовая информация -> Плата за кредит -> Плата за факт просрочки
        public Integer lgotniyPeriod { get; set; }            // Финансовая информация -> Плата за кредит -> Льготный период, дней
        public Decimal procentPoCreditu { get; set; }         // Финансовая информация -> Плата за кредит -> Процент по кредиту
        public Integer prepayAmount { get; set; }             // Финансовая информация -> Тип работы -> Сумма предоплаты по договору
        public Integer tipCredita { get; set; }               // Финансовая информация -> Тип работы -> Тип кредита
        public Integer contractType { get; set; }             // Финансовая информация -> Тип работы -> Тип работы (16, 17)
        public String tipPeni { get; set; }                   // Финансовая информация -> Пени -> Тип пени
        public Decimal znacheniePeni { get; set; }            // Финансовая информация -> Пени -> Значение
        public Integer dopustimayaZadolzenostSumma { get; set; }  // Финансовая информация -> Допустимая задолженность -> Сумма
        public Integer dopustimayaZadolzenostValuta { get; set; } // Финансовая информация -> Допустимая задолженность -> Валюта
        public Integer znachenieOvedrafta { get; set; }       // Финансовая информация -> Овердрафт (Максимальный) - Лимит АС -> Значение овердрафта
        public String opoveshatPoEmail { get; set; }          // Финансовая информация -> Овердрафт (Максимальный) - Лимит АС -> Оповещать по емэйл
        public Integer overdrSumm { get; set; }               // Финансовая информация -> Овердрафт официальный (и "Услуга Доверие") -> Сумма
        public String uslugaDoveria { get; set; }             // Финансовая информация -> Овердрафт официальный (и "Услуга Доверие") -> Услуга доверия
        public String bezDS { get; set; }                     // Финансовая информация -> Овердрафт официальный (и "Услуга Доверие") -> Без ДС
        public Integer dueDate { get; set; }                  // Финансовая информация -> Срок оплаты счета -> Дней
        public Integer invoiceDueDate { get; set; }           // Финансовая информация -> Срок оплаты счёт-фактуры -> Дней
        public String partnerGuarantor { get; set; }          // Финансовая информация -> Гарантии партнера -> Поручитель
        public String guaranteesDatein { get; set; }          // Финансовая информация -> Гарантии партнера -> Дата начала гарантии
        public String bic { get; set; }                       // бик банка
        public String bankNameFull { get; set; }              // название банка
        public String bankNameShort { get; set; }             // сокращенное название банка
        public String bankBic { get; set; }                   // бик ркц банка
        public String corBankAccount { get; set; }            // коррсчет банка
        public String bankInn { get; set; }                   // инн банка
        public String bankKpp { get; set; }                   // кпп банка
        public String bankOkpo { get; set; }                  // окпо банка
        public String bankTown { get; set; }                  // название города банка
        public String bankAddress { get; set; }               // адресс банка
        public String companyPhone { get; set; }              // телефон
        public Integer p_is_for_fin_sms { get; set; }         // связь, для отправки фин смс (1-true, 0-false)
        public Integer p_is_mobile { get; set; }              // связь, мобильный (1-true, 0-false)
        public String companyEmail { get; set; }              // e-mail
        public String p_invoice_doc_num { get; set; }         // номер платежа для оплаты предоплаты
        public Decimal p_invoice_sum { get; set; }            // сумма платежа без НДС
        public Decimal p_invoice_sum_nds { get; set; }        // сумма платежа с НДС
        public String p_invoice_article { get; set; }         // назначение платежа
        public String emailForLK { get; set; }                // email для ЛК
        public String persOfficePhone { get; set; }           // мобильный телефон для доступа в ЛК
        public String postcode { get; set; }                  // Почтовый индекс
        public String p_standart_promos { get; set; }         // Стандартныйе промоакции
        public String contractDate { get; set; }              //  Дата договора	
    }

    public class ContMonitoring {
        public Integer sourceOfLead;                          // Канал привлечения - inbound, E2E, партнеры
        public Integer newLegal;                              // Новое ЮЛ (в пределах 12 месяцев с момента создания)
        public Integer newFounder;                            // Смена учредителя за последние 6 месяцев
        public Integer massRegistrationAddress;               // Адрес массовой регистрации
        public Integer differentPostAddress;                  // Запрос отправки договора и карт на адрес, отличный от юридического
        public Integer firstBill;                             // Запрос первого счета на сумму более 500 т.р.
        public Integer notificationSent;                      // признак, что тотал был достигнут, и письмо было отправлено из SF
    }

    public class Personal {
        public String name { get; set; }                      // Имя
        public String surname { get; set; }                   // Фамилия
        public String parentName { get; set; }                // Отчество
        public String fullName { get; set; }                  // ФИО
        public String title { get; set; }                     // Наименование должности
        public String onBasis { get; set; }                   // На основании чего действует
        public Integer titleType { get; set; }                // Тип сотрудника
    }

    public class Address {
        public Integer rekType { get; set; }                  // Тип реквизитов
        public String address { get; set; }                   // Адрес
        public String postCode { get; set; }                  // Почтовый индекс
        public String mailCity { get; set; }                  // Город
        public String mailStreet { get; set; }                // Улица
        public String mailReceiver { get; set; }              // Получатель почты
    }

    public class EDMInfo {
        public String electronicDocumentManagement { get; set; }    // имя оператора
        public Integer docType { get; set;}                         // типдокумента 1-договор, 2 - доп соглашение
        public Integer docSigned { get; set; }                      // документ подписан (1-true, 0-false)
        public String signDate { get; set; }                        // дата подписания
    }
}