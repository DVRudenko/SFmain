public class CreditFactoryWebCoface {

    /*******************************************************************************
    *  Summary         : Generate HTTP Request to Coface
    *  CreatedDate     : 15/10/2020 by Anton Buzak
    *  Parameters      : endpoint - search endpoint, userName - Coface account name,
                         password - coface account password, searchParametersMap - parameters for searching
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password,
                                                    Map<String, String> searchParametersMap) {
        String body = generateSearchXML(userName, password, searchParametersMap);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', '');
        if (searchParametersMap.containsKey('taxId') && ! String.isBlank(searchParametersMap.get('taxId'))) {
            request.setHeader('SOAPAction', 'http://www.iconx.biz/webservices/searchByIdentifier');
        } else {
            request.setHeader('SOAPAction', 'http://www.iconx.biz/webservices/searchByNameAndAddress');
        }
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        return request;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate XML String
    *  CreatedDate     : 15/10/2020 by Anton Buzak
    *  Parameters      : userName - Coface account name, 
                         password - Coface account password, 
                         searchParametersMap - parameters for searching
    *  Returns         : search string
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, Map<String, String> searchParametersMap) {
        String opportunityName;
        if (searchParametersMap.containsKey('name') && ! String.isEmpty(searchParametersMap.get('name'))) {
            opportunityName = searchParametersMap.get('name').replace('&', ' ');    
        }

        String nationalId;
        if (searchParametersMap.containsKey('taxId') && ! String.isBlank(searchParametersMap.get('taxId'))) {
            String taxId = searchParametersMap.get('taxId');
            if (taxId.length() >= 8) {
                nationalId = taxId.substring(0, 8);
            }
            else {
                nationalId = taxId;
            }
        }

        String xmlBody =
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://www.iconx.biz/webservices">' +
                '<soapenv:Header>' +
                    '<web:AuthHeader>' +
                        '<web:Username>' + userName + '</web:Username>' +
                        '<web:Password>' + password + '</web:Password>' +
                    '</web:AuthHeader>' +
               '</soapenv:Header>' +
               '<soapenv:Body>' +
                    (nationalId == null
                    ?
                    '<web:searchByNameAndAddress>' +
                        '<web:Name>' + opportunityName + '</web:Name>' +
                        '<web:Country>HU</web:Country>' +
                        ((searchParametersMap.containsKey('registeredPostCode') && ! String.isEmpty(searchParametersMap.get('registeredPostCode'))) ?
                            '<web:ZipCode>' + searchParametersMap.get('registeredPostCode') + '</web:ZipCode>' : '') +
                        ((searchParametersMap.containsKey('registeredCity') && ! String.isEmpty(searchParametersMap.get('registeredCity'))) ?
                            '<web:City>' + searchParametersMap.get('registeredCity') + '</web:City>' : '') +
                        '<web:MaxResults>100</web:MaxResults>' +
                    '</web:searchByNameAndAddress>'
                    :
                    '<web:searchByIdentifier>' +
                        '<web:Country>HU</web:Country>' +
                        '<web:Identifier>' + nationalId + '</web:Identifier>' +
                        '<web:TypeOfIdentifier>0</web:TypeOfIdentifier>' +
                        '<web:MaxResults>100</web:MaxResults>' +
                    '</web:searchByIdentifier>') +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 15/10/2020 by Anton Buzak
    *  Parameters      : node - response node
    *  Returns         : body node
    ******************************************************************************/
    public static Dom.XmlNode returnGlobalBody(Dom.XmlNode node) {
        if (node.getName() == 'Envelope') {
            for (Dom.XmlNode child : node.getChildElements()) {
                if (child.getName() == 'Body') {
                    return child;
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return companies
    *  CreatedDate     : 15/10/2020 by Anton Buzak
    *  Parameters      : envelopeNode - node from response
    *  Returns         : companies list
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchedCompanies(Dom.XmlNode bodyNode) {
        List<CreditFactoryCompany> companiesList = new List<CreditFactoryCompany>();
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'searchByNameAndAddressResponse' ||
                bodyChildNode.getName() == 'searchByIdentifierResponse') {
                for (Dom.XmlNode searchByResponseChildNode : bodyChildNode.getChildElements()) {
                    if (searchByResponseChildNode.getName() == 'searchByNameAndAddressResult' ||
                        searchByResponseChildNode.getName() == 'searchByIdentifierResult') {
                        for (Dom.XmlNode searchByResultChildNode : searchByResponseChildNode.getChildElements()) {
                            if (searchByResultChildNode.getName() == 'SearchResults') {
                                for (Dom.XmlNode searchResultsChildNode : searchByResultChildNode.getChildElements()) {
                                    if (searchResultsChildNode.getName() == 'SearchResult') {
                                        CreditFactoryCompany company = new CreditFactoryCompany();
                                        for (Dom.XmlNode searchResultChildNode : searchResultsChildNode.getChildElements()) {
                                            if (searchResultChildNode.getName() == 'Name') {
                                                company.name = searchResultChildNode.getText();
                                            }

                                            if (searchResultChildNode.getName() == 'InternalID') {
                                                company.creditSystemCompanyNumber = searchResultChildNode.getText();
                                                company.identificationNumber = searchResultChildNode.getText();
                                            }

                                            if (searchResultChildNode.getName() == 'SortName') {
                                                company.tradeName = searchResultChildNode.getText();
                                            }

                                            if (searchResultChildNode.getName() == 'Address') {
                                                for (Dom.XmlNode address : searchResultChildNode.getChildElements()) {
                                                    company.street = '';

                                                    if (address.getName() == 'AddressItem1') {
                                                        company.street = address.getText();
                                                    }
                                                    if (address.getName() == 'AddressItem2') {
                                                        company.street = company.street + '\n' + address.getText();
                                                    }
                                                    if (address.getName() == 'City') {
                                                        company.city = address.getText();
                                                    }
                                                    if (address.getName() == 'ZipCode') {
                                                        company.postCode = address.getText();
                                                    }
                                                }
                                            }

                                            if (searchResultChildNode.getName() == 'Identifiers') {
                                                for (Dom.XmlNode identifiersNode : searchResultChildNode.getChildElements()) {
                                                    if (identifiersNode.getName() == 'CompanyIdentifier') {
                                                        String idType;
                                                        String idValue;
                                                        for (Dom.XmlNode companyIdentifier : identifiersNode.getChildElements()) {
                                                            if (companyIdentifier.getName() == 'Type') {
                                                                idType = companyIdentifier.getText();
                                                            }
                                                            else if (companyIdentifier.getName() == 'Identifier') {
                                                                idValue = companyIdentifier.getText();
                                                            }
                                                        }

                                                        if (idType == '0') {
                                                            company.nationalId = idValue;
                                                        }
                                                        else if (idType == '120') {
                                                            company.taxId = idValue;
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        companiesList.add(company);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return companiesList;
    }


    /*******************************************************************************
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : endpoint - Coface endpoint url, userName - Coface account name,
                         password - Coface password, companyId - parameter value from search page
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generateRequestForCheckAvailability(String endpoint, String userName, String password, String companyId) {
        HttpRequest request = new HttpRequest();
        String xmlBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://www.iconx.biz/webservices">' +
            '<soapenv:Header>' +
                '<web:AuthHeader>' +
                    '<web:Username>' + userName + '</web:Username>' +
                    '<web:Password>' + password + '</web:Password>' +
                '</web:AuthHeader>' +
            '</soapenv:Header>' +
            '<soapenv:Body>' +
                '<web:getCompanyDetails>' +
                    '<web:InternalID>' + companyId + '</web:InternalID>' +
                '</web:getCompanyDetails>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';
        request.setBody(xmlBody);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setTimeout(30000);
        request.setEndpoint(endpoint);
        request.setHeader('SOAPAction', 'http://www.iconx.biz/webservices/getCompanyDetails');
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Summary         : Parse response and check if report 761 exist
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      :
    *  Returns         : is 761 product exist or not
    ******************************************************************************/
    public static Boolean isCreditReportAvailable(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'getCompanyDetailsResponse') {
                for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                    if (responseChildNode.getName() == 'getCompanyDetailsResult') {
                        for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                            if (resultChildNode.getName() == 'ResponseCode' && resultChildNode.getText() == 'NotFound') {
                                return false;
                            }

                            if (resultChildNode.getName() == 'CompanyDetails') {
                                for (Dom.XmlNode companyDetailsChildNode : resultChildNode.getChildElements()) {
                                    if (companyDetailsChildNode.getName() == 'AvailableProducts') {
                                        for (Dom.XmlNode availableProductsChildNode : companyDetailsChildNode.getChildElements()) {
                                            if (availableProductsChildNode.getName() == 'Product') {
                                                for (Dom.XmlNode productChildNode : availableProductsChildNode.getChildElements()) {
                                                    if (productChildNode.getName() == 'Code' &&
                                                        productChildNode.getText() == '761' &&
                                                        availableProductsChildNode.getChildElements().size() == 3 &&
                                                        availableProductsChildNode.getChildElements().get(1).getText() == 'AUTOMATIC CREDIT REPORT' &&
                                                        availableProductsChildNode.getChildElements().get(2).getText() == 'AvailableImmediately') {
                                                        return true;
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

        return false;
    }


    /*******************************************************************************
    *  Summary         : generate HTTP Request to Coface to get XML report
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : endpoint - Coface endpoint,
                         userName - Coface user name,
                         password - Coface password,
                         companyId - Id of Credit System Company
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password,
                                                    String companyId) {
        String body = generateReportXML(userName, password, companyId);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'http://www.iconx.biz/webservices/immediateOrder');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call Coface 9997 report
    *  CreatedDate     : 21/02/2018
    *  Parameters      : userName - from CreditSystem custom setting,
                         password - from CreditSystem custom setting,
                         companyId - Id of Credit System Company (from finder page)
    *  Returns         : String
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String companyId) {
        String xmlbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://www.iconx.biz/webservices">' +
            '<soapenv:Header>' +
                '<web:AuthHeader>' +
                    '<web:Username>' + userName + '</web:Username>' +
                    '<web:Password>' + password + '</web:Password>' +
                '</web:AuthHeader>' +
            '</soapenv:Header>' +
            '<soapenv:Body>' +
                '<web:immediateOrder>' +
                    '<web:InternalID>' + companyId + '</web:InternalID>' +
                    '<web:ReportMimeType>text/xml</web:ReportMimeType>' +
                    '<web:Language>EN</web:Language>' +
                    '<web:ProductCode>761</web:ProductCode>' +
                '</web:immediateOrder>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';

        return xmlbody;
    }


    /*******************************************************************************
    *  Summary         : check fault response
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : node - node from body
    *  Returns         : rue if is valid and false if not
    ******************************************************************************/
    public static Boolean checkResponseForFault(Dom.XmlNode node) {
        for (Dom.XmlNode fault : node.getChildElements()) {
            if (fault.getName() == 'Fault') {
                return false;
            }
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : Return Company object
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : Dom.XmlNode
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XmlNode bodyNode, String creditSystemCompanyNumber) {
        Dom.XmlNode reportNode = returnInnerXmlReport(bodyNode);
        CreditFactoryCompany selectedCompany = new CreditFactoryCompany();
        selectedCompany.country = 'Hungary';
        selectedCompany.creditSystemCompanyNumber = creditSystemCompanyNumber;
        selectedCompany.recordType = 'Default';
        selectedCompany.creditFactoryContacts = new List<CreditFactoryCompany.CreditFactoryContact>();
        selectedCompany.referenceNumber = returnReferenceNumber(reportNode);
        selectedCompany.classRating = returnRating(reportNode);
        selectedCompany.turnOver = returnTurnOver(reportNode);
        selectedCompany.legalForm = returnLegalForm(reportNode);
        String vatId = returnVatId(reportNode);
        String taxNumber = returnTaxNumber(reportNode);
        if (vatId != null) {
            selectedCompany.vatNumber = vatId;
        }
        else if (taxNumber != null) {
            selectedCompany.vatNumber = 'HU' + taxNumber.substring(0, 8);
        }

        selectedCompany.taxId = taxNumber;
        selectedCompany.tradeRegisterNumber = returnRegisterId(reportNode);
        selectedCompany.dateLegalForm = returnDateLegalForm(reportNode);
        selectedCompany.registerNumber = selectedCompany.tradeRegisterNumber;
        selectedCompany.dateLastRegisterEntry = returnDateLastRegisterEntry(reportNode);
        selectedCompany.staffCompanyRange = returnStaffCompanyRange(reportNode);
        selectedCompany.creditLimit = returnCreditLimit(reportNode);
        selectedCompany.creditLimitCurrency = returnCreditLimitCurrency(reportNode);
        selectedCompany.dateOfFoundation = returnDateLegalForm(reportNode);
        selectedCompany.status = returnStatus(reportNode);
        selectedCompany.name = returnName(bodyNode);
        selectedCompany.tradeName = returnTradeName(bodyNode);
        selectedCompany.street = returnStreet(reportNode);
        selectedCompany.houseNumber = returnHouseNumber(reportNode);
        selectedCompany.postCode = returnPostcode(reportNode);
        selectedCompany.city = returnCity(reportNode);
        selectedCompany.phone = returnPhone(reportNode);
        selectedCompany.fax = returnFax(reportNode);
        selectedCompany.email = returnEmail(reportNode);
        selectedCompany.website = returnWebsite(reportNode);
        selectedCompany.principalActivityCode = returnPrincipalActivityCode(reportNode);
        if (selectedCompany.principalActivityCode != null) {
            selectedCompany.principalActivityCode = selectedCompany.principalActivityCode.replaceAll('[^0-9]', '');
        }

        selectedCompany.principalActivityDescription = returnPrincipalActivityDescription(reportNode);
        if (selectedCompany.dateOfFoundation != null) {
            if (selectedCompany.dateOfFoundation.length() == 10) {
                selectedCompany.ageOfCompany = String.valueOf(Date.today().year() - Integer.valueOf(selectedCompany.dateOfFoundation.substring(6,10)));
            } else if (selectedCompany.dateOfFoundation.length() == 4) {
                selectedCompany.ageOfCompany = String.valueOf(Date.today().year() - Integer.valueOf(selectedCompany.dateOfFoundation.substring(0,4)));
            }
        }
        selectedCompany.identificationNumber = creditSystemCompanyNumber;
        selectedCompany.dateOfLastMajorUpdate = returnDateOfLastMajorUpdate(reportNode);
        selectedCompany.yearOfLastFinancialInformation = returnYearOfLastFinancialInformation(reportNode);
        selectedCompany.profitLossLastYear = returnProfitLossLastYear(reportNode);
        selectedCompany.profitLossYearBeforeLast = returnProfitLossYearBeforeLast(reportNode);
        selectedCompany.turnOverLastYear = returnTurnOverLastYear(reportNode);
        if (selectedCompany.profitLossLastYear == null || selectedCompany.profitLossYearBeforeLast == null || selectedCompany.turnOverLastYear == null) {
            Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
            if (org.IsSandbox) {
                selectedCompany.profitLossLastYear = '100000';
                selectedCompany.profitLossYearBeforeLast = '100000';
                selectedCompany.turnOverLastYear = '300000000';
            }
        }
        selectedCompany.pitCurrency = 'HUF';
        selectedCompany.creditFactoryContacts = returnReportCompanyEmployees(reportNode);

        return selectedCompany;
    }



    /*******************************************************************************
    *  Summary         : Return xml report node
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : report xml dom
    ******************************************************************************/
    public static Dom.XmlNode returnInnerXmlReport(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'immediateOrderResponse' || bodyChildNode.getName() == 'getCompanyReportResponse') {
                for (Dom.XmlNode responseBodyChildNode : bodyChildNode.getChildElements()) {
                    if (responseBodyChildNode.getName() == 'immediateOrderResult' || responseBodyChildNode.getName() == 'getCompanyReportResult') {
                        for (Dom.XmlNode resultChildNode : responseBodyChildNode.getChildElements()) {
                            if (resultChildNode.getName() == 'Report') {
                                for (Dom.XmlNode reportChildNode : resultChildNode.getChildElements()) {
                                    if (reportChildNode.getName() == 'ReportXML') {
                                        return reportChildNode;
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
    *  Summary         : Return street
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : street
    ******************************************************************************/
    public static String returnStreet(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'STREET') {
                                                        return addressChildNode.getText();
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return house number
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : house number
    ******************************************************************************/
    public static String returnHouseNumber(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'HOUSENUMBER') {
                                                        return addressChildNode.getText();
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return post code
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : house number
    ******************************************************************************/
    public static String returnPostcode(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'ZIPCODE') {
                                                        return addressChildNode.getText();
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return city
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : city
    ******************************************************************************/
    public static String returnCity(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'CITY') {
                                                        return addressChildNode.getText();
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return phone
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : phone
    ******************************************************************************/
    public static String returnPhone(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'TELEPHONE') {
                                                        String phone = '+';
                                                        for (Dom.XmlNode phoneChildNode : addressChildNode.getChildElements()) {
                                                            phone += phoneChildNode.getText();
                                                        }

                                                        return phone;
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return fax
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : phone
    ******************************************************************************/
    public static String returnFax(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'FAX') {
                                                        String phone = '+';
                                                        for (Dom.XmlNode faxChildNode : addressChildNode.getChildElements()) {
                                                            phone += faxChildNode.getText();
                                                        }

                                                        return phone;
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return email
    *  CreatedDate     : 16/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : email
    ******************************************************************************/
    public static String returnEmail(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'EMAIL') {
                                                        return addressChildNode.getText();
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return website
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : website
    ******************************************************************************/
    public static String returnWebsite(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'ADDRESSES') {
                                        for (Dom.XmlNode addressesChildNode : companyChildNode.getChildElements()) {
                                            if (addressesChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : addressesChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() != 'Principal Address') {
                                                       break;
                                                    }
                                                    else if (addressChildNode.getName() == 'ADDRESSTYPE' && addressChildNode.getText() == 'Principal Address') {
                                                        continue;
                                                    }

                                                    if (addressChildNode.getName() == 'INTERNET') {
                                                        return addressChildNode.getText();
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return name
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : name
    ******************************************************************************/
    public static String returnName(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'immediateOrderResponse' || bodyChildNode.getName() == 'getCompanyReportResponse') {
                for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                    if (responseChildNode.getName() == 'immediateOrderResult' || responseChildNode.getName() == 'getCompanyReportResult') {
                        for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                            if (resultChildNode.getName() == 'Report') {
                                for (Dom.XmlNode reportChildNode : resultChildNode.getChildElements()) {
                                    if (reportChildNode.getName() == 'Company') {
                                        for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                            if (companyChildNode.getName() == 'Name') {
                                                return companyChildNode.getText();
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
    *  Summary         : Return trade name
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : trade name
    ******************************************************************************/
    public static String returnTradeName(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'immediateOrderResponse' || bodyChildNode.getName() == 'getCompanyReportResponse') {
                for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                    if (responseChildNode.getName() == 'immediateOrderResult' || responseChildNode.getName() == 'getCompanyReportResult') {
                        for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                            if (resultChildNode.getName() == 'Report') {
                                for (Dom.XmlNode reportChildNode : resultChildNode.getChildElements()) {
                                    if (reportChildNode.getName() == 'Company') {
                                        for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                            if (companyChildNode.getName() == 'SortName') {
                                                return companyChildNode.getText();
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
    *  Summary         : Return trade name
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : trade name
    ******************************************************************************/
    public static String returnVatId(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'UNSTRUCTURED' && reportChildNode.getText().contains('International VAT number: ') && reportChildNode.getText().substringAfter('International VAT number: ').contains('\n')) {
                                return reportChildNode.getText().substringBetween('International VAT number: ','\n');
                            }
                        }
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return register Id
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : register id
    ******************************************************************************/
    public static String returnRegisterId(Dom.XmlNode node) {
        for (Dom.XmlNode bodyChildNode : node.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'REGISTRATION') {
                                        for (Dom.XmlNode registrationChildNode : companyChildNode.getChildElements()) {
                                            if (registrationChildNode.getName() == 'NUMBER') {
                                                return registrationChildNode.getText();
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
    *  Summary         : Return credit limit
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : credit limit
    ******************************************************************************/
    public static String returnCreditLimit(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'MAXIMUMCREDIT') {
                                for (Dom.XmlNode creditChildNode : reportChildNode.getChildElements()) {
                                    if (creditChildNode.getName() == 'INDICATOR') {
                                        for (Dom.XmlNode indicatorChildNode : creditChildNode.getChildElements()) {
                                            if (indicatorChildNode.getName() == 'FROMAMOUNT') {
                                                return indicatorChildNode.getText();
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
    *  Summary         : Return staff company range
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : staff company range
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'WORKFORCE') {
                                for (Dom.XmlNode workforceChildNode : reportChildNode.getChildElements()) {
                                    if (workforceChildNode.getName() == 'INDICATOR') {
                                        String range = '';
                                        for (Dom.XmlNode indicatorChildNode : workforceChildNode.getChildElements()) {
                                            if (indicatorChildNode.getName() == 'FROMAMOUNT') {
                                                range = indicatorChildNode.getText();

                                            }
                                            if (indicatorChildNode.getName() == 'TOAMOUNT') {
                                                if (indicatorChildNode.getText() != null && indicatorChildNode.getText() != '') {
                                                    range = range + '-' + indicatorChildNode.getText();
                                                }
                                                return range;
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
    *  Summary         : Return credit limit currency
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : credit limit currency
    ******************************************************************************/
    public static String returnCreditLimitCurrency(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'MAXIMUMCREDIT') {
                                for (Dom.XmlNode creditChildNode : reportChildNode.getChildElements()) {
                                    if (creditChildNode.getName() == 'INDICATOR') {
                                        for (Dom.XmlNode indicatorChildNode : creditChildNode.getChildElements()) {
                                            if (indicatorChildNode.getName() == 'CURRENCY') {
                                                return indicatorChildNode.getText();
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
    *  Summary         : Return turn over
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : turn over
    ******************************************************************************/
    public static String returnTurnOver(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'UNSTRUCTURED' && reportChildNode.getText().contains('Net sales revenue ')) {
                                String turnOverXml = reportChildNode.getText().substringBetween('Net sales revenue ','\n');
                                if (turnOverXml != null && turnOverXml.contains(',') && turnOverXml.substringAfter(',').length() >= 2) {
                                    turnOverXml = turnOverXml.replace('.', '');
                                    turnOverXml = ((turnOverXml.substringBefore(',') + '.' + turnOverXml.substringAfter(',').substring(0, 2)).replaceAll(' ', ''));
                                    if (reportChildNode.getText().contains('Amounts shown in Euro (EUR) Thousand')) {
                                        return String.valueOf((Decimal.valueOf(turnOverXml) * 1000 * 310).setScale(2));
                                    } else if (reportChildNode.getText().contains('Amounts shown in Euro (EUR)')) {
                                        return String.valueOf((Decimal.valueOf(turnOverXml) * 310).setScale(2));
                                    } else if (reportChildNode.getText().contains('Amounts shown in Hungarian Forint (HUF) Thousand')) {
                                        return String.valueOf((Decimal.valueOf(turnOverXml) * 1000).setScale(2));
                                    } else if (reportChildNode.getText().contains('Amounts shown in Hungarian Forint (HUF)')) {
                                        return String.valueOf((Decimal.valueOf(turnOverXml)).setScale(2));
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
    *  Summary         : Return date last register entity
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : date last register entity
    ******************************************************************************/
    public static String returnDateLastRegisterEntry(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'UNSTRUCTURED' && reportChildNode.getText().contains('Activity status:')) {
                                String lastEntryXml = reportChildNode.getText().substringBetween('Activity status:','\n');
                                lastEntryXml = lastEntryXml.replaceAll(' ', '');
                                return lastEntryXml;
                            }
                        }
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return date legal form
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : date legal form
    ******************************************************************************/
    public static String returnDateLegalForm(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'UNSTRUCTURED' && reportChildNode.getText().contains('Legal Form:')) {
                                String dateLegalFormXml = reportChildNode.getText().substringBetween('Legal Form:','\n');
                                dateLegalFormXml = dateLegalFormXml.replaceAll(' ', '');
                                if (! dateLegalFormXml.isAlpha()) {
                                    return dateLegalFormXml;
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
    *  Summary         : Return tax number
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : tax number
    ******************************************************************************/
    public static String returnTaxNumber(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'VATNUMBER') {
                                        for (Dom.XmlNode vatNumberChildNode : companyChildNode.getChildElements()) {
                                            if (vatNumberChildNode.getName() == 'VALUE') {
                                                String taxId = vatNumberChildNode.getText();
                                                return taxId;
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
    *  Summary         : Return status
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : status
    ******************************************************************************/
    public static String returnStatus(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'STATUS') {
                                        return companyChildNode.getText();
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
    *  Summary         : Return legal form
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : legal form
    ******************************************************************************/
    public static String returnLegalForm(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'LEGALFORM') {
                                        return companyChildNode.getText();
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
    *  Summary         : Return reference number
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : reference number
    ******************************************************************************/
    public static String returnReferenceNumber(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyChildNode : reportChildNode.getChildElements()) {
                                    if (companyChildNode.getName() == 'EASYNUMBER') {
                                        return companyChildNode.getText();
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
    *  Summary         : Return rating
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : rating
    ******************************************************************************/
    public static String returnRating(Dom.XmlNode bodyNode) {
        String classRating;
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'CCEATRATING') {
                                for (Dom.XmlNode ratingChildNode : reportChildNode.getChildElements()) {
                                    if (ratingChildNode.getName() == 'SCORE') {
                                        classRating = ratingChildNode.getAttribute('VALUE', null);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return classRating;
    }


    /*******************************************************************************
    *  Summary         : Return date of last major update
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : date of last major update
    ******************************************************************************/
    public static String returnDateOfLastMajorUpdate(Dom.XmlNode bodyNode) {
        String dateOfLastMajorUpdate;
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode creditReportField : iconChildNode.getChildElements()) {
                            if (creditReportField.getName() == 'COMPANY') {
                                for (Dom.XmlNode companyField : creditReportField.getChildElements()) {
                                    if (companyField.getName() == 'LASTMAJORUPDATE') {
                                        dateOfLastMajorUpdate = companyField.getText();
                                    }
                                }
                            }
                        }

                        if (dateOfLastMajorUpdate == null) {
                            for (Dom.XmlNode reportField : iconChildNode.getChildElements()) {
                                if (reportField.getName() == 'CCEATRATING') {
                                    for (Dom.XmlNode ratingField : reportField.getChildElements()) {
                                        if (ratingField.getName() == 'DATE') {
                                            dateOfLastMajorUpdate = ratingField.getText();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return dateOfLastMajorUpdate;
    }


    /*******************************************************************************
    *  Summary         : Return profit/loss last year
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : profit/loss last year
    ******************************************************************************/
    public static String returnProfitLossLastYear(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode ICON : bodyNode.getChildElements()) {
            if (ICON.getName() == 'ICON') {
                for (Dom.XmlNode CREDITREPORT : ICON.getChildElements()) {
                    if (CREDITREPORT.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode COMPANY : CREDITREPORT.getChildElements()) {
                            if (COMPANY.getName() == 'UNSTRUCTURED') {
                                if (COMPANY.getText().contains('FINANCIAL INFORMATION')) {
                                    String financialInformation = COMPANY.getText().substringAfter('FINANCIAL INFORMATION');
                                    String currencyDescription;
                                    Decimal k;
                                    if (financialInformation.contains('Amounts shown in Euro (EUR) Thousand')) {
                                        currencyDescription = 'Amounts shown in Euro (EUR) Thousand';
                                        k = 1000 * 310;
                                    } else if (financialInformation.contains('Amounts shown in Euro (EUR)')) {
                                        currencyDescription = 'Amounts shown in Euro (EUR)';
                                        k = 310;
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF) Thousand')) {
                                        currencyDescription = 'Amounts shown in Hungarian Forint (HUF) Thousand';
                                        k = 1000;
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF)')) {
                                        currencyDescription = 'Amounts shown in Hungarian Forint (HUF)';
                                        k = 1;
                                    }
                                    List<String> yearsList = new List<String>();
                                    if (currencyDescription != null && financialInformation.contains(currencyDescription + '\n') &&
                                            financialInformation.substringAfter(currencyDescription + '\n').contains('\n')) {
                                        String yearsString = financialInformation.substringBetween(currencyDescription + '\n', '\n').deleteWhitespace().replaceAll('[0-9]{2}[.]', '');
                                        for (Integer i=0; i<yearsString.length(); i+=4) {
                                            if (yearsString.length() >= i+4) {
                                                yearsList.add(yearsString.substring(i, i+4));
                                            }
                                        }
                                        String profitLoss;
                                        if (financialInformation.contains('Operating ( trading )')) {
                                            profitLoss = 'Operating ( trading )';
                                        } else if (financialInformation.contains('Operating result')) {
                                            profitLoss = 'Operating result';
                                        }
                                        if (profitLoss != null && financialInformation.contains(profitLoss) && financialInformation.substringAfter(profitLoss).contains('\n')) {
                                            String amountsString = financialInformation.substringBetween(profitLoss, '\n').deleteWhitespace().replace('.', '');
                                            Integer numberOfYearsAgo;
                                            for (String year : yearsList) {
                                                if (year == String.valueOf(Date.today().year() - 1)) {
                                                    numberOfYearsAgo = 1;
                                                }
                                            }

                                            if (numberOfYearsAgo == null) {
                                                numberOfYearsAgo = 2;
                                            }

                                            for (String year : yearsList) {
                                                if (amountsString.contains(',') && amountsString.substringAfter(',').length() >= 2) {
                                                    String amount = amountsString.substringBefore(',') + '.' + amountsString.substringAfter(',').substring(0, 2);
                                                    if (year == String.valueOf(Date.today().year() - numberOfYearsAgo)) {
                                                        return String.valueOf(Decimal.valueOf(amount) * k);
                                                    } else {
                                                        amountsString = amountsString.substring(amount.length(), amountsString.length());
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return profit/loss for year before last
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : profit/loss for year before last
    ******************************************************************************/
    public static String returnProfitLossYearBeforeLast(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'UNSTRUCTURED') {
                                if (reportChildNode.getText().contains('FINANCIAL INFORMATION')) {
                                    String financialInformation = reportChildNode.getText().substringAfter('FINANCIAL INFORMATION');
                                    String currencyDescription;
                                    Decimal k;
                                    if (financialInformation.contains('Amounts shown in Euro (EUR) Thousand')) {
                                        currencyDescription = 'Amounts shown in Euro (EUR) Thousand';
                                        k = 1000 * 310;
                                    } else if (financialInformation.contains('Amounts shown in Euro (EUR)')) {
                                        currencyDescription = 'Amounts shown in Euro (EUR)';
                                        k = 310;
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF) Thousand')) {
                                        currencyDescription = 'Amounts shown in Hungarian Forint (HUF) Thousand';
                                        k = 1000;
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF)')) {
                                        currencyDescription = 'Amounts shown in Hungarian Forint (HUF)';
                                        k = 1;
                                    }
                                    List<String> yearsList = new List<String>();
                                    if (currencyDescription != null && financialInformation.contains(currencyDescription + '\n') &&
                                            financialInformation.substringAfter(currencyDescription + '\n').contains('\n')) {
                                        String yearsString = financialInformation.substringBetween(currencyDescription + '\n', '\n').deleteWhitespace().replaceAll('[0-9]{2}[.]', '');
                                        for (Integer i=0; i<yearsString.length(); i+=4) {
                                            if (yearsString.length() >= i+4) {
                                                yearsList.add(yearsString.substring(i, i+4));
                                            }
                                        }
                                        String profitLoss;
                                        if (financialInformation.contains('Operating ( trading )')) {
                                            profitLoss = 'Operating ( trading )';
                                        } else if (financialInformation.contains('Operating result')) {
                                            profitLoss = 'Operating result';
                                        }
                                        if (profitLoss != null && financialInformation.contains(profitLoss) && financialInformation.substringAfter(profitLoss).contains('\n')) {
                                            String amountsString = financialInformation.substringBetween(profitLoss, '\n').deleteWhitespace().replace('.', '');
                                            Integer numberOfYearsAgo;
                                            for (String year : yearsList) {
                                                if (year == String.valueOf(Date.today().year() - 1)) {
                                                    numberOfYearsAgo = 2;
                                                }
                                            }

                                            if (numberOfYearsAgo == null) {
                                                numberOfYearsAgo = 3;
                                            }

                                            for (String year : yearsList) {
                                                if (amountsString.contains(',') && amountsString.substringAfter(',').length() >= 2) {
                                                    String amount = amountsString.substringBefore(',') + '.' + amountsString.substringAfter(',').substring(0, 2);
                                                    if (year == String.valueOf(Date.today().year() - numberOfYearsAgo)) {
                                                        return String.valueOf(Decimal.valueOf(amount) * k);
                                                    } else {
                                                        amountsString = amountsString.substring(amount.length(), amountsString.length());
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return profit/loss for year before last
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : profit/loss for year before last
    ******************************************************************************/
    public static String returnTurnOverLastYear(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'UNSTRUCTURED') {
                                if (reportChildNode.getText().contains('FINANCIAL INFORMATION')) {
                                    String financialInformation = reportChildNode.getText().substringAfter('FINANCIAL INFORMATION');
                                    String currencyDescription;
                                    Decimal k;
                                    if (financialInformation.contains('Amounts shown in Euro (EUR) Thousand')) {
                                        currencyDescription = 'Amounts shown in Euro (EUR) Thousand';
                                        k = 1000 * 310;
                                    } else if (financialInformation.contains('Amounts shown in Euro (EUR)')) {
                                        currencyDescription = 'Amounts shown in Euro (EUR)';
                                        k = 310;
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF) Thousand')) {
                                        currencyDescription = 'Amounts shown in Hungarian Forint (HUF) Thousand';
                                        k = 1000;
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF)')) {
                                        currencyDescription = 'Amounts shown in Hungarian Forint (HUF)';
                                        k = 1;
                                    }
                                    List<String> yearsList = new List<String>();
                                    if (currencyDescription != null && financialInformation.contains(currencyDescription + '\n') &&
                                            financialInformation.substringAfter(currencyDescription + '\n').contains('\n')) {
                                        String yearsString = financialInformation.substringBetween(currencyDescription + '\n', '\n').deleteWhitespace().replaceAll('[0-9]{2}[.]', '');
                                        for (Integer i=0; i<yearsString.length(); i+=4) {
                                            if (yearsString.length() >= i+4) {
                                                yearsList.add(yearsString.substring(i, i+4));
                                            }
                                        }
                                        if (financialInformation.contains('Net sales revenue') && financialInformation.substringAfter('Net sales revenue').contains('\n')) {
                                            String amountsString = financialInformation.substringBetween('Net sales revenue', '\n').replaceAll('[^0-9,]', '');
                                            Integer numberOfYearsAgo;
                                            for (String year : yearsList) {
                                                if (year == String.valueOf(Date.today().year() - 1)) {
                                                    numberOfYearsAgo = 1;
                                                }
                                            }

                                            if (numberOfYearsAgo == null) {
                                                numberOfYearsAgo = 2;
                                            }

                                            for (String year : yearsList) {
                                                if (amountsString.contains(',') && amountsString.substringAfter(',').length() >= 2) {
                                                    String amount = amountsString.substringBefore(',') + '.' + amountsString.substringAfter(',').substring(0, 2);
                                                    if (year == String.valueOf(Date.today().year() - numberOfYearsAgo)) {
                                                        return String.valueOf(Decimal.valueOf(amount) * k);
                                                    } else {
                                                        amountsString = amountsString.substring(amount.length(), amountsString.length());
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

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return year of last financial information
    *  CreatedDate     : 26/04/2021 by Ivan Kulinkovich
    *  Parameters      : bodyNode - body from response
    *  Returns         : Year of last financial information
    ******************************************************************************/
    public static String returnYearOfLastFinancialInformation(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'UNSTRUCTURED') {
                                if (reportChildNode.getText().contains('FINANCIAL INFORMATION')) {
                                    String financialInformation = reportChildNode.getText().substringAfter('FINANCIAL INFORMATION');
                                    String year;
                                    if (financialInformation.contains('Amounts shown in Euro (EUR) Thousand\n')) {
                                        year = financialInformation.substringAfter('Amounts shown in Euro (EUR) Thousand\n').substringBefore('\n');
                                    } else if (financialInformation.contains('Amounts shown in Euro (EUR)\n')) {
                                        year = financialInformation.substringAfter('Amounts shown in Euro (EUR)\n').substringBefore('\n');
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF) Thousand\n')) {
                                        year = financialInformation.substringAfter('Amounts shown in Hungarian Forint (HUF) Thousand\n').substringBefore('\n');
                                    } else if (financialInformation.contains('Amounts shown in Hungarian Forint (HUF)\n')) {
                                        year = financialInformation.substringAfter('Amounts shown in Hungarian Forint (HUF)\n').substringBefore('\n');
                                    }

                                    if (year != null) {
                                        year = year.deleteWhitespace().substring(0, 4);
                                    }

                                    return year;
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
    *  Summary         : Return principal activity code
    *  CreatedDate     : 04/03/2021 by Ivan Kulinkovich
    *  Parameters      : bodyNode - body from response
    *  Returns         : principal activity code
    ******************************************************************************/
    public static String returnPrincipalActivityCode(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'ACTIVITIES') {
                                for (Dom.XmlNode activitiesChildNode : reportChildNode.getChildElements()) {
                                    if (activitiesChildNode.getName() == 'ACTIVITY') {
                                        for (Dom.XmlNode activityChildNode : activitiesChildNode.getChildElements()) {
                                            if (activityChildNode.getName() == 'NACECODE') {
                                                return activityChildNode.getText();
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
    *  Summary         : Return principal activity description
    *  CreatedDate     : 04/03/2021 by Ivan Kulinkovich
    *  Parameters      : bodyNode - body from response
    *  Returns         : principal activity description
    ******************************************************************************/
    public static String returnPrincipalActivityDescription(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'ACTIVITIES') {
                                for (Dom.XmlNode activitiesChildNode : reportChildNode.getChildElements()) {
                                    if (activitiesChildNode.getName() == 'ACTIVITY') {
                                        for (Dom.XmlNode activityChildNode : activitiesChildNode.getChildElements()) {
                                            if (activityChildNode.getName() == 'NACETEXT') {
                                                return activityChildNode.getText();
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
    *  Summary         : Return contacts
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : contacts
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnReportCompanyEmployees(Dom.XmlNode bodyNode) {
        List<CreditFactoryCompany.CreditFactoryContact> contactsList = new List<CreditFactoryCompany.CreditFactoryContact>();
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'ICON') {
                for (Dom.XmlNode iconChildNode : bodyChildNode.getChildElements()) {
                    if (iconChildNode.getName() == 'CREDITREPORT') {
                        for (Dom.XmlNode reportChildNode : iconChildNode.getChildElements()) {
                            if (reportChildNode.getName() == 'MANAGEMENT') {
                                for (Dom.XmlNode managementChildNode : reportChildNode.getChildElements()) {
                                    if (managementChildNode.getName() == 'MANAGER') {
                                        CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                                        contact.recordType = 'Default';
                                        for (Dom.XmlNode managerChildNode : managementChildNode.getChildElements()) {
                                            if (managerChildNode.getName() == 'NAME') {
                                                contact.name = managerChildNode.getText();
                                            }

                                            if (managerChildNode.getName() == 'TYPE') {
                                                contact.type = managerChildNode.getText();
                                            }

                                            String address = '';

                                            if (managerChildNode.getName() == 'ADDRESS') {
                                                for (Dom.XmlNode addressChildNode : managerChildNode.getChildElements()) {
                                                    if (addressChildNode.getName() == 'STREET') {
                                                        address += addressChildNode.getText();
                                                    }

                                                    if (addressChildNode.getName() == 'HOUSENUMBER') {
                                                        address += ' ' + addressChildNode.getText();
                                                    }

                                                    if (addressChildNode.getName() == 'ZIPCODE') {
                                                        address += ' ' + addressChildNode.getText();
                                                    }

                                                    if (addressChildNode.getName() == 'CITY') {
                                                        address += ' ' + addressChildNode.getText();
                                                    }
                                                }

                                                contact.address = address;
                                            }
                                        }

                                        contactsList.add(contact);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return contactsList;
    }


    /*******************************************************************************
    *  Summary         : Return internal Id
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : internal Id
    ******************************************************************************/
    public static String returnInternalId(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'getCompanyDetailsResponse' || bodyChildNode.getName() == 'immediateOrderResponse') {
                for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                    if (responseChildNode.getName() == 'getCompanyDetailsResult' || responseChildNode.getName() == 'immediateOrderResult') {
                        for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                            if (resultChildNode.getName() == 'CompanyDetails' || resultChildNode.getName() == 'OrderStatus') {
                                for (Dom.XmlNode detailsChildNode : resultChildNode.getChildElements()) {
                                    if (detailsChildNode.getName() == 'Company') {
                                        for (Dom.XmlNode companyChildNode : detailsChildNode.getChildElements()) {
                                            if (companyChildNode.getName() == 'Identifiers') {
                                                for (Dom.XmlNode identifiersNode : companyChildNode.getChildElements()) {
                                                    if (identifiersNode.getName() == 'CompanyIdentifier') {
                                                        String idType;
                                                        String idValue;
                                                        for (Dom.XmlNode companyIdentifier : identifiersNode.getChildElements()) {
                                                            if (companyIdentifier.getName() == 'Type') {
                                                                idType = companyIdentifier.getText();
                                                            }
                                                            else if (companyIdentifier.getName() == 'Identifier') {
                                                                idValue = companyIdentifier.getText();
                                                            }
                                                        }

                                                        if (idType == '0') {
                                                            return idValue;
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
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return error message
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : error message
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'Fault') {
                for (Dom.XmlNode faultChildNode : bodyChildNode.getChildElements()) {
                    if (faultChildNode.getName() == 'faultstring') {
                        return faultChildNode.getText();
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return binary attachment for ordered report
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : bodyNode - body from response
    *  Returns         : binary attachment
    ******************************************************************************/
    public static Blob getOrderedBinaryAttachment(Dom.XmlNode bodyNode) {
        for (Dom.XmlNode bodyChildNode : bodyNode.getChildElements()) {
            if (bodyChildNode.getName() == 'immediateOrderResponse') {
                for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                    if (responseChildNode.getName() == 'immediateOrderResult') {
                        for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                            if (resultChildNode.getName() == 'Report') {
                                for (Dom.XmlNode reportChildNode : resultChildNode.getChildElements()) {
                                    if (reportChildNode.getName() == 'ReportBinary') {
                                        return EncodingUtil.base64Decode(reportChildNode.getText());
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
    *  Summary         : Generate HTTP Request to Coface to get PDF report
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : endpoint - Coface endpoint,
                         userName - Coface userName,
                         password - Coface password,
                         companyId - Coface company Id
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generatePdfReportRequest(String endpoint, String userName, String password,
                                                    String companyId) {
        String body = generatePdfReportXML(userName, password, companyId);
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', 'http://www.iconx.biz/webservices/immediateOrder');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate xml body for pdf report
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : userName - Coface userName,
                         password - Coface password,
                         companyId - Coface company Id
    *  Returns         : xml body
    ******************************************************************************/
    public static String generatePdfReportXML(String userName, String password, String companyId) {
        String xmlbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://www.iconx.biz/webservices">' +
            '<soapenv:Header>' +
                '<web:AuthHeader>' +
                    '<web:Username>' + userName + '</web:Username>' +
                    '<web:Password>' + password + '</web:Password>' +
                '</web:AuthHeader>' +
            '</soapenv:Header>' +
            '<soapenv:Body>' +
                '<web:immediateOrder>' +
                    '<web:InternalID>' + companyId + '</web:InternalID>' +
                    '<web:ReportMimeType>application/pdf</web:ReportMimeType>' +
                    '<web:Language>EN</web:Language>' +
                    '<web:ProductCode>761</web:ProductCode>' +
                '</web:immediateOrder>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';

        return xmlbody;
    }


    /*******************************************************************************
    *  Summary         : Return PDF report in Blob
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : xmlBody – XML body from PDF response
    *  Returns         : PDF file
    ******************************************************************************/
    public static Blob getBinaryAttachment(String xmlBody) {
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xmlBody);
        Dom.XmlNode xmlDom = domDoc.getRootElement();
        Dom.XmlNode globalBodyNode = returnGlobalBody(xmlDom);
        for (Dom.XmlNode globalBodyChildNode : globalBodyNode.getChildElements()) {
            if (globalBodyChildNode.getName() == 'immediateOrderResponse') {
                for (Dom.XmlNode responseChildNode : globalBodyChildNode.getChildElements()) {
                    if (responseChildNode.getName() == 'immediateOrderResult') {
                        for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                            if (resultChildNode.getName() == 'Report') {
                                for (Dom.XmlNode reportChildNode : resultChildNode.getChildElements()) {
                                    if (reportChildNode.getName() == 'ReportBinary') {
                                        return EncodingUtil.base64Decode(reportChildNode.getText());
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
}