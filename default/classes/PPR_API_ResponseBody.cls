public class PPR_API_ResponseBody {

    public class Metadata {
        public String id;                   //business entity id (E2eFormData__c for now)
        public String user;                 //external username (request maker)
    }

    public class CustomerInfo {
        public String inn;                  //organization id
        public String customerStatus;       //status of a client
        public String customerStatusId;     //PPR_API_Mapping
        public String checkDate;            //deduplication date
        public String ogrn;                 //ogrn
        public String contractNum;          //contract number if any
        public String contractDate;         //date contract was generated if any
        public String invoicePaymentDate;   //date client was moved to start if any
    }

    public Metadata metadata;
    public CustomerInfo customerInfo;
    public String message;                  //errors if any

}