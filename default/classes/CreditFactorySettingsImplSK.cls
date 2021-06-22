public virtual class CreditFactorySettingsImplSK extends CreditFactorySettingsImpl {


    /*******************************************************************************
    *  Summary         : Return data search columns for LWC
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : search columns
    ******************************************************************************/
    public override List<Object> returnSearchColumns() {
        List<Object> searchColumnsList = new List<Object> {
            new Map<String, Object> {'label' => 'Company Name', 'fieldName' => 'name'},
            new Map<String, Object> {'label' => 'Street', 'fieldName' => 'street'},
            new Map<String, Object> {'label' => 'Postcode', 'fieldName' => 'postCode'},
            new Map<String, Object> {'label' => 'City', 'fieldName' => 'city'},
            new Map<String, Object> {'label' => 'Credit System Company Number', 'fieldName' => 'creditSystemCompanyNumber'}
        };

        return searchColumnsList;
    }


    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database,
                         externalCompany - credit factory company from credit system
                         externalAdditionalCompany - additional credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public override List<Object> returnReportSectionsData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany) {
        List<Object> sectionsDataList = new List<Object>();
        sectionsDataList.add(returnGeneralSectionData(externalCompany));
        sectionsDataList.add(returnFoundationSectionData(externalCompany));
        sectionsDataList.add(returnAddressSectionData(externalCompany));
        sectionsDataList.add(returnLexisNexisSectionData(externalCompany));

        return sectionsDataList;
    }


    /*******************************************************************************
    *  Summary         : Return general section data
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : externalCompany - credit factory company from credit system
    *  Returns         : section map
    ******************************************************************************/
    private Map<String, Object> returnGeneralSectionData(CreditFactoryCompany externalCompany) {
        Map<String, Object> generalSectionMap = new Map<String, Object>();
        generalSectionMap.put('title', 'General Information');
        List<Object> generalItemsList = new List<Object> {
            new Map<String, Object> {'label' => 'Credit System Number', 'value' => externalCompany.creditSystemCompanyNumber},
            new Map<String, Object> {'label' => 'Name', 'value' => externalCompany.name},
            new Map<String, Object> {'label' => 'Fax', 'value' => externalCompany.fax},
            new Map<String, Object> {'label' => 'Mobile', 'value' => externalCompany.mobile},
            new Map<String, Object> {'label' => 'Website', 'value' => externalCompany.website},
            new Map<String, Object> {'label' => 'Class Rating', 'value' => externalCompany.classRating},
            new Map<String, Object> {'label' => 'Credit Limit', 'value' => (externalCompany.creditLimit != null ? externalCompany.creditLimit +
                (externalCompany.creditLimitCurrency != null ? ' ' + externalCompany.creditLimitCurrency : '') : '')},
            new Map<String, Object> {'label' => 'Legal Form', 'value' => externalCompany.legalForm},
            new Map<String, Object> {'label' => 'Staff Range', 'value' => externalCompany.staffCompanyRange},
            new Map<String, Object> {'label' => 'Fiscal Number', 'value' => externalCompany.taxId},
            new Map<String, Object> {'label' => 'VAT Number', 'value' => externalCompany.vatNumber},
            new Map<String, Object> {'label' => 'Trade Register Number', 'value' => externalCompany.tradeRegisterNumber},
            new Map<String, Object> {'label' => 'Turn Over', 'value' => externalCompany.turnOver},
            new Map<String, Object> {'label' => 'Solvency Index', 'value' => externalCompany.solvencyIndex},
            new Map<String, Object> {'label' => 'Principal Activity Code', 'value' => externalCompany.principalActivityCode},
            new Map<String, Object> {'label' => 'Principal Activity Description', 'value' => externalCompany.principalActivityDescription},
            new Map<String, Object> {'label' => 'Number of Executions', 'value' => externalCompany.numberOfExecutions},
            new Map<String, Object> {'label' => 'Negative Information', 'value' => externalCompany.negativeInformation},
            new Map<String, Object> {'label' => 'Financial Evaluation', 'value' => externalCompany.financialEvaluation}
        };

        generalSectionMap.put('items', generalItemsList);

        return generalSectionMap;
    }


    /*******************************************************************************
    *  Summary         : Return foundation section data
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : externalCompany - credit factory company from credit system
    *  Returns         : section map
    ******************************************************************************/
    private Map<String, Object> returnFoundationSectionData(CreditFactoryCompany externalCompany) {
        Map<String, Object> foundationSectionMap = new Map<String, Object>();
        foundationSectionMap.put('title', 'Foundation');
        List<Object> foundationItemsList = new List<Object> {
            new Map<String, Object> {'label' => 'Date of Foundation', 'value' => externalCompany.dateOfFoundation},
            new Map<String, Object> {'label' => 'Age of Company', 'value' => externalCompany.ageOfCompany}
        };

        foundationSectionMap.put('items', foundationItemsList);

        return foundationSectionMap;
    }

    /*******************************************************************************
    *  Summary         : Return address section data
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : externalCompany - credit factory company from credit system
    *  Returns         : section map
    ******************************************************************************/
    private Map<String, Object> returnAddressSectionData(CreditFactoryCompany externalCompany) {
        Map<String, Object> addressSectionMap = new Map<String, Object>();
        addressSectionMap.put('title', 'Address Information');
        List<Object> addressItemsList = new List<Object> {
            new Map<String, Object> {'label' => 'Country', 'value' => externalCompany.country},
            new Map<String, Object> {'label' => 'City', 'value' => externalCompany.city},
            new Map<String, Object> {'label' => 'Street', 'value' => externalCompany.street},
            new Map<String, Object> {'label' => 'House Number', 'value' => externalCompany.houseNumber},
            new Map<String, Object> {'label' => 'Postcode', 'value' => externalCompany.postCode}
        };

        addressSectionMap.put('items', addressItemsList);

        return addressSectionMap;
    }


    /*******************************************************************************
    *  Summary         : Return LexisNexis section data
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : externalCompany - credit factory company from credit system
    *  Returns         : section map
    ******************************************************************************/
    private Map<String, Object> returnLexisNexisSectionData(CreditFactoryCompany externalCompany) {
        Map<String, Object> lexisNexisSectionMap = new Map<String, Object>();
        lexisNexisSectionMap.put('title', 'LexisNexis');
        List<Object> lexisNexisItemsList = new List<Object> {
            new Map<String, Object> {'label' => 'Email Exists', 'value' => (externalCompany.emailExists != null ? externalCompany.emailExists +
                (externalCompany.emailDate != null ? ' ' + externalCompany.emailDate : '') : '')},
            new Map<String, Object> {'label' => 'Domain Exists', 'value' => (externalCompany.domainExists != null ? externalCompany.domainExists +
                (externalCompany.domainDate != null ? ' ' + externalCompany.domainDate : '') : '')},
            new Map<String, Object> {'label' => 'Email Status', 'value' => externalCompany.emailStatus},
            new Map<String, Object> {'label' => 'Email Risk', 'value' => externalCompany.emailRisk},
            new Map<String, Object> {'label' => 'Risk Description', 'value' => externalCompany.riskDescription},
            new Map<String, Object> {'label' => 'Risk Advice', 'value' => externalCompany.riskAdvice},
            new Map<String, Object> {'label' => 'Fraud Within Industry', 'value' => externalCompany.fraudWithinIndustry},
            new Map<String, Object> {'label' => 'Fraud Type', 'value' => externalCompany.fraudType},
            new Map<String, Object> {'label' => 'Hits', 'value' => (externalCompany.totalHits != null ? externalCompany.totalHits +
                (externalCompany.uniqueHits != null ? ' (' + externalCompany.uniqueHits + ')' : '') : '')},
            new Map<String, Object> {'label' => 'Name Match', 'value' => externalCompany.nameMatch},
            new Map<String, Object> {'label' => 'Checked Email', 'value' => externalCompany.checkedEmail}
        };

        lexisNexisSectionMap.put('items', lexisNexisItemsList);

        return lexisNexisSectionMap;
    }


    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 04/12/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database,
                         externalCompany - credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public override Map<String, Object> returnTradeRegisterNumberUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany) {
        Map<String, Object> tradeRegisterNumberUpdateMap = new Map<String, Object>();
        tradeRegisterNumberUpdateMap.put('header', 'Update Trade Register Number');
        List<Object> creditSystemTradeRegisterNumberItemsList = new List<Object> {
            new Map<String, Object> {'label' => (externalCompany.tradeRegisterNumber != null ? externalCompany.tradeRegisterNumber : '') + (externalCompany.countyCourt != null ? externalCompany.countyCourt : ''), 'value' => 'tradeRegisterNumber'}
        };

        Map<String, Object> creditSystemTradeRegisterNumberMap = new Map<String, Object> { 'header' => 'Credit System Trade Register Number', 'items' => creditSystemTradeRegisterNumberItemsList};
        tradeRegisterNumberUpdateMap.put('creditSystemData', creditSystemTradeRegisterNumberMap);
        List<Object> currentTradeRegisterNumberDataList = new List<Object> {
            new Map<String, Object> {'header' => 'Account Trade Register Number', 'value' => (internalCompany.tradeRegisterNumber != null ? internalCompany.tradeRegisterNumber : '') + (internalCompany.countyCourt != null ? internalCompany.countyCourt : '')}
        };

        tradeRegisterNumberUpdateMap.put('currentData', currentTradeRegisterNumberDataList);

        return tradeRegisterNumberUpdateMap;
    }


    /*******************************************************************************
    *  Summary         : Return search validations
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual override List<String> returnSearchValidations() {
        return new List<String> {'Profile', 'ClosedOpportunity', 'BlackList', 'DesiredPaymentDetails', 'ProcessedOpportunity', 'NumberOfCards', 'Duplicates'};
    }


    /*******************************************************************************
    *  Summary         : Return parameters for search
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public override Set<String> returnSearchParameters() {
        return new Set<String> {'Name', 'Street', 'City', 'Postal Code', 'Tax Id'};
    }


    /*******************************************************************************
    *  Summary         : Return payment details
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual override Set<String> returnPaymentDetails() {
        return new Set<String> {'7+7', '15+10'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual override List<String> returnReportValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'TradeRegisterNumber', 'Contact', 'LostOpportunities', 'EmailRisk', 'PaymentMethod', 'NegativeInformation'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations that stop process without calculation
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual override List<String> returnReportStopValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'TradeRegisterNumber', 'LostOpportunities', 'EmailRisk', 'PaymentMethod'};
    }
}