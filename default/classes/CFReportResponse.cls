public class CFReportResponse {
	public String status;
	public String message;
	public CreditCompany company {get; set;}
	public Credit_Factory_Report__c sfReport;
	public List<CreditCompanyEmployee> companyEmployees;
	public Blob reportBody;
	public Decimal recommendedBillingPeriod;
	public Decimal recommendedPaymentTerms;
	public Decimal creditLimitDefault;
	public Decimal securityLevel;
	public Decimal buffer;
	public String riskCategory;
	// payment terms = 7
	public Decimal creditLimit7;
	public Decimal creditLimit15;
	public Decimal creditLimit30;
	public Decimal maxCreditLimit7;
	public Decimal maxCreditLimit15;
	public Decimal maxCreditLimit30;
	public Decimal maxValue7;
	public Decimal maxValue15;
	public Decimal maxValue30;
	public Decimal deposit7;
	public Decimal deposit15;
	public Decimal deposit30;
	// payment terms = 14
	public Decimal creditLimit15_Plus14;
	public Decimal maxCreditLimit15_Plus14;
	public Decimal maxValue15_Plus14;
	public Decimal deposit15_Plus14;
	// payment terms = 27
	public Decimal creditLimit30_Plus27;
	public Decimal maxCreditLimit30_Plus27;
	public Decimal maxValue30_Plus27;
	public Decimal deposit30_Plus27;
	// payment terms = 14
	public Decimal creditLimit30_Plus14;
	public Decimal maxCreditLimit30_Plus14;
	public Decimal maxValue30_Plus14;
	public Decimal deposit30_Plus14;

    public CFReportResponse() {}
}