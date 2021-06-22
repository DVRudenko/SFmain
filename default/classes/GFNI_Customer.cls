/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_Customer {
    public String AccountName {
        get {
            return String.isNotBlank(this.AccountName) ? this.AccountName.toUpperCase() : this.AccountName;
        }
        set;
    }
    public String AccountNumber {
        get {
            return String.isNotBlank(this.AccountNumber) ? this.AccountNumber.toUpperCase() : this.AccountNumber;
        }
        set;
    }
    public String AccountManager { get; set; }
    public String TradeRegistrationNumber {
        get {
            return String.isNotBlank(this.TradeRegistrationNumber) ? this.TradeRegistrationNumber.toUpperCase() : this.TradeRegistrationNumber;
        }
        set;
    }
    public Integer LegalEntityId { get; set; }
    public String RegisteredCountryCode {
        get {
            return String.isNotBlank(this.RegisteredCountryCode) ? this.RegisteredCountryCode.toUpperCase() : this.RegisteredCountryCode;
        }
        set;
    }
    public String VATNumber {
        get {
            return String.isNotBlank(this.VATNumber) ? this.VATNumber.toUpperCase() : this.VATNumber;
        }
        set;
    }
    public String VATNumber2 {
        get {
            return String.isNotBlank(this.VATNumber2) ? this.VATNumber2.toUpperCase() : this.VATNumber2;
        }
        set;
    }
    public Integer PriceProfileId { get; set; }
    public Integer CustomerSegmentationId { get; set; }
    public String Language { get; set; }
    public String BillingLanguage { get; set; }
    public String ShortName {
        get {
            return String.isNotBlank(this.ShortName) ? this.ShortName.toUpperCase() : this.ShortName;
        }
        set;
    }
    public Integer MarketingSegmentationId { get; set; }
    public Decimal EstimatedFuelVolume { get; set; }
    public Integer FeeGroupId { get; set; }
    public String HomeSiteCode {
        get {
            return String.isNotBlank(this.HomeSiteCode) ? this.HomeSiteCode.toUpperCase() : this.HomeSiteCode;
        }
        set;
    }
    public Integer IsEcoFeeRuleApplied { get; set; }
    public Integer AcquisitionChannelId { get; set; }
    public Integer SelfServeUserId { get; set; }
    public Integer LineOfBusinessID { get; set; }
    public String NextReviewDate { get; set; }
    public Integer SecurityTypeId { get; set; }
    public Decimal SecurityAmount { get; set; }
    public List<GFNI_Contact> Contacts { get; set; }
    public List<GFNI_Address> Addresses { get; set; }
    public GFNI_CreditInfo CreditInfo { get; set; }
    public List<GFNI_Card> CardOrder { get; set; }
    public GFNI_PaymentInfo PaymentInfo { get; set; }
    public GFNI_CommunicationPreferences CommunicationPreferences { get; set; }

    public void addContact(GFNI_Contact contact) {
        if (this.Contacts == null)
            this.Contacts = new List<GFNI_Contact>();

        this.Contacts.add(contact);
    }

    public void addAddress(GFNI_Address address) {
        if (this.Addresses == null)
            this.Addresses = new List<GFNI_Address>();

        this.Addresses.add(address);
    }

    public void addCardToCardOrder(GFNI_Card card) {
        if (this.CardOrder == null)
            this.CardOrder = new List<GFNI_Card>();

        this.CardOrder.add(card);
    }
}