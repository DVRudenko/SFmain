public class CreditFactoryValidationImplBE extends CreditFactoryValidationImpl {


    /*******************************************************************************
    *  Summary         : return Name of Credit System
    *  Created         : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'CreditSafe';
    }


    /*******************************************************************************
    *  Summary         : Check desired Billing period and desire Payment terms
    *  CreatedDate     : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateDesiredPaymentDetails() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '30' && this.internalCFCompany.desiredPaymentTerms == '7') {
            validationItem.passed = true;
        }

        if (validationItem.passed == null) {
            validationItem.passed = false;
            validationItem.description = 'Desired Billing Period and Desired Payment terms are not available. Available options are: 30+7, 15+7, 7+7.';
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : replace country specific characters
    *  Created         : 17/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : string without country specific characters
    ******************************************************************************/
    protected override String replaceSpecificCharacters(String stringToReplace) {
        if (stringToReplace != null) {
            // Dutch
            if (stringToReplace.contains('Á')) stringToReplace = stringToReplace.replace('Á', 'A');
            if (stringToReplace.contains('á')) stringToReplace = stringToReplace.replace('á', 'a');
            if (stringToReplace.contains('Í')) stringToReplace = stringToReplace.replace('Í', 'I');
            if (stringToReplace.contains('í')) stringToReplace = stringToReplace.replace('í', 'i');
            if (stringToReplace.contains('Ó')) stringToReplace = stringToReplace.replace('Ó', 'O');
            if (stringToReplace.contains('ó')) stringToReplace = stringToReplace.replace('ó', 'o');
            if (stringToReplace.contains('Ú')) stringToReplace = stringToReplace.replace('Ú', 'U');
            if (stringToReplace.contains('ú')) stringToReplace = stringToReplace.replace('ú', 'u');
            if (stringToReplace.contains('Ö')) stringToReplace = stringToReplace.replace('Ö', 'O');
            if (stringToReplace.contains('ö')) stringToReplace = stringToReplace.replace('ö', 'o');
            // French
            if (stringToReplace.contains('Ç')) stringToReplace = stringToReplace.replace('Ç', 'C');
            if (stringToReplace.contains('ç')) stringToReplace = stringToReplace.replace('ç', 'c');
            if (stringToReplace.contains('Â')) stringToReplace = stringToReplace.replace('Â', 'A');
            if (stringToReplace.contains('â')) stringToReplace = stringToReplace.replace('â', 'a');
            if (stringToReplace.contains('Ê')) stringToReplace = stringToReplace.replace('Ê', 'E');
            if (stringToReplace.contains('ê')) stringToReplace = stringToReplace.replace('ê', 'e');
            if (stringToReplace.contains('Î')) stringToReplace = stringToReplace.replace('Î', 'I');
            if (stringToReplace.contains('î')) stringToReplace = stringToReplace.replace('î', 'i');
            if (stringToReplace.contains('Ô')) stringToReplace = stringToReplace.replace('Ô', 'O');
            if (stringToReplace.contains('ô')) stringToReplace = stringToReplace.replace('ô', 'o');
            if (stringToReplace.contains('Û')) stringToReplace = stringToReplace.replace('Û', 'U');
            if (stringToReplace.contains('û')) stringToReplace = stringToReplace.replace('û', 'u');
            if (stringToReplace.contains('Ù')) stringToReplace = stringToReplace.replace('Ù', 'U');
            if (stringToReplace.contains('Ë')) stringToReplace = stringToReplace.replace('Ë', 'E');
            if (stringToReplace.contains('ë')) stringToReplace = stringToReplace.replace('ë', 'e');
            // Dutch & French both
            if (stringToReplace.contains('É')) stringToReplace = stringToReplace.replace('É', 'E');
            if (stringToReplace.contains('é')) stringToReplace = stringToReplace.replace('é', 'e');
            if (stringToReplace.contains('À')) stringToReplace = stringToReplace.replace('À', 'A');
            if (stringToReplace.contains('à')) stringToReplace = stringToReplace.replace('à', 'a');
            if (stringToReplace.contains('È')) stringToReplace = stringToReplace.replace('È', 'E');
            if (stringToReplace.contains('è')) stringToReplace = stringToReplace.replace('è', 'e');
            if (stringToReplace.contains('Ï')) stringToReplace = stringToReplace.replace('Ï', 'I');
            if (stringToReplace.contains('ï')) stringToReplace = stringToReplace.replace('ï', 'i');
            if (stringToReplace.contains('Ü')) stringToReplace = stringToReplace.replace('Ü', 'U');
            if (stringToReplace.contains('ü')) stringToReplace = stringToReplace.replace('ü', 'u');
        }

        return stringToReplace;
    }


    /*******************************************************************************
    *  Summary         : Check empty address
    *  CreatedDate     : 02/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateEmptyAddress() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.externalCFCompany.city == null || this.externalCFCompany.street == null ||
                this.externalCFCompany.postCode == null || this.externalCFCompany.houseNumber == null) {
            validationItem.passed = false;
            validationItem.description = 'Company has no known address.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Check Mandate Type
	*  CreatedDate     : 10/11/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected override CreditFactoryValidationItem validateMandateType() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.paymentMethod == 'Lastschrift' && this.internalCFCompany.directDebitMandateType == 'Core') {
            String riskCategory;
            if (this.externalCFCompany.classRating == '1') {
                riskCategory = 'Low';
            }
            else if (this.externalCFCompany.classRating == '2') {
                riskCategory = 'Medium';
            }
            else if (this.externalCFCompany.classRating == '3' || this.externalCFCompany.classRating == '4') {
                riskCategory = 'High';
            }
            else if (this.externalCFCompany.classRating == '5') {
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