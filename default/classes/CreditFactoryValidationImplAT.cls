public class CreditFactoryValidationImplAT extends CreditFactoryValidationImpl {

    
    /*******************************************************************************
    *  Summary         : return Name of Credit System
    *  Created         : 08/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'Creditreform';
    }
    
    
    /*******************************************************************************
    *  Summary         : Check order validation
    *  CreatedDate     : 10/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateOrder() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.cfStage == 'Pending Credit Report - Order was sent' ||
                this.internalCFCompany.cfStage == 'Pending Credit Report - Additional information was sent') {
            validationItem.passed = false;
            validationItem.description = 'Order request already sent.';
        }
        else if (String.isEmpty(this.internalCFCompany.registeredCity) || String.isEmpty(this.internalCFCompany.registeredPostCode)) {
            validationItem.passed = false;
            validationItem.description = 'Please fill Billing City and Billing Postal Code to do order request.';
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
            else if (this.externalCFCompany.classRating == '4' || this.externalCFCompany.classRating == '5' || this.externalCFCompany.classRating == null) {
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
}