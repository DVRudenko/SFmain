public class CreditCompany {
	public String identificationnumber {get; set;}
	public String name {get; set;}
	public String tradename {get; set;}
	public String street {get; set;}
	public String housenumber {get; set;}
	public String postcode {get; set;}
	public String city {get; set;}
	public String country {get; set;}
	public String address {get; set;}
	public String referencenumber {get; set;}
	public String classRating {get; set;}
	public String creditLimit {get; set;}
	public Decimal maxCreditLimit7 {get; set;}
	public Decimal maxCreditLimit15 {get; set;}
	public Decimal maxCreditLimit30 {get; set;}
	public Decimal maxCreditValue7 {get; set;}
	public Decimal maxCreditValue15 {get; set;}
	public Decimal maxCreditValue30 {get; set;}
	public String creditLimitCurrency {get; set;}
	public String dateoffoundation {get; set;}
	public String phone {get; set;}
	public String fax {get; set;}
	public String status {get; set;}
	public String legalform {get; set;}
	public String staffcompanyrange {get; set;}
	public String countyCourt {get; set;}
	public String datelegalform {get; set;}
	public String datelastregisterentry {get; set;}
	public String ageofcompany {get; set;}
	public String firstlegalform {get; set;}
	public String email {get; set;}
	public String website {get; set;}
	public String mobile {get; set;}
	public String vatid {get; set;}
	public String taxnumber {get; set;}
	public String tradeRegisterNumber {get; set;}
	public String registerNumber {get; set;}
	public String creditDecision {get; set;}
	public String creditVerdict {get; set;}
	public String creditStatusCode {get; set;}
	public String paymentBehaviour {get; set;}
	public String development {get; set;}
	public String turnOver {get; set;}
	public String creditSystemCompanyNumber {get; set;}
	public String orderSituation {get; set;}
	public String solvencyIndex {get; set;}
	public String requestStatus {get; set;}
	public Boolean obligationOverdue {get; set;}
	public Boolean isReportExists {get; set;}
	public String dateOfLastMajorUpdate {get; set;}
	public String indicationMainEstablishment {get; set;}
	public String rsinNumber {get; set;}
	public String indicationOrganisation {get; set;}
	public String primarySbiCode {get; set;}
	public String primarySbiCodeText {get; set;}
	public String indicationEconomicallyActive {get; set;}
	public String indicationNonMailing {get; set;}
	public String indicationBankruptcy {get; set;}
	public String indicationDip {get; set;}
	public String authorizedShareCapital {get; set;}
	public String authorizedShareCapitalCurrency {get; set;}
	public String paidUpShareCapital {get; set;}
	public String paidUpShareCapitalCurrency {get; set;}
	public String issuedShareCapital {get; set;}
	public String issuedShareCapitalCurrency {get; set;}
	public String continuationDate {get; set;}
	public String establishmentDate {get; set;}
	public String creditSystem {get; set;}
	public String numberOfHits {get; set;}
	public List<String> policyRulesHits {get; set;}
	public String nameChangeDecision {get; set;}
	public String addressChangeDecision {get; set;}
	public String identificationType {get; set;}
	public String productType {get; set;}
	public String profitLossLastYear {get; set;}
	public String profitLossYearBeforeLast {get; set;}
	public String turnOverLastYear {get; set;}
	public String pitCurrency {get; set;}
	public String dateOfLastChangeOfDirector {get; set;}
	public String dateOfLastChangeOfAddress {get; set;}
	public String dateOfLastChangeOfName {get; set;}
	public String principalActivityCode {get; set;}
	public String principalActivityDescription {get; set;}
	public Decimal numberOfRatios {get; set;}
	public Decimal overallScore {get; set;}
	public Decimal netWorth {get; set;}
	public Decimal totalAssets {get; set;}
	public Decimal totalLiabilities {get; set;}
	public String exceptionCode {get; set;}
	public Boolean isWaitingReport {get; set;}
	public String nationalId {get; set;}

	// LexisNexis fields
	public String emailExists {get; set;}
	public String domainExists {get; set;}
	public String emailDate {get; set;}
	public String domainDate {get; set;}
	public String emailStatus {get; set;}
	public String emailRisk {get; set;}
	public String riskDescription {get; set;}
	public String riskAdvice {get; set;}
	public String fraudWithinIndustry {get; set;}
	public String fraudType {get; set;}
	public String totalHits {get; set;}
	public String uniqueHits {get; set;}
	public String nameMatch {get; set;}
	public String checkedEmail {get; set;}

	// order
	public String orderReferenceNumber {get; set;}
	public String orderPartyId {get; set;}

	// calculations
	public Decimal creditLimitWeeklyPlus7 {get; set;}
	public Decimal creditLimitBiWeeklyPlus7 {get; set;}
	public Decimal creditLimitBiWeeklyPlus14 {get; set;}
	public Decimal creditLimitMonthlyPlus7 {get; set;}
	public Decimal creditLimitMonthlyPlus27 {get; set;}
	public Decimal depositWeeklyPlus7 {get; set;}
	public Decimal depositBiWeeklyPlus7 {get; set;}
	public Decimal depositBiWeeklyPlus14 {get; set;}
	public Decimal depositMonthlyPlus7 {get; set;}
	public Decimal depositMonthlyPlus27 {get; set;}
	public String errors {get; set;}
	public Decimal securityLevel {get; set;}
	public String additionalDateoffoundation {get; set;}
	public Decimal numberOfCards {get; set;}

	public String parentCompanyId {get; set;}
	public String providerDescription {get; set;}
}