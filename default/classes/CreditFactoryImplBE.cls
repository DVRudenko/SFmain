public class CreditFactoryImplBE extends CreditFactoryImpl {


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : list of searched companies
    ******************************************************************************/
    public override List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
    	try {
            Http http = new Http();
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Creditsafe');
			HttpRequest authRequest = CreditFactoryWebCreditsafe.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
			HttpResponse authResponse = http.send(authRequest);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkCreditsafeAPIErrors(authResponse);
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}

			CreditsafeEntity authEntity = CreditsafeEntity.parse(authResponse.getBody());
            Map<String, String> searchParametersMap = CreditFactoryGlobalUtils.generateSearchParametersMap(searchParametersSet, this.internalCFCompany);
            List<CreditFactoryCompany> externalCompaniesList = new List<CreditFactoryCompany>();
			if (searchParametersMap.containsKey('taxId')) {
                String taxId = searchParametersMap.get('taxId');
                if (taxId != null && taxId.length() == 10 && taxId.startsWith('0')) {
                    taxId = taxId.substring(1, 10);
                }
                searchParametersMap.put('taxId', taxId);
				externalCompaniesList = searchCompanyByTaxId(authEntity, creditSystem, searchParametersMap);
				searchParametersMap.remove('taxId');
			}

			if (! searchParametersMap.isEmpty() && externalCompaniesList.isEmpty()) {
				externalCompaniesList = searchByAllParameters(authEntity, creditSystem, searchParametersMap);
			}

			return externalCompaniesList;
    	} catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.CREDITSAFE_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
    	}
    }


	/*******************************************************************************
    *  Summary         : Returns Credit Company based on search by Tax Id.
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : authEntity - auth data,
						 creditSystem - Creditsafe settings,
    *  Returns         : companies list
    ******************************************************************************/
    private List<CreditFactoryCompany> searchCompanyByTaxId(CreditsafeEntity authEntity, CreditSystem__c creditSystem, Map<String, String> searchParametersMap) {
		Http http = new Http();
		HttpRequest searchRequest = CreditFactoryWebCreditsafe.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c,
																		 this.internalCFCompany.countryCode.substring(0, 2), searchParametersMap);
		HttpResponse searchResponse = http.send(searchRequest);
		this.apiErrorMessage = CreditFactoryGlobalUtils.checkCreditsafeAPIErrors(searchResponse);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		CreditsafeEntity searchEntity = CreditsafeEntity.parse(searchResponse.getBody());
		List<CreditFactoryCompany> creditCompaniesList = CreditFactoryWebCreditsafe.returnSearchCompany(searchEntity, this.internalCFCompany.countryCode);
		return creditCompaniesList;
    }


	/*******************************************************************************
    *  Summary         : Returns Credit Company based on search by name and address
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : authEntity - auth data,
						 creditSystem - Creditsafe settings,
						 searchParametersMap - parameters for search
    *  Returns         : companies list
    ******************************************************************************/
    private List<CreditFactoryCompany> searchByAllParameters(CreditsafeEntity authEntity, CreditSystem__c creditSystem, Map<String, String> searchParametersMap) {
		Http http = new Http();
		HttpRequest searchRequest = CreditFactoryWebCreditsafe.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c,
																		 this.internalCFCompany.countryCode.substring(0, 2), searchParametersMap);
		HttpResponse searchResponse = http.send(searchRequest);
		this.apiErrorMessage = CreditFactoryGlobalUtils.checkCreditsafeAPIErrors(searchResponse);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		CreditsafeEntity searchEntity = CreditsafeEntity.parse(searchResponse.getBody());
		List<CreditFactoryCompany> creditCompaniesList = CreditFactoryWebCreditsafe.returnSearchCompany(searchEntity, this.internalCFCompany.countryCode);
		return creditCompaniesList;
    }


	/*******************************************************************************
    *  Summary         : Send API request for credit report
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : companyId - id of selected company
    *  Returns         : credit reports
    ******************************************************************************/
    public override CreditFactoryReportsItem requestCompanyReports(String companyId) {
        String serviceName = 'Creditsafe';
        try {
            CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
            CreditSystem__c creditsafeSettings = CreditSystem__c.getInstance('Creditsafe');
            HttpResponse creditsafeReportResponse = requestCreditsafeReport(creditsafeSettings, companyId);
            this.externalCFCompany = CreditFactoryWebCreditsafe.returnReportCompany(creditsafeReportResponse.getBody(), this.internalCFCompany.country);

            LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
            if (lexisNexisSettings.Active__c == true) {
                serviceName = 'LexisNexis';
                HttpResponse lexisNexisResponse = requestLexisNexisReport(lexisNexisSettings);
                this.apiErrorMessage = CreditFactoryGlobalUtils.checkLexisNexisAPIErrors(lexisNexisResponse);
                if (!String.isEmpty(this.apiErrorMessage)) {
                    throw new CreditFactoryException(this.apiErrorMessage);
                }

                Dom.XmlNode xmlNodeLexisNexis = getXmlNode(lexisNexisResponse.getBody());
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
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage + '. ' + companyIdText);
			} else if (e.getMessage().contains('Read timed out')) {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.returnServiceError(serviceName) + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.' + '. ' + companyIdText);
			} else {
				throw new CreditFactoryException('Set company error. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + '. ' + companyIdText);
			}
        }
    }


	/*******************************************************************************
	*  Summary         : Send request for Creditsafe report
	*  CreatedDate     : 17/09/2020 by Anton Buzak
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : creditsafe report response
	******************************************************************************/
    private HttpResponse requestCreditsafeReport(CreditSystem__c creditSystem, String companyId) {
		Http http = new Http();
		HttpRequest authRequest = CreditFactoryWebCreditsafe.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
		HttpResponse authResponse = http.send(authRequest);
		this.apiErrorMessage = CreditFactoryGlobalUtils.checkCreditsafeAPIErrors(authResponse);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		CreditsafeEntity authEntity = CreditsafeEntity.parse(authResponse.getBody());
		HttpRequest creditsafeReportRequest = CreditFactoryWebCreditsafe.generateJSONReportRequest(authEntity.token, creditSystem.Endpoint__c, companyId);
		HttpResponse creditsafeReportResponse = http.send(creditsafeReportRequest);
		this.apiErrorMessage = CreditFactoryGlobalUtils.checkCreditsafeAPIErrors(creditsafeReportResponse);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		return creditsafeReportResponse;
    }


	/*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 17/09/2020 by Anton Buzak
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
            else if (validationItemsMap.containsKey('EmptyAddress') && validationItemsMap.get('EmptyAddress').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '013';
                return cfResult;
            }

            this.validationItemsMap = validationItemsMap;

            setFuelPriceIndex();
            setBuffer();
			setRecommendedCreditLimit();
			setDateOfFoundation();
			setDateOfLastChangeOfDirector();
			setDateOfLastChangeOfAddress();
            setCalculationsForNewBusinessException(paymentDetailsSet);

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '7+7') {
                    this.creditLimit7Plus7 = calculateCreditLimit(7, 7);
                    this.securityLevel7Plus7 = calculateSecurityLevel(this.creditLimit7Plus7, 7, 7);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel7Plus7, this.creditLimit7Plus7, 7, 7, this.recommendedCreditLimit);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit7Plus7);
                    this.maxCreditLimit7Plus7 = calculateMaxCreditLimit(this.creditLimit7Plus7, this.deposit7Plus7, 7, 7);
                    this.isNewBusinessException7plus7 = this.isNewBusinessException;
					if (this.creditLimit7Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit7Plus7 * 1.5 <= this.maxCreditLimit7Plus7 && this.deposit7Plus7 == 0) {
						this.creditLimit7Plus7 = this.creditLimit7Plus7 * 1.5;
						this.creditLimit7Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit7Plus7);
					}

                    if (this.securityLevel7Plus7 != null) {
                        this.depositReason7plus7 = setDepositReason(this.securityLevel7Plus7, 7, 7);
                    }
                }
				else if (paymentDetail == '15+7') {
                    this.creditLimit15Plus7 = calculateCreditLimit(15, 7);
                    this.securityLevel15Plus7 = calculateSecurityLevel(this.creditLimit15Plus7, 15, 7);
                    this.deposit15Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus7, this.creditLimit15Plus7, 15, 7, this.recommendedCreditLimit);
                    this.deposit15Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus7);
                    this.maxCreditLimit15Plus7 = calculateMaxCreditLimit(this.creditLimit15Plus7, this.deposit15Plus7, 15, 7);
                    this.maxCreditLimit15Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit15Plus7);
                    this.isNewBusinessException15plus7 = this.isNewBusinessException;
					if (this.creditLimit15Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit15Plus7 * 1.5 <= this.maxCreditLimit15Plus7 && this.deposit15Plus7 == 0) {
						this.creditLimit15Plus7 = this.creditLimit15Plus7 * 1.5;
						this.creditLimit15Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit15Plus7);
					}

                    if (this.securityLevel15Plus7 != null) {
                        this.depositReason15plus7 = setDepositReason(this.securityLevel15Plus7, 15, 7);
                    }
                }
				else if (paymentDetail == '30+7') {
                    this.creditLimit30Plus7 = calculateCreditLimit(30, 7);
                    this.securityLevel30Plus7 = calculateSecurityLevel(this.creditLimit30Plus7, 30, 7);
                    this.deposit30Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel30Plus7, this.creditLimit30Plus7, 30, 7, this.recommendedCreditLimit);
                    this.deposit30Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit30Plus7);
                    this.maxCreditLimit30Plus7 = calculateMaxCreditLimit(this.creditLimit30Plus7, this.deposit30Plus7, 30, 7);
                    this.isNewBusinessException30plus7 = this.isNewBusinessException;
					if (this.creditLimit30Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit30Plus7 * 1.5 <= this.maxCreditLimit30Plus7 && this.deposit30Plus7 == 0) {
						this.creditLimit30Plus7 = this.creditLimit30Plus7 * 1.5;
						this.creditLimit30Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit30Plus7);
					}

                    if (this.securityLevel30Plus7 != null) {
                        this.depositReason30plus7 = setDepositReason(this.securityLevel30Plus7, 30, 7);
                    }
                }
            }

            this.riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);

            setDefaultPaymentDetails(paymentDetailsSet);
            setDecision();
            setMessages();
            setAvailableButtons();
			setResultsList(paymentDetailsSet);

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
				'Direct Debit'
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
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance(this.internalCFCompany.country);
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setBuffer() {
		if (this.externalCFCompany.classRating == '1') {
			this.buffer = 0.3;
		}
		else if (this.externalCFCompany.classRating == '2') {
			this.buffer = 0.2;
		}
		else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4') {
			this.buffer = 0.1;
		}
		else if (this.externalCFCompany.classRating == '5') {
			this.buffer = 0;
		}
    }


	/*******************************************************************************
    *  Summary         : set recommended CL
    *  Created         : 17/09/2020 by Anton Buzak
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
    *  Summary         : set date of foundation
    *  Created         : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDateOfFoundation() {
		if (this.externalCFCompany.dateOfFoundation != null) {
			this.dateOfFoundation = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(0, 4)), Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(5, 7)),
				Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(8, 10)));
		}
    }


	/*******************************************************************************
    *  Summary         : set date of last change of director
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDateOfLastChangeOfDirector() {
        if (this.externalCFCompany.dateOfLastChangeOfDirector != null) {
            this.dateOfLastChangeOfDirector = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfLastChangeOfDirector.substring(0, 4)),
                Integer.valueOf(this.externalCFCompany.dateOfLastChangeOfDirector.substring(5, 7)), Integer.valueOf(this.externalCFCompany.dateOfLastChangeOfDirector.substring(8, 10)));
        }
    }


    /*******************************************************************************
    *  Summary         : set date of last change of address base on string
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDateOfLastChangeOfAddress() {
        if (this.externalCFCompany.dateOfLastChangeOfAddress != null) {
            this.dateOfLastChangeOfAddress = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfLastChangeOfAddress.substring(0, 4)),
                Integer.valueOf(this.externalCFCompany.dateOfLastChangeOfAddress.substring(5, 7)), Integer.valueOf(this.externalCFCompany.dateOfLastChangeOfAddress.substring(8, 10)));
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limit
    *  Created         : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : credit limit
    ******************************************************************************/
    private Decimal calculateCreditLimit(Decimal billingPeriod, Decimal paymentTerms) {
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        Decimal buffer = (this.calculationsMap.get(paymentDetail).highRisk ? 0.1 : this.buffer);
        Decimal creditLimit = (this.internalCFCompany.totalConsumption * this.fuelPriceIndex + this.internalCFCompany.nonFuelExposure) * ((billingPeriod + paymentTerms) / 30) * (1 + buffer);
        creditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(creditLimit);
        return creditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate security level
    *  Created         : 17/09/2020 by Anton Buzak
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
                securityLevel = calculateSecurityLevelRating1(creditLimit);
            }
            else if (this.externalCFCompany.classRating == '2') {
                securityLevel = calculateSecurityLevelRating2(creditLimit);
            }
            else if (this.externalCFCompany.classRating == '3') {
                securityLevel = calculateSecurityLevelRating3(creditLimit);
            }
            else if (this.externalCFCompany.classRating == '4') {
                securityLevel = calculateSecurityLevelRating4();
            }
            else if (this.externalCFCompany.classRating == '5') {
                securityLevel = calculateSecurityLevelRating5();
            }
        }
        else if (securityLevelForNewBusiness != null) {
            securityLevel = Decimal.valueOf(securityLevelForNewBusiness);
        }

		if (securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
            securityLevel = 100;
        }

        if (securityLevelForNewBusiness == '*' && securityLevel == null && billingPeriod == 30 && paymentTerms == 7 &&
                (this.externalCFCompany.classRating == '2' || this.externalCFCompany.classRating == '3')) {
            securityLevel = 50;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 1
    *  Created         : 08/09/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1(Decimal creditLimit) {
		Decimal securityLevel;
		if (isDirectorOrAddressChanged()) {
            securityLevel = 100;
        }
		else if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 3;
		}
		else {
			securityLevel = null;
		}

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 2
    *  Created         : 08/09/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2(Decimal creditLimit) {
		Decimal securityLevel;
        if (isDirectorOrAddressChanged()) {
            securityLevel = 100;
        }
		else if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 3;
		}
		else {
			securityLevel = null;
		}

        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 3
    *  Created         : 08/09/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3(Decimal creditLimit) {
		Decimal securityLevel;
		if (isDirectorOrAddressChanged()) {
            securityLevel = 100;
        }
		else if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 3;
		}
		else {
			securityLevel = null;
		}

        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 4
    *  Created         : 08/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4() {
		Decimal securityLevel = 100;
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 08/09/2020 by Anton Buzak
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
		Decimal securityLevel = 110;
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level if it's a new business exception
    *  Created         : 15/04/2021 by Ivan Kulinkovich
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

                    this.calculationsMap.put(paymentDetail, calculation);
                    break;
                }
            }

            if (! this.calculationsMap.containsKey(paymentDetail)) {
                CreditFactoryCompany.CreditFactoryCalculation calculation = CreditFactoryGlobalUtils.generateDefaultCalculation();
                this.calculationsMap.put(paymentDetail, calculation);
            }
        }
    }


    /*******************************************************************************
    *  Summary         : check for payment detail
    *  Created         : 15/04/2021 by Ivan Kulinkovich
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
    *  Created         : 15/04/2021 by Ivan Kulinkovich
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
    *  Created         : 15/04/2021 by Ivan Kulinkovich
    *  Parameters      : String months, String operator
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isDateOfFoundationMonthValid(String months, String operator) {
        if (operatorsSet.contains(operator) && ! String.isEmpty(months) && this.dateOfFoundation != null) {
            Decimal value1 = this.dateOfFoundation.monthsBetween(Date.today());
            Decimal value2 = Integer.valueOf(months);
            return CreditFactoryGlobalUtils.compareValues(value1, value2, operator);
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : check for number of cards
    *  Created         : 15/04/2021 by Ivan Kulinkovich
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
    *  Created         : 15/04/2021 by Ivan Kulinkovich
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
    *  Summary         : Check if director or name changed
    *  Created         : 18/02/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isDirectorOrAddressChanged() {
        if (this.dateOfLastChangeOfDirector != null && this.dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryGlobalUtils.areDatesEqual(this.dateOfLastChangeOfDirector, this.dateOfFoundation) ||
                this.dateOfLastChangeOfAddress != null && this.dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryGlobalUtils.areDatesEqual(this.dateOfLastChangeOfAddress, this.dateOfFoundation) ||
                this.externalCFCompany.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                this.dateOfFoundation != null && ! (this.dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            return true;
        }
        else {
            return false;
        }
    }


    /*******************************************************************************
    *  Summary         : calculate max CL
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : Decimal creditLimit, Decimal deposit,
                         Decimal billingPeriod, Decimal paymentTerms
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal creditLimit, Decimal deposit, Decimal billingPeriod, Decimal paymentTerms) {
        Decimal maxCreditLimit;
        if (deposit > 0) {
            maxCreditLimit = creditLimit;
        }
        else {
			if (creditLimit * 2 < 6000) {
				maxCreditLimit = creditLimit * 2;
			}
			else {
				maxCreditLimit = 6000;
			}

			if (maxCreditLimit > recommendedCreditLimit + 500) {
				maxCreditLimit = recommendedCreditLimit + 500;
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
    				     billingPeriod - billing period
    				     paymentTerms - payment terms
    *  Returns         : deposit reason
    ******************************************************************************/
    private String setDepositReason(Decimal securityLevel, Decimal billingPeriod, Decimal paymentTerms) {
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        String depositReason = this.calculationsMap.get(paymentDetail).depositReason;
        if (String.isEmpty(depositReason)) {
            depositReason = 'Low credit rating (rating ' + this.externalCFCompany.classRating + ')';
            if (securityLevel == 3) {
                depositReason = 'Low Recommended CL';
            }
            else if (securityLevel == 50 && billingPeriod == 30 && paymentTerms == 7) {
                depositReason = 'Payment details are 30+7';
            }
            else if (this.externalCFCompany.classRating != '4' && this.externalCFCompany.classRating != '5') {
                if (isDirectorOrAddressChanged()) {
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
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
        if (paymentDetailsSet.contains('30+7') && this.creditLimit30Plus7 < 6000 && this.deposit30Plus7 == 0) {
			if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues7Plus7();
			}
			else if (this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues15Plus7();
			}
			else {
				setDefaultValues30Plus7();
			}
		}
        else if (paymentDetailsSet.contains('15+7') && this.creditLimit15Plus7 < 6000 && this.deposit15Plus7 == 0) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus7();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 6000 && this.deposit7Plus7 == 0) {
            setDefaultValues7Plus7();
        }
		else if (paymentDetailsSet.contains('30+7') && this.creditLimit30Plus7 < 6000) {
			if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues7Plus7();
			}
			else if (this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7') {
				setDefaultValues15Plus7();
			}
			else {
				setDefaultValues30Plus7();
			}
		}
        else if (paymentDetailsSet.contains('15+7') && this.creditLimit15Plus7 < 6000) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus7();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 6000) {
            setDefaultValues7Plus7();
        }
    }


    /*******************************************************************************
    *  Summary         : set default values for 7+7
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues7Plus7() {
        this.billingPeriod = '7';
        this.paymentTerms = '7';
        this.creditLimit = this.creditLimit7Plus7;
        this.securityLevel = this.securityLevel7Plus7;
        this.deposit = this.deposit7Plus7;
        this.depositReason = this.depositReason7plus7;
        this.maxCreditLimit = this.maxCreditLimit7Plus7;
        this.isNewBusinessException = this.calculationsMap.get('7+7').newBusinessException;
        this.riskCategory = (this.calculationsMap.get('7+7').highRisk ? 'High' : this.riskCategory);
    }


    /*******************************************************************************
    *  Summary         : set default values for 15+7
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues15Plus7() {
        this.billingPeriod = '15';
        this.paymentTerms = '7';
        this.creditLimit = this.creditLimit15Plus7;
        this.securityLevel = this.securityLevel15Plus7;
        this.deposit = this.deposit15Plus7;
        this.depositReason = this.depositReason15plus7;
        this.maxCreditLimit = this.maxCreditLimit15Plus7;
        this.isNewBusinessException = this.calculationsMap.get('15+7').newBusinessException;
        this.riskCategory = (this.calculationsMap.get('7+7').highRisk ? 'High' : this.riskCategory);
    }


	/*******************************************************************************
    *  Summary         : set default values for 30+7
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues30Plus7() {
        this.billingPeriod = '30';
        this.paymentTerms = '7';
        this.creditLimit = this.creditLimit30Plus7;
        this.securityLevel = this.securityLevel30Plus7;
        this.deposit = this.deposit30Plus7;
        this.depositReason = this.depositReason30plus7;
        this.maxCreditLimit = this.maxCreditLimit30Plus7;
        this.isNewBusinessException = this.calculationsMap.get('30+7').newBusinessException;
        this.riskCategory = (this.calculationsMap.get('7+7').highRisk ? 'High' : this.riskCategory);
    }


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 11/08/2020 by Anton Buzak
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
    *  Created         : 12/02/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMessages() {
        this.messagesList = new List<CreditFactoryResult.Message>();
        if (this.statusCode == '001') {
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Billing Period can be set to ' + this.billingPeriod));
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Payment Terms can be set to ' + this.paymentTerms));
            if (this.deposit > 0) {
                this.messagesList.add(new CreditFactoryResult.Message('info', '</br>Deposit to pay: ' + this.deposit + ' EUR.</br>' +
                    'Deposit reason: ' + this.depositReason + '</br></br>' +
                    'You can update Desired Payment Terms and Desired Billing Period in the Opportunity and restart Credit Factory to recalculate the deposit amount.'));
            }

            if (this.internalCFCompany.desiredPaymentTerms != null && this.internalCFCompany.desiredPaymentTerms != this.paymentTerms ||
                    this.internalCFCompany.desiredBillingPeriod != null && this.internalCFCompany.desiredBillingPeriod != this.billingPeriod) {
                this.messagesList.add(new CreditFactoryResult.Message('warning', 'If you want to close your Opportunity with ' +
                    'desired billing period and desired payment terms, please refer to Credit.'));
                if (this.internalCFCompany.desiredPaymentTerms != null && this.internalCFCompany.desiredPaymentTerms != this.paymentTerms) {
                    this.messagesList.add(new CreditFactoryResult.Message('warning', 'Desired payment terms (' +
                        this.internalCFCompany.desiredPaymentTerms + ') cannot be provided.'));
                }

                if (this.internalCFCompany.desiredBillingPeriod != null && this.internalCFCompany.desiredBillingPeriod != this.billingPeriod) {
                    this.messagesList.add(new CreditFactoryResult.Message('warning', 'Desired billing period (' +
                        this.internalCFCompany.desiredBillingPeriod + ') cannot be provided.'));
                }
            }
        }
        else if (this.statusCode == '004') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Requested limit too high. Please refer to credit.'));
        }
    }


    /*******************************************************************************
    *  Summary         : set available button (pending deposit, closed won etc)
    *  Created         : 25/05/2020
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
                if (this.internalCFCompany.paymentMethod == 'Lastschrift' && (this.internalCFCompany.directDebitFormAvailable == false || String.isEmpty(this.internalCFCompany.iban))) {
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
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList(Set<String> paymentDetailsSet) {
		this.resultsList = new List<CreditFactoryResult>();
        String riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);
		if (paymentDetailsSet.contains('30+7') && this.creditLimit30Plus7 < 6000) {
			CreditFactoryResult result30Plus7 = new CreditFactoryResult();
			result30Plus7.verdict = 'Yes';
			result30Plus7.statusCode = '001';
			result30Plus7.billingPeriod = '30';
			result30Plus7.paymentTerms = '7';
			result30Plus7.creditLimit = this.creditLimit30Plus7;
			result30Plus7.securityLevel = this.securityLevel30Plus7;
			result30Plus7.deposit = this.deposit30Plus7;
            result30Plus7.depositReason = this.depositReason30plus7;
			result30Plus7.maxCreditLimit = this.maxCreditLimit30Plus7;
			result30Plus7.riskCategory = (this.calculationsMap.get('30+7').highRisk ? 'High' : riskCategory);
            result30Plus7.classRating = (this.calculationsMap.get('30+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result30Plus7.paymentMethodsSet = new List<String> {'Direct Debit'};
			result30Plus7.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
			if (this.billingPeriod == result30Plus7.billingPeriod && this.paymentTerms == result30Plus7.paymentTerms) {
				result30Plus7.isDefault = true;
			}

			resultsList.add(result30Plus7);
		}

		if (paymentDetailsSet.contains('15+7') && this.creditLimit15Plus7 < 6000) {
			CreditFactoryResult result15Plus7 = new CreditFactoryResult();
			result15Plus7.verdict = 'Yes';
			result15Plus7.statusCode = '001';
			result15Plus7.billingPeriod = '15';
			result15Plus7.paymentTerms = '7';
			result15Plus7.creditLimit = this.creditLimit15Plus7;
			result15Plus7.securityLevel = this.securityLevel15Plus7;
			result15Plus7.deposit = this.deposit15Plus7;
            result15Plus7.depositReason = this.depositReason15plus7;
			result15Plus7.maxCreditLimit = this.maxCreditLimit15Plus7;
			result15Plus7.riskCategory = (this.calculationsMap.get('15+7').highRisk ? 'High' : riskCategory);
            result15Plus7.classRating = (this.calculationsMap.get('15+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result15Plus7.paymentMethodsSet = new List<String> {'Direct Debit'};
			result15Plus7.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
			if (this.billingPeriod == result15Plus7.billingPeriod && this.paymentTerms == result15Plus7.paymentTerms) {
				result15Plus7.isDefault = true;
			}

			resultsList.add(result15Plus7);
		}

		if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 6000) {
			CreditFactoryResult result7Plus7 = new CreditFactoryResult();
			result7Plus7.verdict = 'Yes';
			result7Plus7.statusCode = '001';
			result7Plus7.billingPeriod = '7';
			result7Plus7.paymentTerms = '7';
			result7Plus7.creditLimit = this.creditLimit7Plus7;
			result7Plus7.securityLevel = this.securityLevel7Plus7;
			result7Plus7.deposit = this.deposit7Plus7;
            result7Plus7.depositReason = this.depositReason7plus7;
			result7Plus7.maxCreditLimit = this.maxCreditLimit7Plus7;
			result7Plus7.riskCategory = (this.calculationsMap.get('7+7').highRisk ? 'High' : riskCategory);
            result7Plus7.classRating = (this.calculationsMap.get('7+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result7Plus7.paymentMethodsSet = new List<String> {'Direct Debit'};
			result7Plus7.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
			if (this.billingPeriod == result7Plus7.billingPeriod && this.paymentTerms == result7Plus7.paymentTerms) {
				result7Plus7.isDefault = true;
			}

			resultsList.add(result7Plus7);
		}
	}


    /*******************************************************************************
    *  Summary         : create pdf reports asynchronously
    *  Created         : 22/09/2020 by Anton Buzak
    *  Parameters      : opportunityId - id of opportunity
    *  Returns         : --
    ******************************************************************************/
    public override void createPdfReports(String opportunityId) {
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' +
                Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() +
                Datetime.now().addSeconds(5).millisecond();
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(this.externalCFCompany.identificationNumber, null, opportunityId, null, this.externalCFCompany.country);
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