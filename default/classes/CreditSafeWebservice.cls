public class CreditSafeWebservice {
    public static final String CREDIT_SYSTEM_NAME = 'Creditsafe';


    /*******************************************************************************
    *  Name            : generateAuthRequest(String userName, String password, String endpoint)
    *  Summary         : Generate authenticate request to Creditsafe    
    *  CreatedDate     : 29/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String userName - Creditsafe username, String password - Creditsafe password, String endpoint - Creditsafe endpoint
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateAuthRequest(String userName, String password, String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endpoint + '/authenticate');
        request.setMethod('POST');
        request.setTimeout(120000);
        String body = 
        '{' +
            '"username": "' + userName + '", ' +
            '"password": "' + password + '"' +
        '}';
        request.setBody(body);
        return request;
    }


    /*******************************************************************************
    *  Name            : generateSearchRequest()
    *  Summary         : Generate search request to Creditsafe    
    *  CreatedDate     : 31/10/2016
    *  ModifiedDate    : 26/08/2019
    *  Parameters      : String token - authorization token, String endpoint - Creditsafe endpount, 
                         String countryCode - current country coude, String regNo - SF tax Id,
                         String name - account name, String street - account street, String account city, 
                         String officeType - Creditsafe company office type
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String token, String endpoint, String countryCode, String regNo, 
                                                    String name, String street, String city, String officeType) {
        countryCode = countryCodesMap.get(countryCode);
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        if (name != null && name != '') {
            name = EncodingUtil.urlEncode(name, 'UTF-8');
            name = name.replace('+', '%20');
        }
        
        request.setEndpoint(endpoint + '/companies?countries=' + countryCode + ((regNo != null && regNo != '') ? '&regNo=' + regNo +
            ((officeType != null && officeType != '') ? '&officeType=' + officeType : '') : '&name=' + name +
            ((city != null && city != '') ? '&city=' + city.replace(' ', '%20') : '') + ((street != null && street != '') ? '&street=' + street.replace(' ', '%20') : '')));
        request.setMethod('GET');
        return request;
    }


    /*******************************************************************************
    *  Name            : returnSearchCompany(Dom.XMLNode node, Opportunity opportunity)
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 1/11/2016
    *  ModifiedDate    : 29/07/2019
    *  Parameters      : String jsonResponseBody - json from report response, String countryCode - country code of current record
    *  Returns         : companies list
    ******************************************************************************/
    public static List<CreditCompany> returnSearchCompany(CreditsafeSearchEntity searchEntity, String countryCode) {
        List<CreditCompany> creditCompaniesList = new List<CreditCompany>();
        for (CreditsafeSearchEntity.Companies searchCompany :  searchEntity.companies) {
            CreditCompany creditCompany = new CreditCompany();
            creditCompany.identificationnumber = searchCompany.id;
            creditCompany.name = searchCompany.name;
            String regNo = searchCompany.regNo;
            if (countryCode == 'FR' && regNo != null && regNo.length() >= 9) {
                creditCompany.creditSystemCompanyNumber = regNo.substring(0, 9);
            } else {
                creditCompany.creditSystemCompanyNumber = regNo;
            }
            creditCompany.status = searchCompany.status;
            creditCompany.isReportExists = true;
            if (searchCompany.address != null) {
                creditCompany.street = searchCompany.address.street;
                creditCompany.housenumber = searchCompany.address.houseNo;
                creditCompany.city = searchCompany.address.city;
                creditCompany.postcode = searchCompany.address.postCode;
                creditCompany.address = searchCompany.address.simpleValue;
            }
            creditCompaniesList.add(creditCompany);
        }

        return creditCompaniesList;
    }


    /*******************************************************************************
    *  Name            : generateJSONReportRequest(String token, String endpoint, String companyId)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String token, String endpoint, String companyId
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateJSONReportRequest(String token, String endpoint, String companyId) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint(endpoint + '/companies/' + companyId);
        request.setMethod('GET');
        return request;
    }


    /*******************************************************************************
    *  Name            : generatePDFReportRequest(String token, String endpoint, String companyId)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String token, String endpoint, String companyId
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generatePDFReportRequest(String token, String endpoint, String companyId) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/pdf');
        request.setTimeout(120000);
        request.setEndpoint(endpoint + '/companies/' + companyId);
        request.setMethod('GET');
        return request;
    }


    /*******************************************************************************
    *  Name            : returnReportCompany(Dom.XMLNode node)
    *  Summary         : Return Company
    *  CreatedDate     : 4/11/2016
    *  ModifiedDate    : 17/09/2019
    *  Parameters      : String jsonResponseBody - json from report response, String countryCode - country code of current record
    *  Returns         : CreditCompany
    ******************************************************************************/
    public static CreditCompany returnReportCompany(String jsonResponseBody, String countryCode) {
        jsonResponseBody = jsonResponseBody.replace('"date"', '"date_x"');
        jsonResponseBody = jsonResponseBody.replace('"currency"', '"currency_x"');
        CreditsafeReportEntity reportEntity = CreditsafeReportEntity.parse(jsonResponseBody);
        CreditCompany company = new CreditCompany();
        if(reportEntity != null && reportEntity.report != null) {
            company.datelastregisterentry = reportEntity.report.creditScore.latestRatingChangeDate;
            company.identificationnumber = reportEntity.report.companyId; 
            if (reportEntity.report.companySummary != null) {
                company.creditSystemCompanyNumber = reportEntity.report.companySummary.companyNumber; 
                company.registerNumber = reportEntity.report.companySummary.companyRegistrationNumber;
                company.taxnumber = returnTaxId(reportEntity, countryCode);
                company.tradeRegisterNumber = returnTradeRegisterNumber(reportEntity, countryCode);
                company.creditLimitCurrency = 'EUR';
                company.name = reportEntity.report.companyIdentification.basicInformation.registeredCompanyName;
                company.tradename = reportEntity.report.companySummary.businessName;
                if (reportEntity.report.companySummary.creditRating != null) {
                    company.creditDecision = reportEntity.report.companySummary.creditRating.commonDescription;
                    company.solvencyIndex = reportEntity.report.companySummary.creditRating.providerValue.value;
                    company.classRating = CreditFactoryUtilities.returnArabicFromAlpha(reportEntity.report.companySummary.creditRating.commonValue);
                    company.creditLimit = returnCreditLimit(reportEntity);
                    company.providerDescription = reportEntity.report.companySummary.creditRating.providerDescription;
                }
                if (reportEntity.report.companySummary.mainActivity != null) {
                    company.principalActivityCode = reportEntity.report.companySummary.mainActivity.code;
                    if (company.principalActivityCode != null) {
                        company.principalActivityCode = company.principalActivityCode.replaceAll('[^0-9]', '');
                    }
                    
                    company.principalActivityDescription = reportEntity.report.companySummary.mainActivity.description;
                }
                if (reportEntity.report.companySummary.latestTurnoverFigure != null) {
                    company.turnOver = reportEntity.report.companySummary.latestTurnoverFigure.value;
                    if (company.turnOver != null) {
                        if (company.turnOver.endsWith('.0')) company.turnOver = company.turnOver.substringBefore('.0');
                        company.turnOver = company.turnOver.replace('.', '');
                        String stringAfterE = company.turnOver.substringAfter('E');
                        company.turnOver = company.turnOver.substringBefore('E' + stringAfterE);
                    }
                }
            }
            if (reportEntity.report.companyIdentification != null) {
                if (reportEntity.report.companyIdentification.basicInformation != null) {
                    company.vatid = returnVatId(reportEntity, countryCode);
                    company.status = reportEntity.report.companyIdentification.basicInformation.companyStatus.description;
                    company.phone = reportEntity.report.companyIdentification.basicInformation.contactAddress.telephone;
                    company.legalform = returnLegalForm(reportEntity, countryCode);
                    company.dateoffoundation = returnDateoffoundation(reportEntity);
                    company.mobile = company.phone;
                }
            }
            if (reportEntity.report.contactInformation != null) {
                company.email = returnEmail(reportEntity);
                if (reportEntity.report.contactInformation.mainAddress != null) {
                    company.street = reportEntity.report.contactInformation.mainAddress.street;
                    company.housenumber = reportEntity.report.contactInformation.mainAddress.houseNumber;
                    company.postcode = reportEntity.report.contactInformation.mainAddress.postalCode;
                    company.city = reportEntity.report.contactInformation.mainAddress.city;
                    company.country = returnCountry(reportEntity, countryCode);
                }

                if (reportEntity.report.contactInformation.otherAddresses != null &&
                        ! reportEntity.report.contactInformation.otherAddresses.isEmpty() && ! (company.street != null &&
                        company.postCode != null && company.city != null)) {
                    company.street = reportEntity.report.contactInformation.otherAddresses.get(0).street;
                    company.houseNumber = reportEntity.report.contactInformation.otherAddresses.get(0).houseNumber;
                    company.postCode = reportEntity.report.contactInformation.otherAddresses.get(0).postalCode;
                    company.city = reportEntity.report.contactInformation.otherAddresses.get(0).city;
                    company.country = returnCountry(reportEntity, countryCode);
                }
            }
            if (reportEntity.report.otherInformation != null) {
                company.staffcompanyrange = returnStaffCompanyRange(reportEntity);
            }
            if (reportEntity.report.directors != null) {
                company.dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(reportEntity);
            }
            if (reportEntity.report.additionalInformation != null) {
                if (countryCode == 'NL') {
                    if (reportEntity.report.additionalInformation.lettersOfLiablilityInformation403 != null &&
                            !reportEntity.report.additionalInformation.lettersOfLiablilityInformation403.isEmpty()) {
                        company.parentCompanyId = 'NL001-X-' + reportEntity.report.additionalInformation.lettersOfLiablilityInformation403.get(0).companyNumber;
                    }
                }
                company.dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(reportEntity);
                company.addressChangeDecision = returnAddressChangeDecision(reportEntity);
            }
        }
        return company;
    }


    /*******************************************************************************
    *  Name            : returnReportCompanyEmployees(CreditsafeReportEntity reportEntity)
    *  Summary         : Return Company
    *  CreatedDate     : 4/11/2016
    *  ModifiedDate    : 18/11/2019
    *  Parameters      : String jsonResponseBody - json from report response
    *  Returns         : List<CreditCompanyEmployee>
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnReportCompanyEmployees(String jsonResponseBody) {
        jsonResponseBody = jsonResponseBody.replace('"date"', '"date_x"');
        jsonResponseBody = jsonResponseBody.replace('"currency"', '"currency_x"');
        CreditsafeReportEntity reportEntity = CreditsafeReportEntity.parse(jsonResponseBody);
        Map<String, CreditCompanyEmployee> companyEmployeesMap = new Map<String, CreditCompanyEmployee>();
        if (reportEntity != null && reportEntity.report != null && reportEntity.report.shareCapitalStructure != null && 
                reportEntity.report.shareCapitalStructure.shareHolders != null) {
            for (CreditsafeReportEntity.ShareHolders shareHolder : reportEntity.report.shareCapitalStructure.shareHolders) {
                CreditCompanyEmployee employee = new CreditCompanyEmployee();
                employee.ename = shareHolder.name;
                if (shareHolder.address != null) employee.address = shareHolder.address.simpleValue; // -
                employee.companyRole = 'ShareHolder';
                companyEmployeesMap.put(employee.ename, employee);
            }
        }
        if (reportEntity != null && reportEntity.report != null && reportEntity.report.directors != null && 
                reportEntity.report.directors.CurrentDirectors != null) { 
            for (CreditsafeReportEntity.CurrentDirectors director : reportEntity.report.directors.CurrentDirectors) {
                if (director.positions != null && ! director.positions.isEmpty()) {
                    for (CreditsafeReportEntity.Positions position : director.positions) {
                        CreditCompanyEmployee employee = new CreditCompanyEmployee();
                        employee.ename = director.name;
                        employee.type = position.positionName;
                        if (position.dateAppointed != null) {
                            String appointmentDate = position.dateAppointed;
                            if (appointmentDate != null && appointmentDate.contains('T00:00:00Z')) {
                                appointmentDate = appointmentDate.replace('T00:00:00Z', '');
                            }
                            employee.participationdate = appointmentDate;
                        }
                        if (director.dateOfBirth != null) {
                            employee.dateOfBirth = String.valueOf(director.dateOfBirth);
                        }
                        employee.companyRole = 'Director';
                        companyEmployeesMap.put(employee.ename, employee);
                    }
                } else {
                    CreditCompanyEmployee employee = new CreditCompanyEmployee();
                    employee.ename = director.name;
                    if (director.dateOfBirth != null) {
                        employee.dateOfBirth = String.valueOf(director.dateOfBirth);
                    }
                    employee.companyRole = 'Director';
                    companyEmployeesMap.put(employee.ename, employee);
                }
            }
                }

        if (reportEntity != null && reportEntity.report != null && reportEntity.report.groupStructure != null) {
            if (reportEntity.report.groupStructure.ultimateParent != null) {
                CreditsafeReportEntity.UltimateParent ultimateParent = reportEntity.report.groupStructure.ultimateParent;
                if (ultimateParent != null && ultimateParent.name != null && companyEmployeesMap.containsKey(ultimateParent.name)) {
                    companyEmployeesMap.get(ultimateParent.name).companyId = ultimateParent.id;
                    companyEmployeesMap.get(ultimateParent.name).companyType = 'Ultimate Parent';
                }
            }

            if (reportEntity.report.groupStructure.affiliatedCompanies != null) {
                for (CreditsafeReportEntity.AffiliatedCompanies affiliatedCompany : reportEntity.report.groupStructure.affiliatedCompanies) {
                    if (affiliatedCompany.name != null && companyEmployeesMap.containsKey(affiliatedCompany.name)) {
                        companyEmployeesMap.get(affiliatedCompany.name).companyId = affiliatedCompany.id;
                        companyEmployeesMap.get(affiliatedCompany.name).companyType = 'Affiliated Company';
                    }
                }
            }
        }

        return companyEmployeesMap.values();
    }


    /*******************************************************************************
    *  Name            : returnLegalForm(CreditsafeReportEntity reportEntity, String countryCode)
    *  Summary         : Return legal form from Creditsafe report Entity
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity, String countryCode - country code of current record 
    *  Returns         : String
    ******************************************************************************/
    public static String returnLegalForm(CreditsafeReportEntity reportEntity, String countryCode) {   
        String legalForm;
        if (reportEntity.report.companyIdentification.basicInformation.legalForm != null) {
            legalForm = reportEntity.report.companyIdentification.basicInformation.legalForm.description;     
        }
        if (countryCode == 'NL' && netherlandslegalFormsMap.containsKey(legalForm)) {
            return netherlandslegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        } else if (countryCode == 'FR' && francelegalFormsMap.containsKey(legalForm)) {
            return francelegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        } else if (countryCode == 'BENL' && belgiumNLLegalFormsMap.containsKey(legalForm)) {
            return belgiumNLLegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        } else if (countryCode == 'BEFR' && belgiumFRLegalFormsMap.containsKey(legalForm)) {
            return belgiumFRLegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        } else {
            return legalForm;
        }
    }


    /*******************************************************************************
    *  Name            : returnTaxId(CreditsafeReportEntity reportEntity, String countryCode)
    *  Summary         : Return tax id from Creditsafe report Entity
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity, String countryCode - country code of current record
    *  Returns         : String
    ******************************************************************************/
    public static String returnTaxId(CreditsafeReportEntity reportEntity, String countryCode) {      
        String taxId = reportEntity.report.companySummary.companyRegistrationNumber;
        if (taxId != null) {
            if (countryCode == 'FR' && taxId.length() >= 9) {
                taxId = taxId.substring(0, 9);
            }
        }

        return taxId;
    }


    /*******************************************************************************
    *  Name            : returnTradeRegisterNumber(CreditsafeReportEntity reportEntity, String countryCode)
    *  Summary         : Return trade register number from Creditsafe report Entity 
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity, String countryCode - country code of current record
    *  Returns         : String
    ******************************************************************************/
    public static String returnTradeRegisterNumber(CreditsafeReportEntity reportEntity, String countryCode) {      
        String tradeRegisterNumber = reportEntity.report.companySummary.companyRegistrationNumber;  
        if (countryCode != 'FR') {
            tradeRegisterNumber = null;
        }

        return tradeRegisterNumber;
    }


    /*******************************************************************************
    *  Summary         : Return vat id
    *  CreatedDate     : 27/08/2020 by Anton Buzak
    *  ModifiedDate    : -
    *  Parameters      : reportEntity - report response entity,
                         countryCode - country code
    *  Returns         : String
    ******************************************************************************/
    public static String returnVatId(CreditsafeReportEntity reportEntity, String countryCode) {
        String vatId = reportEntity.report.companyIdentification.basicInformation.vatRegistrationNumber;
        if (vatId != null) {
            if (countryCode == 'BENL' || countryCode == 'BEFR') {
                vatId = vatId.replace('.', '');
            }
        }

        return vatId;
    }


    /*******************************************************************************
    *  Name            : returnCreditLimit(CreditsafeReportEntity reportEntity)
    *  Summary         : Return credit limit from from Creditsafe report Entity
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditLimit(CreditsafeReportEntity reportEntity) {        
        String creditLimit = reportEntity.report.companySummary.creditRating.creditLimit.value;
        if (creditLimit == 'No Credit Limit') {
            return '0';
        } else {
            return creditLimit;
        }
    }


    /*******************************************************************************
    *  Name            : returnDateoffoundation(CreditsafeReportEntity reportEntity)
    *  Summary         : Return date of foundation from Creditsafe report Entity
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : 11/09/2019
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateoffoundation(CreditsafeReportEntity reportEntity) {        
        String dateOfFoundation = reportEntity.report.companyIdentification.basicInformation.companyRegistrationDate;  
        String dateOfStartingOperations = reportEntity.report.companyIdentification.basicInformation.operationsStartDate;
        if (dateOfFoundation != null && dateOfFoundation.contains('T00:00:00Z')) {
            return dateOfFoundation.replace('T00:00:00Z', '');
        } else if (dateOfStartingOperations != null && dateOfStartingOperations.contains('T00:00:00Z')) {
            return dateOfStartingOperations.replace('T00:00:00Z', '');
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnCountry(CreditsafeReportEntity reportEntity, String countryCode)
    *  Summary         : Return country from Creditsafe report Entity
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity, String countryCode - country code of current record
    *  Returns         : String
    ******************************************************************************/
    public static String returnCountry(CreditsafeReportEntity reportEntity, String countryCode) {        
        String country = reportEntity.report.contactInformation.mainAddress.country;
        if (country != null) {
            return country;
        } else {
            return countryCode;
        }
    }


    /*******************************************************************************
    *  Name            : returnStaffCompanyRange(CreditsafeReportEntity reportEntity)
    *  Summary         : Return staff company range from Creditsafe report Entiry
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity
    *  Returns         : String
    ******************************************************************************/
    public static String returnStaffCompanyRange(CreditsafeReportEntity reportEntity) { 
        if (reportEntity.report.otherInformation.employeesInformation != null && ! reportEntity.report.otherInformation.employeesInformation.isEmpty()) {
            return reportEntity.report.otherInformation.employeesInformation.get(0).numberOfEmployees;
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnEmail(CreditsafeReportEntity reportEntity)
    *  Summary         : Return company email from Creditsafe report Entity  
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditsafeReportEntity reportEntity - report response entity
    *  Returns         : String
    ******************************************************************************/
    public static String returnEmail(CreditsafeReportEntity reportEntity) { 
        if (reportEntity.report.ContactInformation.emailAddresses != null && ! reportEntity.report.ContactInformation.emailAddresses.isEmpty()) {
            return reportEntity.report.ContactInformation.emailAddresses.get(0);
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfDirector(CreditsafeReportEntity reportEntity)
    *  Summary         : Return date of last change of director
    *  CreatedDate     : 30/07/2019
    *  ModifiedDate    : 18/09/2019
    *  Parameters      : Dom.XMLNode node - part of response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateOfLastChangeOfDirector(CreditsafeReportEntity reportEntity) {
        Date dateOfLastChangeOfDirector;
        Set<Date> appointmentDatesSet = new Set<Date>();
        Set<Date> resignationDatesSet = new Set<Date>();
        if (reportEntity.report.directors.currentDirectors != null) {
            for (CreditsafeReportEntity.CurrentDirectors currentDirector : reportEntity.report.directors.currentDirectors) {
                for (CreditsafeReportEntity.Positions position : currentDirector.positions) {
                    if (position.dateAppointed != null) {
                        appointmentDatesSet.add(Date.valueOf(position.dateAppointed));
                    }
                }
            }
        }

        if (reportEntity.report.directors.PreviousDirectors != null) {
            for (CreditsafeReportEntity.PreviousDirectors previousDirector : reportEntity.report.directors.PreviousDirectors) {
                if (previousDirector.resignationDate != null) {
                        resignationDatesSet.add(Date.valueOf(previousDirector.resignationDate));
                    }
            }
        }

        for (Date appointmentDate : appointmentDatesSet) {
            for (Date resignationDate : resignationDatesSet) {
                if (appointmentDate >= resignationDate.addDays(-1) && appointmentDate <= resignationDate.addDays(1) &&
                        (dateOfLastChangeOfDirector == null || appointmentDate > dateOfLastChangeOfDirector)) {
                    dateOfLastChangeOfDirector = appointmentDate;
                }
            }
        }

        if (reportEntity.report.additionalInformation != null && reportEntity.report.additionalInformation.companyHistory != null) {
            for (CreditsafeReportEntity.CompanyHistory history : reportEntity.report.additionalInformation.companyHistory) {
                if (history.description == 'Change of directors' && (dateOfLastChangeOfDirector == null || history.date_x != null &&
                        Date.valueOf(history.date_x) > dateOfLastChangeOfDirector)) {
                    dateOfLastChangeOfDirector = Date.valueOf(history.date_x);
                }
            }
        }

        if (dateOfLastChangeOfDirector != null) {
            return String.valueOf(dateOfLastChangeOfDirector);
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfAddress(CreditsafeReportEntity reportEntity)
    *  Summary         : Return date of last change of director
    *  CreatedDate     : 18/09/2019
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - part of response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateOfLastChangeOfAddress(CreditsafeReportEntity reportEntity) {
        Date dateOfLastChangeOfAddress;
        if (reportEntity.report.additionalInformation.companyHistory != null) {
            for (CreditsafeReportEntity.CompanyHistory history : reportEntity.report.additionalInformation.companyHistory) {
                if ((history.description == 'Address changed.' || history.description == 'Registered office transferred inside jurisdiction of the Commercial Court') &&
                        (dateOfLastChangeOfAddress == null || history.date_x != null && Date.valueOf(history.date_x) > dateOfLastChangeOfAddress)) {
                    dateOfLastChangeOfAddress = Date.valueOf(history.date_x);
                }
            }
        }

        if (dateOfLastChangeOfAddress != null) {
            return String.valueOf(dateOfLastChangeOfAddress);
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnAddressChangeDecision(CreditsafeReportEntity reportEntity)
    *  Summary         : Return change of address in the last 6 months decision
    *  CreatedDate     : 18/09/2019
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - part of response
    *  Returns         : Boolean
    ******************************************************************************/
    public static String returnAddressChangeDecision(CreditsafeReportEntity reportEntity) {
        String addressChangeDecision;
        if (reportEntity.report.additionalInformation.commentaries != null) {
            for (CreditsafeReportEntity.Commentaries commentary : reportEntity.report.additionalInformation.commentaries) {
                if (commentary.commentaryText == 'The business has been at the address for less than 6 months.') {
                    addressChangeDecision = commentary.commentaryText;
                    break;
                }
            }
        }

        return addressChangeDecision;
    }


    public static Map<String, String> countryCodesMap = new Map<String, String>{
        'NL' => 'NL',
        'FR' => 'FR',
        'BEFR' => 'BE',
        'BENL' => 'BE'
    };

    public static Map<String, String> netherlandslegalFormsMap = new Map<String, String> {
        'Sole trader with one owner' => 'Eenmanszaak',
        'Sole trafer with several owners' => 'Eenmanszaak',
        'Public limited company or limited company being set up on A form' => 'Overige',
        'Shipping company' => 'Overige',
        'Partnership' => 'Maatschap',
        'General partnership (VOF)' => 'VOF',
        'Public limited company or limited company being set up on B form' => 'Overige',
        'Limited partnership (CV) with one managing partner' => 'CV',
        'Limited partnership (CV) with several managing partners' => 'CV',
        'public limited company or limited company being set up on D form' => 'Overige',
        'Private limited liability company (BV) with ordinary structure' => 'BV',
        'Private limited liability company (BV) according regulations of the structural company' => 'BV',
        'Limited company (NV) with ordinary structure' => 'NV',
        'Limited company (NV) according regulations of the structural company' => 'NV',
        'NV investment company with a variable capital' => 'NV',
        'NV investment company with a variable capital, according to the regulations' => 'NV',
        'European limited company (SE) with ordinary structure' => 'SE',
        'European limited company (SE) according to the regulations of the structural company of the structural company' => 'SE',
        'Co-operative society excluded liability (Coöperatie U.A.) with ordinary structure' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society excluded liability (Coöperatie U.A.) according to the regulations of the structural Co-operative society' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with legal liabilty (Coöperatie W.A.) with ordinary structure' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with legal liabilty (Coöperatie W.A.) according to the regulations of the structural Co-operative society' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with limited liability (Coöperatie B.A.) with ordinary structure' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with limited liability (Coöperatie B.A.) according to the regulations of the structural Co-operative society' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Association (Vereniging) with complete jurisdiction' => 'Vereniging',
        'Association (Vereniging) with limited jurisdiction' => 'Vereniging',
        'Religious community (Kerkgenootschap)' => 'Overige',
        'Foundation (Stichting)' => 'Stichting',
        'Mutual quarantee association excluded liability (Onderlinge Waarborgmaatschappij U.A.) with ordinary structure' => 'Overige',
        'Mutual quarantee association excluded liability (Onderlinge Waarborgmaatschappij U.A.) according to the regulations of the structural mutual quarantee ' => 'Overige',
        'Mutual quarantee association with legal liabilty (Onderlinge Waarborgmaatschappij W.A.) with ordinary structure' => 'Overige',
        'Mutual quarantee association with legal liabilty (Onderlinge Waarborgmaatschappij W.A.) according to the regulations of the structural mutual quarantee ' => 'Overige',
        'Mutual quarantee association with limited liabilty (Onderlinge Waarborgmaatschappij B.A.) with ordinary structure' => 'Overige',
        'Mutual quarantee association with limited liabilty (Onderlinge Waarborgmaatschappij B.A.) according to the regulations of the structural mutual quarantee ' => 'Overige',
        'Foreign legal form with headquarters in the Netherlands' => 'Overige',
        'Secondary with headquarters in foreign country' => 'Overige',
        'European Economical Cooperation (Europees Economisch Samenwerkingsverband)' => 'Overige',
        'Foreign company of the European Community with establishment in the Netherlands' => 'Overige',
        'Foreign company of the European Community with head-office in the Netherlands' => 'Overige',
        'Foreign company resembling at a company of the European Community with establishment in the Netherlands' => 'Overige',
        'Foreign company resembling at a company of the European Community with head-office in the Netherlands' => 'Overige',
        'Limited company being set up (Rechtspersoon in oprichting)' => 'Overige',
        'Other legal forms' => 'Overige',
        'Public partnership' => 'Overige',
        'Public partnership with corporate existence' => 'Overige',
        'Limited partnership (CV) with corporate existence' => 'CV',
        'Association of owners' => 'Vereniging',
        'Public corporation' => 'Overige',
        'Private corporation' => 'Overige'
    };

    public static Map<String, String> francelegalFormsMap = new Map<String, String> {
        'Mixed interest collective agriculatural public limited company with board of directors' => 'SA',
        'Awarding public limited company with board of directors' => 'SA',
        'Construction cooperative public limited company with board of directors' => 'SA',
        'Council housing public limited company with board of directors' => 'SA',
        'Council housing production cooperative society' => 'SA',
        'Real estate credit public limited company with board of directors' => 'SA',
        'Consumption cooperative public limited company with board of directors' => 'SA',
        'Shopkeeper cooperative public limited company - retailers to board of directors' => 'SA',
        'Craft cooperative public limited company with board of directors' => 'SA',
        'Maritime interest cooperative public limited company with board of directors' => 'SA',
        'Transport cooperative public limited company with board of directors' => 'SA',
        'Worker production cooperative society with board of directors' => 'SA',
        'Cooperative society union public limited company with board of directors' => 'SA',
        'cooperative public limited company with board of directors' => 'SA',
        'Liberal Practice Company in the form of a public limited company with board of directors' => 'SA',
        'Public limited company with board of directors' => 'SA',
        'Public limited company with worker participation in the board of directors' => 'SA',
        'National public limited company with board of directors' => 'SA',
        'Mixed economy public limited company with board of directors' => 'SA',
        'Open End Investment Company with board of directors' => 'SA',
        'Real estate company for industry and trading with management board' => 'SA',
        'Real estate investment public limited company with management board' => 'SA',
        'SAFER Plc with board of directors' => 'SA',
        'Agricultural mixed interest company in the form of a Plc with management board' => 'SA',
        'Agricultural collective interest company in the form of a Plc with management board' => 'SA',
        'Awarding Plc with management board' => 'SA',
        'Construction cooperative Plc with management board' => 'SA',
        'Council housing Plc with management board' => 'SA',
        'Cooperative production council housing Plc with management board' => 'SA',
        'Building society Plc with management board' => 'SA',
        'Consumption cooperative Plc with management board' => 'SA',
        'Traders cooperative Plc - retailers to board of directors' => 'SA',
        'Craft cooperative Plc with management board' => 'SA',
        'Maritime interest cooperative Plc with management board' => 'SA',
        'Transport cooperative Plc with management board' => 'SA',
        'Worker production cooperative society with management board' => 'SA',
        'Cooperative societies union Plc with management board' => 'SA',
        'Cooperative Plc with management board' => 'SA',
        'Liberal Plc with management board' => 'SA',
        'Plc with management board' => 'SA',
        'Simplified joint stock company' => 'SAS',
        'SASU (school and university administration secretary) company by simplified actions' => 'SASU',
        'Savings and provident bank' => 'SA',
        'GEIE-European economic interest group' => 'Autres',
        'Economic interest Group' => 'Autres',
        'CUMA-Common agricultural material usage cooperative' => 'Autres',
        'Agricultural cooperative company' => 'Autres',
        'Union of agricultural cooperative companies' => 'Autres',
        'Mutual Insurance Company' => 'Autres',
        'Collective Real Estate Investment Trust' => 'Autres',
        'Agricultural Collective Interest Company' => 'Autres',
        'Common farm group' => 'Autres',
        'Agricultural Land Organisation' => 'Autres',
        'Woodland Organsation' => 'Autres',
        'Open Area Organisation' => 'Autres',
        'Rural Land Organisation' => 'Autres',
        'Non Trading Land Ownership Company' => 'Autres',
        'Non Trading Estate Agents' => 'Autres',
        'Non Trading Contruction Estate Agents-Sales' => 'Autres',
        'Non Trading Attribution Company' => 'Autres',
        'Non Trading Coopertaive Contruction Company' => 'SCC',
        'Non Trading Coopertaive Consumer Company' => 'SCC',
        'Non Trading Cooperative Maritime Company' => 'SCC',
        'Non Trading Cooperative Company of Doctors' => 'SCC',
        'Non Trading Cooperative Company' => 'SCC',
        'Non Trading Professional Barrister Company' => 'SCP',
        'Non Trading Professional Legal Advisors Company' => 'SCP',
        'Non Trading Professional Registered Solicitors Company' => 'SCP',
        'Non Trading Professional Bailiff Company' => 'SCP',
        'Non Trading Professional Solicitors Company' => 'SCP',
        'Non Trading Professional Pricer Commissioner Company' => 'SCP',
        'Non Trading Professional Bankruptcy Court Clerk Company' => 'SCP',
        'Non Trading Professional Legal Advice Company' => 'SCP',
        'Non Trading Professional Auditor Company' => 'SCP',
        'Non Trading Professional Doctors Company' => 'SCP',
        'Non Trading Professional Dentistry Company' => 'SCP',
        'Non Trading Professional Nursing Company' => 'SCP',
        'Non Trading Professional Physiotherapist Company' => 'SCP',
        'Social Provident Society within the General National Insurance System' => 'Autres',
        'Social Provident Society within the Special National Insurance System' => 'Autres',
        'Social Provident Society for Pension Institution' => 'Autres',
        'Social Provident Society for the Mutual Benefit Agricultural Scheme' => 'Autres',
        'Social Provident Society for Unemployed Illnesses' => 'Autres',
        'Social Provident Society for seniors independent from social security' => 'Autres',
        'Social Provident Society for Unemployed Insurance' => 'Autres',
        'Social Provident Society' => 'Autres',
        'Mutualist Company' => 'Autres',
        'Agricultural Insurance mutualist agency' => 'Autres',
        'Mutualist agency' => 'Autres',
        'Central Business committee' => 'Autres',
        'Etablishment committee' => 'Autres',
        'Employees Union' => 'Autres',
        'Employers Union' => 'Autres',
        'Professional or Integrated Order' => 'Autres',
        'Industrial Technological Centre or the Professional Economic Development Society' => 'Autres',
        'Professional Society' => 'Autres',
        'Contingency Institute' => 'Autres',
        'Retirement Suppliment Institute' => 'Autres',
        'Joint Ownership Union' => 'Autres',
        'Free Union Association' => 'Association',
        'Non declared Association' => 'Association',
        'Declared Association' => 'Association',
        'Association déclarée \"entreprise d\'insertion par l\'économique\"' => 'Association',
        'Intermediate Association' => 'Association',
        'Employers Organization' => 'Association',
        'Declared Association, Recognized Public Benefit' => 'Association',
        'Assembly' => 'Association',
        'Local Rights Association (Bas-Rhin, Haut-Rhin et Moselle)' => 'Association',
        'Foundation' => 'Association',
        'Private Law Corporate Body' => 'Association',
        'Non Trading Professional Medical Laboratory Analysis Directors Company' => 'Autres',
        'Non Trading Professional Vetinary Company' => 'Autres',
        'Non Trading Professional Chartered Surveyors' => 'Autres',
        'Non Trading Professional Architect' => 'Autres',
        'Non Trading Professional Company' => 'Autres',
        'Average Non Trading Professional Company' => 'Autres',
        'Local Fund of Mutual Credit' => 'Autres',
        'Local Fund of Mutual Agricultural  Credit' => 'Autres',
        'Non Trading Farm' => 'Autres',
        'Liable Farms' => 'Autres',
        'Non Trading Company' => 'SC',
        'Corporate Body of Registered Private Rights' => 'Autres',
        'State Adminsitration, Contitutional Authority' => 'Secteur Public',
        'State Administration, Independent Administrative Authority' => 'Secteur Public',
        'State Administration, Department' => 'Secteur Public',
        'State Administration, Central Department' => 'Secteur Public',
        'State Administration, National Defence Department' => 'Secteur Public',
        'State Administration, National Dicentralized Department' => 'Secteur Public',
        'State Administration, Decentralized Interregional Service' => 'Secteur Public',
        'State Administration, Decentralized Inter-Departamental Service' => 'Secteur Public',
        'State Administration, Decentralized Territorial Serivce' => 'Secteur Public',
        'State Administration, National School without Corporate Body' => 'Secteur Public',
        'Regional Commune Group' => 'Secteur Public',
        'Regional Department GROUP' => 'Secteur Public',
        'Regional over seas Territory Group' => 'Secteur Public',
        'Regional Group' => 'Secteur Public',
        'Regional Region Group' => 'Secteur Public',
        'Common Associated Public Establishment' => 'Secteur Public',
        'Common Section Public Establishment' => 'Secteur Public',
        'Joint Urban Public Establishment' => 'Secteur Public',
        'Public Authorized Union Association' => 'Secteur Public',
        'Urban Land Association' => 'Secteur Public',
        'Land Re-grouping Association' => 'Secteur Public',
        'Local Public Educational Establishment' => 'Secteur Public',
        'Public Common Secter Establishment' => 'Secteur Public',
        'Urban District Establishment' => 'Secteur Public',
        'Public Urban Community Establishment' => 'Secteur Public',
        'Mutiple Vocation Public Union Establishment' => 'Secteur Public',
        'Local Authorties' => 'Secteur Public',
        'Village Community Establishment' => 'Secteur Public',
        'Town Community Establishments' => 'Secteur Public',
        'Non specialized Cooperation Society' => 'Autres',
        'Public Institutional Establishment or Interdepartamental Agreement' => 'Autres',
        'Public Institutional Establishment or Interregional Agreement' => 'Autres',
        'Unique Intercommunal union' => 'Autres',
        'Mixed Communal Union' => 'Autres',
        'Public Mixed Union' => 'Autres',
        'Union Board for the Management of Individual Community Goods' => 'Autres',
        'Communal Social Action Establishment' => 'Autres',
        'School Fund Establishment' => 'Autres',
        'Local Credit Fund Establishment' => 'Autres',
        'Hospital Department' => 'Autres',
        'Inner Hospital Department' => 'Autres',
        'Medico-social Public Establishment and Social Public Establishment' => 'Autres',
        'Establishment for Rented Accomodation' => 'Autres',
        'Fire Service Institution' => 'Autres',
        'Local Public Cultural Establishment' => 'Autres',
        'Local Public Establishment' => 'Autres',
        'Consular Body' => 'Autres',
        'Central Administration Public Society' => 'Autres',
        'National Scientific, Cultural and Professional Public Establishment' => 'Autres',
        'National Educational Public Establishment' => 'Autres',
        'Limited Territorial Competence Establishment' => 'Autres',
        'Administrative National Public Establishment' => 'Autres',
        'Public Interest Groups' => 'Autres',
        'Alsace and Lorraine Public Religion Establishment' => 'Autres',
        'Public Circle Establishment or Households in the Army' => 'Autres',
        'Corporate Body of Administrative Rights' => 'Autres',
        'Personal business-commercial craftsman' => 'Autres',
        'Personal business-commercial' => 'Profession libérale',
        'Personal business-craftsman' => 'Artisan',
        'Personal business-ministerial or public officer' => 'Profession libérale',
        'Personal business-liberal profession' => 'Profession libérale',
        'Personal business-farmer' => 'Profession libérale',
        'Personal business-sales representative' => 'Profession libérale',
        'Personal business-manager associated to company' => 'Profession libérale',
        'Personal business-Natural person' => 'ENTREPRISE INDIVIDUELLE',
        'Joint Ownership between natural people' => 'Autres',
        'Joint Ownership With Corporate Body' => 'Autres',
        'De Facto Company Between Natural People' => 'Autres',
        'De Facto Company With Corporate Body' => 'Autres',
        'Joint Equity Venture Company Between Natural People' => 'Autres',
        'Joint Equity Venture Company Wth Corporate Body' => 'Autres',
        'Joint Equity Venture Company - Liberal Professions' => 'Autres',
        'Parish Outside of the Concordat Zone' => 'Autres',
        'Private Law Group not equipped with Corporate Body' => 'Autres',
        'State Representation or Registered Foreign Public Body' => 'Autres',
        'Foreign Business Registered with RCS (business and companies Register)' => 'Autres',
        'International Organisation' => 'Autres',
        'International Organisation' => 'Autres',
        'Foreign Business not Registered with RCS (business and companies Register)' => 'Autres',
        'Foreign Law Company' => 'Autres',
        'National Public Establishment including a Public Accountant' => 'Autres',
        'National Public Establishment not Including a Public Accountant' => 'Autres',
        'Public Manager' => 'Autres',
        'Industrial or Commercial Local Public Establishement' => 'Autres',
        'Industrial or Commercial Local Group' => 'Autres',
        'French Bank Institution' => 'Autres',
        'Mutual Insurance Company' => 'Autres',
        'Cooperative Popular Bank Company' => 'Autres',
        'Maritime Mutual Savings Bank' => 'Autres',
        'Federal Mutual Savings Bank' => 'Autres',
        'Cooperative Registered Association' => 'Autres',
        'Cooperative Savings and Provident Bank' => 'Autres',
        'Partnership' => 'SNC',
        'Cooperative Partnership' => 'SNC',
        'Simple Limited partnership' => 'SNC',
        'Simple Cooperative Limited Partnership' => 'SNC',
        'Limited Partnership by policy' => 'SNC',
        'Limited Partnership by Cooperative Policy' => 'SNC',
        'Liberal Limited Partnership by policy' => 'SARL',
        'National Limited Liability Company' => 'SARL',
        'Mixed Economy Limited Liability Company' => 'SARL',
        'Real Estate Company for Industry and Trading in the form of a Ltd' => 'SARL',
        'Real Estate Management Company in the Form of a Ltd Company' => 'SARL',
        'SAFER company in the Form of a Ltd company' => 'SARL',
        'Mixed Interest Agricultural Society in the Form of a Ltd company' => 'SARL',
        'Agricultural Collective Interest Company in the Form of a Ltd Company' => 'SARL',
        'Limited Liability Granting Company' => 'SARL',
        'Construction Cooperative Limited Liabilty Company' => 'SARL',
        'Consumption Cooperative Limited Liabilty Company' => 'SARL',
        'Craft Cooperative Limited Liability Company' => 'SARL',
        'Maritime Interest Cooperative Limited Liabilty Company' => 'SARL',
        'Transport Cooperative Limited Liability Company' => 'SARL',
        'Worker Production Cooperative Society in the Form of a Ltd' => 'SARL',
        'Union of Cooperative Operated Companies in the Form of a Ltd company' => 'SARL',
        'Cooperative Operated Company in the Form of a Ltd company' => 'SARL',
        'Liberal Operated Limited Liability Company' => 'SARL',
        'Sole proprietorship Ltd' => 'SARL',
        'Limited Liability Company' => 'SARL',
        'Public Limited Company with Worker Participation in the Board of Directors' => 'SARL',
        'National Public Limited Company with Board of Directors' => 'SARL',
        'Mixed Economy Plc with board of directors' => 'SARL',
        'Open End Investment Company with Board of Directors' => 'SARL',
        'Real Estate Company for Industry and Trading with Board of Directors' => 'SARL',
        'Real Estate Investment Public Limited Company with Board of Directors' => 'SARL',
        'SAFER with Board of Directors' => 'SARL',
        'Mixed interest agricultural public limited company with board of directors' => 'SARL'
    };

    public static Map<String, String> belgiumFRLegalFormsMap = new Map<String, String> {
        'Proprietorship' => 'ENTREPRISE INDIVIDUELLE',
        'Foreign Company' => 'SE',
        'Partnership' => 'SNC',
        'Limited Partnership' => 'SCA',
        'Non-Profit Making Organisation' => 'Association',
        'Association with Shares' => 'Association',
        'Collective Name Company' => 'SNC',
        'Private Limited Company (BL/LX)' => 'SPRL',
        'One Person Private Limited Company (BE)' => 'SPRL',
        'Limited Partnership with shares (BL/LX)' => 'SA',
        'Public Limited Liability Company (BE)' => 'SA',
        'Temporary Association' => 'Autres',
        'Limited Liability Company (BE)' => 'SPRL',
        'Co-operative' => 'CVBA',
        'Co-operative Unlimited Company (BE)' => 'CVBA',
        'Co-operative Limited Liability Company (BE)' => 'CVBA',
        'Co-operative Unlimited Company by Participation (BE)' => 'CVBA',
        'Co-operative Limited Company by Participation (BE)' => 'CVBA',
        'Economic Interest Grouping' => 'Autres',
        'European Economic Interest Grouping' => 'Autres',
        'Agriculture Company' => 'Autres',
        'Professional and Interprofessional Company' => 'Autres',
        'Investment Co with Variable Capital regd. under Belgian law (BE)' => 'Autres',
        'Common Investment Fund (BE)' => 'Autres',
        'International Organisation' => 'Autres',
        'Private Limited Liability Company (BL/LX)' => 'SPRL',
        'Public Centre for Social Welfare (BE)' => 'Autres',
        'Public Utility Institute (BE)' => 'Autres',
        'Health Insurance Fund' => 'Autres',
        'Friendly Society' => 'Association',
        'Religious Corporate Body' => 'Association',
        'Civil Co in the form of Agriculture Company (BE)' => 'Autres',
        'Civil Co in form of Association with Shares (BE)' => 'Autres',
        'Civil Co in the form of Co-operative (BE)' => 'Autres',
        'Civil Co in form of Co-operative Ltd Co by Participation (BE)' => 'Autres',
        'Civil Co in the form of Co-operative Limited Liability Co (BE)' => 'Autres',
        'Civil Co in the form of Co-operative Unlimited Company (BE)' => 'Autres',
        'Civil Co in form of Co-operative Unltd Co by Participation (BE)' => 'Autres',
        'Civil Co in the form of Collective Name Company (BE)' => 'Autres',
        'Civil Co in the form of Common Investment Fund (BE)' => 'Autres',
        'Civil Co in the form of Investment Co with Variable Capital (BE)' => 'Autres',
        'Civil Co in the form of Economic Interest Grouping (BE)' => 'Autres',
        'Civil Co in the form of European Economic Interest Grouping (BE)' => 'Autres',
        'Civil Co in the form of Foreign Company (BE)' => 'Autres',
        'Civil Co in the form of International Organisation (BE)' => 'Autres',
        'Civil Co in the form of Public Limited Liability Company (BE)' => 'Autres',
        'Civil Co in the form of Limited Liability Company (BE)' => 'Autres',
        'Civil Co in the form of Limited Partnership (BE)' => 'Autres',
        'Civil Co in the form of Limited Partnership with Shares (BE)' => 'Autres',
        'Civil Co in the form of One Person Private Limited Company (BE)' => 'Autres',
        'Civil Co in the form of Private Limited Company (BE)' => 'Autres',
        'Civil Co in the form of Professional Association (BE)' => 'Autres',
        'Foreign Company with Permanent Office in Belgium (BE)' => 'SE',
        'Foreign Company with Immovable Property in Belgium (BE)' => 'SE',
        'Civil Co (BL/LX)' => 'Autres',
        'Civil Co (BL/LX)' => 'Autres',
        'Investment Co with Variable Capital regd under EU Law (BL/LX)' => 'Autres',
        'Professional Association' => 'Autres',
        'Foreign Company with Value Added Tax Number Representative (BE)' => 'Autres',
        'Public Institute in the form of Public Limited Company (BE)' => 'Autres',
        'Public Institute in the form of a Co-operative (BE)' => 'Autres',
        'Public Institute in the form of Interrelated Insurance Co (BE)' => 'Autres',
        'Public Institute (BE)' => 'Autres',
        'Foundation' => 'Autres',
        'Ministry' => 'Autres',
        'Irregular Collective Name Company (ES)' => 'Autres',
        'Limited Partnership with Social Intention (BE)' => 'Autres',
        'Collective Name Company with Social Intention (BE)' => 'Autres',
        'Private Limited Company with Social Intention (BE)' => 'Autres',
        'One Person Private Limited Company with Social Intention (BE)' => 'Autres',
        'Limited Partnership with Shares with Social Intention (BE)' => 'Autres',
        'Public Limited Liability Company with Social Intention (BE)' => 'Autres',
        'Co-operative Unlimited Company with Social Intention (BE)' => 'CV',
        'Co-operative Limited Liability Co with Social Intention (BE)' => 'CV',
        'Legal entity in formation' => 'Autres',
        'Municipal Institution' => 'Autres',
        'Provincial Institution' => 'Autres',
        'Public Institution under form of Co-operative Unlimited Co (BE)' => 'Autres',
        'Public Institution under form of a Co-operative Limited Co (BE)' => 'Autres',
        'Economic Interest Grouping with Social Intention (BE)' => 'Autres',
        'Publ. Inst. u. f. Co-operative Unltd Co Social Intention (BE)' => 'Autres',
        'Publ Institution u.f. of Co-op Ltd Co with Social Intention (BE)' => 'Autres',
        'Publ Institut form of a Publ. Ltd Co with Social Intention (BE)' => 'Autres',
        'Public Institution with Social Intention (BE)' => 'Autres',
        'European Company' => 'Autres',
        'Polders and Water Boards (BE)' => 'Autres',
        'Personal Partnership (BE)' => 'Autres',
        'European Economic Interest Grouping Registered Outside Belgium' => 'Autres',
        'Organization for Financing Pensions (BE)' => 'Autres',
        'European Cooperative Partnership' => 'Autres',
        'International Non-profit Organization (BE)' => 'Autres',
        'Foreign Non-profit Organization (BE)' => 'Autres'
    };

    public static Map<String, String> belgiumNLLegalFormsMap = new Map<String, String> {
        'Proprietorship' => 'Eenmanszaak',
        'Foreign Company' => 'SE',
        'Partnership' => 'VOF',
        'Limited Partnership' => 'CV',
        'Non-Profit Making Organisation' => 'Vereniging',
        'Association with Shares' => 'Vereniging',
        'Collective Name Company' => 'VOF',
        'Private Limited Company (BL/LX)' => 'BVBA',
        'One Person Private Limited Company (BE)' => 'BVBA',
        'Limited Partnership with shares (BL/LX)' => 'NV',
        'Public Limited Liability Company (BE)' => 'NV',
        'Temporary Association' => 'Overige',
        'Limited Liability Company (BE)' => 'BVBA',
        'Co-operative' => 'CV',
        'Co-operative Unlimited Company (BE)' => 'CV',
        'Co-operative Limited Liability Company (BE)' => 'CV',
        'Co-operative Unlimited Company by Participation (BE)' => 'CV',
        'Co-operative Limited Company by Participation (BE)' => 'CV',
        'Economic Interest Grouping' => 'Overige',
        'European Economic Interest Grouping' => 'Overige',
        'Agriculture Company' => 'Overige',
        'Professional and Interprofessional Company' => 'Overige',
        'Investment Co with Variable Capital regd. under Belgian law (BE)' => 'Overige',
        'Common Investment Fund (BE)' => 'Overige',
        'International Organisation' => 'Overige',
        'Private Limited Liability Company (BL/LX)' => 'BVBA',
        'Public Centre for Social Welfare (BE)' => 'Overige',
        'Public Utility Institute (BE)' => 'Overige',
        'Health Insurance Fund' => 'Overige',
        'Friendly Society' => 'Vereniging',
        'Religious Corporate Body' => 'Vereniging',
        'Civil Co in the form of Agriculture Company (BE)' => 'Overige',
        'Civil Co in form of Association with Shares (BE)' => 'Overige',
        'Civil Co in the form of Co-operative (BE)' => 'Overige',
        'Civil Co in form of Co-operative Ltd Co by Participation (BE)' => 'Overige',
        'Civil Co in the form of Co-operative Limited Liability Co (BE)' => 'Overige',
        'Civil Co in the form of Co-operative Unlimited Company (BE)' => 'Overige',
        'Civil Co in form of Co-operative Unltd Co by Participation (BE)' => 'Overige',
        'Civil Co in the form of Collective Name Company (BE)' => 'Overige',
        'Civil Co in the form of Common Investment Fund (BE)' => 'Overige',
        'Civil Co in the form of Investment Co with Variable Capital (BE)' => 'Overige',
        'Civil Co in the form of Economic Interest Grouping (BE)' => 'Overige',
        'Civil Co in the form of European Economic Interest Grouping (BE)' => 'Overige',
        'Civil Co in the form of Foreign Company (BE)' => 'Overige',
        'Civil Co in the form of International Organisation (BE)' => 'Overige',
        'Civil Co in the form of Public Limited Liability Company (BE)' => 'Overige',
        'Civil Co in the form of Limited Liability Company (BE)' => 'Overige',
        'Civil Co in the form of Limited Partnership (BE)' => 'Overige',
        'Civil Co in the form of Limited Partnership with Shares (BE)' => 'Overige',
        'Civil Co in the form of One Person Private Limited Company (BE)' => 'Overige',
        'Civil Co in the form of Private Limited Company (BE)' => 'Overige',
        'Civil Co in the form of Professional Association (BE)' => 'Overige',
        'Foreign Company with Permanent Office in Belgium (BE)' => 'SE',
        'Foreign Company with Immovable Property in Belgium (BE)' => 'SE',
        'Civil Co (BL/LX)' => 'Overige',
        'Civil Co (BL/LX)' => 'Overige',
        'Investment Co with Variable Capital regd under EU Law (BL/LX)' => 'Overige',
        'Professional Association' => 'Overige',
        'Foreign Company with Value Added Tax Number Representative (BE)' => 'Overige',
        'Public Institute in the form of Public Limited Company (BE)' => 'Overige',
        'Public Institute in the form of a Co-operative (BE)' => 'Overige',
        'Public Institute in the form of Interrelated Insurance Co (BE)' => 'Overige',
        'Public Institute (BE)' => 'Overige',
        'Foundation' => 'Overige',
        'Ministry' => 'Overige',
        'Irregular Collective Name Company (ES)' => 'Overige',
        'Limited Partnership with Social Intention (BE)' => 'Overige',
        'Collective Name Company with Social Intention (BE)' => 'Overige',
        'Private Limited Company with Social Intention (BE)' => 'Overige',
        'One Person Private Limited Company with Social Intention (BE)' => 'Overige',
        'Limited Partnership with Shares with Social Intention (BE)' => 'Overige',
        'Public Limited Liability Company with Social Intention (BE)' => 'Overige',
        'Co-operative Unlimited Company with Social Intention (BE)' => 'CV',
        'Co-operative Limited Liability Co with Social Intention (BE)' => 'CV',
        'Legal entity in formation' => 'Overige',
        'Municipal Institution' => 'Overige',
        'Provincial Institution' => 'Overige',
        'Public Institution under form of Co-operative Unlimited Co (BE)' => 'Overige',
        'Public Institution under form of a Co-operative Limited Co (BE)' => 'Overige',
        'Economic Interest Grouping with Social Intention (BE)' => 'Overige',
        'Publ. Inst. u. f. Co-operative Unltd Co Social Intention (BE)' => 'Overige',
        'Publ Institution u.f. of Co-op Ltd Co with Social Intention (BE)' => 'Overige',
        'Publ Institut form of a Publ. Ltd Co with Social Intention (BE)' => 'Overige',
        'Public Institution with Social Intention (BE)' => 'Overige',
        'European Company' => 'Overige',
        'Polders and Water Boards (BE)' => 'Overige',
        'Personal Partnership (BE)' => 'Overige',
        'European Economic Interest Grouping Registered Outside Belgium' => 'Overige',
        'Organization for Financing Pensions (BE)' => 'Overige',
        'European Cooperative Partnership' => 'Overige',
        'International Non-profit Organization (BE)' => 'Overige',
        'Foreign Non-profit Organization (BE)' => 'Overige'
    };
}