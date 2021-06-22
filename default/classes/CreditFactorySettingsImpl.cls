public virtual class CreditFactorySettingsImpl implements CreditFactorySettings {


    public virtual List<Object> returnSearchColumns() {
        return null;
    }


    public virtual List<Object> returnReportSectionsData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany) {
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database,
                         externalCompany - credit factory company from credit system
                         externalAdditionalCompany - additional credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Map<String, Object> returnAddressUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany) {
        Map<String, Object> addressUpdateMap = new Map<String, Object>();
        addressUpdateMap.put('header', 'Update Address');
        String externalStreet = (! String.isEmpty(externalCompany.street) ? externalCompany.street + ', ' : '') +
            (! String.isEmpty(externalCompany.houseNumber) ? externalCompany.houseNumber + ', ' : '') +
            (! String.isEmpty(externalCompany.postCode) ? externalCompany.postCode + ', ' : '') +
            (! String.isEmpty(externalCompany.city) ? externalCompany.city + ', ' : '');
        externalStreet = externalStreet.removeEnd(', ').removeStart(', ');

        List<Object> creditSystemAddressItemsList = new List<Object> {
            new Map<String, Object> {'label' => externalStreet, 'value' => 'address'}
        };

        Map<String, Object> creditSystemAddressMap = new Map<String, Object> { 'header' => 'Credit System Address', 'items' => creditSystemAddressItemsList};
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
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database, 
                         externalCompany - credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Map<String, Object> returnNameUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany, CreditFactoryCompany externalAdditionalCompany) {
        Map<String, Object> nameUpdateMap = new Map<String, Object>();
        nameUpdateMap.put('header', 'Update Name');
        List<Object> creditSystemNameItemsList = new List<Object> {
            new Map<String, Object> {'label' => externalCompany.name, 'value' => 'name'}
        };
                
        Map<String, Object> creditSystemNameMap = new Map<String, Object> { 'header' => 'Credit System Name', 'items' => creditSystemNameItemsList};
        nameUpdateMap.put('creditSystemData', creditSystemNameMap);
        List<Object> currentNameDataList = new List<Object> {
            new Map<String, Object> {'header' => 'Account Name', 'value' => internalCompany.name}
        };
        
        nameUpdateMap.put('currentData', currentNameDataList);
        
        return nameUpdateMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database, 
                         externalCompany - credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Map<String, Object> returnTaxIdUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany) {
        Map<String, Object> taxIdUpdateMap = new Map<String, Object>();
        taxIdUpdateMap.put('header', 'Update Tax Id');
        List<Object> creditSystemTaxIdItemsList = new List<Object> {
            new Map<String, Object> {'label' => externalCompany.taxId, 'value' => 'taxId'}
        };

        Map<String, Object> creditSystemTaxIdMap = new Map<String, Object> { 'header' => 'Credit System Tax Id', 'items' => creditSystemTaxIdItemsList};
        taxIdUpdateMap.put('creditSystemData', creditSystemTaxIdMap);
        List<Object> currentTaxIdDataList = new List<Object> {
            new Map<String, Object> {'header' => 'Account Tax Id', 'value' => internalCompany.taxId}
        };
        
        taxIdUpdateMap.put('currentData', currentTaxIdDataList);
        
        return taxIdUpdateMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database, 
                         externalCompany - credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Map<String, Object> returnTradeRegisterNumberUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany) {
        Map<String, Object> tradeRegisterNumberUpdateMap = new Map<String, Object>();
        tradeRegisterNumberUpdateMap.put('header', 'Update Trade Register Number');
        List<Object> creditSystemTradeRegisterNumberItemsList = new List<Object> {
            new Map<String, Object> {'label' => externalCompany.tradeRegisterNumber, 'value' => 'tradeRegisterNumber'}
        };
        
        Map<String, Object> creditSystemTradeRegisterNumberMap = new Map<String, Object> { 'header' => 'Credit System Trade Register Number', 'items' => creditSystemTradeRegisterNumberItemsList};
        tradeRegisterNumberUpdateMap.put('creditSystemData', creditSystemTradeRegisterNumberMap);
        List<Object> currentTradeRegisterNumberDataList = new List<Object> {
            new Map<String, Object> {'header' => 'Account Trade Register Number', 'value' => internalCompany.tradeRegisterNumber}
        };
        
        tradeRegisterNumberUpdateMap.put('currentData', currentTradeRegisterNumberDataList);
        
        return tradeRegisterNumberUpdateMap;
    }


    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database,
                         externalCompany - credit factory company from credit system
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Map<String, Object> returnVatNumberUpdateData(CreditFactoryCompany internalCompany, CreditFactoryCompany externalCompany) {
        Map<String, Object> vatNumberUpdateMap = new Map<String, Object>();
        vatNumberUpdateMap.put('header', 'Update Vat Number');
        List<Object> creditSystemVatNumberItemsList = new List<Object> {
            new Map<String, Object> {'label' => externalCompany.vatNumber, 'value' => 'vatNumber'}
        };

        Map<String, Object> creditSystemVatNumberMap = new Map<String, Object> { 'header' => 'Credit System Vat Number', 'items' => creditSystemVatNumberItemsList};
        vatNumberUpdateMap.put('creditSystemData', creditSystemVatNumberMap);
        List<Object> currentVatNumberDataList = new List<Object> {
            new Map<String, Object> {'header' => 'Account Vat Number', 'value' => internalCompany.vatNumber}
        };

        vatNumberUpdateMap.put('currentData', currentVatNumberDataList);

        return vatNumberUpdateMap;
    }


    /*******************************************************************************
    *  Summary         : Return data for LWC sections
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : internalCompany - company from database
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Map<String, Object> returnSwiftBicUpdateData(CreditFactoryCompany internalCompany) {
        Map<String, Object> swiftBicUpdateMap = new Map<String, Object>();
        swiftBicUpdateMap.put('header', 'Update SWIFT BIC');
        List<Object> creditSystemSwiftBicItemsList = new List<Object> {
            new Map<String, Object> {'label' => internalCompany.swiftBic, 'value' => 'swiftBic'}
        };

        Map<String, Object> creditSystemSwiftBicMap = new Map<String, Object> { 'header' => 'Credit System SWIFT BIC', 'items' => creditSystemSwiftBicItemsList};
        swiftBicUpdateMap.put('creditSystemData', creditSystemSwiftBicMap);
        List<Object> currentSwfitBicDataList = new List<Object> {
            new Map<String, Object> {'header' => 'Opportunity SWIFT BIC', 'value' => internalCompany.requestedSwiftBic}
        };

        swiftBicUpdateMap.put('currentData', currentSwfitBicDataList);

        return swiftBicUpdateMap;
    }


    /*******************************************************************************
    *  Summary         : Return search validations
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual List<String> returnSearchValidations() {
        return new List<String> {'Profile', 'ClosedOpportunity', 'BlackList', 'DesiredPaymentDetails', 'ProcessedOpportunity', 'SepaAttachment', 'NumberOfCards', 'Duplicates'};
    }


    /*******************************************************************************
    *  Summary         : Return parameters for search
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Set<String> returnSearchParameters() {
        return new Set<String> {'Name', 'Street', 'City', 'Tax Id'};
    }


    /*******************************************************************************
    *  Summary         : Return payment details
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual Set<String> returnPaymentDetails() {
        return new Set<String> {'7+7', '15+7', '30+7'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual List<String> returnReportValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'Contact', 'LostOpportunities', 'EmailRisk', 'SwiftBic', 'MandateType', 'LegalForm', 'EmptyAddress', 'PaymentMethod'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations that stop process without calculation
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual List<String> returnReportStopValidations() {
        return new List<String> {'CompanyName', 'Address', 'TaxId', 'VatNumber', 'LostOpportunities', 'EmailRisk', 'SwiftBic', 'MandateType', 'LegalForm', 'EmptyAddress', 'PaymentMethod'};
    }


    /*******************************************************************************
    *  Summary         : Return report validations for additional scoring
    *  CreatedDate     : 23/09 by Anton Buzak
    *  Parameters      : country - country
    *  Returns         : sections map
    ******************************************************************************/
    public virtual List<String> returnAdditionalScoringValidations() {
        return new List<String> {'ConsentSigner'};
    }
}