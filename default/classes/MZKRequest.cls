public class MZKRequest {
    public MZKRequest.MzkCards Cards { get; set; }

    public class MzkCards {
        public Integer sendType { get; set; }             // default 3 (курьерская служба) - способ отправки карт - ok
        public String transitId { get; set; }             // идентификатор контрагента из транзита - ok
        public String requestDescription { get; set; }    // Примечание - ok
        public String logUser { get; set; }               // default (93D6ED45932B44A4AE8AF3934AC1C940) идентификатор пользователя в транзите
        public Integer isTemplate { get; set; }           // default 0 (признак не шаблона)
        public Integer eqv { get; set; }                  // default 1 (ППР)
        public String serviceId { get; set; }             // идентификатор улсуг через ';'
        public String limitVal { get; set; }              // default 0 - значение лимита
        public String limitTypeId { get; set; }           // default 1 (суточный) - идентификатор типа лимита
        public String isCommon { get; set; }              // default 1 (общий) - вид лимита
        public String isRuble { get; set; }               // default 1 (рубль)
        public Integer productId { get; set; }            // default 62 (1000-Вездеход онлайн Ультра) - идентификатор продукта в транзите
        public Integer totalLimitValue { get; set; }      // default 0 - общее значение лимита
        public Integer totalLimitType { get; set; }       // default 1 (суточный) - идентификатор общего лимита
        public Integer cardsNumber { get; set; }          // количество заказываемых карт (от 1 до 10)
        public String cardDescr { get; set; }             // комментарии для курьерской службы
        public String serviceGroups { get; set; }         // группы по  услугам через ';'
//        public Integer virtualCards = 0;                  // маркер виртуальной карты 1 - да, 0 - нет
    }
}