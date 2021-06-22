global class CreditsafeReportEntity {
	global String orderId;
	global Object chargeRef;
	global String companyId;
	global String dateOfOrder;
	global String language;
	global Report report;
	global String userId;
	global String error;

	global class EmployeesInformation {
		global String numberOfEmployees;
		global Decimal year;
	}

	global class OtherInformation {
		global List<EmployeesInformation> employeesInformation;
	}

	global class LatestShareholdersEquityFigure {
		global Decimal value;
		global String currency_x;
	}

	global class OtherAddresses {
		global String houseNumber;
		global String street;
		global String simpleValue;
		global String country;
		global String postalCode;
		global String city;
	}

	global class MainAddress {
		global String houseNumber;
		global String street;
		global String simpleValue;
		global String telephone;
		global String country;
		global String province;
		global String postalCode;
		global String city;
	}

	global class ContactInformation {
		global List<OtherAddresses> otherAddresses;
		global List<String> emailAddresses;
		global MainAddress mainAddress;
	}

	global class Positions {
		global String positionName;
		global String dateAppointed;
	}

	global class CurrentDirectors {
		global String surname;
		global String dateOfBirth;
		global String directorType;
		global String gender;
		global String firstNames;
		global String name;
		global String id;
		global List<Positions> positions;
	}

	global class PreviousDirectors {
		global String resignationDate;
		global String name;
		global String gender;
		global List<Positions> positions;
	}

	global class Directors {
		global List<CurrentDirectors> currentDirectors;
		global List<PreviousDirectors> previousDirectors;
	}

	global class MainActivity {
		global String classification;
		global String code;
		global String description;
	}

	global class CompanyStatus {
		global String description;
		global String status;
	}

	global class CreditLimit {
		global String value;
	}

	global class ProviderValue {
		global String minValue;
		global String value;
		global String maxValue;
	}

	global class LatestTurnoverFigure {
		global String value;
	}

	global class CreditRating {
		global String commonValue;
		global CreditLimit creditLimit;
		global String providerDescription;
		global String commonDescription;
		global ProviderValue providerValue;
	}

	global class CompanySummary {
		global LatestTurnoverFigure latestTurnoverFigure;
		global String businessName;
		global LatestShareholdersEquityFigure latestShareholdersEquityFigure;
		global MainActivity mainActivity;
		global String companyNumber;
		global String country;
		global CompanyStatus companyStatus;
		global String companyRegistrationNumber;
		global CreditRating creditRating;
	}

	global class PreviousCreditRating {
		global String commonValue;
		global CreditLimit creditLimit;
		global String providerDescription;
		global String commonDescription;
		global ProviderValue providerValue;
	}

	global class CurrentCreditRating {
		global String commonValue;
		global CreditLimit creditLimit;
		global String providerDescription;
		global String commonDescription;
		global ProviderValue providerValue;
	}

	global class CreditScore {
		global PreviousCreditRating previousCreditRating;
		global CurrentCreditRating currentCreditRating;
		global String latestRatingChangeDate;
	}

	global class IssuedShareCapital {
		global Decimal value;
	}

	global class Address {
		global String houseNumber;
		global String street;
		global String simpleValue;
		global String country;
		global String postalCode;
		global String city;
	}

	global class ShareHolders {
		global Decimal percentSharesHeld;
		global Address address;
		global String name;
	}

	global class ShareCapitalStructure {
		global IssuedShareCapital issuedShareCapital;
		global List<ShareHolders> shareHolders;
	}

	global class ContactAddress {
		global String houseNumber;
		global String street;
		global String simpleValue;
		global String telephone;
		global String country;
		global String province;
		global String postalCode;
		global String city;
	}

	global class PrincipalActivity {
		global String classification;
		global String code;
		global String description;
	}

	global class LegalForm {
		global String providerCode;
		global String description;
	}

	global class BasicInformation {
		global ContactAddress contactAddress;
		global String businessName;
		global PrincipalActivity principalActivity;
		global String operationsStartDate;
		global String country;
		global LegalForm legalForm;
		global String companyRegistrationDate;
		global CompanyStatus companyStatus;
		global String companyRegistrationNumber;
		global String registeredCompanyName;
		global String vatRegistrationNumber;
	}

	global class Activities {
		global String code;
		global String description;
	}

	global class ActivityClassifications {
		global String classification;
		global List<Activities> activities;
	}

	global class CompanyIdentification {
		global BasicInformation basicInformation;
		global List<ActivityClassifications> activityClassifications;
	}

	global class Commentaries {
		global String commentaryText;
		global String positiveOrNegative;
	}

	global class Misc {
		global String importer;
		global String exporter;
		global String branchNumber;
		global String kvkStatus;
		global String employeeClass;
		global Decimal numberOfSearchesL12;
		global String employeeNumber;
	}

	global class TradingStyles {
		global String tradingName;
	}

	global class IndustryComparison {
		global Decimal industryAverageCreditLimit;
		global Decimal industryAverageCreditRating;
	}

	global class RatingHistory {
		global String commonValue;
		global String date_x;
		global String commonDescription;
		global ProviderValue providerValue;
	}

	global class PaymentExpectationsSummary {
		global String suspensionOfPaymentsMora;
	}

	global class LimitHistory {
		global String date_x;
		global Decimal companyValue;
	}

	global class CompanyHistory {
		global String description;
		global String date_x;
	}

	global class AdditionalInformation {
		global List<Commentaries> commentaries;
		global Misc misc;
		global List<CompanyHistory> companyHistory;
		global List<TradingStyles> tradingStyles;
		global IndustryComparison industryComparison;
		global List<RatingHistory> ratingHistory;
		global PaymentExpectationsSummary paymentExpectationsSummary;
		global List<LimitHistory> limitHistory;
		global List<LettersOfLiablilityInformation403> lettersOfLiablilityInformation403;
	}

	global class LettersOfLiablilityInformation403 {
		global String companyName;
		global String companyNumber;
		global DateTime dateSubmited;
		global DateTime letterOfLiability1SubmittedDate;
		global DateTime letterOfLiability1StartDate;
		global String financialYear;
	}

	global class Report {
		global OtherInformation otherInformation;
		global ContactInformation contactInformation;
		global Directors directors;
		global CompanySummary companySummary;
		global String language;
		global String companyId;
		global CreditScore creditScore;
		global ShareCapitalStructure shareCapitalStructure;
		global CompanyIdentification companyIdentification;
		global AdditionalInformation additionalInformation;
		global GroupStructure groupStructure;
	}

	global class GroupStructure {
		global UltimateParent ultimateParent;
		global List<AffiliatedCompanies> affiliatedCompanies;
	}

	global class UltimateParent {
		global String name;
		global String safeNumber;
		global String status;
		global String id;
		global String country;
		global String registrationNumber;
		global String type;
	}

	global class AffiliatedCompanies {
		global String name;
		global String safeNumber;
		global String status;
		global String id;
		global String country;
		global String registrationNumber;
		global String type;
	}

	global static CreditsafeReportEntity parse(String jsonStr) {
		return (CreditsafeReportEntity) JSON.deserialize(jsonStr, CreditsafeReportEntity.class);
	}
}