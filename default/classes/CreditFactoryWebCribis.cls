public class CreditFactoryWebCribis {

    /*******************************************************************************
    *  Summary         : Generate HTTP Request to Crif
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : endpoint - Cribis endpoint,
                         userName - Cribis account name,
                         password - Cribis account password,
                         searchParametersNames - parameters for searching,
                         country - country
    *  Returns         : search request
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password,
            Map<String, String> searchParametersMap, String countryCode) {
        String body = generateSearchXML(userName, password, searchParametersMap, countryCode);
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/soap+xml; charset=utf-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : userName - Cribis account name,
                         password - Cribis account password,
                         searchParametersMap - parameters for searching,
                         country - country
    *  Returns         : search string
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, Map<String, String> searchParametersMap, String countryCode) {
        String opportunityName;
        if (searchParametersMap.containsKey('name') && !String.isEmpty(searchParametersMap.get('name'))) {
            opportunityName = searchParametersMap.get('name').replace('&', ' ');
        }

        Boolean isTaxId;
        if (searchParametersMap.containsKey('taxId') && !String.isEmpty(searchParametersMap.get('taxId'))) {
            isTaxId = true;
        }
        else {
            isTaxId = false;
        }

        String xmlBody =
                '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ws="https://ws.urplus.sk">' +
                    '<soap:Header/>' +
                        '<soap:Body>' +
                            '<ws:URPlusGetCandidates>' +
                                '<ws:credentials>' +
                                    '<ws:UserName>' + userName + '</ws:UserName>' +
                                    '<ws:Password>' + password + '</ws:Password>' +
                                '</ws:credentials>' +
                                '<ws:language>EN</ws:language>' +
                                '<ws:searchString>' + (isTaxId ? searchParametersMap.get('taxId') : opportunityName) + '</ws:searchString>' +
                                '<ws:subjectType>ID</ws:subjectType>' +
                                '<ws:historicalNames>false</ws:historicalNames>' +
                                '<ws:nonActiveSubjects>false</ws:nonActiveSubjects>' +
                                '<ws:top100Subjects>true</ws:top100Subjects>' +
                                (!isTaxId ? ((searchParametersMap.containsKey('registeredCity') && !String.isEmpty(searchParametersMap.get('registeredCity'))) ?
                                        '<ws:city>' + searchParametersMap.get('registeredCity') + '</ws:city>' : '') +
                                        ((searchParametersMap.containsKey('registeredStreet') && !String.isEmpty(searchParametersMap.get('registeredStreet'))) ?
                                                '<ws:street>' + searchParametersMap.get('registeredStreet') + '</ws:street>' : '') +
                                        ((searchParametersMap.containsKey('registeredPostCode') && !String.isEmpty(searchParametersMap.get('registeredPostCode'))) ?
                                                '<ws:zip>' + searchParametersMap.get('registeredPostCode') + '</ws:zip>' : '') : '') +
                                '<ws:country>' + countryCode + '</ws:country>' +
                            '</ws:URPlusGetCandidates>' +
                            '</soap:Body>' +
                    '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Summary         : Return error message
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : envelope - node from response
    *  Returns         : error message
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XmlNode envelope) {
        String errorMessage;
        for (Dom.XmlNode envelopeChildNode : envelope.getChildElements()) {
            if (envelopeChildNode.getName() == 'Body') {
                for (Dom.XmlNode bodyChildNode : envelopeChildNode.getChildElements()) {
                    if (bodyChildNode.getName() == 'URPlusGetCompanyListResponse' || bodyChildNode.getName() == 'CribisGetGlobalReportResponse') {
                        for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                            if (responseChildNode.getName() == 'URPlusGetCompanyListResult' || responseChildNode.getName() == 'CribisGetGlobalReportResult') {
                                for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                                    if (resultChildNode.getName() == 'Status') {
                                        for (Dom.XmlNode statusChildNode : resultChildNode.getChildElements()) {
                                            if (statusChildNode.getName() == 'Code') {
                                                String code = statusChildNode.getText();
                                                if (code == '401') {
                                                    errorMessage = 'Bad request';
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

        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : Return searched companies list
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : envelopeNode - node from response
    *  Returns         : list of companies
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchedCompanies(Dom.XmlNode envelopeNode) {
        List<CreditFactoryCompany> companiesFromSearch = new List<CreditFactoryCompany>();
        Integer id = 1;
        Dom.XmlNode dataNode = returnSearchResponseDataNode(envelopeNode);
        if (dataNode != null) {
            for (Dom.XmlNode dataChildNode : dataNode.getChildElements()) {
                if (dataChildNode.getName() == 'Subject') {
                    CreditFactoryCompany company = new CreditFactoryCompany();
                    for (Dom.XmlNode subjectChildNode : dataChildNode.getChildElements()) {
                        if (subjectChildNode.getName() == 'IC') {
                            company.taxId = subjectChildNode.getText();
                            company.creditSystemCompanyNumber = subjectChildNode.getText();
                            company.identificationNumber = subjectChildNode.getText();
                        }
                        else if (subjectChildNode.getName() == 'Name') {
                            company.name = subjectChildNode.getText();
                        }
                        else if (subjectChildNode.getName() == 'AddressComplex') {
                            for (Dom.XmlNode addressChildNode : subjectChildNode.getChildElements()) {
                                if (addressChildNode.getName() == 'Street') {
                                    company.street = addressChildNode.getText();
                                } else if (addressChildNode.getName() == 'City') {
                                    company.city = addressChildNode.getText();
                                } else if (addressChildNode.getName() == 'Zip') {
                                    company.postCode = addressChildNode.getText();
                                }
                            }
                        }
                    }

                    if (company.identificationNumber != null) {
                        company.id = String.valueOf(id);
                        id++;
                        companiesFromSearch.add(company);
                    }
                }
            }
        }

        return companiesFromSearch;
    }


    /*******************************************************************************
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : envelope - body from response
    *  Returns         : search dom
    ******************************************************************************/
    private static Dom.XmlNode returnSearchResponseDataNode(Dom.XmlNode envelopeNode) {
        for (Dom.XmlNode envelopeChildNode : envelopeNode.getChildElements()) {
            if (envelopeChildNode.getName() == 'Body') {
                for (Dom.XmlNode bodyChildNode : envelopeChildNode.getChildElements()) {
                    if (bodyChildNode.getName() == 'URPlusGetCandidatesResponse') {
                        for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                            if (responseChildNode.getName() == 'URPlusGetCandidatesResult') {
                                for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                                    if (resultChildNode.getName() == 'Data') {
                                        return resultChildNode;
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
    *  Summary         : Generate HTTP Request to Cribis
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : endpoint - from CreditSystem custom setting,
                         userName - from CreditSystem custom setting,
                         password - from CreditSystem custom setting,
                         companyId - Id of Credit System Company
    *  Returns         : report request
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password,
            String companyId, String countryCode) {
        String body = generateReportXML(userName, password, companyId, countryCode);
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/soap+xml; charset=utf-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : userName - from CreditSystem custom setting,
                         password - from CreditSystem custom setting,
                         companyId - Id of Credit System Company,
                         countryCode - country code
    *  Returns         : report request xml
    ******************************************************************************/
    public static String generateReportXML(String userName, String password,
                                           String companyId, String countryCode) {
        String xmlBody =
                '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ws="https://ws.urplus.sk">' +
                    '<soap:Header/>' +
                    '<soap:Body>' +
                        '<ws:CribisGetGlobalReport>' +
                            '<ws:credentials>' +
                                '<ws:UserName>' + userName + '</ws:UserName>' +
                                '<ws:Password>' + password + '</ws:Password>' +
                            '</ws:credentials>' +
                            '<ws:language>EN</ws:language>' +
                            '<ws:country>' + countryCode.toUpperCase() + '</ws:country>' +
                            '<ws:ico>' + companyId + '</ws:ico>' +
                            '<ws:pdf>true</ws:pdf>' +
                        '</ws:CribisGetGlobalReport>' +
                    '</soap:Body>' +
                '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Summary         : Return Company
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : enveloperNode - node from response,
                         icoNumber - nip number for getting report,
                         country - country
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XmlNode envelopeNode, String icoNumber, String country) {
        CreditFactoryCompany company = new CreditFactoryCompany();
        company.identificationNumber = icoNumber;
        company.creditSystemCompanyNumber = icoNumber;
        company.country = country;
        company.recordType = 'Default';
        company.numberOfExecutions = 0;
        company.financialEvaluation = true;
        company.creditFactoryContacts = new List<CreditFactoryCompany.CreditFactoryContact>();
        Dom.XmlNode globalReportNode = returnGlobalReportNode(envelopeNode);
        if (globalReportNode != null) {
            for (Dom.XmlNode globalReportChildNode : globalReportNode.getChildElements()) {
                if (globalReportChildNode.getName() == 'CompanyIdentification') {
                    company = fillIdentificationData(globalReportChildNode, company);
                }
                else if (globalReportChildNode.getName() == 'CompanyRatingCalculationResponse') {
                    company = fillRatingData(globalReportChildNode, company);
                }
                else if (globalReportChildNode.getName() == 'KeyInformation') {
                    company = fillKeyInfoData(globalReportChildNode, company);
                }
                else if (globalReportChildNode.getName() == 'OtherCompanyInformation') {
                    company = fillOtherInfoData(globalReportChildNode, company);
                }
                else if (globalReportChildNode.getName() == 'KeyResultsWarning') {
                    company = fillWarningsData(globalReportChildNode, company);
                }
            }
        }

        Dom.XmlNode documentTicketNode = returnDocumentTicketNode(envelopeNode);
        if (documentTicketNode != null) {
            company.documentTicket = documentTicketNode.getText();
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Return status description
    *  CreatedDate     : 07/10/2020 by Anton Buzak
    *  Parameters      : envelopeNode - node from response
    *  Returns         : status
    ******************************************************************************/
    public static String returnStatus(Dom.XmlNode envelopeNode) {
        for (Dom.XmlNode envelopeChildNode : envelopeNode.getChildElements()) {
            if (envelopeChildNode.getName() == 'Body') {
                for (Dom.XmlNode bodyChildNode : envelopeChildNode.getChildElements()) {
                    if (bodyChildNode.getName() == 'CribisGetGlobalReportResponse') {
                        for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                            if (responseChildNode.getName() == 'CribisGetGlobalReportResult') {
                                for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                                    if (resultChildNode.getName() == 'Status') {
                                        for (Dom.XmlNode statusChildNode : resultChildNode.getChildElements()) {
                                            if (statusChildNode.getName() == 'Description') {
                                                return statusChildNode.getText();
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
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : envelopeNode - node from response
    *  Returns         : report dom
    ******************************************************************************/
    private static Dom.XmlNode returnGlobalReportNode(Dom.XmlNode envelopeNode) {
        for (Dom.XmlNode envelopeChildNode : envelopeNode.getChildElements()) {
            if (envelopeChildNode.getName() == 'Body') {
                for (Dom.XmlNode bodyChildNode : envelopeChildNode.getChildElements()) {
                    if (bodyChildNode.getName() == 'CribisGetGlobalReportResponse') {
                        for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                            if (responseChildNode.getName() == 'CribisGetGlobalReportResult') {
                                for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                                    if (resultChildNode.getName() == 'Data') {
                                        for (Dom.XmlNode dataChildNode : resultChildNode.getChildElements()) {
                                            if (dataChildNode.getName() == 'CompanyGlobalReport') {
                                                return dataChildNode;
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
    *  Summary         : Fill company identification data
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : globalReportChildNode - global report child node,
                         company - company
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany fillIdentificationData(Dom.XmlNode globalReportChildNode, CreditFactoryCompany company) {
        for (Dom.XmlNode identificationChildNode : globalReportChildNode.getChildElements()) {
            String idName = identificationChildNode.getName();
            String idText = identificationChildNode.getText();
            if (idName == 'LegalForm') {
                company.legalForm = idText;
            }
            else if (idName == 'Ico') {
                company.taxId = idText;
            }
            else if (idName == 'VATID') {
                company.vatNumber = idText;
            }
            else if (idName == 'Name') {
                company.name = idText;
            }
            else if (idName == 'Seat') {
                for (Dom.XmlNode seatChildNode : identificationChildNode.getChildElements()) {
                    String seatName = seatChildNode.getName();
                    String seatText = seatChildNode.getText();
                    if (seatName == 'Street') {
                        company.street = seatText;
                    }
                    else if (seatName == 'City') {
                        company.city = seatText;
                    }
                    else if (seatName == 'Zip') {
                        company.postCode = seatText;
                    }
                }
            }
            else if (idName == 'PhoneNumbers') {
                for (Dom.XmlNode phonesChildNode : identificationChildNode.getChildElements()) {
                    if (phonesChildNode.getName() == 'PhoneNumber') {
                        for (Dom.XmlNode phoneChildNode : phonesChildNode.getChildElements()) {
                            if (phoneChildNode.getName() == 'Number') {
                                company.mobile = phoneChildNode.getText();
                                break;
                            }
                        }
                    }
                }
            }
            else if (idName == 'FaxNumber') {
                company.fax = idText;
            }
            else if (idName == 'Website') {
                company.website = idText;
            }
            else if (idName == 'Email') {
                company.email = idText;
            }
            else if (idName == 'MainNACE') {
                for (Dom.XmlNode naceChildNode : identificationChildNode.getChildElements()) {
                    String naceName = naceChildNode.getName();
                    String naceText = naceChildNode.getText();
                    if (naceName == 'Code') {
                        company.principalActivityCode = naceText;
                        if (company.principalActivityCode != null) {
                            company.principalActivityCode = company.principalActivityCode.replaceAll('[^0-9]', '');
                        }
                    }
                    else if (naceName == 'Description') {
                        company.principalActivityDescription = naceText;
                    }
                }
            }
            else if (idName == 'DateOfCreation') {
                company.dateOfFoundation = idText;
                if (company.dateOfFoundation != null && company.dateOfFoundation.length() == 10) {
                    company.ageOfCompany = String.valueOf(Date.today().year() - Integer.valueOf(company.dateOfFoundation.substring(0, 4)));
                }
            }
            else if (idName == 'Registration') {
                for (Dom.XmlNode registrationChildNode : identificationChildNode.getChildElements()) {
                    if (registrationChildNode.getName() == 'Item') {
                        String tradeRegisterNumber = '';
                        String countyCourt = '';
                        String type;
                        for (Dom.XmlNode itemChildNode : registrationChildNode.getChildElements()) {
                            if (itemChildNode.getName() == 'Type') {
                                type = itemChildNode.getText();
                            }
                            else if (itemChildNode.getName() == 'Number') {
                                tradeRegisterNumber = itemChildNode.getText();
                            }
                            else if (itemChildNode.getName() == 'Registrar') {
                                countyCourt = ' ' + itemChildNode.getText();
                            }
                        }

                        if (type == 'OR') {
                            company.tradeRegisterNumber = tradeRegisterNumber;
                            company.countyCourt = countyCourt;
                        }
                    }
                }
            }
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Fill company rating data
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : globalReportChildNode - global report child node,
                         company - company
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany fillRatingData(Dom.XmlNode globalReportChildNode, CreditFactoryCompany company) {
        for (Dom.XmlNode ratingChildNode : globalReportChildNode.getChildElements()) {
            String name = ratingChildNode.getName();
            String text = ratingChildNode.getText();
            if (name == 'IndexCribis10Level') {
                if (ratingsMap.containsKey(text)) {
                    company.classRating = ratingsMap.get(text);
                } else {
                    company.classRating = text;
                }

                if (solvenciesMap.containsKey(text)) {
                    company.solvencyIndex = solvenciesMap.get(text);
                }
                else {
                    company.solvencyIndex = text;
                }
            }
            else if (name == 'IndexCribis10NefiLevel') {
                company.financialEvaluation = false;
            }
            else if (name == 'CreditUsed') {
                company.creditLimit = text;
            }
            else if (name == 'CreditCurrency') {
                company.creditLimitCurrency = text;
            }
            else if (name == 'CreditUnit' && text != null) {
                Decimal unit = Decimal.valueOf(text);
                if (company.creditLimit != null) {
                    company.creditLimit = String.valueOf(Decimal.valueOf(company.creditLimit) * unit);
                }
            }
            else if (name == 'DateOfLastRequest') {
                company.dateOfLastRequest = text;
            }
            else if (name == 'FinancialSituation') {
                company.financialSituation = text;
            }
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Fill company key info data
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : globalReportChildNode - global report child node,
                         company - company
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany fillKeyInfoData(Dom.XmlNode globalReportChildNode, CreditFactoryCompany company) {
        for (Dom.XmlNode keyInfoChildNode : globalReportChildNode.getChildElements()) {
            if (keyInfoChildNode.getName() == 'KeyOwnersList') {
                for (Dom.XmlNode keyOwnersListChildNode : keyInfoChildNode.getChildElements()) {
                    if (keyOwnersListChildNode.getName() == 'KeyOwner') {
                        CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                        contact.recordType = 'Default';
                        for (Dom.XmlNode keyOwnerChildNode : keyOwnersListChildNode.getChildElements()) {
                            String relationName = keyOwnerChildNode.getName();
                            String relationText = keyOwnerChildNode.getText();
                            if (relationName == 'Name') {
                                contact.name = relationText;
                            }
                            else if (relationName == 'Surname') {
                                if (contact.name != null) {
                                    contact.name = contact.name + ' ' + relationText;
                                } else {
                                    contact.name = relationName;
                                }
                            }
                            else if (relationName == 'Address') {
                                for (Dom.XmlNode addressChildNode : keyOwnerChildNode.getChildElements()) {
                                    if (addressChildNode.getName() == 'FullAddress') {
                                        contact.address = addressChildNode.getText();
                                    }
                                }
                            }
                            else if (relationName == 'Position') {
                                contact.type = relationText;
                            }
                        }

                        Boolean isContactAdded = false;
                        for (CreditFactoryCompany.CreditFactoryContact currentContact : company.creditFactoryContacts) {
                            if (currentContact.name == contact.name) {
                                isContactAdded = true;
                                break;
                            }
                        }

                        if (! isContactAdded) {
                            company.creditFactoryContacts.add(contact);
                        }
                    }
                }
            } else if (keyInfoChildNode.getName() == 'TurnoverRangeList') {
                for (Dom.XmlNode turnOverListChildNode : keyInfoChildNode.getChildElements()) {
                    if (turnOverListChildNode.getName() == 'TurnoverRange') {
                        for (Dom.XmlNode turnOverChildNode : turnOverListChildNode.getChildElements()) {
                            if (turnOverChildNode.getName() == 'Value') {
                                company.turnOver = turnOverChildNode.getText();
                                break;
                            }
                        }
                    }
                }
            }
            else if (keyInfoChildNode.getName() == 'EmployeesRangeList') {
                for (Dom.XmlNode employeesListChildNode : keyInfoChildNode.getChildElements()) {
                    if (employeesListChildNode.getName() == 'EmployeesRange') {
                        for (Dom.XmlNode employeesChildNode : employeesListChildNode.getChildElements()) {
                            if (employeesChildNode.getName() == 'Value') {
                                company.staffCompanyRange = employeesChildNode.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Fill company other info data
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : globalReportChildNode - global report child node,
                         company - company
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany fillOtherInfoData(Dom.XmlNode globalReportChildNode, CreditFactoryCompany company) {
        for (Dom.XmlNode otherInfoChildNode : globalReportChildNode.getChildElements()) {
            if (otherInfoChildNode.getName() == 'OtherRelationsList') {
                for (Dom.XmlNode otherRelationsListChildNode : otherInfoChildNode.getChildElements()) {
                    if (otherRelationsListChildNode.getName() == 'OtherRelation') {
                        CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                        contact.recordType = 'Default';
                        for (Dom.XmlNode otherRelationChildNode : otherRelationsListChildNode.getChildElements()) {
                            String relationName = otherRelationChildNode.getName();
                            String relationText = otherRelationChildNode.getText();
                            if (relationName == 'Name') {
                                contact.name = relationText;
                            }
                            else if (relationName == 'Surname') {
                                if (contact.name != null) {
                                    contact.name = contact.name + ' ' + relationText;
                                } else {
                                    contact.name = relationName;
                                }
                            }
                            else if (relationName == 'Address') {
                                for (Dom.XmlNode addressChildNode : otherRelationChildNode.getChildElements()) {
                                    if (addressChildNode.getName() == 'FullAddress') {
                                        contact.address = addressChildNode.getText();
                                    }
                                }
                            }
                            else if (relationName == 'Position') {
                                contact.type = relationText;
                            }
                        }

                        Boolean isContactAdded = false;
                        for (CreditFactoryCompany.CreditFactoryContact currentContact : company.creditFactoryContacts) {
                            if (currentContact.name == contact.name) {
                                isContactAdded = true;
                                break;
                            }
                        }

                        if (! isContactAdded) {
                            company.creditFactoryContacts.add(contact);
                        }
                    }
                }
            }
            else if (otherInfoChildNode.getName() == 'StatutoryList') {
                for (Dom.XmlNode statutoryListChildNode : otherInfoChildNode.getChildElements()) {
                    if (statutoryListChildNode.getName() == 'Statutory') {
                        CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                        contact.recordType = 'Default';
                        for (Dom.XmlNode statutoryChildNode : statutoryListChildNode.getChildElements()) {
                            String relationName = statutoryChildNode.getName();
                            String relationText = statutoryChildNode.getText();
                            if (relationName == 'Name') {
                                contact.name = relationText;
                            }
                            else if (relationName == 'Surname') {
                                if (contact.name != null) {
                                    contact.name = contact.name + ' ' + relationText;
                                } else {
                                    contact.name = relationName;
                                }
                            }
                            else if (relationName == 'Address') {
                                for (Dom.XmlNode addressChildNode : statutoryChildNode.getChildElements()) {
                                    if (addressChildNode.getName() == 'FullAddress') {
                                        contact.address = addressChildNode.getText();
                                    }
                                }
                            }
                            else if (relationName == 'Position') {
                                contact.type = relationText;
                            }
                        }

                        Boolean isContactAdded = false;
                        for (CreditFactoryCompany.CreditFactoryContact currentContact : company.creditFactoryContacts) {
                            if (currentContact.name == contact.name) {
                                isContactAdded = true;
                                break;
                            }
                        }

                        if (! isContactAdded) {
                            company.creditFactoryContacts.add(contact);
                        }
                    }
                }
            }
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Fill company other info data
    *  CreatedDate     : 09/10/2020 by Anton Buzak
    *  Parameters      : globalReportChildNode - global report child node,
                         company - company
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany fillWarningsData(Dom.XmlNode globalReportChildNode, CreditFactoryCompany company) {
        for (Dom.XmlNode otherInfoChildNode : globalReportChildNode.getChildElements()) {
            if (otherInfoChildNode.getName() == 'ArrayOfWarning') {
                for (Dom.XmlNode warningsChildNode : otherInfoChildNode.getChildElements()) {
                    if (warningsChildNode.getName() == 'Warning') {
                        String text;
                        String abbreviation;
                        Boolean isEnded = false;
                        for (Dom.XmlNode warningChildNode : warningsChildNode.getChildElements()) {
                            if (warningChildNode.getName() == 'Text') {
                                text = warningChildNode.getText();
                            }
                            else if (warningChildNode.getName() == 'Abbreviation') {
                                abbreviation = warningChildNode.getText();
                            }
                            else if (warningChildNode.getName() == 'EndDate' && warningChildNode.getText() != null) {
                                isEnded = true;
                            }
                        }

                        if (abbreviation != null && ! isEnded && negativeInformationSet.contains(abbreviation)) {
                            company.negativeInformation = text;
                            break;
                        }
                    }
                }
            }
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Generate HTTP Request to Cribis
    *  CreatedDate     : 07/10/2020 by Anton Buzak
    *  Parameters      : endpoint - from CreditSystem custom setting,
                         userName - from CreditSystem custom setting,
                         password - from CreditSystem custom setting,
                         firstName - contact first name,
                         lastName - contact last name,
                         birthDate - contact birth date,
                         countryCode - country code
    *  Returns         : report request
    ******************************************************************************/
    public static HttpRequest generateExecuteRequest(String endpoint, String userName, String password,
            String firstName, String lastName, String birthDate,
            String countryCode) {
        String body = generateExecuteXML(userName, password, firstName, lastName, birthDate, countryCode);
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/soap+xml; charset=utf-8');
        request.setBody(body);
        request.setTimeout(120000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : userName - from CreditSystem custom setting,
                         password - from CreditSystem custom setting,
                         firstName - contact first name,
                         lastName - contact last name,
                         birthDate - contact birth date,
                         countryCode - country code
    *  Returns         : report request xml
    ******************************************************************************/
    public static String generateExecuteXML(String userName, String password,
            String firstName, String lastName,
            String birthDate, String countryCode) {
        String xmlBody =
                '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ws="https://ws.urplus.sk">' +
                        '<soap:Header/>' +
                        '<soap:Body>' +
                        '<ws:CribisExekuceGet>' +
                        '<ws:credentials>' +
                        '<ws:UserName>' + userName + '</ws:UserName>' +
                        '<ws:Password>' + password + '</ws:Password>' +
                        '</ws:credentials>' +
                        '<ws:country>' + countryCode + '</ws:country>' +
                        '<ws:subjectType>F</ws:subjectType>' +
                        '<ws:name>' + firstName + '</ws:name>' +
                        '<ws:surname>' + lastName + '</ws:surname>' +
                        '<ws:dateOfBirth>' + birthDate + '</ws:dateOfBirth>' +
                        '</ws:CribisExekuceGet>' +
                        '</soap:Body>' +
                        '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Summary         : Return Company
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : enveloperNode - node from response,
                         icoNumber - nip number for getting report,
                         country - country
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany returnExecuteData(Dom.XmlNode enveloperNode, CreditFactoryCompany company) {
        for (Dom.XmlNode envelopeChildNode : enveloperNode.getChildElements()) {
            if (envelopeChildNode.getName() == 'Body') {
                for (Dom.XmlNode bodyChildNode : envelopeChildNode.getChildElements()) {
                    if (bodyChildNode.getName() == 'CribisExekuceGetResponse') {
                        for (Dom.XmlNode executeGetChildNode : bodyChildNode.getChildElements()) {
                            if (executeGetChildNode.getName() == 'CribisExekuceGetResult') {
                                for (Dom.XmlNode executeGetRusltChildNode : executeGetChildNode.getChildElements()) {
                                    if (executeGetRusltChildNode.getName() == 'Data') {
                                        for (Dom.XmlNode dataChildNode : executeGetRusltChildNode.getChildElements()) {
                                            if (dataChildNode.getName() == 'SearchResults') {
                                                for (Dom.XmlNode searchResultsChildNode : dataChildNode.getChildElements()) {
                                                    if (dataChildNode.getName() == 'Subject') {
                                                        company.numberOfExecutions++;
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

        return company;
    }


    /*******************************************************************************
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : envelopeNode - node from response
    *  Returns         : report dom
    ******************************************************************************/
    private static Dom.XmlNode returnDocumentTicketNode(Dom.XmlNode envelopeNode) {
        for (Dom.XmlNode envelopeChildNode : envelopeNode.getChildElements()) {
            if (envelopeChildNode.getName() == 'Body') {
                for (Dom.XmlNode bodyChildNode : envelopeChildNode.getChildElements()) {
                    if (bodyChildNode.getName() == 'CribisGetGlobalReportResponse') {
                        for (Dom.XmlNode responseChildNode : bodyChildNode.getChildElements()) {
                            if (responseChildNode.getName() == 'CribisGetGlobalReportResult') {
                                for (Dom.XmlNode resultChildNode : responseChildNode.getChildElements()) {
                                    if (resultChildNode.getName() == 'Data') {
                                        for (Dom.XmlNode dataChildNode : resultChildNode.getChildElements()) {
                                            if (dataChildNode.getName() == 'DocumentTicket') {
                                                return dataChildNode;
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
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 07/10/2020 by Anton Buzak
    *  Parameters      : endpoint - from CreditSystem custom setting,
                         userName - from CreditSystem custom setting,
                         password - from CreditSystem custom setting,
                         companyId - Id of Credit System Company
    *  Returns         : pdf report request
    ******************************************************************************/
    public static HttpRequest generatePdfRequest(String endpoint, String userName, String password, String companyId) {
        try {
            String body = generatePdfRequest(userName, password, companyId);
            HttpRequest request = new HttpRequest();
            request.setBody(body);
            request.setHeader('Accept-Encoding', 'gzip,deflate');
            request.setHeader('Content-Type', 'application/soap+xml;charset=UTF-8');
            request.setTimeout(120000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            throw new CreditFactoryException('Report request failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 30/09/2020 by Anton Buzak
    *  Parameters      : userName - Cribis account name,
                         password - Cribis account password,
                         searchParametersMap - parameters for searching,
                         country - country
    *  Returns         : search string
    ******************************************************************************/
    public static String generatePdfRequest(String userName, String password, String companyId) {
        String xmlBody =
                '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ws="https://ws.urplus.sk">' +
                        '<soap:Header/>' +
                        '<soap:Body>' +
                        '<ws:GetDocumentByTicket>' +
                        '<ws:credentials>' +
                        '<ws:UserName>' + userName + '</ws:UserName>' +
                        '<ws:Password>' + password + '</ws:Password>' +
                        '</ws:credentials>' +
                        '<ws:guid>' + companyId + '</ws:guid>' +
                        '</ws:GetDocumentByTicket>' +
                        '</soap:Body>' +
                        '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Summary         : Return pdf report body
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : enveloperNode - node from response
    *  Returns         : company
    ******************************************************************************/
    public static String returnPdfReportBody(Dom.XmlNode envelopeNode) {
        String pdfBody;
        for (Dom.XmlNode envelopeChildNode : envelopeNode.getChildElements()) {
            if (envelopeChildNode.getName() == 'Body') {
                for (Dom.XmlNode bodyChildNode : envelopeChildNode.getChildElements()) {
                    if (bodyChildNode.getName() == 'GetDocumentByTicketResponse') {
                        for (Dom.XmlNode getDocumentByTicketResponseChildNode : bodyChildNode.getChildElements()) {
                            if (getDocumentByTicketResponseChildNode.getName() == 'GetDocumentByTicketResult') {
                                for (Dom.XmlNode getDocumentByTicketResultChildNode : getDocumentByTicketResponseChildNode.getChildElements()) {
                                    if (getDocumentByTicketResultChildNode.getName() == 'Data') {
                                        for (Dom.XmlNode dataChildNode : getDocumentByTicketResultChildNode.getChildElements()) {
                                            if (dataChildNode.getName() == 'Document') {
                                                pdfBody = dataChildNode.getText();
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

        return pdfBody;
    }


    public static Map<String, String> ratingsMap = new Map<String, String>{
            '1' => '5',
            '2' => '4',
            '3' => '4',
            '4' => '3',
            '5' => '3',
            '6' => '3',
            '7' => '2',
            '8' => '2',
            '9' => '1',
            '10' => '1',
            '0' => null
    };


    public static Map<String, String> solvenciesMap = new Map<String, String>{
            '1' => null,
            '2' => '2',
            '3' => '1',
            '4' => '3',
            '5' => '2',
            '6' => '1',
            '7' => '2',
            '8' => '1',
            '9' => '2',
            '10' => '1',
            '0' => null
    };


    public static Set<String> negativeInformationSet = new Set<String>{
        'BB',
        'D',
        'DO',
        'DOV',
        'DU',
        'E',
        'EO',
        'EOP',
        'FBB',
        'IR',
        'K',
        'KNI',
        'KS',
        'KZBL',
        'L',
        'NDN',
        'NLP',
        'NZ',
        'O',
        'PŽ',
        'QP',
        'R',
        'RM',
        'SVI',
        'SVK',
        'SZK',
        'UO',
        'VA',
        'VY',
        'ZV',
        'ZŽ'
    };
}