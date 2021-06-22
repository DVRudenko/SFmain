public class CreditFactoryGlobalUtils {
    public static String CONTACT_ADMIN = 'Please contact your administrator.';
    public static String CRIF_API_ERROR = 'Crif API error.';
    public static String KRD_API_ERROR = 'KRD API error.';
    public static String LEXISNEXIS_API_ERROR = 'LexisNexis API error.';
    public static String BIG_API_ERROR = 'Big API error.';
    public static String SUBMIT_FOR_APPROVAL = 'Opportunity was submitted for Approval.';
    public static String SCHUFA_API_ERROR = 'Schufa API error.';
    public static String CREDITSAFE_API_ERROR = 'Creditsafe API error.';
    public static String STATEMENT_403 = 'no rating - 403 statement filed, check parent company.';
    public static String BRANCH = 'no rating - branch, refer to head office report.';
    public static String COMPANY_INFO_API_ERROR = 'Company.info API error.';
    public static String CRIBIS_API_ERROR = 'Cribis API error.';
    public static String COFACE_API_ERROR = 'Coface API error.';
    public static String CREDICONNECT_API_ERROR = 'Crediconnect API error.';
    public static String CREDITREFORM_API_ERROR = 'Creditreform API error.';
    

    /*******************************************************************************
    *  Summary         : Remove waste characters from error message.
    *  CreatedDate     : 12/09/2019 by Anton Buzak
    *  Parameters      : String error - error message
    *  Returns         : cleared error message
    ******************************************************************************/
    public static String clearErrorMessage(String error) {
        if (error.contains('BLACK LIST')) {
            String comment = error.substringBetween('^^');
            error = 'Company found in black list. Please refer to credit.' + 
                (comment != null ? '\nComment: ' + comment : '');
        } 
        else if (error.contains('Duplicate Opportunities found:') || 
            error.contains('Duplicate Accounts found:') || 
            error.contains('Duplicate Contacts found:')) {
            error = 'Duplicates found.';
        } else if (error == 'Fix all validation errors or refer to Credit.') {
            error = '';
        }
    
        error = error.replace('<br/>', '').replace('<ul>', '').replace('</ul>', '').replace('<li>', '\n').replace('</li>', '');
    
        return error;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return current date in valid form
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Current date
    ******************************************************************************/
    public static String returnCurrentDate()  {
        String strConvertedDate = Datetime.now().format(
            'yyyy-MM-dd HH:mm:ss');
        strConvertedDate = strConvertedDate.replace(' ', 'T');
        strConvertedDate = strConvertedDate + '.' + Datetime.now().millisecond();
        return strConvertedDate;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return arabic values from roman
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Arabic value
    ******************************************************************************/
    public static String returnArabic(String romanValue) {
        if (romanValue == 'I') return '1';
        if (romanValue == 'II') return '2';
        if (romanValue == 'III') return '3';
        if (romanValue == 'IV') return '4';
        if (romanValue == 'V') return '5';
        if (romanValue == 'VI') return '6';
        if (romanValue == 'VII') return '7';
        if (romanValue == 'VIII') return '8';
        if (romanValue == 'IX') return '9';
        if (romanValue == 'X') return '10';
        return romanValue;
    }


    /*******************************************************************************
    *  Summary         : Return arabic values
    *  CreatedDate     : 18/02/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Arabic value
    ******************************************************************************/
    public static String returnArabicFromAlpha(String romanValue) {
        if (romanValue == 'A') return '1';
        if (romanValue == 'B') return '2';
        if (romanValue == 'C') return '3';
        if (romanValue == 'D') return '4';
        if (romanValue == 'E') return '5';
        return romanValue;
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate search parameters map based on set
    *  CreatedDate     : 23/12/2019
    *  Parameters      : searchParametersSet - set of parameters for searching, 
                         internalCFCompany - Credit Factory Company with Salesforce data
    *  Returns         : search parameters map
    ******************************************************************************/
    public static Map<String, String> generateSearchParametersMap(Set<String> searchParametersSet, CreditFactoryCompany internalCFCompany) {
        Map<String, String> searchParametersMap = new Map<String, String>();
        for (String searchParameter : searchParametersSet) {
            if (searchParameter == 'Name') {
                searchParametersMap.put('name', internalCFCompany.opportunityName);
            } else if (searchParameter == 'Street') {
                searchParametersMap.put('registeredStreet', getStreet(internalCFCompany.registeredStreet));
            } else if (searchParameter == 'City') {
                searchParametersMap.put('registeredCity', internalCFCompany.registeredCity);
            } else if (searchParameter == 'House Number') {
                searchParametersMap.put('registeredHouseNumber', getHouseNumber(internalCFCompany.registeredStreet));
            } else if (searchParameter == 'Postal Code') {
                searchParametersMap.put('registeredPostCode', internalCFCompany.registeredPostCode);
            } else if (searchParameter == 'Tax Id') {
                searchParametersMap.put('taxId', internalCFCompany.taxId);
            }
            else if (searchParameter == 'Country') {
                searchParametersMap.put('country', internalCFCompany.country);
            }
            else if (searchParameter == 'Credit System Id') {
                searchParametersMap.put('creditSystemId', internalCFCompany.creditSystemCompanyNumber);
            }
            else if (searchParameter == 'Vat Number') {
                searchParametersMap.put('vatNumber', internalCFCompany.vatNumber);
            }
            else if (searchParameter == 'Trade Register Number') {
                searchParametersMap.put('traderegisterNumber', internalCFCompany.tradeRegisterNumber);
            }
            else if (searchParameter == 'Company Id') {
                searchParametersMap.put('companyId', internalCFCompany.creditSystemCompanyNumber);
            }
        }

        return searchParametersMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get Street name from address line
    *  CreatedDate     : 12/09/2019 by Anton Buzak
    *  Parameters      : addressLine - street + house number
    *  Returns         : street 
    ******************************************************************************/
    public static String getStreet(String addressLine) {
        String street;
        if (addressLine != null) {
            if (! addressLine.substringAfterLast(' ').isAlpha()) {
                street = addressLine.substringBeforeLast(' ');
            } else if (! (addressLine.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + addressLine.substringAfterLast(' ')).isAlphaSpace()) {
                street = addressLine.substringBeforeLast(' ').substringBeforeLast(' ');
            } else {
                street = addressLine.substringBeforeLast(' ').substringBeforeLast(' ').substringBeforeLast(' ');
            }
        }

        return street;
    }


    /*******************************************************************************
    *  Summary         : Get House Number from address line
    *  CreatedDate     : 12/09/2019 by Anton Buzak
    *  Parameters      : streetAndHouseNumber - BillingStreet(Street + House Number)
    *  Returns         : house number 
    ******************************************************************************/
    public static String getHouseNumber(String addressLine) {
        String houseNumber;
        if (addressLine != null) {
            if (! addressLine.substringAfterLast(' ').isAlpha()) {
                houseNumber = addressLine.substringAfterLast(' ');
            } else if (! (addressLine.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + addressLine.substringAfterLast(' ')).isAlphaSpace()) {
                houseNumber = addressLine.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + addressLine.substringAfterLast(' ');
            } else {
                houseNumber = addressLine.substringBeforeLast(' ').substringBeforeLast(' ') + ' ' + addressLine.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + addressLine.substringAfterLast(' ');
            }

            houseNumber = houseNumber.substringBefore(' ').substringBefore('-').substringBefore('/').substringBefore('.').replaceAll('[^0-9]', '');
        }

        return houseNumber;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return reference for LexisNexis requests
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : countryCode - country code (DE, NL etc.)
    *  Returns         : reference for LexisNexis request
    ******************************************************************************/
    public static String returnReferenceForLexisNexis(String countryCode) {
        Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        String orgType = '';
        if (org.IsSandbox) orgType = 'TEST';

        return orgType + 'CF' + countryCode;
    }
    
    
    /*******************************************************************************
    *  Summary         : round Credit Limit hundreds (0 -> 100, 1 -> 100, 149 -> 100, 150 -> 200)
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : rounded value
    ******************************************************************************/
    public static Decimal roundCreditLimitToHundreds(Decimal notRoundedValue) {
        Decimal roundedValue;
        if (notRoundedValue <= 100) {
            roundedValue = 100;
        }
        else if (notRoundedValue != null) {
            roundedValue = (notRoundedValue / 100).round(System.RoundingMode.HALF_UP) * 100;
        }
        
        return roundedValue;
    }


    /*******************************************************************************
    *  Summary         : round Credit Limit ten thousands (0 -> 10000, 1 -> 10000, 14900 -> 10000, 15000 -> 20000)
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : rounded value
    ******************************************************************************/
    public static Decimal roundCreditLimitToTenThousands(Decimal notRoundedValue) {
        Decimal roundedValue;
        if (notRoundedValue <= 10000) {
            roundedValue = 10000;
        }
        else if (notRoundedValue != null) {
            roundedValue = (notRoundedValue / 10000).round(System.RoundingMode.HALF_UP) * 10000;
        }

        return roundedValue;
    }
    
    
    /*******************************************************************************
    *  Summary         : return deposit value based on security level
    *  Created         : 08/01/2020
    *  Parameters      : securityLevel - security level, creditLimit - CL for some bp + pt,
                         billingPeriod - Billing Period, paymentTerms = Payment Terms,
                         recommendedCL - CL from credit system
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal returnDepositValue(Decimal securityLevel, Decimal creditLimit,
                                             Decimal billingPeriod, Decimal paymentTerms,
                                             Decimal recommendedCL) {
        Decimal deposit;
        if (securityLevel == 110) {
            deposit = creditLimit * (billingPeriod + paymentTerms + 10) / (billingPeriod + paymentTerms);
        }
        else if (securityLevel == 4 || securityLevel == 3) {
            deposit = creditLimit - recommendedCL;
        }
        else if (securityLevel >= 0) {
            deposit = creditLimit * securityLevel / 100;
        }
        else if (securityLevel == null) {
            deposit = 0;
        }
        
        return deposit;
    }
    
    
    /*******************************************************************************
    *  Summary         : round Deposit hundreds (0 -> 0, 1 -> 100, 149 -> 100, 150 -> 200)
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : rounded value
    ******************************************************************************/
    public static Decimal roundDepositToHundreds(Decimal notRoundedValue) {
        Decimal roundedValue;
        if (notRoundedValue == 0) {
            roundedValue = 0;
        }
        else if (notRoundedValue > 0 && notRoundedValue <= 100) {
            roundedValue = 100;
        }
        else if (notRoundedValue != null) {
            roundedValue = (notRoundedValue / 100).round(System.RoundingMode.HALF_UP) * 100;
        }
        
        return roundedValue;
    }


    /*******************************************************************************
    *  Summary         : round Deposit hundreds (0 -> 0, 1 -> 10000, 149 -> 10000, 150 -> 20000)
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : rounded value
    ******************************************************************************/
    public static Decimal roundDepositToTenThousands(Decimal notRoundedValue) {
        Decimal roundedValue;
        if (notRoundedValue == 0) {
            roundedValue = 0;
        }
        else if (notRoundedValue > 0 && notRoundedValue <= 10000) {
            roundedValue = 10000;
        }
        else if (notRoundedValue != null) {
            roundedValue = (notRoundedValue / 10000).round(System.RoundingMode.HALF_UP) * 10000;
        }

        return roundedValue;
    }


    /*******************************************************************************
    *  Summary         : Return Rating based on solvency boundaries from custom settings
    *  CreatedDate     : 14/08/2020 by Anton Buzak
    *  Parameters      : solvencyIndex - index related to class rating,
                         country - country
    *  Returns         : String
    ******************************************************************************/
    public static String returnRatingBasedOnSolvency(String solvencyIndex, String country) {
        if (solvencyIndex != null && solvencyIndex.isNumeric()) {
            Integer solvencyIndexValue = Integer.valueOf(solvencyIndex);
            Solvency__c solvencySetting = Solvency__c.getAll().get(country);
            if (solvencyIndexValue >= solvencySetting.Rating_1_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_1_Maximum__c) return '1';
            if (solvencyIndexValue >= solvencySetting.Rating_2_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_2_Maximum__c) return '2';
            if (solvencyIndexValue >= solvencySetting.Rating_3_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_3_Maximum__c) return '3';
            if (solvencyIndexValue >= solvencySetting.Rating_4_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_4_Maximum__c) return '4';
            if (solvencyIndexValue >= solvencySetting.Rating_5_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_5_Maximum__c) return '5';
            if (solvencyIndexValue >= solvencySetting.Rating_6_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_6_Maximum__c) return '6';
        }
        return solvencyIndex;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Crif API errors   
    *  Created         : 27/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCrifAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CRIF_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 500) {
            String xml = response.getBody();
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xml);
	        Dom.XmlNode xmlDom = domDoc.getRootElement();
            String serviceError = CreditFactoryWebCrif.returnErrorMessage(xmlDom);
            if (! String.isEmpty(serviceError)) {
                errorMessage += ' ' + serviceError;
            }
        }
        
        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : check KRD API errors
    *  Created         : 06/08/2020 by Anton Buzak
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkKRDAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = KRD_API_ERROR + ' ' + CONTACT_ADMIN;
        }

        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Creditreform API errors   
    *  Created         : 17/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkLexisNexisAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = LEXISNEXIS_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        else {
            Dom.Document domDocLexisNexis = new Dom.Document();
            domDocLexisNexis.load(response.getBody());
            Dom.XmlNode xmlDomLexisNexis = domDocLexisNexis.getRootElement();
            errorMessage = CreditFactoryWebLexisNexis.returnErrorMessage(xmlDomLexisNexis);
            if (! String.isEmpty(errorMessage)) {
                errorMessage = LEXISNEXIS_API_ERROR + ' ' + CONTACT_ADMIN + ' ' + errorMessage;
            }
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check BIG API errors   
    *  Created         : 27/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkBigAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = BIG_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 500) {
            errorMessage += ' Internal Error';
        }
        
        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : check Schufa API errors
    *  Created         : 10/08/2020 by Anton Buzak
    *  Parameters      : response - API response,
                         requestType - type of API request
    *  Returns         : error message
    ******************************************************************************/
    public static String checkSchufaAPIErrors(HttpResponse response, String requestType) {
        String errorMessage;
        if (response.getStatusCode() != 404) {
            if (response.getStatusCode() != 200) {
                errorMessage = SCHUFA_API_ERROR + ' ' + CONTACT_ADMIN;
            } else if (requestType == 'orderStatus') {
                SchufaEntity orderStatusEntity = SchufaEntity.parse(response.getBody());
                for (SchufaEntity.Order order : orderStatusEntity.order) {
                    if (order.name == 'FullEconomyInfo' && order.failed == true &&
                            !order.reason.contains('Es werden derzeit keine Auskünfte zu diesem Unternehmen erteilt.')) {
                        errorMessage = SCHUFA_API_ERROR + ' ' + CONTACT_ADMIN + ' ' + order.reason;
                    }
                }
            }
        }

        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        }
        else if (response.getStatusCode() == 403 || response.getStatusCode() == 409) {
            SchufaEntity schufaEntity = SchufaEntity.parse(response.getBody());
            if (! String.isEmpty(schufaEntity.message)) {
                errorMessage += ' ' + schufaEntity.message;
            }
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : check Creditsafe API errors
    *  Created         : 04/09/2020 by Anton Buzak
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCreditsafeAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CREDITSAFE_API_ERROR + ' ' + CONTACT_ADMIN;
        }

        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        }
        else if (response.getStatusCode() == 401 || response.getStatusCode() == 403 || response.getStatusCode() == 404) {
            CreditsafeEntity creditsafeEntity = CreditsafeEntity.parse(response.getBody());
            if (! String.isEmpty(creditsafeEntity.message)) {
                errorMessage += ' ' + creditsafeEntity.message;
            }
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : check Company.info API errors
    *  Created         : 09/09/2020 by Anton Buzak
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCompanyInfoAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = COMPANY_INFO_API_ERROR + ' ' + CONTACT_ADMIN;
        }

        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        }
        else if (response.getStatusCode() == 500) {
	        Dom.Document domDoc = new Dom.Document();
            domDoc.load(response.getBody());
            Dom.XmlNode xmlDom = domDoc.getRootElement();
            String serviceError = CreditFactoryWebCompanyInfo.returnErrorMessage(xmlDom);
            if (! String.isEmpty(serviceError)) {
                errorMessage += ' ' + serviceError;
            }
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : check Cribis API errors
    *  Created         : 05/10/2020 by Anton Buzak
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCribisAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CRIBIS_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        else {
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(response.getBody());
            Dom.XmlNode xmlDom = domDoc.getRootElement();
            errorMessage = CreditFactoryWebCribis.returnErrorMessage(xmlDom);
            if (! String.isEmpty(errorMessage)) {
                errorMessage = CRIBIS_API_ERROR + ' ' + CONTACT_ADMIN + ' ' + errorMessage;
            }
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : check Coface API errors
    *  Created         : 15/10/2020 by Anton Buzak
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCofaceAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = COFACE_API_ERROR + ' ' + CONTACT_ADMIN;
        }

        if (response.getStatusCode() == 500) {
            String xml = response.getBody();
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xml);
	        Dom.XmlNode xmlDom = domDoc.getRootElement();
            Dom.XmlNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
	        String serviceError = CofaceWebservice.returnErrorMessage(globalBody);
            if (! String.isEmpty(serviceError)) {
                errorMessage += ' ' + serviceError;
            }
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Summary         : check Crediconnect API errors
    *  Created         : 26/11/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCrediconnectAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CREDICONNECT_API_ERROR + ' ' + CONTACT_ADMIN;
        }

        if (response.getStatusCode() == 500) {
            String xml = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xml);
            Dom.XmlNode xmlDom = domDoc.getRootElement();
            String serviceError = CreditFactoryWebCrediconnect.returnErrorMessage(xmlDom);
            if (! String.isEmpty(serviceError)) {
                errorMessage += ' ' + serviceError;
            }
        }

        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Creditreform API errors
    *  Created         : 10/12/2020 by Ivan Kulinkovich
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCreditreformAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CREDITREFORM_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        }
        
        String xml = response.getBody();
        xml = CreditFactoryWebCreditreform.clearSearchXML(xml);
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xml);
        Dom.XmlNode xmlDom = domDoc.getRootElement();
        Dom.XmlNode globalBody = CreditFactoryWebCreditreform.returnGlobalBody(xmlDom);
        if (response.getStatusCode() == 500) {
            String serviceError = CreditFactoryWebCreditreform.returnServiceError(globalBody);
            System.debug('1 == ' + serviceError);
            if (! String.isEmpty(serviceError) && (serviceError.contains('Das gewählte Produkt ist für das angefragte Unternehmen nicht verfügbar. Sie können eine Wirtschaftsauskunft ' +
                    'abrufen oder bestellen.') || serviceError.contains('Auskunft zur Zeit nicht möglich. Bitte Auftrag erteilen.'))) {
                errorMessage = null;
            }
            else {
                errorMessage += ' ' + serviceError;
            }
        }
        
        return errorMessage;
    }

    
    /*******************************************************************************
    *  Summary         : return service error   
    *  Created         : 18/02/2020
    *  Parameters      : serviceName - name of API service
    *  Returns         : String
    ******************************************************************************/
    public static String returnServiceError(String serviceName) {
        String serviceError;
        if (serviceName == 'Crif') {
            serviceError = CRIF_API_ERROR;
        }
        else if (serviceName == 'LexisNexis') {
            serviceError = LEXISNEXIS_API_ERROR;
        }
        else if (serviceName == 'BIG') {
            serviceError = BIG_API_ERROR;
        }
        else if (serviceName == 'KRD') {
            serviceError = KRD_API_ERROR;
        }
        else if (serviceName == 'Schufa') {
            serviceError = SCHUFA_API_ERROR;
        }
        else if (serviceName == 'Creditsafe') {
            serviceError = CREDITSAFE_API_ERROR;
        }
        else if (serviceName == 'Company.Info') {
            serviceError = COMPANY_INFO_API_ERROR;
        }
        else if (serviceName == 'Cribis') {
            serviceError = CRIBIS_API_ERROR;
        }
        else if (serviceName == 'Coface') {
            serviceError = COFACE_API_ERROR;
        }
        else if (serviceName == 'CrediconnectCH') {
            serviceError = CREDICONNECT_API_ERROR;
        }
        else if (serviceName == 'Creditreform') {
            serviceError = CREDITREFORM_API_ERROR;
        }
        
        return serviceError;
    }
    
    
    /*******************************************************************************
    *  Summary         : return attachments based on country   
    *  Created         : 23/04/2020
    *  Parameters      : country - country name
    *  Returns         : map of attachments
    ******************************************************************************/
    public static Map<String, String> returnAttachmentNamesMap(String country) {
        Map<String, Map<String, String>> countryToAttachmentNamesMap = new Map<String, Map<String, String>>{
            'Poland' => new Map<String, String>{
                'Report' => 'CrifReport.pdf',
                'KRD' => 'KrdReport.xml'
            },
            'Germany' => new Map<String, String>{
                'Report' => 'SchufaReport.pdf'
            },
            'Netherlands' => new Map<String, String>{
                'Report' => 'CreditsafeReport.pdf',
                'ParentReport' => 'CreditsafeReportParent.pdf'
            },
            'Belgium-NL' => new Map<String, String>{
                'Report' => 'CreditsafeReport.pdf'
            },
            'Belgium-FR' => new Map<String, String>{
                'Report' => 'CreditsafeReport.pdf'
            },
            'Slovakia' => new Map<String, String>{
                'Report' => 'CribisReport.pdf'
            },
            'Hungary' => new Map<String, String>{
                'Report' => 'CofaceReport.pdf'
            },
            'France' => new Map<String, String>{
                'Report' => 'CreditsafeReport.pdf'
            },
            'Czech Republic' => new Map<String, String>{
                'Report' => 'CribisReport.pdf'
            },
            'Switzerland-DE' => new Map<String, String>{
                'Report' => 'CrediconnectReport.pdf'
            },
            'Switzerland-FR' => new Map<String, String>{
                'Report' => 'CrediconnectReport.pdf'
            },
            'Switzerland-IT' => new Map<String, String>{
                'Report' => 'CrediconnectReport.pdf'
            },
            'Austria' => new Map<String, String>{
                'Report' => 'CrefoReport.pdf'
            },
            'Luxembourg' => new Map<String, String>{
                'Report' => 'CrefoReport.pdf'
            }
        };
        
        return countryToAttachmentNamesMap.get(country);
    }


    /*******************************************************************************
    *  Summary         : Compare 2 dates for equality
    *  CreatedDate     : 08/09/2020 by Anton Buzak
    *  Parameters      : firstDate - first date to compare,
                         secondDate - second date to compare
    *  Returns         : comparison result
    ******************************************************************************/
    public static Boolean areDatesEqual(Date firstDate, Date secondDate) {
        if (firstDate != null && secondDate != null) {
            if (firstDate.year() == secondDate.year() && firstDate.month() == secondDate.month() &&
                    firstDate.day() == secondDate.day()) {
                return true;
            }
        }

        return false;
    }


    /*******************************************************************************
    *  Summary         : return Direct Debit Mandate type
    *  CreatedDate     : 24/12/2020 by Anton Buzak
    *  Parameters      : country - country
                         riskCategory - risk category,
                         totalConsumption - total consumption of liters
    *  Returns         : Direct Debit Mandate Type
    ******************************************************************************/
    public static String returnAppropriateMandateType(String implKey,
                                                      String riskCategory,
                                                      Decimal totalConsumption) {
        String mandateType;
        String MANDATE_TYPE_CORE = 'Core';
        String MANDATE_TYPE_B2B = 'B2B';
        if (implKey == 'Germany') {
            if (riskCategory == 'Medium' && totalConsumption > 2500 ||
                    (riskCategory == 'High' || riskCategory == 'Very') && totalConsumption > 1500) {
                mandateType = MANDATE_TYPE_B2B;
            }
            else {
                mandateType = MANDATE_TYPE_CORE;
            }
        }
        else if (implKey == 'France') {
            if (totalConsumption > 1500) {
                mandateType = MANDATE_TYPE_B2B;
            }
            else {
                mandateType = MANDATE_TYPE_CORE;
            }
        }
        else if (implKey == 'Netherlands' || implKey == 'Austria' || implKey == 'Luxembourg') {
            if ((riskCategory == 'Medium' || riskCategory == 'High' || riskCategory == 'Very') && totalConsumption > 1500) {
                mandateType = MANDATE_TYPE_B2B;
            }
            else {
                mandateType = MANDATE_TYPE_CORE;
            }
        }
        else if (implKey == 'Belgium-NL' || implKey == 'Belgium-FR') {
            if ((riskCategory == 'Medium' || riskCategory == 'High' || riskCategory == 'Very') && totalConsumption >= 1000) {
                mandateType = MANDATE_TYPE_B2B;
            }
            else {
                mandateType = MANDATE_TYPE_CORE;
            }
        }
        else if (implKey == 'Slovakia CCS') {
            mandateType = MANDATE_TYPE_B2B;
        }

        return mandateType;
    }


    /*******************************************************************************
    *  Summary         : Compare 2 values
    *  CreatedDate     : 10/03/2021 by Ivan Kulinkovich
    *  Parameters      : value1 - first value to compare,
                         value2 - second value to compare
                         operator - explains how to compare
    *  Returns         : comparison result
    ******************************************************************************/
    public static Boolean compareValues(Decimal value1, Decimal value2, String operator) {
        switch on operator {
            when '=' {
                return (value1 == value2 ? true : false);
            }
            when '>' {
                return (value1 > value2 ? true : false);
            }
            when '>=' {
                return (value1 >= value2 ? true : false);
            }
            when '<' {
                return (value1 < value2 ? true : false);
            }
            when '<=' {
                return (value1 <= value2 ? true : false);
            }
            when '*' {
                return true;
            }
            when else {
                return false;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Generate default calculation
    *  CreatedDate     : 22/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : CreditFactoryCompany.CreditFactoryCalculation calculation
    ******************************************************************************/
    public static CreditFactoryCompany.CreditFactoryCalculation generateDefaultCalculation() {
        CreditFactoryCompany.CreditFactoryCalculation calculation = new CreditFactoryCompany.CreditFactoryCalculation();
        calculation.paymentDetail = '*';
        calculation.classRating = '*';
        calculation.dateOfFoundationMonths = '';
        calculation.dateOfFoundationMonthsOperator = '*';
        calculation.numberOfCards = '';
        calculation.numberOfCardsOperator = '*';
        calculation.totalConsumptionMinValue = '*';
        calculation.totalConsumptionMaxValue = '*';
        calculation.securityLevel = '*';
        calculation.newBusinessException = false;
        calculation.highRisk = false;

        return calculation;
    }


    /*******************************************************************************
    *  Summary         : Return risk category based on buffer
    *  CreatedDate     : 03/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : String riskCategory
    ******************************************************************************/
    public static String returnRiskCategory(Decimal buffer) {
        String riskCategory;
        if (buffer == 0.3) {
            riskCategory = 'Low';
        }
        else if (buffer == 0.2) {
            riskCategory = 'Medium';
        }
        else if (buffer == 0.1) {
            riskCategory = 'High';
        }
        else {
            riskCategory = 'Very';
        }

        return riskCategory;
    }


    public static String returnImplKey(String country, String recordType) {
        String implKey;
        if (recordType == 'Lotos') {
            implKey = 'Poland Lotos';
        }
        else if (recordType == 'CCS Opportunity Layout') {
            if (country == 'Czech Republic') {
                implKey = 'Czech Republic CCS';
            }
            else if (country == 'Slovakia') {
                implKey = 'Slovakia CCS';
            }
        }
        else {
            implKey = country;
        }

        return implKey;
    }
}