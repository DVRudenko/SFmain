public class CreditFactoryValidationImplPL extends CreditFactoryValidationImpl {
    
    
    /*******************************************************************************
    *  Summary         : return Name of Credit System   
    *  Created         : 05/03/2020
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'Crif';
    }
    
    /*******************************************************************************
    *  Summary         : Check desired Billing period and desire Payment terms  
    *  CreatedDate     : 05/09/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateDesiredPaymentDetails() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        Boolean isCarnetOnly = false;
        if ((this.internalCFCompany.recordType == 'Euroshell' || this.internalCFCompany.recordType == 'Euroshell Starts') &&
                this.internalCFCompany.numberOfGpsUnits != null && this.internalCFCompany.numberOfGpsUnits > 0 &&
                (String.isEmpty(this.internalCFCompany.numberOfCards) || Integer.valueOf(this.internalCFCompany.numberOfCards) == 0)) {
            isCarnetOnly = true;
        }

        if (this.internalCFCompany.desiredBillingPeriod == '7' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '7' ||
                this.internalCFCompany.desiredBillingPeriod == '15' && this.internalCFCompany.desiredPaymentTerms == '14' || isCarnetOnly) {
            validationItem.passed = true;
        }

        if (validationItem.passed == null) {
            validationItem.passed = false;
            validationItem.description = 'Desired Billing Period and Desired Payment terms are not available. Available options are: 15+14, 15+7, 7+7.';
        }

        return validationItem;
    }
    
    
    /*******************************************************************************
    *  Summary         : replace country specific characters   
    *  Created         : 05/03/2020
    *  Parameters      : -
    *  Returns         : string without country specific characters
    ******************************************************************************/
    protected override String replaceSpecificCharacters(String stringToReplace) {
        if (stringToReplace != null) {
            if (stringToReplace.contains('Ć')) stringToReplace = stringToReplace.replace('Ć', 'C');
            if (stringToReplace.contains('ć')) stringToReplace = stringToReplace.replace('ć', 'c');
            if (stringToReplace.contains('Ń')) stringToReplace = stringToReplace.replace('Ń', 'N');
            if (stringToReplace.contains('ń')) stringToReplace = stringToReplace.replace('ń', 'n');
            if (stringToReplace.contains('Ó')) stringToReplace = stringToReplace.replace('Ó', 'O');
            if (stringToReplace.contains('ó')) stringToReplace = stringToReplace.replace('ó', 'o');
            if (stringToReplace.contains('Ś')) stringToReplace = stringToReplace.replace('Ś', 'S');
            if (stringToReplace.contains('ś')) stringToReplace = stringToReplace.replace('ś', 's');
            if (stringToReplace.contains('Ź')) stringToReplace = stringToReplace.replace('Ź', 'Z');
            if (stringToReplace.contains('ź')) stringToReplace = stringToReplace.replace('ź', 'z');
            if (stringToReplace.contains('Ż')) stringToReplace = stringToReplace.replace('Ż', 'Z');
            if (stringToReplace.contains('ż')) stringToReplace = stringToReplace.replace('ż', 'z');
            if (stringToReplace.contains('Ą')) stringToReplace = stringToReplace.replace('Ą', 'A');
            if (stringToReplace.contains('ą')) stringToReplace = stringToReplace.replace('ą', 'a');
            if (stringToReplace.contains('Ę')) stringToReplace = stringToReplace.replace('Ę', 'E');
            if (stringToReplace.contains('ę')) stringToReplace = stringToReplace.replace('ę', 'e');
            if (stringToReplace.contains('Ł')) stringToReplace = stringToReplace.replace('Ł', 'L');
            if (stringToReplace.contains('ł')) stringToReplace = stringToReplace.replace('ł', 'l');
            if (stringToReplace.contains('X')) stringToReplace = stringToReplace.replace('X', 'KS');
            if (stringToReplace.contains('x')) stringToReplace = stringToReplace.replace('x', 'ks');
        }

        return stringToReplace;
    }
    
    
    /*******************************************************************************
	*  Summary         : Check that company name from Credit System is the same as Salesforce company name
	*  CreatedDate     : 14/01/2020
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
        String externalPostalStreetAndHouseNumber = joinStreetAndHouseNumber(this.externalCFCompany.postalStreet, this.externalCFCompany.postalHouseNumber);
        String externalPostalHouseNumberAndStreet = joinStreetAndHouseNumber(this.externalCFCompany.postalHouseNumber, this.externalCFCompany.postalStreet);
        String externalRegisteredStreetAndHouseNumber = joinStreetAndHouseNumber(this.externalCFCompany.registeredStreet, this.externalCFCompany.registeredHouseNumber);
        String externalRegisteredHouseNumberAndStreet = joinStreetAndHouseNumber(this.externalCFCompany.registeredHouseNumber, this.externalCFCompany.registeredStreet);

        if (! ((isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalStreetAndHouseNumber) ||
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalHouseNumberAndStreet) || 
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalPostalStreetAndHouseNumber) ||
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalPostalHouseNumberAndStreet) || 
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalRegisteredStreetAndHouseNumber) || 
                isStreetAndHouseNumberValid(this.internalCFCompany.registeredStreet, this.internalCFCompany.shippingStreet, externalRegisteredHouseNumberAndStreet)) &&
                (isCityValid(this.internalCFCompany.registeredCity, this.internalCFCompany.shippingCity, this.externalCFCompany.city) ||
                isCityValid(this.internalCFCompany.registeredCity, this.internalCFCompany.shippingCity, this.externalCFCompany.postalCity) ||
                isCityValid(this.internalCFCompany.registeredCity, this.internalCFCompany.shippingCity, this.externalCFCompany.registeredCity)) && 
                (isPostalCodeValid(this.internalCFCompany.registeredPostCode, this.internalCFCompany.shippingPostCode, this.externalCFCompany.postCode) || 
                isPostalCodeValid(this.internalCFCompany.registeredPostCode, this.internalCFCompany.shippingPostCode, this.externalCFCompany.postalPostCode) || 
                isPostalCodeValid(this.internalCFCompany.registeredPostCode, this.internalCFCompany.shippingPostCode, this.externalCFCompany.registeredPostCode)))) {
            validationItem.passed = false;
            validationItem.description = 'Account Billing and Shipping Addresses should be the same as ' + returnCreditSystemName() + ' address';
        } else {
            validationItem.passed = true;
        }
        
        return validationItem;
    }


    /*******************************************************************************
    *  Summary         : Check empty address
    *  CreatedDate     : 16/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateEmptyAddress() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        String city = this.externalCFCompany.city;
        String postCode = this.externalCFCompany.postCode;
        String street = this.externalCFCompany.street;
        String houseNumber = this.externalCFCompany.houseNumber;
        String postalCity = this.externalCFCompany.postalCity;
        String postalPostCode = this.externalCFCompany.postalPostCode;
        String postalStreet = this.externalCFCompany.postalStreet;
        String postalHouseNumber = this.externalCFCompany.postalHouseNumber;
        String registeredCity = this.externalCFCompany.registeredCity;
        String registeredPostCode = this.externalCFCompany.registeredPostCode;
        String registeredStreet = this.externalCFCompany.registeredStreet;
        String registeredHouseNumber = this.externalCFCompany.registeredHouseNumber;

        if ((city != null && postCode != null && street != null && houseNumber != null) ||
                (postalCity != null && postalPostCode != null && postalStreet != null && postalHouseNumber != null) ||
                (registeredCity != null && registeredPostCode != null && registeredStreet != null && registeredHouseNumber != null)) {
            validationItem.passed = true;
        }
        else {
            validationItem.passed = false;
            validationItem.description = 'Address can\'t be verified (incomplete data in the report).';
        }
        return validationItem;
    }
}