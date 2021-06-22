public class CreditFactoryImplHU extends CreditFactoryImpl {
    private Decimal profitLossLastYear;
    private Decimal profitLossYearBeforeLast;
    private Decimal turnOverLastYear;
    private Decimal yearOfLastFinancialInformation;


    /*******************************************************************************
    *  Summary         : Send API request to search list of companies
    *  CreatedDate     : 15/10/2019 by Anton Buzak
    *  Parameters      : searchParametersSet - set of parameters for searching
    *  Returns         : list of searched companies
    ******************************************************************************/
    public override List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
        try {
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Coface');
            Map<String, String> searchParametersMap = CreditFactoryGlobalUtils.generateSearchParametersMap(searchParametersSet, this.internalCFCompany);
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
                throw new CreditFactoryException(CreditFactoryGlobalUtils.COFACE_API_ERROR + ' ' + CreditFactoryGlobalUtils.CONTACT_ADMIN + ' Read timed out.');
            }
            else {
                throw new CreditFactoryException('Search company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Returns Credit Company based on search by Tax Id.
    *  CreatedDate     : 15/10/2019 by Anton Buzak
    *  Parameters      : creditSystem - Creditsafe settings,
    *  Returns         : companies list
    ******************************************************************************/
    private List<CreditFactoryCompany> doSearch(CreditSystem__c creditSystem, Map<String, String> searchParametersMap) {
        HttpRequest request = CreditFactoryWebCoface.generateSearchRequest(creditSystem.Endpoint__c, creditSystem.UserName__c,
                creditSystem.Password__c, searchParametersMap);
        Http http = new Http();
        HttpResponse searchResponse = http.send(request);
        this.apiErrorMessage = CreditFactoryGlobalUtils.checkCofaceAPIErrors(searchResponse);
        if (! String.isEmpty(this.apiErrorMessage)) {
            throw new CreditFactoryException(this.apiErrorMessage);
        }

        String xml = searchResponse.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xml);
        Dom.XmlNode xmldom = domDoc.getRootElement();
        Dom.XmlNode globalBody = CreditFactoryWebCoface.returnGlobalBody(xmldom);
        List<CreditFactoryCompany> companiesList = CreditFactoryWebCoface.returnSearchedCompanies(globalBody);
        return companiesList;
    }


    /*******************************************************************************
	*  Summary         : Do order request for report.
	*  CreatedDate     : 15/10/2019 by Anton Buzak
	*  Parameters      : internalId - credit company id
	*  Returns         : -
	******************************************************************************/
    public override CreditFactoryOrderItem requestOrder(String internalId) {
        try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            CF_Order_Notifications__c notification = CF_Order_Notifications__c.getInstance('Hungary');
            String nationalId;
            if (notification.Active__c) {
                message.setToAddresses(new List<String>{
                        notification.Email__c
                });
                List<OrgWideEmailAddress> addressesList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Credit Hungary' LIMIT 1];
                if (! addressesList.isEmpty()) {
                    if (internalId != null) {
                        nationalId = internalId;
                    }
                    else if (this.internalCFCompany.taxId != null && this.internalCFCompany.taxId.length() >= 8) {
                        nationalId = this.internalCFCompany.taxId.substring(0, 8);
                    }
                    else {
                        nationalId =this.internalCFCompany.taxId;
                    }

                    if (nationalId == null) {
                        throw new CreditFactoryException('');
                    }

                    message.setOrgWideEmailAddressId(addressesList.get(0).Id);
                    String body = 'Dear Coface, </br>Please make this report about the company ' + this.internalCFCompany.name + ' with National ID ' +
                            nationalId + ' available as soon as possible. </br></br>Regards, </br>Fleetcor Hungary';
                    message.setHtmlBody(body);
                    message.setSubject('Report unavailable');
                    message.setSaveAsActivity(false);
                    List<Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>();
                    messagesList.add(message);
                    Messaging.sendEmail(messagesList);
                }
            }

            CreditFactoryOrderItem orderItem = new CreditFactoryOrderItem();
            orderItem.message = 'Order request was sent.';
            orderItem.orderReferenceNumber = nationalId;

            return orderItem;
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '<br/>Opportunity Id: ' + this.internalCFCompany.opportunityId, String.valueOf(e.getStackTraceString()));
            throw new CreditFactoryException('Order request failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
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
        opportunityFieldsMap.put('CF_Order_Reference_Number__c', orderId);
        opportunityFieldsMap.put('CF_Orders__c', orderId + ' - ' + Datetime.now());
        opportunityFieldsMap.put('StageName', 'Pending Credit Report');
        opportunityFieldsMap.put('CF_Stage__c', 'Pending Credit Report - Order was sent');
        opportunityFieldsMap.put('CF_Order_Date__c', Datetime.now());
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
        String serviceName = 'Coface';
        try {
            CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
            CreditSystem__c creditSystem = CreditSystem__c.getInstance(serviceName);
            HttpResponse cofaceAvailabilityResponse = isCreditReportAvailable(creditSystem, companyId);
            apiErrorMessage = CreditFactoryGlobalUtils.checkCofaceAPIErrors(cofaceAvailabilityResponse);
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage);
            }

            Dom.Document domDocAvailability = new Dom.Document();
            domDocAvailability.load(cofaceAvailabilityResponse.getBody());
            Dom.XmlNode xmlDomAvailability = domDocAvailability.getRootElement();
            Dom.XmlNode globalBodyAvailability = CreditFactoryWebCoface.returnGlobalBody(xmlDomAvailability);

            Boolean isReportExists = CreditFactoryWebCoface.isCreditReportAvailable(globalBodyAvailability);
            if ( ! isReportExists ) {
                reportsItem.isReportAvailable = false;
                reportsItem.errorMessage = 'AUTOMATIC CREDIT REPORT is not available';
                reportsItem.isOrderAvailable = true;
                reportsItem.orderId = CreditFactoryWebCoface.returnInternalId(globalBodyAvailability);
                return reportsItem;
            }

            HttpResponse cofaceReportResponse = requestCofaceReport(creditSystem, companyId);
            apiErrorMessage = CreditFactoryGlobalUtils.checkCofaceAPIErrors(cofaceReportResponse);
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage);
            }

            Dom.Document domDoc = new Dom.Document();
            domDoc.load(cofaceReportResponse.getBody());
            Dom.XmlNode xmlDom = domDoc.getRootElement();
            Dom.XmlNode globalBody = CreditFactoryWebCoface.returnGlobalBody(xmlDom);
            Dom.XmlNode xmlReport = CreditFactoryWebCoface.returnInnerXmlReport(globalBody);
            String dateOfLastMajorUpdateString = CreditFactoryWebCoface.returnDateOfLastMajorUpdate(xmlReport);
            if (dateOfLastMajorUpdateString != null) {
                Date dateOfLastMajorUpdate = Date.newInstance(Integer.valueOf(dateOfLastMajorUpdateString.substring(0, 4)),
                        Integer.valueOf(dateOfLastMajorUpdateString.substring(4, 6)), Integer.valueOf(dateOfLastMajorUpdateString.substring(6, 8)));
                if (dateOfLastMajorUpdate.daysBetween(Date.today().addYears(-1)) > 0) {
                    reportsItem.isReportAvailable = false;
                    reportsItem.errorMessage = 'Date of Last Major Update is too old.';
                    reportsItem.isOrderAvailable = true;
                    reportsItem.orderId = CreditFactoryWebCoface.returnInternalId(globalBodyAvailability);
                    return reportsItem;
                }
            } else {
                reportsItem.isReportAvailable = false;
                reportsItem.errorMessage = 'Date of Last Major Update is unknown.';
                reportsItem.isOrderAvailable = true;
                reportsItem.orderId = CreditFactoryWebCoface.returnInternalId(globalBodyAvailability);
                return reportsItem;
            }

            this.externalCFCompany = CreditFactoryWebCoface.returnReportCompany(globalBody, companyId);

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
    *  Summary         : replace country specific characters
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : string without country specific characters
    ******************************************************************************/
    protected override String replaceSpecificCharacters(String stringToReplace) {
        if (stringToReplace != null) {
            if (stringToReplace.contains('Á')) stringToReplace = stringToReplace.replace('Á', 'A');
            if (stringToReplace.contains('á')) stringToReplace = stringToReplace.replace('á', 'a');
            if (stringToReplace.contains('É')) stringToReplace = stringToReplace.replace('É', 'E');
            if (stringToReplace.contains('é')) stringToReplace = stringToReplace.replace('é', 'e');
            if (stringToReplace.contains('Í')) stringToReplace = stringToReplace.replace('Í', 'I');
            if (stringToReplace.contains('í')) stringToReplace = stringToReplace.replace('í', 'i');
            if (stringToReplace.contains('Ó')) stringToReplace = stringToReplace.replace('Ó', 'O');
            if (stringToReplace.contains('ó')) stringToReplace = stringToReplace.replace('ó', 'o');
            if (stringToReplace.contains('Ö')) stringToReplace = stringToReplace.replace('Ö', 'O');
            if (stringToReplace.contains('ö')) stringToReplace = stringToReplace.replace('ö', 'o');
            if (stringToReplace.contains('Ő')) stringToReplace = stringToReplace.replace('Ő', 'O');
            if (stringToReplace.contains('ő')) stringToReplace = stringToReplace.replace('ő', 'o');
            if (stringToReplace.contains('Ú')) stringToReplace = stringToReplace.replace('Ú', 'U');
            if (stringToReplace.contains('ú')) stringToReplace = stringToReplace.replace('ú', 'u');
            if (stringToReplace.contains('Ü')) stringToReplace = stringToReplace.replace('Ü', 'U');
            if (stringToReplace.contains('ü')) stringToReplace = stringToReplace.replace('ü', 'u');
            if (stringToReplace.contains('Ű')) stringToReplace = stringToReplace.replace('Ű', 'U');
            if (stringToReplace.contains('ű')) stringToReplace = stringToReplace.replace('ű', 'u');
        }

        return stringToReplace;
    }


    /*******************************************************************************
    *  Summary         : Send report request
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page,
    *  Returns         :
    ******************************************************************************/
    public HttpResponse requestCofaceReport(CreditSystem__c creditSystem, String companyId) {
        HttpRequest request = CreditFactoryWebCoface.generateReportRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, companyId);
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }


    /*******************************************************************************
    *  Summary         : Check availability of AUTOMATIC CREDIT REPORT report (Code: 761)
    *  CreatedDate     : 19/10/2020 by Anton Buzak
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : void
    ******************************************************************************/
    public HttpResponse isCreditReportAvailable(CreditSystem__c creditSystem, String companyId) {
        HttpRequest request = CreditFactoryWebCoface.generateRequestForCheckAvailability(creditSystem.Endpoint__c,
                                                                                         creditSystem.UserName__c,
                                                                                         creditSystem.Password__c,
                                                                                         companyId);
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }


    /*******************************************************************************
    *  Summary         : Return currency Iso code based on country
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    protected override String returnCurrencyIsoCode(String countryCode) {
		return 'HUF';
    }


    /*******************************************************************************
    *  Summary         : Return company name fields to update in Account
    *  CreatedDate     : 26/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public override Map<String, Object> returnNameFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('Name', this.externalCFCompany.tradeName);
		fieldsMap.put('Account', accountFieldsMap);

        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 21/10/2020 by Anton Buzak
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
            setRiskCategory();
            setRecommendedCreditLimit();
            setProfitLossLastYear();
            setProfitLossYearBeforeLast();
            setTurnOverLastYear();
            setYearOfLastFinancialInformation();
            setDateOfFoundation();
            setCalculationsForNewBusinessException(paymentDetailsSet);

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '7+7') {
                    this.creditLimit7Plus7 = calculateCreditLimit(7, 7);
                    this.securityLevel7Plus7 = calculateSecurityLevel(this.creditLimit7Plus7, 7, 7);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel7Plus7, this.creditLimit7Plus7, 7, 7, this.recommendedCreditLimit);
                    this.deposit7Plus7 = CreditFactoryGlobalUtils.roundDepositToTenThousands(this.deposit7Plus7);
                    this.maxCreditLimit7Plus7 = calculateMaxCreditLimit(this.creditLimit7Plus7, this.deposit7Plus7, 7, 7);
                    this.maxCreditLimit7Plus7 = CreditFactoryGlobalUtils.roundCreditLimitToTenThousands(this.maxCreditLimit7Plus7);
                    if (this.securityLevel7Plus7 != null) {
                        this.depositReason7plus7 = setDepositReason(this.securityLevel7Plus7, this.creditLimit7Plus7, 7, 7);
                    }
                }
                else if (paymentDetail == '15+14') {
                    this.creditLimit15Plus14 = calculateCreditLimit(15, 14);
                    this.securityLevel15Plus14 = calculateSecurityLevel(this.creditLimit15Plus14, 15, 14);
                    this.deposit15Plus14 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus14, this.creditLimit15Plus14, 15, 14, this.recommendedCreditLimit);
                    this.deposit15Plus14 = CreditFactoryGlobalUtils.roundDepositToTenThousands(this.deposit15Plus14);
                    this.maxCreditLimit15Plus14 = calculateMaxCreditLimit(this.creditLimit15Plus14, this.deposit15Plus14, 15, 14);
                    this.maxCreditLimit15Plus14 = CreditFactoryGlobalUtils.roundCreditLimitToTenThousands(this.maxCreditLimit15Plus14);
                    if (this.securityLevel15Plus14 != null) {
                        this.depositReason15plus14 = setDepositReason(this.securityLevel15Plus14, this.creditLimit15Plus14, 15, 14);
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
            cfResult.paymentMethodsSet = new List<String> {
                    'Direct Debit', 'Bank Transfer'
            };
            cfResult.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};

            cfResult.resultsList = this.resultsList;

            return cfResult;
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Scoring failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
		}
    }


    /*******************************************************************************
    *  Summary         : Set fuel price index
    *  CreatedDate     : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
		Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Hungary');
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setBuffer() {
        if (this.externalCFCompany.classRating == '0' || this.externalCFCompany.classRating == '1' ||
                this.externalCFCompany.classRating == '2' || this.externalCFCompany.classRating == '3') {
	        this.buffer = 0;
	    }
        else if (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5') {
	    	this.buffer = 0.1;
	    }
        else if (this.externalCFCompany.classRating == '6' || this.externalCFCompany.classRating == '7' || this.externalCFCompany.classRating == '8' ||
                this.externalCFCompany.classRating == '9' || this.externalCFCompany.classRating == '10') {
	    	this.buffer = 0.2;
	    }
        else if (this.externalCFCompany.classRating == '99') {
	    	this.buffer = 0.1;
	    }
    }


    /*******************************************************************************
    *  Summary         : Set Risk Category
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    protected override void setRiskCategory() {
        if (this.externalCFCompany.classRating == '0' || this.externalCFCompany.classRating == '1' ||
                this.externalCFCompany.classRating == '2' || this.externalCFCompany.classRating == '3') {
	        this.riskCategory = 'Very';
	    }
        else if (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5') {
	    	this.riskCategory = 'High';
	    }
        else if (this.externalCFCompany.classRating == '6' || this.externalCFCompany.classRating == '7' || this.externalCFCompany.classRating == '8' ||
                this.externalCFCompany.classRating == '9' || this.externalCFCompany.classRating == '10') {
	    	this.riskCategory = 'Medium';
	    }
        else if (this.externalCFCompany.classRating == '99') {
	    	this.riskCategory = 'High';
	    }
    }


    /*******************************************************************************
    *  Summary         : set recommended CL
    *  Created         : 21/10/2020 by Anton Buzak
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
    *  Summary         : set profit/loss for the last year
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setProfitLossLastYear() {
        if (this.externalCFCompany.profitLossLastYear != null) {
            this.profitLossLastYear = Decimal.valueOf(this.externalCFCompany.profitLossLastYear);
        }
    }


    /*******************************************************************************
    *  Summary         : set profit/loss for the year before last
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setProfitLossYearBeforeLast() {
        if (this.externalCFCompany.profitLossYearBeforeLast != null) {
            this.profitLossYearBeforeLast = Decimal.valueOf(this.externalCFCompany.profitLossYearBeforeLast);
        }
    }


    /*******************************************************************************
    *  Summary         : set turn over for the last year
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setTurnOverLastYear() {
        if (this.externalCFCompany.turnOverLastYear != null) {
            this.turnOverLastYear = Decimal.valueOf(this.externalCFCompany.turnOverLastYear);
        }
    }


    /*******************************************************************************
    *  Summary         : set year of last financial information
    *  Created         : 26/04/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setYearOfLastFinancialInformation() {
        if (this.externalCFCompany.yearOfLastFinancialInformation != null) {
            this.yearOfLastFinancialInformation = Decimal.valueOf(this.externalCFCompany.yearOfLastFinancialInformation);
        }
    }


    /*******************************************************************************
    *  Summary         : set date of foundation
    *  Created         : 03/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDateOfFoundation() {
        if (this.externalCFCompany.dateOfFoundation != null) {
            this.dateOfFoundation = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(6, 10)), Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(3, 5)),
                    Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(0, 2)));
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limit
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : credit limit
    ******************************************************************************/
    private Decimal calculateCreditLimit(Decimal billingPeriod, Decimal paymentTerms) {
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        Decimal buffer = (this.calculationsMap.get(paymentDetail).highRisk ? 0.1 : this.buffer);
        Decimal creditLimit = this.internalCFCompany.totalConsumption * this.fuelPriceIndex * ((billingPeriod + paymentTerms) / 30) * (1 + buffer);
        creditLimit = CreditFactoryGlobalUtils.roundCreditLimitToTenThousands(creditLimit);
        return creditLimit;
    }


    /*******************************************************************************
    *  Summary         : calculate security level
    *  Created         : 26/12/2019 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        String securityLevelForNewBusiness = this.calculationsMap.get(paymentDetail).securityLevel;
        if (securityLevelForNewBusiness == '*') {
            if (this.externalCFCompany.classRating == '0' || this.externalCFCompany.classRating == '1' ||
                    this.externalCFCompany.classRating == '2' || this.externalCFCompany.classRating == '3') {
                securityLevel = calculateSecurityLevelRating0_3();
            }
            else if (this.externalCFCompany.classRating == '4') {
                securityLevel = calculateSecurityLevelRating4(creditLimit);
            }
            else if (this.externalCFCompany.classRating == '5') {
                securityLevel = calculateSecurityLevelRating5(creditLimit);
            }
            else if (this.externalCFCompany.classRating == '6' || this.externalCFCompany.classRating == '7' ||
                    this.externalCFCompany.classRating == '8' || this.externalCFCompany.classRating == '9' ||
                    this.externalCFCompany.classRating == '10') {
                securityLevel = calculateSecurityLevelRating6_10(creditLimit);
            }
            else if (this.externalCFCompany.classRating == '99') {
                securityLevel = calculateSecurityLevelRating99();
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
    *  Summary         : calculate security level for ratings 0-3
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : security Level for Rating 0-3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating0_3() {
        Decimal securityLevel = 110;
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 4
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4(Decimal creditLimit) {
        Decimal securityLevel;
        if (! isPITValid(creditLimit)) {
            securityLevel = 100;
        }
        else if (this.yearOfLastFinancialInformation != null && Date.today().year() - this.yearOfLastFinancialInformation > 2) {
            securityLevel = 50;
        }
        else if (creditLimit > this.recommendedCreditLimit * 1.33) {
            securityLevel = 4;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5(Decimal creditLimit) {
        Decimal securityLevel;
        if (! isPITValid(creditLimit)) {
            securityLevel = 100;
        }
        else if (this.yearOfLastFinancialInformation != null && Date.today().year() - this.yearOfLastFinancialInformation > 2) {
            securityLevel = 50;
        }
        else if (creditLimit > this.recommendedCreditLimit * 1.33) {
            securityLevel = 4;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 6-10
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms
    *  Returns         : security Level for Ratings 6-10
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating6_10(Decimal creditLimit) {
        Decimal securityLevel;
        if (! isPITValid(creditLimit)) {
            securityLevel = 100;
        }
        else if (this.yearOfLastFinancialInformation != null && Date.today().year() - this.yearOfLastFinancialInformation > 2) {
            securityLevel = 50;
        }
        else if (creditLimit > this.recommendedCreditLimit * 1.33) {
            securityLevel = 4;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 99
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : security Level for Rating 99
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating99() {
        Decimal securityLevel = 100;
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level if it's a new business exception
    *  Created         : 16/06/2021 by Ivan Kulinkovich
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
    *  Created         : 16/06/2021 by Ivan Kulinkovich
    *  Parameters      : String paymentDetail, String calculationPaymentDetail
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
    *  Created         : 16/06/2021 by Ivan Kulinkovich
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
    *  Created         : 16/06/2021 by Ivan Kulinkovich
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
    *  Created         : 16/06/2021 by Ivan Kulinkovich
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
    *  Created         : 16/06/2021 by Ivan Kulinkovich
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
    *  Summary         : check if PIT is valid
    *  Created         : 18/02/2021 by Ivan Kulinkovich
    *  Parameters      : Decimal creditLimit
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isPITValid(Decimal creditLimit) {
        if ((this.profitLossLastYear == null || this.profitLossYearBeforeLast == null || this.turnOverLastYear == null ||
                this.profitLossLastYear < 0 || this.profitLossYearBeforeLast < 0 || this.turnOverLastYear * 0.1 < creditLimit) &&
                this.externalCFCompany.legalForm != 'Sole proprietorship' || this.externalCFCompany.legalForm == 'Sole proprietorship' &&
                this.internalCFCompany.totalConsumption > 800) {
            return false;
        }
        else {
            return true;
        }
    }


    /*******************************************************************************
    *  Summary         : calculate max CL
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max credit limit
    ******************************************************************************/
    private Decimal calculateMaxCreditLimit(Decimal creditLimit, Decimal deposit, Decimal billingPeriod, Decimal paymentTerms) {
        Decimal maxCreditLimit;
        if (deposit > 0) {
            maxCreditLimit = creditLimit;
        }
        else {
			if (creditLimit * 2 < 2500000) {
				maxCreditLimit = creditLimit * 2;
			}
			else {
				maxCreditLimit = 2500000;
			}

			if (maxCreditLimit > recommendedCreditLimit * 1.33) {
				maxCreditLimit = recommendedCreditLimit * 1.33;
			}

            String paymentDetail = billingPeriod + '+' + paymentTerms;
            CreditFactoryCompany.CreditFactoryCalculation calculation = this.calculationsMap.get(paymentDetail);
            if (calculation.totalConsumptionMaxValue != '*') {
                Decimal totalConsumption = Integer.valueOf(calculation.totalConsumptionMaxValue);
                Decimal buffer = (calculation.highRisk ? 0.1 : this.buffer);
                Decimal creditLimitMax = ((totalConsumption * this.fuelPriceIndex) * ((billingPeriod + paymentTerms) / 30.0) * (1.0 + buffer)).setScale(2);
                if (creditLimit * 2 < creditLimitMax) {
                    maxCreditLimit = creditLimit * 2;
                }
                else {
                    maxCreditLimit = creditLimitMax;
                }
            }
        }

        maxCreditLimit = CreditFactoryGlobalUtils.roundCreditLimitToTenThousands(maxCreditLimit);

        return maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : set deposit reason
    *  Created         : 18/02/2021 by Ivan Kulinkovich
    *  Parameters      : securityLevel - security level
                         creditLimit - credit limit
    *  Returns         : deposit reason
    ******************************************************************************/
    private String setDepositReason(Decimal securityLevel, Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
        String paymentDetail = billingPeriod + '+' + paymentTerms;
        String depositReason = this.calculationsMap.get(paymentDetail).depositReason;
        if (String.isEmpty(depositReason)) {
            depositReason = 'Low credit rating (rating ' + this.externalCFCompany.classRating + ')';
            if (securityLevel == 4) {
                depositReason = 'Low Recommended CL';
            }
            else if (securityLevel == 50) {
                depositReason = 'Missing financials';
            }
            else if (securityLevel != 110 && this.externalCFCompany.classRating != '99') {
                if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
                    depositReason = 'New business';
                }
                else if (! isPITValid(creditLimit)) {
                    depositReason = 'Low/no profitability';
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
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
        if (paymentDetailsSet.contains('15+14') && this.creditLimit15Plus14 < 2500000 && this.deposit15Plus14 == 0) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus14();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 2500000 && this.deposit7Plus7 == 0) {
            setDefaultValues7Plus7();
        }
        else if (paymentDetailsSet.contains('15+14') && this.creditLimit15Plus14 < 2500000) {
            if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7') {
                setDefaultValues7Plus7();
            }
            else {
                setDefaultValues15Plus14();
            }
        }
        else if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 2500000) {
            setDefaultValues7Plus7();
        }
    }


    /*******************************************************************************
    *  Summary         : set default values for 7+7
    *  Created         : 20/10/2020 by Anton Buzak
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
    *  Summary         : set default values for 15+14
    *  Created         : 20/10/2020 by Anton Buzak
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
        this.isNewBusinessException = this.calculationsMap.get('15+14').newBusinessException;
        this.riskCategory = (this.calculationsMap.get('15+14').highRisk ? 'High' : this.riskCategory);
    }


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 20/10/2020 by Anton Buzak
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
    *  Created         : 20/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMessages() {
        this.messagesList = new List<CreditFactoryResult.Message>();
        if (this.statusCode == '001') {
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Billing Period can be set to ' + this.billingPeriod));
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Payment Terms can be set to ' + this.paymentTerms));
            if (this.deposit > 0) {
                this.messagesList.add(new CreditFactoryResult.Message('info', '</br>Deposit to pay: ' + this.deposit + ' HUF.</br>' +
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
        if (this.statusCode == '004') {
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Requested limit too high. Please refer to credit.'));
        }
    }


    /*******************************************************************************
    *  Summary         : set available button (pending deposit, closed won etc)
    *  Created         : 21/10/2020 by Anton Buzak
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
                Boolean isClosedWonPossible;
                if (this.internalCFCompany.docuSignStatus == 'Completed' && this.internalCFCompany.totalConsumption <= 1500) {
                    Set<String> dsRecipientsNamesSet = new Set<String>();
                    if (this.internalCFCompany.documentsStatusesList != null) {
                        for (CreditFactoryCompany.DocumentStatus documentStatus : this.internalCFCompany.documentsStatusesList) {
                            if (documentStatus.documentRecipients != null) {
                                for (CreditFactoryCompany.DocumentRecipient recipient : documentStatus.documentRecipients) {
                                    dsRecipientsNamesSet.add(replaceSpecificCharacters(recipient.name.toUpperCase().replace('’', '\'')));
                                }
                            }
                        }
                    }

                    if (this.externalCFCompany.creditFactoryContacts != null) {
                        for (CreditFactoryCompany.CreditFactoryContact contact : this.externalCFCompany.creditFactoryContacts) {
                            if (dsRecipientsNamesSet.contains(replaceSpecificCharacters(contact.name.toUpperCase().replace('’', '\'')))) {
                                isClosedWonPossible = true;
                            }
                        }
                    }
                }
                
                if (isClosedWonPossible == true) {
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
    *  Created         : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList(Set<String> paymentDetailsSet) {
		this.resultsList = new List<CreditFactoryResult>();
        String riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);
        if (paymentDetailsSet.contains('15+14') && this.creditLimit15Plus14 < 2500000) {
			CreditFactoryResult result15Plus14 = new CreditFactoryResult();
			result15Plus14.verdict = 'Yes';
			result15Plus14.statusCode = '001';
			result15Plus14.billingPeriod = '15';
			result15Plus14.paymentTerms = '14';
			result15Plus14.creditLimit = this.creditLimit15Plus14;
			result15Plus14.securityLevel = this.securityLevel15Plus14;
			result15Plus14.deposit = this.deposit15Plus14;
            result15Plus14.depositReason = this.depositReason15plus14;
			result15Plus14.maxCreditLimit = this.maxCreditLimit15Plus14;
			result15Plus14.riskCategory = (this.calculationsMap.get('15+14').highRisk ? 'High' : riskCategory);
            result15Plus14.classRating = (this.calculationsMap.get('15+14').newBusinessException ? '0-EX' : this.externalCFCompany.classRating);
			result15Plus14.paymentMethodsSet = new List<String> {'Direct Debit', 'Bank Transfer'};
			result15Plus14.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
			if (this.billingPeriod == result15Plus14.billingPeriod && this.paymentTerms == result15Plus14.paymentTerms) {
				result15Plus14.isDefault = true;
			}

			this.resultsList.add(result15Plus14);
		}

		if (paymentDetailsSet.contains('7+7') && this.creditLimit7Plus7 < 2500000) {
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
            result7Plus7.paymentMethodsSet = new List<String>{'Direct Debit', 'Bank Transfer'};
            result7Plus7.invoicesSet = new List<String>{
                    'e-Invoicing', 'Paper Invoice'
            };
            if (this.billingPeriod == result7Plus7.billingPeriod && this.paymentTerms == result7Plus7.paymentTerms) {
                result7Plus7.isDefault = true;
            }

            this.resultsList.add(result7Plus7);
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
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(this.externalCFCompany.creditSystemCompanyNumber, null, opportunityId, null, this.externalCFCompany.country);
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