/**
 * Created by Anna Rudas on 29.11.2017.
 */

public class AccountGfnReport {

    public String accountNum { get; set; }
    public String accountType { get; set; }
    public String opportunitySecChannel { get; set; }
    public String opportunityLeadSource { get; set; }
    public String accountName { get; set; }
    public String language { get; set; }
    public String opportunityOwner { get; set; }
    public String companyForm { get; set; }
    public String taxId { get; set; }
    public String tradeRegisterNum { get; set; }
    public String vatNum { get; set; }
    public String swiftBic { get; set; }
    public String iban { get; set; }
    public String creditSystemNum { get; set; }
    public String opportunityProduct { get; set; }
    public String offerDuration { get; set; }
    public String esi { get; set; }
    public String numOfVehicles { get; set; }
    public String numOfCards { get; set; }
    public String consumptionInMonth { get; set; }
    public String paymentMethod { get; set; }
    public String directDebitMandateType { get; set; }
    public String umr { get; set; }
    public String creditLimit { get; set; }
    public String creditLimitCurrency { get; set; }
    public String paymentTermsCredit { get; set; }
    public String riskCategory { get; set; }
    public String billingPeriod { get; set; }
    public Integer invoicingPdf { get; set; }
    public Integer isPaperInvoicing { get; set; }
    public String processedBy { get; set; }
    public String creditSystemRating { get; set; }
    public String nextReviewDate { get; set; }
    public String security { get; set; }
    public String securityAmount { get; set; }
    public String registeredCountry { get; set; }
    public String registeredState { get; set; }
    public String registeredCity { get; set; }
    public String registeredZip { get; set; }
    public String registeredStreet { get; set; }
    public String shippingCountry { get; set; }
    public String shippingState { get; set; }
    public String shippingCity { get; set; }
    public String shippingZip { get; set; }
    public String shippingStreet { get; set; }
    public Integer customPin { get; set; }
    public String accountLink { get; set; }
    public String opportunityLink { get; set; }
    public Integer ecoFee { get; set; }
    public Integer vatRecovery { get; set; }
    public List<ContactGfnReport> contacts { get; set; }
    public List<CardGfnReport> cards { get; set; }

    public AccountGfnReport() {
        this.accountNum = '';
        this.accountType = '';
        this.opportunitySecChannel = '';
        this.opportunityLeadSource = '';
        this.accountName = '';
        this.language = '';
        this.opportunityOwner = '';
        this.companyForm = '';
        this.taxId = '';
        this.tradeRegisterNum = '';
        this.vatNum = '';
        this.swiftBic = '';
        this.iban = '';
        this.creditSystemNum = '';
        this.opportunityProduct = '';
        this.offerDuration = '';
        this.esi = '';
        this.numOfVehicles = '';
        this.numOfCards = '';
        this.consumptionInMonth = '';
        this.paymentMethod = '';
        this.directDebitMandateType = '';
        this.umr = '';
        this.creditLimit = '';
        this.creditLimitCurrency = '';
        this.paymentTermsCredit = '';
        this.riskCategory = '';
        this.billingPeriod = '';
        this.invoicingPdf = 0;
        this.isPaperInvoicing = 0;
        this.processedBy = '';
        this.creditSystemRating = '';
        this.nextReviewDate = '';
        this.security = '';
        this.securityAmount = '';
        this.registeredCountry = '';
        this.registeredState = '';
        this.registeredCity = '';
        this.registeredZip = '';
        this.registeredStreet = '';
        this.shippingCountry = '';
        this.shippingState = '';
        this.shippingCity = '';
        this.shippingZip = '';
        this.shippingStreet = '';
        this.customPin = 0;
        this.accountLink = '';
        this.opportunityLink = '';
        this.ecoFee = 0;
        this.vatRecovery = 0;
        this.accountLink = '';
        this.opportunityLink = '';
        this.contacts = new List<ContactGfnReport>();
        this.cards = new List<CardGfnReport>();
    }
}