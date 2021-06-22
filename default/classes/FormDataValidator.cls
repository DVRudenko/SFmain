/*
* Class for validation all steps
*
* */
public class FormDataValidator {

    /*******************************************************************************
    *  Name            : validateMobilePhone(String phoneNumber)
    *  Summary         : mobile phone number field validation
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateMobilePhone(String phoneNumber) {
        if (!LongFormGlobalUtils.validatePhone(phoneNumber, 'Russia')) {
            throw new E2EFormRuException('Validation error: Mobile Phone - ' + phoneNumber);
        }
    }

    /*******************************************************************************
    *  Name            : validateEmail(String emailAddress)
    *  Summary         : email field validation
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateEmail(String emailAddress) {
        if (!LongFormGlobalUtils.validateEmailFormatRu(emailAddress)) {
            throw new E2EFormRuException('Validation error: Email Address - ' + emailAddress);
        }
    }

    /*******************************************************************************
    *  Name            : validateStringField(String value)
    *  Summary         : string field validation
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateStringField(String value) {
        if (value == null || !value.isAlphaSpace() || value == '') {
            throw new E2EFormRuException('Validation error: String field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateBooleanField(String value)
    *  Summary         : boolean field validation
    *  CreatedDate     : 16/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateBooleanField(String value) {
        if (value == null || ! (value.toUpperCase() == 'FALSE' || value.toUpperCase() == 'TRUE')) {
            throw new E2EFormRuException('Validation error: boolean field -' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateOGRNField(String value)
    *  Summary         : OGRN field validation
    *  CreatedDate     : 18/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validatePSRNField(String value) {
        if (value.length() != 13 && ! value.isNumeric()) {
            throw new E2EFormRuException('Validation error: OGRN field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateKPPField(String value)
    *  Summary         : KPP field validation
    *  CreatedDate     : 18/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateKPPField(String value) {
        if (value.length() != 9 && !value.isNumeric()) {
            throw new E2EFormRuException('Validation error: KPP field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateOKPOField(String value)
    *  Summary         : OKPO field validation
    *  CreatedDate     : 18/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateOKPOField(String value) {
        if (value == null || ((value.length() > 10 || value.length() < 8) && ! value.isNumeric())) {
            throw new E2EFormRuException('Validation error: OKPO field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateBICField(String value)
    *  Summary         : BIC field validation
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateBICField(String value) {
        if (value.length() != 9 && !value.isNumeric()) {
            throw new E2EFormRuException('Validation error: BIC field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateCheckingAccount(String value)
    *  Summary         : Checking Account field validation
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateCheckingAccount(String value) {
        if (value.length() != 20 && !value.isNumeric()) {
            throw new E2EFormRuException('Validation error: Checking Account field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateCheckingAccount(String value)
    *  Summary         : Checking INN field validation
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateInnField(String value) {
        if (!value.isNumeric() || (value.length() != 10 && value.length() != 12)) {
            throw new E2EFormRuException('Validation error: Checking INN field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateCheckingAccount(String value)
    *  Summary         : Checking Account Name field validation
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String value
    *  Returns         : void
    ******************************************************************************/
    public void validateAccountNameField(String value) {
        if (value == null || value == '') {
            throw new E2EFormRuException('Validation error: account name field - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateNumberOfCards(String value)
    *  Summary         : Checking Number of cards field validation
    *  CreatedDate     : 07/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String value
    *  Returns         : void
    ******************************************************************************/
    public void validateNumberOfCards(String value) {
        Integer numberOfCards = Integer.valueOf(value);
        if (numberOfCards < 0 && numberOfCards > 1000) {
            throw new E2EFormRuException('Validation error: number of cards is invalid - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateFieldFulling(String value)
    *  Summary         : Checking value is not empty or null
    *  CreatedDate     : 07/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String value
    *  Returns         : void
    ******************************************************************************/
    public void validateFieldFulling(String value) {
        if (value == null) {
            throw new E2EFormRuException('Validation error: field is null - ' + value);
        }
        if (value == '') {
            throw new E2EFormRuException('Validation error: field is empty - ' + value);
        }
    }

    /*******************************************************************************
    *  Name            : validateIsNotBlank(String value, String name)
    *  Summary         : Checking value is not empty or null
    *  CreatedDate     : 07/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String value, String name
    *  Returns         : void
    ******************************************************************************/
    public void validateIsNotBlank(String value, String name) {
        if (value == null) {
            throw new E2EFormRuException('Validation error: field is null - ' + name);
        }
        if (value == '') {
            throw new E2EFormRuException('Validation error: field is empty - ' + name);
        }
    }

    /*******************************************************************************
    *  Name            : validateFieldFulling(String value)
    *  Summary         : Checking value is not empty or null without exception
    *  CreatedDate     : 23/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String value
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateIsNotBlank(String value) {
        if (value == null || value == '') {
            return false;
        }
        return true;
    }

    /*******************************************************************************
    *  Name            : isValidAddress()
    *  Summary         : Checking address components
    *  CreatedDate     : 23/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String city, String state, String street, String postalCode
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isValidAddress(String country, String city, String state, String street, String postalCode) {
        if (validateIsNotBlank(state) && isValidAddress(country, city, street, postalCode)) {
            return true;
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : isValidAddress()
    *  Summary         : Checking address components
    *  CreatedDate     : 23/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String city, String street, String postalCode
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isValidAddress(String country, String city, String street, String postalCode) {
        if (validateIsNotBlank(country) &&
                validateIsNotBlank(city) &&
                validateIsNotBlank(street) &&
                validateIsNotBlank(postalCode)) {
            return true;
        } else {
            return false;
        }
    }

}