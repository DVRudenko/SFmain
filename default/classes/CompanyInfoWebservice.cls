public class CompanyInfoWebservice {


    /*******************************************************************************
    *  Name            : generateSearchRequest()
    *  Summary         : Generate dutchBusinessSearch request to Company.info    
    *  CreatedDate     : 21/05/2018
    *  ModifiedDate    : -
    *  Parameters      : String endpoint - from CreditSystem custom setting, String userName - from CreditSystem custom setting, 
                         String password - from CreditSystem custom setting, 
                         String recordName - company name for search, String recordStreet - company street for search, 
                         String recordCity - company city for search, String kvk – identification number
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password,
                                                    String recordName, String recordStreet, 
                                                    String recordCity, String kvk) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', 'https://ws1.webservices.nl/soap_doclit.php/dutchBusinessSearch');
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
                    '<soap:dutchBusinessSearch>' +
                        '<soap:dossier_number>' + kvk + '</soap:dossier_number>' +
                        '<soap:trade_name>' + recordName + '</soap:trade_name>' +
                        '<soap:city>' + recordCity + '</soap:city>' +
                        '<soap:street>' + recordStreet + '</soap:street>' +
                    '</soap:dutchBusinessSearch>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        request.setBody(body);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Name            : returnSearchCompanies(Dom.XMLNode node)
    *  Summary         : Return list of CreditCompany    
    *  CreatedDate     : 21/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : List<CreditCompany>
    ******************************************************************************/
    public static List<CreditCompany> returnSearchCompanies(Dom.XMLNode node) {
        List<CreditCompany> companiesFromSearchList = new List<CreditCompany>();
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessSearchResponse') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'results') {
                                        for (Dom.XMLNode resultsField : outField.getChildElements()) {
                                            if (resultsField.getName() == 'item') {
                                                CreditCompany company = new CreditCompany();
                                                company.creditSystem = 'Company.info';
                                                company.isReportExists = true;
                                                for (Dom.XMLNode itemField : resultsField.getChildElements()) {
                                                    if (itemField.getName() == 'legal_name') {
                                                        company.name = itemField.getText();
                                                    } else if (itemField.getName() == 'trade_name') {
                                                        company.tradename = itemField.getText();
                                                    } else if (itemField.getName() == 'dossier_number') {
                                                        company.creditSystemCompanyNumber = itemField.getText();
                                                        company.identificationnumber = itemField.getText();
                                                    } else if (itemField.getName() == 'correspondence_street') {
                                                        company.street = itemField.getText();
                                                    } else if (itemField.getName() == 'correspondence_city') {
                                                        company.city = itemField.getText();
                                                    }
                                                }

                                                if (company.name == null || company.tradename == '') {
                                                    company.name = company.tradename;
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
    *  Name            : dutchBusinessGetPositions(String endpoint, String username, String password, String kvk)
    *  Summary         : Get positions from company info     
    *  CreatedDate     : 28/02/2018
    *  ModifiedDate    : 
    *  Parameters      : String endpoint – company.info endpoint url 
                         String username 
                         String password 
                         String kvk – identification number
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest dutchBusinessGetPositions(String endpoint, String username, String password, String kvk) {
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
                        '<soap:dossier_number>' + kvk + '</soap:dossier_number>' +
                    '</soap:dutchBusinessGetPositions>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        request.setBody(body);
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Name            : returnCompanyInfoEmployees(Dom.XMLNode xmldom)
    *  Summary         : Get employees from company.info response     
    *  CreatedDate     : 02/03/2018
    *  ModifiedDate    : 
    *  Parameters      : Dom.XMLNode xmldom – response
    *  Returns         : List<CreditCompanyEmployee>
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnCompanyInfoEmployees(Dom.XMLNode xmldom) {
        List<CreditCompanyEmployee> employeesList = new List<CreditCompanyEmployee>();
        for (Dom.XMLNode Body : xmldom.getChildElements()) {
            if (Body.getName() == 'Body') {
                for (Dom.XMLNode dutchBusinessGetPositionsResponse : Body.getChildElements()) {
                    if (dutchBusinessGetPositionsResponse.getName() == 'dutchBusinessGetPositionsResponse') {
                        for (Dom.XMLNode out : dutchBusinessGetPositionsResponse.getChildElements()) {
                            if (out.getName() == 'out') {
                                for (Dom.XMLNode positions : out.getChildElements()) {
                                    if (positions.getName() == 'positions') {
                                        for (Dom.XMLNode item : positions.getChildElements()) {
                                            if (item.getName() == 'item') {
                                                CreditCompanyEmployee employee = new CreditCompanyEmployee();
                                                for (Dom.XMLNode functionary : item.getChildElements()) {
                                                    if (functionary.getName() == 'functionary') {
                                                        for (Dom.XMLNode functionaryItem : functionary.getChildElements()) {                                            
                                                            if (functionaryItem.getName() == 'first_name') {
                                                                employee.ename = functionaryItem.getText();
                                                            }
                                                            if (functionaryItem.getName() == 'last_name') {
                                                                employee.ename += ' ' + functionaryItem.getText();
                                                            }
                                                            employee.type = 'Company.info';
                                                            if (functionaryItem.getName() == 'date_of_birth') {
                                                                for (Dom.XMLNode dobItem : functionaryItem.getChildElements()) {
                                                                    if (dobItem.getName() == 'year') {
                                                                        employee.dateofbirth = dobItem.getText();
                                                                    }
                                                                    if (dobItem.getName() == 'month') {
                                                                        employee.dateofbirth += '.' + dobItem.getText();
                                                                    }
                                                                    if (dobItem.getName() == 'day') {
                                                                        employee.dateofbirth += '.' + dobItem.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                    if (functionary.getName() == 'function_type') {
                                                        employee.companyRole = functionary.getText();
                                                    }
                                                }

                                                if (employee.ename != null) {
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
    *  Name            : generateDutchBusinessGetDossierV3Request(String endpoint, String username, String password, String kvk)
    *  Summary         : Generate dutchBusinessGetDossierV3 HTTP request.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String endpoint – company.info endpoint url 
                         String username 
                         String password 
                         String kvk – identification number
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateDutchBusinessGetDossierV3Request(String endpoint, String username, String password, String kvk) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', 'https://ws1.webservices.nl/soap_doclit.php/dutchBusinessGetDossierV3');
        request.setTimeout(30000);
        String body = generateDutchBusinessGetDossierV3RequestBody(username, password, kvk);
        request.setBody(body);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Name            : generateDutchBusinessGetDossierV3RequestBody(String username, String password, String kvk)
    *  Summary         : Generate XML String for request.
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String generateDutchBusinessGetDossierV3RequestBody(String username, String password, String kvk) {
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
                        '<soap:dossier_number>' + kvk + '</soap:dossier_number>' +
                    '</soap:dutchBusinessGetDossierV3>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';
        return body;
    }


    /*******************************************************************************
    *  Name            : returnReportCompany(Dom.XMLNode node)
    *  Summary         : Return Company.
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static CreditCompany returnReportCompany(Dom.XMLNode node) {
        CreditCompany company = new CreditCompany();
        company.identificationnumber = returnIdentificationNumber(node); 
        company.indicationMainEstablishment = returnIndicationMainEstablishment(node);
        company.rsinNumber = returnRsinNumber(node);
        company.legalform = returnLegalForm(node);
        company.indicationOrganisation = returnIndicationOrganisation(node);
        company.name = returnTradeName(node);
        company.tradename = returnTradeName(node);
        company.postcode = returnPostalCode(node);
        company.city = returnCity(node);
        company.street = returnStreet(node);
        company.housenumber = returnHouseNumber(node);
        company.country = returnCountry(node);
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
        company.dateoffoundation = returnDateOfFoundation(node);
        return company;
    }


    /*******************************************************************************
    *  Name            : returnIdentificationNumber()
    *  Summary         : Return identification number
    *  CreatedDate     : 25/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIdentificationNumber(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIndicationMainEstablishment()
    *  Summary         : Return Indication Main Establishment.
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationMainEstablishment(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnRsinNumber(Dom.XMLNode node)
    *  Summary         : Return Rsin Number.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnRsinNumber(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnLegalForm(Dom.XMLNode node)
    *  Summary         : Return Legal Form.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnLegalForm(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIndicationOrganisation(Dom.XMLNode node)
    *  Summary         : Return Indication Organisation Code.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationOrganisation(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnTradeName(Dom.XMLNode node)
    *  Summary         : Return Trade Name.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnTradeName(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnPostalCode(Dom.XMLNode node)
    *  Summary         : Return Postal Code.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostalCode(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XMLNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                for (Dom.XMLNode formattedField : addressField.getChildElements()) {
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
    *  Name            : returnCity(Dom.XMLNode node)
    *  Summary         : Return City.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCity(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XMLNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                for (Dom.XMLNode formattedField : addressField.getChildElements()) {
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
    *  Name            : returnStreet(Dom.XMLNode node)
    *  Summary         : Return Street.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStreet(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XMLNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                for (Dom.XMLNode formattedField : addressField.getChildElements()) {
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
    *  Name            : returnHouseNumber(Dom.XMLNode node)
    *  Summary         : Return House Number.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnHouseNumber(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XMLNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                String houseNumber = '';
                                                for (Dom.XMLNode formattedField : addressField.getChildElements()) {
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
    *  Name            : returnCountry(Dom.XMLNode node)
    *  Summary         : Return Country.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCountry(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'correspondence_address') {
                                        for (Dom.XMLNode addressField : outField.getChildElements()) {
                                            if (addressField.getName() == 'formatted') {
                                                for (Dom.XMLNode formattedField : addressField.getChildElements()) {
                                                    if (formattedField.getName() == 'country') {
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
    *  Name            : returnPhone(Dom.XMLNode node)
    *  Summary         : Return Phone.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPhone(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnMobile(Dom.XMLNode node)
    *  Summary         : Return Mobile.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnMobile(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnWebsite(Dom.XMLNode node)
    *  Summary         : Return Website.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnWebsite(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnPrimarySbiCode(Dom.XMLNode node)
    *  Summary         : Return Primary Sbi Code.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPrimarySbiCode(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnPrimarySbiCodeText(Dom.XMLNode node)
    *  Summary         : Return Primary Sbi Code Text.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPrimarySbiCodeText(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnStaffCompanyRange(Dom.XMLNode node)
    *  Summary         : Return Personnel.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIndicationEconomicallyActive(Dom.XMLNode node)
    *  Summary         : Return Indication Economically Active.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationEconomicallyActive(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIndicationNonMailing(Dom.XMLNode node)
    *  Summary         : Return Indication Non Mailing.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationNonMailing(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIndicationBankruptcy(Dom.XMLNode node)
    *  Summary         : Return Indication Bankruptcy.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationBankruptcy(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIndicationDip(Dom.XMLNode node)
    *  Summary         : Return Indication Dip.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationDip(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnAuthorizedShareCapital(Dom.XMLNode node)
    *  Summary         : Return Authorized Share Capital.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnAuthorizedShareCapital(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnAuthorizedShareCapitalCurrency(Dom.XMLNode node)
    *  Summary         : Return Authorized ShareCapital Currency.
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnAuthorizedShareCapitalCurrency(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnPaidUpShareCapital(Dom.XMLNode node)
    *  Summary         : Return Paid Up Share Capital.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPaidUpShareCapital(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnPaidUpShareCapitalCurrency(Dom.XMLNode node)
    *  Summary         : Return Paid Up Share Capital Currency.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPaidUpShareCapitalCurrency(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIssuedShareCapital(Dom.XMLNode node)
    *  Summary         : Return Issued Share Capital.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIssuedShareCapital(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnIssuedShareCapitalCurrency(Dom.XMLNode node)
    *  Summary         : Return Issued Share Capital Currency.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIssuedShareCapitalCurrency(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
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
    *  Name            : returnDateOfFoundation(Dom.XMLNode node)
    *  Summary         : Return Date Of Foundation.
    *  CreatedDate     : 21/06/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateOfFoundation(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'founding_date') {
                                        String dateOfFoundation = '';
                                        for (Dom.XMLNode dateField : outField.getChildElements()) {
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
    *  Name            : returnContinuationDate(Dom.XMLNode node)
    *  Summary         : Return Continuation Date.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : 21/06/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnContinuationDate(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'continuation_date') {
                                        String continuationDate = '';
                                        for (Dom.XMLNode dateField : outField.getChildElements()) {
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
    *  Name            : returnEstablishmentDate(Dom.XMLNode node)
    *  Summary         : Return Establishment Date.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : 21/06/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnEstablishmentDate(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'dutchBusinessGetDossierV3Response') {
                        for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                            if (responseField.getName() == 'out') {
                                for (Dom.XMLNode outField : responseField.getChildElements()) {
                                    if (outField.getName() == 'establishment_date') {
                                        String establishmentDate = '';
                                        for (Dom.XMLNode dateField : outField.getChildElements()) {
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
    *  Created         : 18/02/2020
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