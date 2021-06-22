public class CreditFactoryValidationImplNL extends CreditFactoryValidationImpl {

    /*******************************************************************************
    *  Summary         : return Name of Credit System
    *  Created         : 03/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'CreditSafe';
    }

    /*******************************************************************************
    *  Summary         : Check desired Billing period and desire Payment terms
    *  CreatedDate     : 03/09/2020 by Anton Buzak
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
    *  Created         : 07/09/2020 by Anton Buzak
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
            if (stringToReplace.contains('Ú')) stringToReplace = stringToReplace.replace('Ú', 'U');
            if (stringToReplace.contains('ú')) stringToReplace = stringToReplace.replace('ú', 'u');
            if (stringToReplace.contains('À')) stringToReplace = stringToReplace.replace('À', 'A');
            if (stringToReplace.contains('à')) stringToReplace = stringToReplace.replace('à', 'a');
            if (stringToReplace.contains('È')) stringToReplace = stringToReplace.replace('È', 'E');
            if (stringToReplace.contains('è')) stringToReplace = stringToReplace.replace('è', 'e');
            if (stringToReplace.contains('Ï')) stringToReplace = stringToReplace.replace('Ï', 'I');
            if (stringToReplace.contains('ï')) stringToReplace = stringToReplace.replace('ï', 'i');
            if (stringToReplace.contains('Ö')) stringToReplace = stringToReplace.replace('Ö', 'O');
            if (stringToReplace.contains('ö')) stringToReplace = stringToReplace.replace('ö', 'o');
            if (stringToReplace.contains('Ü')) stringToReplace = stringToReplace.replace('Ü', 'U');
            if (stringToReplace.contains('ü')) stringToReplace = stringToReplace.replace('ü', 'u');
        }

        return stringToReplace;
    }


    /*******************************************************************************
	*  Summary         : Check that company name from Credit System is the same as Salesforce company name
	*  CreatedDate     : 07/09/2020 by Anton Buzak
	*  Parameters      : -
    *  Returns         : validation result
	******************************************************************************/
    protected override CreditFactoryValidationItem validateAddress() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        CreditFactoryValidationItem validationEmptyAddress = validateEmptyAddress();
        if (validationEmptyAddress.passed == false) {
            validationItem.passed = true;
            return validationItem;
        }

        String externalStreetAndHouseNumber = joinStreetAndHouseNumber(this.externalCFCompany.street, this.externalCFCompany.houseNumber);
        String externalHouseNumberAndStreet = joinStreetAndHouseNumber(this.externalCFCompany.houseNumber, this.externalCFCompany.street);

        String additionalCreditCompanyStreetAndHouseNumber = '';
        String additionalCreditCompanyHouseNumberAndStreet = '';
        String additionalCreditCompanyCity = '';
        String additionalCreditCompanyPostCode = '';

        if (this.externalAdditionalCFCompany != null) {
            additionalCreditCompanyStreetAndHouseNumber = (this.externalAdditionalCFCompany.street != null ? this.externalAdditionalCFCompany.street : '') + ' ' +
                (this.externalAdditionalCFCompany.houseNumber != null ? this.externalAdditionalCFCompany.houseNumber : '');
            additionalCreditCompanyStreetAndHouseNumber = additionalCreditCompanyStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
            additionalCreditCompanyHouseNumberAndStreet = (this.externalAdditionalCFCompany.houseNumber != null ? this.externalAdditionalCFCompany.houseNumber : '') + ' ' +
                (this.externalAdditionalCFCompany.street != null ? this.externalAdditionalCFCompany.street : '');
            additionalCreditCompanyHouseNumberAndStreet = additionalCreditCompanyHouseNumberAndStreet.removeStart(' ').removeEnd(' ');
            additionalCreditCompanyCity = (this.externalAdditionalCFCompany.city != null ? this.externalAdditionalCFCompany.city : '');
            additionalCreditCompanyPostCode = (this.externalAdditionalCFCompany.postCode != null ? this.externalAdditionalCFCompany.postCode : '');
        }

        if (! ((isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalStreetAndHouseNumber) ||
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalHouseNumberAndStreet) ||
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, additionalCreditCompanyStreetAndHouseNumber) ||
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, additionalCreditCompanyHouseNumberAndStreet)) &&
                (isCityValid(this.internalCFCompany.registeredCity, this.internalCFCompany.shippingCity, this.externalCFCompany.city) ||
                isCityValid(this.internalCFCompany.registeredCity, this.internalCFCompany.shippingCity, additionalCreditCompanyCity)) &&
                (isPostalCodeValid(this.internalCFCompany.registeredPostCode, this.internalCFCompany.shippingPostCode, this.externalCFCompany.postCode) ||
                isPostalCodeValid(this.internalCFCompany.registeredPostCode, this.internalCFCompany.shippingPostCode, additionalCreditCompanyPostCode)))) {
            validationItem.passed = false;
            validationItem.description = 'Account Billing and Shipping Addresses should be the same as ' + returnCreditSystemName() + ' address';
        } else {
            validationItem.passed = true;
        }

        return validationItem;
    }


    /*******************************************************************************
	*  Summary         : Check that company name from Credit System is the same as Salesforce company name
	*  CreatedDate     : 14/11/2019
	*  ModifiedDate    : -
	*  Returns         : validation result
	******************************************************************************/
	protected override CreditFactoryValidationItem validateCompanyName() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (areStringsEquals(this.internalCFCompany.name, this.externalCFCompany.name) ||
                (this.externalAdditionalCFCompany != null && areStringsEquals(this.internalCFCompany.name, this.externalAdditionalCFCompany.name))) {
            validationItem.passed = true;
        }
        else {
            validationItem.passed = false;
            validationItem.description = 'Account Name and ' + returnCreditSystemName() + ' Name mismatch';
        }

		return validationItem;
	}


    /*******************************************************************************
    *  Summary         : Check empty address
    *  CreatedDate     : 02/10/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateEmptyAddress() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        if (this.externalCFCompany.name != null && (this.externalCFCompany.city == null || this.externalCFCompany.street == null ||
                this.externalCFCompany.postCode == null || this.externalCFCompany.houseNumber == null)) {
            validationItem.passed = false;
            validationItem.description = 'Company has no known address.';
        }
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }
}