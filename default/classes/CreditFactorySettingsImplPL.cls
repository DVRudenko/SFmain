public class CreditFactorySettingsImplPL extends CreditFactorySettingsImpl {


    /*******************************************************************************
    *  Summary         : Return data search columns for LWC
    *  CreatedDate     : 17/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : search columns
    ******************************************************************************/
    public override List<Object> returnSearchColumns() {
        List<Object> searchColumnsList = new List<Object> {
            new Map<String, Object> {'label' => 'Company Name', 'fieldName' => 'name'},
            new Map<String, Object> {'label' => 'Street', 'fieldName' => 'street'},
            new Map<String, Object> {'label' => 'House Number', 'fieldName' => 'houseNumber'},
            new Map<String, Object> {'label' => 'Postcode', 'fieldName' => 'postCode'},
            new Map<String, Object> {'label' => 'City', 'fieldName' => 'city'},
            new Map<String, Object> {'label' => 'Credit System Company Number', 'fieldName' => 'creditSystemCompanyNumber'},
            new Map<String, Object> {'label' => 'Status', 'fieldName' => 'status'}
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
        sectionsDataList.add(returnPitSectionData(externalCompany));
        sectionsDataList.add(returnLexisNexisSectionData(externalCompany));
        sectionsDataList.add(returnBigSectionData(externalCompany));
        
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
            new Map<String, Object> {'label' => 'Trade Name', 'value' => externalCompany.tradeName},
            new Map<String, Object> {'label' => 'Company Status', 'value' => externalCompany.status},
            new Map<String, Object> {'label' => 'Legal Form', 'value' => externalCompany.legalForm},
            new Map<String, Object> {'label' => 'Staff Range', 'value' => externalCompany.staffCompanyRange},
            new Map<String, Object> {'label' => 'Fiscal Number', 'value' => externalCompany.taxId},
            new Map<String, Object> {'label' => 'Trade Register Number', 'value' => externalCompany.tradeRegisterNumber},
            new Map<String, Object> {'label' => 'Register Number', 'value' => externalCompany.registerNumber},
            new Map<String, Object> {'label' => 'Turn Over', 'value' => externalCompany.turnOver},
            new Map<String, Object> {'label' => 'Solvency Index', 'value' => externalCompany.solvencyIndex},
            new Map<String, Object> {'label' => 'Request Status', 'value' => externalCompany.requestStatus},
            new Map<String, Object> {'label' => 'Obligation Overdue', 'value' => externalCompany.obligationOverdue},
            new Map<String, Object> {'label' => 'Principal Activity Code', 'value' => externalCompany.principalActivityCode},
            new Map<String, Object> {'label' => 'Principal Activity Description', 'value' => externalCompany.principalActivityDescription}
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
            new Map<String, Object> {'label' => 'Postcode', 'value' => externalCompany.postCode},
            new Map<String, Object> {'label' => 'Postal City', 'value' => externalCompany.postalCity},
            new Map<String, Object> {'label' => 'Postal Street', 'value' => externalCompany.postalStreet},
            new Map<String, Object> {'label' => 'Postal House Number', 'value' => externalCompany.postalHouseNumber},
            new Map<String, Object> {'label' => 'Postal Postcode', 'value' => externalCompany.postalPostCode},
            new Map<String, Object> {'label' => 'Registered City', 'value' => externalCompany.registeredCity},
            new Map<String, Object> {'label' => 'Registered Street', 'value' => externalCompany.registeredStreet},
            new Map<String, Object> {'label' => 'Registered House Number', 'value' => externalCompany.registeredHouseNumber},
            new Map<String, Object> {'label' => 'Registered Postcode', 'value' => externalCompany.registeredPostCode}
        };
        
        addressSectionMap.put('items', addressItemsList);
        
        return addressSectionMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return PIT section data
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : externalCompany - credit factory company from credit system
    *  Returns         : section map
    ******************************************************************************/
    private Map<String, Object> returnPitSectionData(CreditFactoryCompany externalCompany) {
        Map<String, Object> pitSectionMap = new Map<String, Object>();
        pitSectionMap.put('title', 'PIT');
        List<Object> pitItemsList = new List<Object> {
            new Map<String, Object> {'label' => 'Profit Loss Last Year', 'value' => (externalCompany.profitLossLastYear != null ? externalCompany.profitLossLastYear +
                (externalCompany.pitCurrency != null ? ' ' + externalCompany.pitCurrency : '') : '')},
            new Map<String, Object> {'label' => 'Profit Loss Year Before Last', 'value' => (externalCompany.profitLossYearBeforeLast != null ? externalCompany.profitLossYearBeforeLast +
                (externalCompany.pitCurrency != null ? ' ' + externalCompany.pitCurrency : '') : '')},
            new Map<String, Object> {'label' => 'Turn Over Last Year', 'value' => (externalCompany.turnOverLastYear != null ? externalCompany.turnOverLastYear +
                (externalCompany.pitCurrency != null ? ' ' + externalCompany.pitCurrency : '') : '')}
        };
        
        pitSectionMap.put('items', pitItemsList);
        
        return pitSectionMap;
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
    *  Summary         : Return BIG section data
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : externalCompany - credit factory company from credit system
    *  Returns         : section map
    ******************************************************************************/
    private Map<String, Object> returnBigSectionData(CreditFactoryCompany externalCompany) {
        Map<String, Object> bigSectionMap = new Map<String, Object>();
        bigSectionMap.put('title', 'BIG');
        List<Object> bigItemsList = new List<Object> {
            new Map<String, Object> {'label' => 'Creditors Count', 'value' => externalCompany.creditorsCount},
            new Map<String, Object> {'label' => 'Economic Informations Count', 'value' => externalCompany.economicInformationsCount},
            new Map<String, Object> {'label' => 'Liabilities Count', 'value' => externalCompany.liabilitiesCount},
            new Map<String, Object> {'label' => 'Total Amount', 'value' => externalCompany.totalAmount},
            new Map<String, Object> {'label' => 'Total Overdue Amount', 'value' => externalCompany.totalOverdueAmount}
        };

        bigSectionMap.put('items', bigItemsList);
        
        return bigSectionMap;
    }
    
    
     /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database, 
                         externalCompany - credit factory company from credit system
                         externalAdditionalCompany - additional credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public override Map<String, Object> returnAddressUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany) {
        Map<String, Object> addressUpdateMap = new Map<String, Object>();
        addressUpdateMap.put('header', 'Update Address');

        List<Object> addressList = new List<Object>();
        if (! String.isEmpty(externalCompany.street) && ! String.isEmpty(externalCompany.houseNumber) &&
               ! String.isEmpty(externalCompany.postCode) && ! String.isEmpty(externalCompany.city)) {
            String externalStreet = externalCompany.street + ', ' + externalCompany.houseNumber + ', ' +
                    externalCompany.postCode + ', ' + externalCompany.city;
            addressList.add(new Map<String, Object> {'label' => externalStreet, 'value' => 'address'});
        }

        if (! String.isEmpty(externalCompany.postalStreet) && ! String.isEmpty(externalCompany.postalHouseNumber) &&
               ! String.isEmpty(externalCompany.postalPostCode) && ! String.isEmpty(externalCompany.postalCity)) {
            String externalPostalStreet = externalCompany.postalStreet + ', ' + externalCompany.postalHouseNumber + ', ' +
                    externalCompany.postalPostCode + ', ' + externalCompany.postalCity;
            addressList.add(new Map<String, Object> {'label' => externalPostalStreet, 'value' => 'postalAddress'});
        }

        if (! String.isEmpty(externalCompany.registeredStreet) && ! String.isEmpty(externalCompany.registeredHouseNumber) &&
               ! String.isEmpty(externalCompany.registeredPostCode) && ! String.isEmpty(externalCompany.registeredCity)) {
            String externalRegisteredStreet = externalCompany.registeredStreet + ', ' + externalCompany.registeredHouseNumber + ', ' +
                    externalCompany.registeredPostCode + ', ' + externalCompany.registeredCity;
            addressList.add(new Map<String, Object> {'label' => externalRegisteredStreet, 'value' => 'address'});
        }

        Map<String, Object> creditSystemAddressMap = new Map<String, Object> { 'header' => 'Credit System Address', 'items' => addressList};
        addressUpdateMap.put('creditSystemData', creditSystemAddressMap);
        
        String internalRegisteredStreet = (! String.isEmpty(internalCompany.registeredStreet) ? internalCompany.registeredStreet + ', ' : '') +
            (! String.isEmpty(internalCompany.registeredPostCode) ? internalCompany.registeredPostCode + ', ' : '') + 
            (! String.isEmpty(internalCompany.registeredCity) ? internalCompany.registeredCity + ', ' : '');
        internalRegisteredStreet = internalRegisteredStreet.removeEnd(', ').removeStart(', ');
        String internalShippingStreet = (! String.isEmpty(internalCompany.shippingStreet) ? internalCompany.shippingStreet + ', ' : '') +
            (! String.isEmpty(internalCompany.shippingPostCode) ? internalCompany.shippingPostCode + ', ' : '') + 
            (! String.isEmpty(internalCompany.shippingCity) ? internalCompany.shippingCity + ', ' : '');
        internalShippingStreet = internalShippingStreet.removeEnd(', ').removeStart(', ');
        
        List<Object> currentAddressDataList = new List<Object> {
            new Map<String, Object> {'header' => 'Account Registered Address', 'value' => internalRegisteredStreet},
            new Map<String, Object> {'header' => 'Account Shipping Address', 'value' => internalShippingStreet}
        };

        addressUpdateMap.put('currentData', currentAddressDataList);
        
        return addressUpdateMap;
    }


    /*******************************************************************************
    *  Summary         : Return search validations
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : -
    *  Returns         : List of search validations
    ******************************************************************************/
    public override List<String> returnSearchValidations() {
        return new List<String> {'Profile', 'ClosedOpportunity', 'BlackList', 'DesiredPaymentDetails', 'Invoicing', 'ProcessedOpportunity', 'NumberOfCards', 'Duplicates'};
    }


    /*******************************************************************************
    *  Summary         : Return parameters for search
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Set of search parameters
    ******************************************************************************/
    public override Set<String> returnSearchParameters() {
        return new Set<String> {'Name', 'Street', 'City', 'House Number', 'Postal Code', 'Tax Id'};
    }


    /*******************************************************************************
    *  Summary         : Return payment details
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Set of payment details
    ******************************************************************************/
    public override Set<String> returnPaymentDetails() {
        return new Set<String> {'7+7', '15+7', '15+14'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : -
    *  Returns         : List of report validations
    ******************************************************************************/
    public override List<String> returnReportValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'TradeRegisterNumber', 'Contact', 'RequestStatus', 'AgeOfCompany', 'ObligationOverdue', 'LostOpportunities', 'EmailRisk', 'EmptyAddress', 'CompanyStatus'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations that stop process without calculation
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : -
    *  Returns         : List of report stop validations
    ******************************************************************************/
    public override List<String> returnReportStopValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'TradeRegisterNumber', 'RequestStatus', 'LostOpportunities', 'EmailRisk', 'EmptyAddress', 'CompanyStatus'};
    }
}