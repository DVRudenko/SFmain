public class CreditFactoryWebCompanyInfo {


    /*******************************************************************************
    *  Summary         : Generate dutchBusinessSearch request to Company.info
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : endpoint - Company.info endpoint,
                         userName - Company.info user,
                         password - Company.info password,
                         searchParametersNames - parameters for searching
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password,
                                                    Map<String, String> searchParametersMap) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', 'https://ws1.webservices.nl/soap_doclit.php/dutchBusinessSearch');
        request.setTimeout(30000);
        String body = '' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://www.webservices.nl/soap/">' +
                '<soapenv:Header>' +
                    '<soap:HeaderLogin>' +
                        '<soap:username>' + userName + '</soap:username>' +
                        '<soap:password>' + password + '</soap:password>' +
                    '</soap:HeaderLogin>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                    '<soap:dutchBusinessSearch>' +
                        ((searchParametersMap.containsKey('taxId') && ! String.isEmpty(searchParametersMap.get('taxId'))) ? '<soap:dossier_number>' + searchParametersMap.get('taxId') + '</soap:dossier_number>' : '')  +
                        ((searchParametersMap.containsKey('name') && ! String.isEmpty(searchParametersMap.get('name'))) ? '<soap:trade_name>' + searchParametersMap.get('name') + '</soap:trade_name>' : '')  +
                        ((searchParametersMap.containsKey('registeredCity') && ! String.isEmpty(searchParametersMap.get('registeredCity'))) ? '<soap:city>' + searchParametersMap.get('registeredCity') + '</soap:city>' : '')  +
                        ((searchParametersMap.containsKey('registeredStreet') && ! String.isEmpty(searchParametersMap.get('registeredStreet'))) ? '<soap:street>' + searchParametersMap.get('registeredStreet') + '</soap:street>' : '')  +
                    '</soap:dutchBusinessSearch>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        request.setBody(body);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Return list of CreditCompany
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : companies
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchCompanies(Dom.XmlNode node) {
        List<CreditFactoryCompany> companiesFromSearchList = new List<CreditFactoryCompany>();
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessSearchResponse') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'results') {
                                        for (Dom.XmlNode resultsField : outField.getChildElements()) {
                                            if (resultsField.getName() == 'item') {
                                                CreditFactoryCompany company = new CreditFactoryCompany();
                                                company.recordType = 'Company.info';
                                                for (Dom.XmlNode itemField : resultsField.getChildElements()) {
                                                    if (itemField.getName() == 'legal_name') {
                                                        company.name = itemField.getText();
                                                    } else if (itemField.getName() == 'trade_name') {
                                                        company.tradeName = itemField.getText();
                                                    } else if (itemField.getName() == 'dossier_number') {
                                                        company.creditSystemCompanyNumber = itemField.getText();
                                                        company.identificationNumber = itemField.getText();
                                                        company.taxId = itemField.getText();
                                                    } else if (itemField.getName() == 'correspondence_street') {
                                                        company.street = itemField.getText();
                                                    } else if (itemField.getName() == 'correspondence_city') {
                                                        company.city = itemField.getText();
                                                    }
                                                }

                                                if (company.name == null) {
                                                    company.name = company.tradeName;
                                                }

                                                companiesFromSearchList.add(company);
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

        return companiesFromSearchList;
    }


    /*******************************************************************************
    *  Summary         : Get positions from company info
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : endpoint - Company.info endpoint,
                         userName - Company.info user,
                         password - Company.info password,
                         taxId - tax Id 
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest dutchBusinessGetPositions(String endpoint, String username, String password, String taxId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', 'https://ws1.webservices.nl/soap_doclit.php/dutchBusinessGetPositions');
        request.setTimeout(30000);
        String body = '' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://www.webservices.nl/soap/">' +
                '<soapenv:Header>' +
                    '<soap:HeaderLogin>' +
                        '<soap:username>' + username + '</soap:username>' +
                        '<soap:password>' + password + '</soap:password>' +
                    '</soap:HeaderLogin>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                    '<soap:dutchBusinessGetPositions>' +
                        '<soap:dossier_number>' + taxId + '</soap:dossier_number>' +
                    '</soap:dutchBusinessGetPositions>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        request.setBody(body);
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Summary         : Get employees from company.info response
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : xmldom – node from response
    *  Returns         : List<CreditCompanyEmployee>
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnCompanyInfoEmployees(Dom.XmlNode xmldom) {
        List<CreditFactoryCompany.CreditFactoryContact> employeesList = new List<CreditFactoryCompany.CreditFactoryContact>();
        for (Dom.XmlNode Body : xmldom.getChildElements()) {
            if (Body.getName() == 'Body') {
                for (Dom.XmlNode dutchBusinessGetPositionsResponse : Body.getChildElements()) {
                    if (dutchBusinessGetPositionsResponse.getName() == 'dutchBusinessGetPositionsResponse') {
                        for (Dom.XmlNode out : dutchBusinessGetPositionsResponse.getChildElements()) {
                            if (out.getName() == 'out') {
                                for (Dom.XmlNode positions : out.getChildElements()) {
                                    if (positions.getName() == 'positions') {
                                        for (Dom.XmlNode item : positions.getChildElements()) {
                                            if (item.getName() == 'item') {
                                                CreditFactoryCompany.CreditFactoryContact employee = new CreditFactoryCompany.CreditFactoryContact();
                                                for (Dom.XmlNode functionary : item.getChildElements()) {
                                                    if (functionary.getName() == 'functionary') {
                                                        for (Dom.XmlNode functionaryItem : functionary.getChildElements()) {
                                                            if (functionaryItem.getName() == 'first_name') {
                                                                employee.name = functionaryItem.getText();
                                                            }
                                                            if (functionaryItem.getName() == 'last_name') {
                                                                employee.name += ' ' + functionaryItem.getText();
                                                            }
                                                            employee.recordType = 'Company Info';
                                                            if (functionaryItem.getName() == 'date_of_birth') {
                                                                for (Dom.XmlNode dobItem : functionaryItem.getChildElements()) {
                                                                    if (dobItem.getName() == 'year') {
                                                                        employee.dateOfBirth = dobItem.getText();
                                                                    }
                                                                    if (dobItem.getName() == 'month') {
                                                                        employee.dateOfBirth += '.' + dobItem.getText();
                                                                    }
                                                                    if (dobItem.getName() == 'day') {
                                                                        employee.dateOfBirth += '.' + dobItem.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                    if (functionary.getName() == 'function_type') {
                                                        employee.companyRole = functionary.getText();
                                                    }
                                                }

                                                if (employee.name != null) {
                                                    employeesList.add(employee);
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

        return employeesList;
    }


    /*******************************************************************************
    *  Summary         : Generate dutchBusinessGetDossierV3 HTTP request.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : endpoint - Company.info endpoint,
                         userName - Company.info user,
                         password - Company.info password,
                         taxId - tax Id
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateDutchBusinessGetDossierV3Request(String endpoint, String username, String password, String taxId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', 'https://ws1.webservices.nl/soap_doclit.php/dutchBusinessGetDossierV3');
        request.setTimeout(30000);
        String body = generateDutchBusinessGetDossierV3RequestBody(username, password, taxId);
        request.setBody(body);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Name            : generateDutchBusinessGetDossierV3RequestBody(String username, String password, String kvk)
    *  Summary         : Generate XML String for request.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : userName - Company.info user,
                         password - Company.info password,
                         taxId - tax Id
    *  Returns         : body
    ******************************************************************************/
    public static String generateDutchBusinessGetDossierV3RequestBody(String username, String password, String taxId) {
        String body = '' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://www.webservices.nl/soap/">' +
                '<soapenv:Header>' +
                    '<soap:HeaderLogin>' +
                        '<soap:username>' + username + '</soap:username>' +
                        '<soap:password>' + password + '</soap:password>' +
                    '</soap:HeaderLogin>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                    '<soap:dutchBusinessGetDossierV3>' +
                        '<soap:dossier_number>' + taxId + '</soap:dossier_number>' +
                    '</soap:dutchBusinessGetDossierV3>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return body;
    }


    /*******************************************************************************
    *  Summary         : Return Company
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - node from response
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XmlNode node) {
        CreditFactoryCompany company = new CreditFactoryCompany();
        company.identificationNumber = returnIdentificationNumber(node);
        company.indicationMainEstablishment = returnIndicationMainEstablishment(node);
        company.rsinNumber = returnRsinNumber(node);
        company.legalForm = returnLegalForm(node);
        company.indicationOrganisation = returnIndicationOrganisation(node);
        company.name = returnTradeName(node);
        company.tradeName = returnTradeName(node);
        company.postCode = returnPostalCode(node);
        company.city = returnCity(node);
        company.street = returnStreet(node);
        company.houseNumber = returnHouseNumber(node);
        company.country = 'Netherlands';
        company.phone = returnPhone(node);
        company.mobile = returnMobile(node);
        company.website = returnWebsite(node);
        company.primarySbiCode = returnPrimarySbiCode(node);
        company.primarySbiCodeText = returnPrimarySbiCodeText(node);
        company.staffCompanyRange = returnStaffCompanyRange(node);
        company.indicationEconomicallyActive = returnIndicationEconomicallyActive(node);
        company.indicationNonMailing = returnIndicationNonMailing(node);
        company.indicationBankruptcy = returnIndicationBankruptcy(node);
        company.indicationDip = returnIndicationDip(node);
        company.authorizedShareCapital = returnAuthorizedShareCapital(node);
        company.authorizedShareCapitalCurrency = returnAuthorizedShareCapitalCurrency(node);
        company.paidUpShareCapital = returnPaidUpShareCapital(node);
        company.paidUpShareCapitalCurrency = returnPaidUpShareCapitalCurrency(node);
        company.issuedShareCapital = returnIssuedShareCapital(node);
        company.issuedShareCapitalCurrency = returnIssuedShareCapitalCurrency(node);
        company.continuationDate = returnContinuationDate(node);
        company.establishmentDate = returnEstablishmentDate(node);
        company.dateOfFoundation = returnDateOfFoundation(node);
        company.recordType = 'Company Info';
        return company;
    }


    /*******************************************************************************
    *  Summary         : Return identification number
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : identification number
    ******************************************************************************/
    public static String returnIdentificationNumber(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'dossier_number') {
                                        return outField.getText();
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
    *  Summary         : Return Indication Main Establishment.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : indication Main Establishment
    ******************************************************************************/
    public static String returnIndicationMainEstablishment(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'indication_main_establishment') {
                                        return outField.getText();
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
    *  Summary         : Return Rsin Number.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : rsin number
    ******************************************************************************/
    public static String returnRsinNumber(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'rsin_number') {
                                        return outField.getText();
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
    *  Summary         : Return Legal Form.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : legal form
    ******************************************************************************/
    public static String returnLegalForm(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'legal_form_text') {
                                        return outField.getText();
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
    *  Summary         : Return Indication Organisation Code.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : indication organization
    ******************************************************************************/
    public static String returnIndicationOrganisation(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'indication_organisation_code') {
                                        return CreditfactoryUtilities.returnIndicationOrganisation(outField.getText());
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
    *  Summary         : Return Trade Name.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : trade name
    ******************************************************************************/
    public static String returnTradeName(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'trade_name_full') {
                                        return outField.getText();
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
    *  Summary         : Return Postal Code.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : postal code
    ******************************************************************************/
    public static String returnPostalCode(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XmlNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                for (Dom.XmlNode formattedField : addressField.getChildElements()) {
                                                    if (formattedField.getName() == 'postcode') {
                                                        return formattedField.getText();
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
    *  Summary         : Return City.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : city
    ******************************************************************************/
    public static String returnCity(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XmlNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                for (Dom.XmlNode formattedField : addressField.getChildElements()) {
                                                    if (formattedField.getName() == 'city') {
                                                        return formattedField.getText();
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
    *  Summary         : Return Street.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : street
    ******************************************************************************/
    public static String returnStreet(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XmlNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                for (Dom.XmlNode formattedField : addressField.getChildElements()) {
                                                    if (formattedField.getName() == 'street') {
                                                        return formattedField.getText();
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
    *  Summary         : Return House Number.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : house number
    ******************************************************************************/
    public static String returnHouseNumber(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XmlNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                String houseNumber = '';
                                                for (Dom.XmlNode formattedField : addressField.getChildElements()) {
                                                    if (formattedField.getName() == 'house_number') {
                                                        houseNumber += formattedField.getText() + ' ';
                                                    } else if (formattedField.getName() == 'house_number_addition') {
                                                        houseNumber += formattedField.getText();
                                                    }
                                                }

                                                houseNumber = houseNumber.removeEnd(' ');
                                                return houseNumber;
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
    *  Summary         : Return Phone.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : phone
    ******************************************************************************/
    public static String returnPhone(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'telephone_number') {
                                        return outField.getText();
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
    *  Summary         : Return Mobile.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : mobile
    ******************************************************************************/
    public static String returnMobile(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'mobile_number') {
                                        return outField.getText();
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
    *  Summary         : Return Website.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : website
    ******************************************************************************/
    public static String returnWebsite(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'domain_name') {
                                        return outField.getText();
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
    *  Summary         : Return Primary Sbi Code.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : primary sbi code
    ******************************************************************************/
    public static String returnPrimarySbiCode(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'primary_sbi_code') {
                                        return outField.getText();
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
    *  Summary         : Return Primary Sbi Code Text.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : primary sbi code text
    ******************************************************************************/
    public static String returnPrimarySbiCodeText(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'primary_sbi_code_text') {
                                        return outField.getText();
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
    *  Summary         : Return Personnel.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : staff company range
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'personnel') {
                                        return outField.getText();
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
    *  Summary         : Return Indication Economically Active.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : indication economically active
    ******************************************************************************/
    public static String returnIndicationEconomicallyActive(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'indication_economically_active') {
                                        return outField.getText();
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
    *  Summary         : Return Indication Non Mailing.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : indication non mailing
    ******************************************************************************/
    public static String returnIndicationNonMailing(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'indication_non_mailing') {
                                        return outField.getText();
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
    *  Summary         : Return Indication Bankruptcy.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : indication bankruptcy
    ******************************************************************************/
    public static String returnIndicationBankruptcy(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'indication_bankruptcy') {
                                        return outField.getText();
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
    *  Summary         : Return Indication Dip.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : indication dip
    ******************************************************************************/
    public static String returnIndicationDip(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'indication_dip') {
                                        return outField.getText();
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
    *  Summary         : Return Authorized Share Capital.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : authorized share capital
    ******************************************************************************/
    public static String returnAuthorizedShareCapital(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'authorized_share_capital') {
                                        return outField.getText();
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
    *  Summary         : Return Authorized ShareCapital Currency.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : authorized share capital currency
    ******************************************************************************/
    public static String returnAuthorizedShareCapitalCurrency(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'authorized_share_capital_currency') {
                                        return outField.getText();
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
    *  Summary         : Return Paid Up Share Capital.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : paid up share capital
    ******************************************************************************/
    public static String returnPaidUpShareCapital(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'paid_up_share_capital') {
                                        return outField.getText();
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
    *  Summary         : Return Paid Up Share Capital Currency.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : paid up share capital currency
    ******************************************************************************/
    public static String returnPaidUpShareCapitalCurrency(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'paid_up_share_capital_currency') {
                                        return outField.getText();
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
    *  Summary         : Return Issued Share Capital.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : issued share capital
    ******************************************************************************/
    public static String returnIssuedShareCapital(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'issued_share_capital') {
                                        return outField.getText();
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
    *  Summary         : Return Issued Share Capital Currency.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : issued share capital currency
    ******************************************************************************/
    public static String returnIssuedShareCapitalCurrency(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'issued_share_capital_currency') {
                                        return outField.getText();
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
    *  Summary         : Return Date Of Foundation.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : date of foundation
    ******************************************************************************/
    public static String returnDateOfFoundation(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'founding_date') {
                                        String dateOfFoundation = '';
                                        for (Dom.XmlNode dateField : outField.getChildElements()) {
                                            if (dateField.getName() == 'year') {
                                                dateOfFoundation += dateField.getText();
                                            } else if (dateField.getName() == 'month') {
                                                dateOfFoundation += '-' + (dateField.getText().length() == 1 ? '0' + dateField.getText() : dateField.getText());
                                            } else if (dateField.getName() == 'day') {
                                                dateOfFoundation += '-' + (dateField.getText().length() == 1 ? '0' + dateField.getText() : dateField.getText());
                                            }
                                        }

                                        return dateOfFoundation;
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
    *  Summary         : Return Continuation Date.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : continuation date
    ******************************************************************************/
    public static String returnContinuationDate(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'continuation_date') {
                                        String continuationDate = '';
                                        for (Dom.XmlNode dateField : outField.getChildElements()) {
                                            if (dateField.getName() == 'year') {
                                                continuationDate += dateField.getText();
                                            } else if (dateField.getName() == 'month') {
                                                continuationDate += '-' + (dateField.getText().length() == 1 ? '0' + dateField.getText() : dateField.getText());
                                            } else if (dateField.getName() == 'day') {
                                                continuationDate += '-' + (dateField.getText().length() == 1 ? '0' + dateField.getText() : dateField.getText());
                                            }
                                        }

                                        return continuationDate;
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
    *  Summary         : Return Establishment Date.
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body from response
    *  Returns         : establishment date
    ******************************************************************************/
    public static String returnEstablishmentDate(Dom.XmlNode node) {
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XmlNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XmlNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'establishment_date') {
                                        String establishmentDate = '';
                                        for (Dom.XmlNode dateField : outField.getChildElements()) {
                                            if (dateField.getName() == 'year') {
                                                establishmentDate += dateField.getText();
                                            } else if (dateField.getName() == 'month') {
                                                establishmentDate += '-' + (dateField.getText().length() == 1 ? '0' + dateField.getText() : dateField.getText());
                                            } else if (dateField.getName() == 'day') {
                                                establishmentDate += '-' + (dateField.getText().length() == 1 ? '0' + dateField.getText() : dateField.getText());
                                            }
                                        }

                                        return establishmentDate;
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
    *  Summary         : return Error Message
    *  Created         : 09/09/2020 by Anton Buzak
    *  Parameters      : node - body node from response
    *  Returns         : -
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XmlNode node) {
        String errorMessage;
        for (Dom.XmlNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XmlNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'Fault') {
                        for (Dom.XmlNode faultField : bodyField.getChildElements()) {
                            if (bodyField.getName() == 'faultstring') {
                                errorMessage = bodyField.getText();
                            }
                        }
                    }
                }
            }
        }

        return errorMessage;
    }
}