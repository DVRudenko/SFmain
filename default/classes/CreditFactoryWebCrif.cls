public class CreditFactoryWebCrif {


    /*******************************************************************************
    *  Summary         : Generate HTTP Request to Crif
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : endpoint - Crif endpoint, 
                         userName - Crif account name, 
                         password - Crif account password, 
                         searchParametersNames - parameters for searching.
    *  Returns         : search requset
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password, Map<String, String> searchParametersMap) {
        String body = generateSearchXML(userName, password, searchParametersMap);
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'urn:search');
        request.setHeader('Content-Type', 'text/xml');
        request.setBody(body);
        request.setTimeout(30000);
        request.setEndpoint(endpoint.substringBefore(','));
        request.setMethod('POST');
        return request;
    }

    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : userName - Crif account name, 
                         password - Crif account password, 
                         searchParametersMap - parameters for searching
    *  Returns         : search string
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, Map<String, String> searchParametersMap) {
        String opportunityName;
        if (searchParametersMap.containsKey('name') && ! String.isEmpty(searchParametersMap.get('name'))) {
            opportunityName = searchParametersMap.get('name').replace('&', ' ');    
        }
        
        String xmlbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sear="http://www.deltavista.com/dspone/webservices/search">' +
           '<soapenv:Header>' +
                '<sear:IdentificationMessageContext>' +
                    '<sear:Credentials>' +
                        '<sear:Login>' + userName + '</sear:Login>' +
                        '<sear:Password>' + password + '</sear:Password>' +
                    '</sear:Credentials>' +
                '</sear:IdentificationMessageContext>' +
           '</soapenv:Header>' +
           '<soapenv:Body>' +
                '<sear:SearchRequest>' +
                    '<sear:Address>' +
                        ((opportunityName != null) ? 
                            '<sear:Name>' + opportunityName + '</sear:Name>' : '') +
                        ((searchParametersMap.containsKey('registeredStreet') && ! String.isEmpty(searchParametersMap.get('registeredStreet'))) ? 
                            '<sear:Street>' + searchParametersMap.get('registeredStreet') + '</sear:Street>' : '') +
                        ((searchParametersMap.containsKey('registeredHouseNumber') && ! String.isEmpty(searchParametersMap.get('registeredHouseNumber'))) ?
                            '<sear:Unit>' + searchParametersMap.get('registeredHouseNumber') + '</sear:Unit>' : '') +
                        ((searchParametersMap.containsKey('registeredPostCode') && ! String.isEmpty(searchParametersMap.get('registeredPostCode'))) ?
                            '<sear:Zip>' + searchParametersMap.get('registeredPostCode') + '</sear:Zip>' : '') +
                        ((searchParametersMap.containsKey('registeredCity') && ! String.isEmpty(searchParametersMap.get('registeredCity'))) ?
                            '<sear:City>' + searchParametersMap.get('registeredCity') + '</sear:City>' : '') +
                        '<sear:Country>POL</sear:Country>' + 
                    '</sear:Address>' +
                    '<sear:HitQuality>' +
                        '<sear:MinSimilarity>30</sear:MinSimilarity>' +
                        '<sear:MaxReturn>10</sear:MaxReturn>' +
                    '</sear:HitQuality>' +
                    ((searchParametersMap.containsKey('taxId') && ! String.isBlank(searchParametersMap.get('taxId'))) ? '<sear:CompanyRegistrationInfo>' +
                        '<sear:directoryEntry>' +
                           '<sear:type>PL_NIP</sear:type>' +
                           '<sear:ID>' + searchParametersMap.get('taxId') + '</sear:ID>' +
                        '</sear:directoryEntry>' +
                    '</sear:CompanyRegistrationInfo>' : '') +
                '</sear:SearchRequest>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : search dom
    ******************************************************************************/
    public static Dom.XmlNode returnSearchResponse(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'SearchResponse') {
                        return bodyField;
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Error message if search response body of xml is null
    *  CreatedDate     : 17/04/2020
    *  Parameters      : node - body from response
    *  Returns         : error message
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'Fault') {
                        for (Dom.XmlNode faultField : bodyField.getChildElements()) {
                            if (faultField.getName() == 'detail') {
                                for (Dom.XmlNode detailField : faultField.getChildElements()) {
                                    if (detailField.getName() == 'error') {
                                        for (Dom.XmlNode errorField : detailField.getChildElements()) {
                                            if (errorField.getName() == 'code') {
                                                String code = errorField.getText();
                                                if (code == '400') {
                                                    return 'Bad request';
                                                } else if (code == '401') {
                                                    return 'Authorization error';
                                                } else if (code == 'Authentication error') {
                                                    return 'Read timed out';
                                                } else if (code == '500' || code == '503') {
                                                    return 'Internal server error';
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        for (Dom.XmlNode faultField : bodyField.getChildElements()) {
                            if (faultField.getName() == 'faultstring') {
                                return faultField.getText();
                            }
                        }
                    }
                }
            }
        }
        
        return null;    
    } 


    /*******************************************************************************
    *  Summary         : Return searched companies list
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : Dom.XmlNode node - body from response
    *  Returns         : list of companies
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchedCompanies(Dom.XmlNode node) {
        List<CreditFactoryCompany> companiesFromSearch = new List<CreditFactoryCompany>();
        Integer id = 1;
        for (Dom.XmlNode responseField : node.getChildElements()) {
            if (responseField.getName() == 'Candidates') {
                CreditFactoryCompany company = new CreditFactoryCompany();
                for (Dom.XmlNode candidateField : responseField.getChildElements()) {
                    if (candidateField.getName() == 'Address') {
                        for (Dom.XmlNode addressField : candidateField.getChildElements()) {
                            if (addressField.getName() == 'Name') {
                                company.name = addressField.getText();
                            }
                            if (addressField.getName() == 'CompanyRegistrationInfo') {
                                for (Dom.XmlNode regInfoField : addressField.getChildElements()) {
                                    if (regInfoField.getName() == 'directoryEntry') {
                                        Boolean isNip;
                                        String nipNumber;
                                        for (Dom.XmlNode entryField : regInfoField.getChildElements()) {
                                            if (entryField.getName() == 'type' && entryField.getText() == 'PL_NIP') {
                                                isNip = true;
                                            }

                                            if (entryField.getName() == 'ID') {
                                                nipNumber = entryField.getText();
                                            }
                                        }

                                        if (isNip == true && nipNumber != null) {
                                            company.identificationNumber = nipNumber;
                                            company.taxId = nipNumber;
                                            company.creditSystemCompanyNumber = nipNumber;
                                        }
                                    }
                                }
                            }
                            if (addressField.getName() == 'Street') {
                                company.street = addressField.getText();
                            }
                            if (addressField.getName() == 'Unit') {
                                company.houseNumber = addressField.getText();
                            }
                            if (addressField.getName() == 'UnitAdd' && ! String.isEmpty(company.registeredHouseNumber) && addressField.getText() != '') {
                                company.houseNumber += '/' + addressField.getText();
                            }
                            if (addressField.getName() == 'Zip') {
                                company.postCode = addressField.getText();
                            }
                            if (addressField.getName() == 'City') {
                                company.city = addressField.getText();
                            }
                            if (addressField.getName() == 'CompanyStatus') {
                                company.status = addressField.getText();
                            }
                        }
                    }
                }

                if (company.identificationNumber != null) {
                    company.id = String.valueOf(id);
                    id ++;
                    companiesFromSearch.add(company);
                }
            }
        }

        return companiesFromSearch;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : endpoint - from CreditSystem custom setting, 
                         userName - from CreditSystem custom setting, 
                         password - from CreditSystem custom setting, 
                         companyId - Id of Credit System Company
    *  Returns         : report request
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String companyId) {
        String body = generateReportXML(userName, password, companyId);
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'urn:orderCheck');
        request.setHeader('Content-Type', 'text/xml');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint.substringBetween(','));
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : userName - from CreditSystem custom setting, 
                         password - from CreditSystem custom setting,
                         companyId - Id of Credit System Company
    *  Returns         : report request xml
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String companyId) {
        String xmlbody = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001">' +
            '<SOAP-ENV:Header>' +
                '<ns1:messageContext>' +
                    '<ns1:credentials>' +
                        '<ns1:user>' + userName + '</ns1:user>' +
                        '<ns1:password>' + password + '</ns1:password>' +
                    '</ns1:credentials>' +
                '</ns1:messageContext>' +
            '</SOAP-ENV:Header>' +
            '<SOAP-ENV:Body>' +
                '<ns1:orderCheckRequest>' +
                    '<ns1:product>' +
                        '<ns1:name>CreditCheckBusiness</ns1:name>' +
                        '<ns1:country>POL</ns1:country>' +
                    '</ns1:product>' +
                    '<ns1:searchedAddress>' +
                        '<ns1:registry>' +
                            '<ns1:type>PL_NIP</ns1:type>' +
                            '<ns1:number>' + companyId + '</ns1:number>' +
                        '</ns1:registry>' +
                    '</ns1:searchedAddress>' +
                '</ns1:orderCheckRequest>' +
            '</SOAP-ENV:Body>' +
        '</SOAP-ENV:Envelope>';
        return xmlbody;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : report dom
    ******************************************************************************/
    public static Dom.XMLNode returnReportBody(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                return envelopeField;
            }
        }
        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return Company
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response, 
                         nipNumber - nip number for getting report
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XmlNode node, String nipNumber) {
        try {
            CreditFactoryCompany company = new CreditFactoryCompany();
            company.creditSystemCompanyNumber = returnCreditSystemNumber(node);
            company.classRating = returnClassRating(node);
            company.turnOver = returnTurnOver(node);
            company.legalForm = returnLegalForm(node);
            company.tradeRegisterNumber = returnTradeRegisterNumber(node); 
            company.taxId = returnTaxNumber(node);
            if (company.taxId != null) {
                company.vatNumber = 'PL' + company.taxId;
            }

            company.registerNumber = returnRegisterId(node);
            company.staffCompanyRange = returnStaffCompanyRange(node);
            company.creditLimit = returnCreditLimit(node);
            company.creditLimitCurrency = 'PLN';
            company.dateOfFoundation = returnDateOfFoundation(node);
            company.ageOfCompany = returnAgeOfCompany(node);
            company.status = returnStatus(node);
            company.name = returnName(node);
            company.tradeName = returnTradeName(node); 
            company.street = returnStreet(node);
            company.houseNumber = returnHouseNumber(node);
            company.postCode = returnPostcode(node);
            company.city = returnCity(node);
            company.postalStreet = returnPostalStreet(node);
            company.postalHouseNumber = returnPostalHouseNumber(node);
            company.postalPostCode = returnPostalPostCode(node);
            company.postalCity = returnPostalCity(node);
            company.registeredStreet = returnRegisteredStreet(node);
            company.registeredHouseNumber = returnRegisteredHouseNumber(node);
            company.registeredPostCode = returnRegisteredPostCode(node);
            company.registeredCity = returnRegisteredCity(node);
            company.country = 'Poland';
            company.phone = returnPhone(node);
            company.fax = returnFax(node);
            company.mobile = returnMobile(node);
            company.email = returnEmail(node);
            company.website = returnWebsite(node);
            company.identificationNumber = nipNumber;
            company.solvencyIndex = returnSolvencyIntex(node);
            company.requestStatus = returnRequestStatus(node);
            company.obligationOverdue = returnObligationOverdue(node);
            company.numberOfHits = returnNumberOfHits(node);
            company.policyRuleHitsList = returnPolicyRuleHits(node);
            company.nameChangeDecision = returnNameChangeDecision(node);
            company.addressChangeDecision = returnAddressChangeDecision(node);
            company.identificationType = returnIdentificationType(node);
            company.profitLossLastYear = returnProfitLossLastYear(node);
            company.profitLossYearBeforeLast = returnProfitLossYearBeforeLast(node);
            company.turnoverLastYear = returnTurnOverLastYear(node);
            company.pitCurrency = 'PLN';
            company.bigRequested = false;
            company.creditFactoryContacts = returnReportCompanyEmployees(company, node);
            company.principalActivityCode = returnMainPkdCode(node);
            if (mainPkdCodesMap.containsKey(company.principalActivityCode)) {
                company.principalActivityDescription = mainPkdCodesMap.get(company.principalActivityCode);
                company.principalActivityCode = company.principalActivityCode.replaceAll('[^0-9]', '');    
            }
            
            company.recordType = 'Default';
            return company;
        } catch (Exception e) {
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Company number
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : credit system number
    ******************************************************************************/
    public static String returnCreditSystemNumber(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'archiveID') {
                        return responseField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company class rating
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : rating
    ******************************************************************************/
    public static String returnClassRating(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'myDecision') {
                        for (Dom.XmlNode myDecisionField : responseField.getChildElements()) {
                            if (myDecisionField.getName() == 'decision') {
                                if (ratingsMap.containsKey(myDecisionField.getText())) {
                                    return ratingsMap.get(myDecisionField.getText());
                                }
                                else {
                                    return myDecisionField.getText();
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Turn over
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : turn over
    ******************************************************************************/
    public static String returnTurnOver(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'myDecision') {
                        for (Dom.XmlNode myDecisionField : responseField.getChildElements()) {
                            if (myDecisionField.getName() == 'rating') {
                                if (myDecisionField.getText() != null && turnOversMap.containsKey(myDecisionField.getText().substring(0, 1))) {
                                    return turnOversMap.get(myDecisionField.getText().substring(0, 1));
                                }
                                else {
                                    return myDecisionField.getText();
                                }
                            }
                        }
                    }
                }
            }
        }
            
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company form
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : legal form
    ******************************************************************************/
    public static String returnLegalForm(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'classification') {
                                for (Dom.XmlNode classField : basicDataField.getChildElements()) {
                                    if (classField.getName() == 'companyLegalForm') {
                                        if (legalFormsMap.containsKey(classField.getText())) {
                                            return legalFormsMap.get(classField.getText());
                                        } else {
                                            return classField.getText();
                                        }
                                    }   
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Trade Register Number
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : trade register number
    ******************************************************************************/
    public static String returnTradeRegisterNumber(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XmlNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        Boolean isRegon;
                                        String regonNumber; 
                                        for (Dom.XmlNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'type' && companyRegField.getText() == 'PL_REGON') {
                                                isRegon = true;
                                            }

                                            if (companyRegField.getName() == 'number') {
                                                regonNumber = companyRegField.getText();
                                            }
                                        }

                                        if (isRegon == true && regonNumber != null) {
                                            return regonNumber;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company tax number
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : tax number
    ******************************************************************************/
    public static String returnTaxNumber(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XmlNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        Boolean isNip;
                                        String nipNumber; 
                                        for (Dom.XmlNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'type' && companyRegField.getText() == 'PL_NIP') {
                                                isNip = true;
                                            }

                                            if (companyRegField.getName() == 'number') {
                                                nipNumber = companyRegField.getText();
                                            }
                                        }

                                        if (isNip == true && nipNumber != null) {
                                            return nipNumber;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company register Id
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : register id
    ******************************************************************************/
    public static String returnRegisterId(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XmlNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        Boolean isKrs;
                                        String krsNumber; 
                                        for (Dom.XmlNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'type' && companyRegField.getText() == 'PL_KRS') {
                                                isKrs = true;
                                            }

                                            if (companyRegField.getName() == 'number') {
                                                krsNumber = companyRegField.getText();
                                            }
                                        }

                                        if (isKrs == true && krsNumber != null) {
                                            return krsNumber;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company range
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : staff company range
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'FinanceData') {
                                for (Dom.XmlNode financeDataField : basicDataField.getChildElements()) {
                                    if (financeDataField.getName() == 'employeesNumberInfo') {
                                        return financeDataField.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return Credit Limit
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : credit limit
    ******************************************************************************/
    public static String returnCreditLimit(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'myDecision') {
                        for (Dom.XmlNode myDecisionField : responseField.getChildElements()) {
                            if (myDecisionField.getName() == 'rating') {
                                if (myDecisionField.getText() != null && creditLimitsMap.containsKey(myDecisionField.getText().substring(0, 1))) {
                                    return creditLimitsMap.get(myDecisionField.getText().substring(0, 1));
                                }
                                else {
                                    return myDecisionField.getText();
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company date of foundation
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : date of foundation
    ******************************************************************************/
    public static String returnDateOfFoundation(Dom.XmlNode node) {
       for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XmlNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        for (Dom.XmlNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'dateOfRegistration') {
                                                return companyRegField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company age
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : age of company
    ******************************************************************************/
    public static String returnAgeOfCompany(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XmlNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'solvencyDecision') {
                                for (Dom.XmlNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'daysSinceInBusiness') {
                                        for (Dom.XmlNode daysField : decisionField.getChildElements()) {
                                            if (daysField.getName() == 'value') {
                                                return String.valueOf(Integer.valueOf(daysField.getText())/365.25.round(System.RoundingMode.HALF_EVEN));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company status
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : status
    ******************************************************************************/
    public static String returnStatus(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'clientExtensions') {
                        for (Dom.XmlNode extensionField : responseField.getChildElements()) {
                            if (extensionField.getName() == 'additionalData') {
                                Boolean isStatus;
                                String status;
                                for (Dom.XmlNode addDataField : extensionField.getChildElements()) {
                                    if (addDataField.getName() == 'name' && addDataField.getText() == 'detailedCompanyStatus') {
                                        isStatus = true;
                                    }

                                    if (addDataField.getName() == 'value') {
                                        status = addDataField.getText();
                                    }
                                }

                                if (isStatus == true && status != null) {
                                    return status;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return Main Pkd Code
    *  CreatedDate     : 20/04/2020
    *  Parameters      : node - body from response
    *  Returns         : main pkd code
    ******************************************************************************/
    public static String returnMainPkdCode(Dom.XMLNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'clientExtensions') {
                        for (Dom.XmlNode extensionField : responseField.getChildElements()) {
                            if (extensionField.getName() == 'additionalData') {
                                String name;
                                String value;
                                for (Dom.XmlNode addDataField : extensionField.getChildElements()) {
                                    if (addDataField.getName() == 'name') {
                                        name = addDataField.getText();
                                    }

                                    if (addDataField.getName() == 'value' && name == 'mainPKDCode') {
                                        value = addDataField.getText();
                                    }
                                }

                                if (value != null) {
                                    return value;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company name
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : name
    ******************************************************************************/
    public static String returnName(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XmlNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XmlNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'name') {
                                        return addressField.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Summary         : Return Company trade name
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : trade name
    ******************************************************************************/
    public static String returnTradeName(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'officialName') {
                                return basicDataField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company best known street.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : street
    ******************************************************************************/
    public static String returnStreet(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XmlNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XmlNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        for (Dom.XmlNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'street') {
                                                return locationField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company best known housenumber.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : house number
    ******************************************************************************/
    public static String returnHouseNumber(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XmlNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XmlNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        String houseNumber;
                                        for (Dom.XmlNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'house') {
                                                houseNumber = locationField.getText();
                                            }
                                            if (locationField.getName() == 'houseExtension' && ! String.isEmpty(houseNumber) && locationField.getText() != '') {
                                                houseNumber += '/' + locationField.getText();
                                            }
                                        }

                                        return houseNumber;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company best known postcode.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : postal code
    ******************************************************************************/
    public static String returnPostcode(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XmlNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XmlNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        for (Dom.XmlNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'zip') {
                                                return locationField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company best known city.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : city
    ******************************************************************************/
    public static String returnCity(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XmlNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XmlNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        for (Dom.XmlNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'city') {
                                                return locationField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Postal street.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : postal address street
    ******************************************************************************/
    public static String returnPostalStreet(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String street = '';
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'street') {
                                        street = locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return street;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Postal housenumber.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : postal address house number
    ******************************************************************************/
    public static String returnPostalHouseNumber(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String houseNumber;
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'house') {
                                        houseNumber = locationField.getText();
                                    }

                                    if (locationField.getName() == 'houseExtension' && ! String.isEmpty(houseNumber) && locationField.getText() != '') {
                                        houseNumber += '/' + locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return houseNumber;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Postal postcode.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : postal address post code
    ******************************************************************************/
    public static String returnPostalPostCode(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String postalCode = '';
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'zip') {
                                        postalCode = locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return postalCode;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Postal city.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : postal address city
    ******************************************************************************/
    public static String returnPostalCity(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String city = '';
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'city') {
                                        city = locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return city;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Registered street.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : registered street
    ******************************************************************************/
    public static String returnRegisteredStreet(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String street = '';
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'street') {
                                        street = locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return street;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Registered housenumber.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : registered house number
    ******************************************************************************/
    public static String returnRegisteredHouseNumber(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String houseNumber = '';
                                String houseNumberExtension = '';
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'house') {
                                        houseNumber = locationField.getText();
                                    }

                                    if (locationField.getName() == 'houseExtension' && ! String.isEmpty(houseNumber) && locationField.getText() != '') {
                                        houseNumber += '/' + locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return houseNumber;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Registered postcode.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : registered post code
    ******************************************************************************/
    public static String returnRegisteredPostCode(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String postalCode = '';
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'zip') {
                                        postalCode = locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return postalCode;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company Registered city.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : registered city
    ******************************************************************************/
    public static String returnRegisteredCity(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String city = '';
                                for (Dom.XmlNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'city') {
                                        city = locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return city;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company phone
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : phone
    ******************************************************************************/
    public static String returnPhone(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isPhone;
                                String phoneNumber;
                                for (Dom.XmlNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'PHONE') {
                                        isPhone = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        phoneNumber = contactField.getText();
                                    }
                                }

                                if (isPhone == true && phoneNumber != null) {
                                    return phoneNumber;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company fax
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : fax
    ******************************************************************************/
    public static String returnFax(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isFax;
                                String faxNumber;
                                for (Dom.XmlNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'FAX') {
                                        isFax = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        faxNumber = contactField.getText();
                                    }
                                }

                                if (isFax == true && faxNumber != null) {
                                    return faxNumber;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company mobile
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : mobile
    ******************************************************************************/
    public static String returnMobile(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isMobile;
                                String mobileNumber;
                                for (Dom.XmlNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'MOBILE') {
                                        isMobile = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        mobileNumber = contactField.getText();
                                    }
                                }

                                if (isMobile == true && mobileNumber != null) {
                                    return mobileNumber;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company email
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : email
    ******************************************************************************/
    public static String returnEmail(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isEmail;
                                String emailAddress;
                                for (Dom.XmlNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'EMAIL') {
                                        isEmail = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        emailAddress = contactField.getText();
                                    }
                                }

                                if (isEmail == true && emailAddress != null) {
                                    return emailAddress;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Company website
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : website
    ******************************************************************************/
    public static String returnWebsite(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XmlNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isWebsite;
                                String webSiteAddress;
                                for (Dom.XmlNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'WWW') {
                                        isWebsite = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        webSiteAddress = contactField.getText();
                                    }
                                }

                                if (isWebsite == true && webSiteAddress != null) {
                                    return webSiteAddress;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
        
        
    /*******************************************************************************
    *  Summary         : Return Solvency Index
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : solvency index
    ******************************************************************************/
    public static String returnSolvencyIntex(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'myDecision') {
                        for (Dom.XmlNode myDecisionField : responseField.getChildElements()) {
                            if (myDecisionField.getName() == 'rating') {
                                if (myDecisionField.getText() != null && solvencyIndexesMap.containsKey(myDecisionField.getText().substring(1, myDecisionField.getText().length()))) {
                                    return solvencyIndexesMap.get(myDecisionField.getText().substring(1, myDecisionField.getText().length()));
                                }
                                else {
                                    return myDecisionField.getText();
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return request status
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : request status
    ******************************************************************************/
    public static String returnRequestStatus(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XmlNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'SolvencyDecision') {
                                for (Dom.XmlNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'externalSourcesProcessingStatus') {
                                        for (Dom.XmlNode statusField : decisionField.getChildElements()) {
                                            if (statusField.getName() == 'value') {
                                                return statusField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return obligation overdue based on payment history
    *  CreatedDate     : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : obligation overdue
    ******************************************************************************/
    public static Boolean returnObligationOverdue(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'paymentHistory') {
                        for (Dom.XmlNode paymentHistoryField : responseField.getChildElements()) {
                            if (paymentHistoryField.getName() == 'detail') {
                                Date openDate;
                                Date closeDate;
                                Decimal amountOpen;
                                for (Dom.XmlNode detailField : paymentHistoryField.getChildElements()) {
                                    if (detailField.getName() == 'dateOpen') {
                                        openDate = Date.newInstance(Integer.valueOf(detailField.getText().substring(0, 4)), 
                                            Integer.valueOf(detailField.getText().substring(4, 6)), Integer.valueOf(detailField.getText().substring(6, 8)));
                                    }

                                    if (detailField.getName() == 'dateClosed') {
                                        closeDate = Date.newInstance(Integer.valueOf(detailField.getText().substring(0, 4)), 
                                            Integer.valueOf(detailField.getText().substring(4, 6)), Integer.valueOf(detailField.getText().substring(6, 8)));
                                    }

                                    if (detailField.getName() == 'amountOpen') {
                                        amountOpen = Decimal.valueOf(detailField.getText());
                                    }
                                }

                                if ((openDate != null && closeDate != null && openDate.daysBetween(closeDate) > 7 ||
                                    openDate != null && closeDate == null && openDate.daysBetween(Date.today()) > 7) && amountOpen > 100) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        }
        return false;
    }


    /*******************************************************************************
    *  Summary         : Return number of hits from policy rules    
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : Dom.XmlNode node - body from response
    *  Returns         : number of policy rule hits
    ******************************************************************************/
    public static String returnNumberOfHits(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XmlNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'clientExtensionsDecision') {
                                for (Dom.XmlNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'policyRule') {
                                        for (Dom.XmlNode policyRuleField : decisionField.getChildElements()) {
                                            if (policyRuleField.getName() == 'value') {
                                                return policyRuleField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return policy rule hits
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : Dom.XmlNode node - body from response
    *  Returns         : policy rules list
    ******************************************************************************/
    public static List<String> returnPolicyRuleHits(Dom.XmlNode node) {
        List<String> policyRulesSet = new List<String>();
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'clientExtensions') {
                        for (Dom.XmlNode extensionsField : responseField.getChildElements()) {
                            if (extensionsField.getName() == 'decisionRule') {
                                for (Dom.XmlNode decisionRuleField : extensionsField.getChildElements()) {
                                    if (decisionRuleField.getName() == 'description') {
                                        policyRulesSet.add(decisionRuleField.getText());
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return policyRulesSet;
    }


    /*******************************************************************************
    *  Summary         : Return name change decision    
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : Dom.XmlNode node - body from response
    *  Returns         : decision about change of company name
    ******************************************************************************/
    public static String returnNameChangeDecision(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XmlNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'solvencyDecision') {
                                for (Dom.XmlNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'daysSinceNameChange') {
                                        for (Dom.XmlNode nameChangeField : decisionField.getChildElements()) {
                                            if (nameChangeField.getName() == 'partialDecision') {
                                                return nameChangeField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return adress change decision    
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : Dom.XmlNode node - body from response
    *  Returns         : decision about address of company name
    ******************************************************************************/
    public static String returnAddressChangeDecision(Dom.XmlNode node) {
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XmlNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'solvencyDecision') {
                                for (Dom.XmlNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'daysSinceDomicileChange') {
                                        for (Dom.XmlNode nameChangeField : decisionField.getChildElements()) {
                                            if (nameChangeField.getName() == 'partialDecision') {
                                                return nameChangeField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return identification type
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : identification type
    ******************************************************************************/
    public static String returnIdentificationType(Dom.XmlNode body) {
        for (Dom.XmlNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XmlNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'identificationDecision') {
                                for (Dom.XmlNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'identificationType') {
                                        for (Dom.XmlNode typeField : decisionField.getChildElements()) {
                                            if (typeField.getName() == 'value') {
                                                return typeField.getText();
                                            }
                                        }
                                    }
                                } 
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return profit/loss for the last year.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : Dom.XmlNode node - body from response
    *  Returns         : profit/loss for the last year
    ******************************************************************************/
    public static String returnProfitLossLastYear(Dom.XmlNode body) {
        for (Dom.XmlNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyExtendedData') {
                        for (Dom.XmlNode companyExtendedDataField : responseField.getChildElements()) {
                            if (companyExtendedDataField.getName() == 'financialStatement') {
                                for (Dom.XmlNode financialStatementField : companyExtendedDataField.getChildElements()) {
                                    if (financialStatementField.getName() == 'profitAndLoss') {
                                        String identifier;
                                        String amount;
                                        String startDate;
                                        String endDate;
                                        for (Dom.XmlNode profitAndLossField : financialStatementField.getChildElements()) {
                                            if (profitAndLossField.getName() == 'financialAccount') {
                                                for (Dom.XmlNode financialAccountField : profitAndLossField.getChildElements()) {
                                                    if (financialAccountField.getName() == 'financialSubAccount') {
                                                        for (Dom.XmlNode financialSubAccountField : financialAccountField.getChildElements()) {
                                                            if (financialSubAccountField.getName() == 'identifier') {
                                                                identifier = financialSubAccountField.getText();
                                                            } else if (financialSubAccountField.getName() == 'amount') {
                                                                for (Dom.XmlNode amountField : financialSubAccountField.getChildElements()) {
                                                                    if (identifier == 'POL_PROF_LOSS_COMP_N' && amountField.getName() == 'amount') {
                                                                        amount = amountField.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if (profitAndLossField.getName() == 'period') {
                                                for (Dom.XmlNode periodField : profitAndLossField.getChildElements()) {
                                                    if (periodField.getName() == 'startDate') {
                                                        startDate = periodField.getText();
                                                    } else if (periodField.getName() == 'endDate') {
                                                        endDate = periodField.getText();
                                                    }
                                                }
                                            }

                                            if (startDate == String.valueOf(Date.today().year() - 1) + '0101' &&
                                                    endDate == String.valueOf(Date.today().year() - 1) + '1231') {
                                                return amount;
                                            }
                                        }
                                    }
                                } 
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return profit/loss for the year before last.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : profit/loss for year before last
    ******************************************************************************/
    public static String returnProfitLossYearBeforeLast(Dom.XmlNode body) {
        for (Dom.XmlNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyExtendedData') {
                        for (Dom.XmlNode companyExtendedDataField : responseField.getChildElements()) {
                            if (companyExtendedDataField.getName() == 'financialStatement') {
                                for (Dom.XmlNode financialStatementField : companyExtendedDataField.getChildElements()) {
                                    if (financialStatementField.getName() == 'profitAndLoss') {
                                        String identifier;
                                        String amount;
                                        String startDate;
                                        String endDate;
                                        for (Dom.XmlNode profitAndLossField : financialStatementField.getChildElements()) {
                                            if (profitAndLossField.getName() == 'financialAccount') {
                                                for (Dom.XmlNode financialAccountField : profitAndLossField.getChildElements()) {
                                                    if (financialAccountField.getName() == 'financialSubAccount') {
                                                        for (Dom.XmlNode financialSubAccountField : financialAccountField.getChildElements()) {
                                                            if (financialSubAccountField.getName() == 'identifier') {
                                                                identifier = financialSubAccountField.getText();
                                                            } else if (financialSubAccountField.getName() == 'amount') {
                                                                for (Dom.XmlNode amountField : financialSubAccountField.getChildElements()) {
                                                                    if (identifier == 'POL_PROF_LOSS_COMP_N' && amountField.getName() == 'amount') {
                                                                        amount = amountField.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if (profitAndLossField.getName() == 'period') {
                                                for (Dom.XmlNode periodField : profitAndLossField.getChildElements()) {
                                                    if (periodField.getName() == 'startDate') {
                                                        startDate = periodField.getText();
                                                    } else if (periodField.getName() == 'endDate') {
                                                        endDate = periodField.getText();
                                                    }
                                                }
                                            }

                                            if (startDate == String.valueOf(Date.today().year() - 2) + '0101' &&
                                                    endDate == String.valueOf(Date.today().year() - 2) + '1231') {
                                                return amount;
                                            }
                                        }
                                    }
                                } 
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Turn Over for the last year.
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : Dom.XmlNode node - body from response
    *  Returns         : turn over for the last year
    ******************************************************************************/
    public static String returnTurnOverLastYear(Dom.XmlNode body) {
        for (Dom.XmlNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyExtendedData') {
                        for (Dom.XmlNode companyExtendedDataField : responseField.getChildElements()) {
                            if (companyExtendedDataField.getName() == 'financialStatement') {
                                for (Dom.XmlNode financialStatementField : companyExtendedDataField.getChildElements()) {
                                    if (financialStatementField.getName() == 'profitAndLoss') {
                                        String identifier;
                                        String amount;
                                        String startDate;
                                        String endDate;
                                        for (Dom.XmlNode profitAndLossField : financialStatementField.getChildElements()) {
                                            if (profitAndLossField.getName() == 'financialAccount') {
                                                for (Dom.XmlNode financialAccountField : profitAndLossField.getChildElements()) {
                                                    if (financialAccountField.getName() == 'financialSubAccount') {
                                                        for (Dom.XmlNode financialSubAccountField : financialAccountField.getChildElements()) {
                                                            if (financialSubAccountField.getName() == 'identifier') {
                                                                identifier = financialSubAccountField.getText();
                                                            } else if (financialSubAccountField.getName() == 'amount') {
                                                                for (Dom.XmlNode amountField : financialSubAccountField.getChildElements()) {
                                                                    if (identifier == 'POL_PROF_LOSS_COMP_C' && amountField.getName() == 'amount') {
                                                                        amount = amountField.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if (profitAndLossField.getName() == 'period') {
                                                for (Dom.XmlNode periodField : profitAndLossField.getChildElements()) {
                                                    if (periodField.getName() == 'startDate') {
                                                        startDate = periodField.getText();
                                                    } else if (periodField.getName() == 'endDate') {
                                                        endDate = periodField.getText();
                                                    }
                                                }
                                            }

                                            if (startDate == String.valueOf(Date.today().year() - 1) + '0101' &&
                                                    endDate == String.valueOf(Date.today().year() - 1) + '1231') {
                                                return amount;
                                            }
                                        }
                                    }
                                } 
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return company employees
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : company - company, node - body from response
    *  Returns         : list of company employees
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnReportCompanyEmployees(CreditFactoryCompany company, Dom.XmlNode node) {
        company.creditFactoryContacts = new List<CreditFactoryCompany.CreditFactoryContact>();
        for (Dom.XmlNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyExtendedData') {
                        for (Dom.XmlNode extendedDataField : responseField.getChildElements()) {
                            if (extendedDataField.getName() == 'organization') {
                                for (Dom.XmlNode orgField : extendedDataField.getChildElements()) {
                                    if (orgField.getName() == 'organizationPosition') {
                                        CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                                        for (Dom.XmlNode orgPositionField : orgField.getChildElements()) {
                                            if (orgPositionField.getName() == 'firstName') {
                                                contact.name = orgPositionField.getText();
                                            }
        
                                            if (orgPositionField.getName() == 'name') {
                                                String name = orgPositionField.getText();
                                                if (contact.name != null) {
                                                    contact.name = contact.name + ' ' + name;
                                                } else {
                                                    contact.name = name;
                                                }
                                            }
        
                                            if (orgPositionField.getName() == 'location') {
                                                for (Dom.XmlNode locationField : orgPositionField.getChildElements()) {
                                                    if (locationField.getName() == 'street') {
                                                        contact.address = locationField.getText();
                                                    }
        
                                                    if (locationField.getName() == 'house') {
                                                        contact.address = contact.address + ', ' + locationField.getText();
                                                    }
        
                                                    if (locationField.getName() == 'city') {
                                                        contact.address = contact.address + ', ' + locationField.getText();
                                                    }
        
                                                    if (locationField.getName() == 'zip') {
                                                        contact.address = contact.address + ', ' + locationField.getText();
                                                    }
                                                }
                                            }
        
                                            if (orgPositionField.getName() == 'function') {
                                                for (Dom.XmlNode functionField : orgPositionField.getChildElements()) {
                                                    if (functionField.getName() == 'functionType') {
                                                        contact.type = functionField.getText();
                                                    }
                                                }
                                            }
                                        }

                                        contact.recordType = 'Default';
                                        company.creditFactoryContacts.add(contact);
                                    }
                                }
                            }
                        }
                    }
                }
            }    
        }
        
        return company.creditFactoryContacts;
    }


    /*******************************************************************************
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : endpoint - from CreditSystem custom setting, 
                         userName - from CreditSystem custom setting, 
                         password - from CreditSystem custom setting, 
                         companyId - Id of Credit System Company
    *  Returns         : pdf report request
    ******************************************************************************/
    public static HttpRequest generatePdfRequest(String endpoint, String userName, String password, String companyId) {
        try {
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Accept-Encoding', 'gzip,deflate');
            request.setHeader('Content-Type', 'text/xml');
            request.setTimeout(30000);
            request.setEndpoint(endpoint.substringAfterLast(',') + '?login=' + userName + '&password=' + password + '&archId=' + companyId);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Report request failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    public static Map<String, String> countriesMap = new Map<String, String>{
        'POL' => 'Poland'
    };


    public static Map<String, String> legalFormsMap = new Map<String, String>{
        '0' => 'Unknown',
        '1' => 'Private',
        '2' => 'European Economic Interest Grouping (EEIG)',
        '3' => 'Employers Federation',
        '4' => 'Foundation',
        '5' => 'Funds',
        '6' => 'Commune self-government units',
        '7' => 'Other businesses organization',
        '8' => 'Other social or professional organization',
        '9' => 'Other legal entity, which is public benefit organizations',
        '10' => 'Other churches and religious organizations',
        '11' => 'Chamber of commerce',
        '12' => 'Chamber of Crafts',
        '13' => 'Research and development unit',
        '14' => 'Non legal entity organizational units',
        '15' => 'Agricultural circle',
        '16' => 'Medical transport',
        '17' => 'Clergyman legal entity, which is public benefit organization',
        '18' => 'Catholic church',
        '19' => 'Non legal entity church institution, which is public benefit organization',
        '20' => 'Non legal entity public benefit organization',
        '21' => 'Foreign company branch',
        '22' => 'Representation by national trade and services associations',
        '23' => 'Representation by national transport associations',
        '24' => 'National amid industry association',
        '25' => 'National amid industry union',
        '26' => 'Other social legal form',
        '27' => 'Organs of state control and protection of rights',
        '28' => 'Government administration units',
        '29' => 'Private person company',
        '30' => 'Legal entity',
        '31' => 'State agencies',
        '32' => 'Political party™',
        '33' => 'National sport association',
        '34' => 'District local organizational units',
        '35' => 'National company',
        '36' => 'Foreign company',
        '37' => 'Agricultural industry association',
        '38' => 'Courts',
        '39' => 'Independent public health care',
        '40' => 'State treasury',
        '41' => 'Economic self-government',
        '42' => 'Cooperative',
        '43' => 'Joint-stock company',
        '44' => 'Civil company',
        '45' => 'European company',
        '46' => 'General partnership',
        '47' => 'Limited partnership',
        '48' => 'Limited joint-stock',
        '49' => 'private company',
        '50' => 'Partnership company',
        '51' => 'Private limited company',
        '52' => 'Societas Cooperativa Europaea',
        '53' => 'Association',
        '54' => 'Sport association',
        '55' => 'Nationwide sport association',
        '56' => 'Insurance company',
        '57' => 'Province self-government units',
        '58' => 'Residential community',
        '59' => 'Self-government community',
        '60' => 'Trade and services associations',
        '61' => 'Transport association',
        '62' => 'Association of farmers',
        '63' => 'Employers union',
        '64' => 'Agricultural association',
        '65' => 'Polish craftsmen association',
        '66' => 'Sports Association',
        '67' => 'Union of associations',
        '68' => 'Trade union',
        '69' => 'Union of farmers',
        '70' => 'Union of farmers and agricultural circles',
        '71' => 'Any capital or non-capital company or organization',
        '72' => 'Ordinary Association',
        '73' => 'State budget agency',
        '74' => 'Single person company confirmed',
        '75' => 'Other type of partnership company',
        '76' => 'Mutual Reinsurance Associations',
        '77' => 'Main branches of foreign Mutual Reinsurance Associations',
        '78' => 'Universities',
        '79' => 'European Grouping of Territorial Cooperation',
        '80' => 'Employers\' organisations',
        '81' => 'Foreign representations',
        '82' => 'Public kindergarten',
        '83' => 'Private kindergarten',
        '84' => 'Public school',
        '85' => 'Private school',
        '86' => 'Public educational institution',
        '87' => 'Private educational institution',
        '90' => 'Limited joint-stock partnership',
        '100' => 'Private enterprise',
        '322' => 'European Cooperativa',
        '324' => 'European company',
        '348' => 'Joint-stock company',
        '390' => 'Private limited company',
        '502' => 'European Economic Interest Grouping (EEIG) 600 Public authority',
        '600' => 'Public authority',
        '905' => 'Registered branch (foreign)',
        '2000' => 'Foundation',
        '2001' => 'Funds',
        '2002' => 'National company',
        '2003' => 'Cooperative',
        '2004' => 'Civil company',
        '2005' => 'General partnership',
        '2006' => 'Limited partnership',
        '2007' => 'Limited joint-stock',
        '2008' => 'Partnership company',
        '2009' => 'Association',
        '2010' => 'Insurance company'
    };
    
    
    public static Map<String, String> ratingsMap = new Map<String, String> {
        'GREEN' => '1',
        'YELLOW' => '2',
        'RED' => '3'
    };
    
    
    public static Map<String, String> turnOversMap = new Map<String, String> {
        'A' => '>= 5 Million',
        'B' => '500.000 - 5 Million',
        'C' => '100.000 - 499.999',
        'D' => '< 100000',
        'U' => 'unknown'
    };
    
    
    public static Map<String, String> creditLimitsMap = new Map<String, String> {
        'A' => '80000',
        'B' => '40000',
        'C' => '20000',
        'D' => '10000',
        'U' => '7000'
    };
    
    
    public static Map<String, String> solvencyIndexesMap = new Map<String, String> {
        '+++' => '100',
        '++' => '200',
        '+' => '300',
        '-' => '400',
        '--' => '500',
        '---' => '600'
    };
    
    
    public static Map<String, String> mainPkdCodesMap = new Map<String, String>{
        '23.11.Z' => 'Manufacture of flat glass',
        '01.23.Z' => 'Growing of tree and bush citrus fruits',
        '23.12.Z' => 'Shaping and processing of flat glass',
        '46.45.Z' => 'Wholesale of perfume and cosmetics',
        '13.20.C' => 'Manufacture of man-made woven fabrics',
        '07.10.Z' => 'Mining of iron ores',
        '07.21.Z' => 'Mining of uranium and thorium ores',
        '13.20.D' => 'Manufacture of other woven fabrics',
        '47.54.Z' => 'Retail sale of electrical household appliances in specialised stores',
        '14.12.Z' => 'Manufacture of workwear',
        '16.22.Z' => 'Manufacture of assembled parquet floors',
        '17.24.Z' => 'Manufacture of wallpaper',
        '17.29.Z' => 'Manufacture of other articles of paper and paperboard',
        '01.11.Z' => 'Growing of cereals, leguminous crops and oil plants, for seeds, except rice',
        '01.12.Z' => 'Growing of rice',
        '01.13.Z' => 'Growing of vegetables, including melons, and of roots and tubers',
        '01.14.Z' => 'Growing of sugar cane',
        '01.15.Z' => 'Growing of tobacco',
        '01.16.Z' => 'Growing of fibre crops',
        '01.19.Z' => 'Growing of other non-perennial crops',
        '01.21.Z' => 'Growing of grapes',
        '01.22.Z' => 'Growing of tree and bush tropical and subtropical fruits',
        '01.24.Z' => 'Growing of tree and bush pome fruits and stone fruits',
        '01.25.Z' => 'Growing of other tree and bush fruits and nuts',
        '01.26.Z' => 'Growing of tree oleaginous fruits',
        '01.27.Z' => 'Growing of beverage crops',
        '01.28.Z' => 'Growing of spices, aromatic, drug and pharmaceutical crops',
        '01.29.Z' => 'Growing of other perennial crops',
        '01.30.Z' => 'Plant propagation',
        '01.41.Z' => 'Raising of dairy cattle',
        '01.42.Z' => 'Raising of other cattle and buffaloes',
        '01.43.Z' => 'Raising of horses and other equines',
        '01.44.Z' => 'Raising of camels and camelids',
        '01.45.Z' => 'Raising of sheep and goats',
        '01.46.Z' => 'Raising of swine/pigs',
        '01.47.Z' => 'Raising of poultry',
        '01.49.Z' => 'Raising of other animals',
        '01.50.Z' => 'Agricultural cultivation together with raising of animals (mixed activity)',
        '01.61.Z' => 'Support activities for crop production',
        '01.62.Z' => 'Support activities for farm animal production',
        '01.63.Z' => 'Post-harvest crop activities',
        '01.64.Z' => 'Seed processing for propagation',
        '01.70.Z' => 'Hunting and acquiring of hunting animals, including service activity',
        '02.10.Z' => 'Silviculture and other forestry activities, excluding gathering of forestry products',
        '02.20.Z' => 'Logging',
        '02.30.Z' => 'Gathering of wild growing forestry products, excluding wood',
        '02.40.Z' => 'Service activity related to forestry',
        '03.11.Z' => 'Marine fishing',
        '03.12.Z' => 'Freshwater fishing',
        '03.21.Z' => 'Marine aquaculture',
        '03.22.Z' => 'Freshwater aquaculture',
        '05.10.Z' => 'Mining of hard coal',
        '05.20.Z' => 'Mining of lignite',
        '06.10.Z' => 'Extraction of crude petroleum',
        '06.20.Z' => 'Extraction of natural gas',
        '23.13.Z' => 'Manufacture of hollow glass',
        '07.29.Z' => 'Mining of other non-ferrous metal ores',
        '08.11.Z' => 'Quarrying of ornamental and building stone, limestone, gypsum, chalk and slate',
        '08.12.Z' => 'Operation of gravel and sand pits; mining of clays and kaolin',
        '08.91.Z' => 'Mining of minerals for chemical industry and for production of fertilizers',
        '10.32.Z' => 'Manufacture of fruit and vegetable juice',
        '08.92.Z' => 'Extraction of peat',
        '08.93.Z' => 'Extraction of salt',
        '08.99.Z' => 'Other mining and quarrying notelsewhere classified',
        '09.10.Z' => 'Support activities for petroleum and natural gas extraction',
        '09.90.Z' => 'Support activities for other mining and quarrying',
        '10.11.Z' => 'Processing and preserving of meat, excluding poultry meat',
        '10.12.Z' => 'Processing and preserving of poultry meat',
        '10.13.Z' => 'Production of meat products, including poultry meat products',
        '10.20.Z' => 'Processing and preserving of fish, crustaceans and molluscs',
        '10.31.Z' => 'Processing and preserving of potatoes',
        '10.39.Z' => 'Other processing and preserving of fruit and vegetables',
        '10.41.Z' => 'Manufacture of oils and other fluid fats',
        '10.42.Z' => 'Manufacture of margarine and similar edible fats',
        '10.51.Z' => 'Operation of dairies and cheese making',
        '10.83.Z' => 'Processing of tea and coffee',
        '10.52.Z' => 'Manufacture of ice cream',
        '10.71.Z' => 'Manufacture of bread; manufacture of fresh pastry goods and cakes',
        '10.72.Z' => 'Manufacture of rusks and biscuits; manufacture of preserved pastry goods and cakes',
        '10.73.Z' => 'Manufacture of macaroni, noodles, couscous and similar farinaceous products',
        '10.81.Z' => 'Manufacture of sugar',
        '10.82.Z' => 'Manufacture of cocoa, chocolate and sugar confectionery',
        '10.84.Z' => 'Manufacture of condiments and seasonings',
        '10.85.Z' => 'Manufacture of prepared meals and dishes',
        '10.86.Z' => 'Manufacture of homogenised food preparations and dietetic food',
        '10.89.Z' => 'Manufacture of other food products not elsewhere classified',
        '10.91.Z' => 'Manufacture of prepared feeds for farm animals',
        '10.92.Z' => 'Manufacture of prepared pet foods',
        '13.20.A' => 'Manufacture of cotton woven fabrics',
        '10.61.Z' => 'Manufacture of grain mill products',
        '10.62.Z' => 'Manufacture of starches and starch products',
        '11.01.Z' => 'Distilling, rectifying and blending of spirits',
        '11.02.Z' => 'Manufacture of wine from grape',
        '11.03.Z' => 'Manufacture of cider and other fruit wines',
        '11.04.Z' => 'Manufacture of other non-distilled fermented beverages',
        '13.20.B' => 'Manufacture of wool woven fabrics',
        '11.05.Z' => 'Manufacture of beer',
        '11.06.Z' => 'Manufacture of malt',
        '11.07.Z' => 'Manufacture of soft drinks; production of mineral waters and other bottled waters',
        '12.00.Z' => 'Manufacture of tobacco products',
        '13.10.A' => 'Manufacture of cotton yarn',
        '13.10.B' => 'Manufacture of wool yarn',
        '13.10.C' => 'Manufacture of man-made fibres yarn',
        '13.10.D' => 'Manufacture of yarn from other textile fibres, including manufacture of sewing thread',
        '13.30.Z' => 'Finishing of textiles',
        '13.91.Z' => 'Manufacture of knitted and crocheted fabrics',
        '13.92.Z' => 'Manufacture of made-up textile articles',
        '13.93.Z' => 'Manufacture of carpets and rugs',
        '13.94.Z' => 'Manufacture of cordage, rope, twine and netting',
        '13.95.Z' => 'Manufacture of non-wovens and articles made from non-wovens, except apparel',
        '13.96.Z' => 'Manufacture of other technical and industrial textiles',
        '13.99.Z' => 'Manufacture of other textiles notelsewhere classified',
        '14.11.Z' => 'Manufacture of leather clothes',
        '14.13.Z' => 'Manufacture of other outerwear',
        '14.14.Z' => 'Manufacture of underwear',
        '14.19.Z' => 'Manufacture of other wearing apparel and accessories',
        '14.20.Z' => 'Manufacture of articles of fur',
        '14.31.Z' => 'Manufacture of knitted and crocheted hosiery',
        '14.39.Z' => 'Manufacture of other knitted and crocheted apparel',
        '15.11.Z' => 'Tanning and dressing of leather; dressing and dyeing of fur',
        '15.12.Z' => 'Produkcja toreb bagażowych, toreb ręcznych i podobnych wyrobów kaletniczych; produkcja wyrobów rymarskich',
        '15.20.Z' => 'Manufacture of footwear',
        '20.11.Z' => 'Manufacture of industrial gases',
        '20.12.Z' => 'Manufacture of dyes and pigments',
        '20.13.Z' => 'Manufacture of other inorganic basic chemicals',
        '20.14.Z' => 'Manufacture of other organic basic chemicals',
        '18.11.Z' => 'Printing of newspapers',
        '20.15.Z' => 'Manufacture of fertilisers and nitrogen compounds',
        '20.17.Z' => 'Manufacture of synthetic rubber in primary forms',
        '20.16.Z' => 'Manufacture of plastics in primary forms',
        '20.20.Z' => 'Manufacture of pesticides and other agrochemical products',
        '20.30.Z' => 'Manufacture of paints, varnishes and similar coatings, printing ink and mastics',
        '20.41.Z' => 'Manufacture of soap and detergents, cleaning and polishing preparations',
        '20.42.Z' => 'Manufacture of perfumes and toilet preparations',
        '20.51.Z' => 'Manufacture of explosives',
        '20.52.Z' => 'Manufacture of glues',
        '20.53.Z' => 'Manufacture of essential oils',
        '20.59.Z' => 'Manufacture of other chemical products not elsewhere classified',
        '20.60.Z' => 'Manufacture of man-made fibres',
        '21.10.Z' => 'Manufacture of basic pharmaceutical substances',
        '21.20.Z' => 'Manufacture of medicines and other pharmaceutical products',
        '22.11.Z' => 'Manufacture of rubber tyres and tubes; retreading and rebuilding of rubber tyres',
        '22.19.Z' => 'Produkcja pozostałych wyrobów z gumy',
        '22.21.Z' => 'Manufacture of plastic plates, sheets, tubes and profiles',
        '22.22.Z' => 'Manufacture of plastic packing goods',
        '22.23.Z' => 'Manufacture of builders’ ware of plastic',
        '22.29.Z' => 'Manufacture of other plastic products',
        '16.10.Z' => 'Sawmilling and planing of wood',
        '16.21.Z' => 'Manufacture of veneer sheets and wood-based panels',
        '16.23.Z' => 'Manufacture of other builders\' carpentry and joinery',
        '16.24.Z' => 'Manufacture of wooden containers',
        '16.29.Z' => 'Manufacture of other products of wood; manufacture of articles of cork, straw and plaiting materials',
        '17.11.Z' => 'Manufacture of pulp',
        '17.12.Z' => 'Manufacture of paper and paperboard',
        '17.21.Z' => 'Manufacture of corrugated paper and paperboard and of containers of paper and paperboard',
        '17.22.Z' => 'Manufacture of household and sanitary goods and of toilet requisites',
        '17.23.Z' => 'Manufacture of paper stationery',
        '18.12.Z' => 'Other printing',
        '18.13.Z' => 'Pre-press and pre-media services',
        '18.14.Z' => 'Binding and related services',
        '18.20.Z' => 'Reproduction of recorded media',
        '19.10.Z' => 'Manufacture and processing of coke',
        '19.20.Z' => 'Manufacture and processing ofrefind petroleum products',
        '23.14.Z' => 'Manufacture of glass fibres',
        '23.19.Z' => 'Manufacture and processing of other glass, including technical glassware',
        '23.20.Z' => 'Manufacture of refractory products',
        '23.31.Z' => 'Manufacture of ceramic tiles and flags',
        '23.32.Z' => 'Manufacture of bricks, tiles and construction products, in baked clay',
        '23.41.Z' => 'Manufacture of ceramic tableware and ornamental articles',
        '23.42.Z' => 'Manufacture of ceramic sanitary fixtures',
        '23.43.Z' => 'Manufacture of ceramic insulators and hollow insulators',
        '23.44.Z' => 'Manufacture of other technical ceramic products',
        '23.49.Z' => 'Manufacture of other ceramic products',
        '23.51.Z' => 'Manufacture of cement',
        '23.52.Z' => 'Manufacture of lime and plaster',
        '23.61.Z' => 'Manufacture of concrete products for construction purposes',
        '23.62.Z' => 'Manufacture of plaster products for construction purposes',
        '23.63.Z' => 'Manufacture of ready-mixed concrete',
        '23.64.Z' => 'Manufacture of mortars',
        '23.65.Z' => 'Manufacture of fibre cement',
        '23.69.Z' => 'Manufacture of other articles of concrete, plaster and cement',
        '23.70.Z' => 'Cutting, shaping and finishing of stone',
        '23.91.Z' => 'Production of abrasive products',
        '23.99.Z' => 'Manufacture of abrasive products and others non-metallic mineral products not elsewhere classified',
        '24.10.Z' => 'Manufacture of pig iron, ferro-alloys, basic iron and steel and metallurgic articles',
        '24.20.Z' => 'Manufacture of tubes and pipes, conduits, closed sections andconnectors, of steel',
        '24.31.Z' => 'Cold drawing of bars',
        '24.32.Z' => 'Cold rolling of narrow strip',
        '24.33.Z' => 'Manufacture of cold forming products',
        '24.34.Z' => 'Manufacture of wire',
        '24.41.Z' => 'Precious metals production',
        '24.42.A' => 'Primary aluminium production',
        '24.42.B' => 'Aluminium and aluminium alloy goods production',
        '24.43.Z' => 'Lead, zinc and tin production',
        '24.44.Z' => 'Copper production',
        '24.45.Z' => 'Other non-ferrous metal production',
        '24.46.Z' => 'Nuclear fuel production',
        '24.51.Z' => 'Casting of iron',
        '24.52.Z' => 'Casting of steel',
        '24.53.Z' => 'Casting of light metals',
        '24.54.A' => 'Casting of copper and copper alloy',
        '24.54.B' => 'Casting of other non-ferrous metals not elsewhere classified',
        '29.10.B' => 'Manufacture of cars',
        '27.11.Z' => 'Manufacture of electric motors, generators and transformers',
        '27.12.Z' => 'Manufacture of electricity distribution and control apparatus',
        '27.20.Z' => 'Manufacture of batteries and accumulators',
        '27.31.Z' => 'Manufacture of fibre optic cables',
        '27.32.Z' => 'Manufacture of other electronic and electric wires and cables',
        '27.33.Z' => 'Manufacture of installing equipment',
        '27.40.Z' => 'Manufacture of electric lighting equipment',
        '27.51.Z' => 'Manufacture of electric domestic appliances',
        '27.52.Z' => 'Manufacture of non-electric domestic appliances',
        '27.90.Z' => 'Manufacture of other electrical equipment',
        '29.10.A' => 'Manufacture of engines for motor vehicles (excluding motorcycles) and for agricultural tractors',
        '47.65.Z' => 'Retail sale of games and toys in specialised stores',
        '29.10.C' => 'Manufacture of buses',
        '29.10.D' => 'Manufacture of motor vehicles for the transport of goods',
        '29.10.E' => 'Manufacture of other motor vehicles excluding motorcycles',
        '29.20.Z' => 'Manufacture of bodies (coachwork) for motor vehicles; manufacture of trailers and semi-trailers',
        '29.31.Z' => 'Manufacture of electrical and electronic equipment for motor vehicles',
        '29.32.Z' => 'Manufacture of other parts and accessories for motor vehicles excluding motorcycles',
        '30.99.Z' => 'Manufacture of other transport equipment not elsewhere classified',
        '30.11.Z' => 'Produkcja statków i konstrukcji pływających',
        '30.12.Z' => 'Building of pleasure and sporting boats',
        '30.20.Z' => 'Manufacture of railway locomotives and rolling stock',
        '30.30.Z' => 'Manufacture of air and spacecraft and related machinery',
        '30.40.Z' => 'Manufacture of military fighting vehicles',
        '30.91.Z' => 'Manufacture of motorcycles',
        '30.92.Z' => 'Manufacture of bicycles and invalid carriages',
        '25.11.Z' => 'Manufacture of metal structures and parts of structures',
        '25.12.Z' => 'Manufacture of metal elements of building woodwork',
        '25.21.Z' => 'Manufacture of central heating radiators and boilers',
        '25.29.Z' => 'Manufacture of other tanks, reservoirs and containers of metal',
        '25.30.Z' => 'Manufacture of steam generators, except central heating hot water boilers',
        '25.40.Z' => 'Manufacture of weapons and ammunition',
        '25.50.Z' => 'Forging, pressing, stamping and roll-forming of metal; powder metallurgy',
        '25.61.Z' => 'Treatment and coating of metals',
        '25.62.Z' => 'Mechanical working of metal elements',
        '25.71.Z' => 'Manufacture of cutlery',
        '25.72.Z' => 'Manufacture of locks and hinges',
        '25.73.Z' => 'Manufacture of tools',
        '25.91.Z' => 'Manufacture of metal containers',
        '25.92.Z' => 'Manufacture of metal packaging',
        '25.93.Z' => 'Manufacture of wire products,chains and springs',
        '25.94.Z' => 'Manufacture of fasteners and screws',
        '25.99.Z' => 'Manufacture of other fabricated metal products not elsewhere classified',
        '26.11.Z' => 'Manufacture of electronic components',
        '26.12.Z' => 'Manufacture of electronic printed circuits',
        '26.20.Z' => 'Manufacture of computers and peripheral equipment',
        '26.80.Z' => 'Manufacture of unrecorded magnetic and optical media',
        '31.03.Z' => 'Manufacture of mattresses',
        '26.30.Z' => 'Manufacture of(tele)communication equipment',
        '26.40.Z' => 'Manufacture of consumer electronics',
        '26.60.Z' => 'Manufacture of irradiation, electromedical and electrotherapeutic equipment',
        '26.51.Z' => 'Manufacture of instruments and appliances for measuring, testing and navigation',
        '26.52.Z' => 'Manufacture of watches and clocks',
        '26.70.Z' => 'Manufacture of optical instruments and photographic equipment',
        '32.50.Z' => 'Manufacture of medical and dental instruments and supplies',
        '28.11.Z' => 'Manufacture of engines and turbines, except aircraft, vehicle and cycle engines',
        '28.12.Z' => 'Manufacture of fluid power equipment',
        '28.13.Z' => 'Manufacture of other pumps and compressors',
        '28.14.Z' => 'Manufacture of other taps and valves',
        '28.15.Z' => 'Manufacture of bearings, gears, gearing and driving elements',
        '28.21.Z' => 'Manufacture of ovens, furnaces and furnace burners',
        '28.22.Z' => 'Manufacture of lifting equipment and gripping devices',
        '28.23.Z' => 'Manufacture of office machinery and equipment, except computers and peripheral equipment',
        '28.24.Z' => 'Manufacture of power-driven hand tools',
        '28.25.Z' => 'Manufacture of industrial cooling and ventilation equipment',
        '28.29.Z' => 'Manufacture of other general-purpose machinery notelsewhere classified',
        '31.09.Z' => 'Manufacture of other furniture',
        '28.30.Z' => 'Manufacture of agricultural and forestry machinery',
        '28.41.Z' => 'Manufacture of metal forming machinery',
        '28.49.Z' => 'Manufacture of other mechanical tools',
        '28.91.Z' => 'Manufacture of machinery for metallurgy',
        '28.92.Z' => 'Manufacture of machinery for mining, quarrying and construction',
        '32.11.Z' => 'Striking of coins',
        '28.93.Z' => 'Manufacture of machinery for food, beverage and tobacco processing',
        '28.94.Z' => 'Manufacture of machinery for textile, apparel and leather production',
        '28.95.Z' => 'Manufacture of machinery for paper and paperboard production',
        '28.96.Z' => 'Manufacture of machinery forworking rubber or plastics and for manufacture of the articles from these materials',
        '28.99.Z' => 'Manufacture of other special-purpose machinery notelsewhere classified',
        '31.01.Z' => 'Manufacture of office and shop furniture',
        '31.02.Z' => 'Manufacture of kitchen furniture',
        '32.12.Z' => 'Manufacture of jewellery and related articles',
        '32.13.Z' => 'Manufacture of imitation jewellery and related articles',
        '32.20.Z' => 'Manufacture of musical instruments',
        '32.30.Z' => 'Manufacture of sports goods',
        '32.40.Z' => 'Manufacture of games and toys',
        '32.91.Z' => 'Manufacture of brooms and brushes',
        '32.99.Z' => 'Other manufacturing notelsewhere classified',
        '33.11.Z' => 'Repair and maintenance of fabricated metal products',
        '33.12.Z' => 'Repair and maintenance of machinery',
        '33.13.Z' => 'Repair and maintenance of electronic and optical equipment',
        '33.15.Z' => 'Repair and maintenance of ships and boats',
        '33.16.Z' => 'Repair and maintenance of aircraft and spacecraft',
        '35.11.Z' => 'Production of electricity',
        '33.14.Z' => 'Repair and maintenance of electrical equipment',
        '33.17.Z' => 'Repair and maintenance of other transport equipment',
        '33.19.Z' => 'Repair and maintenance of other equipment',
        '33.20.Z' => 'Installation of industrial machinery and equipment and outfit',
        '35.12.Z' => 'Transmission of electricity',
        '35.13.Z' => 'Distribution of electricity',
        '35.14.Z' => 'Trade of electricity',
        '35.21.Z' => 'Manufacture of gaseous fuels',
        '35.22.Z' => 'Distribution of gaseous fuels through mains',
        '35.23.Z' => 'Trade of gaseous fuels through mains',
        '43.32.Z' => 'Joinery installation',
        '35.30.Z' => 'Steam, hot water and air conditioning manufacturing and supply',
        '36.00.Z' => 'Water collection, treatment and supply',
        '37.00.Z' => 'Sewage disposal and treatment',
        '38.11.Z' => 'Collection of non-hazardous waste',
        '38.12.Z' => 'Collection of hazardous waste',
        '38.21.Z' => 'Treatment and disposal of non-hazardous waste',
        '38.22.Z' => 'Hazardous waste processing and neutralizing',
        '38.31.Z' => 'Dismantling of wrecks',
        '38.32.Z' => 'Recovery of sorted materials',
        '39.00.Z' => 'Remediation activities and other waste management services',
        '41.10.Z' => 'Realization of building projects related to erection of buildings',
        '41.20.Z' => 'Building works related to erection of residential and non-residential buildings',
        '42.11.Z' => 'Works related to construction of roads and motorways',
        '42.12.Z' => 'Works related to construction of railways and underground railways',
        '63.91.Z' => 'News agency activities',
        '42.13.Z' => 'Works related to construction of bridges and tunnels',
        '42.21.Z' => 'Works related to construction oftransmission pipelines and distribution networks',
        '42.22.Z' => 'Works related to construction of telecommunications and electricity lines',
        '42.91.Z' => 'Works related to construction of water projects',
        '42.99.Z' => 'Works related to construction of other civil engineering projects not elsewhere classified',
        '43.11.Z' => 'Demolition',
        '43.12.Z' => 'Site preparation',
        '43.13.Z' => 'Test drilling and boring',
        '43.21.Z' => 'Electrical installation',
        '43.22.Z' => 'Plumbing, heat and air-conditioning installation',
        '43.29.Z' => 'Other construction installation',
        '43.31.Z' => 'Plastering',
        '43.33.Z' => 'Floor and wall covering',
        '43.34.Z' => 'Painting and glazing',
        '43.39.Z' => 'Other building completion and finishing',
        '43.91.Z' => 'Roofing activities',
        '43.99.Z' => 'Other specialised construction activities not elsewhere classified',
        '45.11.Z' => 'Sale of cars and light motor vehicles',
        '45.19.Z' => 'Sale of other motor vehicles, excluding motorcycles',
        '47.81.Z' => 'Retail sale via stalls and markets of food, beverages and tobacco products',
        '45.20.Z' => 'Maintenance and repair of motor vehicles, excluding motorcycles',
        '45.31.Z' => 'Wholesale trade of motor vehicle parts and accessories, excluding motorcycles',
        '45.32.Z' => 'Retail trade of motor vehicle parts and accessories, excluding motorcycles',
        '45.40.Z' => 'Sale, maintenance and repair of motorcycles and related parts and accessories',
        '46.11.Z' => 'Agents involved in the sale of agricultural raw materials, live animals, textile raw materials and semi-finished goods',
        '46.12.Z' => 'Agents involved in the sale of fuels, ores, metals and industrial chemicals',
        '46.13.Z' => 'Agents involved in the sale of timber and building materials',
        '47.71.Z' => 'Retail sale of clothing in specialised stores',
        '46.14.Z' => 'Agents involved in the sale of machinery, industrial equipment, ships and aircraft',
        '46.15.Z' => 'Agents involved in the sale of furniture, household goods, hardware and ironmongery',
        '46.16.Z' => 'Agents involved in the sale of textiles, clothing, fur, footwear and leather goods',
        '46.17.Z' => 'Agents involved in the sale of food, beverages and tobacco',
        '46.18.Z' => 'Agents specialised in the sale of other particular products',
        '46.19.Z' => 'Agents involved in the sale of a variety of goods',
        '46.21.Z' => 'Wholesale of grain, unmanufactured tobacco, seeds and animal feeds',
        '46.22.Z' => 'Wholesale of flowers and plants',
        '46.23.Z' => 'Wholesale of live animals',
        '46.24.Z' => 'Wholesale of hides, skins and leather',
        '46.31.Z' => 'Wholesale of fruit and vegetables',
        '46.32.Z' => 'Wholesale of meat and meat products',
        '46.33.Z' => 'Wholesale of dairy products, eggs and edible oils and fats',
        '46.34.A' => 'Wholesale of alcoholic beverages',
        '46.34.B' => 'Wholesale of non-alcoholic beverages',
        '46.35.Z' => 'Wholesale of tobacco products',
        '46.43.Z' => 'Wholesale of electrical household appliances',
        '46.36.Z' => 'Wholesale of sugar and chocolate and sugar confectionery',
        '46.37.Z' => 'Wholesale of coffee, tea, cocoa and spices',
        '46.38.Z' => 'Wholesale of other food, including fish, crustaceans and molluscs',
        '46.39.Z' => 'Non-specialised wholesale of food, beverages and tobacco',
        '46.41.Z' => 'Wholesale of textiles',
        '46.42.Z' => 'Wholesale of clothing and footwear',
        '46.44.Z' => 'Wholesale of china, ceramics and glassware and cleaning materials',
        '46.46.Z' => 'Wholesale of pharmaceutical goods',
        '46.47.Z' => 'Wholesale of furniture, carpets and lighting equipment',
        '46.48.Z' => 'Wholesale of watches, clocks and jewellery',
        '46.49.Z' => 'Wholesale of other household goods',
        '46.51.Z' => 'Wholesale of computers, peripheral equipment and software',
        '46.52.Z' => 'Wholesale of electronic and telecommunications equipment and parts thereof',
        '46.61.Z' => 'Wholesale of agricultural machinery, equipment and supplies',
        '46.62.Z' => 'Wholesale of machine tools',
        '46.63.Z' => 'Wholesale of mining, construction and civil engineering machinery',
        '46.64.Z' => 'Wholesale of machinery for the textile industry and of sewing and knitting machines',
        '46.65.Z' => 'Wholesale of office furniture',
        '46.66.Z' => 'Wholesale of other office machinery and equipment',
        '46.69.Z' => 'Wholesale of other machinery and equipment',
        '46.71.Z' => 'Wholesale of fuels and related products',
        '46.72.Z' => 'Wholesale of metals and metal ores',
        '46.73.Z' => 'Wholesale of wood, construction materials and sanitary equipment',
        '46.74.Z' => 'Wholesale of hardware and plumbing and heating equipment and supplies',
        '47.59.Z' => 'Retail sale of furniture, lighting equipment and other household articles in specialised stores',
        '46.75.Z' => 'Wholesale of chemical products',
        '46.76.Z' => 'Wholesale of other intermediate products',
        '46.77.Z' => 'Wholesale of waste and scrap',
        '46.90.Z' => 'Non-specialised wholesale trade',
        '47.61.Z' => 'Retail sale of books in specialised stores',
        '47.62.Z' => 'Retail sale of newspapers and stationery in specialised stores',
        '47.11.Z' => 'Retail sale in non-specialised stores with food, beverages or tobacco predominating',
        '47.19.Z' => 'Other retail sale in non-specialised stores',
        '47.21.Z' => 'Retail sale of fruit and vegetables in specialised stores',
        '47.22.Z' => 'Retail sale of meat and meat products in specialised stores',
        '47.23.Z' => 'Retail sale of fish, crustaceans and molluscs in specialised stores',
        '47.24.Z' => 'Retail sale of bread, cakes, flour confectionery and sugar confectionery in specialised stores',
        '47.25.Z' => 'Retail sale of alcoholic and non-alcoholic beverages in specialised stores',
        '47.63.Z' => 'Retail sale of music and video recordings in specialised stores',
        '47.64.Z' => 'Retail sale of sporting equipment in specialised stores',
        '47.26.Z' => 'Retail sale of tobacco products in specialised stores',
        '47.29.Z' => 'Other retail sale of food in specialised stores',
        '47.30.Z' => 'Retail sale of fuel for motor vehicles in fuel stations',
        '47.41.Z' => 'Retail sale of computers, peripheral units and software in specialised stores',
        '47.42.Z' => 'Retail sale of telecommunications equipment in specialised stores',
        '47.43.Z' => 'Retail sale of audio and video equipment in specialised stores',
        '47.51.Z' => 'Retail sale of textiles in specialised stores',
        '47.52.Z' => 'Retail sale of hardware, paints and glass in specialised stores',
        '47.53.Z' => 'Retail sale of carpets, rugs, wall and floor coverings in specialised stores',
        '47.72.Z' => 'Retail sale of footwear and leather goods in specialised stores',
        '47.73.Z' => 'Dispensing chemist in specialised stores',
        '47.74.Z' => 'Retail sale of medical and orthopaedic goods in specialised stores',
        '47.75.Z' => 'Retail sale of cosmetic and toilet articles in specialised stores',
        '47.76.Z' => 'Retail sale of flowers, plants, seeds, fertilisers, pet animals and pet food in specialised stores',
        '47.77.Z' => 'Retail sale of watches, clocks and jewellery in specialised stores',
        '47.78.Z' => 'Other retail sale of new goods in specialised stores',
        '47.79.Z' => 'Retail sale of second-hand goods in specialised stores',
        '47.82.Z' => 'Retail sale via stalls and markets of textiles, clothing and footwear',
        '47.89.Z' => 'Retail sale via stalls and markets of other goods',
        '47.91.Z' => 'Retail sale via mail order houses or via Internet',
        '47.99.Z' => 'Other retail sale not in stores, stalls or markets',
        '49.10.Z' => 'Passenger rail transport, interurban',
        '49.20.Z' => 'Freight rail transport',
        '49.31.Z' => 'Urban and suburban passenger land transport',
        '49.32.Z' => 'Taxi operation',
        '49.39.Z' => 'Other passenger land transport not elsewhere classified',
        '49.41.Z' => 'Freight transport by road',
        '49.42.Z' => 'Removal services',
        '49.50.A' => 'Transport via pipeline of fuelgases',
        '49.50.B' => 'Transport via pipeline of othercommodities',
        '50.10.Z' => 'Sea and coastal passenger water transport',
        '50.20.Z' => 'Sea and coastal freight water transport',
        '50.30.Z' => 'Inland passenger water transport',
        '50.40.Z' => 'Inland freight water transport',
        '51.10.Z' => 'Passenger air transport',
        '51.21.Z' => 'Freight air transport',
        '51.22.Z' => 'Space transport',
        '52.10.A' => 'Warehousing and storage of fuel gases',
        '52.10.B' => 'Warehousing and storage of other goods',
        '52.29.C' => 'Other transportation agencies activities',
        '52.21.Z' => 'Service activities incidental to land transportation',
        '52.22.A' => 'Service activities incidental to sea transportation',
        '52.22.B' => 'Service activities incidental to inland transportation',
        '52.23.Z' => 'Service activities incidental to air transportation',
        '52.24.A' => 'Cargo handling in sea ports',
        '52.24.B' => 'Cargo handling in inland ports',
        '52.24.C' => 'Cargo handling in other reloading points',
        '52.29.A' => 'Sea transportation agencies activities',
        '52.29.B' => 'Inland transportation agencies activities',
        '58.21.Z' => 'Publishing of computer games',
        '53.10.Z' => 'Postal activities under universal service obligation (public operator)',
        '53.20.Z' => 'Other postal and courier activities',
        '55.10.Z' => 'Hotels and similar accommodation',
        '55.20.Z' => 'Holiday and other short-stay accommodation',
        '63.12.Z' => 'Web portals',
        '55.30.Z' => 'Camping grounds (including grounds for camping vehicles), and campsites',
        '55.90.Z' => 'Other accommodation',
        '56.10.A' => 'Restaurants and other eating places',
        '56.10.B' => 'Mobile eating places',
        '56.21.Z' => 'Event catering activities',
        '56.29.Z' => 'Other food service activities',
        '58.29.Z' => 'Other software publishing',
        '56.30.Z' => 'Beverage serving activities',
        '58.11.Z' => 'Book publishing',
        '58.12.Z' => 'Publishing of directories and registers (e.g. street, phone directory)',
        '58.13.Z' => 'Publishing of newspapers',
        '58.14.Z' => 'Publishing of journals and periodicals',
        '58.19.Z' => 'Other publishing activities',
        '59.11.Z' => 'Motion picture, video and television programme production activities',
        '59.12.Z' => 'Motion picture, video and television programme post-production activities',
        '59.13.Z' => 'Motion picture, video and television programme distribution activities',
        '59.14.Z' => 'Motion picture projection activities',
        '59.20.Z' => 'Sound recording and music publishing activities',
        '60.10.Z' => 'Radio broadcasting',
        '63.11.Z' => 'Data processing, hosting and related activities',
        '60.20.Z' => 'Public and licence television programmes broadcasting',
        '61.10.Z' => 'Wired telecommunications activities',
        '61.20.Z' => 'Wireless telecommunications activities, excluding satellite telecommunications activities',
        '61.30.Z' => 'Satellite telecommunications activities',
        '61.90.Z' => 'Other telecommunications activities',
        '63.99.Z' => 'Other information service activities not elsewhere classified',
        '62.01.Z' => 'Computer programming activities',
        '62.02.Z' => 'Computer consultancy activities',
        '62.03.Z' => 'Computer facilities management activities',
        '62.09.Z' => 'Other information technology and computer service activities',
        '64.11.Z' => 'Central banking',
        '64.19.Z' => 'Other monetary intermediation',
        '64.20.Z' => 'Activities of holding companies',
        '64.30.Z' => 'Trusts, funds and similar financial entities',
        '64.91.Z' => 'Financial leasing',
        '64.92.Z' => 'Other credit granting',
        '64.99.Z' => 'Other financial service activities, except insurance and pension funding not elsewhere classified',
        '65.11.Z' => 'Life insurance',
        '73.12.B' => 'Intermediation in the sale of the place on advertising aims in printed media',
        '65.12.Z' => 'Other personal and property insurance',
        '65.20.Z' => 'Reinsurance',
        '65.30.Z' => 'Pension funding',
        '66.11.Z' => 'Administration of financial markets',
        '66.12.Z' => 'Security and commodity contracts brokerage',
        '66.19.Z' => 'Other activities auxiliary to financial services, except insurance and pension funding',
        '66.21.Z' => 'Risk and damage evaluation',
        '66.22.Z' => 'Activities of insurance agents and brokers',
        '66.29.Z' => 'Other activities auxiliary to insurance and pension funding',
        '66.30.Z' => 'Fund management activities',
        '68.10.Z' => 'Buying and selling of own real estate',
        '68.20.Z' => 'Rental and operating of own or leased real estate',
        '68.31.Z' => 'Real estate agencies',
        '73.12.C' => 'Intermediation in the sale of the place on advertising aims in electronic media (Internet)',
        '68.32.Z' => 'Management of real estate on a fee or contract basis',
        '69.10.Z' => 'Legal activities',
        '69.20.Z' => 'Accounting, bookkeeping and auditing activities; tax consultancy',
        '70.10.Z' => 'Activities of head office and holding companies, excluding financial holding companies',
        '70.21.Z' => 'Public relations and communication activities',
        '73.12.D' => 'Intermediation in the sale of the place on advertising aims in other media',
        '70.22.Z' => 'Business and other management consultancy activities',
        '71.11.Z' => 'Architectural activities',
        '71.12.Z' => 'Engineering activities and related technical consultancy',
        '71.20.A' => 'Food quality testing and analysis',
        '71.20.B' => 'Other technical testing and analysis',
        '73.20.Z' => 'Market research and public opinion polling',
        '74.10.Z' => 'Specialised design activities',
        '72.11.Z' => 'Research and experimental development on biotechnology',
        '72.19.Z' => 'Other research and experimental development on natural sciences and engineering',
        '72.20.Z' => 'Research and experimental development on social sciences and humanities',
        '73.11.Z' => 'Advertising agencies activities',
        '73.12.A' => 'Intermediation in the sale of time and place on advertising aims in the radio and television',
        '74.20.Z' => 'Photographic activities',
        '74.30.Z' => 'Translation and interpretation activities',
        '74.90.Z' => 'Other professional, scientific and technical activities not elsewhere classified',
        '75.00.Z' => 'Veterinary activities',
        '77.11.Z' => 'Rental and leasing of cars and light motor vehicles',
        '77.12.Z' => 'Rental and leasing of other motor vehicle, excluding motorcycles',
        '77.21.Z' => 'Rental and leasing of recreational and sports goods',
        '77.22.Z' => 'Rental of video tapes and CDs, DVDs etc.',
        '77.29.Z' => 'Rental and leasing of other personal and household goods',
        '77.31.Z' => 'Rental and leasing of agricultural machinery and equipment',
        '77.32.Z' => 'Rental and leasing of construction machinery and equipment',
        '77.33.Z' => 'Rental and leasing of office machinery and equipment, including computers',
        '77.34.Z' => 'Rental and leasing of water transport equipment',
        '77.35.Z' => 'Rental and leasing of air transport equipment',
        '77.39.Z' => 'Rental and leasing of other machinery, equipment and tangible goods not elsewhere classified',
        '79.11.B' => 'Tour middlemen activities',
        '77.40.Z' => 'Leasing of intellectual property and similar products, except copyrighted works',
        '78.10.Z' => 'Activities of employment placement agencies',
        '78.20.Z' => 'Temporary employment agency activities',
        '78.30.Z' => 'Other human resources provision',
        '79.11.A' => 'Tour agents activities',
        '79.12.Z' => 'Tour operator activities',
        '79.90.A' => 'Couriers on package tours and tour guides activities',
        '79.90.B' => 'Tourist information activities',
        '79.90.C' => 'Other reservation service activities not elsewhere classified',
        '80.10.Z' => 'Private security activities, excluding security systems service activities',
        '80.20.Z' => 'Security systems service activities',
        '80.30.Z' => 'Investigation activities',
        '81.10.Z' => 'Działalność pomocnicza związana z utrzymaniem porządku w budynkach',
        '81.21.Z' => 'General cleaning of buildings',
        '81.22.Z' => 'Specialised building and industrial cleaning activities',
        '81.29.Z' => 'Other cleaning activities',
        '81.30.Z' => 'Landscape service activities',
        '82.11.Z' => 'Office administrative service activities',
        '82.19.Z' => 'Photocopying, document preparation and other specialised office support activities',
        '82.20.Z' => 'Activities of call centres',
        '82.30.Z' => 'Organisation of conventions and trade shows',
        '82.91.Z' => 'Activities of collection agencies and credit bureaus',
        '82.92.Z' => 'Packaging activities',
        '85.42.Z' => 'Szkoły wyższe',
        '82.99.Z' => 'Other business support service activities not elsewhere classified',
        '84.11.Z' => 'General public administration activities',
        '84.12.Z' => 'Regulation of the activities of providing health care, education, cultural services and other social services, excluding social security',
        '84.13.Z' => 'Regulation of and contribution to more efficient operation of businesses',
        '84.21.Z' => 'Foreign affairs',
        '84.22.Z' => 'Defence activities',
        '84.23.Z' => 'Justice and judicial activities',
        '84.24.Z' => 'Public order and safety activities',
        '84.25.Z' => 'Fire service activities',
        '84.30.Z' => 'Compulsory social security activities',
        '85.10.Z' => 'Pre-primary education',
        '85.20.Z' => 'Primary education',
        '85.31.A' => 'Lower secondary schools',
        '85.31.B' => 'General upper secondary schools',
        '85.32.A' => 'Technical secondary schools',
        '85.32.B' => 'Basic vocational schools',
        '85.32.C' => 'Special job-training schools',
        '85.32.D' => 'Branżowe szkoły II stopnia',
        '85.41.A' => 'Szkoły policealne',
        '85.41.B' => 'Kolegia pracowników służb społecznych',
        '85.41.C' => 'Placówki doskonalenia nauczycieli',
        '85.51.Z' => 'Out-of-school forms of sports and leisure education',
        '85.52.Z' => 'Out-of-school forms of cultural education',
        '85.53.Z' => 'Out-of- school forms of driving education',
        '85.59.A' => 'Teaching of foreign languages',
        '85.59.B' => 'Other out-of-school forms of education, not elsewhere classified',
        '85.60.Z' => 'Educational support activities',
        '95.12.Z' => 'Repair and maintenance of (tele)communication equipment',
        '86.10.Z' => 'Działalność szpitali',
        '86.21.Z' => 'General medical practice activities',
        '86.22.Z' => 'Specialist medical practice activities',
        '86.23.Z' => 'Dental practice activities',
        '86.90.A' => 'Physiotherapeutical activities',
        '95.21.Z' => 'Repair and maintenance of consumer electronics',
        '86.90.B' => 'Emergency ambulance activities',
        '86.90.C' => 'Nurses and midwives activities',
        '86.90.D' => 'Paramedical activities',
        '86.90.E' => 'Other human health activities notelsewhere classified',
        '87.10.Z' => 'Pomoc społeczna z zakwaterowaniem zapewniająca opiekę pielęgniarską',
        '87.20.Z' => 'Residential care activities for mental retardation, mental health and substance abuse',
        '87.30.Z' => 'Residential care activities for the elderly and disabled',
        '96.04.Z' => 'Physical well-being activities',
        '87.90.Z' => 'Other residential care activities',
        '88.10.Z' => 'Social work activities without accommodation for the elderly and disabled',
        '88.91.Z' => 'Child day-care activities',
        '88.99.Z' => 'Other social work activities without accommodation notelsewhere classified',
        '90.01.Z' => 'Performing arts activities',
        '90.02.Z' => 'Support activities to performing arts',
        '90.03.Z' => 'Artistic creation activities',
        '90.04.Z' => 'Operation of arts facilities',
        '91.01.A' => 'Library activities',
        '91.01.B' => 'Archives activities',
        '91.02.Z' => 'Museums activities',
        '91.03.Z' => 'Operation of historical sites and buildings and similar visitor attractions',
        '91.04.Z' => 'Botanical and zoological gardens and nature reserves activities',
        '92.00.Z' => 'Gambling and betting activities',
        '93.11.Z' => 'Operation of sports facilities',
        '93.12.Z' => 'Activities of sports clubs',
        '93.13.Z' => 'Operation of fitness facilities',
        '93.19.Z' => 'Other sports activities',
        '93.21.Z' => 'Activities of amusement parks and theme parks',
        '93.29.Z' => 'Other amusement and recreation activities',
        '94.11.Z' => 'Activities of commercial and employers organisations',
        '94.12.Z' => 'Activities of professional organisations',
        '94.20.Z' => 'Activities of trade unions',
        '94.91.Z' => 'Activities of religious organisations',
        '94.92.Z' => 'Activities of political organisations',
        '94.99.Z' => 'Activities of other membership organisations not elsewhere classified',
        '95.11.Z' => 'Repair and maintenance of computers and peripheral equipment',
        '95.22.Z' => 'Repair and maintenance of household appliances and home and garden equipment',
        '95.23.Z' => 'Repair of footwear and leather goods',
        '95.24.Z' => 'Repair and maintenance of furniture and home furnishings',
        '95.25.Z' => 'Repair of watches, clocks and jewellery',
        '95.29.Z' => 'Repair of other personal and household goods',
        '96.01.Z' => 'Washing and (dry-)cleaning of textile and fur products',
        '96.02.Z' => 'Hairdressing and other beauty treatment',
        '96.03.Z' => 'Funeral and related activities',
        '96.09.Z' => 'Other personal service activities not elsewhere classified',
        '97.00.Z' => 'Households as employers of domestic personnel',
        '98.10.Z' => 'Goods-producing activities of private households for own use',
        '98.20.Z' => 'Service-producing activities of private households for own use',
        '99.00.Z' => 'Extraterritorial organisations and bodies'
    };
}