public interface CreditFactorySettings {
    List<Object> returnSearchColumns();
    List<Object> returnReportSectionsData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany);
    Map<String, Object> returnAddressUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany);
    Map<String, Object> returnNameUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany);
    Map<String, Object> returnTaxIdUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany);
    Map<String, Object> returnTradeRegisterNumberUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany);
    Map<String, Object> returnVatNumberUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany);
    Map<String, Object> returnSwiftBicUpdateData(CreditFactoryCompany internalCompany);
    List<String> returnSearchValidations();
    Set<String> returnSearchParameters();
    Set<String> returnPaymentDetails();
    List<String> returnReportValidations();
    List<String> returnReportStopValidations();
    List<String> returnAdditionalScoringValidations();
}