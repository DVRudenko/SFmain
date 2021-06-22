public class ETEUserModel {
    public String ipAddress;
    public String deviceType;

    public String source;
    public String utmProducts;
    public String implKey;
    public String name;
    public String stageName;
    public String eteStatus;
    public String eteFinishedDetails;
    public String currentLang;
    public String currentStep;
    public String countryCode;
    public List<ETE_Contact> contacts;
    public String salutation;
    public String firstName;
    public String lastName;
    public String phone;
    public String email;
    public String birthdate;
    public String companyForm;
    public String postalCode;
    public String country;
    public String city;
    public String street;
    public String riskCategory;
    public String creditSystemRating;
    public String directDebitMandateType;
    public List<String> availableSteps;
    public List<NavigationMenuStep> navigationMenuSteps;
    public String selectedCompanyName;
    public String companyShortName;
    public String selectedCompanyId;
    public String taxId;
    public String vatId;
    public String tradeRegisterNumber;
    public Boolean agreementToPhoneContact;
    public Boolean agreementToReceiveInfoByEmail;
    public Boolean agreementPrivacyPolicy;
    public Boolean agreeToProcessPersDataForMarketing;
    public Boolean termsAndConditionsAgreement;
    public Boolean authorizedSignatoryConfirmed;
    public Boolean acceptSepa;
    public String accountHolder;
    public String iban;
    public String swift;
    public String bankAccountPrefix;
    public String bankAccountNumber;
    public String bankCode;
    public String bankName;
    public List<Product> products;
    public List<Additional_Service> additionalServices;
    public Decimal securityAmountToPay;
    public String depositReason;
    public Boolean depositAgreement;
    public String paymentMethod;
    public Decimal securityLevel;
    public Decimal creditLimit;
    public Decimal maxCreditLimit;
    public String classRating;
    public String billingPeriod;
    public String paymentTerms;
    public Boolean eInvoice;
    public Boolean paperInvoice;
    public String esi;
    public String homeStation;
    public String pm;
    public String brand;
    public String googleClientId;


    public class NavigationMenuStep {
        public String name;
        public Boolean order_data;
    }


    public class ETE_Contact {
        public String source;
        public Integer index;
        public String name;
        public String salutation;
        public String firstName;
        public String lastName;
        public String phone;
        public String email;
        public String birthdate;
        public String role;
        public Boolean isPrimary;
    }


    public class Product {
        public String source;
        public String name;
        public String productId;
        public String typeName;
        public String typeId;
        public List<Offer_Item> offerItems;
        public List<Filling_Station> stations;
        public List<Filling_Stations_Network> stationsNetworks;
    }


    public class Filling_Station {
        public String source;
        public String name;
        public String esi;
    }


    public class Filling_Stations_Network {
        public String source;
        public String name;
    }


    public class Offer_Item {
        public String source;
        public String typeOfVehicle;
        public String typeOfCard;
        public Boolean mileageData;
        public Boolean lockedPinChange;
        public Boolean evCharging;
        public String licensePlateNumber;
        public String driverName;
        public String companyName;
        public String categoryOfProducts;
        public String fleetcorOfferItem;
        public String offerName;
        public String offerItemTypeName;
        public String offerItemType;
        public Decimal dailyLimit;
        public Decimal monthlyFuelConsumption;
        public Decimal monthlyCardLimit;
    }


    public class Additional_Service {
        public String source;
        public String id;
        public Boolean selected;
    }
}