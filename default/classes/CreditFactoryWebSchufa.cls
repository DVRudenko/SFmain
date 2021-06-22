public with sharing class CreditFactoryWebSchufa {
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
                         name - account name, 
                         city - account city,
                         id - Schufa id
    *  Returns         : request
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String token, 
                                                    String endpoint, 
                                                    String name,
                                                    String city,
                                                    String id) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        String method;
        String finalEndpoint;
        if (id != null) {
            method = 'GET';
            finalEndpoint = endpoint + '/company/' + id + '/detail';
        }
        else {
            method = 'POST';
            finalEndpoint = endpoint + '/company/search/full/detail';
            String body = 
            '{' + 
                ((! String.isEmpty(city)) ? '"city": "' + city + '", ' : '') +
                ((! String.isEmpty(name)) ? '"companyName": "' + name + '", ' : '') +
            '}';
            body = body.replace('", }', '"}');
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
    public static List<CreditCompany> returnSearchCompany(SchufaEntity searchEntity) {
        List<CreditCompany> creditCompaniesList = new List<CreditCompany>();
        if (searchEntity.companies != null) {
            for (SchufaEntity.Companies company : searchEntity.companies) {
                CreditCompany creditCompany = new CreditCompany();
                creditCompany.identificationNumber = company.companyId;
                creditCompany.creditSystemCompanyNumber = company.companyId;
                creditCompany.name = company.companyName;
                creditCompany.isReportExists = true;
                creditCompany.street = company.street;
                creditCompany.city = company.city;
                creditCompany.postcode = company.zipCode;
                creditCompany.status = 'Active';
                creditCompaniesList.add(creditCompany);
            }
        } else {
            CreditCompany creditCompany = new CreditCompany();
            if (searchEntity.companyId != null) {
                creditCompany.identificationNumber = searchEntity.companyId;
                creditCompany.creditSystemCompanyNumber = searchEntity.companyId;
                creditCompany.name = searchEntity.companyName;
                creditCompany.isReportExists = true;
                creditCompany.street = searchEntity.street;
                creditCompany.city = searchEntity.city;
                creditCompany.postcode = searchEntity.zipCode;
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
    public static CreditCompany returnReportCompany(String responseBody) {
        SchufaEntity reportEntity = SchufaEntity.parse(responseBody);
        
        CreditCompany company = new CreditCompany();
        if (reportEntity != null) {
            SchufaEntity.CoreData coreDataEntity = reportEntity.coreData;
            if (coreDataEntity != null) {
                SchufaEntity.CompanyData companyDataEntity = coreDataEntity.companyData;
                if (companyDataEntity != null) {
                    company.creditSystemCompanyNumber = companyDataEntity.companyId;
                    company.identificationnumber = companyDataEntity.companyId;
                    company.legalform = companyDataEntity.legalFormAbbreviation;
                    company.vatid = companyDataEntity.vatID;
                    company.dateoffoundation = companyDataEntity.foundationDate;
                    if (company.dateoffoundation != null && company.dateoffoundation.length() == 8) {
                        if (Date.today().year() - 2000 < Integer.valueOf(company.dateoffoundation.substring(6, 8))) {
                            company.dateoffoundation = company.dateoffoundation.substring(0, 6) + '19' + company.dateoffoundation.substring(6, 8);
                        }
                        else {
                            company.dateoffoundation = company.dateoffoundation.substring(0, 6) + '20' + company.dateoffoundation.substring(6, 8);
                        }
                    }
                    
                    if (company.dateoffoundation != null && company.dateoffoundation.length() == 10) {
                        company.ageofcompany = String.valueOf(Date.today().year() - Integer.valueOf(company.dateoffoundation.substring(6, 10)));
                    }
                    
                    company.name = companyDataEntity.name;
                    company.street = companyDataEntity.street;
                    company.postcode = companyDataEntity.zipcode;
                    company.city = companyDataEntity.city;
                    company.registerNumber = companyDataEntity.tradeRegisterNumber;
                    company.countyCourt = companyDataEntity.registercourt;
                    company.principalActivityCode = companyDataEntity.branchCode;
                    if (company.principalActivityCode != null) {
                        company.principalActivityCode = company.principalActivityCode.replaceAll('[^0-9]', '');    
                    }
                    
                    company.principalActivityDescription = companyDataEntity.branch;
                    company.country = 'DE';
                    company.status = 'Active';
                    SchufaEntity.CurrentCommunicationData currentCommunicationDataEntity = companyDataEntity.currentCommunicationData;
                    if (currentCommunicationDataEntity != null) {
                        company.phone = returnPhone(currentCommunicationDataEntity);
                        company.fax = returnFax(currentCommunicationDataEntity);
                        company.email = currentCommunicationDataEntity.email;
                        company.website = currentCommunicationDataEntity.website;
                    }
                }
            }
            
            SchufaEntity.FinancialStanding financialStandingEntity = reportEntity.financialStanding;
            if (financialStandingEntity != null) {
                SchufaEntity.FinancialIndex financialIndexEntity = financialStandingEntity.financialIndex;
                if (financialIndexEntity != null) {
                    SchufaEntity.CurrentScore currentScoreEntity = financialIndexEntity.currentScore;
                    if (currentScoreEntity != null) {
                        company.classRating = CreditFactoryUtilities.returnRatingBasedOnSolvency(currentScoreEntity.score, 'Germany');
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
                company.staffcompanyrange = employeesEntity.get(0).description;
            }
            
            List<SchufaEntity.Volume> volumeEntity = reportEntity.volume;
            if (volumeEntity != null && ! volumeEntity.isEmpty()) {
                company.turnOver = volumeEntity.get(0).description;
            }
            
            company.isWaitingReport = false;
        }
        return company;
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
    *  Summary         : Return Company
    *  CreatedDate     : 09/03/2020
    *  Parameters      : jsonResponseBody - json from report response
    *  Returns         : employees list
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnReportCompanyEmployees(String responseBody) {
        SchufaEntity reportEntity = SchufaEntity.parse(responseBody);
        List<CreditCompanyEmployee> companyEmployeesList = new List<CreditCompanyEmployee>();
        if (reportEntity != null) {
            SchufaEntity.CoreData coreDataEntity = reportEntity.coreData;
            if (coreDataEntity != null) {
                List<SchufaEntity.RepresentationAuthorized> authorizedEntitiesList = coreDataEntity.representationAuthorized;
                if (authorizedEntitiesList != null) {
                    for (SchufaEntity.RepresentationAuthorized authorized : authorizedEntitiesList) {
                        CreditCompanyEmployee employee = new CreditCompanyEmployee();
                        employee.address = authorized.address;
                        employee.type = authorized.position;
                        employee.dateofbirth = authorized.birthdate;
                        employee.ename = '';
                        employee.enumber = authorized.schufaid;
                        String firstName = authorized.firstname;
                        if (firstName != null) {
                            employee.ename += firstName + ' ';
                        }
                        
                        String lastName = authorized.lastname;
                        if (lastName != null) {
                            employee.ename += lastName;
                        }
                        
                        companyEmployeesList.add(employee);
                    }
                }
            }
        }
        
        return companyEmployeesList;
    }
    
    
    /*******************************************************************************
    *  Summary         : clear json before parsing   
    *  Created         : 09/03/2020
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String clearReportBody(String responseBody) {
        responseBody = responseBody.replace('"class"', '"class_x"');
        responseBody = responseBody.replace('"date"', '"date_x"');
        responseBody = responseBody.replace('"number"', '"number_x"');
        responseBody = responseBody.replace('"currency"', '"currency_x"');
        return responseBody;
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