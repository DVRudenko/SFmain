global class AccountDetailsGfn {

    public Data Data { get; private set; }

    public class Data {
        public Integer CustomerID { get; private set; }
        public String FullName { get; private set; }
        public String CustomerERP { get; private set; }
        public String ClientCustomerNumber { get; private set; }
        public String MarketingSegmentation { get; private set; }
        public Integer StatusID { get; private set; }
        public String Status { get; private set; }
        public String Language { get; private set; }
        public String RegistrationNumber { get; private set; }
        public String VATRegistrationNumber { get; private set; }
        public Decimal AverageVolume { get; private set; }
        public String DebtorStatus { get; private set; }
        public Decimal OutstandingDebt { get; private set; }
        public String OutstandDebtCurrency { get; private set; }
        public Integer CreditLimit { get; private set; }
        public String CreditLimitCurrency { get; private set; }
        public String PaymentMethod { get; private set; }
        public String PaymentTerms { get; private set; }
        public Decimal Guarantee { get; private set; }
        public String GuarenteeCurrency { get; private set; }
        public String BillingFrequency { get; private set; }
        public String DefaultDistributionMethod { get; private set; }
        public String DefaultDistributionFormat { get; private set; }
        public String LineOfBusiness { get; private set; }
        public String CustomerClassification { get; private set; }
        public String StartDate { get; private set; }
        public List<RelatedAccount> RelatedAccounts { get; private set; }
        public List<AllowedStatusChanges> AllowedStatusChanges { get; private set; }
        public List<AccountAddress> AccountAddresses { get; private set; }
        public List<AccountContact> AccountContacts { get; private set; }
        public List<AccountServices> AccountServices { get; private set; }
        public List<AccountSelfServeUsers> AccountSelfServeUsers { get; private set; }
        public List<SalesforceCards> SalesforceCards { get; private set; }
        public List<UnbilledProducts> UnbilledProducts { get; private set; }
        public List<UnbilledTransactions> UnbilledTransactions { get; private set; }
        public List<InfoSubscriptions> InfoSubscriptions { get; private set; }
        public List<AccountBillingDocuments> AccountBillingDocuments { get; private set; }
        public List<FeeRules> FeeRules { get; private set; }
        public List<AccountPriceRules> AccountPriceRules { get; private set; }
        public List<HomeSites> HomeSites { get; private set; }
        public String PdfData { get; private set; }
        public String DocumentNumber { get; private set; }
        public Integer InvoiceCustomerID { get; private set; }
        public String InvoiceCustomerERP { get; private set; }
        public String InvoiceCustomerFullName { get; private set; }
        public CustomerLink InvoiceCustomer { get; private set; }
        public Integer PaymentCustomerID { get; private set; }
        public String PaymentCustomerERP { get; private set; }
        public String PaymentCustomerFullName { get; private set; }
        public CustomerLink PaymentCustomer { get; private set; }
        public Integer TopLevelCustomerID { get; private set; }
        public String TopLevelCustomerERP { get; private set; }
        public String TopLevelCustomerFullName { get; private set; }
        public String Exposure { get; private set; }
        public CustomerLink TopLevelCustomer { get; private set; }
        public List<SalesforceSearchByCards> SalesforceSearchByCards { get; private set; }
    }

    public class RelatedAccount {
        public Integer CustomerID { get; private set; }
        public String ClientCustomerNumber { get; private set; }
        public String CustomerERP { get; private set; }
        public String ShortName { get; private set; }
        public String Fullname { get; private set; }
        public Integer StatusID { get; private set; }
        public String Status { get; private set; }
        public Boolean Parent { get; private set; }
        public Boolean Child { get; private set; }
        public String City { get; private set; }
        public CustomerLink CustomerLink { get; private set; }
    }

    public class AllowedStatusChanges {
        public String Status { get; private set; }
        public CustomerLink StatusChange { get; private set; }
    }

    public class AccountAddress {
        public Integer CustomerID { get; private set; }
        public Integer AddressID { get; private set; }
        public String AddressLines { get; private set; }
        public String Region { get; private set; }
        public String ZipCode { get; private set; }
        public String City { get; private set; }
        public String Country { get; private set; }
        public String Telephone { get; private set; }
        public String Fax { get; private set; }
        public List<AddressType> AddressTypes { get; private set; }
    }

    public class AccountContact {
        public Integer CustomerID { get; private set; }
        public Integer ContactID { get; private set; }
        public Boolean IsPrimary { get; private set; }
        public Boolean IsActive { get; private set; }
        public Integer ContactTitleID { get; private set; }
        public String ContactTitle { get; private set; }
        public Integer LanguageID { get; private set; }
        public String LanguageCode { get; private set; }
        public String Language { get; private set; }
        public String SalutationWritten { get; private set; }
        public String SalutationVerbal { get; private set; }
        public String ForeName { get; private set; }
        public String MiddleName { get; private set; }
        public String LastName { get; private set; }
        public String Telephone { get; private set; }
        public String Fax { get; private set; }
        public String MobilePhone { get; private set; }
        public String EmailAddress { get; private set; }
        public Boolean MarketingCampaigns { get; private set; }
        public String Position { get; private set; }
        public List<ContactTypes> ContactTypes { get; private set; }
    }

    public class AccountServices {
        public Integer ServiceID { get; private set; }
        public String ServiceDescription { get; private set; }
        public Integer ServiceTypeID { get; private set; }
        public String ServiceType { get; private set; }
        public Boolean Essential { get; private set; }
        public Boolean QuotaRequired { get; private set; }
        public String MaxQuota { get; private set; }
        public String RegistrationNumber { get; private set; }
        public String StartDate { get; private set; }
        public Boolean Registered { get; private set; }
        public String Quota { get; private set; }
    }

    public class AccountSelfServeUsers {
        public Integer UserID { get; private set; }
        public String LoginName { get; private set; }
        public String Title { get; private set; }
        public String FirstName { get; private set; }
        public String LastName { get; private set; }
        public String TelephoneNumber { get; private set; }
        public String EmailAddress { get; private set; }
        public Integer CultureID { get; private set; }
        public String Culture { get; private set; }
        public String LastLogin { get; private set; }
        public String LastActivity { get; private set; }
        public Integer LoginAttempts { get; private set; }
        public String LockoutTime { get; private set; }
        public String LockExpiry { get; private set; }
        public String CreatedDate { get; private set; }
        public Boolean isLocked { get; private set; }
        public Boolean OptOutOfEMail { get; private set; }
        public String ContactID { get; private set; }
        public Integer UserTypeID { get; private set; }
        public String UserType { get; private set; }
        public Boolean isActive { get; private set; }
        public Integer UITypeID { get; private set; }
        public String UIType { get; private set; }
    }

    public class SalesforceCards {
        public String PurchaseCategory { get; private set; }
        public Integer PurchaseCategoryID { get; private set; }
        public String EffectiveDate { get; private set; }
        public Boolean IsDriverNameEmbossed { get; private set; }
        public String CardGroup { get; private set; }
        public String DriverName { get; private set; }
        public Boolean IsOdometerPromptRequired { get; private set; }
        public Boolean IsRegNumberEmbossed { get; private set; }
        public String RegNumber { get; private set; }
        public String Status { get; private set; }
        public String LastStatusChange { get; private set; }
        public Integer StatusID { get; private set; }
        public Integer IssueNumber { get; private set; }
        public String ExpiryDate { get; private set; }
        public Integer CardTypeID { get; private set; }
        public String PAN { get; private set; }
        public String CardType { get; private set; }
        public String PinEntryType { get; private set; }
        public String PinSelectionMethod { get; private set; }
        public Integer CardID { get; private set; }
    }

    public class UnbilledProducts {
        public Integer Occurances { get; private set; }
        public String Product { get; private set; }
        public Integer ProductID { get; private set; }
    }

    public class UnbilledTransactions {
        public Decimal AmountGross { get; private set; }
        public Decimal AmountNet { get; private set; }
        public Decimal Quantity { get; private set; }
        public Decimal AmountVat { get; private set; }
        public String Product { get; private set; }
        public Integer ProductID { get; private set; }
        public String DriverName { get; private set; }
        public String VRN { get; private set; }
        public String SiteCountry { get; private set; }
        public Integer SiteID { get; private set; }
        public String Card { get; private set; }
        public String SiteLocation { get; private set; }
        public String SalesDateTime { get; private set; }
        public String SiteNumber { get; private set; }
        public String SalesItemID { get; private set; }
    }

    public class InfoSubscriptions {
        public List<InfoSubscriptionDetails> InfoSubscriptionDetails { get; private set; }
        public String FrequencyType { get; private set; }
    }

    public class AccountBillingDocuments {
        public String DocumentType { get; private set; }
        public Integer DocumentTypeID { get; private set; }
        public Decimal AmountAllocated { get; private set; }
        public String DelcoID { get; private set; }
        public Decimal TotalGross { get; private set; }
        public String Delco { get; private set; }
        public String PaymentDueDate { get; private set; }
        public String DelcoClientCompanyNumber { get; private set; }
        public String DocumentDate { get; private set; }
        public String BillingOrSummary { get; private set; }
        public String DocumentNumber { get; private set; }
        public String InvoicePdfLink { get; private set; }
        public Integer DocumentID { get; private set; }
        public String GFNCurrency { get; private set; }
    }

    public class InfoSubscriptionDetails {
        public String DistributionMethod { get; private set; }
        public String OutputType { get; private set; }
        public List<AccountInfoSubscriptionContacts> AccountInfoSubscriptionContacts { get; private set; }
    }

    public class AccountInfoSubscriptionContacts {
        public String EMailAddress { get; private set; }
        public Boolean isPrimary { get; private set; }
    }

    public class FeeRules {
        public Integer CurrencyID { get; private set; }
        public String Product { get; private set; }
        public Integer FeeRuleBasisID { get; private set; }
        public Integer ProductID { get; private set; }
        public String FeeRuleBasis { get; private set; }
        public String FrequencyType { get; private set; }
        public Decimal MinValue { get; private set; }
        public String FrequencyTypeID { get; private set; }
        public Decimal MaxValue { get; private set; }
        public String FeeType { get; private set; }
        public String FeeCurrency { get; private set; }
        public Integer FeeTypeID { get; private set; }
        public List<FeeTiers> FeeTiers { get; private set; }
        public String FeeRuleDescription { get; private set; }
        public Integer FeeRuleID { get; private set; }
        public String DateEffective { get; private set; }
        public String DateTerminated { get; private set; }
    }

    public class FeeTiers {
        public String DateTerminated { get; private set; }
        public Integer TierMax { get; private set; }
        public Decimal Value { get; private set; }
        public Integer TierMin { get; private set; }
        public Decimal BaseValue { get; private set; }
        public String DateEffective { get; private set; }
        public Decimal UpliftValue { get; private set; }
        public Integer FeeRuleTierID { get; private set; }
        public Boolean AllowEditUplift { get; private set; }
        public Integer FeeRuleID { get; private set; }
    }

    public class AccountPriceRules {
        public String PriceListPrice { get; private set; }
        public String PriceCurrency { get; private set; }
        public Integer PriceRuleCategoryID { get; private set; }
        public Integer CurrencyID { get; private set; }
        public String PriceRuleCategory { get; private set; }
        public String PriceRuleBasis { get; private set; }
        public Integer FunderTypeID { get; private set; }
        public Integer PriceRuleBasisID { get; private set; }
        public String FunderType { get; private set; }
        public String ReferencePrice { get; private set; }
        public String PriceListID { get; private set; }
        public Integer ReferencePriceID { get; private set; }
        public List<PriceRuleLocations> PriceRuleLocations { get; private set; }
        public String DateTerminated { get; private set; }
        public List<PriceRuleProducts> PriceRuleProducts { get; private set; }
        public String DateEffective { get; private set; }
        public List<PriceRuleCards> PriceRuleCards { get; private set; }
        public String PriceRuleDescription { get; private set; }
        public List<PriceRuleTiers> PriceRuleTiers { get; private set; }
        public Integer PriceRuleID { get; private set; }
    }

    public class PriceRuleCards{
		public String CardType { get; private set; }
		public Integer CardTypeID { get; private set; }
		public String DateEffective { get; private set; }
		public Integer CardTypeGroupID { get; private set; }
		public String DateTerminated { get; private set; }
		public Integer PriceRuleID { get; private set; }
    }

    public class PriceRuleTiers {
        public Integer TierMaxExclusive { get; private set; }
        public String DateEffective { get; private set; }
        public Integer TierMin { get; private set; }
        public String DateTerminated { get; private set; }
        public Integer PriceRuleTierID { get; private set; }
        public Decimal Value { get; private set; }
        public Integer PriceRuleID { get; private set; }
    }
    public class PriceRuleProducts {
        public String DateTerminated { get; private set; }
        public String ProductGroup { get; private set; }
        public String ProductID { get; private set; }
        public Integer ProductGroupID { get; private set; }
        public String Product { get; private set; }
        public Integer PriceRuleID { get; private set; }
        public String DateEffective { get; private set; }
        public Integer PriceRuleProductID { get; private set; }
    }
    public class PriceRuleLocations {
        public String DateTerminated { get; private set; }
        public String FuelNetworkFullName { get; private set; }
        public String FuelNetworkShortName { get; private set; }
        public String FuelNetworkID { get; private set; }
        public String SiteGroupID { get; private set; }
        public String CompanyName { get; private set; }
        public String SiteGroupName { get; private set; }
        public Integer DelcoID { get; private set; }
        public String SiteID { get; private set; }
        public Integer PriceRuleID { get; private set; }
        public String SiteFullName { get; private set; }
        public Integer PriceRuleLocationID { get; private set; }
        public String SiteShortName { get; private set; }
        public String DateEffective { get; private set; }
    }

    public class HomeSites {
        public Decimal Longitude { get; private set; }
        public Decimal Latitude { get; private set; }
        public String AddressLines { get; private set; }
        public String ShortName { get; private set; }
        public String City { get; private set; }
        public String FullName { get; private set; }
        public Integer RegionID { get; private set; }
        public String SiteCode { get; private set; }
        public String Region { get; private set; }
        public String DateTerminated { get; private set; }
        public Integer CountryID { get; private set; }
        public String DateEffective { get; private set; }
        public String ZipCode { get; private set; }
        public Integer SiteID { get; private set; }
        public Integer CustomerHomeSiteID { get; private set; }
    }

    public class AddressType {
        public Integer AddressTypeID { get; private set; }
        public String AddressType { get; private set; }
    }

    public class ContactTypes {
        public Integer ContactID { get; private set; }
        public Integer ContactTypeID { get; private set; }
        public String ContactType { get; private set; }
    }

    public class CustomerLink {
        public String Description { get; private set; }
        public String Method { get; private set; }
        public String Link { get; private set; }
    }

    public class SalesforceSearchByCards {
        public String CustomerERP { get; private set; }
        public String ColCoID { get; private set; }        
    }
}