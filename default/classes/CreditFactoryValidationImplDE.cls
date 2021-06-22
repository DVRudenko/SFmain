public class CreditFactoryValidationImplDE extends CreditFactoryValidationImpl {


    /*******************************************************************************
    *  Summary         : return Name of Credit System
    *  Created         : 10/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'Schufa';
    }

    /*******************************************************************************
    *  Summary         : Check desired Billing period and desire Payment terms
    *  CreatedDate     : 10/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateDesiredPaymentDetails() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '30' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '30' && this.internalCFCompany.desiredPaymentTerms == '10') {
            validationItem.passed = true;
        }

        if (validationItem.passed == null) {
            validationItem.passed = false;
            validationItem.description = 'Desired Billing Period and Desired Payment terms are not available. Available options are: 30+10, 30+7, 15+7, 7+7.';
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check Opportunity "Processed by" field
    *  CreatedDate     : 08/05/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateOrder() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.cfStage == 'Pending Credit Report - Order was sent') {
            validationItem.passed = false;
            validationItem.description = 'Order request already sent.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Check Mandate Type
	*  CreatedDate     : 11/08/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected override CreditFactoryValidationItem validateMandateType() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.paymentMethod == 'Lastschrift' && this.internalCFCompany.directDebitMandateType == 'Core') {
            String riskCategory;
            if (this.externalCFCompany.classRating == '1' || this.externalCFCompany.classRating == '2') {
                riskCategory = 'Low';
            }
            else if (this.externalCFCompany.classRating == '3') {
                riskCategory = 'Medium';
            }
            else if (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5') {
                riskCategory = 'High';
            }
            else if (this.externalCFCompany.classRating == '6') {
                riskCategory = 'Very';
            }

            String appropriateMandateType = CreditFactoryGlobalUtils.returnAppropriateMandateType(this.internalCFCompany.country,
                                                                                                          riskCategory,
                                                                                          this.internalCFCompany.totalConsumption);

            if (appropriateMandateType == 'B2B') {
                validationItem.passed = false;
                validationItem.description = 'Please change the Direct Debit Type Mandate from Core to B2B because the Customer has high Credit risk.';
            }
            else {
                validationItem.passed = true;
            }
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : replace country specific characters
    *  Created         : 11/0
    *  Parameters      : -
    *  Returns         : string without country specific characters
    ******************************************************************************/
    protected override String replaceSpecificCharacters(String stringToReplace) {
        if (stringToReplace != null) {
            if (stringToReplace.contains('Ä')) stringToReplace = stringToReplace.replace('Ä', 'AE');
            if (stringToReplace.contains('ä')) stringToReplace = stringToReplace.replace('ä', 'ae');
            if (stringToReplace.contains('Ö')) stringToReplace = stringToReplace.replace('Ö', 'OE');
            if (stringToReplace.contains('ö')) stringToReplace = stringToReplace.replace('ö', 'oe');
            if (stringToReplace.contains('Ü')) stringToReplace = stringToReplace.replace('Ü', 'UE');
            if (stringToReplace.contains('ü')) stringToReplace = stringToReplace.replace('ü', 'ue');
            // "ß" cannot be capital
            if (stringToReplace.contains('ß')) stringToReplace = stringToReplace.replace('ß', 'ss');
        }

        return stringToReplace;
    }
}