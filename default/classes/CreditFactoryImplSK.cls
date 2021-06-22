public virtual class CreditFactoryImplSK extends CreditFactoryImpl {
	protected Decimal creditLimit15Plus10;
    protected Decimal securityLevel15Plus10;
    protected Decimal deposit15Plus10;
    protected Decimal maxCreditLimit15Plus10;
    protected List<String> paymentMethodsList;


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 05/10/2019 by Anton Buzak
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : list of searched companies
    ******************************************************************************/
    public override List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
    	try {
            Map<String, String> searchParametersMap = CreditFactoryGlobalUtils.generateSearchParametersMap(searchParametersSet, this.internalCFCompany);
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Cribis');
            List<CreditFactoryCompany> externalCompaniesList = new List<CreditFactoryCompany>();
			if (searchParametersMap.containsKey('taxId')) {
                externalCompaniesList = doSearch(creditSystem, searchParametersMap);
				searchParametersMap.remove('taxId');
			}

			if (! searchParametersMap.isEmpty() && externalCompaniesList.isEmpty()) {
				externalCompaniesList = doSearch(creditSystem, searchParametersMap);
			}

            return externalCompaniesList;
    	} catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.CRIBIS_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
    	}
    }


    /*******************************************************************************
    *  Summary         : Returns Credit Company based on search by Tax Id.
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : creditSystem - Creditsafe settings,
                         searchParametersMap - search parameters
    *  Returns         : companies list
    ******************************************************************************/
    private List<CreditFactoryCompany> doSearch(CreditSystem__c creditSystem, Map<String, String> searchParametersMap) {
		HttpRequest request = CreditFactoryWebCribis.generateSearchRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, searchParametersMap, this.internalCFCompany.countryCode);
        Http http = new Http();
        HttpResponse response = http.send(request);
        this.apiErrorMessage = CreditFactoryGlobalUtils.checkCribisAPIErrors(response);
        if (! String.isEmpty(this.apiErrorMessage)) {
            throw new CreditFactoryException(this.apiErrorMessage);
        }

        Dom.Document domDoc = new Dom.Document();
        domDoc.load(response.getBody());
        Dom.XmlNode xmlDom = domDoc.getRootElement();

        List<CreditFactoryCompany> externalCompaniesList = CreditFactoryWebCribis.returnSearchedCompanies(xmlDom);
        return externalCompaniesList;
    }


	/*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : credit reports
    ******************************************************************************/
    public override CreditFactoryReportsItem requestCompanyReports(String companyId) {
		String serviceName = 'Cribis';
		try {
			CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
			CreditSystem__c creditSystem = CreditSystem__c.getInstance(serviceName);
			HttpResponse cribisReportResponse = requestCribisReport(creditSystem, companyId);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkCribisAPIErrors(cribisReportResponse);
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}

			Dom.XmlNode xmlNodeCribisReport = getXmlNode(cribisReportResponse.getBody());
			String identificationType = CreditFactoryWebCribis.returnStatus(xmlNodeCribisReport);
            if (identificationType == 'No data') {
                reportsItem.isReportAvailable = false;
                reportsItem.isOrderAvailable = false;
                reportsItem.errorMessage = 'Credit report is not available. Please refer to Credit.';
                return reportsItem;
            }

			this.externalCFCompany = CreditFactoryWebCribis.returnReportCompany(xmlNodeCribisReport, companyId, this.internalCFCompany.country);

			HttpResponse cribisExecuteResponse = requestCribisExecute(creditSystem, companyId);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkCribisAPIErrors(cribisExecuteResponse);
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}

			Dom.XmlNode xmlNodeCribisExecute = getXmlNode(cribisExecuteResponse.getBody());
			this.externalCFCompany = CreditFactoryWebCribis.returnExecuteData(xmlNodeCribisExecute, this.externalCFCompany);

			LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
			if (lexisNexisSettings.Active__c == true) {
				serviceName = 'LexisNexis';
				HttpResponse lexisNexisResponse = requestLexisNexisReport(lexisNexisSettings);
				this.apiErrorMessage = CreditFactoryGlobalUtils.checkLexisNexisAPIErrors(lexisNexisResponse);
				if (!String.isEmpty(this.apiErrorMessage)) {
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
			if (!String.isEmpty(apiErrorMessage)) {
				throw new CreditFactoryException(apiErrorMessage + '. ' + companyIdText);
			} else if (e.getMessage().contains('Read timed out')) {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.returnServiceError(serviceName) + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.' + '. ' + companyIdText);
			} else {
				throw new CreditFactoryException('Set company error. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + '. ' + companyIdText);
			}
		}
	}


	/*******************************************************************************
	*  Summary         : Send request to Credit System to get company
	*  CreatedDate     : 06/10/2020 by Anton Buzak
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : Cribis report request
	******************************************************************************/
    private HttpResponse requestCribisReport(CreditSystem__c creditSystem, String companyId) {
		HttpRequest request = CreditFactoryWebCribis.generateReportRequest(
            creditSystem.Endpoint__c, creditSystem.UserName__c,
            creditSystem.Password__c, companyId, this.internalCFCompany.countryCode);
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }


	/*******************************************************************************
	*  Summary         : Send request to Credit System to get company
	*  CreatedDate     : 07/10/2020 by Anton Buzak
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : Cribis report request
	******************************************************************************/
    private HttpResponse requestCribisExecute(CreditSystem__c creditSystem, String companyId) {
		CreditFactoryCompany.CreditFactoryContact primaryContact;
        for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.isPrimary == true) {
                primaryContact = contact;
                break;
            }
        }

		String dateOfBirth = String.valueOf(primaryContact.dateOfBirth).substring(0, 10);
		HttpRequest request = CreditFactoryWebCribis.generateExecuteRequest(
            creditSystem.Endpoint__c, creditSystem.UserName__c,
            creditSystem.Password__c, primaryContact.firstName,
			primaryContact.lastName, dateOfBirth,
			this.internalCFCompany.countryCode);
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }


    /*******************************************************************************
    *  Summary         : Return trade register number fields to update in Account
    *  CreatedDate     : 04/12/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public override Map<String, Object> returnTradeRegisterNumberFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('HR_Abteilung_HRA_HRB_und_HR_Nummer__c', this.externalCFCompany.tradeRegisterNumber);
        accountFieldsMap.put('Ort_der_Registrierung_Handelsregisterort__c', this.externalCFCompany.countyCourt);
		fieldsMap.put('Account', accountFieldsMap);

        return fieldsMap;
    }


	/*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 08/10/2020 by Anton Buzak
    *  Parameters      : paymentDetailsSet - possible payment details,
                         validationItemsMap - validations results map
    *  Returns         : Credit Factory result structure
    ******************************************************************************/
    public virtual override CreditFactoryResult doCreditScoring(Set<String> paymentDetailsSet, Map<String, CreditFactoryValidationItem> validationItemsMap) {
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

            setFuelPriceIndex();
            setBuffer();
            setRiskCategory();
			setRecommendedCreditLimit();
			setDateOfFoundation();

            this.validationItemsMap = validationItemsMap;

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '7+7') {
                    this.creditLimit7Plus7 = calculateCreditLimit(7, 7);
                    this.securityLevel7Plus7 = calculateSecurityLevel(this.creditLimit7Plus7, 7, 7);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel7Plus7, this.creditLimit7Plus7, 7, 7, this.recommendedCreditLimit);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit7Plus7);
                    this.maxCreditLimit7Plus7 = calculateMaxCreditLimit(this.creditLimit7Plus7, this.deposit7Plus7);
                    this.maxCreditLimit7Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit7Plus7);
                    if (this.securityLevel7Plus7 != null) {
                        this.depositReason7plus7 = setDepositReason(this.securityLevel7Plus7);
                    }
                } else if (paymentDetail == '15+10') {
                    this.creditLimit15Plus10 = calculateCreditLimit(15, 10);
                    this.securityLevel15Plus10 = calculateSecurityLevel(this.creditLimit15Plus10, 15, 10);
                    this.deposit15Plus10 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus10, this.creditLimit15Plus10, 15, 10, this.recommendedCreditLimit);
                    this.deposit15Plus10 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus10);
                    this.maxCreditLimit15Plus10 = calculateMaxCreditLimit(this.creditLimit15Plus10, this.deposit15Plus10);
                    this.maxCreditLimit15Plus10 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit15Plus10);
                    if (this.securityLevel15Plus10 != null) {
                        this.depositReason15plus10 = setDepositReason(this.securityLevel15Plus10);
                    }
                }
            }

            setDefaultPaymentDetails(paymentDetailsSet);
            setDecision();
            setMessages();
            setAvailableButtons();
            setPaymentMethodsList();
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
            cfResult.paymentMethodsSet = this.paymentMethodsList;
            cfResult.invoicesSet = new List<String>{
                    'e-Invoicing'
            };

            cfResult.resultsList = this.resultsList;

            return cfResult;
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Scoring failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
		}
    }


	/*******************************************************************************
    *  Summary         : Set fuel price index
    *  CreatedDate     : 08/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Slovakia');
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


	/*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 08/10/2020 by Anton Buzak
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
		else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == null) {
			this.buffer = 0.1;
		}
		else if (this.externalCFCompany.classRating == '5') {
			this.buffer = 0;
		}
    }


    /*******************************************************************************
    *  Summary         : Set Risk Category
    *  Created         : 08/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    protected override void setRiskCategory() {
		if (this.externalCFCompany.classRating == '1') {
			this.riskCategory = 'Low';
		}
		else if (this.externalCFCompany.classRating == '2') {
			this.riskCategory = 'Medium';
		}
		else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == null) {
			this.riskCategory = 'High';
		}
		else if (this.externalCFCompany.classRating == '5') {
			this.riskCategory = 'Very';
		}
    }


	/*******************************************************************************
    *  Summary         : Calculate credit limit
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : credit limit
    ******************************************************************************/
    private Decimal calculateCreditLimit(Decimal billingPeriod, Decimal paymentTerms) {
        Decimal creditLimit = this.internalCFCompany.totalConsumption * this.fuelPriceIndex * ((billingPeriod + paymentTerms) / 30) * (1 + this.buffer);
        creditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(creditLimit);
        return creditLimit;
    }


	/*******************************************************************************
    *  Summary         : set recommended CL
    *  Created         : 12/08/2020 by Anton Buzak
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
    *  Created         : 12/08/2020 by Anton Buzak
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
    *  Summary         : calculate security level
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
						 billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
        if (this.externalCFCompany.classRating == '1') {
	        securityLevel = calculateSecurityLevelRating1(billingPeriod, paymentTerms);
	    }
        else if (this.externalCFCompany.classRating == '2') {
            securityLevel = calculateSecurityLevelRating2(billingPeriod, paymentTerms);
        }
		else if (this.externalCFCompany.classRating == '3') {
            securityLevel = calculateSecurityLevelRating3(creditLimit, billingPeriod, paymentTerms);
        }
		else if (this.externalCFCompany.classRating == '4') {
            securityLevel = calculateSecurityLevelRating4(billingPeriod, paymentTerms);
        }
		else if (this.externalCFCompany.classRating == '5') {
            securityLevel = calculateSecurityLevelRating5();
        }
		else if (this.externalCFCompany.classRating == null) {
            securityLevel = calculateSecurityLevelNoRating(billingPeriod, paymentTerms);
        }

		if (securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
            securityLevel = 100;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 1
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
						 billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1(Decimal billingPeriod, Decimal paymentTerms) {
		Decimal securityLevel;
		if (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0 &&
				Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2 && this.internalCFCompany.totalConsumption <= 1000) {
			securityLevel = 110;
		}
		else if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
		}
		else if (this.validationItemsMap.containsKey('NegativeInformation') && this.validationItemsMap.get('NegativeInformation').passed == false) {
			securityLevel = 100;
		}
        else if (this.externalCFCompany.financialEvaluation == false && this.internalCFCompany.totalConsumption > 1500) {
            securityLevel = 50;
        }
		else {
			securityLevel = null;
		}

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 2
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
						 billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2(Decimal billingPeriod, Decimal paymentTerms) {
		Decimal securityLevel;
		if (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0 &&
				Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2 && this.internalCFCompany.totalConsumption <= 1000) {
			securityLevel = 110;
		}
		else if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
		}
		else if (this.validationItemsMap.containsKey('NegativeInformation') && this.validationItemsMap.get('NegativeInformation').passed == false) {
			securityLevel = 100;
		}
        else if (this.externalCFCompany.financialEvaluation == false && this.internalCFCompany.totalConsumption > 1500) {
            securityLevel = 50;
        }
		else {
			securityLevel = null;
		}

        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 3
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
						 billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
		Decimal securityLevel;
		if (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0 &&
				Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2 && this.internalCFCompany.totalConsumption <= 1000) {
			securityLevel = 110;
		}
		else if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
		}
		else if (this.validationItemsMap.containsKey('NegativeInformation') && this.validationItemsMap.get('NegativeInformation').passed == false) {
			securityLevel = 100;
		}
        else if (this.externalCFCompany.financialEvaluation == false && this.internalCFCompany.totalConsumption > 1500) {
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
    *  Summary         : calculate security level for rating 4
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4(Decimal billingPeriod, Decimal paymentTerms) {
		Decimal securityLevel;
		if (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0 &&
				Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2 && this.internalCFCompany.totalConsumption <= 1000) {
			securityLevel = 110;
		}
		else if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
		}
		else if (this.validationItemsMap.containsKey('NegativeInformation') && this.validationItemsMap.get('NegativeInformation').passed == false) {
			securityLevel = 100;
		}
		else {
			securityLevel = 70;
		}

        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
		Decimal securityLevel = 110;
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for no rating
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for No Rating
    ******************************************************************************/
    private Decimal calculateSecurityLevelNoRating(Decimal billingPeriod, Decimal paymentTerms) {
		Decimal securityLevel;
		if (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0 &&
				Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2 && this.internalCFCompany.totalConsumption <= 1000) {
			securityLevel = 110;
		}
		else if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
		}
		else {
			securityLevel = 100;
		}

        return securityLevel;
    }
    
    
    /*******************************************************************************
    *  Summary         : Check if it's a new business exception
    *  Created         : 16/01/2021 by Ivan Kulinkovich
    *  Parameters      : Decimal billingPeriod,
    					 Decimal paymentTerms
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isNewBusinessException(Decimal billingPeriod, Decimal paymentTerms) {
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18 &&
                this.internalCFCompany.totalConsumption <= 300 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 1 &&
                billingPeriod == 7 && paymentTerms == 7) {
            this.isNewBusinessException = true;
			return true;
        }
        
        return false;
    }


	/*******************************************************************************
    *  Summary         : calculate max CL
    *  Created         : 11/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal creditLimit, Decimal deposit) {
        Decimal maxCreditLimit;
        if (deposit > 0) {
            maxCreditLimit = creditLimit;
        }
        else {
            if (this.externalCFCompany.classRating == '1') {
				maxCreditLimit = calculateMaxCreditLimitRating1(creditLimit);
			}
			else if (this.externalCFCompany.classRating == '2') {
				maxCreditLimit = calculateMaxCreditLimitRating2(creditLimit);
			}
			else if (this.externalCFCompany.classRating == '3') {
				maxCreditLimit = calculateMaxCreditLimitRating3(creditLimit);
			}
			else if (this.externalCFCompany.classRating == '4') {
				maxCreditLimit = calculateMaxCreditLimitRating4(creditLimit);
			}
            else if (this.externalCFCompany.classRating == null) {
				maxCreditLimit = calculateMaxCreditLimitNoRating(creditLimit);
			}
		}

        maxCreditLimit = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(maxCreditLimit);

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate max CL for rating 1
    *  Created         : 02/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : max credit limit for rating 1
    ******************************************************************************/
    private Decimal calculateMaxCreditLimitRating1(Decimal creditLimit) {
        Decimal maxCreditLimit;
		if (creditLimit * 2 < 8000) {
            maxCreditLimit = creditLimit * 2;
        }
        else {
            maxCreditLimit = 8000;
        }

        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            Decimal creditLimit300 = (this.fuelPriceIndex * 300 + this.internalCFCompany.nonFuelExposure) * (7 + 7) / 30 * (1 + this.buffer);
            if (maxCreditLimit > creditLimit300) {
                maxCreditLimit = creditLimit300;
            }
        }

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate max CL for rating 2
    *  Created         : 02/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : max credit limit for rating 1
    ******************************************************************************/
    private Decimal calculateMaxCreditLimitRating2(Decimal creditLimit) {
        Decimal maxCreditLimit;
		if (creditLimit * 2 < 8000) {
            maxCreditLimit = creditLimit * 2;
        }
        else {
            maxCreditLimit = 8000;
        }

        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            Decimal creditLimit300 = (this.fuelPriceIndex * 300 + this.internalCFCompany.nonFuelExposure) * (7 + 7) / 30 * (1 + this.buffer);
            if (maxCreditLimit > creditLimit300) {
                maxCreditLimit = creditLimit300;
            }
        }

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate max CL for rating 3
    *  Created         : 02/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : max credit limit for rating 1
    ******************************************************************************/
    private Decimal calculateMaxCreditLimitRating3(Decimal creditLimit) {
        Decimal maxCreditLimit;
		if (creditLimit * 2 < 8000) {
            maxCreditLimit = creditLimit * 2;
        }
        else {
            maxCreditLimit = 8000;
        }

        if (maxCreditLimit > recommendedCreditLimit + 500) {
            maxCreditLimit = recommendedCreditLimit + 500;
        }

        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            Decimal creditLimit300 = (this.fuelPriceIndex * 300 + this.internalCFCompany.nonFuelExposure) * (7 + 7) / 30 * (1 + this.buffer);
            if (maxCreditLimit > creditLimit300) {
                maxCreditLimit = creditLimit300;
            }
        }

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate max CL for rating 4
    *  Created         : 02/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : max credit limit for rating 1
    ******************************************************************************/
    private Decimal calculateMaxCreditLimitRating4(Decimal creditLimit) {
        Decimal maxCreditLimit;
		if (creditLimit * 2 < 8000) {
            maxCreditLimit = creditLimit * 2;
        }
        else {
            maxCreditLimit = 8000;
        }

        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            Decimal creditLimit300 = (this.fuelPriceIndex * 300 + this.internalCFCompany.nonFuelExposure) * (7 + 7) / 30 * (1 + this.buffer);
            if (maxCreditLimit > creditLimit300) {
                maxCreditLimit = creditLimit300;
            }
        }

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate max CL for No rating
    *  Created         : 02/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : max credit limit for rating 1
    ******************************************************************************/
    private Decimal calculateMaxCreditLimitNoRating(Decimal creditLimit) {
        Decimal maxCreditLimit;
		if (creditLimit * 2 < 8000) {
            maxCreditLimit = creditLimit * 2;
        }
        else {
            maxCreditLimit = 8000;
        }

        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            Decimal creditLimit300 = (this.fuelPriceIndex * 300 + this.internalCFCompany.nonFuelExposure) * (7 + 7) / 30 * (1 + this.buffer);
            if (maxCreditLimit > creditLimit300) {
                maxCreditLimit = creditLimit300;
            }
        }

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : set deposit reason
    *  Created         : 18/02/2021 by Ivan Kulinkovich
    *  Parameters      : securityLevel - security level
    *  Returns         : deposit reason
    ******************************************************************************/
    private String setDepositReason(Decimal securityLevel) {
        String depositReason;
        if (this.externalCFCompany.classRating != null) {
            depositReason = 'Low credit rating (rating ' + this.externalCFCompany.classRating + ')';
        }
        else {
            depositReason = 'Low credit rating (no rating)';
        }

        if (securityLevel == 3) {
            depositReason = 'Low Recommended CL';
        }
        else if (securityLevel == 110 && this.externalCFCompany.classRating != '5') {
            depositReason = 'Executions';
        }
        else if (securityLevel != 70 && this.externalCFCompany.classRating != '5' && this.externalCFCompany.classRating != null) {
            if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
                depositReason = 'New business';
            }
            else if (this.validationItemsMap.containsKey('NegativeInformation') && this.validationItemsMap.get('NegativeInformation').passed == false) {
                depositReason = 'Cribis negative information';
            }
            else if (this.externalCFCompany.financialEvaluation == false && this.internalCFCompany.totalConsumption > 1500) {
                depositReason = 'Missing financials';
            }
            else if (this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
                depositReason = 'Invalid contact';
            }
        }

        return depositReason;
    }


	/*******************************************************************************
    *  Summary         : set default billing period and payment terms
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
		if (paymentDetailsSet.contains('15+10') && this.creditLimit15Plus10 < 8000 && this.deposit15Plus10 == 0) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus10();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 8000 && this.deposit7Plus7 == 0) {
            setDefaultValues7Plus7();
        }
        else if (paymentDetailsSet.contains('15+10') && this.creditLimit15Plus10 < 8000) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus10();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 8000) {
            setDefaultValues7Plus7();
        }
    }


	/*******************************************************************************
    *  Summary         : set default values for 7+7
    *  Created         : 08/10/2020 by Anton Buzak
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
    *  Summary         : set default values for 15+10
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues15Plus10() {
        this.billingPeriod = '15';
        this.paymentTerms = '10';
        this.creditLimit = this.creditLimit15Plus10;
        this.securityLevel = this.securityLevel15Plus10;
        this.deposit = this.deposit15Plus10;
        this.depositReason = this.depositReason15plus10;
        this.maxCreditLimit = this.maxCreditLimit15Plus10;
    }


	/*******************************************************************************
    *  Summary         : set decision
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDecision() {
		if (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0 &&
				! (Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2 && this.internalCFCompany.totalConsumption <= 1000)) {
			this.verdict = 'No';
			this.statusCode = '014';
		}
		else if (this.billingPeriod != null && this.paymentTerms != null) {
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
    *  Created         : 08/10/2020 by Anton Buzak
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
		else if (this.statusCode == '014') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Executions and potentially high exposure, rejected'));
        }
    }


	/*******************************************************************************
    *  Summary         : set available button (pending deposit, closed won etc)
    *  Created         : 08/10/2020 by Anton Buzak
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
				Boolean isClosedWonAvailable = false;
				if (this.internalCFCompany.attachments != null) {
					for (CreditFactoryCompany.CreditFactoryAttachment attachment : this.internalCFCompany.attachments) {
						if (attachment.name.containsIgnoreCase('Card Order Form SK.pdf')) {
							isClosedWonAvailable = true;
							break;
						}
					}
				}

				if (this.internalCFCompany.files != null) {
					for (CreditFactoryCompany.CreditFactoryFile file : this.internalCFCompany.files) {
						if (file.title.containsIgnoreCase('Card Order Form SK.pdf')) {
							isClosedWonAvailable = true;
							break;
						}
				   }
				}

				if (isClosedWonAvailable) {
					this.availableButtonsList.add('Closed Won');
				}
				else {
					this.availableButtonsList.add('Contract Check');
				}
            }
        }
    }


	/*******************************************************************************
    *  Summary         : set results list
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList(Set<String> paymentDetailsSet) {
		this.resultsList = new List<CreditFactoryResult>();
		if (paymentDetailsSet.contains('15+10') && this.creditLimit15Plus10 < 8000) {
			CreditFactoryResult result15Plus10 = new CreditFactoryResult();
			result15Plus10.verdict = 'Yes';
			result15Plus10.statusCode = '001';
			result15Plus10.billingPeriod = '15';
			result15Plus10.paymentTerms = '10';
			result15Plus10.creditLimit = this.creditLimit15Plus10;
			result15Plus10.securityLevel = this.securityLevel15Plus10;
			result15Plus10.deposit = this.deposit15Plus10;
            result15Plus10.depositReason = this.depositReason15plus10;
			result15Plus10.maxCreditLimit = this.maxCreditLimit15Plus10;
			result15Plus10.riskCategory = this.riskCategory;
            result15Plus10.classRating = this.externalCFCompany.classRating;
			result15Plus10.paymentMethodsSet = this.paymentMethodsList;
			result15Plus10.invoicesSet = new List<String>{
					'e-Invoicing', 'Paper Invoice'
			};
			if (this.billingPeriod == result15Plus10.billingPeriod && this.paymentTerms == result15Plus10.paymentTerms) {
				result15Plus10.isDefault = true;
			}

			resultsList.add(result15Plus10);
		}

		if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 8000) {
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
            result7Plus7.classRating = (this.isNewBusinessException == true ? '0-EX' : this.externalCFCompany.classRating);
			result7Plus7.paymentMethodsSet = this.paymentMethodsList;
			result7Plus7.invoicesSet = new List<String>{
					'e-Invoicing', 'Paper Invoice'
			};
			if (this.billingPeriod == result7Plus7.billingPeriod && this.paymentTerms == result7Plus7.paymentTerms) {
				result7Plus7.isDefault = true;
			}

			resultsList.add(result7Plus7);
		}
	}


    /*******************************************************************************
    *  Summary         : set available payment methods
    *  Created         : 08/10/2020 by Anton Buzak
    *  Parameters      : --
    *  Returns         : -
    ******************************************************************************/
    private void setPaymentMethodsList() {
        this.paymentMethodsList = new List<String>{
                'Direct Debit'
        };

        if (this.externalCFCompany.classRating != '4' && this.externalCFCompany.classRating != '5' &&
                ! (dateOfFoundation != null && dateOfFoundation.monthsBetween(Date.today()) <= 18 &&
                this.internalCFCompany.totalConsumption <= 300 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 1) &&
                ! (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0)) {
            this.paymentMethodsList.add('Bank Transfer');
    	}
	}


	/*******************************************************************************
    *  Summary         : create pdf reports asynchronously
    *  Created         : 15/01/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public override void createPdfReports(String opportunityId) {
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' +
                Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() +
                Datetime.now().addSeconds(5).millisecond();
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(this.externalCFCompany.documentTicket, null, opportunityId, null, this.externalCFCompany.country);
        System.schedule(scheduleName, schedule, pdfSchedule);
    }
}