public class CreditFactoryImplAT extends CreditFactoryImpl {
	private transient Blob attachmentBody;

    
    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : list of searched companies
    ******************************************************************************/
    public override List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
    	try {
			Map<String, String> searchParametersMap = CreditFactoryGlobalUtils.generateSearchParametersMap(searchParametersSet, this.internalCFCompany);
			CreditSystem__c creditSystem = CreditSystem__c.getInstance('CreditreformAT');
			List<CreditFactoryCompany> externalCompaniesList = new List<CreditFactoryCompany>();
	    	HttpRequest request = CreditFactoryWebCreditreform.generateSearchRequest(creditSystem.Endpoint__c, creditSystem.UserName__c,
				creditSystem.Password__c, creditSystem.API_Key__c, searchParametersMap, this.internalCFCompany.countryCode);
			Http h = new Http();
			HttpResponse res = h.send(request);
			this.apiErrorMessage = CreditFactoryUtilities.checkCreditreformAPIErrors(res);
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			
	        String xml = res.getBody();
	        xml = CreditReformWebserviceAT.clearSearchXML(xml);
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xml);
	        Dom.XmlNode xmldom = domDoc.getRootElement();
	        Dom.XmlNode globalBody = CreditFactoryWebCreditreform.returnGlobalBody(xmldom);
	        Dom.XmlNode innerBody = CreditFactoryWebCreditreform.returnInnerBody(globalBody);
	        externalCompaniesList = CreditFactoryWebCreditreform.returnSearchCompany(innerBody);
	    	return externalCompaniesList;
    	} catch (Exception e) {
			if (! String.isEmpty(this.apiErrorMessage)) {
				ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryGlobalUtils.CREDITREFORM_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
					'<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(CreditFactoryGlobalUtils.CREDITREFORM_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				ExceptionLogger.sendException('<br/>Reason: ' + 'Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
					'<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
    	}
    }
	
	
	/*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 11/12/2020 by Ivan Kulinkovich
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : credit reports
    ******************************************************************************/
	public override CreditFactoryReportsItem requestCompanyReports(String companyId) {
		String serviceName = 'Creditreform';
		try {
			CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
			CreditSystem__c creditSystem = CreditSystem__c.getInstance('CreditreformAT');
			HttpResponse creditreformResponse = requestCreditreformReport(creditSystem, companyId);
			this.apiErrorMessage = CreditFactoryGlobalUtils.checkCreditreformAPIErrors(creditreformResponse);
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			
			this.attachmentBody = doPrepareBodyForAttachment(creditreformResponse);
			String xml = creditreformResponse.getBody();
			xml = CreditFactoryWebCreditreform.clearSearchXML(xml);
            Dom.Document domDoc = new Dom.Document();
			domDoc.load(xml);
			Dom.XmlNode xmldom = domDoc.getRootElement();
			Dom.XmlNode globalBody = CreditFactoryWebCreditreform.returnGlobalBody(xmldom);
			Dom.XmlNode innerBody = CreditFactoryWebCreditreform.returnInnerBody(globalBody);
			if (innerBody == null) {
				String errorMessage = CreditReformWebserviceAT.returnErrorMessage(globalBody);
				if (errorMessage == 'ER-114 Das gewählte Produkt ist für das angefragte Unternehmen nicht verfügbar. Sie können eine Wirtschaftsauskunft ' +
					'abrufen oder bestellen.' || errorMessage == 'ER-66 Auskunft zur Zeit nicht möglich. Bitte Auftrag erteilen.') {
					reportsItem.isReportAvailable = false;
                	reportsItem.errorMessage = errorMessage;
					reportsItem.isOrderAvailable = true;
					return reportsItem;
				}
			}
			
			this.externalCFCompany = CreditFactoryWebCreditreform.returnReportCompany(innerBody, companyId, this.internalCFCompany.country);
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
	*  CreatedDate     : 11/12/2020 by Ivan Kulinkovich
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : Creditreform report request
	******************************************************************************/
	private HttpResponse requestCreditreformReport(CreditSystem__c creditSystem, String companyId) {
		HttpRequest request = CreditFactoryWebCreditreform.generateReportRequest(
            creditSystem.Endpoint__c, creditSystem.UserName__c,
            creditSystem.Password__c, creditSystem.API_Key__c, companyId);
        Http h = new Http();
        HttpResponse response = h.send(request);
		
		return response;
	}
	
	
	/*******************************************************************************
    *  Summary         : Get pdf from reponse
    *  CreatedDate     : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : response - response from request for report
    *  Returns         : Blob - body of PDF report
    ******************************************************************************/
    private Blob doPrepareBodyForAttachment(HttpResponse response) {
		Blob blobBody = response.getBodyAsBlob();
		String blobBodyHex = EncodingUtil.convertToHex(blobBody);
		String blobPdfHex = blobBodyHex.substringBetween('25504446', '2525454f46');
		Blob blobPdf;
		if (blobPdfHex != null) {
			blobPdfHex = '25504446' + blobPdfHex + '2525454f46';
			blobPdf = EncodingUtil.convertFromHex(blobPdfHex);
			return blobPdf;
		}
	
		return null;
    }
	
	
	/*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 11/12/2020 by Ivan Kulinkovich
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

            setFuelPriceIndex();
            setBuffer();
            setRiskCategory();
			setRecommendedCreditLimit();

            this.validationItemsMap = validationItemsMap;

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '15+7') {
                    this.creditLimit15Plus7 = calculateCreditLimit(15, 7);
                    this.securityLevel15Plus7 = calculateSecurityLevel(this.creditLimit15Plus7);
                    this.deposit15Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus7, this.creditLimit15Plus7, 15, 7, this.recommendedCreditLimit);
                    this.deposit15Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus7);
                    this.maxCreditLimit15Plus7 = calculateMaxCreditLimit(this.creditLimit15Plus7, this.deposit15Plus7);
					if (this.creditLimit15Plus7 < 700 && this.recommendedCreditLimit > 1000 && this.creditLimit15Plus7 * 1.5 <= this.maxCreditLimit15Plus7 && this.deposit15Plus7 == 0) {
						this.creditLimit15Plus7 = this.creditLimit15Plus7 * 1.5;
						this.creditLimit15Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.creditLimit15Plus7);
					}

					if (this.securityLevel15Plus7 != null) {
						this.depositReason15plus7 = setDepositReason(this.securityLevel15Plus7);
					}
                }
            }

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
    *  CreatedDate     : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance(this.internalCFCompany.country);
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setBuffer() {
		if (this.externalCFCompany.classRating != null) {
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
		else {
			this.buffer = 0.1;
		}
    }


    /*******************************************************************************
    *  Summary         : Set Risk Category
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    protected override void setRiskCategory() {
		if (this.externalCFCompany.classRating != null) {
			if (this.externalCFCompany.classRating == '1' || this.externalCFCompany.classRating == '2') {
				this.riskCategory = 'Low';
			}
			else if (this.externalCFCompany.classRating == '3') {
				this.riskCategory = 'Medium';
			}
			else if (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5') {
				this.riskCategory = 'High';
			}
			else if (this.externalCFCompany.classRating == '6') {
				this.riskCategory = 'Very';
			}
		}
		else {
			this.riskCategory = 'High';
		}
    }


	/*******************************************************************************
    *  Summary         : set recommended CL
    *  Created         : 14/12/2020 by Ivan Kulinkovich
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
    *  Created         : 14/12/2020 by Ivan Kulinkovich
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
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
						 billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel(Decimal creditLimit) {
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
            securityLevel = calculateSecurityLevelRating4(creditLimit);
        }
		else if (this.externalCFCompany.classRating == '5') {
            securityLevel = calculateSecurityLevelRating5();
        }
		else if (this.externalCFCompany.classRating == '6') {
			securityLevel = calculateSecurityLevelRating6();
		}
		else if (this.externalCFCompany.classRating == null) {
			securityLevel = calculateSecurityLevelNoRating();
		}

		if (securityLevel == null && this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
            securityLevel = 100;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 1
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1(Decimal creditLimit) {
		Decimal securityLevel;
		if (isNewBusiness()) {
			if (isNewBusinessException()) {
				securityLevel = null;
			}
			else {
				securityLevel = 100;
			}
		}
		else if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		}
		else {
			securityLevel = null;
		}
        
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 2
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2(Decimal creditLimit) {
		Decimal securityLevel;
		if (isNewBusiness()) {
			if (isNewBusinessException()) {
				securityLevel = null;
			}
			else {
				securityLevel = 100;
			}
		}
		else if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		}
		else {
			securityLevel = null;
		}
        
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 3
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3(Decimal creditLimit) {
		Decimal securityLevel;
		if (isNewBusiness()) {
			if (isNewBusinessException()) {
				securityLevel = null;
			}
			else {
				securityLevel = 100;
			}
		}
		else if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		}
		else {
			securityLevel = null;
		}
        
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 4
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4(Decimal creditLimit) {
		Decimal securityLevel;
		if (isNewBusiness()) {
			if (isNewBusinessException()) {
				securityLevel = null;
			}
			else {
				securityLevel = 100;
			}
		}
		else if (creditLimit > this.recommendedCreditLimit + 500) {
			securityLevel = 4;
		}
		else {
			securityLevel = null;
		}
        
        return securityLevel;
    }


	/*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
		Decimal securityLevel;
		if (isNewBusinessException()) {
			securityLevel = null;
		}
		else {
			securityLevel = 100;
		}
		
        return securityLevel;
    }
	
	
	/*******************************************************************************
    *  Summary         : calculate security level for rating 6
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 6
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating6() {
		Decimal securityLevel = 110;
        return securityLevel;
    }
	
	
	/*******************************************************************************
    *  Summary         : calculate security level for no rating
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for no Rating
    ******************************************************************************/
    private Decimal calculateSecurityLevelNoRating() {
		Decimal securityLevel;
		if (isNewBusinessException()) {
			securityLevel = null;
		}
		else {
			securityLevel = 100;
		}
		
        return securityLevel;
    }
	
	
	/*******************************************************************************
    *  Summary         : Check if it's a new business
    *  Created         : 16/01/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
	private Boolean isNewBusiness() {
		if (this.externalCFCompany.dateOfFoundation != null && (this.externalCFCompany.dateOfFoundation.length() == 10 &&
				Date.valueOf(this.externalCFCompany.dateOfFoundation).monthsBetween(Date.today()) <= 18 ||
				this.externalCFCompany.dateOfFoundation.length() == 4 && Date.today().year() - Decimal.valueOf(this.externalCFCompany.dateOfFoundation) < 2)) {
			return true;
		}
		
		return false;
	}
	
	
	/*******************************************************************************
    *  Summary         : Check if it's a new business exception
    *  Created         : 16/01/2021 by Ivan Kulinkovich
    *  Parameters      : Decimal billingPeriod,
    					 Decimal paymentTerms
    *  Returns         : Boolean
    ******************************************************************************/
	private Boolean isNewBusinessException() {
		if (isNewBusiness() && this.internalCFCompany.totalConsumption <= 300 && this.internalCFCompany.numberOfCards != null &&
				Integer.valueOf(this.internalCFCompany.numberOfCards) <= 1) {
			this.isNewBusinessException = true;
			return true;
		}
		
		return false;
	}


    /*******************************************************************************
    *  Summary         : calculate max CL
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal creditLimit, Decimal deposit) {
        Decimal maxCreditLimit;
        if (deposit > 0) {
            maxCreditLimit = creditLimit;
        }
        else {
			if (creditLimit * 2 < 8000) {
				maxCreditLimit = creditLimit * 2;
			}
			else {
				maxCreditLimit = 8000;
			}

			if (maxCreditLimit > recommendedCreditLimit + 500) {
				maxCreditLimit = recommendedCreditLimit + 500;
			}
			
			if (this.externalCFCompany.dateOfFoundation != null && (this.externalCFCompany.dateOfFoundation.length() == 10 &&
					Date.valueOf(this.externalCFCompany.dateOfFoundation).monthsBetween(Date.today()) <= 18 ||
					this.externalCFCompany.dateOfFoundation.length() == 4 && Date.today().year() - Decimal.valueOf(this.externalCFCompany.dateOfFoundation) < 2)) {
				Decimal creditLimit300 = (this.fuelPriceIndex * 300 + this.internalCFCompany.nonFuelExposure) * (15 + 7) / 30 * (1 + this.buffer);
				if (maxCreditLimit > creditLimit300) {
                    maxCreditLimit = creditLimit300;
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
	private String setDepositReason(Decimal securityLevel) {
		String depositReason;
		if (this.externalCFCompany.classRating != null) {
			depositReason = 'Low credit rating (rating ' + this.externalCFCompany.classRating + ')';
		}
		else {
			depositReason = 'Low credit rating (no rating)';
		}

		if (securityLevel == 4) {
			depositReason = 'Low Recommended CL';
		}
		else if (this.externalCFCompany.classRating != '5' && this.externalCFCompany.classRating != '6' && this.externalCFCompany.classRating != null) {
			if (isNewBusiness()) {
				depositReason = 'New business';
			}
			else if (this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
				depositReason = 'Invalid contact';
			}
		}

		return depositReason;
	}


    /*******************************************************************************
    *  Summary         : set default billing period and payment terms
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
        if (paymentDetailsSet.contains('15+7') && this.creditLimit15Plus7 < 8000) {
			setDefaultValues15Plus7();
		}
    }
	
	
    /*******************************************************************************
    *  Summary         : set default values for 15+7
    *  Created         : 14/12/2020 by Ivan Kulinkovich
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
    *  Summary         : set decision
    *  Created         : 14/12/2020 by Ivan Kulinkovich
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
    *  Created         : 14/12/2020 by Ivan Kulinkovich
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
        }
        else if (this.statusCode == '004') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Requested limit too high. Please refer to credit.'));
        }
    }


    /*******************************************************************************
    *  Summary         : set available button (pending deposit, closed won etc)
    *  Created         : 14/12/2020 by Ivan Kulinkovich
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
    *  Created         : 14/12/2020 by Ivan Kulinkovich
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
    *  Created         : 14/12/2020 by Ivan Kulinkovich
    *  Parameters      : opportunityId - id of opportunity
    *  Returns         : --
    ******************************************************************************/
    public override void createPdfReports(String opportunityId) {
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' +
                Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() +
                Datetime.now().addSeconds(5).millisecond();
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(this.externalCFCompany.identificationNumber, null, opportunityId, this.attachmentBody, this.externalCFCompany.country);
        System.schedule(scheduleName, schedule, pdfSchedule);
    }
}