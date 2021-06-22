public virtual class CreditFactoryValidationImplCZ extends CreditFactoryValidationImpl {


    /*******************************************************************************
    *  Summary         : return Name of Credit System
    *  Created         : 28/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'Cribis';
    }

    /*******************************************************************************
    *  Summary         : Check desired Billing period and desire Payment terms
    *  CreatedDate     : 28/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected virtual override CreditFactoryValidationItem validateDesiredPaymentDetails() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '10') {
            validationItem.passed = true;
        }

        if (validationItem.passed == null) {
            validationItem.passed = false;
            validationItem.description = 'Desired Billing Period and Desired Payment terms are not available. Available options are: 15+10, 7+7.';
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check Payment Method
    *  CreatedDate     : 28/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validatePaymentMethod() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        Date dateOfFoundation;
        if (this.externalCFCompany.dateOfFoundation != null) {
			dateOfFoundation = Date.newInstance(Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(0, 4)), Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(5, 7)),
				Integer.valueOf(this.externalCFCompany.dateOfFoundation.substring(8, 10)));
		}

    	if (this.internalCFCompany.paymentMethod == 'Banküberweisung' &&
                (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5' ||
                dateOfFoundation != null && dateOfFoundation.monthsBetween(Date.today()) <= 18 &&
                this.internalCFCompany.totalConsumption <= 300 && Integer.valueOf(this.internalCFCompany.numberOfCards) <= 1 ||
                this.externalCFCompany.numberOfExecutions != null && this.externalCFCompany.numberOfExecutions > 0)) {
            validationItem.passed = false;
            validationItem.description = 'Opportunity cannot be closed automatically with Payment Method Bank Transfer.';
    	}
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Compare Credit System and Salesforce trade register numbers
	*  CreatedDate     : 04/12/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
	protected override CreditFactoryValidationItem validateTradeRegisterNumber() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        String externalTradeRegisterInfo = (externalCFCompany.tradeRegisterNumber != null ? externalCFCompany.tradeRegisterNumber : '') + ' ' + (externalCFCompany.countyCourt != null ? externalCFCompany.countyCourt : '');
        String internalTradeRegisterInfo = (internalCFCompany.tradeRegisterNumber != null ? internalCFCompany.tradeRegisterNumber : '') + ' ' + (internalCFCompany.countyCourt != null ? internalCFCompany.countyCourt : '');
		if (! areStringsEquals(externalTradeRegisterInfo, internalTradeRegisterInfo)) {
            validationItem.passed = false;
            validationItem.description = 'Account Trade Register Number and ' + returnCreditSystemName() + ' Trade Register Number mismatch.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
	}
}