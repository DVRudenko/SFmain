public without sharing class PPR_API_CreateClientRequest {
    public MetadataObj metadata;
    public CustomerInfoObj customerInfo;

    public without sharing class MetadataObj {
        public String source;
        public String id;
        public String user;
    }

    public without sharing class CustomerInfoObj {
        public LegalInfoObj legalInfo;
        public AdditionalInfoObj additionalInfo;
        public OrderInfoObj orderInfo;
        public BankInfoObj bankInfo;
        public List<AddressObj> addresses;
        public List<StaffObj> staff;
    }

    public without sharing class LegalInfoObj {
        public String inn;
        public String codeWord;
        public List<EmailObj> emails;
        public List<PhoneObj> phones;
        public List<String> agreements;
    }
    public without sharing class AdditionalInfoObj {
        public String courierServiceComments;
    }
    public without sharing class OrderInfoObj {
        public String product;
        public String tariff;
        public String orderType;
        public String overdraftSum;
        public List<String> services;
        public List<String> promos;
        public List<String> cards;
    }
    public without sharing class BankInfoObj {
        public String bik;
        public String accountNum;
    }
    public without sharing class EmailObj extends Obj {
        public String value;
    }

    public without sharing class PhoneObj extends Obj {
        public ValueObj value;
    }

    public without sharing class ValueObj {
        public String code;
        public String numberStr;
        public String ext;
    }

    public without sharing class AddressObj extends Obj {
        public String countryCode;
        public String addressId;
        public String zipCode;
        public String country;
        public String state;
        public String city;
        public String street;
        public String house;
        public String apartment;
    }

    public without sharing class StaffObj {
        public String firstName;
        public String lastName;
        public String Surname;
        public String email;
        public String role;
        public String position;
        public List<PhoneObj> phones;
    }

    public abstract class Obj {
        public List<String> type;
    }
    
}