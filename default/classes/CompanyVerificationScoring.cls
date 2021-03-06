global class CompanyVerificationScoring {

    public Integer decision;                // тип решения:
                                                // 0 – проверка пройдена
                                                // 1 - необходимо согласование с ОУР
                                                // 2 - ограничение по отсрочке
                                                // 3 - отказ от сотрудничества
                                                // 4 - необходимо согласование перекупщика
    public Integer limitation;              // максимальный срок отсрочки платежа, если ответ на проверку «ограничение по отсрочке»
    public List<Integer> blackListType;     // список типов клиента, если были совпадения при проверке по ЧЧС:
                                                // 1 – Должник
                                                // 2 - Аффилированное/связанное лицо с Должником
                                                // 3 – Мошенник
                                                // 4 - Аффилированное/связанное лицо с мошенником
                                                // 5 - Должник конкурента
                                                // 6 - Синий список 1
                                                // 7 - Синий список 2
                                                // 8 - Синий список 3
                                                // 9 - Синий список 4
                                                // 10 - Перекупщик (список Сазонова Е.)
    public String sfRequestId;              // id opportunity из SalesForce
}