public class CreditFactoryImplPL extends CreditFactoryImpl {
    private Decimal profitLossLastYear;
    private Decimal profitLossYearBeforeLast;
    private Decimal turnOverLastYear;
    private String policyRulesPriority;
    private transient String krdResponseBody;
    private Boolean isCarnetOnly = false;
    private Boolean isCarnetWithShell = false;


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 01/08/2019 by Anton Buzak
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : list of searched companies
    ******************************************************************************/
    public override List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
    	try {
            Map<String, String> searchParametersMap = CreditFactoryGlobalUtils.generateSearchParametersMap(searchParametersSet, this.internalCFCompany);
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Crif');
	    	HttpRequest request = CreditFactoryWebCrif.generateSearchRequest(
                    creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, searchParametersMap);
			Http http = new Http();
			HttpResponse response = http.send(request);
            this.apiErrorMessage = CreditFactoryGlobalUtils.checkCrifAPIErrors(response);
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
            
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(response.getBody());
	        Dom.XmlNode xmlDom = domDoc.getRootElement();
            Dom.XmlNode searchResponseBody = CreditFactoryWebCrif.returnSearchResponse(xmlDom);
        
	        List<CreditFactoryCompany> externalCompaniesList = CreditFactoryWebCrif.returnSearchedCompanies(searchResponseBody);
            return externalCompaniesList;
    	} catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.CRIF_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
    	}
    }


    /*******************************************************************************
	*  Summary         : Do order request for report.
	*  CreatedDate     : 15/01/2020
	*  Parameters      : internalId - credit company id
	*  Returns         : -
	******************************************************************************/
    public override CreditFactoryOrderItem requestOrder(String internalId) {
		try {
            CreditFactoryOrderItem orderItem = new CreditFactoryOrderItem();
            String companyId;
            if (internalId == null) {
                companyId = this.internalCFCompany.taxId;
                CreditSystem__c creditSystem = CreditSystem__c.getInstance('Crif');
                HttpRequest request = CreditFactoryWebCrif.generateReportRequest(
                        creditSystem.Endpoint__c, creditSystem.UserName__c,
                        creditSystem.Password__c, companyId);
                Http http = new Http();
                HttpResponse response = http.send(request);
                this.apiErrorMessage = CreditFactoryGlobalUtils.checkCrifAPIErrors(response);
				if (! String.isEmpty(this.apiErrorMessage)) {
					throw new CreditFactoryException(this.apiErrorMessage);
				}
            } 
            else {
                companyId = internalId;
            }
            
            orderItem.orderReferenceNumber = companyId;
            orderItem.message = 'Additional attempts to download a Credit Factory report will be performed automatically till the end of the day. ' +
			    'Once a report is downloaded you will receive an email notification.';
            
            return orderItem;
	    } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
	    	if (! String.isEmpty(apiErrorMessage)) {
				throw new CreditFactoryException(apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.CRIF_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
                throw new CreditFactoryException('Order request failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
	    }
	}
    
    
    /*******************************************************************************
    *  Summary         : return set of fields to update after order request   
    *  Created         : 07/04/2020
    *  Parameters      : orderId - id of order
    *  Returns         : -
    ******************************************************************************/
    public override Map<String, Object> returnOrderFieldsToUpdate(String orderId) {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        if (this.internalCFCompany.recordType == 'Lotos') {
			opportunityFieldsMap.put('Credit_Stage__c', 'Pending Credit Report');
		} 
        else {
			opportunityFieldsMap.put('StageName', 'Pending Credit Report');
		}

        opportunityFieldsMap.put('CF_Stage__c', 'Pending Credit Report - Order was sent');
        opportunityFieldsMap.put('Credit_Report_Id__c', orderId);
        opportunityFieldsMap.put('CF_Orders__c', orderId + ' - ' + Datetime.now());
        opportunityFieldsMap.put('Credit_Report_Request_Date__c', Date.today());
        fieldsMap.put('Opportunity', opportunityFieldsMap);

        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 24/10/2019 by Anton Buzak
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : credit reports
    ******************************************************************************/
    public override CreditFactoryReportsItem requestCompanyReports(String companyId) {
        String serviceName = 'Crif';
        try {
            CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Crif');
            HttpResponse crifResponse = requestCrifReport(creditSystem, companyId);
            this.apiErrorMessage = CreditFactoryGlobalUtils.checkCrifAPIErrors(crifResponse);
            if (! String.isEmpty(this.apiErrorMessage)) {
                throw new CreditFactoryException(this.apiErrorMessage);
            }
            
            Dom.XmlNode xmlNodeCrif = getXmlNode(crifResponse.getBody());
            Dom.XmlNode reportDom = CreditFactoryWebCrif.returnReportBody(xmlNodeCrif);
            String identificationType = CreditFactoryWebCrif.returnIdentificationType(reportDom);
            if (identificationType == 'NOT_IDENTIFIED') {
                reportsItem.isReportAvailable = false;
                reportsItem.isOrderAvailable = false;
                reportsItem.errorMessage = 'Credit report is not available. Customer did not publish his company details. Please refer to Credit.';
                return reportsItem;
            }

            String requestStatus = CreditFactoryWebCrif.returnRequestStatus(reportDom);
            if (requestStatus != 'OK') {
                reportsItem.isReportAvailable = false;
                reportsItem.errorMessage = 'Credit Factory report received with a system error.';
                reportsItem.isOrderAvailable = true;
                reportsItem.orderId = companyId;
                return reportsItem;
            }

            this.externalCFCompany = CreditFactoryWebCrif.returnReportCompany(reportDom, companyId);
            if (this.externalCFCompany.name == null) {
                reportsItem.isReportAvailable = false;
                reportsItem.isOrderAvailable = false;
                reportsItem.errorMessage = 'Credit Report does not contain enough information for the Credit Scoring. Please refer to Credit.';
                return reportsItem;
            }

            CreditSystem__c krdSettings = CreditSystem__c.getInstance('KRD');
            if (krdSettings != null && this.internalCFCompany.totalConsumption > 1000) {
                serviceName = 'KRD';
                checkPaymentHistory(companyId);
            }

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
    *  Summary         : Get data from KRD request
    *  CreatedDate     : 08/10/2020 by Ivan Kulinkovich
    *  Parameters      : companyId - company id
    *  Returns         : void
    ******************************************************************************/
    private void checkPaymentHistory(String companyId) {
        CreditSystem__c krdSettings = CreditSystem__c.getInstance('KRD');
        HttpResponse krdResponse = requestKrdReport(krdSettings, companyId);
        this.apiErrorMessage = CreditFactoryGlobalUtils.checkKRDAPIErrors(krdResponse);
        if (! String.isEmpty(this.apiErrorMessage)) {
            throw new CreditFactoryException(this.apiErrorMessage);
        }

        this.krdResponseBody = krdResponse.getBody();
        Dom.XmlNode krdXmlNode = getXmlNode(this.krdResponseBody);
        Dom.XmlNode disclosureReportNode = CreditFactoryWebKRD.returnDisclosureReportNode(krdXmlNode);
        this.externalCFCompany = CreditFactoryWebKRD.returnReportCompany(disclosureReportNode, this.externalCFCompany);
    }
    
    /*******************************************************************************
	*  Summary         : Send request to Credit System to get company, employees and pdf report
	*  CreatedDate     : 31/10/2016 by Anton Buzak
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : Crif report request
	******************************************************************************/
    private HttpResponse requestCrifReport(CreditSystem__c creditSystem, String companyId) {
		HttpRequest request = CreditFactoryWebCrif.generateReportRequest(
            creditSystem.Endpoint__c, creditSystem.UserName__c, 
            creditSystem.Password__c, companyId);
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }


    /*******************************************************************************
    *  Summary         : Send request to KRD
    *  CreatedDate     : 06/08/2020 by Anton Buzak
    *  Parameters      : krdSettings - KRD settings
    *  Returns         : KRD report response
    ******************************************************************************/
    private HttpResponse requestKrdReport(CreditSystem__c krdSettings, String companyId) {
        HttpRequest request = CreditFactoryWebKRD.generateReportRequest(
            krdSettings.Endpoint__c, krdSettings.UserName__c,
            krdSettings.Password__c, companyId);
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }


    /*******************************************************************************
    *  Summary         : Return currency Iso code based on country
    *  Created         : 12/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    protected override String returnCurrencyIsoCode(String countryCode) {
		return 'PLN';
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 26/12/2019 by Anton Buzak
    *  Parameters      : paymentDetailsSet - possible payment details, 
                         validationItemsMap - validations results map
    *  Returns         : Credit Factory result structure
    ******************************************************************************/
    public override CreditFactoryResult doCreditScoring(Set<String> paymentDetailsSet, Map<String, CreditFactoryValidationItem> validationItemsMap) {
        try {
            CreditFactoryResult cfResult = new CreditFactoryResult();

            Boolean isPaymentHistoryRequested = false;
            if (this.internalCFCompany.totalConsumption > 1000 && this.externalCFCompany.paymentHistoryRequested == false) {
                checkPaymentHistory(this.externalCFCompany.identificationNumber);
                isPaymentHistoryRequested = true;
            }

            if (validationItemsMap.containsKey('CompanyStatus') && validationItemsMap.get('CompanyStatus').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '012';
                return cfResult;
            }
            else if (validationItemsMap.containsKey('EmptyAddress') && validationItemsMap.get('EmptyAddress').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '013';
                return cfResult;
            }

            this.validationItemsMap = validationItemsMap;
            checkForCarnet();

            if (! this.isCarnetOnly) {
                setFuelPriceIndex();
                setBuffer();
                setProfitLossLastYear();
                setProfitLossYearBeforeLast();
                setTurnOverLastYear();
                setPolicyRulesPriority();
                setDateOfFoundation();
                setCalculationsForNewBusinessException(paymentDetailsSet);

                for (String paymentDetail : paymentDetailsSet) {
                    if (paymentDetail == '7+7') {
                        this.creditLimit7Plus7 = calculateCreditLimit(7, 7);
                        this.securityLevel7Plus7 = calculateSecurityLevel(this.creditLimit7Plus7, 7, 7);
                        this.deposit7Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel7Plus7, this.creditLimit7Plus7, 7, 7, null);
                        this.deposit7Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit7Plus7);
                        this.maxCreditLimit7Plus7 = calculateMaxCreditLimit(7, 7, this.creditLimit7Plus7, this.deposit7Plus7);
                        this.maxCreditLimit7Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit7Plus7);
                        if (this.securityLevel7Plus7 != null) {
                            this.depositReason7plus7 = setDepositReason(this.creditLimit7Plus7, paymentDetail);
                        }
                    }
                    else if (paymentDetail == '15+7') {
                        this.creditLimit15Plus7 = calculateCreditLimit(15, 7);
                        this.securityLevel15Plus7 = calculateSecurityLevel(this.creditLimit15Plus7, 15, 7);
                        this.deposit15Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus7, this.creditLimit15Plus7, 15, 7, null);
                        this.deposit15Plus7 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus7);
                        this.maxCreditLimit15Plus7 = calculateMaxCreditLimit(15, 7, this.creditLimit15Plus7, this.deposit15Plus7);
                        this.maxCreditLimit15Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit15Plus7);
                        if (this.securityLevel15Plus7 != null) {
                            this.depositReason15plus7 = setDepositReason(this.creditLimit15Plus7, paymentDetail);
                        }
                    }
                    else if (paymentDetail == '15+14') {
                        this.creditLimit15Plus14 = calculateCreditLimit(15, 14);
                        this.securityLevel15Plus14 = calculateSecurityLevel(this.creditLimit15Plus14, 15, 14);
                        this.deposit15Plus14 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus14, this.creditLimit15Plus14, 15, 14, null);
                        this.deposit15Plus14 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus14);
                        this.maxCreditLimit15Plus14 = calculateMaxCreditLimit(15, 14, this.creditLimit15Plus14, this.deposit15Plus14);
                        this.maxCreditLimit15Plus14 = CreditFactoryGlobalUtils.roundCreditLimitToHundreds(this.maxCreditLimit15Plus14);
                        if (this.securityLevel15Plus14 != null) {
                            this.depositReason15plus14 = setDepositReason(this.creditLimit15Plus14, paymentDetail);
                        }
                    }
                }

                this.riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);
                setDefaultPaymentDetails(paymentDetailsSet);
            }

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
                    'Direct Debit', 'Bank Transfer'
            };
            cfResult.invoicesSet = new List<String>{
                    'e-Invoicing'
            };

            if (isPaymentHistoryRequested) {
                cfResult.requiredUpdates = 'Payment history data';
            }

            cfResult.resultsList = this.resultsList;

            return cfResult;
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Scoring failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
		}
    }


    /*******************************************************************************
    *  Summary         : Check for carnet units
    *  CreatedDate     : 26/02/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void checkForCarnet() {
        if ((this.internalCFCompany.recordType == 'Euroshell' || this.internalCFCompany.recordType == 'Euroshell Starts') &&
                this.internalCFCompany.numberOfGpsUnits != null && this.internalCFCompany.numberOfGpsUnits > 0) {
            if (String.isEmpty(this.internalCFCompany.numberOfCards) || Integer.valueOf(this.internalCFCompany.numberOfCards) == 0) {
                this.isCarnetOnly = true;
            }
            else {
                this.isCarnetWithShell = true;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Set fuel price index
    *  CreatedDate     : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Poland');
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setBuffer() {
        if (this.externalCFCompany.classRating == '1') {
	        this.buffer = 0.2;
	    }
        else if (this.externalCFCompany.classRating == '2') {
	    	this.buffer = 0.1;
	    }
        else if (this.externalCFCompany.classRating == '3') {
	    	this.buffer = 0;
	    }
    }


    /*******************************************************************************
    *  Summary         : set profit/loss for the last year
    *  Created         : 30/12/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setProfitLossLastYear() {
        this.profitLossLastYear = 0;
        if (this.externalCFCompany.profitLossLastYear != null) {
            this.profitLossLastYear = Decimal.valueOf(this.externalCFCompany.profitLossLastYear);
        }
        else if (this.internalCFCompany.profitLossLastYear != null) {
            this.profitLossLastYear = Decimal.valueOf(this.internalCFCompany.profitLossLastYear);
        }
    }


    /*******************************************************************************
    *  Summary         : set profit/loss for the year before last
    *  Created         : 30/12/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setProfitLossYearBeforeLast() {
        this.profitLossYearBeforeLast = 0;
        if (this.externalCFCompany.profitLossYearBeforeLast != null) {
            this.profitLossYearBeforeLast = Decimal.valueOf(this.externalCFCompany.profitLossYearBeforeLast);
        }
        else if (this.internalCFCompany.profitLossYearBeforeLast != null) {
            this.profitLossYearBeforeLast = Decimal.valueOf(this.internalCFCompany.profitLossYearBeforeLast);
        }
    }


    /*******************************************************************************
    *  Summary         : set turn over for the last year
    *  Created         : 30/12/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setTurnOverLastYear() {
        this.turnOverLastYear = 0;
        if (this.externalCFCompany.turnOverLastYear != null) {
            this.turnOverLastYear = Decimal.valueOf(this.externalCFCompany.turnOverLastYear);
        }
        else if (this.internalCFCompany.turnOverLastYear != null) {
            this.turnOverLastYear = Decimal.valueOf(this.internalCFCompany.turnOverLastYear);
        }
    }


    /*******************************************************************************
    *  Summary         : return the highest policy rules priority
    *  Created         : 30/12/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setPolicyRulesPriority() {
		List<String> prioritiesList = new List<String>();
		if (this.externalCFCompany.numberOfHits != null) {
			for (String policyRule : this.externalCFCompany.policyRuleHitsList) {
				if (allPolicyRulesMap.containsKey(policyRule)) {
                    prioritiesList.add(allPolicyRulesMap.get(policyRule));
				}
			}

			if (! prioritiesList.isEmpty()) {
				prioritiesList.sort();
				this.policyRulesPriority = prioritiesList.get(0);
			}
		}
    }


    /*******************************************************************************
    *  Summary         : set date of foundation
    *  Created         : 01/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDateOfFoundation() {
        if (this.externalCFCompany.dateOfFoundation != null) {
            this.dateOfFoundation = Date.newInstance(Integer.valueOf(externalCFCompany.dateOfFoundation.substring(0, 4)),
                    Integer.valueOf(externalCFCompany.dateOfFoundation.substring(4, 6)), Integer.valueOf(externalCFCompany.dateOfFoundation.substring(6, 8)));
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limit
    *  Created         : 26/12/2019 by Anton Buzak
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
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
                         Decimal billingPeriod - billing period,
                         Decimal paymentTerms - payment terms
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
    *  Created         : 30/12/2019
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1(Decimal creditLimit) {
        Decimal securityLevel;
        if (this.validationItemsMap.containsKey('ObligationOverdue') && this.validationItemsMap.get('ObligationOverdue').passed == false) {
            securityLevel = 100;
        }
        else if (this.internalCFCompany.totalConsumption > 1500) {
            securityLevel = calculateSecurityLevelBasedOnPIT(creditLimit);
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for 7+7 rating 2
    *  Created         : 30/12/2019
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2(Decimal creditLimit) {
        Decimal securityLevel;
        if (this.validationItemsMap.containsKey('ObligationOverdue') && this.validationItemsMap.get('ObligationOverdue').passed == false ||
                    this.policyRulesPriority == '2' || this.policyRulesPriority == '3' && soloTradersSet.contains(this.externalCFCompany.legalForm) ||
                    this.policyRulesPriority == null && (this.externalCFCompany.nameChangeDecision == 'YELLOW' || this.externalCFCompany.addressChangeDecision == 'YELLOW' ||
                    this.externalCFCompany.nameChangeDecision != 'YELLOW' && this.externalCFCompany.addressChangeDecision != 'YELLOW')) {
            securityLevel = 100;
        }
        else if (this.internalCFCompany.totalConsumption > 1500) {
            securityLevel = calculateSecurityLevelBasedOnPIT(creditLimit);
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level based on PIT
    *  Created         : 30/12/2019
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security level based on PIT
    ******************************************************************************/
    private Decimal calculateSecurityLevelBasedOnPIT(Decimal creditLimit) {
        Decimal securityLevel;
        if (this.profitLossLastYear == 0 && this.profitLossYearBeforeLast == 0 ||
                this.profitLossLastYear < 0) {
            securityLevel = 100;
        }
        else if (this.profitLossLastYear > 0 && this.profitLossYearBeforeLast < 0) {
            securityLevel = 70;
        }
        else if (this.profitLossLastYear <= 20000 ||
                this.profitLossYearBeforeLast <= 35000 ||
                creditLimit > this.profitLossLastYear ||
                creditLimit > this.turnOverLastYear * 0.1) {
            securityLevel = 50;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level if it's a new business exception
    *  Created         : 01/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
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
    *  Created         : 01/04/2021 by Ivan Kulinkovich
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
    *  Created         : 01/04/2021 by Ivan Kulinkovich
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
    *  Created         : 01/04/2021 by Ivan Kulinkovich
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
    *  Created         : 01/04/2021 by Ivan Kulinkovich
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
    *  Created         : 01/04/2021 by Ivan Kulinkovich
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
    *  Summary         : calculate max CL
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal billingPeriod, Decimal paymentTerms, Decimal creditLimit, Decimal deposit) {
        Decimal maxCreditLimit;
        if (deposit > 0) {
            maxCreditLimit = creditLimit;
        }
        else {
            Decimal creditLimit2000 = (this.fuelPriceIndex * 2000 + this.internalCFCompany.nonFuelExposure) * (billingPeriod + paymentTerms) / 30 * (1 + this.buffer);
            Decimal creditLimit8000 = (this.fuelPriceIndex * 8000 + this.internalCFCompany.nonFuelExposure) * (billingPeriod + paymentTerms) / 30 * (1 + this.buffer);

            Decimal fixedCL;
            if (this.externalCFCompany.totalOverdueAmount != 0) { // null or > 0
                fixedCL = creditLimit2000;
            }
            else {
                fixedCL = creditLimit8000;
            }

            if (creditLimit * 2 <= fixedCL) {
                maxCreditLimit = creditLimit * 2;
            }
            else {
                maxCreditLimit = fixedCL;
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
    *  Parameters      : creditLimit - credit limit
    *  Returns         : deposit reason
    ******************************************************************************/
    private String setDepositReason(Decimal creditLimit, String paymentDetail) {
        String depositReason = this.calculationsMap.get(paymentDetail).depositReason;
        if (String.isEmpty(depositReason)) {
            if (this.validationItemsMap.containsKey('ObligationOverdue') && this.validationItemsMap.get('ObligationOverdue').passed == false) {
                depositReason = 'Obligation overdue';
            }
            else if (this.policyRulesPriority == '2' || this.policyRulesPriority == '3' && soloTradersSet.contains(this.externalCFCompany.legalForm)) {
                depositReason = 'Negative policy rule';
            }
            else if (this.externalCFCompany.classRating == '2' && this.policyRulesPriority == null &&
                    (this.externalCFCompany.nameChangeDecision == 'YELLOW' || this.externalCFCompany.addressChangeDecision == 'YELLOW' ||
                            this.externalCFCompany.nameChangeDecision != 'YELLOW' && this.externalCFCompany.addressChangeDecision != 'YELLOW')) {
                depositReason = 'Address/Director/Name change 6M';
            }
            else if (this.internalCFCompany.totalConsumption > 1500 && calculateSecurityLevelBasedOnPIT(creditLimit) != null) {
                depositReason = 'Low/no profitability';
            }
            else if (this.validationItemsMap.containsKey('Contact') && this.validationItemsMap.get('Contact').passed == false) {
                depositReason = 'Invalid contact';
            }
        }

        return depositReason;
    }


    /*******************************************************************************
    *  Summary         : set default billing period and payment terms
    *  Created         : 08/01/2020
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
        if (paymentDetailsSet.contains('15+14') && this.deposit15Plus14 == 0 && this.internalCFCompany.secChannel == 'Outbound') {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else if (this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues15Plus7();
            }
            else {
                setDefaultValues15Plus14();
            }
        }
        else if (paymentDetailsSet.contains('15+7') && this.deposit15Plus7 == 0) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus7();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.deposit7Plus7 == 0) {
            setDefaultValues7Plus7();
        }
        else {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus7();
            }
        }
    }


    /*******************************************************************************
    *  Summary         : set default values for 7+7
    *  Created         : 12/02/2020
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
    *  Created         : 12/02/2020
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
        this.riskCategory = (this.calculationsMap.get('15+7').highRisk ? 'High' : this.riskCategory);
    }


    /*******************************************************************************
    *  Summary         : set default values for 15+14
    *  Created         : 15/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues15Plus14() {
        this.billingPeriod = '15';
        this.paymentTerms = '14';
        this.creditLimit = this.creditLimit15Plus14;
        this.securityLevel = this.securityLevel15Plus14;
        this.deposit = this.deposit15Plus14;
        this.depositReason = this.depositReason15plus14;
        this.maxCreditLimit = this.maxCreditLimit15Plus14;
    }


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 09/01/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDecision() {
        if (this.validationItemsMap.containsKey('EmailRisk') && this.validationItemsMap.get('EmailRisk').passed == false) {
            this.verdict = 'No';
            this.statusCode = '009';
        }
        else if (this.validationItemsMap.containsKey('BlackList') && this.validationItemsMap.get('BlackList').passed == false) {
            this.verdict = 'No';
            this.statusCode = '008';
        }
        else if (this.externalCFCompany.classRating == '3') {
            this.verdict = 'No';
            this.statusCode = '007';
        }
        else if (this.isCarnetOnly) {
            this.verdict = 'Yes';
            this.statusCode = '015';
        }
        else if (this.externalCFCompany.classRating == '2' && this.policyRulesPriority == '1') {
            this.verdict = 'No';
            this.statusCode = '005';
        }
        else if (this.internalCFCompany.totalConsumption <= 2000) {
            this.verdict = 'Yes';
            this.statusCode = '001';
        }
        else if (this.internalCFCompany.totalConsumption > 2000 && this.externalCFCompany.bigRequested == false) {
            this.verdict = 'No';
            this.statusCode = '002';
        }
        else if (this.externalCFCompany.bigRequested == true) {
            if (this.externalCFCompany.totalOverdueAmount > 0) {
                this.verdict = 'No';
                this.statusCode = '003'; // overdue
            }
            else if (this.internalCFCompany.totalConsumption > 8000) {
                this.verdict = 'No';
                this.statusCode = '004'; // too high limit
            }
            else {
                this.verdict = 'Yes';
                this.statusCode = '001';
            }
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
                this.messagesList.add(new CreditFactoryResult.Message('info', '</br>Deposit to pay: ' + this.deposit + ' PLN.</br>' +
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

            if (this.isCarnetWithShell) {
                this.messagesList.add(new CreditFactoryResult.Message('info', 'Customer check successful, waiting for the advance payment for ordered goods.'));
            }
        }
        else if (this.statusCode == '002') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Company should be scored additionally.'));
        }
        else if (this.statusCode == '003') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Company has overdue debts. Please refer to credit.'));
        }
        else if (this.statusCode == '004') { 
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Requested limit too high. Please refer to credit.'));
        }
        else if (this.statusCode == '005') {
            String message = 'Opportunity is Closed as Lost. Reasons:<br/><ul>';
            for (String policyRule : this.externalCFCompany.policyRuleHitsList) {
                if (allPolicyRulesMap.containsKey(policyRule) && allPolicyRulesMap.get(policyRule) == this.policyRulesPriority) {
                    message += '<li>' + policyRule + '</li>';
                }
            }
            
            message += '</ul>';
            
            this.messagesList.add(new CreditFactoryResult.Message('error', message));
        }
        else if (this.statusCode == '007') { 
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Opportunity is closed as Lost (Rating 3)'));
        }
        else if (this.statusCode == '015') {
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Customer check successful, waiting for the advance payment for ordered goods.'));
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
            else if (! isCarnetOnly && this.internalCFCompany.docuSignStatus != 'Completed') {
                this.availableButtonsList.add('Contract Check');
            }
            else if (this.isCarnetOnly || this.isCarnetWithShell) {
                this.availableButtonsList.add('Pending Advance Payment');
            }
            else {
                this.availableButtonsList.add('Closed Won');
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
        if (paymentDetailsSet.contains('15+7')) {
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
			result15Plus7.riskCategory = (! this.isCarnetOnly && this.calculationsMap.get('15+7').highRisk ? 'High' : riskCategory);
            result15Plus7.classRating = (! this.isCarnetOnly && this.calculationsMap.get('15+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result15Plus7.paymentMethodsSet = new List<String> {'Direct Debit', 'Bank Transfer'};
			result15Plus7.invoicesSet = new List<String> {'e-Invoicing'};
			if (this.billingPeriod == result15Plus7.billingPeriod && this.paymentTerms == result15Plus7.paymentTerms) {
				result15Plus7.isDefault = true;
			}

			this.resultsList.add(result15Plus7);
		}

		if (paymentDetailsSet.contains('7+7')) {
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
            result7Plus7.riskCategory = (! this.isCarnetOnly && this.calculationsMap.get('7+7').highRisk ? 'High' : riskCategory);
            result7Plus7.classRating = (! this.isCarnetOnly && this.calculationsMap.get('7+7').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
            result7Plus7.paymentMethodsSet = new List<String>{'Direct Debit', 'Bank Transfer'};
            result7Plus7.invoicesSet = new List<String>{'e-Invoicing'};
            if (this.billingPeriod == result7Plus7.billingPeriod && this.paymentTerms == result7Plus7.paymentTerms) {
                result7Plus7.isDefault = true;
            }

            this.resultsList.add(result7Plus7);
        }
	}


    /*******************************************************************************
	*  Summary         : request BIG for additional credit scoring
	*  CreatedDate     : 09/01/2020
	*  Parameters      : validationItemsMap - validations map
	*  Returns         : credit reports
	******************************************************************************/
	public override CreditFactoryReportsItem requestAdditionalCreditScoringData(Map<String, CreditFactoryValidationItem> validationItemsMap) {
        try {
            CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
            BIG__c bigSettingsTest = BIG__c.getInstance('Test');
            BIG__c bigSettingsProd = BIG__c.getInstance('Production');
            BIG__c bigSettings;
            if (bigSettingsProd != null && bigSettingsProd.Active__c == true) {
                bigSettings = bigSettingsProd;
            } else if (bigSettingsTest != null && bigSettingsTest.Active__c == true) {
                bigSettings = bigSettingsTest;
            }

            if (bigSettings != null) {
                HttpResponse response = requestBigReport(bigSettings, DateTime.valueOf(validationItemsMap.get('ConsentSigner').parametersMap.get('ConsentGrantDate')));
                this.apiErrorMessage = CreditFactoryGlobalUtils.checkBigAPIErrors(response);
				if (!String.isEmpty(this.apiErrorMessage)) {
					throw new CreditFactoryException(this.apiErrorMessage);
				}
                String xmlBody = CreditFactoryWebBig.clearReportXml(response.getBody());
                Dom.Document domDocBIG = new Dom.Document();
                domDocBIG.load(xmlBody);
                Dom.XmlNode xmlNodeBIG = domDocBIG.getRootElement();
                Dom.XmlNode overdueNode = CreditFactoryWebBig.returnOverdueNode(xmlNodeBIG);
                this.externalCFCompany = CreditFactoryWebBig.returnReportCompany(overdueNode, this.externalCFCompany);
            }

            reportsItem.companiesList = new List<CreditFactoryCompany>();
            reportsItem.companiesList.add(this.externalCFCompany);
            return reportsItem;
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
			if (! String.isEmpty(this.apiErrorMessage)) {
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage().contains('Read timed out')) {
				throw new CreditFactoryException(CreditFactoryGlobalUtils.BIG_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				throw new CreditFactoryException('Set company error. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
			}
		}
	}


	/*******************************************************************************
    *  Summary         : Send request to BIG to get risks
    *  CreatedDate     : 08/10/2019
    *  Parameters      : bigSettings - BIG settings, consentGrantDate - date of signing agreement for additional scoring
    *  Returns         : BIG response
    ******************************************************************************/
    private HttpResponse requestBigReport(BIG__c bigSettings, DateTime consentGrantDate) {
        String consentGrantDateString = consentGrantDate.format('yyyy-MM-dd');
        HttpRequest request = CreditFactoryWebBig.generateReportRequest(
            bigSettings.Endpoint__c, bigSettings.User_Name__c, bigSettings.Password__c, 
            bigSettings.Client_Id__c, bigSettings.Test_Data_Marker__c, this.externalCFCompany.name, 
            this.externalCFCompany.taxId, consentGrantDateString);
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }


    /*******************************************************************************
    *  Summary         : Return fields to update in Report after KRD request
    *  CreatedDate     : 08/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public override Map<String, Object> returnPaymentHistoryFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> reportFieldsMap = new Map<String, Object>();
        reportFieldsMap.put('Payment_History_Requested__c', this.externalCFCompany.paymentHistoryRequested);
        fieldsMap.put('Credit_Factory_Report__c', reportFieldsMap);

        return fieldsMap;
    }

    
    /*******************************************************************************
    *  Summary         : create pdf reports asynchronously   
    *  Created         : 15/01/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public override void createPdfReports(String opportunityId) {
        // create schedule job for Crif pdf report
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' +
                Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() +
                Datetime.now().addSeconds(5).millisecond();
        Blob krdResponseBody;
        if (krdResponseBody != null) {
            krdResponseBody = Blob.valueOf(this.krdResponseBody);
        }

        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(this.externalCFCompany.creditSystemCompanyNumber, null, opportunityId, krdResponseBody, this.externalCFCompany.country);
        System.schedule(scheduleName, schedule, pdfSchedule);
    }


    /*******************************************************************************
    *  Summary         : create krd pdf reports asynchronously
    *  Created         : 09/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public override void createPaymentHistoryAttachment(String opportunityId) {
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' +
                Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() +
                Datetime.now().addSeconds(5).millisecond();
        Blob krdResponseBody = Blob.valueOf(this.krdResponseBody);
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(null, null, opportunityId, krdResponseBody, this.externalCFCompany.country);
        System.schedule(scheduleName, schedule, pdfSchedule);
    }


    public static Map<String, String> allPolicyRulesMap = new Map<String, String> {
        'Aktywna osoba decyzyjna otworzyła co najmniej 5 stanowisk w ciągu ostatnich 12 miesięcy w innych firmach' => '1',
        'Aktywna osoba decyzyjna zamknęła co najmniej 5 stanowisk w ciągu ostatnich 12 miesięcy w innych firmach' => '1',
        'Istnieją aktywne osoby decyzyjne z dużą ilością aktywnych połączeń do firm (>50)' => '1',
        'W tym samym budynku istnieje co najmniej 10 firm tego samego właściciela w dowolnym stanie aktywności połączenia' => '1',
        'Istnieje aktywna osoba decyzyjna z danymi negatywnymi' => '2',
        'Istnieje informacja negatywna dla firmy matki' => '2',
        'Istnieje informacja negatywna dla firmy córki' => '2',
        'Istnieje informacja negatywna dla firmy siostrzanej' => '2',
        'Firma była zawieszona lub zamknięta w ciągu ostatnich 12 miesięcy' => '2',
        'Więcej niż 2 zmiany adresu rejestracji firmy w ciągu ostatnich 24 miesięcy' => '2',
		'Firma była zawieszona lub zamknięta w ciągu ostatnich 12 miesięcy' => '2',
        'Istnieje nieaktywna osoba decyzyjna z danymi negatywnymi i data zamknięcia funkcji jest młodsza niż 12 miesięcy' => '3',
        'Istnieje aktywny właściciel połączony z firmą która ma dane negatywne' => '3',
        'Istnieje aktywna osoba decyzyjna będąca właścicielem innej firmy która ma dane negatywne' => '3',
		'W firmie KRS istnieje więcej niż jedna aktywna osoba decyzyjna bez numeru PESEL' => '4',
        'Budynek z dużą ilością firm zarejestrowanych w KRS' => '4',
        'Firma KRS jest zarejestrowana w budynku z dużą populacją' => '4',
        'Mniej niż 3 sprawozdania finansowe w ciągu ostatnich 5 lat' => '4',
        'Obniżenie kapitału w ciągu ostatnich 12 miesięcy' => '4',
        'Forma własności w REGON to własność zagraniczna' => '4'
	};


    public static Set<String> soloTradersSet = new Set<String> {
        'Private person company',
        'General partnership',
        'private company',
        'Partnership company',
        'Single person company confirmed'
    };


    private static Set<String> operatorsSet = new Set<String> {
            '>',
            '>=',
            '=',
            '<',
            '<=',
            '*'
    };
}