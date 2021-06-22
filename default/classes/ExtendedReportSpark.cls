public class ExtendedReportSpark {

    public class Address {
        public String postCode { get; set; }
        public String address { get; set; }
        public String region { get; set; }
        public String rayon { get; set; }
        public String city { get; set; }
        public String streetName { get; set; }
        public String buildingNumber { get; set; }
        public String fiasGUID { get; set; }
        public String fiasCode { get; set; }
        public String fiasRegion { get; set; }
        public String fiasArea { get; set; }
        public String fiasCity { get; set; }
        public String fiasPlace { get; set; }
        public String fiasPlan { get; set; }
        public String fiasStreet { get; set; }
        public String actualDate { get; set; }
        public String housing { get; set; }
        public String block { get; set; }
        public String room { get; set; }
        public String businessCenterName { get; set; }
    }

    public class Oktmo {
        public String code { get; set; }
    }

    public class Okved {
        public String code { get; set; }
        public String name { get; set; }
        public Boolean isMain { get; set; }
    }

    public class OkvedList {
        List<Okved> okved;
    }

    public Integer sparkID { get; set; }
    public Integer companyType { get; set; }
    public Status status { get; set; }
    public String isActing { get; set; }
    public String dateFirstReg { get; set; }
    public String shortNameRus { get; set; }
    public String shortNameEn { get; set; }
    public String fullNameRus { get; set; }
    public String normName { get; set; }
    public String guid { get; set; }
    public String inn { get; set; }
    public String kpp { get; set; }
    public String ogrn { get; set; }
    public String okpo { get; set; }
    public String bik { get; set; }
    public Okato okato { get; set; }
    public Oktmo oktmo { get; set; }
    public Okogu okogu { get; set; }
    public Okogu okfs { get; set; }
    public Okopf okopf { get; set; }
    public Okved mainOkved { get; set; }
    public Leader actualLeader { get; set; }
    public OkvedList okved2List { get; set; }
    public String charterCapital { get; set; }
    public LeaderList leaderList { get; set; }
    public LegalAddresses legalAddresses { get; set; }
    public String email { get; set; }
    public String www { get; set; }
    public String workersRange { get; set; }
    public String egrpoincluded { get; set; }
    public String fcsmcode { get; set; }
    public ConsolidatedIndicator consolidatedIndicator;
    public BankruptcyMessage bankruptcyMessage;

    public class Status {
        public String dateD { get; set; }
        public String type_Z { get; set; }
        public Integer code { get; set; }
    }

    public class Okopf {
        public String code { get; set; }
        public String name { get; set; }
        public String codeNew { get; set; }
    }

    public class Okogu {
        public String code { get; set; }
        public String name { get; set; }

    }

    public class Okato {
        public String code { get; set; }
        public String regionName { get; set; }
        public Integer regionCode { get; set; }

    }

    public class LegalAddresses {
        public Address address { get; set; }
    }

    public class LeaderList {
        public List<Leader> leader { get; set; }
    }

    public class Leader {
        public String actualDate { get; set; }
        public String fio { get; set; }
        public String position { get; set; }
        public String inn { get; set; }
        //public Object legalCapacityEndDate {get;set;}
        //public Object managementCompany {get;set;}
        //public Object managementCompanyINN {get;set;}
        //public List<Disqualification> disqualification {get;set;}
    }

    public class ListName {
        public List<String> content { get; set; }
        public Integer id { get; set; }
        public Boolean isNegative { get; set; }
    }

    public class ConsolidatedIndicator {
        public String value;
    }

    public class Message {
        public String date_x;       // format 2011-11-11T21:00:00.000+0000
        public String decisionDate; // format 2011-11-11T21:00:00.000+0000
        public Integer idType;
        public String type;
        public String caseId;
        public String caseNumber;
    }

    public class BankruptcyMessage {
        public List<Message> messages;
    }

    /*****************************************************************************
    *  Name            : getMainOkved()
    *  Summary         : returns OKVED of organization in SPARK,  which is marked as main
    *  CreatedDate     : 06/12/2019
    *  Parameters      : -
    *  Returns         : Okved - object with data about main OKVED from spark
    ******************************************************************************/
    public Okved getMainOkved() {
        if (okved2List == null) {
            //if no OKVED data in SPARK, return empty object
            return new Okved();
        } else {
            if (okved2List.okved.isEmpty()) {
                //if no OKVED data in SPARK, return empty object
                return new Okved();
            } else {
                //if data exist
                for (Okved okved : okved2List.okved) {
                    if (okved.isMain != null && okved.isMain == true) {
                        //return main OKVED
                        return okved;
                    }
                }
                //if no main OKVED found, return first OKVED from JSON
                return okved2List.okved.get(0);
            }
        }
    }
}