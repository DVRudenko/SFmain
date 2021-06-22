public with sharing class OpportunityScoring {

    public Id opportunityId;
    public Id accountId;
    public Boolean sourceOfLead = false;                          // Канал привлечения - inbound, E2E, партнеры
    public Boolean newLegal = false;                              // Новое ЮЛ (в пределах 12 месяцев с момента создания)
    public Boolean newFounder = false;                            // Смена учредителя за последние 6 месяцев
    public Boolean massRegistrationAddress = false;               // Адрес массовой регистрации
    public Boolean differentPostAddress = false;                  // Запрос отправки договора и карт на адрес, отличный от юридического
    public Boolean firstBill = false;                             // Запрос первого счета на сумму более 500 т.р.
    public Boolean notificationSent = false;                      // признак, что тотал был достигнут, и письмо было отправлено из SF
    public Integer totalPoints = 0;                               // сумма баллов

}