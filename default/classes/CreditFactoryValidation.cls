public interface CreditFactoryValidation {
    void setInternalCFCompany(Map<String, Object> creditFactoryDataMap);
    CreditFactoryCompany getInternalCFCompany();
    void setExternalCreditFactoryCompanies(List<CreditFactoryCompany> externalCFCompaniesList);
	Map<String, CreditFactoryValidationItem> validate(List<String> validationsNamesList, Boolean validateAll);
}