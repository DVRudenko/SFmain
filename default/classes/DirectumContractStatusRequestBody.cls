public class DirectumContractStatusRequestBody {
    public class Metadata {
        public String transactionId;        //Идентификатор транзакции (поставляется системой источником)
        public String user;                 //Пользователь, выполняющий операцию (домен/логин)
        public Long tsCreated;              //Timestamp инициализации события в системе источнике с точностью до миллисекунд
        public Long tsSent;                 //Timestamp отправки события из системы источника с точностью до миллисекунд
        public String source;               //Система источник формируемого события
        public String channel;              //Должно иметь значение “api”
    }

    public class Data {
        public String contractStage;        //Статус договора
        public String contractDate;         //Дата договора в директуме в формате yyyy-MM-dd
        public String externalId;           //Идентификатор рабочей сущности в системе получателе
        public String contractId;           //Идентификатор рабочей сущности в  системе Directum (проекта договора/договора)
        public String contractNumber;       //Регистрационный номер договора в директуме
        public String contractLink;         //Гиперссылка по которой пользователь может перейти на проект договора/договор в веб-клиенте директума
        public String message;              //Доп информация
    }

    public Metadata metadata;
    public Data data;

    public static DirectumContractStatusRequestBody parse(String jsonStr) {
        return (DirectumContractStatusRequestBody) JSON.deserialize(jsonStr, DirectumContractStatusRequestBody.class);
    }
}