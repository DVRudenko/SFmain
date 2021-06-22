public class CreditFactoryImplSKCCS extends CreditFactoryImplSK {
    private Decimal monthlyCardsLimit;
    private Date dateOfLastRequest;


    /*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 07/06/2020 by Ivan Kulinkovich
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
            else if (validationItemsMap.containsKey('NegativeInformation') && validationItemsMap.get('NegativeInformation').passed == false) {
                cfResult.verdict = 'No';
                cfResult.statusCode = '016';
                return cfResult;
            }

            setFuelPriceIndex();
            setDateOfFoundation();
            setDateOfLastRequest();
            setMonthlyCardsLimit();
            setBuffer();
            setRecommendedCreditLimit();

            this.validationItemsMap = validationItemsMap;

            for (String paymentDetail : paymentDetailsSet) {
                if (paymentDetail == '15+2') {
                    this.creditLimit15Plus2 = calculateCreditLimit(15, 2);
                    this.securityLevel15Plus2 = calculateSecurityLevel();
                    this.deposit15Plus2 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus2, this.monthlyCardsLimit, 15, 2, this.recommendedCreditLimit);
                    this.deposit15Plus2 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus2);
                    if (this.securityLevel15Plus2 != null) {
                        this.depositReason15Plus2 = setDepositReason(this.securityLevel15Plus2);
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
            cfResult.availableButtonsList = this.availableButtonsList;
            cfResult.riskCategory = this.riskCategory;
            cfResult.paymentMethodsSet = new List<String>{
                    'Direct Debit'
            };
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
    *  CreatedDate     : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
        Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Slovakia');
        this.fuelPriceIndex = fuelPrice.Index__c;
    }


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setBuffer() {
        String offerCategory = returnOfferCategoryBasedOnFinancials();
        if (this.externalCFCompany.classRating == '5' || offerCategory == 'E') {
            this.buffer = 0;
        }
        else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == null ||
                this.externalCFCompany.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18 ||
                offerCategory == 'C' || offerCategory == 'D') {
            this.buffer = 0.1;
        }
        else if (this.externalCFCompany.classRating == '2' || offerCategory == 'B') {
            this.buffer = 0.2;
        }
        else if (this.externalCFCompany.classRating == '1') {
            this.buffer = 0.3;
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate credit limit
    *  Created         : 07/06/2020 by Ivan Kulinkovich
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
    *  Created         : 07/06/2020 by Ivan Kulinkovich
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
    *  Created         : 07/06/2020 by Ivan Kulinkovich
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
    *  Summary         : set date of last financial request
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDateOfLastRequest() {
        if (this.externalCFCompany.dateOfLastRequest != null) {
            this.dateOfLastRequest = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfLastRequest.substring(0, 4)), Integer.valueOf(this.externalCFCompany.dateOfLastRequest.substring(5, 7)),
                    Integer.valueOf(this.externalCFCompany.dateOfLastRequest.substring(8, 10)));
        }
    }


    /*******************************************************************************
    *  Summary         : set monthly cards limit
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMonthlyCardsLimit() {
        this.monthlyCardsLimit = 0;
        if (this.internalCFCompany.offerItems != null) {
            for (CreditFactoryCompany.OfferItem offerItem : this.internalCFCompany.offerItems) {
                if (offerItem.monthlyCardLimit != null) {
                    this.monthlyCardsLimit += offerItem.monthlyCardLimit;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : calculate security level
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
                         billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel() {
        Decimal securityLevel;
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
            securityLevel = calculateSecurityLevelRating4();
        }
        else if (this.externalCFCompany.classRating == '5') {
            securityLevel = calculateSecurityLevelRating5();
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
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1() {
        Decimal securityLevel;
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException()) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'D') {
            securityLevel = 100;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 2
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2() {
        Decimal securityLevel;
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException()) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'D') {
            securityLevel = 100;
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 3
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3() {
        Decimal securityLevel;
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException()) {
                securityLevel = null;
            }
            else {
                securityLevel = 100;
            }
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'D') {
            securityLevel = 100;
        }
        else {
            securityLevel = 25;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 4
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4() {
        Decimal securityLevel;
        if (isNewBusinessException()) {
            securityLevel = null;
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'E') {
            securityLevel = 200;
        }
        else {
            securityLevel = 100;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
        Decimal securityLevel = 200;
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for no rating
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : security Level for No Rating
    ******************************************************************************/
    private Decimal calculateSecurityLevelNoRating() {
        Decimal securityLevel;
        if (isNewBusinessException()) {
            securityLevel = null;
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'E') {
            securityLevel = 200;
        }
        else {
            securityLevel = 100;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : Check if it's a new business exception
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : Decimal billingPeriod,
    					 Decimal paymentTerms
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean isNewBusinessException() {
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18 &&
                this.monthlyCardsLimit <= 800 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2) {
            this.isNewBusinessException = true;
            return true;
        }

        return false;
    }


    /*******************************************************************************
    *  Summary         : return risk category based on financials
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String returnOfferCategoryBasedOnFinancials() {
        String offerCategory;
        if (this.externalCFCompany.financialSituation != 'Not rated' && this.dateOfLastRequest != null) {
            Date lastFinancialDate = Date.newInstance(Date.today().year() - 2, 12, 31);
            if (soloTradersSet.contains(this.externalCFCompany.legalForm) && this.dateOfLastRequest < lastFinancialDate) {
                if (Integer.valueOf(this.internalCFCompany.numberOfCards) <= 5 && this.monthlyCardsLimit <= 2000) {
                    if (this.externalCFCompany.classRating == '1' || this.externalCFCompany.classRating == '2') {
                        offerCategory = 'C';
                    }
                    else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == null) {
                        offerCategory = 'D';
                    }
                    else if (this.externalCFCompany.classRating == '5') {
                        offerCategory = 'E';
                    }
                }
                else if (this.externalCFCompany.classRating != '5') {
                    offerCategory = 'D';
                }
            }
        }

        if (this.externalCFCompany.financialSituation == 'Not rated') {
            if (Integer.valueOf(this.internalCFCompany.numberOfCards) <= 5 && this.monthlyCardsLimit <= 2000) {
                if (this.externalCFCompany.classRating == '1' || this.externalCFCompany.classRating == '2') {
                    offerCategory = 'B';
                }
            }
            else if (this.externalCFCompany.classRating != '5') {
                offerCategory = 'D';
            }
        }

        return offerCategory;
    }


    /*******************************************************************************
    *  Summary         : set deposit reason
    *  Created         : 07/06/2020 by Ivan Kulinkovich
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

        if (this.externalCFCompany.classRating != '5') {
            if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
                depositReason = 'New business';
            }
            else if (this.externalCFCompany.financialSituation == 'Not rated' || this.dateOfLastRequest != null &&
                    this.dateOfLastRequest < Date.newInstance(Date.today().year() - 2, 12, 31)) {
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
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails(Set<String> paymentDetailsSet) {
        if (paymentDetailsSet.contains('15+2') && this.monthlyCardsLimit <= 4000 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 10) {
            setDefaultValues15Plus2();
        }
    }


    /*******************************************************************************
    *  Summary         : set default values for 15+2
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues15Plus2() {
        this.billingPeriod = '15';
        this.paymentTerms = '2';
        this.creditLimit = this.creditLimit15Plus2;
        this.securityLevel = this.securityLevel15Plus2;
        this.deposit = this.deposit15Plus2;
        this.depositReason = this.depositReason15Plus2;
    }


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDecision() {
        if (this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0) {
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
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMessages() {
        this.messagesList = new List<CreditFactoryResult.Message>();
        if (this.statusCode == '001') {
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Billing Period can be set to ' + this.billingPeriod));
            this.messagesList.add(new CreditFactoryResult.Message('info', 'Payment Terms can be set to ' + this.paymentTerms));
            if (this.deposit > 0) {
                this.messagesList.add(new CreditFactoryResult.Message('info', '</br>Deposit to pay: ' + this.deposit + ' CZK.</br>' +
                        'Deposit reason: ' + this.depositReason + '</br></br>' +
                        'You can update Desired Payment Terms and Desired Billing Period in the Opportunit and restart Credit Factory to recalculate the deposit amount.'));
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
            this.messagesList.add(new CreditFactoryResult.Message('error', 'Hit on executions, rejected'));
        }
    }


    /*******************************************************************************
    *  Summary         : set available button (pending deposit, closed won etc)
    *  Created         : 07/06/2020 by Ivan Kulinkovich
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
                this.availableButtonsList.add('Closed Won');
            }
        }
    }


    /*******************************************************************************
    *  Summary         : set results list
    *  Created         : 07/06/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList(Set<String> paymentDetailsSet) {
        this.resultsList = new List<CreditFactoryResult>();
        if (this.monthlyCardsLimit <= 4000 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 10) {
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
            cfResult.paymentMethodsSet = new List<String> {'Direct Debit'};
            cfResult.invoicesSet = new List<String> {'e-Invoicing', 'Paper Invoice'};
            cfResult.isDefault = true;

            this.resultsList.add(cfResult);

        }
    }


    public static Set<String> soloTradersSet = new Set<String> {
            'Limited liability company',
            'Joint stock company'
    };
}