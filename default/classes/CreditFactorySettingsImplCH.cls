public class CreditFactorySettingsImplCH extends CreditFactorySettingsImpl {


    /*******************************************************************************
    *  Summary         : Return search columns data for LWC
    *  CreatedDate     : 25/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : search columns
    ******************************************************************************/
    public override List<Object> returnSearchColumns() {
        List<Object> searchColumnsList = new List<Object> {
            new Map<String, Object> {'label' => 'Company Name', 'fieldName' => 'name'},
            new Map<String, Object> {'label' => 'Street', 'fieldName' => 'street'},
            new Map<String, Object> {'label' => 'Postcode', 'fieldName' => 'postCode'},
            new Map<String, Object> {'label' => 'City', 'fieldName' => 'city'},
            new Map<String, Object> {'label' => 'Credit System Company Number', 'fieldName' => 'creditSystemCompanyNumber'},
            new Map<String, Object> {'label' => 'Status', 'fieldName' => 'status'}
        };

        return searchColumnsList;
    }


    /*******************************************************************************
    *  Summary         : Return payment details
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public override Set<String> returnPaymentDetails() {
        return new Set<String> {'30+14', '30+27'};
    }


    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : internalCompany - company from database,
                         externalCompany - credit factory company
                         externalAdditionalCompany - additional credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public override List<Object> returnReportSectionsData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany) {
        List<Object> sectionsDataList = new List<Object>();
        sectionsDataList.add(returnGeneralSectionData(internalCompany, externalCompany));
        sectionsDataList.add(returnFoundationSectionData(externalCompany));
        sectionsDataList.add(returnAddressSectionData(externalCompany));
        sectionsDataList.add(returnLexisNexisSectionData(externalCompany));

        return sectionsDataList;
    }


    /*******************************************************************************
    *  Summary         : Return general section data
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : internalCompany - company from database,
                         externalCompany - credit factory company
    *  Returns         : section map
    ******************************************************************************/
    private Map<String, Object> returnGeneralSectionData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany) {
        Map<String, Object> generalSectionMap = new Map<String, Object>();
        generalSectionMap.put('title', 'General Information');
        List<Object> generalItemsList = new List<Object> {
            new Map<String, Object> {'label' => 'Credit System Number', 'value' => externalCompany.creditSystemCompanyNumber},
            new Map<String, Object> {'label' => 'Name', 'value' => externalCompany.name},
            new Map<String, Object> {'label' => 'fax', 'value' => externalCompany.fax},
            new Map<String, Object> {'label' => 'Mobile', 'value' => externalCompany.mobile},
            new Map<String, Object> {'label' => 'Website', 'value' => externalCompany.website},
            new Map<String, Object> {'label' => 'Class Rating', 'value' => externalCompany.classRating},
            new Map<String, Object> {'label' => 'Credit Limit', 'value' => (externalCompany.creditLimit != null ? externalCompany.creditLimit +
                (externalCompany.creditLimitCurrency != null ? ' ' + externalCompany.creditLimitCurrency : '') : '')},
            new Map<String, Object> {'label' => 'Company Status', 'value' => externalCompany.status},
            new Map<String, Object> {'label' => 'Legal Form', 'value' => externalCompany.legalForm},
            new Map<String, Object> {'label' => 'Staff Range', 'value' => externalCompany.staffCompanyRange},
            new Map<String, Object> {'label' => 'Fiscal Number', 'value' => externalCompany.taxId},
            new Map<String, Object> {'label' => 'VAT Number', 'value' => externalCompany.vatNumber},
            new Map<String, Object> {'label' => 'Credit Decision', 'value' => externalCompany.creditDecision},
            new Map<String, Object> {'label' => 'Share Capital', 'value' => (externalCompany.paidUpShareCapital != null ? externalCompany.paidUpShareCapital +
                (externalCompany.paidUpShareCapitalCurrency != null ? ' ' + externalCompany.paidUpShareCapitalCurrency : '') : '')},
            new Map<String, Object> {'label' => 'Turn Over', 'value' => externalCompany.turnOver},
            new Map<String, Object> {'label' => 'Solvency Index', 'value' => externalCompany.solvencyIndex},
            new Map<String, Object> {'label' => 'Date of last change of director', 'value' => externalCompany.dateOfLastChangeOfDirector},
            new Map<String, Object> {'label' => 'Date of last change of address', 'value' => externalCompany.dateOfLastChangeOfAddress},
            new Map<String, Object> {'label' => 'Date of last change of name', 'value' => externalCompany.dateOfLastChangeOfName},
            new Map<String, Object> {'label' => 'Requested BIC', 'value' => internalCompany.requestedSwiftBic}
        };

        generalSectionMap.put('items', generalItemsList);

        return generalSectionMap;
    }


    /*******************************************************************************
    *  Summary         : Return foundation section data
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
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
            new Map<String, Object> {'label' => 'House number', 'value' => externalCompany.houseNumber},
            new Map<String, Object> {'label' => 'Postcode', 'value' => externalCompany.postCode}
        };

        addressSectionMap.put('items', addressItemsList);

        return addressSectionMap;
    }


    /*******************************************************************************
    *  Summary         : Return LexisNexis section data
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
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
    *  Summary         : Return search validations
    *  CreatedDate     : 25/11/2020 by Ivan Kulinkovich
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public override List<String> returnSearchValidations() {
        return new List<String> {'Profile', 'ClosedOpportunity', 'BlackList', 'ProcessedOpportunity', 'SepaAttachment', 'NumberOfCards', 'Duplicates'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public override List<String> returnReportValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'Contact', 'LostOpportunities', 'EmailRisk', 'SwiftBic'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations that stop process without calculation
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public override List<String> returnReportStopValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'LostOpportunities', 'EmailRisk', 'SwiftBic'};
    }


    /*******************************************************************************
    *  Summary         : Return parameters for search
    *  CreatedDate     : 25/11/2020 by Ivan Kulinkovich
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public override Set<String> returnSearchParameters() {
        return new Set<String> {'Name', 'Vat Number'};
    }
}