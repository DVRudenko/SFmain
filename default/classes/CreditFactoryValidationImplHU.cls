public class CreditFactoryValidationImplHU extends CreditFactoryValidationImpl {


    /*******************************************************************************
    *  Summary         : return Name of Credit System
    *  Created         : 22/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'Coface';
    }


    /*******************************************************************************
    *  Summary         : Check desired Billing period and desire Payment terms
    *  CreatedDate     : 15/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateDesiredPaymentDetails() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '14') {
            validationItem.passed = true;
        }

        if (validationItem.passed == null) {
            validationItem.passed = false;
            validationItem.description = 'Desired Billing Period and Desired Payment terms are not available. Available options are: 15+14, 7+7.';
        }

        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check Opportunity "Processed by" field
    *  CreatedDate     : 21/10/2020 by Anton Buzak
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
            validationItem.description = 'Please approve Tax Id to send order: ' + this.internalCFCompany.taxId + '.';
            validationItem.parametersMap = new Map<String, Object>();
            validationItem.parametersMap.put('isTaxIdApprove', true);
        }

        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Check that company name from Credit System is the same as Salesforce company name
	*  CreatedDate     : 22/10/2020 by Anton Buzak
    *  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
    protected override CreditFactoryValidationItem validateCompanyName() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (areStringsEquals(this.internalCFCompany.name, this.externalCFCompany.tradeName)) {
            validationItem.passed = true;
        }
        else {
            validationItem.passed = false;
            validationItem.description = 'Account Name and ' + returnCreditSystemName() + ' Name mismatch';
        }

		return validationItem;
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
}