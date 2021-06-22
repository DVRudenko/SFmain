public class CreditFactoryCompany {
    @AuraEnabled public String name;
    @AuraEnabled public String street;
    @AuraEnabled public String houseNumber;
    @AuraEnabled public String city;
    @AuraEnabled public String postCode;
    @AuraEnabled public String address;
    @AuraEnabled public String email;
    @AuraEnabled public String opportunityId;
    @AuraEnabled public String identificationNumber;
    @AuraEnabled public String creditSystemCompanyNumber;
    @AuraEnabled public String tradeName;
    @AuraEnabled public String status;
    @AuraEnabled public String country;
    @AuraEnabled public String countryCode;
    @AuraEnabled public String taxId;
    @AuraEnabled public String vatNumber;
    @AuraEnabled public String tradeRegisterNumber;
    @AuraEnabled public String iban;
    @AuraEnabled public String paymentMethod;
    @AuraEnabled public Boolean directDebitFormAvailable;
    @AuraEnabled public Boolean sepaRequestApproved;
    @AuraEnabled public String processedBy;
    @AuraEnabled public String stage;
    @AuraEnabled public String cfStage;
    @AuraEnabled public String desiredBillingPeriod;
    @AuraEnabled public String desiredPaymentTerms;
    @AuraEnabled public String recordType;
    @AuraEnabled public String type;
    @AuraEnabled public String numberOfEmployees;
    @AuraEnabled public Decimal totalConsumption;
    @AuraEnabled public Decimal nonFuelExposure;
    @AuraEnabled public Decimal monthlyVolume;
    @AuraEnabled public String product;
    @AuraEnabled public String numberOfCards;
    @AuraEnabled public String paymentTerms;
    @AuraEnabled public String creditSystemNumber;
    @AuraEnabled public String opportunityName;
    @AuraEnabled public String accountId;
    @AuraEnabled public String classRating;
    @AuraEnabled public String solvencyIndex;
    @AuraEnabled public String development;
    @AuraEnabled public String turnOver;
    @AuraEnabled public String legalForm;
    @AuraEnabled public String vatId;
    @AuraEnabled public String registerNumber;
    @AuraEnabled public String countyCourt;
    @AuraEnabled public String paymentBehaviour;
    @AuraEnabled public String staffCompanyRange;
    @AuraEnabled public String creditLimit;
    @AuraEnabled public String creditLimitCurrency;
    @AuraEnabled public String creditDecision;
    @AuraEnabled public String firstLegalForm;
    @AuraEnabled public String ageOfCompany;
    @AuraEnabled public String phone;
    @AuraEnabled public String fax;
    @AuraEnabled public String mobile;
    @AuraEnabled public String website;
    @AuraEnabled public String dateOfFoundation;
    @AuraEnabled public Decimal probability;
    @AuraEnabled public String emailExists;
	@AuraEnabled public String domainExists;
	@AuraEnabled public String emailDate;
	@AuraEnabled public String domainDate;
	@AuraEnabled public String emailStatus;
	@AuraEnabled public String emailRisk;
	@AuraEnabled public String riskDescription;
	@AuraEnabled public String riskAdvice;
	@AuraEnabled public String fraudWithinIndustry;
	@AuraEnabled public String fraudType;
	@AuraEnabled public String totalHits;
	@AuraEnabled public String uniqueHits;
	@AuraEnabled public String nameMatch;
	@AuraEnabled public String checkedEmail;
    @AuraEnabled public String shippingStreet;
    @AuraEnabled public String shippingCity;
    @AuraEnabled public String shippingPostCode;
    @AuraEnabled public String registeredStreet;
    @AuraEnabled public String registeredHouseNumber;
    @AuraEnabled public String registeredCity;
    @AuraEnabled public String registeredPostCode;
    @AuraEnabled public String postalStreet;
    @AuraEnabled public String postalHouseNumber;
    @AuraEnabled public String postalPostCode;
    @AuraEnabled public String postalCity;
    @AuraEnabled public String requestStatus;
    @AuraEnabled public Boolean obligationOverdue;
    @AuraEnabled public Boolean paymentHistoryRequested;
    @AuraEnabled public String numberOfHits;
    @AuraEnabled public List<String> policyRuleHitsList;
    @AuraEnabled public String nameChangeDecision;
    @AuraEnabled public String addressChangeDecision;
    @AuraEnabled public String identificationType;
    @AuraEnabled public String profitLossLastYear;
    @AuraEnabled public String profitLossYearBeforeLast;
    @AuraEnabled public String turnOverLastYear;
    @AuraEnabled public String pitCurrency;
    @AuraEnabled public Decimal creditorsCount;
	@AuraEnabled public Decimal economicInformationsCount;
	@AuraEnabled public Decimal liabilitiesCount;
	@AuraEnabled public Decimal totalAmount;
	@AuraEnabled public Decimal totalOverdueAmount;
	@AuraEnabled public Boolean bigRequested;
    @AuraEnabled public Boolean eInvoice;
    @AuraEnabled public Boolean paperInvoice;
    @AuraEnabled public String contactRoleConfirmationCall;
    @AuraEnabled public String visitorId;
    @AuraEnabled public Boolean customPin;
    @AuraEnabled public String principalActivityCode;
    @AuraEnabled public String principalActivityDescription;
    @AuraEnabled public String cfErrors;
    @AuraEnabled public String lastCfErrors;
    @AuraEnabled public String docuSignStatus;
    @AuraEnabled public String id;
    @AuraEnabled public String ownerName;
    @AuraEnabled public String cfOrders;
    @AuraEnabled public String directDebitMandateType;
    @AuraEnabled public String referenceNumber;
    @AuraEnabled public String swiftBic;
    @AuraEnabled public String requestedSwiftBic;
    @AuraEnabled public String dateLastRegisterEntry;
    @AuraEnabled public String providerDescription;
    @AuraEnabled public String dateOfLastChangeOfDirector;
    @AuraEnabled public String dateOfLastChangeOfAddress;
    @AuraEnabled public String dateOfLastChangeOfName;
    @AuraEnabled public String parentCompanyId;
    @AuraEnabled public String indicationMainEstablishment;
    @AuraEnabled public String rsinNumber;
    @AuraEnabled public String indicationOrganisation;
    @AuraEnabled public String primarySbiCode;
    @AuraEnabled public String primarySbiCodeText;
    @AuraEnabled public String indicationEconomicallyActive;
    @AuraEnabled public String indicationNonMailing;
    @AuraEnabled public String indicationBankruptcy;
    @AuraEnabled public String indicationDip;
    @AuraEnabled public String authorizedShareCapital;
    @AuraEnabled public String authorizedShareCapitalCurrency;
    @AuraEnabled public String paidUpShareCapital;
    @AuraEnabled public String paidUpShareCapitalCurrency;
    @AuraEnabled public String issuedShareCapital;
    @AuraEnabled public String issuedShareCapitalCurrency;
    @AuraEnabled public String continuationDate;
    @AuraEnabled public String establishmentDate;
    @AuraEnabled public Decimal numberOfExecutions;
    @AuraEnabled public String negativeInformation;
    @AuraEnabled public Boolean financialEvaluation;
    @AuraEnabled public String documentTicket;
    @AuraEnabled public String nationalId;
    @AuraEnabled public String dateLegalForm;
    @AuraEnabled public String dateOfLastMajorUpdate;
    @AuraEnabled public String yearOfFoundation;
    @AuraEnabled public String industry;
    @AuraEnabled public Boolean isNewBusinessException;
    @AuraEnabled public Decimal numberOfGpsUnits;
    @AuraEnabled public String yearOfLastFinancialInformation;
    @AuraEnabled public String financialSituation;
    @AuraEnabled public String dateOfLastRequest;
    @AuraEnabled public String secChannel;

    public List<CreditFactoryContact> creditFactoryContacts;
    
    public class CreditFactoryContact {
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String phone;
        @AuraEnabled public String mobilePhone;
        @AuraEnabled public String email;
        @AuraEnabled public String id;
        @AuraEnabled public String sfId;
        @AuraEnabled public Boolean isPrimary;
        @AuraEnabled public String relation;
        @AuraEnabled public String address;
        @AuraEnabled public String dateOfBirth;
        @AuraEnabled public String name;
        @AuraEnabled public String participationDate;
        @AuraEnabled public String type;
        @AuraEnabled public String role;
        @AuraEnabled public String recordType;
        @AuraEnabled public String companyId;
        @AuraEnabled public String companyType;
        @AuraEnabled public String companyRole;
        @AuraEnabled public Boolean reported;
    }
    
    public List<DocumentStatus> documentsStatusesList;
    
    public class DocumentStatus {
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime completedDate;
        @AuraEnabled public List<DocumentRecipient> documentRecipients;
    }
    
    public class DocumentRecipient {
        @AuraEnabled public String name;
    }
    
    public List<Card> cards;
    
    public class Card {}
    
    public List<LineItem> lineItems;
    
    public class LineItem {
        @AuraEnabled public String productFamily;
        @AuraEnabled public String id;
    }
    
    public List<OfferItem> offerItems;
    
    public class OfferItem {
        @AuraEnabled public String productId;
        @AuraEnabled public Decimal monthlyCardLimit;
    }

    public List<CreditFactoryAttachment> attachments;

    public class CreditFactoryAttachment {
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String body;
    }

    public List<CreditFactoryFile> files;

    public class CreditFactoryFile {
        @AuraEnabled public String title;
        @AuraEnabled public String versionData;
    }

    public List<CreditFactoryCalculation> calculations;

    public class CreditFactoryCalculation {
        @AuraEnabled public String country;
        @AuraEnabled public String classRating;
        @AuraEnabled public String dateOfFoundationMonths;
        @AuraEnabled public String dateOfFoundationMonthsOperator;
        @AuraEnabled public String numberOfCards;
        @AuraEnabled public String numberOfCardsOperator;
        @AuraEnabled public String totalConsumptionMaxValue;
        @AuraEnabled public String totalConsumptionMinValue;
        @AuraEnabled public String securityLevel;
        @AuraEnabled public Decimal order;
        @AuraEnabled public String paymentDetail;
        @AuraEnabled public Boolean newBusinessException;
        @AuraEnabled public String depositReason;
        @AuraEnabled public Boolean highRisk;
    }
}