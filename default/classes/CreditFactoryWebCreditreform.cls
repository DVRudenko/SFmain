public class CreditFactoryWebCreditreform {
    private static String orderSpecifyingText;

    /*******************************************************************************
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : String endpoint - Creditreform endpoint url, String userName - Creditreform account name,
    					 String password - Creditreform password, String apikey - Creditreform apikey,
                         Map<String, String> searchParametersMap - parameters for search
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password, String apikey,
                                                    Map<String, String> searchParametersMap, String countryCode) {
        String body = generateSearchXML(userName, password, apikey, searchParametersMap, countryCode);
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', '');
        request.setHeader('Content-Type', 'application/soap+xml');
        request.setBody(body);
        request.setTimeout(30000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, String apikey - Creditreform apikey,
    					 String opportunityName - company name for search, String street - company street for search,
                         String city - company city for search, String houseNumber - company house number for search,
                         String postalCode - company postal code for search, String creditSystemId - Id of Creditreform company
    *  Returns         : String
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, String apikey, Map<String, String> searchParametersMap, String countryCode) {
        String opportunityName;
        if (searchParametersMap.containsKey('name') && ! String.isEmpty(searchParametersMap.get('name'))) {
            opportunityName = searchParametersMap.get('name').replace('&', ' ');
        }
        
        String xmlbody = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
           '<soap:Header/>'+
           '<soap:Body>'+
              '<ns:searchRequest>'+
                 '<ns:header>'+
                    '<ns:communicationlanguage>en</ns:communicationlanguage>'+
                    // '<ns:transmissiontimestamp>2018-09-28T09:37:01.95</ns:transmissiontimestamp>'+
                    '<ns:transmissiontimestamp>' + CreditFactoryGlobalUtils.returnCurrentDate() + '</ns:transmissiontimestamp>'+
                    '<ns:keylistversion>20</ns:keylistversion>'+
                    '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>'+
                    '<ns:clientapplicationversion>3</ns:clientapplicationversion>'+
                    '<ns:useraccount>'+ userName +'</ns:useraccount>'+
                    '<ns:generalpassword>'+ password +'</ns:generalpassword>'+
                    '<ns:individualpassword>'+ apikey +'</ns:individualpassword>'+
                 '</ns:header>'+
                 '<ns:body>'+
                    '<ns:searchtype>SETY-1</ns:searchtype>'+
                    ((searchParametersMap.containsKey('creditSystemId') && ! String.isEmpty(searchParametersMap.get('creditSystemId'))) ?
                            '<ns:identificationnumber>' + searchParametersMap.get('creditSystemId') + '</ns:identificationnumber>' : '') +
                    (! String.isEmpty(opportunityName) ? '<ns:companyname>'+ opportunityName +'</ns:companyname>' : '' ) +
                    ((searchParametersMap.containsKey('registeredStreet') && ! String.isEmpty(searchParametersMap.get('registeredStreet'))) ?
                            '<ns:street>'+ searchParametersMap.get('registeredStreet') +'</ns:street>' : '') +
                    ((searchParametersMap.containsKey('registeredHouseNumber') && ! String.isEmpty(searchParametersMap.get('registeredHouseNumber'))) ?
                            '<ns:housenumber>'+ searchParametersMap.get('registeredHouseNumber') +'</ns:housenumber>' : '') +
                    ((searchParametersMap.containsKey('registeredCity') && ! String.isEmpty(searchParametersMap.get('registeredCity'))) ?
                            '<ns:city>'+ searchParametersMap.get('registeredCity') +'</ns:city>' : '') +
                            '<ns:country>' + countryCode.toUpperCase() + '</ns:country>' +
                    ((searchParametersMap.containsKey('traderegisterNumber') && ! String.isEmpty(searchParametersMap.get('traderegisterNumber'))) ?
                            '<ns:registerid>' + searchParametersMap.get('traderegisterNumber') + '</ns:registerid>' : '') +
                 '</ns:body>'+
              '</ns:searchRequest>'+
           '</soap:Body>'+
        '</soap:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : String endpoint - Creditreform endpoint url, String userName - Creditreform account name,
    					 String password - Creditreform password, String apikey - Creditreform apikey,
    					 String companyId - Id of Credit System Company
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String apikey,
                                                    String companyId) {
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
    }


    /*******************************************************************************
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            '<ns:transmissiontimestamp>' + CreditFactoryGlobalUtils.returnCurrentDate() + '</ns:transmissiontimestamp>'+
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
    *  Summary         : generate HTTP Request to CreditReform
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : String endpoint - Creditreform endpoint url, String userName - Creditreform account name,
                         String password - Creditreform password, String apiKey - Creditreform api key,
                         String name - company name, String postalCode - company postal code, String city - company city,
                         String houseNumber - company house number, CreditFactoryCompany internalCompany - Credit Factory Company with Salesforce data
                         Boolean isAdditionalRequest - is request additional
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateOrderRequest(String endpoint, String userName, String password, String apiKey, String name, String postalCode,
                                                   String city, String street, String houseNumber) {
        String xmlBody = generateOrderXML(userName, password, apiKey, name, postalCode, city, street, houseNumber);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', '');
        request.setHeader('Content-Type', 'application/soap+xml');
        request.setBody(xmlBody);
        request.setTimeout(30000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        return request;
    }
    
    
    /*******************************************************************************
	*  Summary         : set company data for request
	*  CreatedDate     : 21/12/2020 by Ivan Kulinkovich
	*  Parameters      : CreditFactoryCompany internalCFCompany
	*  Returns         : void
	******************************************************************************/
    public static void setDataForRequest(CreditFactoryCompany internalCFCompany, String street, String houseNumber) {
        String legalForm = internalCFCompany.legalForm;
        String streetAndHouseNumberWithAffix = internalCFCompany.registeredStreet;
        String taxId = internalCFCompany.taxId;
        String vatNumber = internalCFCompany.vatNumber;
        String tradeRegisterNumber = internalCFCompany.tradeRegisterNumber;
        String yearOfFoundation = internalCFCompany.yearOfFoundation;
        String industry = internalCFCompany.industry;
        String webSite = internalCFCompany.website;
        String firstName;
        String lastName;
        String phone;
        String email;
        String birthdate;
        for (CreditFactoryCompany.CreditFactoryContact role : internalCFCompany.creditFactoryContacts) {
            if (role.isPrimary == true) {
                firstName = role.firstName;
                lastName = role.lastName;
                phone = role.phone;
                email = role.email;
                
                birthdate = role.dateOfBirth;
            }
        }
        orderSpecifyingText = (legalForm != null ? 'Gesellschaftsform: ' + legalForm + '\n' : '') +
                                   (streetAndHouseNumberWithAffix != null && streetAndHouseNumberWithAffix != street + houseNumber ? 'Straße: ' + streetAndHouseNumberWithAffix + '\n' : '') +
                                   (taxId != null ? 'Steuernummer: ' + taxId + '\n' : '') +
                                   (vatNumber != null ? 'USt-IdNr.: ' + vatNumber + '\n' : '') +
                                   (tradeRegisterNumber != null ? 'HR Nr.: ' + tradeRegisterNumber + '\n' : '') +
                                   (yearOfFoundation != null ? 'Grundungsjahr: ' + yearOfFoundation + '\n' : '') +
                                   (industry != null ? 'Branche: ' + industry + '\n' : '') +
                                   (webSite != null ? 'Webseite: ' + webSite + '\n' : '') +
                                   (firstName != null ? 'Vorname: ' + firstName + '\n' : '') +
                                   (lastName != null ? 'Nachname: ' + lastName + '\n' : '') +
                                   (phone != null ? 'Phone: ' + phone + '\n' : '') +
                                   (email != null ? 'E-mail: ' + email + '\n' : '') +
                                   (birthdate != null ? 'Geburtsdatum: ' + birthdate + '\n' : '');
        if (orderSpecifyingText.length() > 364) {
            orderSpecifyingText = orderSpecifyingText.substring(0, 364);
        }
    }
    
    
    /*******************************************************************************
	*  Summary         : get company data for request
	*  CreatedDate     : 2/12/2020 by Ivan Kulinkovich
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
    public static String getDataForRequest() {
        return orderSpecifyingText;
    }


    /*******************************************************************************
    *  Summary         : generate XML String to call CreditReform order
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password,
                         String apiKey - Creditreform api key, String name - company name,
                         String postalCode - company postal code, String city - company city,
                         String houseNumber - company house number, String orderSpecifyingText - company additional information
    *  Returns         : String
    ******************************************************************************/
    public static String generateOrderXML(String userName, String password, String apiKey, String name, String postalCode, String city,
                                          String street, String houseNumber) {
        String xmlBody =
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
                '<soap:Header/>' +
                '<soap:Body>' +
                    '<ns:orderRequest>' +
                        '<ns:header>' +
                            '<ns:communicationlanguage>en</ns:communicationlanguage>' +
                            // '<ns:transmissiontimestamp>2018-09-28T10:07:00.00</ns:transmissiontimestamp>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryGlobalUtils.returnCurrentDate() + '</ns:transmissiontimestamp>' +
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
                            '<ns:country>AT</ns:country>' +
                            ((orderSpecifyingText != null && orderSpecifyingText != '') ? '<ns:orderspecifyingtext>'+ orderSpecifyingText +'</ns:orderspecifyingtext>' : '') +
                        '</ns:body>' +
                    '</ns:orderRequest>' +
                '</soap:Body>' +
            '</soap:Envelope>';
        return xmlbody;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate HTTP Request to CreditReform
   	*  CreatedDate     : 18/12/2020 by Ivan Kulinkovich
    *  Parameters      : String endpoint - Creditreform  endpoint url, String userName - Creditreform account name,
                         String password - Creditreform password, String apiKey - Creditreform api key,
                         String referenceNumber - order reference number
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateMailboxDirectoryRequest(String endpoint, String userName, String password,
                                                              String apiKey, String referenceNumber) {
        String xmlBody = generateMailboxDirectoryXML(userName, password, apiKey, referenceNumber);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', '');
        request.setHeader('Content-Type', 'application/soap+xml');
        request.setBody(xmlBody);
        request.setTimeout(30000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Summary         : generate XML String to call CreditReform order
    *  CreatedDate     : 18/12/2020 by Ivan Kulinkovich
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
    *  Summary         : generate HTTP Request to CreditReform
    *  CreatedDate     : 18/12/2020 by Ivan Kulinkovich
    *  Parameters      : String endpoint - endpoint url, String userName - Creditreform account name, String password - Creditreform password,
                         String apiKey - Creditreform api key, String mailboxEntryNumber - number of checked mailbox entry
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateMailboxEntryRequest(String endpoint, String userName, String password,
                                                          String apiKey, String mailboxEntryNumber) {
        String xmlBody = generateMailboxEntryXML(userName, password, apiKey, mailboxEntryNumber);
        HttpRequest request = new HttpRequest();
        request.setHeader('SOAPAction', '');
        request.setHeader('Content-Type', 'application/soap+xml');
        request.setBody(xmlBody);
        request.setTimeout(30000);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        return request;
    }


    /*******************************************************************************
    *  Summary         : generate XML String to call CreditReform order
    *  CreatedDate     : 18/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchCompany(Dom.XMLNode node) {
        List<CreditFactoryCompany> companiesFromSearch = new List<CreditFactoryCompany>();
        for (Dom.XMLNode hit : node.getChildElements()) {
            if (hit.getName() == 'hit') {
                CreditFactoryCompany company = new CreditFactoryCompany();
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
                
                if (company.status.toLowerCase() == 'inactive') {
                    continue;
                }
                
                companiesFromSearch.add(company);
            }
        }

        return companiesFromSearch;
    }


    /*******************************************************************************
    *  Summary         : Return Company
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : Dom.XMLNode node - body from response, String creditSystemCompanyNumber - Id of Creditreform company
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(Dom.XMLNode node, String creditSystemCompanyNumber, String country) {
        CreditFactoryCompany selectedCompany = new CreditFactoryCompany();
        selectedCompany.creditSystemCompanyNumber = creditSystemCompanyNumber.subString(4, 14);
        selectedCompany.referenceNumber = returnReferenceNumber(node);
        selectedCompany.classRating = CreditFactoryGlobalUtils.returnArabic(returnClassRating(node, country));
        selectedCompany.solvencyIndex = returnSolvencyIndex(node);
        selectedCompany.development = returnDevelopment(node);
        selectedCompany.turnOver = returnTurnOver(node);
        selectedCompany.legalForm = returnLegalForm(node);
        selectedCompany.vatId = returnVatId(node);
        selectedCompany.taxId = returnTaxNumber(node, country);
        selectedCompany.dateLegalForm = returnDateLegalForm(node);
        selectedCompany.registerNumber = returnRegisterId(node);
        selectedCompany.dateLastRegisterEntry = returnDateLastRegisterEntry(node);
        selectedCompany.countyCourt = returnCountyCourt(node);
        selectedCompany.paymentBehaviour = returnPaymentBehaviour(node);
        selectedCompany.staffCompanyRange = returnStaffCompanyRange(node);
        selectedCompany.creditLimit = returnCreditLimit(node);
        selectedCompany.creditLimitCurrency = returnCreditLimitCurrency(node);
        selectedCompany.creditDecision = returnCreditDecision(node);
        selectedCompany.dateOfFoundation = returnDateoffoundation(node);
        selectedCompany.ageOfCompany = returnAgeofcompany(node);
        selectedCompany.firstLegalForm = returnFirstlegalform(node);
        selectedCompany.status = returnStatus(node);
        selectedCompany.name = returnName(node);
        selectedCompany.tradeName = returnTradename(node);
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
        selectedCompany.creditFactoryContacts = returnEmployees(node);
        selectedCompany.recordType = 'Default';
        return selectedCompany;
    }
    

    /*******************************************************************************
    *  Summary         : Return Company Employees
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnEmployees(Dom.XMLNode node) {
        List<CreditFactoryCompany.CreditFactoryContact> companyEmployeesList = new List<CreditFactoryCompany.CreditFactoryContact>();

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
    *  Summary         : Return Company Employees
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : List<Dom.XMLNode> fields - fields of participantcapacities node
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnEmployee(List<Dom.XMLNode> fields) {
        String eType = '';
        List<CreditFactoryCompany.CreditFactoryContact> currentEmployeesList = new List<CreditFactoryCompany.CreditFactoryContact>();
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
                CreditFactoryCompany.CreditFactoryContact currentEmployee = new CreditFactoryCompany.CreditFactoryContact();
                currentEmployee.type = eType;
                for (Dom.XMLNode activeFields : participantcapacitiesFields.getChildElements()) {
                    if (activeFields.getName() == 'identificationnumber') {
                        currentEmployee.id = activeFields.getText();
                    }

                    if (activeFields.getName() == 'privateperson') {
                        for (Dom.XMLNode privatepersonFields : activeFields.getChildElements()) {
                            if (privatepersonFields.getName() == 'firstname') {
                                if (String.isEmpty(currentEmployee.name)) {
                                    currentEmployee.name = privatepersonFields.getText();
                                } else {
                                    currentEmployee.name = currentEmployee.name + ' ' + privatepersonFields.getText();
                                }
                            }

                            if (privatepersonFields.getName() == 'surname') {
                                if (String.isEmpty(currentEmployee.name)) {
                                    currentEmployee.name = privatepersonFields.getText();
                                } else {
                                    currentEmployee.name = currentEmployee.name + ' ' + privatepersonFields.getText();
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
                
                currentEmployee.recordType = 'Default';
                currentEmployeesList.add(currentEmployee);
            }
        }

        return currentEmployeesList;
    }


    /*******************************************************************************
    *  Summary         : Return Company Employees
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnReferenceNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'referencenumber') {
                return field.getText();
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Class Rating.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnClassRating(Dom.XMLNode node, String country) {
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
                                return CreditFactoryGlobalUtils.returnRatingBasedOnSolvency(indexFields.getText(), country);
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Solvency Index.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Development.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Turn Over.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnVatId(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'taxdata') {
                        for (Dom.XMLNode taxdatafields : reportfields.getChildElements()) {
                            if (taxdatafields.getName() == 'vatid') {
                                String vatNumber = taxdatafields.getText();
                                if (vatNumber != null) {
                                    vatNumber = vatNumber.replaceAll('\\s+', '').replace('.', '');
                                }

                                return vatNumber;
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnTaxNumber(Dom.XMLNode node, String country) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'taxdata') {
                        for (Dom.XMLNode taxdatafields : reportfields.getChildElements()) {
                            if (taxdatafields.getName() == 'taxnumber') {
                                String taxNumber = taxdatafields.getText();
                                if (taxNumber != null) {
                                    if (country == 'Austria') {
                                        taxNumber = taxNumber.replaceAll('[^0-9]', '');
                                        if (taxNumber.length() >= 7) {
                                            taxNumber = taxNumber.substring(taxNumber.length() - 7, taxNumber.length());
                                        }
                                    }
                                    else if (country == 'Luxembourg') {
                                        taxNumber = taxNumber.replace('/', '');
                                    }
                                }

                                return taxNumber;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Date Legal Form.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Register Id.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Date of Last Register Entry.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return County Court.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Payment Behaviour.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Staff Company Range.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Credit Limit.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Date of foundation.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Age of company.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return First legal form.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Status.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Name.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Trade name.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Housenumber.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Post code.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Country.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Fax.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Email.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Summary         : Return Credit Limit Currency.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Credit Decision.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return mailbox entry number.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return identification number.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return status of order.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return status of report.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return negative report.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return information from order researcher.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return Body DOM element.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnGlobalBody(Dom.XMLNode node) {
        for (Dom.XMLNode child : node.getChildElements()) {
            if (child.getName() == 'Body') {
                return child;
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Summary         : Return Inner Body DOM element.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnInnerBody(Dom.XMLNode node) {
        for (Dom.XMLNode searchResponse : node.getChildElements()) {
            for (Dom.XMLNode bodyInner : searchResponse.getChildElements()) {
                if (bodyInner.getName() == 'body') {
                    return bodyInner;
                }
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Summary         : Return Error message if inner body of xml is null.
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
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
    *  Summary         : Return service error
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : node - body from response
    *  Returns         : validation error
    ******************************************************************************/
    public static String returnServiceError(Dom.XmlNode node) {
        String error;
        for (Dom.XmlNode searchResponse : node.getChildElements()) {
            if (searchResponse.getName() == 'Fault') {
                for (Dom.XmlNode faultField : searchResponse.getChildElements()) {
                    if (faultField.getName() == 'Detail') {
                        for (Dom.XmlNode detailField : faultField.getChildElements()) {
                            if (detailField.getName() == 'servicefault') {
                                for (Dom.XmlNode serviceFaultField : detailField.getChildElements()) {
                                    if (serviceFaultField.getName() == 'body') {
                                        for (Dom.XmlNode bodyField : serviceFaultField.getChildElements()) {
                                            if (bodyField.getName() == 'fault') {
                                                for (Dom.XmlNode faultField2 : bodyField.getChildElements()) {
                                                    if (faultField2.getName() == 'errorkey') {
                                                        for (Dom.XmlNode errorKeyField : faultField2.getChildElements()) {
                                                            if (errorKeyField.getName() == 'designation') {
                                                                error = errorKeyField.getText();
                                                            }
                                                        }
                                                    }
                                                    else if (faultField2.getName() == 'errorfield' && error != null) {
                                                        error += ' ' + faultField2.getText();
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
        
        return error;
    }


    /*******************************************************************************
    *  Summary         : Remove Content Type from response XML
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : xmlString - String from response
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
            if (! s.startsWith('<')) { // replace carriage returns with spaces in field values
                finalString = finalString + ' ';
            }
            finalString = finalString + s;
        }
        return finalString;
    }
}