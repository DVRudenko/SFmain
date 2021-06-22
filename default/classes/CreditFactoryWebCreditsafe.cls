public class CreditFactoryWebCreditsafe {


    /*******************************************************************************
    *  Summary         : Generate authenticate request
    *  CreatedDate     : 03/09/2020 by Anton Buzak
    *  Parameters      : userName - Creditsafe username,
                         password - Creditsafe password,
                         endpoint - Creditsafe endpoint
    *  Returns         : request
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
    *  Summary         : Generate search request
    *  CreatedDate     : 03/09/2020 by Anton Buzak
    *  Parameters      : token - authorization token,
                         endpoint - Creditsafe endpount,
                         countryCode - country code,
                         searchParametersNames - parameters for searching
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String token, String endpoint, String countryCode,
                                                    Map<String, String> searchParametersMap) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        if (searchParametersMap.containsKey('name') && ! String.isEmpty(searchParametersMap.get('name'))) {
            String name = searchParametersMap.get('name');
            name = EncodingUtil.urlEncode(name, 'UTF-8');
            name = name.replace('+', '%20');
            searchParametersMap.put('name', name);
        }

        request.setEndpoint(endpoint + '/companies?countries=' + countryCode + ((searchParametersMap.containsKey('taxId') && ! String.isEmpty(searchParametersMap.get('taxId'))) ? '&regNo=' + searchParametersMap.get('taxId') +
            ((searchParametersMap.containsKey('officeType') && ! String.isEmpty(searchParametersMap.get('officeType'))) ? '&officeType=' + searchParametersMap.get('officeType') : '') : '&name=' + searchParametersMap.get('name') +
            ((searchParametersMap.containsKey('registeredCity') && ! String.isEmpty(searchParametersMap.get('registeredCity'))) ? '&city=' + searchParametersMap.get('registeredCity').replace(' ', '%20') : '') +
            ((searchParametersMap.containsKey('registeredStreet') && ! String.isEmpty(searchParametersMap.get('registeredStreet'))) ? '&street=' + searchParametersMap.get('registeredStreet').replace(' ', '%20') : '')));
        request.setMethod('GET');
        return request;
    }


    /*******************************************************************************
    *  Summary         : Return list of searched companies
    *  CreatedDate     : 03/09/2020 by Anton Buzak
    *  Parameters      : searchEntity - search response entity
                         countryCode - country code
    *  Returns         : companies list
    ******************************************************************************/
    public static List<CreditFactoryCompany> returnSearchCompany(CreditsafeEntity searchEntity, String countryCode) {
        List<CreditFactoryCompany> creditCompaniesList = new List<CreditFactoryCompany>();
        for (CreditsafeEntity.Companies searchCompany :  searchEntity.companies) {
            CreditFactoryCompany creditCompany = new CreditFactoryCompany();
            creditCompany.identificationNumber = searchCompany.id;
            creditCompany.name = searchCompany.name;
            String regNo = searchCompany.regNo;
            if (countryCode == 'FR' && regNo != null && regNo.length() >= 9) {
                creditCompany.creditSystemCompanyNumber = regNo.substring(0, 9);
            }
            else {
                creditCompany.creditSystemCompanyNumber = regNo;
            }

            creditCompany.status = searchCompany.status;
            if (searchCompany.address != null) {
                creditCompany.street = searchCompany.address.street;
                creditCompany.houseNumber = searchCompany.address.houseNo;
                creditCompany.city = searchCompany.address.city;
                creditCompany.postCode = searchCompany.address.postCode;
                creditCompany.address = searchCompany.address.simpleValue;
            }
            creditCompaniesList.add(creditCompany);

            if (searchCompany.regNo != null) {
                if (countryCode == 'NL' && searchCompany.regNo.length() >= 8) {
                    creditCompany.taxId = searchCompany.regNo.substring(0, 8);
                }
                else if (countryCode == 'FR' && searchCompany.regNo.length() >= 9) {
                    creditCompany.taxId = searchCompany.regNo.substring(0, 9);
                }
                else {
                    creditCompany.taxId = searchCompany.regNo;
                }
            }
        }

        return creditCompaniesList;
    }


    /*******************************************************************************
    *  Summary         : Generate JSON report request
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : token - auth token,
                         endpoint - url endpoint,
                         companyId - id of selected company
    *  Returns         : request
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
    *  Summary         : Return Company object
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : jsonResponseBody - json from report response,
                         country - country
    *  Returns         : company
    ******************************************************************************/
    public static CreditFactoryCompany returnReportCompany(String jsonResponseBody, String country) {
        jsonResponseBody = jsonResponseBody.replace('"date"', '"date_x"');
        jsonResponseBody = jsonResponseBody.replace('"currency"', '"currency_x"');
        CreditsafeEntity reportEntity = CreditsafeEntity.parse(jsonResponseBody);
        CreditFactoryCompany company = new CreditFactoryCompany();
        if(reportEntity != null && reportEntity.report != null) {
            company.dateLastRegisterEntry = reportEntity.report.creditScore.latestRatingChangeDate;
            company.identificationNumber = reportEntity.report.companyId;
            company.creditFactoryContacts = returnReportCompanyEmployees(reportEntity.report);
            if (reportEntity.report.companySummary != null) {
                company.creditSystemCompanyNumber = reportEntity.report.companySummary.companyNumber;
                company.registerNumber = reportEntity.report.companySummary.companyRegistrationNumber;
                company.taxId = returnTaxId(reportEntity, country);
                company.tradeRegisterNumber = returnTradeRegisterNumber(reportEntity, country);
                company.creditLimitCurrency = 'EUR';
                company.name = reportEntity.report.companyIdentification.basicInformation.registeredCompanyName;
                company.tradeName = reportEntity.report.companySummary.businessName;
                if (reportEntity.report.companySummary.creditRating != null) {
                    company.creditDecision = reportEntity.report.companySummary.creditRating.commonDescription;
                    company.solvencyIndex = reportEntity.report.companySummary.creditRating.providerValue.value;
                    company.classRating = CreditFactoryGlobalUtils.returnArabicFromAlpha(reportEntity.report.companySummary.creditRating.commonValue);
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
                    company.vatNumber = returnVatId(reportEntity, country);
                    company.status = reportEntity.report.companyIdentification.basicInformation.companyStatus.description;
                    company.phone = reportEntity.report.companyIdentification.basicInformation.contactAddress.telephone;
                    company.legalForm = returnLegalForm(reportEntity, country);
                    company.dateOfFoundation = returnDateOfFoundation(reportEntity);
                    if (company.dateOfFoundation != null && company.dateOfFoundation.length() == 10) {
                        company.ageOfCompany = String.valueOf(Date.today().year() - Integer.valueOf(company.dateOfFoundation.substring(0, 4)));
                    }
                    company.mobile = company.phone;
                }
            }
            if (reportEntity.report.contactInformation != null) {
                company.email = returnEmail(reportEntity);
                if (reportEntity.report.contactInformation.mainAddress != null) {
                    company.street = reportEntity.report.contactInformation.mainAddress.street;
                    company.houseNumber = reportEntity.report.contactInformation.mainAddress.houseNumber;
                    company.postCode = reportEntity.report.contactInformation.mainAddress.postalCode;
                    company.city = reportEntity.report.contactInformation.mainAddress.city;
                    company.country = country;
                }

                if (reportEntity.report.contactInformation.otherAddresses != null &&
                        ! reportEntity.report.contactInformation.otherAddresses.isEmpty() && ! (company.street != null &&
                        company.houseNumber != null && company.postCode != null &&
                        company.city != null)) {
                    company.street = reportEntity.report.contactInformation.otherAddresses.get(0).street;
                    company.houseNumber = reportEntity.report.contactInformation.otherAddresses.get(0).houseNumber;
                    company.postCode = reportEntity.report.contactInformation.otherAddresses.get(0).postalCode;
                    company.city = reportEntity.report.contactInformation.otherAddresses.get(0).city;
                    company.country = country;
                }
            }
            if (reportEntity.report.otherInformation != null) {
                company.staffCompanyRange = returnStaffCompanyRange(reportEntity);
            }
            if (reportEntity.report.directors != null) {
                company.dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(reportEntity);
            }
            if (reportEntity.report.additionalInformation != null) {
                if (country == 'Netherlands') {
                    if (reportEntity.report.additionalInformation.lettersOfLiablilityInformation403 != null &&
                            !reportEntity.report.additionalInformation.lettersOfLiablilityInformation403.isEmpty()) {
                        company.parentCompanyId = 'NL001-X-' + reportEntity.report.additionalInformation.lettersOfLiablilityInformation403.get(0).companyNumber;
                    }
                }
                company.dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(reportEntity);
                company.addressChangeDecision = returnAddressChangeDecision(reportEntity);
            }

            company.recordType = 'Default';
        }

        return company;
    }


    /*******************************************************************************
    *  Summary         : Return company employees
    *  CreatedDate     : 07/09/2020 by Anton Buzak
    *  Parameters      : authorizedEntitiesList - contacts data
    *  Returns         : list of company employees
    ******************************************************************************/
    public static List<CreditFactoryCompany.CreditFactoryContact> returnReportCompanyEmployees(CreditsafeEntity.Report reportEntity) {
        Map<String, CreditFactoryCompany.CreditFactoryContact> contactsMap = new Map<String, CreditFactoryCompany.CreditFactoryContact>();
        if (reportEntity.shareCapitalStructure != null && reportEntity.shareCapitalStructure.shareHolders != null) {
            for (CreditsafeEntity.ShareHolders shareHolder : reportEntity.shareCapitalStructure.shareHolders) {
                CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                contact.name = shareHolder.name;
                if (shareHolder.address != null) contact.address = shareHolder.address.simpleValue;
                contact.role = 'ShareHolder';
                contact.recordType = 'Default';
                contactsMap.put(contact.name, contact);
            }
        }
        if (reportEntity.directors != null && reportEntity.directors.currentDirectors != null) {
            for (CreditsafeEntity.CurrentDirectors director : reportEntity.directors.currentDirectors) {
                if (director.positions != null && ! director.positions.isEmpty()) {
                    for (CreditsafeEntity.Positions position : director.positions) {
                        CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                        contact.name = director.name;
                        contact.type = position.positionName;
                        if (position.dateAppointed != null) {
                            String appointmentDate = position.dateAppointed;
                            if (appointmentDate != null && appointmentDate.contains('T00:00:00Z')) {
                                appointmentDate = appointmentDate.replace('T00:00:00Z', '');
                            }
                            contact.participationDate = appointmentDate;
                        }
                        if (director.dateOfBirth != null) {
                            contact.dateOfBirth = String.valueOf(director.dateOfBirth);
                        }
                        contact.role = 'Director';
                        contact.recordType = 'Default';
                        contactsMap.put(contact.name, contact);
                    }
                } else {
                    CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
                    contact.name = director.name;
                    if (director.dateOfBirth != null) {
                        contact.dateOfBirth = String.valueOf(director.dateOfBirth);
                    }

                    contact.role = 'Director';
                    contact.recordType = 'Default';
                    contactsMap.put(contact.name, contact);
                }
            }
        }

        if (reportEntity.groupStructure != null) {
            if (reportEntity.groupStructure.ultimateParent != null) {
                CreditsafeEntity.UltimateParent ultimateParent = reportEntity.groupStructure.ultimateParent;
                if (ultimateParent != null && ultimateParent.name != null && contactsMap.containsKey(ultimateParent.name)) {
                    contactsMap.get(ultimateParent.name).companyId = ultimateParent.id;
                    contactsMap.get(ultimateParent.name).companyType = 'Ultimate Parent';
                }
            }

            if (reportEntity.groupStructure.affiliatedCompanies != null) {
                for (CreditsafeEntity.AffiliatedCompanies affiliatedCompany : reportEntity.groupStructure.affiliatedCompanies) {
                    if (affiliatedCompany.name != null && contactsMap.containsKey(affiliatedCompany.name)) {
                        contactsMap.get(affiliatedCompany.name).companyId = affiliatedCompany.id;
                        contactsMap.get(affiliatedCompany.name).companyType = 'Affiliated Company';
                    }
                }
            }
        }

        return contactsMap.values();
    }


    /*******************************************************************************
    *  Summary         : Return legal form from Creditsafe report Entity
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  ModifiedDate    : -
    *  Parameters      : reportEntity - report response entity,
                         countryCode - country code of current record
    *  Returns         : String
    ******************************************************************************/
    public static String returnLegalForm(CreditsafeEntity reportEntity, String country) {
        String legalForm;
        if (reportEntity.report.companyIdentification.basicInformation.legalForm != null) {
            legalForm = reportEntity.report.companyIdentification.basicInformation.legalForm.description;
        }

        if (country == 'Netherlands' && netherlandslegalFormsMap.containsKey(legalForm)) {
            return netherlandslegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        }
        else if (country == 'France' && francelegalFormsMap.containsKey(legalForm)) {
            return francelegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        }
        else if (country == 'Belgium-NL' && belgiumNLLegalFormsMap.containsKey(legalForm)) {
            return belgiumNLLegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        }
        else if (country == 'Belgium-FR' && belgiumFRLegalFormsMap.containsKey(legalForm)) {
            return belgiumFRLegalFormsMap.get(legalForm).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
        }
        else {
            return legalForm;
        }
    }


    /*******************************************************************************
    *  Summary         : Return tax id from Creditsafe report Entity
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity,
                         country - country
    *  Returns         : tax id
    ******************************************************************************/
    public static String returnTaxId(CreditsafeEntity reportEntity, String country) {
        String taxId = reportEntity.report.companySummary.companyRegistrationNumber;
        if (taxId != null) {
            if (country == 'France' && taxId.length() >= 9) {
                taxId = taxId.substring(0, 9);
            }
        }

        return taxId;
    }


    /*******************************************************************************
    *  Summary         : Return trade register number
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity,
                         countryCode - country code of current record
    *  Returns         : trade register number
    ******************************************************************************/
    public static String returnTradeRegisterNumber(CreditsafeEntity reportEntity, String country) {
        String tradeRegisterNumber = reportEntity.report.companySummary.companyRegistrationNumber;
        if (country != 'France') {
            tradeRegisterNumber = null;
        }

        return tradeRegisterNumber;
    }


    /*******************************************************************************
    *  Summary         : Return vat id
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity,
                         country - country
    *  Returns         : vat id
    ******************************************************************************/
    public static String returnVatId(CreditsafeEntity reportEntity, String country) {
        String vatId = reportEntity.report.companyIdentification.basicInformation.vatRegistrationNumber;
        if (vatId != null) {
            if (country == 'Belgium-NL' || country == 'Belgium-FR') {
                vatId = vatId.replace('.', '');
            }
        }

        return vatId;
    }


    /*******************************************************************************
    *  Summary         : Return credit limit
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity
    *  Returns         : credit limit
    ******************************************************************************/
    public static String returnCreditLimit(CreditsafeEntity reportEntity) {
        String creditLimit = reportEntity.report.companySummary.creditRating.creditLimit.value;
        if (creditLimit == 'No Credit Limit') {
            return '0';
        } else {
            return creditLimit;
        }
    }


    /*******************************************************************************
    *  Summary         : Return date of foundation
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity
    *  Returns         : date of foundation
    ******************************************************************************/
    public static String returnDateOfFoundation(CreditsafeEntity reportEntity) {
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
    *  Summary         : Return staff company range from Creditsafe report Entiry
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity
    *  Returns         : staff company range
    ******************************************************************************/
    public static String returnStaffCompanyRange(CreditsafeEntity reportEntity) {
        if (reportEntity.report.otherInformation.employeesInformation != null && ! reportEntity.report.otherInformation.employeesInformation.isEmpty()) {
            return reportEntity.report.otherInformation.employeesInformation.get(0).numberOfEmployees;
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Summary         : Return company email from Creditsafe report Entity
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity
    *  Returns         : email
    ******************************************************************************/
    public static String returnEmail(CreditsafeEntity reportEntity) {
        if (reportEntity.report.contactInformation.emailAddresses != null && ! reportEntity.report.contactInformation.emailAddresses.isEmpty()) {
            return reportEntity.report.contactInformation.emailAddresses.get(0);
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Summary         : Return date of last change of director
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity
    *  Returns         : date of last change of director
    ******************************************************************************/
    public static String returnDateOfLastChangeOfDirector(CreditsafeEntity reportEntity) {
        Date dateOfLastChangeOfDirector;
        Set<Date> appointmentDatesSet = new Set<Date>();
        Set<Date> resignationDatesSet = new Set<Date>();
        if (reportEntity.report.directors.currentDirectors != null) {
            for (CreditsafeEntity.CurrentDirectors currentDirector : reportEntity.report.directors.currentDirectors) {
                for (CreditsafeEntity.Positions position : currentDirector.positions) {
                    if (position.dateAppointed != null) {
                        appointmentDatesSet.add(Date.valueOf(position.dateAppointed));
                    }
                }
            }
        }

        if (reportEntity.report.directors.PreviousDirectors != null) {
            for (CreditsafeEntity.PreviousDirectors previousDirector : reportEntity.report.directors.previousDirectors) {
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
            for (CreditsafeEntity.CompanyHistory history : reportEntity.report.additionalInformation.companyHistory) {
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
    *  Summary         : Return date of last change of director
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateOfLastChangeOfAddress(CreditsafeEntity reportEntity) {
        Date dateOfLastChangeOfAddress;
        if (reportEntity.report.additionalInformation.companyHistory != null) {
            for (CreditsafeEntity.CompanyHistory history : reportEntity.report.additionalInformation.companyHistory) {
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
    *  Summary         : Return change of address in the last 6 months decision
    *  CreatedDate     : 04/09/2020 by Anton Buzak
    *  Parameters      : reportEntity - report response entity
    *  Returns         : address change decision
    ******************************************************************************/
    public static String returnAddressChangeDecision(CreditsafeEntity reportEntity) {
        String addressChangeDecision;
        if (reportEntity.report.additionalInformation.commentaries != null) {
            for (CreditsafeEntity.Commentaries commentary : reportEntity.report.additionalInformation.commentaries) {
                if (commentary.commentaryText == 'The business has been at the address for less than 6 months.') {
                    addressChangeDecision = commentary.commentaryText;
                    break;
                }
            }
        }

        return addressChangeDecision;
    }


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