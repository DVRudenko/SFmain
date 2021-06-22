public class CreditReformWebserviceLU {
    public static final String CREDIT_SYSTEM_NAME = 'CreditreformLU';

    /*******************************************************************************
    *  Name            : generateSearchRequest()
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String endpoint - Creditreform endpoint url, String userName - Creditreform account name, 
    					 String password - Creditreform password, String apikey - Creditreform apikey, 
                         String recordName - company name for search, String recordStreet - company street for search, 
                         String recordCity - company city for search, String recordHousenumber - company house number for search, 
                         String recordPostalCode - company postal code for search, String creditSystemId - Id of Creditreform company
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password, String apikey,
                                                    String recordName, String recordStreet, String recordCity, String recordHousenumber, 
                                                    String creditSystemId) {
        try {
            String body = generateSearchXML(userName, password, apiKey, recordName, recordStreet, recordCity, recordHousenumber, creditSystemId);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(body);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');

            return request;
        } catch (Exception e) {
            System.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Search request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateSearchXML()
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, String apikey - Creditreform apikey, 
    					 String opportunityName - company name for search, String street - company street for search, 
                         String city - company city for search, String houseNumber - company house number for search, 
                         String postalCode - company postal code for search, String creditSystemId - Id of Creditreform company
    *  Returns         : String
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, String apikey, String opportunityName, String street, 
                                           String city, String housenumber, String creditSystemId) {
        opportunityName = opportunityName.replace('&', ' ');
        String xmlbody = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
           '<soap:Header/>'+
           '<soap:Body>'+
              '<ns:searchRequest>'+
                 '<ns:header>'+
                    '<ns:communicationlanguage>en</ns:communicationlanguage>'+
                    // '<ns:transmissiontimestamp>2018-09-28T09:37:01.95</ns:transmissiontimestamp>'+
                    '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>'+
                    '<ns:keylistversion>20</ns:keylistversion>'+
                    '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>'+
                    '<ns:clientapplicationversion>3</ns:clientapplicationversion>'+
                    '<ns:useraccount>'+ userName +'</ns:useraccount>'+
                    '<ns:generalpassword>'+ password +'</ns:generalpassword>'+
                    '<ns:individualpassword>'+ apikey +'</ns:individualpassword>'+
                 '</ns:header>'+
                 '<ns:body>'+
                    '<ns:searchtype>SETY-1</ns:searchtype>'+
                    ((creditSystemId != null && creditSystemId != '') ? '<ns:identificationnumber>' + creditSystemId + '</ns:identificationnumber>' : '') +
                    '<ns:companyname>'+ opportunityName +'</ns:companyname>' +
                    ((street != null && street != '') ? '<ns:street>'+ street +'</ns:street>' : '') +
                    ((housenumber != null && housenumber != '' && housenumber.replaceAll('[^0-9]', '') != '') ? '<ns:housenumber>'+ housenumber.replaceAll('[^0-9]', '') +'</ns:housenumber>' : '') +
                    (city != null ? '<ns:city>'+ city +'</ns:city>' : '') +
                    '<ns:country>LU</ns:country>' +
                 '</ns:body>'+
              '</ns:searchRequest>'+
           '</soap:Body>'+
        '</soap:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : generateReportRequest(String endpoint, String userName, String password, String apikey, String companyId)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String endpoint - Creditreform endpoint url, String userName - Creditreform account name, 
    					 String password - Creditreform password, String apikey - Creditreform apikey, 
    					 String companyId - Id of Credit System Company
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String apikey,
                                                    String companyId) {
        try {
            String body = generateReportXML(userName, password, apiKey, companyId);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(body);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');

            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Report request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateReportXML(String userName, String password, String apikey, String companyId)
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, 
                         String apikey - Creditreform apikey, String companyId - Id of Credit System Company
    *  Returns         : String
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String apikey, 
                                           String companyId) {
        String xmlbody = '<soap:Envelope xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018" xmlns:soap="http://www.w3.org/2003/05/soap-envelope">'+
                '<soap:Header></soap:Header>'+
                '<soap:Body>'+
                    '<ns:reportRequest>'+
                        '<ns:header>'+
                            '<ns:communicationlanguage>de</ns:communicationlanguage>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>'+
                            '<ns:keylistversion>20</ns:keylistversion>'+
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>'+
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>'+
                            '<ns:useraccount>'+ userName +'</ns:useraccount>'+
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>'+
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>'+
                        '</ns:header>'+
                        '<ns:body>'+
                            '<ns:identificationnumber>' + companyId + '</ns:identificationnumber>'+
                            '<ns:legitimateinterest>LEIN-100</ns:legitimateinterest>'+
                            '<ns:reportlanguage>de</ns:reportlanguage>'+
                            '<ns:producttype>PRTY-5</ns:producttype>'+
                        '</ns:body>'+
                    '</ns:reportRequest>'+
                '</soap:Body>'+
            '</soap:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : generateOrderRequest(String endpoint, String userName, String password, 
                         String city, String companyName, String postalCode)
    *  Summary         : generate HTTP Request to CreditReform    
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String endpoint - Creditreform endpoint url, String userName - Creditreform account name, 
                         String password - Creditreform password, String apiKey - Creditreform api key, 
                         String name - company name, String postalCode - company postal code, String city - company city, 
                         String houseNumber - company house number, String orderSpecifyingText - company additional information
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateOrderRequest(String endpoint, String userName, String password, String apiKey, String name, 
                                                   String postalCode, String city, String street, String houseNumber, String orderSpecifyingText) {
        try {
            String xmlBody = generateOrderXML(userName, password, apiKey, name, postalCode, city, street, houseNumber, orderSpecifyingText);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(xmlBody);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateOrderXML(String userName, String password, 
                         String city, String companyName, String postalCode)
    *  Summary         : generate XML String to call CreditReform order    
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String name - company name,
                         String postalCode - company postal code, String city - company city,
                         String houseNumber - company house number, String orderSpecifyingText - company additional information
    *  Returns         : String
    ******************************************************************************/
    public static String generateOrderXML(String userName, String password, String apiKey, String name, String postalCode, String city, 
                                          String street, String houseNumber, String orderSpecifyingText) {
        String xmlBody = 
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
                '<soap:Header/>' +
                '<soap:Body>' +
                    '<ns:orderRequest>' +
                        '<ns:header>' +
                            '<ns:communicationlanguage>en</ns:communicationlanguage>' +
                            // '<ns:transmissiontimestamp>2018-09-28T10:07:00.00</ns:transmissiontimestamp>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>' +
                            '<ns:keylistversion>20</ns:keylistversion>' +
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>' +
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>' +
                            '<ns:useraccount>'+ userName +'</ns:useraccount>' +
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>' +
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>' +
                        '</ns:header>' +
                        '<ns:body>' +
                            '<ns:producttype>PRTY-2</ns:producttype>' +
                            '<ns:ordertype>ORTY-1</ns:ordertype>' +
                            '<ns:legitimateinterest>LEIN-100</ns:legitimateinterest>' +
                            '<ns:reportlanguage>de</ns:reportlanguage>' +
                            '<ns:company>' +
                                '<ns:companyname>' + name + '</ns:companyname>' +
                            '</ns:company>' +
                            ((street != null && street != '') ? '<ns:street>'+ street +'</ns:street>' : '') +
                            ((houseNumber != null && houseNumber != '') ? '<ns:housenumber>'+ houseNumber +'</ns:housenumber>' : '') +
                            '<ns:postcode>'+ postalCode +'</ns:postcode>' +
                            '<ns:city>' + city + '</ns:city>' +
                            '<ns:country>LU</ns:country>' +
                            ((orderSpecifyingText != null && orderSpecifyingText != '') ? '<ns:orderspecifyingtext>'+ orderSpecifyingText +'</ns:orderspecifyingtext>' : '') +
                        '</ns:body>' +
                    '</ns:orderRequest>' +
                '</soap:Body>' +
            '</soap:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : generateMailboxDirectoryRequest(String endpoint, String userName, String password, String apiKey, String referenceNumber)
    *  Summary         : generate HTTP Request to CreditReform    
   	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String endpoint - Creditreform  endpoint url, String userName - Creditreform account name, 
                         String password - Creditreform password, String apiKey - Creditreform api key,
                         String referenceNumber - order reference number
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateMailboxDirectoryRequest(String endpoint, String userName, String password,
                                                              String apiKey, String referenceNumber) {
        try {
            String xmlBody = generateMailboxDirectoryXML(userName, password, apiKey, referenceNumber);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(xmlBody);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Mailbox Directory request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateMailboxDirectoryXML(String userName, String password, String apiKey, String referenceNumber)
    *  Summary         : generate XML String to call CreditReform order    
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String referenceNumber - order reference number
    *  Returns         : String
    ******************************************************************************/
    public static String generateMailboxDirectoryXML(String userName, String password, String apiKey, String referenceNumber) {
        String xmlBody = 
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
               '<soap:Header/>' +
               '<soap:Body>' +
                    '<ns:mailboxdirectoryRequest>' +
                        '<ns:header>' +
                            '<ns:communicationlanguage>en</ns:communicationlanguage>' +
                            // '<ns:transmissiontimestamp>2017-12-18T11:00:00.00</ns:transmissiontimestamp>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>' +
                            '<ns:keylistversion>20</ns:keylistversion>' +
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>' +
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>' +
                            '<ns:useraccount>'+ userName +'</ns:useraccount>' +
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>' +
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>' +
                        '</ns:header>' +
                        '<ns:body>' +
                            '<ns:referencenumber>' + referenceNumber + '</ns:referencenumber>' +
                            '<ns:openorders>false</ns:openorders>' +
                            '<ns:entriesread>false</ns:entriesread>' +
                            '<ns:entriesunread>true</ns:entriesunread>' +
                            '<ns:deliverytypeupdate>true</ns:deliverytypeupdate>' +
                            '<ns:deliverytypereport>true</ns:deliverytypereport>' +
                            '<ns:deliverytypestatusreply>true</ns:deliverytypestatusreply>' +
                            '<ns:deliverytypesupplement>true</ns:deliverytypesupplement>' +
                            '<ns:deliverytypestockdelivery>true</ns:deliverytypestockdelivery>' +
                        '</ns:body>' +
                    '</ns:mailboxdirectoryRequest>' +
                '</soap:Body>' +
            '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Name            : generateMailboxEntryRequest(String endpoint, String userName, String password, String apiKey, String mailboxEntryNumber)
    *  Summary         : generate HTTP Request to CreditReform    
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String endpoint - endpoint url, String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String mailboxEntryNumber - number of checked mailbox entry
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateMailboxEntryRequest(String endpoint, String userName, String password, 
                                                          String apiKey, String mailboxEntryNumber) {
        try {
            String xmlBody = generateMailboxEntryXML(userName, password, apiKey, mailboxEntryNumber);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(xmlBody);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Mailbox Entry request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateMailboxEntryXML(String userName, String password, String apiKey, String mailboxEntryNumber)
    *  Summary         : generate XML String to call CreditReform order    
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String mailboxEntryNumber - number of checked mailbox entry
    *  Returns         : String
    ******************************************************************************/
    public static String generateMailboxEntryXML(String userName, String password, String apiKey, String mailboxEntryNumber) {
        String xmlbody =
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
                '<soap:Header/>' +
                '<soap:Body>' +
                    '<ns:mailboxentryRequest>' +
                        '<ns:header>' +
                            '<ns:communicationlanguage>en</ns:communicationlanguage>' +
                            // '<ns:transmissiontimestamp>2017-12-18T11:00:00.00</ns:transmissiontimestamp>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>' +
                            '<ns:keylistversion>20</ns:keylistversion>' +
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>' +
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>' +
                            '<ns:useraccount>'+ userName +'</ns:useraccount>' +
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>' +
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>' +
                        '</ns:header>' +
                        '<ns:body>' +
                            '<ns:mailboxentrynumber>' + mailboxEntryNumber + '</ns:mailboxentrynumber>' +
                        '</ns:body>' +
                    '</ns:mailboxentryRequest>' +
                '</soap:Body>' +
            '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Name            : returnSearchCompany(Dom.XMLNode node)
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompany> returnSearchCompany(Dom.XMLNode node) {
        try {
            List<CreditCompany> companiesFromSearch = new List<CreditCompany>();
            for (Dom.XMLNode hit : node.getChildElements()) {
                if (hit.getName() == 'hit') {
                    CreditCompany company = new CreditCompany();
                    company.isReportExists = true;
                    for (Dom.XMLNode field : hit.getChildElements()) {
                        if (field.getName() == 'companyname') {
                            company.name = field.getText();
                        }
                        if (field.getName() == 'identificationnumber') {
                            company.identificationnumber = field.getText();
                            company.creditSystemCompanyNumber = company.identificationnumber.subString(4, 14);
                        }
                        if (field.getName() == 'tradename') {
                            company.tradename = field.getText();
                        }
                        if (field.getName() == 'street') {
                            company.street = field.getText();
                        }
                        if (field.getName() == 'housenumber') {
                            company.housenumber = field.getText();
                        }
                        if (field.getName() == 'postcode') {
                            company.postcode = field.getText();
                        }
                        if (field.getName() == 'city') {
                            company.city = field.getText();
                        }
                        if (field.getName() == 'operationalstatus') {
                            for (Dom.XMLNode status : field.getChildElements()) {
                                if (status.getName() == 'designation') {
                                    company.status = status.getText();
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
            throw new CreditFactoryException('Parsing Search Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnReportCompany(Dom.XMLNode node, String creditSystemCompanyNumber)
    *  Summary         : Return Company
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response, String creditSystemCompanyNumber - Id of Creditreform company
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static CreditCompany returnReportCompany(Dom.XMLNode node, String creditSystemCompanyNumber) {
        try {
            CreditCompany selectedCompany = new CreditCompany();
            selectedCompany.creditSystemCompanyNumber = creditSystemCompanyNumber.subString(4, 14);
            selectedCompany.referencenumber = returnReferenceNumber(node);
            selectedCompany.classRating = CreditFactoryUtilities.returnArabic(returnClassRating(node));
            selectedCompany.solvencyIndex = returnSolvencyIndex(node);
            selectedCompany.development = returnDevelopment(node);
            selectedCompany.turnOver = returnTurnOver(node);
            selectedCompany.legalform = returnLegalForm(node);
            selectedCompany.vatid = returnVatId(node);
            selectedCompany.taxnumber = returnTaxNumber(node);
            selectedCompany.datelegalform = returnDateLegalForm(node);
            selectedCompany.registerNumber = returnRegisterId(node);
            selectedCompany.datelastregisterentry = returnDateLastRegisterEntry(node);
            selectedCompany.countyCourt = returnCountyCourt(node);
            selectedCompany.paymentBehaviour = returnPaymentBehaviour(node);
            selectedCompany.staffcompanyrange = returnStaffCompanyRange(node);
            selectedCompany.creditLimit = returnCreditLimit(node);
            selectedCompany.creditLimitCurrency = returnCreditLimitCurrency(node);
            selectedCompany.creditDecision = returnCreditDecision(node);
            selectedCompany.dateoffoundation = returnDateoffoundation(node);
            selectedCompany.ageofcompany = returnAgeofcompany(node);
            selectedCompany.firstlegalform = returnFirstlegalform(node);
            selectedCompany.status = returnStatus(node);
            selectedCompany.name = returnName(node);
            selectedCompany.tradename = returnTradename(node);
            selectedCompany.street = returnStreet(node);
            selectedCompany.housenumber = returnHousenumber(node);
            selectedCompany.postcode = returnPostcode(node);
            selectedCompany.city = returnCity(node);
            selectedCompany.country = returnCountry(node);
            selectedCompany.phone = returnPhone(node);
            selectedCompany.fax = returnFax(node);
            selectedCompany.mobile = returnMobile(node);
            selectedCompany.email = returnEmail(node);
            selectedCompany.website = returnWebsite(node);
            selectedCompany.identificationnumber = creditSystemCompanyNumber;
            return selectedCompany;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnReportCompanyEmployees(Dom.XMLNode node)
    *  Summary         : Return Company Employees
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnReportCompanyEmployees(Dom.XMLNode node) {
        List<CreditCompanyEmployee> companyEmployeesList = returnEmployees(node);
        return companyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : returnEmployees(Dom.XMLNode node)
    *  Summary         : Return Company Employees
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnEmployees(Dom.XMLNode node) {
        List<CreditCompanyEmployee> companyEmployeesList = new List<CreditCompanyEmployee>();

        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'deputymanagement') {
                        for (Dom.XMLNode deputymanagementfields : reportfields.getChildElements()) {
                            if (deputymanagementfields.getName() == 'participantcapacities') {
                                companyEmployeesList.addAll(returnEmployee(deputymanagementfields.getChildElements()));
                                for (Dom.XMLNode deputymanagementfeildsInner : deputymanagementfields.getChildElements()) {
                                    if (deputymanagementfeildsInner.getName() == 'active') {
                                        for (Dom.XMLNode activefields : deputymanagementfeildsInner.getChildElements()) {
                                            if (activefields.getName() == 'complementaryparticipantcapacities') {
                                                for (Dom.XMLNode complementaryparticipantcapacitiesFields : activefields.getChildElements()) {
                                                    if (complementaryparticipantcapacitiesFields.getName() == 'participantcapacities') {
                                                        companyEmployeesList.addAll(returnEmployee(complementaryparticipantcapacitiesFields.getChildElements()));
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
        return companyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : returnEmployee(Dom.XMLNode node)
    *  Summary         : Return Company Employees
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Dom.XMLNode> fields - fields of participantcapacities node
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnEmployee(List<Dom.XMLNode> fields) {
        String eType = '';
        List<CreditCompanyEmployee> currentEmployeesList = new List<CreditCompanyEmployee>();
        for (Dom.XMLNode participantcapacitiesFields : fields) {

            if (participantcapacitiesFields.getName() == 'capacity') {
                for (Dom.XMLNode capacityFields : participantcapacitiesFields.getChildElements()) {
                    if (capacityFields.getName() == 'designation') {
                        eType = '';
                        eType = capacityFields.getText();
                        break;
                    }
                }
            }
            if (participantcapacitiesFields.getName() == 'active') {
                CreditCompanyEmployee currentEmployee = new CreditCompanyEmployee();
                currentEmployee.type = eType;
                for (Dom.XMLNode activeFields : participantcapacitiesFields.getChildElements()) {
                    if (activeFields.getName() == 'identificationnumber') {
                        currentEmployee.enumber = activeFields.getText();
                    }

                    if (activeFields.getName() == 'privateperson') {
                        for (Dom.XMLNode privatepersonFields : activeFields.getChildElements()) {
                            if (privatepersonFields.getName() == 'firstname') {
                                if (String.isEmpty(currentEmployee.ename)) {
                                    currentEmployee.ename = privatepersonFields.getText();
                                } else {
                                    currentEmployee.ename = currentEmployee.ename + ' ' + privatepersonFields.getText();
                                }
                            }

                            if (privatepersonFields.getName() == 'surname') {
                                if (String.isEmpty(currentEmployee.ename)) {
                                    currentEmployee.ename = privatepersonFields.getText();
                                } else {
                                    currentEmployee.ename = currentEmployee.ename + ' ' + privatepersonFields.getText();
                                }
                            }

                            if (privatepersonFields.getName() == 'dateofbirth') {
                                currentEmployee.dateofbirth = privatepersonFields.getText();
                            }
                        }
                    }

                    if (activeFields.getName() == 'participatingsince') {
                        currentEmployee.participationdate = activeFields.getText();
                    }

                    if (activeFields.getName() == 'country') {
                        for (Dom.XMLNode countryFields : activeFields.getChildElements()) {
                            if (countryFields.getName() == 'key') {
                                if (String.isEmpty(currentEmployee.address)) {
                                    currentEmployee.address = activeFields.getText();
                                } else {
                                    currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                                }
                            }
                        }
                    }

                    if (activeFields.getName() == 'city') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }

                    if (activeFields.getName() == 'street') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }

                    if (activeFields.getName() == 'housenumber') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }

                    if (activeFields.getName() == 'postcode') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }
                }
                if (currentEmployee.address != null) {
                    currentEmployee.address = currentEmployee.address.removeEnd(', ');
                }
                currentEmployeesList.add(currentEmployee);
            }
        }

        return currentEmployeesList;
    }


    /*******************************************************************************
    *  Name            : returnReferenceNumber(Dom.XMLNode node)
    *  Summary         : Return Company Employees
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnReferenceNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'referencenumber') {
                return field.getText();
                break;
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnClassRating(Dom.XMLNode node)
    *  Summary         : Return Class Rating.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : 14/06/2019
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnClassRating(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'solvencyfinanceindustry') {
                        for (Dom.XMLNode industryfields : reportfields.getChildElements()) {
                            if (industryfields.getName() == 'class') {
                                return industryfields.getText();
                            }
                        }
                    }

                    if (reportfields.getName() == 'solvencyindex') {
                        for (Dom.XMLNode indexFields : reportfields.getChildElements()) {
                            if (indexFields.getName() == 'solvencyindextwozero') {
                                return CreditFactoryUtilities.returnRatingBasedOnSolvency(indexFields.getText(), 'Luxembourg');
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnSolvencyIndex(Dom.XMLNode node)
    *  Summary         : Return Solvency Index.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnSolvencyIndex(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'solvencyindex') {
                        for (Dom.XMLNode indexFields : reportfields.getChildElements()) {
                            if (indexFields.getName() == 'solvencyindextwozero') {
                                return indexFields.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDevelopment(Dom.XMLNode node)
    *  Summary         : Return Development.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnDevelopment(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'businessdevelopment') {
                        for (Dom.XMLNode developmentfields : reportfields.getChildElements()) {
                            if (developmentfields.getName() == 'businessdevelopment') {
                                for (Dom.XMLNode development2fields : developmentfields.getChildElements()) {
                                    if (developmentfields.getName() == 'grade') {
                                        return development2fields.getText();
                                        break;
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
    *  Name            : returnTurnOver(Dom.XMLNode node)
    *  Summary         : Return Turn Over.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnTurnOver(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'turnovercompanyrange') {
                        for (Dom.XMLNode turnovercompanyrangeFields : reportfields.getChildElements()) {
                            if (turnovercompanyrangeFields.getName() == 'range') {
                                return turnovercompanyrangeFields.getText();
                                break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnLegalForm(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'legalform') {
                        for (Dom.XMLNode legalformfields : reportfields.getChildElements()) {
                            if (legalformfields.getName() == 'presentlegalform') {
                                for (Dom.XMLNode presentlegalformfields : legalformfields.getChildElements()) {
                                    if (presentlegalformfields.getName() == 'designation') {
                                        return presentlegalformfields.getText();
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
    *  Summary         : Return Vat Id.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : vat Id
    ******************************************************************************/
    public static String returnVatId(Dom.XmlNode node) {
        for (Dom.XmlNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XmlNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'taxdata') {
                        for (Dom.XmlNode taxdatafields : reportfields.getChildElements()) {
                            if (taxdatafields.getName() == 'vatid') {
                                String vatId = taxdatafields.getText();
                                if (vatId != null) {
                                    vatId = vatId.replaceAll('\\s+', '').replace('.', '');
                                }

                                return vatId;
                            }
                        }
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Tax Number.
    *  CreatedDate     : 13/11/2018
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : tax number
    ******************************************************************************/
    public static String returnTaxNumber(Dom.XmlNode node) {
        for (Dom.XmlNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XmlNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'taxdata') {
                        for (Dom.XmlNode taxdatafields : reportfields.getChildElements()) {
                            if (taxdatafields.getName() == 'taxnumber') {
                                String taxId = taxdatafields.getText();
                                if (taxId != null) {
                                    taxId = taxId.replace('/', '');
                                }

                                return taxId;
                            }
                        }
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnDateLegalForm(Dom.XMLNode node)
    *  Summary         : Return Date Legal Form.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnDateLegalForm(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'datelegalform') {
                                return registerfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnRegisterId(Dom.XMLNode node)
    *  Summary         : Return Register Id.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnRegisterId(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'registerid') {
                                return registerfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDateLastRegisterEntry(Dom.XMLNode node)
    *  Summary         : Return Date of Last Register Entry.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnDateLastRegisterEntry(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'datelastregisterentry') {
                                return registerfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCountyCourt(Dom.XMLNode node)
    *  Summary         : Return County Court.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnCountyCourt(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'register') {
                                String countyCourt = '';
                                for (Dom.XMLNode register2fields : registerfields.getChildElements()) {
                                    if (register2fields.getName() == 'shortdesignationcourt') {
                                        countyCourt += register2fields.getText();
                                    }

                                    if (register2fields.getName() == 'city') {
                                        countyCourt += ' ' + register2fields.getText();
                                    }

                                    if (register2fields.getName() == 'postcode') {
                                        countyCourt += ' ' + register2fields.getText();
                                    }
                                }
                                return countyCourt;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPaymentBehaviour(Dom.XMLNode node)
    *  Summary         : Return Payment Behaviour.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnPaymentBehaviour(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'paymentmode') {
                        for (Dom.XMLNode paymentmodeFields : reportfields.getChildElements()) {
                            if (paymentmodeFields.getName() == 'paymentmode') {
                                String paymentBehaviour = '';
                                for (Dom.XMLNode paymentmodeFields2 : paymentmodeFields.getChildElements()) {
                                    if (paymentmodeFields2.getName() == 'key') {
                                        paymentBehaviour = paymentBehaviour + paymentmodeFields2.getText() + ' ';
                                    }
                                    if (paymentmodeFields2.getName() == 'designation') {
                                        paymentBehaviour = paymentBehaviour + paymentmodeFields2.getText() + ' ';
                                    }
                                    if (paymentmodeFields2.getName() == 'grade') {
                                        paymentBehaviour = paymentBehaviour + paymentmodeFields2.getText() + ' ';
                                    }
                                    return paymentBehaviour;
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
    *  Summary         : Return Staff Company Range.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'staffcompanyrange') {
                        for (Dom.XMLNode staffcompanyrangefields : reportfields.getChildElements()) {
                            if (staffcompanyrangefields.getName() == 'range') {
                                return staffcompanyrangefields.getText();
                                break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnCreditLimit(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'creditopinion') {
                        for (Dom.XMLNode creditopinionfields : reportfields.getChildElements()) {
                            if (creditopinionfields.getName() == 'creditlimit') {
                                for (Dom.XMLNode creditlimitfields : creditopinionfields.getChildElements()) {
                                    if (creditlimitfields.getName() == 'value') {
                                        return creditlimitfields.getText();
                                        break;
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
    *  Name            : returnDateoffoundation(Dom.XMLNode node)
    *  Summary         : Return Date of foundation.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnDateoffoundation(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'foundation') {
                        for (Dom.XMLNode foundationfields : reportfields.getChildElements()) {
                            if (foundationfields.getName() == 'dateoffoundation') {
                                return foundationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnAgeofcompany(Dom.XMLNode node)
    *  Summary         : Return Age of company.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnAgeofcompany(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'foundation') {
                        for (Dom.XMLNode foundationfields : reportfields.getChildElements()) {
                            if (foundationfields.getName() == 'ageofcompany') {
                                return foundationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnFirstlegalform(Dom.XMLNode node)
    *  Summary         : Return First legal form.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnFirstlegalform(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'foundation') {
                        for (Dom.XMLNode foundationfields : reportfields.getChildElements()) {
                            if (foundationfields.getName() == 'firstlegalform') {
                                for (Dom.XMLNode firstlegalformfields : foundationfields.getChildElements()) {
                                    if (firstlegalformfields.getName() == 'designation') {
                                        return firstlegalformfields.getText();
                                        break;
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
    *  Name            : returnStatus(Dom.XMLNode node)
    *  Summary         : Return Status.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnStatus(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'status') {
                                for (Dom.XMLNode statusfields : companyidentificationfields.getChildElements()) {
                                    if (statusfields.getName() == 'designation') {
                                        return statusfields.getText();
                                        break;
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
    *  Name            : returnName(Dom.XMLNode node)
    *  Summary         : Return Name.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnName(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'companyname') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnTradename(Dom.XMLNode node)
    *  Summary         : Return Trade name.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnTradename(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'tradename') {
                                return companyidentificationfields.getText();
                                break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnStreet(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'street') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnHousenumber(Dom.XMLNode node)
    *  Summary         : Return Housenumber.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnHousenumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        String houseNumber = '';
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'housenumber') {
                                houseNumber = companyidentificationfields.getText();
                            }

                            if (companyidentificationfields.getName() == 'housenumberaffix') {
                                houseNumber += ' ' + companyidentificationfields.getText();
                            }
                        }

                        return houseNumber;
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPostcode(Dom.XMLNode node)
    *  Summary         : Return Post code.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnPostcode(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'postcode') {
                                return companyidentificationfields.getText();
                                break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnCity(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'city') {
                                return companyidentificationfields.getText();
                                break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnCountry(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'country') {
                                for (Dom.XMLNode countryfields : companyidentificationfields.getChildElements()) {
                                    if (countryfields.getName() == 'key') {
                                        return countryfields.getText();
                                        break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnPhone(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            String phone = '';
                            if (companyidentificationfields.getName() == 'phone') {
                                for (Dom.XMLNode phonefields : companyidentificationfields.getChildElements()) {
                                    if (phonefields.getName() == 'countrycode') {
                                        phone = phonefields.getText();
                                    }

                                    if (phonefields.getName() == 'diallingcode') {
                                        phone = phone + phonefields.getText();
                                    }

                                    if (phonefields.getName() == 'phonenumber') {
                                        phone = phone + phonefields.getText();
                                    }
                                }
                                return phone;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnFax(Dom.XMLNode node)
    *  Summary         : Return Fax.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnFax(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            String fax = '';
                            if (companyidentificationfields.getName() == 'fax') {
                                for (Dom.XMLNode faxfields : companyidentificationfields.getChildElements()) {
                                    if (faxfields.getName() == 'countrycode') {
                                        fax += faxfields.getText();
                                    }

                                    if (faxfields.getName() == 'diallingcode') {
                                        fax += faxfields.getText();
                                    }

                                    if (faxfields.getName() == 'phonenumber') {
                                        fax += faxfields.getText();
                                    }
                                }
                                return fax;
                                break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnMobile(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            String mobile = '';
                            if (companyidentificationfields.getName() == 'mobile') {
                                for (Dom.XMLNode mobilefields : companyidentificationfields.getChildElements()) {
                                    if (mobilefields.getName() == 'countrycode') {
                                        mobile = mobilefields.getText();
                                    }

                                    if (mobilefields.getName() == 'diallingcode') {
                                        mobile = mobile + mobilefields.getText();
                                    }

                                    if (mobilefields.getName() == 'phonenumber') {
                                        mobile = mobile + mobilefields.getText();
                                    }
                                }
                                return mobile;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnEmail(Dom.XMLNode node)
    *  Summary         : Return Email.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnEmail(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'email') {
                                return companyidentificationfields.getText();
                                break;
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnWebsite(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'website') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditLimitCurrency(Dom.XMLNode node)
    *  Summary         : Return Credit Limit Currency.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnCreditLimitCurrency(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'creditopinion') {
                        for (Dom.XMLNode creditopinionfields : reportfields.getChildElements()) {
                            if (creditopinionfields.getName() == 'creditlimit') {
                                for (Dom.XMLNode creditlimitfields : creditopinionfields.getChildElements()) {
                                    if (creditlimitfields.getName() == 'currency') {
                                        for (Dom.XMLNode currencyfields : creditlimitfields.getChildElements()) {
                                            if (currencyfields.getName() == 'key') {
                                                return currencyfields.getText();
                                                break;
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
    *  Name            : returnCreditDecision(Dom.XMLNode node)
    *  Summary         : Return Credit Decision.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnCreditDecision(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'creditopinion') {
                        for (Dom.XMLNode creditopinionfields : reportfields.getChildElements()) {
                            if (creditopinionfields.getName() == 'typeofcreditopinion') {
                                for (Dom.XMLNode typeofcreditopinionfields : creditopinionfields.getChildElements()) {
                                    if (typeofcreditopinionfields.getName() == 'designation') {
                                        return typeofcreditopinionfields.getText();
                                        break;
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
    *  Name            : returnMailboxEntryNumber(Dom.XMLNode node)
    *  Summary         : Return mailbox entry number.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnMailboxEntryNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'mailboxentrynumber') {
                return field.getText();
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnIdentificationNumber(Dom.XMLNode node)
    *  Summary         : Return mailbox entry number. 
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIdentificationNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'identificationnumber') {
                return field.getText();
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnOrderStatus(Dom.XMLNode node)
    *  Summary         : Return status of order.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnOrderStatus(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'statusoforder') {
                for (Dom.XMLNode statusField : field.getChildElements()) {
                    if (statusField.getName() == 'key') {
                        return statusField.getText();
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnReportStatus(Dom.XMLNode node)
    *  Summary         : Return mailbox entry number.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnReportStatus(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'deliverytype') {
                for (Dom.XMLNode entryField : field.getChildElements()) {
                    if (entryField.getName() == 'key') {
                        return entryField.getText();
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnNegativeReport(Dom.XMLNode node)
    *  Summary         : Return mailbox entry number.   
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnNegativeReport(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'negativereport') {
                return field.getText();
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnReplyInformation(Dom.XMLNode node)
    *  Summary         : Return information from order researcher.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnReplyInformation(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportField : field.getChildElements()) {
                    if (reportField.getName() == 'statusreply') {
                        for (Dom.XMLNode statusField : reportField.getChildElements()) {
                            if (statusField.getName() == 'reason') {
                                for (Dom.XMLNode reasonField : statusField.getChildElements()) {
                                    if (reasonField.getName() == 'designation') {
                                        return reasonField.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return '';
    }


    /*******************************************************************************
    *  Name            : returnGlobalBody(Dom.XMLNode node)
    *  Summary         : Return Body DOM element.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnGlobalBody(Dom.XMLNode node) {
        for (Dom.XMLNode child : node.getChildElements()) {
            if (child.getName() == 'Body') {
                return child;
                break;
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : returnInnerBody(Dom.XMLNode node)
    *  Summary         : Return Inner Body DOM element.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnInnerBody(Dom.XMLNode node) {
        for (Dom.XMLNode searchResponse : node.getChildElements()) {
            for (Dom.XMLNode bodyInner : searchResponse.getChildElements()) {
                if (bodyInner.getName() == 'body') {
                    return bodyInner;
                    break;
                }
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : returnErrorMessage(Dom.XMLNode node)
    *  Summary         : Return Error message if inner body of xml is null.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XMLNode node) {
        String errorString = '';
        for (Dom.XMLNode searchResponse : node.getChildElements()) {
            if (searchResponse.getName() == 'fault') {
                for (Dom.XMLNode faultField : searchResponse.getChildElements()) {
                    if (faultField.getName() == 'detail') {
                        for (Dom.XMLNode detailField : faultField.getChildElements()) {
                            if (detailField.getName() == 'servicefault') {
                                for (Dom.XMLNode servicefaultField : detailField.getChildElements()) {
                                    if (servicefaultField.getName() == 'body') {
                                        for (Dom.XMLNode bodyFaultField : servicefaultField.getChildElements()) {
                                            if (bodyFaultField.getName() == 'fault') {
                                                for (Dom.XMLNode secondFaultField : bodyFaultField.getChildElements()) {
                                                    if (secondFaultField.getName() == 'errorkey') {
                                                        for (Dom.XMLNode errorkeyField : secondFaultField.getChildElements()) {
                                                            if (errorkeyField.getName() == 'key') {
                                                                errorString = errorString + errorkeyField.getText();
                                                            }

                                                            if (errorkeyField.getName() == 'designation') {
                                                                errorString = errorString + ' ' + errorkeyField.getText();
                                                            }
                                                        }
                                                        return errorString;
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
    *  Name            : returnSearchErrorMessage(Dom.XMLNode node)
    *  Summary         : Return Error message if inner body of xml is null
    *  CreatedDate     : 29/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnSearchErrorMessage(Dom.XMLNode node) {
        String errorString = '';
        for (Dom.XMLNode searchResponse : node.getChildElements()) {
            if (searchResponse.getName() == 'fault') {
                for (Dom.XMLNode faultField : searchResponse.getChildElements()) {
                    if (faultField.getName() == 'detail') {
                        for (Dom.XMLNode detailField : faultField.getChildElements()) {
                            if (detailField.getName() == 'validationfault') {
                                return detailField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;    
    } 


    /*******************************************************************************
    *  Name            : clearSearchXML(String xmlString)
    *  Summary         : Remove Content Type from response XML.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String xmlString - String from response 
    *  Returns         : String
    ******************************************************************************/
    public static String clearSearchXML(String xmlString) {
        List<String> newString = xmlString.split('\n');
        String finalString = '';
        Boolean isFirstPart = false;
        for (String s : newString) {
            if (s.startsWith('------=_Part') && isFirstPart == false) {
                isFirstPart = true;
                continue;
            }
            if (isFirstPart && s.startsWith('Content-Type:')) {
                continue;
            }
            if (s.startsWith('------=_Part') && isFirstPart) {
                break;
            }
            finalString = finalString + s;
        }
        return finalString;
    }
}