public class CreditFactoryImplCH extends CreditFactoryImpl {
    private transient Blob attachmentBody;


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 25/11/2020 by Ivan Kulinkovich
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : list of searched companies
    ******************************************************************************/
    public override List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
    	try {
            Map<String, String> searchParametersMap = CreditFactoryGlobalUtils.generateSearchParametersMap(searchParametersSet, this.internalCFCompany);
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('CrediconnectCH');
            List<CreditFactoryCompany> externalCompaniesList = new List<CreditFactoryCompany>();
            if (searchParametersMap.containsKey('vatNumber')) {
                externalCompaniesList = searchCompanyByVatNumber(creditSystem, searchParametersMap);
                searchParametersMap.remove('vatNumber');
            }

            if (! searchParametersMap.isEmpty() && externalCompaniesList.isEmpty()) {
                externalCompaniesList = searchCompanyByName(creditSystem, searchParametersMap);
            }

            return externalCompaniesList;
    	} catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.CREDICONNECT_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
    	}
    }


    /*******************************************************************************
    *  Summary         : Returns List of Credit Companies based on search by Vat Number.
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : CreditSystem creditSystem - credit system settings
     *                   Map<String, String> searchParametersMap - parameters for search
    *  Returns         : return List<CreditFactoryCompany>
    ******************************************************************************/
    public List<CreditFactoryCompany> searchCompanyByVatNumber(CreditSystem__c creditSystem, Map<String, String> searchParametersMap) {
    	HttpRequest request = CreditFactoryWebCrediconnect.generateSearchRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, searchParametersMap);
        Http http = new Http();
        HttpResponse response = http.send(request);
        this.apiErrorMessage = CreditFactoryGlobalUtils.checkCrediconnectAPIErrors(response);
        if (! String.isEmpty(this.apiErrorMessage)) {
            throw new CreditFactoryException(this.apiErrorMessage);
        }

        Dom.Document domDoc = new Dom.Document();
        domDoc.load(response.getBody());
        Dom.XmlNode xmlDom = domDoc.getRootElement();
        Dom.XmlNode searchResponseBody = CreditFactoryWebCrediconnect.returnSearchResponse(xmlDom);
        return CreditFactoryWebCrediconnect.returnSearchedCompanies(searchResponseBody);
    }


    /*******************************************************************************
    *  Summary         : Returns List of Credit Companies based on search by Vat Number.
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : CreditSystem creditSystem - credit system settings
     *                   Map<String, String> searchParametersMap - parameters for search
    *  Returns         : return List<CreditFactoryCompany>
    ******************************************************************************/
    public List<CreditFactoryCompany> searchCompanyByName(CreditSystem__c creditSystem, Map<String, String> searchParametersMap) {
    	HttpRequest request = CreditFactoryWebCrediconnect.generateSearchRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, searchParametersMap);
        Http http = new Http();
        HttpResponse response = http.send(request);
        this.apiErrorMessage = CreditFactoryGlobalUtils.checkCrediconnectAPIErrors(response);
        if (! String.isEmpty(this.apiErrorMessage)) {
            throw new CreditFactoryException(this.apiErrorMessage);
        }

        Dom.Document domDoc = new Dom.Document();
        domDoc.load(response.getBody());
        Dom.XmlNode xmlDom = domDoc.getRootElement();
        Dom.XmlNode searchResponseBody = CreditFactoryWebCrediconnect.returnSearchResponse(xmlDom);
        return CreditFactoryWebCrediconnect.returnSearchedCompanies(searchResponseBody);
    }


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : credit reports
    ******************************************************************************/
    public override CreditFactoryReportsItem requestCompanyReports(String companyId) {
        String serviceName = 'CrediconnectCH';
        try {
            CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('CrediconnectCH');
            HttpResponse crediconnectResponse = requestCrediconnectReport(creditSystem, companyId);
            this.apiErrorMessage = CreditFactoryGlobalUtils.checkCrediconnectAPIErrors(crediconnectResponse);
            if (! String.isEmpty(this.apiErrorMessage)) {
                throw new CreditFactoryException(this.apiErrorMessage);
            }

            Dom.XmlNode xmlNodeCrediconnect = getXmlNode(crediconnectResponse.getBody());
            Dom.XmlNode reportDom = CreditFactoryWebCrediconnect.returnReportBody(xmlNodeCrediconnect);
            this.externalCFCompany = CreditFactoryWebCrediconnect.returnReportCompany(reportDom, companyId, this.internalCFCompany.country);
            this.attachmentBody = EncodingUtil.base64Decode(CreditFactoryWebCrediconnect.returnBlobBody(reportDom));
            LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
            if (lexisNexisSettings.Active__c == true) {
                serviceName = 'LexisNexis';
                HttpResponse lexisNexisResponse = requestLexisNexisReport(lexisNexisSettings);
                this.apiErrorMessage = CreditFactoryGlobalUtils.checkLexisNexisAPIErrors(lexisNexisResponse);
                if (! String.isEmpty(this.apiErrorMessage)) {
                    throw new CreditFactoryException(this.apiErrorMessage);
                }

                Dom.XmlNode XmlNodeLexisNexis = getXmlNode(lexisNexisResponse.getBody());
                Dom.XmlNode emailRiskBody = CreditFactoryWebLexisNexis.returnEmailRiskBody(XmlNodeLexisNexis);
                this.externalCFCompany = CreditFactoryWebLexisNexis.returnReportCompany(emailRiskBody, this.externalCFCompany);
            }

            reportsItem.companiesList = new List<CreditFactoryCompany>();
            reportsItem.companiesList.add(this.externalCFCompany);
            reportsItem.isReportAvailable = true;
            return reportsItem;
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
            String companyIdText = 'Company Id: ' + companyId;
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage + '. ' + companyIdText);
            }
            else if (e.getMessage().contains('Read timed out')) {
                throw new CreditFactoryException(CreditFactoryGlobalUtils.returnServiceError(serviceName) + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.' + '. ' + companyIdText);
            }
            else {
                throw new CreditFactoryException('Set company error. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + '. ' + companyIdText);
            }
        }
    }


    /*******************************************************************************
	*  Summary         : Send request to Credit System to get company, employees and pdf report
	*  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : Crif report request
	******************************************************************************/
    private HttpResponse requestCrediconnectReport(CreditSystem__c creditSystem, String companyId) {
		HttpRequest request = CreditFactoryWebCrediconnect.generateReportRequest(
            creditSystem.Endpoint__c, creditSystem.UserName__c,
            creditSystem.Password__c, companyId);
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }


    /*******************************************************************************
    *  Summary         : Return currency Iso code based on country
    *  Created         : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    protected override String returnCurrencyIsoCode(String countryCode) {
		return 'CHF';
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : paymentDetailsSet - possible payment details,
                         validationItemsMap - validations results map
    *  Returns         : Credit Factory result structure
    ******************************************************************************/
    public override CreditFactoryResult doCreditScoring(Set<String> paymentDetailsSet, Map<String, CreditFactoryValidationItem> validationItemsMap) {
        try {
            CreditFactoryResult cfResult = new CreditFactoryResult();
            if (validationItemsMap.containsKey('EmailRisk') && validationItemsMap.get('EmailRisk').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '009';
                return cfResult;
            }
            else if (validationItemsMap.containsKey('BlackList') && validationItemsMap.get('BlackList').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '008';
                return cfResult;
            }

            this.validationItemsMap = validationItemsMap;

            setFuelPriceIndex();
            setBuffer();
            setRecommendedCreditLimit();
            setCalculationsForNewBusinessException(paymentDetailsSet);

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '30+14') {
                    this.creditLimit30Plus14 = calculateCreditLimit(30, 14);
                    this.securityLevel30Plus14 = calculateSecurityLevel(this.creditLimit30Plus14, 30, 14);
                    this.deposit30Plus14 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel30Plus14, this.creditLimit30Plus14, 30, 14, this.recommendedCreditLimit);
                    this.deposit30Plus14 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit30Plus14);
                    this.maxCreditLimit30Plus14 = calculateMaxCreditLimit(30, 14, this.creditLimit30Plus14, this.deposit30Plus14);
                    this.maxCreditLimit30Plus14 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit30Plus14);
                    if (this.securityLevel30Plus14 != null) {
                        this.depositReason30plus14 = setDepositReason(this.securityLevel30Plus14, 30, 14);
                    }
                } else if (paymentDetail == '30+27') {
                    this.creditLimit30Plus27 = calculateCreditLimit(30, 27);
                    this.securityLevel30Plus27 = calculateSecurityLevel(this.creditLimit30Plus27, 30, 27);
                    this.deposit30Plus27 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel30Plus27, this.creditLimit30Plus27, 30, 27, this.recommendedCreditLimit);
                    this.deposit30Plus27 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit30Plus27);
                    this.maxCreditLimit30Plus27 = calculateMaxCreditLimit(30, 27, this.creditLimit30Plus27, this.deposit30Plus27);
                    this.maxCreditLimit30Plus27 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit30Plus27);
                    if (this.securityLevel30Plus27 != null) {
                        this.depositReason30plus27 = setDepositReason(this.securityLevel30Plus27, 30, 27);
                    }
                }
            }

            this.riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);

            setDefaultPaymentDetails(paymentDetailsSet);
            setDecision();
            setMessages();
            setAvailableButtons();
            setResultsList();

            cfResult.verdict = this.verdict;
            cfResult.statusCode = this.statusCode;
            cfResult.messagesList = this.messagesList;
            cfResult.billingPeriod = this.billingPeriod;
            cfResult.paymentTerms = this.paymentTerms;
            cfResult.creditLimit = this.creditLimit;
            cfResult.securityLevel = this.securityLevel;
            cfResult.deposit = this.deposit;
            cfResult.depositReason = this.depositReason;
            cfResult.maxCreditLimit = this.maxCreditLimit;
            cfResult.availableButtonsList = this.availableButtonsList;
            cfResult.riskCategory = this.riskCategory;
            cfResult.paymentMethodsSet = new List<String>{
                    'Direct Debit', 'Bank Transfer'
            };
            cfResult.invoicesSet = new List<String>{
                    'e-Invoicing', 'Paper Invoice'
            };

            cfResult.resultsList = this.resultsList;

            return cfResult;
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Scoring failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
		}
    }


    /*******************************************************************************
    *  Summary         : Set fuel price index
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance(this.internalCFCompany.country);
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setBuffer() {
        if (this.externalCFCompany.classRating == '1' || this.externalCFCompany.classRating == '2') {
            this.buffer = 0.3;
	    }
        else if (this.externalCFCompany.classRating == '3') {
           this.buffer = 0.2;
	    }
        else if (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5') {
	    	this.buffer = 0.1;
	    }
        else if (this.externalCFCompany.classRating == '6') {
            this.buffer = 0;
        }
    }


    /*******************************************************************************
    *  Summary         : set recommended CL
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setRecommendedCreditLimit() {
		this.recommendedCreditLimit = 0;
		if (this.externalCFCompany.creditLimit != null && this.externalCFCompany.creditLimit.isNumeric()) {
			this.recommendedCreditLimit = Decimal.valueOf(this.externalCFCompany.creditLimit);
		}
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limit
    *  Created         : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : credit limit
    ******************************************************************************/
    private Decimal calculateCreditLimit(Decimal billingPeriod, Decimal paymentTerms) {
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        Decimal buffer = (this.calculationsMap.get(paymentDetail).highRisk ? 0.1 : this.buffer);
        Decimal creditLimit = this.internalCFCompany.totalConsumption * this.fuelPriceIndex * ((billingPeriod + paymentTerms) / 30) * (1 + buffer);
        creditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(creditLimit);
        return creditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate security level
    *  Created         : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
                         billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        String securityLevelForNewBusiness = this.calculationsMap.get(paymentDetail).securityLevel;
        if (securityLevelForNewBusiness == '*') {
            if (this.externalCFCompany.classRating == '1') {
                securityLevel = calculateSecurityLevelRating1();
            }
            else if (this.externalCFCompany.classRating == '2') {
                securityLevel = calculateSecurityLevelRating2();
            }
            else if (this.externalCFCompany.classRating == '3') {
                securityLevel = calculateSecurityLevelRating3();
            }
            else if (this.externalCFCompany.classRating == '4') {
                securityLevel = calculateSecurityLevelRating4(creditLimit);
            }
            else if (this.externalCFCompany.classRating == '5') {
                securityLevel = calculateSecurityLevelRating5();
            }
            else if (this.externalCFCompany.classRating == '6') {
                securityLevel = calculateSecurityLevelRating6();
            }
        }
        else if (securityLevelForNewBusiness != null) {
            securityLevel = Decimal.valueOf(securityLevelForNewBusiness);
        }

        if (securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
            securityLevel = 100;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 1
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1() {
        Decimal securityLevel;
        if (isDirectorChanged() || isAddressChanged() || isNameChanged()) {
            securityLevel = 100;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level rating 2
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2() {
        Decimal securityLevel;
        if (isDirectorChanged() || isAddressChanged() || isNameChanged()) {
            securityLevel = 100;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level rating 3
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3() {
        Decimal securityLevel;
        if (isDirectorChanged() || isAddressChanged() || isNameChanged()) {
            securityLevel = 100;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level rating 4
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
                         billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4(Decimal creditLimit) {
        Decimal securityLevel;
        if (isDirectorChanged() || isAddressChanged() || isNameChanged()) {
            securityLevel = 100;
        }
        else if (creditLimit > this.recommendedCreditLimit * 2) {
            securityLevel = 4;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level rating 5
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
        Decimal securityLevel = 100;
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level rating 6
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 6
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating6() {
        Decimal securityLevel = 110;
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level if it's a new business exception
    *  Created         : 30/04/2021 by Ivan Kulinkovich
    *  Parameters      : Set<String> paymentDetailsSet
    *  Returns         : security level
    ******************************************************************************/
    private void setCalculationsForNewBusinessException(Set<String> paymentDetailsSet) {
        this.calculationsMap = new Map<String, CreditFactoryCompany.CreditFactoryCalculation>();
        List<CreditFactoryCompany.CreditFactoryCalculation> calculations = this.internalCFCompany.calculations;
        for (String paymentDetail : paymentDetailsSet) {
            for (CreditFactoryCompany.CreditFactoryCalculation calculation : calculations) {
                if (arePaymentDetailsValid(paymentDetail, calculation.paymentDetail) && isClassRatingValid(calculation.classRating) &&
                        isDateOfFoundationMonthValid(calculation.dateOfFoundationMonths, calculation.dateOfFoundationMonthsOperator) &&
                        isNumberOfCardsValid(calculation.numberOfCards, calculation.numberOfCardsOperator) &&
                        isTotalConsumptionValid(calculation.totalConsumptionMinValue, calculation.totalConsumptionMaxValue)) {
                    if (calculation.securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
                        calculation.newBusinessException = false;
                    }

                    if (! (calculation.newBusinessException && this.internalCFCompany.paperInvoice))  {
                        this.calculationsMap.put(paymentDetail, calculation);
                        break;
                    }
                }
            }

            if ((! (this.externalCFCompany.classRating == '5' || this.externalCFCompany.classRating == '6') &&
                    this.calculationsMap.containsKey(paymentDetail) && (isDirectorChanged() || isAddressChanged() || isNameChanged())) ||
                    ! this.calculationsMap.containsKey(paymentDetail)) {
                CreditFactoryCompany.CreditFactoryCalculation calculation = CreditFactoryGlobalUtils.generateDefaultCalculation();
                this.calculationsMap.put(paymentDetail, calculation);
            }
        }
    }


    /*******************************************************************************
    *  Summary         : check for payment detail
    *  Created         : 30/04/2021 by Ivan Kulinkovich
    *  Parameters      : String classRating
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean arePaymentDetailsValid(String paymentDetail, String calculationPaymentDetail) {
        if (paymentDetail == calculationPaymentDetail || calculationPaymentDetail == '*') {
            return true;
        }

        return false;
    }


    /*******************************************************************************
    *  Summary         : check for class rating
    *  Created         : 30/04/2021 by Ivan Kulinkovich
    *  Parameters      : String classRating
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isClassRatingValid(String classRating) {
        if (classRating == this.externalCFCompany.classRating || classRating == '*') {
            return true;
        }

        return false;
    }


    /*******************************************************************************
    *  Summary         : check for date of foundation
    *  Created         : 30/04/2021 by Ivan Kulinkovich
    *  Parameters      : String months, String operator
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isDateOfFoundationMonthValid(String months, String operator) {
        Date dateOfFoundation = returnDateOfFoundation();
        if (operatorsSet.contains(operator) && ! String.isEmpty(months) && dateOfFoundation != null) {
            Decimal value1 = dateOfFoundation.monthsBetween(Date.today());
            Decimal value2 = Integer.valueOf(months);
            return CreditFactoryGlobalUtils.compareValues(value1, value2, operator);
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : check for number of cards
    *  Created         : 30/04/2021 by Ivan Kulinkovich
    *  Parameters      : String numberOfCards, String operator
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isNumberOfCardsValid(String numberOfCards, String operator) {
        if (operatorsSet.contains(operator) && ! String.isEmpty(numberOfCards) && this.internalCFCompany.numberOfCards != null) {
            Decimal value1 = Integer.valueOf(this.internalCFCompany.numberOfCards);
            Decimal value2 = Integer.valueOf(numberOfCards);
            return CreditFactoryGlobalUtils.compareValues(value1, value2, operator);
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : check for total consumption
    *  Created         : 30/04/2021 by Ivan Kulinkovich
    *  Parameters      : String minValue, String maxValue
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isTotalConsumptionValid(String minValue, String maxValue) {
        if (! String.isEmpty(minValue) && ! String.isEmpty(maxValue)) {
            if (minValue == '*' && maxValue == '*' ||
                    minValue == '*' && maxValue != '*' && this.internalCFCompany.totalConsumption <= Integer.valueOf(maxValue) ||
                    minValue != '*' && maxValue == '*' && this.internalCFCompany.totalConsumption >= Integer.valueOf(minValue) ||
                    this.internalCFCompany.totalConsumption >= Integer.valueOf(minValue) && this.internalCFCompany.totalConsumption <= Integer.valueOf(maxValue)) {
                return true;
            }
            else {
                return false;
            }
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : Check if company director was changed
    *  CreatedDate     : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isDirectorChanged() {
		Date dateOfLastChangeOfDirector = returnDateOfLastChange(this.externalCFCompany.dateOfLastChangeOfDirector);
		Date dateOfFoundation = returnDateOfFoundation();
		if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            return true;
        } else {
			return false;
		}
    }


    /*******************************************************************************
    *  Summary         : Check if company address was changed
    *  CreatedDate     : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isAddressChanged() {
		Date dateOfLastChangeOfAddress = returnDateOfLastChange(this.externalCFCompany.dateOfLastChangeOfAddress);
		Date dateOfFoundation = returnDateOfFoundation();
		if (dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            return true;
        } else {
			return false;
		}
    }


    /*******************************************************************************
    *  Summary         : Check if company name was changed
    *  CreatedDate     : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isNameChanged() {
		Date dateOfLastChangeOfName = returnDateOfLastChange(this.externalCFCompany.dateOfLastChangeOfName);
		Date dateOfFoundation = returnDateOfFoundation();
		if (dateOfLastChangeOfName != null && dateOfLastChangeOfName.monthsBetween(Date.today()) <= 6 &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            return true;
        } else {
			return false;
		}
    }


    /*******************************************************************************
    *  Summary         : Return Date of Foundation based on string
    *  CreatedDate     : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Date
    ******************************************************************************/
    private Date returnDateOfFoundation() {
        Date dateOfFoundation;
        if (! String.isEmpty(this.externalCFCompany.dateOfFoundation)) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(0, 4)),
                Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(5, 7)),
                Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(8, 10)));
        }

        return dateOfFoundation;
    }


	/*******************************************************************************
    *  Summary         : Return Date of Last Change Of Address, Director or Name
    *  CreatedDate     : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : String dateOfLastChangeString
    *  Returns         : Date
    ******************************************************************************/
    private Date returnDateOfLastChange(String dateOfLastChangeString) {
        Date dateOfLastChange;
        if (dateOfLastChangeString != null && dateOfLastChangeString.length() == 7) {
            dateOfLastChange = Date.newInstance(Integer.valueOf(dateOfLastChangeString.substring(3, 7)),
                Integer.valueOf(dateOfLastChangeString.substring(0, 2)), Date.today().day());
        }

        return dateOfLastChange;
    }


    /*******************************************************************************
    *  Summary         : calculate max CL
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal billingPeriod, Decimal paymentTerms, Decimal creditLimit, Decimal deposit) {
        Decimal maxCreditLimit;
        if (deposit > 0) {
            maxCreditLimit = creditLimit;
        }
        else {
			if (creditLimit * 2 < 10000) {
				maxCreditLimit = creditLimit * 2;
			}
			else {
				maxCreditLimit = 10000;
			}

			if (maxCreditLimit > this.recommendedCreditLimit * 2 && this.externalCFCompany.classRating == '4') {
				maxCreditLimit = this.recommendedCreditLimit * 2;
			}

            String paymentDetail = billingPeriod + '+' + paymentTerms;
            CreditFactoryCompany.CreditFactoryCalculation calculation = this.calculationsMap.get(paymentDetail);
            if (calculation.totalConsumptionMaxValue != '*') {
                Decimal totalConsumption = Integer.valueOf(calculation.totalConsumptionMaxValue);
                Decimal buffer = (calculation.highRisk ? 0.1 : this.buffer);
                Decimal creditLimitMax = ((totalConsumption * this.fuelPriceIndex + this.internalCFCompany.nonFuelExposure) * ((billingPeriod + paymentTerms) / 30.0) * (1.0 + buffer)).setScale(2);
                if (creditLimit * 2 < creditLimitMax) {
                    maxCreditLimit = creditLimit * 2;
                }
                else {
                    maxCreditLimit = creditLimitMax;
                }
            }
        }

        maxCreditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(maxCreditLimit);

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : set deposit reason
    *  Created         : 18/02/2021 by Ivan Kulinkovich
    *  Parameters      : securityLevel - security level
    *  Returns         : deposit reason
    ******************************************************************************/
    private String setDepositReason(Decimal securityLevel, Decimal billingPeriod, Decimal paymentTerms) {
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        String depositReason = this.calculationsMap.get(paymentDetail).depositReason;
        if (String.isEmpty(depositReason)) {
            depositReason = 'Low credit rating (rating ' + this.externalCFCompany.classRating + ')';
            if (securityLevel == 4) {
                depositReason = 'Low Recommended CL';
            }
            else if (this.externalCFCompany.classRating != '5' && this.externalCFCompany.classRating != '6') {
                if (isDirectorChanged() || isAddressChanged() || isNameChanged()) {
                    depositReason = 'Address/Director/Name change 6M';
                }
                else if (this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
                    depositReason = 'Invalid contact';
                }
            }
        }

        return depositReason;
    }


    /*******************************************************************************
    *  Summary         : set default billing period and payment terms
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
        if (paymentDetailsSet.contains('30+14') && this.calculationsMap.get('30+14').paymentDetail == '30+14' && this.creditLimit30Plus27 < 10000 &&
                ! (this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false &&
                this.calculationsMap.get('30+14').securityLevel == null)) {
            setDefaultValues30Plus14();
        }
        else if (paymentDetailsSet.contains('30+27') && this.creditLimit30Plus27 < 10000) {
            setDefaultValues30Plus27();
        }
    }


    /*******************************************************************************
    *  Summary         : set default values for 30+14
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues30Plus14() {
        this.billingPeriod = '30';
        this.paymentTerms = '14';
        this.creditLimit = this.creditLimit30Plus14;
        this.securityLevel = this.securityLevel30Plus14;
        this.deposit = this.deposit30Plus14;
        this.depositReason = this.depositReason30plus14;
        this.maxCreditLimit = this.maxCreditLimit30Plus14;
        this.isNewBusinessException = this.calculationsMap.get('30+14').newBusinessException;
        this.riskCategory = (this.calculationsMap.get('30+14').highRisk ? 'High' : this.riskCategory);
    }


    /*******************************************************************************
    *  Summary         : set default values for 30+27
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues30Plus27() {
        this.billingPeriod = '30';
        this.paymentTerms = '27';
        this.creditLimit = this.creditLimit30Plus27;
        this.securityLevel = this.securityLevel30Plus27;
        this.deposit = this.deposit30Plus27;
        this.depositReason = this.depositReason30plus27;
        this.maxCreditLimit = this.maxCreditLimit30Plus27;
        this.isNewBusinessException = this.calculationsMap.get('30+27').newBusinessException;
        this.riskCategory = (this.calculationsMap.get('30+27').highRisk ? 'High' : this.riskCategory);
    }


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDecision() {
		if (this.billingPeriod != null && this.paymentTerms != null) {
			this.verdict = 'Yes';
			this.statusCode = '001';
		}
		else {
			this.verdict = 'No';
			this.statusCode = '004';
		}
    }


    /*******************************************************************************
    *  Summary         : set decision description
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMessages() {
        this.messagesList = new List<CreditFactoryResult.Message>();
        if (this.statusCode == '001') {
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Billing Period can be set to ' + this.billingPeriod));
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Payment Terms can be set to ' + this.paymentTerms));
            if (this.deposit > 0) {
                this.messagesList.add(new CreditFactoryResult.Message('info', '</br>Deposit to pay: ' + this.deposit + ' CHF.</br>' +
                    'Deposit reason: ' + this.depositReason + '</br></br>' +
                    'You can update Desired Payment Terms and Desired Billing Period in the Opportunity and restart Credit Factory to recalculate the deposit amount.'));
            }
        }
        else if (this.statusCode == '004') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Requested limit too high. Please refer to credit.'));
        }
    }


    /*******************************************************************************
    *  Summary         : set available button (pending deposit, closed won etc)
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setAvailableButtons() {
        this.availableButtonsList = new List<String>();
        if (this.verdict == 'Yes') {
            this.availableButtonsList.add('Update Opportunity');
            if (this.deposit != null && this.deposit != 0) {
                this.availableButtonsList.add('Pending Deposit');
            }
            else {
                if (this.internalCFCompany.paymentMethod == 'Lastschrift' && this.internalCFCompany.directDebitFormAvailable == false) {
                    this.availableButtonsList.add('Pending SEPA');
                }
                else {
                    this.availableButtonsList.add('Closed Won');
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : set results list
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList() {
		this.resultsList = new List<CreditFactoryResult>();
        CreditFactoryResult cfResult = new CreditFactoryResult();
        cfResult.verdict = this.verdict;
        cfResult.statusCode = this.statusCode;
        cfResult.billingPeriod = this.billingPeriod;
        cfResult.paymentTerms = this.paymentTerms;
        cfResult.creditLimit = this.creditLimit;
        cfResult.securityLevel = this.securityLevel;
        cfResult.deposit = this.deposit;
        cfResult.depositReason = this.depositReason;
        cfResult.maxCreditLimit = this.maxCreditLimit;
        cfResult.riskCategory = this.riskCategory;
        cfResult.classRating = (this.isNewBusinessException == true ? '0-EX' : this.externalCFCompany.classRating);
        cfResult.paymentMethodsSet = new List<String> {'Direct Debit', 'Bank Transfer'};
        cfResult.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
        cfResult.isDefault = true;

        this.resultsList.add(cfResult);
	}


    /*******************************************************************************
    *  Summary         : create pdf reports asynchronously
    *  Created         : 27/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public override void createPdfReports(String opportunityId) {
        // create schedule job for Crediconnect pdf report
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' +
                Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() +
                Datetime.now().addSeconds(5).millisecond();
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(this.externalCFCompany.creditSystemCompanyNumber, null, opportunityId, this.attachmentBody, this.externalCFCompany.country);
        System.schedule(scheduleName, schedule, pdfSchedule);
    }


    private static Set<String> operatorsSet = new Set<String> {
            '>',
            '>=',
            '=',
            '<',
            '<=',
            '*'
    };
}