public with sharing class DirectumContractRequestBody {

    @AuraEnabled public String DocumentKind {public set;}             //справочник Виды документов
    @AuraEnabled public String BusinessUnit {public set;}             //справочник Наши организации
    @AuraEnabled public String Subject {public set;}                  //предмет договора
    @AuraEnabled public String Note {public set;}                     //примечания к договору
    @AuraEnabled public String OurSignatory {public set;}             //справочник Сотрудники
    @AuraEnabled public String DocumentGroup {public set;}            //справочник Категории договоров
    @AuraEnabled public Double TotalAmount {public set;}
    @AuraEnabled public String pCurrency {public set;}                //справочникВалюты
    @AuraEnabled public String ValidFrom {public set;}
    @AuraEnabled public String ValidTill {public set;}
    @AuraEnabled public String ResponsibleEmployee {public set;}      //справочник Сотрудники
    @AuraEnabled public Boolean IsStandard {public set;}              //типовой договор
    @AuraEnabled public Integer CardCountBK {public set;}             //количество бизнес карт
    @AuraEnabled public Integer CardCountTK {public set;}             //количество топливных карт
    @AuraEnabled public String CodeWord {public set;}                 //кодовое слово для ЛК
    @AuraEnabled public String CreditConditions {public set;}         //справочникУсловия кредита
    @AuraEnabled public Integer CountOfVehicle {public set;}          //количество транспорта
    @AuraEnabled public Integer ForecastLiters {public set;}          //прогнозные литры
    @AuraEnabled public String Login {public set;}                    //логин для ЛК
    @AuraEnabled public String ManagerKO {public set;}                //менеджер КО
    @AuraEnabled public String Rate {public set;}                     //справочникТарифы
    @AuraEnabled public String Promotion {public set;}                //справочник Акции
    @AuraEnabled public Double Credit {public set;}
    @AuraEnabled public String PhoneNumber {public set;}
    @AuraEnabled public String Email {public set;}
    @AuraEnabled public String RequestID {public set;}                //ID заявки
    @AuraEnabled public String MarketingInfo {public set;}            //маркетинговая инфа
    @AuraEnabled public String TypeSearchChannel {public set;}        //канал поиска
    @AuraEnabled public Double Summ {public set;}
    @AuraEnabled public String LKGK {public set;}
    @AuraEnabled public String Services {public set;}                 //справочникУслуги
    @AuraEnabled public String Contact {public set;}                  //данные контактного лица
    @AuraEnabled public String CounterpartySignatory {public set;}    //данные лица принимающего решения
    @AuraEnabled public String Bank {public set;}                     //данные банка
    @AuraEnabled public String CounterpartyBank {public set;}         //данные банка контрагента
    @AuraEnabled public String Counterparty {public set;}             //данные контрагента

}