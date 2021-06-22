public class CreditFactoryWebCrediconnect {
    public static final String CREDIT_SYSTEM_NAME = 'CrediconnectCH';


    /*******************************************************************************
    *  Name            : generateSearchRequest(String endpoint, String userName, String password,String recordName,
                                               String recordStreet, String recordCity, String recordHousenumber,
                                               String recordPostalCode)
    *  Summary         : Generate HTTP Request to Crediconnect.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : String endpoint - from CreditSystem custom setting, String userName - from CreditSystem custom setting,
                         String password - from CreditSystem custom setting, String recordName - company name for search,
                         String uid - uid for search, String recordCity - company city for search
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password, Map<String, String> searchParametersMap) {
        try {
            String body = generateSearchXML(userName, password, searchParametersMap);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', 'http://crediconnect.ch/V2/02/CrediConnectWebservice/GetHitListEx');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setBody(body);
            request.setTimeout(60000);
            // url that returns the XML in the response body
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            System.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Search request failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateSearchXML()
    *  Summary         : Generate XML String to call Crediconnect search.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : String userName - from CreditSystem custom setting, String password - from CreditSystem custom setting,
                         String opportunityName - company name for search, String uid - uid (vat number) for search, String recordCity - company city for search
    *  Returns         : String
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, Map<String, String> searchParametersMap) {
        String vatNumber, opportunityName, registeredCity;
        if (searchParametersMap.containsKey('vatNumber') && ! String.isEmpty(searchParametersMap.get('vatNumber'))) {
            vatNumber = searchParametersMap.get('vatNumber').replace('-', '').replace('.', '');
        }

        if (searchParametersMap.containsKey('name') && ! String.isEmpty(searchParametersMap.get('name'))) {
            opportunityName = searchParametersMap.get('name').replace('&', ' ');
        }

        if (searchParametersMap.containsKey('registeredCity') && ! String.isEmpty(searchParametersMap.get('registeredCity'))) {
            registeredCity = searchParametersMap.get('registeredCity');
        }

        String xmlbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://crediconnect.ch/V2/02/" xmlns:ns1="http://schemas.creditreform.ch/2017/05">' +
           '<soapenv:Header>' +
                '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
                    '<wsse:UsernameToken>' +
                        '<wsse:Username>' + userName + '</wsse:Username>' +
                        '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + password + '</wsse:Password>' +
                        //2018-08-08T06:21:01.632Z
                        '<wsu:Created>' + datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '</wsu:Created>' +
                    '</wsse:UsernameToken>' +
                '</wsse:Security>' +
           '</soapenv:Header>' +
                '<soapenv:Body>' +
                    '<ns:GetHitListEx>' +
                        '<ns:searchedAddress>' +
                            ((vatNumber != null) ?
                                '<ns1:UID>' + vatNumber + '</ns1:UID>' : '') +
                            ((opportunityName != null) ?
                                '<ns1:Name>' + opportunityName + '</ns1:Name>' : '') +
                            ((registeredCity != null) ?
                                '<ns1:City>' + registeredCity + '</ns1:City>' : '') +
                            '<ns1:Country>CH</ns1:Country>' +
                        '</ns:searchedAddress>' +
                        '<ns:searchFilter>' +
                            '<ns1:ArchiveType>Business Active</ns1:ArchiveType>' +
                            '<ns1:MatchLevel>' + ((vatNumber != null && vatNumber != '') ? 'Regular' : 'Low') + '</ns1:MatchLevel>' +
                        '</ns:searchFilter>' +
                    '</ns:GetHitListEx>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : returnSearchResponse(Dom.XMLNode node)
    *  Summary         : Return Body DOM element.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnSearchResponse(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'GetHitListExResponse') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'GetHitListExResult') {
                                return responseField;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnErrorMessage(Dom.XMLNode node)
    *  Summary         : Return Error message if search response body of xml is null.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'fault') {
                        for (Dom.XMLNode faultField : bodyField.getChildElements()) {
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
    *  Name            : returnSearchedCompanies(Dom.XMLNode node)
    *  Summary         : Return searched companies list.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchedCompanies(Dom.XMLNode node) {
        try {
            List<CreditFactoryCompany> companiesFromSearch = new List<CreditFactoryCompany>();
            for (Dom.XMLNode responseField : node.getChildElements()) {
                if (responseField.getName() == 'HitListItem') {
                    CreditFactoryCompany company = new CreditFactoryCompany();
                    for (Dom.XMLNode hitListItemField : responseField.getChildElements()) {
                        if (hitListItemField.getName() == 'CrefoID') {
                            company.identificationnumber = hitListItemField.getText();
                            company.creditSystemCompanyNumber = hitListItemField.getText();
                        } else if (hitListItemField.getName() == 'StatusCode') {
                            company.status = hitListItemField.getText();
                        } else if (hitListItemField.getName() == 'Address') {
                            for (Dom.XMLNode addressField : hitListItemField.getChildElements()) {
                                if (addressField.getName() == 'Name') {
                                    company.name = addressField.getText();
                                } else if (addressField.getName() == 'AddressLine1') {
                                    company.street = addressField.getText();
                                } else if (addressField.getName() == 'HouseNr') {
                                    company.housenumber = addressField.getText();
                                } else if (addressField.getName() == 'PostalCode') {
                                    company.postcode = addressField.getText();
                                } else if (addressField.getName() == 'City') {
                                    company.city = addressField.getText();
                                }
                            }
                        }
                    }
                    companiesFromSearch.add(company);
                }
            }

            return companiesFromSearch;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Search Company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateReportRequest(String endpoint, String userName, String password, String companyId)
    *  Summary         : Generate HTTP Request to Crediconnect.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : String endpoint - from CreditSystem custom setting, String userName - from CreditSystem custom setting,
                         String password - from CreditSystem custom setting, String companyId - Id of Credit System Company (from finder page)
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String companyId) {
        try {
            String body = generateReportXML(userName, password, companyId);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '"http://crediconnect.ch/V2/02/CrediConnectWebservice/GetReport"');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setBody(body);
            request.setTimeout(120000);
            // url that returns the XML in the response body
            request.setEndpoint(endpoint);
            request.setMethod('POST');

            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Report request failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateReportXML(String userName, String password, String companyId)
    *  Summary         : Generate XML String to call CreditReform report.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : userName - from CreditSystem custom setting, password - from CreditSystem custom setting,
                         companyId - Id of Credit System Company (from finder page)
    *  Returns         : String
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String companyId) {
        String xmlbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://crediconnect.ch/V2/02/" xmlns:ns1="http://schemas.creditreform.ch/2017/05">' +
             '<soapenv:Header>' +
                '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
                    '<wsse:UsernameToken>' +
                        '<wsse:Username>' + userName + '</wsse:Username>' +
                        '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + password + '</wsse:Password>' +
                        //2018-08-08T06:21:01.632Z
                        '<wsu:Created>' + datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '</wsu:Created>' +
                    '</wsse:UsernameToken>' +
                '</wsse:Security>' +
           '</soapenv:Header>' +
            '<soapenv:Body>' +
                '<ns:GetReport>' +
                    '<ns:crefoID>' + companyId + '</ns:crefoID>' +
                    '<ns:orderReport>' +
                        '<ns1:ProductCode>07</ns1:ProductCode>' +
                        '<ns1:ReportFormat>PDF</ns1:ReportFormat>' +
                        '<ns1:ReportLanguage>EN</ns1:ReportLanguage>' +
                        '<ns1:TermsOfExecution>Void</ns1:TermsOfExecution>' +
                        '<ns1:ReasonOfInquiry>Creditworthiness</ns1:ReasonOfInquiry>' +
                    '</ns:orderReport>' +
                '</ns:GetReport>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : clearReportXml(String xml)
    *  Summary         : Remove CDATA characters
    *  CreatedDate     : 25/11/2020
    *  Parameters      : String xml - response body xml
    *  Returns         : String
    ******************************************************************************/
    public static String clearReportXml(String xml) {
        Pattern p = Pattern.compile('<!\\[CDATA\\[(.*?)\\]\\]>');
        Matcher m = p.matcher(xml);
        while (m.find()) {
            xml = xml.replace(m.group(), m.group(1));
        }

        return xml;
    }


    /*******************************************************************************
    *  Name            : returnReportBody(Dom.XMLNode node)
    *  Summary         : Return Body DOM element.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnReportBody(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'GetReportResponse') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'GetReportResult') {
                                return responseField;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnReportCompany(Dom.XMLNode node)
    *  Summary         : Return Company.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XMLNode node, String creditSystemCompanyNumber, String country) {
        try {
            CreditFactoryCompany selectedCompany = new CreditFactoryCompany();
            selectedCompany.creditFactoryContacts = returnReportCompanyEmployees(node);
            selectedCompany.creditSystemCompanyNumber = creditSystemCompanyNumber;
            selectedCompany.classRating = returnClassRating(node);
            selectedCompany.turnOver = returnTurnOver(node);
            selectedCompany.legalForm = returnLegalForm(node);
            selectedCompany.vatNumber = returnVatId(node);
            selectedCompany.taxId = returnTaxNumber(node);
            selectedCompany.staffCompanyRange = returnStaffCompanyRange(node);
            selectedCompany.creditLimit = returnCreditLimit(node);
            if (selectedCompany.creditLimit != null) {
                selectedCompany.creditLimitCurrency = 'CHF';
            }
            selectedCompany.creditDecision = returnCreditDecision(node);
            selectedCompany.dateOfFoundation = returnDateOfFoundation(node);
            selectedCompany.ageOfCompany = returnAgeofcompany(node);
            selectedCompany.status = returnStatus(node);
            selectedCompany.name = returnName(node);
            selectedCompany.street = returnStreet(node);
            selectedCompany.houseNumber = returnHousenumber(node);
            selectedCompany.postCode = returnPostcode(node);
            selectedCompany.city = returnCity(node);
            selectedCompany.country = country;
            selectedCompany.phone = returnPhone(node);
            selectedCompany.fax = returnFax(node);
            selectedCompany.mobile = returnMobile(node);
            selectedCompany.email = returnEmail(node);
            selectedCompany.website = returnWebsite(node);
            selectedCompany.identificationNumber = creditSystemCompanyNumber;
            selectedCompany.paidUpShareCapital = returnShareCapital(node);
            selectedCompany.paidUpShareCapitalCurrency = returnShareCapitalCurrency(node);
            selectedCompany.solvencyIndex = returnSolvencyIndex(node);
            selectedCompany.dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(node);
            selectedCompany.dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(node);
            selectedCompany.dateOfLastChangeOfName = returnDateOfLastChangeOfName(node);
            selectedCompany.recordType = 'Default';
            return selectedCompany;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnClassRating(Dom.XMLNode reportBody)
    *  Summary         : Return Class Rating.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnClassRating(Dom.XMLNode reportBody) {
        for (Dom.XMLNode reportBodyField : reportBody.getChildElements()) {
            if (reportBodyField.getName() == 'CustomizedKeyValues') {
                for (Dom.XMLNode customizedKeyValuesField : reportBodyField.getChildElements()) {
                    if (customizedKeyValuesField.getName() == 'KeyValue') {
                        String keyName;
                        for (Dom.XMLNode keyValueField : customizedKeyValuesField.getChildElements()) {
                            if (keyValueField.getName() == 'Key') {
                                keyName = keyValueField.getText();
                            } else if (keyValueField.getName() == 'Value' && keyName == 'Score') {
                                return CreditFactoryGlobalUtils.returnRatingBasedOnSolvency(keyValueField.getText(), 'Switzerland');
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnTurnOver(Dom.XMLNode reportBody)
    *  Summary         : Return Turn Over.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnTurnOver(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'ExtendedProductContent') {
                for (Dom.XMLNode extendedProductContentField : bodyField.getChildElements()) {
                    if (extendedProductContentField.getName() == 'Turnover') {
                        for (Dom.XMLNode turnOverField : extendedProductContentField.getChildren()) {
                            if (turnOverField.getName() == 'Amount') {
                                return turnOverField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnLegalForm(Dom.XMLNode reportBody)
    *  Summary         : Return Legal Form.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnLegalForm(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode basicContentField : bodyField.getChildElements()) {
                    if (basicContentField.getName() == 'LegalForm') {
                        for (Dom.XMLNode legalFormField : basicContentField.getChildren()) {
                            if (legalFormField.getName() == 'Description') {
                                return legalFormField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnVatId(Dom.XMLNode reportBody)
    *  Summary         : Return Vat Id.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnVatId(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode productContentField : bodyField.getChildElements()) {
                    if (productContentField.getName() == 'UID') {
                        return productContentField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnTaxNumber(Dom.XMLNode reportBody)
    *  Summary         : Return Tax Number.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnTaxNumber(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode productContentField : bodyField.getChildElements()) {
                    if (productContentField.getName() == 'HrNr') {
                        return productContentField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnStaffCompanyRange(Dom.XMLNode reportBody)
    *  Summary         : Return Number of employees.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'ExtendedProductContent') {
                for (Dom.XMLNode extendedProductContentField : bodyField.getChildElements()) {
                    if (extendedProductContentField.getName() == 'Employees') {
                        for (Dom.XMLNode employeesField : extendedProductContentField.getChildren()) {
                            if (employeesField.getName() == 'Count') {
                                return employeesField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditLimit(Dom.XMLNode node)
    *  Summary         : Return Credit Limit.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditLimit(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'ProductContent') {
                for (Dom.XMLNode productContentField : bodyField.getChildElements()) {
                    if (productContentField.getName() == 'CreditLimit') {
                        return productContentField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditDecision(Dom.XMLNode node)
    *  Summary         : Return Credit Decision.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditDecision(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'ProductContent') {
                for (Dom.XMLNode productContentField : bodyField.getChildElements()) {
                    if (productContentField.getName() == 'CreditJudgement') {
                        return productContentField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDateOfFoundation(Dom.XMLNode node)
    *  Summary         : Return Date of Foundation.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateOfFoundation(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode basicContentField : bodyField.getChildElements()) {
                    if (basicContentField.getName() == 'DateOfRegistry') {
                        return basicContentField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnAgeOfCompany(Dom.XMLNode node)
    *  Summary         : Return Age of company.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnAgeOfCompany(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode basicContentField : bodyField.getChildElements()) {
                    if (basicContentField.getName() == 'Foundation' && basicContentField.getText() != null && basicContentField.getText().isNumeric()) {
                        return String.valueOf(Date.today().Year() - Integer.valueOf(basicContentField.getText()));
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnStatus(Dom.XMLNode node)
    *  Summary         : Return Company Status.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStatus(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode basicContentField : bodyField.getChildElements()) {
                    if (basicContentField.getName() == 'Status') {
                        return basicContentField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnName(Dom.XMLNode node)
    *  Summary         : Return Company name.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnName(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'Name') {
                        return addressField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnStreet(Dom.XMLNode reportBody)
    *  Summary         : Return Street.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStreet(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                String street1;
                String street2;
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'AddressLine1') {
                        street1 = addressField.getText();
                    } else if (addressField.getName() == 'AddressLine2') {
                        street2 = addressField.getText();
                    }
                }

                return (street2 + ', ' + street1).removeStart(', ').removeEnd(', ');
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnHousenumber(Dom.XMLNode reportBody)
    *  Summary         : Return House Number.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnHousenumber(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'HouseNr') {
                        return addressField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPostcode(Dom.XMLNode reportBody)
    *  Summary         : Return Postal code.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostcode(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'PostalCode') {
                        return addressField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCity(Dom.XMLNode reportBody)
    *  Summary         : Return City.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCity(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'City') {
                        return addressField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPhone(Dom.XMLNode reportBody)
    *  Summary         : Return Phone.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPhone(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'Communication') {
                        for (Dom.XMLNode communicationField : addressField.getChildren()) {
                            if (communicationField.getName() == 'Phone1') {
                                return communicationField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnFax(Dom.XMLNode reportBody)
    *  Summary         : Return Fax.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnFax(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'Communication') {
                        for (Dom.XMLNode communicationField : addressField.getChildren()) {
                            if (communicationField.getName() == 'Fax') {
                                return communicationField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnMobile(Dom.XMLNode reportBody)
    *  Summary         : Return Phone.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnMobile(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'Communication') {
                        for (Dom.XMLNode communicationField : addressField.getChildren()) {
                            if (communicationField.getName() == 'Phone2') {
                                return communicationField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnEmail(Dom.XMLNode reportBody)
    *  Summary         : Return Email.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnEmail(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'Communication') {
                        for (Dom.XMLNode communicationField : addressField.getChildren()) {
                            if (communicationField.getName() == 'Email') {
                                return communicationField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnWebsite(Dom.XMLNode reportBody)
    *  Summary         : Return Website.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnWebsite(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'Address') {
                for (Dom.XMLNode addressField : bodyField.getChildElements()) {
                    if (addressField.getName() == 'Communication') {
                        for (Dom.XMLNode communicationField : addressField.getChildren()) {
                            if (communicationField.getName() == 'Url') {
                                return communicationField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnShareCapital(Dom.XMLNode reportBody)
    *  Summary         : Return Paid Up Capital.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnShareCapital(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode basicContentField : bodyField.getChildElements()) {
                    if (basicContentField.getName() == 'Capitals') {
                        for (Dom.XMLNode capitalsField : basicContentField.getChildren()) {
                            if (capitalsField.getName() == 'Capital') {
                                String description;
                                for (Dom.XMLNode capitalField : capitalsField.getChildElements()) {
                                    if (capitalField.getName() == 'Description') {
                                        description = capitalField.getText();
                                    } else if (description == 'Share capital' && capitalField.getName() == 'Amount') {
                                        return capitalField.getText();
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
    *  Name            : returnShareCapitalCurrency(Dom.XMLNode reportBody)
    *  Summary         : Return Paid Up Capital Currency.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnShareCapitalCurrency(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'BasicContent') {
                for (Dom.XMLNode basicContentField : bodyField.getChildElements()) {
                    if (basicContentField.getName() == 'Capitals') {
                        for (Dom.XMLNode capitalsField : basicContentField.getChildren()) {
                            if (capitalsField.getName() == 'Capital') {
                                String description;
                                for (Dom.XMLNode capitalField : capitalsField.getChildElements()) {
                                    if (capitalField.getName() == 'Description') {
                                        description = capitalField.getText();
                                    } else if (description == 'Share capital' && capitalField.getName() == 'Currency') {
                                        return capitalField.getText();
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
    *  Name            : returnBlobBody(Dom.XMLNode reportBody)
    *  Summary         : Return blob body.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnBlobBody(Dom.XMLNode reportBody) {
        for (Dom.XMLNode bodyField : reportBody.getChildElements()) {
            if (bodyField.getName() == 'ReportData') {
                return bodyField.getText();
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnSolvencyIndex(Dom.XMLNode reportBody)
    *  Summary         : Return Solvency Index.
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnSolvencyIndex(Dom.XMLNode reportBody) {
        for (Dom.XMLNode reportBodyField : reportBody.getChildElements()) {
            if (reportBodyField.getName() == 'CustomizedKeyValues') {
                for (Dom.XMLNode customizedKeyValuesField : reportBodyField.getChildElements()) {
                    if (customizedKeyValuesField.getName() == 'KeyValue') {
                        String keyName;
                        for (Dom.XMLNode keyValueField : customizedKeyValuesField.getChildElements()) {
                            if (keyValueField.getName() == 'Key') {
                                keyName = keyValueField.getText();
                            } else if (keyValueField.getName() == 'Value' && keyName == 'Score') {
                                return keyValueField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnReportCompanyEmployees(Dom.XMLNode node)
    *  Summary         : Return Company Employees
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XMLNode reportBody - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnReportCompanyEmployees(Dom.XMLNode reportBody) {
        List<CreditFactoryCompany.CreditFactoryContact> companyEmployeesList = new List<CreditFactoryCompany.CreditFactoryContact>();
        for (Dom.XMLNode reportBodyField : reportBody.getChildElements()) {
            if (reportBodyField.getName() == 'CustomizedKeyValues') {
                for (Dom.XMLNode customizedKeyValuesField : reportBodyField.getChildElements()) {
                    if (customizedKeyValuesField.getName() == 'KeyValue') {
                        String keyName;
                        for (Dom.XMLNode keyValueField : customizedKeyValuesField.getChildElements()) {
                            if (keyValueField.getName() == 'Key') {
                                keyName = keyValueField.getText();
                            } else if (keyValueField.getName() == 'Value' && keyName == 'AuthorisedSignatories') {
                                Dom.Document domDoc = new Dom.Document();
                                domDoc.load(keyValueField.getText());
                                Dom.XMLNode xmldom = domDoc.getRootElement();
                                for (Dom.XMLNode valueField : xmldom.getChildElements()) {
                                    if (valueField.getName() == 'AuthorisedSignatory') {
                                        CreditFactoryCompany.CreditFactoryContact employee = new CreditFactoryCompany.CreditFactoryContact();
                                        for (Dom.XMLNode authorisedSignatoryField : valueField.getChildElements()) {
                                            if (authorisedSignatoryField.getName() == 'CrefoID') {
                                                employee.id = authorisedSignatoryField.getText();
                                            } else if (authorisedSignatoryField.getName() == 'Name') {
                                                employee.name = authorisedSignatoryField.getText();
                                            } else if (authorisedSignatoryField.getName() == 'name') {
                                                employee.name = authorisedSignatoryField.getText();
                                            } else if (authorisedSignatoryField.getName() == 'Firstname') {
                                                if (employee.name != null) {
                                                    employee.name = authorisedSignatoryField.getText() + ' ' + employee.name;
                                                } else {
                                                    employee.name = authorisedSignatoryField.getText();
                                                }
                                            } else if (authorisedSignatoryField.getName() == 'Position') {
                                                employee.type = authorisedSignatoryField.getText();
                                            }

                                            employee.recordType = 'Default';
                                        }
                                        companyEmployeesList.add(employee);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return companyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfDirector(Dom.XMLNode node)
    *  Summary         : Return Date Of Last Change Of Company Director
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XmlNode reportBody - body from response
    *  Returns         : Dom.XmlNode
    ******************************************************************************/
    public static String returnDateOfLastChangeOfDirector(Dom.XmlNode reportBody) {
        String dateOfLastChangeOfDirector;
        for (Dom.XmlNode reportBodyField : reportBody.getChildElements()) {
            if (reportBodyField.getName() == 'CustomizedKeyValues') {
                for (Dom.XmlNode customizedKeyValuesField : reportBodyField.getChildElements()) {
                    if (customizedKeyValuesField.getName() == 'KeyValue') {
                        String keyName;
                        for (Dom.XmlNode keyValueField : customizedKeyValuesField.getChildElements()) {
                            if (keyValueField.getName() == 'Key') {
                                keyName = keyValueField.getText();
                            } else if (keyValueField.getName() == 'Value' && keyName == 'AuthorisedSignatories') {
                                Dom.Document domDoc = new Dom.Document();
                                domDoc.load(keyValueField.getText());
                                Dom.XmlNode xmldom = domDoc.getRootElement();
                                for (Dom.XmlNode valueField : xmldom.getChildElements()) {
                                    if (valueField.getName() == 'AuthorisedSignatory') {
                                        String lastDateMonth;
                                        String lastDateYear;
                                        for (Dom.XmlNode authorisedSignatoryField : valueField.getChildElements()) {
                                            if (authorisedSignatoryField.getName() == 'Since') {
                                                String currentLoopDate = authorisedSignatoryField.getText();
                                                if (currentLoopDate != null && currentLoopDate.length() == 7) {
                                                    String currentLoopMonth = currentLoopDate.substring(0, 2);
                                                    String currentLoopYear = currentLoopDate.substring(3, 7);
                                                    if (currentLoopYear > lastDateYear || currentLoopYear == lastDateYear && currentLoopMonth > lastDateMonth) {
                                                        lastDateMonth = currentLoopMonth;
                                                        lastDateYear = currentLoopYear;
                                                        dateOfLastChangeOfDirector = currentLoopDate;
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
            }
        }

        return dateOfLastChangeOfDirector;
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfAddress(Dom.XMLNode node)
    *  Summary         : Return Date Of Last Change Of Company Address
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XmlNode reportBody - body from response
    *  Returns         : Dom.XmlNode
    ******************************************************************************/
    public static String returnDateOfLastChangeOfAddress(Dom.XmlNode reportBody) {
        String dateOfLastChangeOfAddress;
        for (Dom.XmlNode reportBodyField : reportBody.getChildElements()) {
            if (reportBodyField.getName() == 'CustomizedKeyValues') {
                for (Dom.XmlNode customizedKeyValuesField : reportBodyField.getChildElements()) {
                    if (customizedKeyValuesField.getName() == 'KeyValue') {
                        String keyName;
                        for (Dom.XmlNode keyValueField : customizedKeyValuesField.getChildElements()) {
                            if (keyValueField.getName() == 'Key') {
                                keyName = keyValueField.getText();
                            } else if (keyValueField.getName() == 'Value' && keyName == 'NameAndDomicileChanges') {
                                Dom.Document domDoc = new Dom.Document();
                                domDoc.load(keyValueField.getText());
                                Dom.XmlNode xmldom = domDoc.getRootElement();
                                for (Dom.XmlNode valueField : xmldom.getChildElements()) {
                                    if (valueField.getName() == 'NameAndDomicileChange') {
                                        String lastDateMonth;
                                        String lastDateYear;
                                        String alteration;
                                        for (Dom.XmlNode nameAndDomicileChangeField : valueField.getChildElements()) {
                                            if (nameAndDomicileChangeField.getName() == 'Alteration') {
                                                alteration = nameAndDomicileChangeField.getText();
                                            } else if (alteration != null && alteration.contains('3') && nameAndDomicileChangeField.getName() == 'From') {
                                                String currentLoopDate = nameAndDomicileChangeField.getText();
                                                if (currentLoopDate != null && currentLoopDate.length() == 7) {
                                                    String currentLoopMonth = currentLoopDate.substring(0, 2);
                                                    String currentLoopYear = currentLoopDate.substring(3, 7);
                                                    if (dateOfLastChangeOfAddress == null || currentLoopYear > lastDateYear || currentLoopYear == lastDateYear && currentLoopMonth > lastDateMonth) {
                                                        lastDateMonth = currentLoopMonth;
                                                        lastDateYear = currentLoopYear;
                                                        dateOfLastChangeOfAddress = currentLoopDate;
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
            }
        }

        return dateOfLastChangeOfAddress;
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfName(Dom.XMLNode node)
    *  Summary         : Return Date Of Last Change Of Company Name
    *  CreatedDate     : 25/11/2020
    *  Parameters      : Dom.XmlNode reportBody - body from response
    *  Returns         : Dom.XmlNode
    ******************************************************************************/
    public static String returnDateOfLastChangeOfName(Dom.XmlNode reportBody) {
        String dateOfLastChangeOfName;
        for (Dom.XmlNode reportBodyField : reportBody.getChildElements()) {
            if (reportBodyField.getName() == 'CustomizedKeyValues') {
                for (Dom.XmlNode customizedKeyValuesField : reportBodyField.getChildElements()) {
                    if (customizedKeyValuesField.getName() == 'KeyValue') {
                        String keyName;
                        for (Dom.XmlNode keyValueField : customizedKeyValuesField.getChildElements()) {
                            if (keyValueField.getName() == 'Key') {
                                keyName = keyValueField.getText();
                            } else if (keyValueField.getName() == 'Value' && keyName == 'NameAndDomicileChanges') {
                                Dom.Document domDoc = new Dom.Document();
                                domDoc.load(keyValueField.getText());
                                Dom.XmlNode xmldom = domDoc.getRootElement();
                                for (Dom.XmlNode valueField : xmldom.getChildElements()) {
                                    if (valueField.getName() == 'NameAndDomicileChange') {
                                        String lastDateMonth;
                                        String lastDateYear;
                                        String alteration;
                                        for (Dom.XmlNode nameAndDomicileChangeField : valueField.getChildElements()) {
                                            if (nameAndDomicileChangeField.getName() == 'Alteration') {
                                                alteration = nameAndDomicileChangeField.getText();
                                            } else if (alteration!= null && alteration.contains('2') && nameAndDomicileChangeField.getName() == 'From') {
                                                String currentLoopDate = nameAndDomicileChangeField.getText();
                                                if (currentLoopDate != null && currentLoopDate.length() == 7) {
                                                    String currentLoopMonth = currentLoopDate.substring(0, 2);
                                                    String currentLoopYear = currentLoopDate.substring(3, 7);
                                                    if (dateOfLastChangeOfName == null || currentLoopYear > lastDateYear || currentLoopYear == lastDateYear && currentLoopMonth > lastDateMonth) {
                                                        lastDateMonth = currentLoopMonth;
                                                        lastDateYear = currentLoopYear;
                                                        dateOfLastChangeOfName = currentLoopDate;
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
            }
        }

        return dateOfLastChangeOfName;
    }
}