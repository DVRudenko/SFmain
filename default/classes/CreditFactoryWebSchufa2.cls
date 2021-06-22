public with sharing class CreditFactoryWebSchufa2 {
    public static final String CREDIT_SYSTEM_NAME = 'Schufa';


    /*******************************************************************************
    *  Summary         : Generate authenticate request to Schufa
    *  CreatedDate     : 03/03/2020
    *  Parameters      : userName - Schufa username,
                         password - Schufa password,
                         endpoint - Schufa endpoint
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generateAuthRequest(String userName, String password, String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endpoint + '/auth');
        request.setMethod('POST');
        request.setTimeout(120000);
        String body =
        '{' +
            '"clientID":"' + userName + '", ' +
            '"clientSecret":"' + password + '"' +
        '}';
        request.setBody(body);
        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate search request to Schufa
    *  CreatedDate     : 03/03/2020
    *  Parameters      : token - authorization token,
                         endpoint - Schufa endpoint,
                         searchParametersNames - parameters for searching
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String token,
                                                    String endpoint,
                                                    Map<String, String> searchParametersMap) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        String method;
        String finalEndpoint;
        if (searchParametersMap.containsKey('creditSystemId') && ! String.isEmpty(searchParametersMap.get('creditSystemId'))) {
            method = 'GET';
            finalEndpoint = endpoint + '/company/' + searchParametersMap.get('creditSystemId') + '/detail';
        }
        else {
            method = 'POST';
            finalEndpoint = endpoint + '/company/search/full/detail';
            String body =
            '{' +
                ((searchParametersMap.containsKey('registeredCity') && ! String.isEmpty(searchParametersMap.get('registeredCity'))) ?
                    '"city": "' + searchParametersMap.get('registeredCity') + '", ' : '') +
                ((searchParametersMap.containsKey('name') && ! String.isEmpty(searchParametersMap.get('name'))) ?
                    '"companyName": "' + searchParametersMap.get('name') + '", ' : '') +
                ((searchParametersMap.containsKey('companyId') && ! String.isEmpty(searchParametersMap.get('companyId'))) ?
                    '"companyId": ' + searchParametersMap.get('companyId') + ', ' : '') +
                ((searchParametersMap.containsKey('traderegisterNumber') && ! String.isEmpty(searchParametersMap.get('traderegisterNumber'))) ?
                    '"traderegisterNumber": "' + searchParametersMap.get('traderegisterNumber') + '", ' : '') +
            '}';
            body = body.replace('", }', '"}').replace(', }', '}');
            request.setBody(body);
        }

        request.setMethod(method);
        request.setEndpoint(finalEndpoint);
        return request;
    }


     /*******************************************************************************
    *  Summary         : Return companies list
    *  CreatedDate     : 04/03/2020
    *  Parameters      : jsonResponseBody - json from report response
    *  Returns         : companies list
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchCompany(SchufaEntity searchEntity) {
        List<CreditFactoryCompany> creditCompaniesList = new List<CreditFactoryCompany>();
        if (searchEntity.companies != null) {
            for (SchufaEntity.Companies company : searchEntity.companies) {
                CreditFactoryCompany creditCompany = new CreditFactoryCompany();
                creditCompany.identificationNumber = company.companyId;
                creditCompany.creditSystemCompanyNumber = company.companyId;
                creditCompany.tradeRegisterNumber = company.traderegisterNumber;
                creditCompany.name = company.companyName;
                creditCompany.street = company.street;
                creditCompany.city = company.city;
                creditCompany.postCode = company.zipCode;
                creditCompany.status = 'Active';
                creditCompaniesList.add(creditCompany);
            }
        } else {
            CreditFactoryCompany creditCompany = new CreditFactoryCompany();
            if (searchEntity.companyId != null) {
                creditCompany.identificationNumber = searchEntity.companyId;
                creditCompany.creditSystemCompanyNumber = searchEntity.companyId;
                creditCompany.tradeRegisterNumber = searchEntity.traderegisterNumber;
                creditCompany.name = searchEntity.companyName;
                creditCompany.street = searchEntity.street;
                creditCompany.city = searchEntity.city;
                creditCompany.postCode = searchEntity.zipCode;
                creditCompany.status = 'Active';
                creditCompaniesList.add(creditCompany);
            }
        }

        return creditCompaniesList;
    }


    /*******************************************************************************
    *  Summary         : Generate "StartShortEconomyCheckOrder" request to Schufa
    *  CreatedDate     : 09/03/2020
    *  Parameters      : token - authorization token,
                         endpoint - Schufa endpoint,
                         id - company id
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generateOrderEconomyInfoRequest(String token,
                                                              String endpoint,
                                                              String id) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint(endpoint + '/company/schufa/' + id + '/full/X1/order');
        request.setMethod('GET');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate "GetOrders" request to Schufa
    *  Created         : 09/03/2020
    *  Parameters      : token - authorization token,
                         endpoint - Schufa endpoint,
                         id - company id
    *  Returns         : -
    ******************************************************************************/
    public static HttpRequest generateOrderStatusRequest(String token,
                                                         String endpoint,
                                                         String id) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint(endpoint + '/company/' + id + '/orders');
        request.setMethod('GET');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Generate "GetShortEconomyInfo" request to Schufa
    *  Created         : 09/03/2020
    *  Parameters      : token - authorization token,
                         endpoint - Schufa endpoint,
                         id - company id
    *  Returns         : -
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String token,
                                                    String endpoint,
                                                    String id) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint(endpoint + '/company/schufa/' + id + '/full');
        request.setMethod('GET');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Return Company
    *  CreatedDate     : 09/03/2020
    *  Parameters      : responseBody - json from report response
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(String responseBody) {
        SchufaEntity reportEntity = SchufaEntity.parse(responseBody);

        CreditFactoryCompany company = new CreditFactoryCompany();
        company.creditFactoryContacts = new List<CreditFactoryCompany.CreditFactoryContact>();
        if (reportEntity != null) {
            SchufaEntity.CoreData coreDataEntity = reportEntity.coreData;
            if (coreDataEntity != null) {
                SchufaEntity.CompanyData companyDataEntity = coreDataEntity.companyData;
                if (companyDataEntity != null) {
                    company.creditSystemCompanyNumber = companyDataEntity.companyId;
                    company.identificationNumber = companyDataEntity.companyId;
                    company.legalForm = companyDataEntity.legalFormAbbreviation;
                    company.vatNumber = companyDataEntity.vatID;
                    company.dateOfFoundation = companyDataEntity.foundationDate;
                    if (company.dateOfFoundation != null && company.dateOfFoundation.length() == 8) {
                        if (Date.today().year() - 2000 < Integer.valueOf(company.dateOfFoundation.substring(6, 8))) {
                            company.dateOfFoundation = company.dateOfFoundation.substring(0, 6) + '19' + company.dateOfFoundation.substring(6, 8);
                        }
                        else {
                            company.dateOfFoundation = company.dateOfFoundation.substring(0, 6) + '20' + company.dateOfFoundation.substring(6, 8);
                        }
                    }

                    if (company.dateOfFoundation != null && company.dateOfFoundation.length() == 10) {
                        company.ageOfCompany = String.valueOf(Date.today().year() - Integer.valueOf(company.dateOfFoundation.substring(6, 10)));
                    }

                    company.name = companyDataEntity.name;
                    company.street = companyDataEntity.street;
                    company.postCode = companyDataEntity.zipcode;
                    company.city = companyDataEntity.city;
                    company.registerNumber = companyDataEntity.tradeRegisterNumber;
                    company.countyCourt = companyDataEntity.registercourt;
                    company.principalActivityCode = companyDataEntity.branchCode;
                    if (company.principalActivityCode != null) {
                        company.principalActivityCode = company.principalActivityCode.replaceAll('[^0-9]', '');
                    }

                    company.principalActivityDescription = companyDataEntity.branch;
                    company.country = 'Germany';
                    company.status = 'Active';
                    SchufaEntity.CurrentCommunicationData currentCommunicationDataEntity = companyDataEntity.currentCommunicationData;
                    if (currentCommunicationDataEntity != null) {
                        company.phone = returnPhone(currentCommunicationDataEntity);
                        company.fax = returnFax(currentCommunicationDataEntity);
                        company.email = currentCommunicationDataEntity.email;
                        company.website = currentCommunicationDataEntity.website;
                    }
                }

                List<SchufaEntity.RepresentationAuthorized> authorizedEntitiesList = coreDataEntity.representationAuthorized;
                if (authorizedEntitiesList != null) {
                    company.creditFactoryContacts = returnReportCompanyEmployees(authorizedEntitiesList);
                }
            }

            SchufaEntity.FinancialStanding financialStandingEntity = reportEntity.financialStanding;
            if (financialStandingEntity != null) {
                SchufaEntity.FinancialIndex financialIndexEntity = financialStandingEntity.financialIndex;
                if (financialIndexEntity != null) {
                    SchufaEntity.CurrentScore currentScoreEntity = financialIndexEntity.currentScore;
                    if (currentScoreEntity != null) {
                        company.classRating = CreditFactoryGlobalUtils.returnRatingBasedOnSolvency(currentScoreEntity.score, 'Germany');
                        if (company.classRating == '0') {
                            company.classRating = '6';
                        }
                        company.solvencyIndex = currentScoreEntity.score;
                    }
                }

                company.creditLimit = returnCreditLimit(financialStandingEntity, company.classRating);
                company.creditLimitCurrency = 'EUR';
            }

            List<SchufaEntity.Employees> employeesEntity = reportEntity.employees;
            if (employeesEntity != null && ! employeesEntity.isEmpty()) {
                company.staffCompanyRange = employeesEntity.get(0).description;
            }

            List<SchufaEntity.Volume> volumeEntity = reportEntity.volume;
            if (volumeEntity != null && ! volumeEntity.isEmpty()) {
                company.turnOver = volumeEntity.get(0).description;
            }

            company.recordType = 'Default';
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Return company employees
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : authorizedEntitiesList - contacts data
    *  Returns         : list of company employees
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnReportCompanyEmployees(List<SchufaEntity.RepresentationAuthorized> authorizedEntitiesList) {
        List<CreditFactoryCompany.CreditFactoryContact> contactsList = new List<CreditFactoryCompany.CreditFactoryContact>();
        for (SchufaEntity.RepresentationAuthorized authorized : authorizedEntitiesList) {
            CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
            contact.address = authorized.address;
            contact.type = authorized.position;
            contact.dateOfBirth = authorized.birthdate;
            contact.name = '';
            contact.id = authorized.schufaid;
            String firstName = authorized.firstname;
            if (firstName != null) {
                contact.name += firstName + ' ';
            }

            String lastName = authorized.lastname;
            if (lastName != null) {
                contact.name += lastName;
            }

            contact.recordType = 'Default';

            contactsList.add(contact);
        }

        return contactsList;
    }


    /*******************************************************************************
    *  Summary         : return Phone
    *  Created         : 09/03/2020
    *  Parameters      :
    *  Returns         :
    ******************************************************************************/
    private static String returnPhone(SchufaEntity.CurrentCommunicationData currentCommunicationDataEntity) {
        String phone;
        SchufaEntity.PhoneNumber phoneNumberEntity = currentCommunicationDataEntity.phoneNumber;
        if (phoneNumberEntity != null) {
            String phoneDialingCode = phoneNumberEntity.dialingCode;
            String phoneNumber = phoneNumberEntity.number_x;
            phone = '';

            if (phoneDialingCode != null) {
                phone += phoneDialingCode;
            }

            if (phoneNumber != null) {
                phone += phoneNumber;
            }
        }

        return phone;
    }


    /*******************************************************************************
    *  Summary         : return Fax
    *  Created         : 09/03/2020
    *  Parameters      :
    *  Returns         :
    ******************************************************************************/
    private static String returnFax(SchufaEntity.CurrentCommunicationData currentCommunicationDataEntity) {
        String fax;
        SchufaEntity.FaxNumber faxNumberEntity = currentCommunicationDataEntity.faxNumber;
        if (faxNumberEntity != null) {
            String faxDialingCode = faxNumberEntity.dialingCode;
            String faxNumber = faxNumberEntity.number_x;
            fax = '';

            if (faxDialingCode != null) {
                fax += faxDialingCode;
            }

            if (faxNumber != null) {
                fax += faxNumber;
            }
        }

        return fax;
    }


    /*******************************************************************************
    *  Summary         : return Fax
    *  Created         : 09/03/2020
    *  Parameters      : financialStandingEntity - financial data, classRating - company rating
    *  Returns         : String
    ******************************************************************************/
    private static String returnCreditLimit(SchufaEntity.FinancialStanding financialStandingEntity, String classRating) {
        String creditLimit;
        SchufaEntity.CreditLimit creditLimitEntity = financialStandingEntity.creditLimit;
        if (creditLimitEntity != null) {
            creditLimit = creditLimitEntity.amount;
        }

        if (creditLimit == null) {
            if (classRating == '1') {
                creditLimit = '4000';
            }
            else if (classRating == '2') {
                creditLimit = '3000';
            }
            else if (classRating == '3') {
                creditLimit = '1500';
            }
            else if (classRating == '4') {
                creditLimit = '700';
            }
        }

        return creditLimit;
    }


    /*******************************************************************************
    *  Summary         : Generate pdf report request to Schufa
    *  Created         : 09/03/2020
    *  Parameters      : token - authorization token,
                         endpoint - Schufa endpoint,
                         id - company id
    *  Returns         : -
    ******************************************************************************/
    public static HttpRequest generatePdfReportRequest(String token,
                                                    String endpoint,
                                                    String id) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint(endpoint + '/company/' + id + '/coredata/economy/pdf');
        request.setMethod('GET');
        return request;
    }
}