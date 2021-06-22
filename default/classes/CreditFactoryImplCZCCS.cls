public class CreditFactoryImplCZCCS extends CreditFactoryImplCZ {
    private Decimal monthlyCardsLimit;
    private Date dateOfLastRequest;


    /*******************************************************************************
    *  Summary         : Calculate credit limits, deposit etc.
    *  CreatedDate     : 14/05/2020 by Ivan Kulinkovich
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
                if (paymentDetail == '7+2') {
                    this.creditLimit7Plus2 = calculateCreditLimit(7, 2);
                    this.securityLevel7Plus2 = calculateSecurityLevel(this.creditLimit30Plus2, 7, 2);
                    this.deposit7Plus2 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel7Plus2, this.monthlyCardsLimit, 7, 2, this.recommendedCreditLimit);
                    this.deposit7Plus2 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit7Plus2);
                    if (this.securityLevel7Plus2 != null) {
                        this.depositReason7Plus2 = setDepositReason(this.securityLevel7Plus2);
                    }
                } else if (paymentDetail == '15+2') {
                    this.creditLimit15Plus2 = calculateCreditLimit(15, 2);
                    this.securityLevel15Plus2 = calculateSecurityLevel(this.creditLimit30Plus2, 15, 2);
                    this.deposit15Plus2 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel15Plus2, this.monthlyCardsLimit, 15, 2, this.recommendedCreditLimit);
                    this.deposit15Plus2 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit15Plus2);
                    if (this.securityLevel15Plus2 != null) {
                        this.depositReason15Plus2 = setDepositReason(this.securityLevel15Plus2);
                    }
                }
                else if (paymentDetail == '30+2') {
                    this.creditLimit30Plus2 = calculateCreditLimit(30, 2);
                    this.securityLevel30Plus2 = calculateSecurityLevel(this.creditLimit30Plus2, 30, 2);
                    this.deposit30Plus2 = CreditFactoryGlobalUtils.returnDepositValue(this.securityLevel30Plus2, this.monthlyCardsLimit, 30, 2, this.recommendedCreditLimit);
                    this.deposit30Plus2 = CreditFactoryGlobalUtils.roundDepositToHundreds(this.deposit30Plus2);
                    if (this.securityLevel30Plus2 != null) {
                        this.depositReason30Plus2 = setDepositReason(this.securityLevel30Plus2);
                    }
                }
            }

            this.riskCategory = CreditFactoryGlobalUtils.returnRiskCategory(this.buffer);

            setCreditDecisionToShow();
            setDefaultPaymentDetails();
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
    *  CreatedDate     : 14/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setFuelPriceIndex() {
        Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Czech Republic');
        this.fuelPriceIndex = fuelPrice.Index__c;
    }


    /*******************************************************************************
    *  Summary         : Set buffer
    *  Created         : 14/05/2021 by Ivan Kulinkovich
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
    *  Created         : 14/05/2021 by Ivan Kulinkovich
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
    *  Created         : 14/05/2021 by Ivan Kulinkovich
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
    *  Created         : 14/05/2021 by Ivan Kulinkovich
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
    *  Created         : 20/05/2021 by Ivan Kulinkovich
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
    *  Created         : 14/05/2021 by Ivan Kulinkovich
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
    *  Created         : 17/05/2021 by Ivan Kulinkovich
    *  Parameters      : creditLimit - credit limit for some billing period + payment terms,
                         billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : Security Level
    ******************************************************************************/
    private Decimal calculateSecurityLevel(Decimal creditLimit, Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        if (this.externalCFCompany.classRating == '1') {
            securityLevel = calculateSecurityLevelRating1(billingPeriod, paymentTerms);
        }
        else if (this.externalCFCompany.classRating == '2') {
            securityLevel = calculateSecurityLevelRating2(billingPeriod, paymentTerms);
        }
        else if (this.externalCFCompany.classRating == '3') {
            securityLevel = calculateSecurityLevelRating3(billingPeriod, paymentTerms);
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
    *  Created         : 17/05/2021 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 1
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating1(Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else if (billingPeriod == 7 && paymentTerms == 2) {
                securityLevel = 50;
            }
            else {
                securityLevel = 100;
            }
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'D') {
            if (billingPeriod == 7 && paymentTerms == 2) {
                securityLevel = 50;
            }
            else {
                securityLevel = 100;
            }
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 2
    *  Created         : 17/05/2021 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
						 paymentTerms - payment terms
    *  Returns         : security Level for Rating 2
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating2(Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else if (billingPeriod == 7 && paymentTerms == 2) {
                securityLevel = 50;
            }
            else {
                securityLevel = 100;
            }
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'D') {
            if (billingPeriod == 7 && paymentTerms == 2) {
                securityLevel = 50;
            }
            else {
                securityLevel = 100;
            }
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 3
    *  Created         : 17/05/2021 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : security Level for Rating 3
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating3(Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        if (this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if (isNewBusinessException(billingPeriod, paymentTerms)) {
                securityLevel = null;
            }
            else if (billingPeriod == 7 && paymentTerms == 2) {
                securityLevel = 50;
            }
            else {
                securityLevel = 100;
            }
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'D') {
            if (billingPeriod == 7 && paymentTerms == 2) {
                securityLevel = 50;
            }
            else {
                securityLevel = 100;
            }
        }
        else {
            securityLevel = null;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 4
    *  Created         : 17/05/2021 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : security Level for Rating 4
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating4(Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        if (isNewBusinessException(billingPeriod, paymentTerms)) {
            securityLevel = null;
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'E') {
            securityLevel = 200;
        }
        else if (billingPeriod == 7 && paymentTerms == 2) {
            securityLevel = 50;
        }
        else {
            securityLevel = 100;
        }

        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for rating 5
    *  Created         : 17/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : security Level for Rating 5
    ******************************************************************************/
    private Decimal calculateSecurityLevelRating5() {
        Decimal securityLevel = 200;
        return securityLevel;
    }


    /*******************************************************************************
    *  Summary         : calculate security level for no rating
    *  Created         : 17/05/2021 by Ivan Kulinkovich
    *  Parameters      : billingPeriod - billing period,
                         paymentTerms - payment terms
    *  Returns         : security Level for No Rating
    ******************************************************************************/
    private Decimal calculateSecurityLevelNoRating(Decimal billingPeriod, Decimal paymentTerms) {
        Decimal securityLevel;
        if (isNewBusinessException(billingPeriod, paymentTerms)) {
            securityLevel = null;
        }
        else if (returnOfferCategoryBasedOnFinancials() == 'E') {
            securityLevel = 200;
        }
        else if (billingPeriod == 7 && paymentTerms == 2) {
            securityLevel = 50;
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
                this.monthlyCardsLimit <= 20000 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 2 &&
                (billingPeriod == 7 && paymentTerms == 2 || billingPeriod == 15 && paymentTerms == 2)) {
            this.isNewBusinessException = true;
            return true;
        }

        return false;
    }


    /*******************************************************************************
    *  Summary         : return risk category based on financials
    *  Created         : 20/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String returnOfferCategoryBasedOnFinancials() {
        String offerCategory;
        if (this.externalCFCompany.financialSituation != 'Not rated' && this.dateOfLastRequest != null) {
            Date lastFinancialDate = Date.newInstance(Date.today().year() - 2, 12, 31);
            if (soloTradersSet.contains(this.externalCFCompany.legalForm) && this.dateOfLastRequest < lastFinancialDate) {
                if (Integer.valueOf(this.internalCFCompany.numberOfCards) <= 5 && this.monthlyCardsLimit <= 50000) {
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
            if (Integer.valueOf(this.internalCFCompany.numberOfCards) <= 5 && this.monthlyCardsLimit <= 50000) {
                if (this.externalCFCompany.classRating == '1') {
                    offerCategory = 'B';
                }
                else if (this.externalCFCompany.classRating == '2') {
                    offerCategory = 'C';
                }
                else if (this.externalCFCompany.classRating == '3') {
                    offerCategory = 'D';
                }
            }
            else if (this.externalCFCompany.classRating != '5') {
                offerCategory = 'D';
            }
        }

        return offerCategory;
    }


    /*******************************************************************************
    *  Summary         : set Credit Decision to show on E2E
    *  Created         : 15/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setCreditDecisionToShow() {
        String offerCategory = returnOfferCategoryBasedOnFinancials();
        if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == null ||
                this.dateOfFoundation != null && this.dateOfFoundation.monthsBetween(Date.today()) <= 18 && this.externalCFCompany.classRating != '5' ||
                offerCategory == 'C' || offerCategory == 'D') {
            this.creditDecisionToShow.put('30+2', false);
        }
        else if (this.externalCFCompany.classRating == '5') {
            this.creditDecisionToShow.put('30+2', false);
            this.creditDecisionToShow.put('7+2', false);
        }
    }


    /*******************************************************************************
    *  Summary         : set deposit reason
    *  Created         : 17/05/2021 by Ivan Kulinkovich
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
    *  Created         : 15/05/2021 by Ivan Kulinkovich
    *  Parameters      : paymentDetailsSet - possible payment details set
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultPaymentDetails() {
        if (this.monthlyCardsLimit <= 100000 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 10) {
            if (this.creditDecisionToShow.get('30+2')) {
                setDefaultValues30Plus2();
            }
            else if (this.creditDecisionToShow.get('15+2')) {
                setDefaultValues15Plus2();
            }
            else {
                setDefaultValues7Plus2();
            }
        }
    }


    /*******************************************************************************
    *  Summary         : set default values for 7+2
    *  Created         : 15/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues7Plus2() {
        this.billingPeriod = '7';
        this.paymentTerms = '2';
        this.creditLimit = this.creditLimit7Plus2;
        this.securityLevel = this.securityLevel7Plus2;
        this.deposit = this.deposit7Plus2;
        this.depositReason = this.depositReason7Plus2;
    }


    /*******************************************************************************
    *  Summary         : set default values for 15+2
    *  Created         : 15/05/2021 by Ivan Kulinkovich
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
    *  Summary         : set default values for 30+2
    *  Created         : 15/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDefaultValues30Plus2() {
        this.billingPeriod = '30';
        this.paymentTerms = '2';
        this.creditLimit = this.creditLimit30Plus2;
        this.securityLevel = this.securityLevel30Plus2;
        this.deposit = this.deposit30Plus2;
        this.depositReason = this.depositReason30Plus2;
    }


    /*******************************************************************************
    *  Summary         : set decision
    *  Created         : 15/05/2021 by Ivan Kulinkovich
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
    *  Created         : 17/05/2021 by Ivan Kulinkovich
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
    *  Created         : 17/05/2021 by Ivan Kulinkovich
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
    *  Created         : 15/05/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setResultsList(Set<String> paymentDetailsSet) {
        this.resultsList = new List<CreditFactoryResult>();
        if (this.monthlyCardsLimit <= 100000 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 10) {
            if (paymentDetailsSet.contains('30+2') && this.creditDecisionToShow.get('30+2')) {
                CreditFactoryResult result30Plus2 = new CreditFactoryResult();
                result30Plus2.verdict = 'Yes';
                result30Plus2.statusCode = '001';
                result30Plus2.billingPeriod = '30';
                result30Plus2.paymentTerms = '2';
                result30Plus2.creditLimit = this.creditLimit30Plus2;
                result30Plus2.securityLevel = this.securityLevel30Plus2;
                result30Plus2.deposit = this.deposit30Plus2;
                result30Plus2.depositReason = this.depositReason30Plus2;
                result30Plus2.riskCategory = this.riskCategory;
                result30Plus2.classRating = (this.isNewBusinessException == true ? '0-EX' : this.externalCFCompany.classRating);
                result30Plus2.paymentMethodsSet = new List<String>{
                        'Direct Debit'
                };
                result30Plus2.invoicesSet = new List<String>{
                        'e-Invoicing', 'Paper Invoice'
                };
                if (this.billingPeriod == result30Plus2.billingPeriod && this.paymentTerms == result30Plus2.paymentTerms) {
                    result30Plus2.isDefault = true;
                }

                this.resultsList.add(result30Plus2);
            }

            if (paymentDetailsSet.contains('15+2') && this.creditDecisionToShow.get('15+2')) {
                CreditFactoryResult result15Plus2 = new CreditFactoryResult();
                result15Plus2.verdict = 'Yes';
                result15Plus2.statusCode = '001';
                result15Plus2.billingPeriod = '15';
                result15Plus2.paymentTerms = '2';
                result15Plus2.creditLimit = this.creditLimit15Plus2;
                result15Plus2.securityLevel = this.securityLevel15Plus2;
                result15Plus2.deposit = this.deposit15Plus2;
                result15Plus2.depositReason = this.depositReason15Plus2;
                result15Plus2.riskCategory = this.riskCategory;
                result15Plus2.classRating = (this.isNewBusinessException == true ? '0-EX' : this.externalCFCompany.classRating);
                result15Plus2.paymentMethodsSet = new List<String>{
                        'Direct Debit'
                };
                result15Plus2.invoicesSet = new List<String>{
                        'e-Invoicing', 'Paper Invoice'
                };
                if (this.billingPeriod == result15Plus2.billingPeriod && this.paymentTerms == result15Plus2.paymentTerms) {
                    result15Plus2.isDefault = true;
                }

                this.resultsList.add(result15Plus2);
            }

            if (paymentDetailsSet.contains('7+2') && this.creditDecisionToShow.get('7+2')) {
                CreditFactoryResult result7Plus2 = new CreditFactoryResult();
                result7Plus2.verdict = 'Yes';
                result7Plus2.statusCode = '001';
                result7Plus2.billingPeriod = '7';
                result7Plus2.paymentTerms = '2';
                result7Plus2.creditLimit = this.creditLimit7Plus2;
                result7Plus2.securityLevel = this.securityLevel7Plus2;
                result7Plus2.deposit = this.deposit7Plus2;
                result7Plus2.depositReason = this.depositReason7Plus2;
                result7Plus2.riskCategory = this.riskCategory;
                result7Plus2.classRating = (this.isNewBusinessException == true ? '0-EX' : this.externalCFCompany.classRating);
                result7Plus2.paymentMethodsSet = new List<String>{
                        'Direct Debit'
                };
                result7Plus2.invoicesSet = new List<String>{
                        'e-Invoicing', 'Paper Invoice'
                };
                if (this.billingPeriod == result7Plus2.billingPeriod && this.paymentTerms == result7Plus2.paymentTerms) {
                    result7Plus2.isDefault = true;
                }

                this.resultsList.add(result7Plus2);
            }
        }

    }


    private Map<String, Boolean> creditDecisionToShow = new Map<String, Boolean> {
            '7+2' => true,
            '15+2' => true,
            '30+2' => true
    };


    public static Set<String> soloTradersSet = new Set<String> {
            'Limited liability company',
            'Joint stock company'
    };
}