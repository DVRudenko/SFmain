public class CreditFactoryImplFR extends CreditFactoryImpl {

    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
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
        System.debug('1 == ' + searchEntity.companies);
		List<CreditFactoryCompany> creditCompaniesList = CreditFactoryWebCreditsafe.returnSearchCompany(searchEntity, this.internalCFCompany.countryCode);
        System.debug('2 == ' + creditCompaniesList);
		return creditCompaniesList;
    }


	/*******************************************************************************
    *  Summary         : Returns Credit Company based on search by name and address
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
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

            setFuelPriceIndex();
            setBuffer();
            setRiskCategory();
			setRecommendedCreditLimit();
			setDateOfFoundation();
			setDateOfLastChangeOfDirector();
			setDateOfLastChangeOfAddress();

            this.validationItemsMap = validationItemsMap;

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '7+7') {
                    this.creditLimit7Plus7 = calculateCreditLimit(7, 7);
                    this.securityLevel7Plus7 = calculateSecurityLevel(this.creditLimit7Plus7, 7, 7);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel7Plus7, this.creditLimit7Plus7, 7, 7, this.recommendedCreditLimit);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit7Plus7);
                    this.maxCreditLimit7Plus7 = calculateMaxCreditLimit(this.creditLimit7Plus7, this.deposit7Plus7);
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
                    this.maxCreditLimit15Plus7 = calculateMaxCreditLimit(this.creditLimit15Plus7, this.deposit15Plus7);
                    this.maxCreditLimit15Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit15Plus7);
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
                    this.maxCreditLimit30Plus7 = calculateMaxCreditLimit(this.creditLimit30Plus7, this.deposit30Plus7);
                    if (this.creditLimit30Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit30Plus7 * 1.5 <= this.maxCreditLimit30Plus7 && this.deposit30Plus7 == 0) {
                        this.creditLimit30Plus7 = this.creditLimit30Plus7 * 1.5;
                        this.creditLimit30Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit30Plus7);
                    }

                    if (this.securityLevel30Plus7 != null) {
                        this.depositReason30plus7 = setDepositReason(this.securityLevel30Plus7, 30, 7);
                    }
                }
            }

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
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance(this.internalCFCompany.country);
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    *  Summary         : Set Risk Category
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    protected override void setRiskCategory() {
		if (this.externalCFCompany.classRating == '1') {
			this.riskCategory = 'Low';
		} else if (this.externalCFCompany.classRating == '2') {
			this.riskCategory = 'Medium';
		} else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4') {
			this.riskCategory = 'High';
		} else if (this.externalCFCompany.classRating == '5') {
			this.riskCategory = 'Very';
		}
    }


	/*******************************************************************************
    *  Summary         : set recommended CL
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
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
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : credit limit
    ******************************************************************************/
    private Decimal calculateCreditLimit(Decimal billingPeriod, Decimal paymentTerms) {
        Decimal creditLimit = (this.internalCFCompany.totalConsumption * this.fuelPriceIndex + this.internalCFCompany.nonFuelExposure) * ((billingPeriod + paymentTerms) / 30) * (1 + this.buffer);
        creditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(creditLimit);
        return creditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate security level
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
						 billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
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

		if (securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
            securityLevel = 100;
        }

        if (securityLevel == null && (billingPeriod == 15 && paymentTerms == 7 || billingPeriod == 30 && paymentTerms == 7)) {
			securityLevel = 50;
		}

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 1
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1(Decimal creditLimit) {
		Decimal securityLevel;
		if (this.dateOfFoundation == null || this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            securityLevel = 100;
        }
        else if (isDirectorOrAddressChanged()) {
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2(Decimal creditLimit) {
		Decimal securityLevel;
        if (this.dateOfFoundation == null || this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            securityLevel = 100;
        }
        else if (isDirectorOrAddressChanged()) {
            securityLevel = 100;
        }
		else if (soleTradersSet.contains(this.externalCFCompany.legalForm) && Integer.valueOf(this.dateOfFoundation.year()) > Date.today().year() - 2) {
			securityLevel = 50;
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3(Decimal creditLimit) {
		Decimal securityLevel;
		if (this.dateOfFoundation == null || this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            securityLevel = 100;
        }
        else if (isDirectorOrAddressChanged()) {
            securityLevel = 100;
        }
		else if (soleTradersSet.contains(this.externalCFCompany.legalForm)) {
			securityLevel = 70;
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4() {
		Decimal securityLevel = 100;
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
		Decimal securityLevel = 110;
        return securityLevel;
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal creditLimit, Decimal deposit) {
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
        String depositReason = 'Low credit rating (rating ' + this.externalCFCompany.classRating + ')';
        if (securityLevel == 3) {
            depositReason = 'Low Recommended CL';
        }
        else if (securityLevel == 50 && billingPeriod == 15 && paymentTerms == 7) {
            depositReason = 'Payment details are 15+7';
        }
        else if (securityLevel == 50 && billingPeriod == 30 && paymentTerms == 7) {
            depositReason = 'Payment details are 30+7';
        }
        else if ((securityLevel == 50 || securityLevel == 70) &&
                soleTradersSet.contains(this.externalCFCompany.legalForm)) {
            depositReason = 'Sole trader';
        }
        else if (this.externalCFCompany.classRating != '4' && this.externalCFCompany.classRating != '5') {
            if (this.dateOfFoundation == null || this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
                depositReason = 'New business';
            }
            else if (isDirectorOrAddressChanged()) {
                depositReason = 'Address/Director/Name change 6M';
            }
            else if (this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
                depositReason = 'Invalid contact';
            }
        }

        return depositReason;
    }


    /*******************************************************************************
    *  Summary         : set default billing period and payment terms
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
        if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 6000 && this.deposit7Plus7 == 0) {
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    }


    /*******************************************************************************
    *  Summary         : set default values for 15+7
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    }


	/*******************************************************************************
    *  Summary         : set default values for 30+7
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    }


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList(Set<String> paymentDetailsSet) {
		this.resultsList = new List<CreditFactoryResult>();
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
			result30Plus7.riskCategory = this.riskCategory;
            result30Plus7.classRating = this.externalCFCompany.classRating;
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
			result15Plus7.riskCategory = this.riskCategory;
            result15Plus7.classRating = this.externalCFCompany.classRating;
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
			result7Plus7.riskCategory = this.riskCategory;
            result7Plus7.classRating = this.externalCFCompany.classRating;
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
    *  Created         : 02/11/2020 by Ivan Kulinkovich
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


	public static Set<String> soleTradersSet = new Set<String>{
        'Personal business- liberal profession',
        'Personal business- Natural person',
        'INDIVIDUAL ENTREPRISE',
        'Personal business- craftsman',
        'Personal business- commercial craftsman',
        'Personal business- commercial',
        'Artisans',
        'Single company',
        'Sole Proprietorship',
        'Freelance',
        'Auto entrepreneur',
        'Personal business- farmer',
        'Sole Proprietor'
    };
}