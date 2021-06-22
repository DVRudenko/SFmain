public class CreditFactorySettingsImplCZCCS extends CreditFactorySettingsImplCZ {


    /*******************************************************************************
    *  Summary         : Return payment details
    *  CreatedDate     : 06/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : sections map
    ******************************************************************************/
    public override Set<String> returnPaymentDetails() {
        return new Set<String> {'30+2', '15+2', '7+2'};
    }

    /*******************************************************************************
    *  Summary         : Return search validations
    *  CreatedDate     : 06/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : sections map
    ******************************************************************************/
    public override List<String> returnSearchValidations() {
        return new List<String> {'Profile', 'ClosedOpportunity', 'BlackList', 'ProcessedOpportunity', 'NumberOfCards', 'Duplicates'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations
    *  CreatedDate     : 06/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : sections map
    ******************************************************************************/
    public override List<String> returnReportValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'TradeRegisterNumber', 'Contact', 'LostOpportunities', 'EmailRisk', 'NegativeInformation'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations that stop process without calculation
    *  CreatedDate     : -
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public override List<String> returnReportStopValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'TradeRegisterNumber', 'LostOpportunities', 'EmailRisk', 'NegativeInformation'};
    }
}