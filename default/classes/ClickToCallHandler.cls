public class ClickToCallHandler {
    
    public static Boolean setValidNumber = true;
    // public static String DE_CODE = '+49';
    // public static String AT_CODE = '+43';
    // public static String PL_CODE = '+48';
    // public static String NL_CODE = '+31';
    // public static String BE_CODE = '+32';
    // public static String FR_CODE = '+33';
    // public static String HU_CODE = '+36';
    // public static String CH_CODE = '+41';
    // public static String LU_CODE = '+352';
    // public static String CZ_CODE = '+420';
    // public static String SK_CODE = '+421';
    
    // public static Map <String, String> countryCodesMap = new Map <String, String> {
    //     'DE' => DE_CODE,
    //     'AT' => AT_CODE,
    //     'PL' => PL_CODE,
    //     'NL' => NL_CODE,
    //     'BEFR' => BE_CODE,
    //     'BENL' => BE_CODE,
    //     'FR' => FR_CODE,
    //     'HU' => HU_CODE,
    //     'CHDE' => CH_CODE,
    //     'CHFR' => CH_CODE,
    //     'CHIT' => CH_CODE,
    //     'LU' => LU_CODE,
    //     'CZ' => CZ_CODE,
    //     'SK' => SK_CODE
    // };

    // 11.02.2021 - Egor Bosolyho - the ClickToCallHandler.countryCodesMap was updated according to the country codes used on the ETE-2.0 form
    public static Map <String, String> countryCodesMap = new Map <String, String> {
            'AL' => '+355',
            'AD' => '+376',
            'AT' => '+43',
            'BY' => '+375',
            'BE' => '+32',
            'BEFR' => '+32',
            'BENL' => '+32',
            'BA' => '+387',
            'BG' => '+359',
            'HR' => '+385',
            'CZ' => '+420',
            'DK' => '+45',
            'EE' => '+372',
            'FO' => '+298',
            'FI' => '+358',
            'FR' => '+33',
            'DE' => '+49',
            'GI' => '+350',
            'GR' => '+30',
            'VA' => '+39',
            'HU' => '+36',
            'IS' => '+354',
            'IE' => '+353',
            'IT' => '+39',
            'LV' => '+371',
            'LI' => '+423',
            'LT' => '+370',
            'LU' => '+352',
            'MK' => '+389',
            'MT' => '+356',
            'MD' => '+373',
            'MC' => '+377',
            'ME' => '+382',
            'NL' => '+31',
            'NO' => '+47',
            'PL' => '+48',
            'PT' => '+351',
            'RO' => '+40',
            'RU' => '+7',
            'SM' => '+378',
            'RS' => '+381',
            'SK' => '+421',
            'SI' => '+386',
            'ES' => '+34',
            'SE' => '+46',
            'CH' => '+41',
            'CHDE' => '+41',
            'CHFR' => '+41',
            'CHIT' => '+41',
            'UA' => '+380',
            'GB' => '+44'
    };

    public static Map <String, String> countriesToCodesMap;
    public static Map <String, String> getCountriesToCodesMap () {
        if (countriesToCodesMap == null) {
            countriesToCodesMap = GlobalUtils.getFleetcorCountriesToCodesMap();
        }
        return countriesToCodesMap;
    }

    /*******************************************************************************
    *  Name            : checkPhonesOnRecordAndProcess(Schema.sObjectType sObjType, String countryCode, sObject newSObj, sobject oldSObj)
    *  Summary         : check if phone fields were changed and proccess    
    *  CreatedDate     : 30/10/2019
    *  Parameters      : Schema.sObjectType sObjType - schema sobjecttype, String countryCode - country code field value on the record, sObject newSObj, sobject oldSObj - new and old records from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void checkPhonesOnRecordAndProcess (Schema.sObjectType sObjType, String countryCode, String countryName, sObject newSObj, sobject oldSObj) {
        List<Schema.FieldSetMember>  phoneFields_EU = GlobalUtils.getFieldSetMembers (sObjType, 'All_Phone_Fields_EU');
        if (countryCode == null && countryName != null) {
            countryCode = getCountriesToCodesMap().containsKey(countryName) ?  getCountriesToCodesMap().get(countryName) : null; 
        }
        if (countryCode != null) {
        // process cases when country code is defined
            for (Schema.FieldSetMember phoneField : phoneFields_EU) {
                String phoneFieldAPI = phoneField.getFieldPath();
                String newPhoneNumber = newSObj.get(phoneFieldAPI) == null ? null : String.valueOf(newSObj.get(phoneFieldAPI));
                String oldPhoneNumber = oldSObj != null && oldSObj.get(phoneFieldAPI) != null ? String.valueOf(oldSObj.get(phoneFieldAPI)) : null;
                if (newPhoneNumber == null) {
                    putPhoneStatus (newSObj, phoneFieldAPI, null);
                }
                if (newPhoneNumber != null && (oldSObj == null || oldPhoneNumber != newPhoneNumber)) {
                    String formattedPhone = ClickToCallHandler.returnValidNumber(newPhoneNumber, countryCode);
                    String countryCodeNumber = getCountryCodeNumber (formattedPhone);
                    if (countryCodeNumber == null) {
                        // check if previous phone value was valid
                        String oldCountryCodeNumber = getCountryCodeNumber (oldPhoneNumber);
                        if (oldCountryCodeNumber != null) {
                        // if old phone number was valid then leave it // otherwise - validation error will occur
                            savePhoneNumber (oldPhoneNumber, phoneFieldAPI, newSObj);
                        }
                    } else {
                        putPhoneStatus (newSObj, phoneFieldAPI, null);
                        savePhoneNumber (formattedPhone, phoneFieldAPI, newSObj);
                    }
                }
            }
        } else {
        // process cases when country code is empty (only found these cases with contact records)
            if (sObjType == Schema.Contact.sObjectType) {
                for (Schema.FieldSetMember phoneField : phoneFields_EU) {
                    String phoneFieldAPI = phoneField.getFieldPath();
                    String newPhoneNumber = newSObj.get(phoneFieldAPI) == null ? null : String.valueOf(newSObj.get(phoneFieldAPI));
                    //country code is empty and number is invalid
                    if (newPhoneNumber != null) { 
                        String countryCodeNumber = getCountryCodeNumber (newPhoneNumber);
                        newPhoneNumber = removeNonNumberCharacters (newPhoneNumber, countryCodeNumber); // 03.09.2019 removes all extra characters
                        if (countryCodeNumber == null) {
                            // if country code is not valid and it's not set on a contact then set Needs validation status
                            putPhoneStatus (newSObj, phoneFieldAPI, 'Needs validation');
                        } else {
                            putPhoneStatus (newSObj, phoneFieldAPI, null);
                            savePhoneNumber (newPhoneNumber, phoneFieldAPI, newSObj);
                        }
                    } else {
                        putPhoneStatus (newSObj, phoneFieldAPI, null);
                    }
                }
            } else {
                for (Schema.FieldSetMember phoneField : phoneFields_EU) {
                    String phoneFieldAPI = phoneField.getFieldPath();
                    String newPhoneNumber = newSObj.get(phoneFieldAPI) == null ? null : String.valueOf(newSObj.get(phoneFieldAPI));
                    savePhoneNumber (newPhoneNumber, phoneFieldAPI, newSObj);
                }
            }
        }
    }
    /*******************************************************************************
    *  Name            : savePhoneNumber
    *  Summary         : save phone number on the record and set status "Needs validation" if needed
    *  CreatedDate     : 03/03/2020
    *  Parameters      : String newPhoneNumber - new value from trigger, String phoneFieldAPI - phone field api, sObject newSObj - sObject record from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void savePhoneNumber (String newPhoneNumber, String phoneFieldAPI, sObject newSObj) {
        newSObj.put(phoneFieldAPI, newPhoneNumber);
        checkIfPhoneNumberIsValid (newPhoneNumber, phoneFieldAPI, newSObj);
    }
    /*******************************************************************************
    *  Name            : checkIfPhoneNumberIsValid
    *  Summary         : check phone format and set status "Needs validation" if needed
    *  CreatedDate     : 03/03/2020
    *  Parameters      : String newPhoneNumber - new value from trigger, String phoneFieldAPI - phone field api, sObject newSObj - sObject record from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void checkIfPhoneNumberIsValid (String newPhoneNumber, String phoneFieldAPI, sObject newSObj) {
        if (PhoneNumbersHandler.isPhoneNumberValid (newPhoneNumber) == false) {
            putPhoneStatus (newSObj, phoneFieldAPI, 'Needs validation');
        }
    }
    /*******************************************************************************
    *  Name            : getCountryCodeNumber(String phone)
    *  Summary         : get country code number from the phone string
    *  CreatedDate     : 08/11/2019
    *  Parameters      : String phone – phone from the Salesforce
    *  Returns         : String - country code number
    ******************************************************************************/
    public static String getCountryCodeNumber (String phone) {
        // check if country code (of any country) is entered in the phone number
        if (phone == null) return null;
        String countryCodeNumber;
        for (String countryCodeItem : countryCodesMap.values()) {
            if (phone.startsWith(countryCodeItem)) {
                countryCodeNumber = countryCodeItem;
                break;
            }
        }
        return countryCodeNumber;
    }
    
    /*******************************************************************************
    *  Name            : putPhoneStatus(sObject newSObj, String phoneFieldAPI, String statusVal)
    *  Summary         : put phone status
    *  CreatedDate     : 08/11/2019
    *  Parameters      : sObject newSObj - sobj on whic we save phone status, String phoneFieldAPI – phone field api, String statusVal - new status value
    *  Returns         : void
    ******************************************************************************/
    public static void putPhoneStatus (sObject newSObj, String phoneFieldAPI, String statusVal) {
        String phoneStatusAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
        try {
            String oldPhoneStatusVal = newSObj.get(phoneStatusAPI) == null ? null : String.valueOf(newSObj.get(phoneStatusAPI));
            if (oldPhoneStatusVal == 'New' && statusVal == null) return;
            newSObj.put(phoneStatusAPI, statusVal);
        } catch (Exception ex) {} // if there is no status field for the phone field the exception will occur
    }
    
    /*******************************************************************************
    *  Name            : returnValidNumber(String phone, String CountryCode)
    *  Summary         : Based on phone and CountryCode return correct phone number     
    *  CreatedDate     : 01/03/2017
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : String phone – phone from the Salesforce
                         String CountryCode – CountryCode from object
    *  Returns         : String - valid phone
    ******************************************************************************/
    public static String returnValidNumber(String phone, String countryCode) {
        if (setValidNumber == false) return phone;
        String validPhone = phone;
        String countryCodeNumber = getCountryCodeNumber (phone);
        
        // a country code is not entered in the phone number
        if (countryCodeNumber == null && countryCode != null) {
            countryCodeNumber = countryCodesMap.get(countryCode);
            if (countryCode == 'DE') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesDESet);
            } else if (countryCode == 'AT') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesATSet);
            } else if (countryCode == 'PL') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesPLSet);
            } else if (countryCode == 'NL') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesNLSet);
            } else if (countryCode == 'BEFR' || countryCode == 'BENL') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesBESet);
            } else if (countryCode == 'FR') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesFRSet);
            } else if (countryCode == 'HU') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesBESet);
            } else if (countryCode == 'CHDE' || countryCode == 'CHFR' || countryCode == 'CHIT') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesCHSet);
            } else if (countryCode == 'LU') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesLUSet);
            } else if (countryCode == 'CZ') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesCZSet);
            } else if (countryCode == 'SK') {
                validPhone = returnPhone(validPhone, countryCodeNumber, invalidCodesSKSet);
            }
        }
        
        validPhone = removeNonNumberCharacters (validPhone, countryCodeNumber); // 03.09.2019 removes all extra characters
        return validPhone;
    }

    /*******************************************************************************
    *  Name            : removeNonNumberCharacters (String phoneNumber, String countryCodeNumber)
    *  Summary         : removes extra characters from phone number   
    *  CreatedDate     : 03/09/2019
    *  ModifiedDate    : 
    *  Parameters      : String phoneNumber – phone which was entered, String countryCodeNumber - country code number (for ex. '+49')
    *  Returns         : String - phone number without text characters
    ******************************************************************************/
    private static String removeNonNumberCharacters (String phoneNumber, String countryCodeNumber) {
        system.debug('phonenumberbefore : ' + phoneNumber);
        String[] charsPhoneNumber = new List <String> ();
        String phoneNumber_NoCountryCode = phoneNumber;
        if (countryCodeNumber != null) {
            phoneNumber_NoCountryCode = phoneNumber.replaceFirst('\\'+countryCodeNumber, '');
        }
        String[] chars = phoneNumber_NoCountryCode.split('');
        if (!chars.isEmpty()) {
            for (Integer i = 0; i <= chars.size() - 1; i++) {
                if (chars[i].isNumeric()) { // add numbers only
                    if (chars[i] == '0' && charsPhoneNumber.isEmpty()) continue;  // don't add first 0 characters after country code
                    charsPhoneNumber.add(chars[i]);
                }
            }
        }
        phoneNumber = countryCodeNumber == null ? phoneNumber : countryCodeNumber +
                     (charsPhoneNumber.isEmpty() ? '' : String.join (charsPhoneNumber, ''));
        return phoneNumber;
    }

    /*******************************************************************************
    *  Name            : returnPhone(String phoneFromSalesforce, String mainCode, Set<String> invalidCodesSet)
    *  Summary         : Return phone number with correct phone code     
    *  CreatedDate     : 01/03/2017
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : phoneFromSalesforce - object Phone field 
                         mainCode – static code for the country 
                         invalidCodesSet – set with supported invlalid phone codes
    *  Returns         : String – phone number
    ******************************************************************************/
    public static String returnPhone(String phoneFromSalesforce, String mainCode, Set<String> invalidCodesSet) {
        String validPhone = '';
        for (String invalidCode : invalidCodesSet) {
            if (phoneFromSalesforce != null && phoneFromSalesforce.length() >= invalidCode.length() && invalidCode == phoneFromSalesforce.substring(0, invalidCode.length())) {
                validPhone = mainCode + phoneFromSalesforce.substring(invalidCode.length(), phoneFromSalesforce.length());
                return validPhone;
            }
        }
        if (phoneFromSalesforce != null && phoneFromSalesforce.length() >= mainCode.length() && phoneFromSalesforce.isNumeric() && phoneFromSalesforce.substring(0, mainCode.length()) != mainCode) {
            validPhone = mainCode + phoneFromSalesforce;
            return validPhone;
        }

        return phoneFromSalesforce;
    }


    public static Set<String> invalidCodesDESet = new Set<String>{
        //'+49(0)',
        '0049',
        '49(0)',
        '00049',
        '49',
        '049',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesATSet = new Set<String>{
        //'+43(0)',
        '0043',
        '43(0)',
        '00043',
        '43',
        '043',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesPLSet = new Set<String>{
        //'+48(0)',
        '0048',
        '48(0)',
        '00048',
        '48',
        '048',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesNLSet = new Set<String>{
        //'+31(0)',
        '0031',
        '31(0)',
        '00031',
        '31',
        '031',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesBESet = new Set<String>{
        //'+32(0)',
        '0032',
        '32(0)',
        '00032',
        '32',
        '032',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesFRSet = new Set<String>{
        //'+33(0)',
        '0033',
        '33(0)',
        '00033',
        '33',
        '033',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesHUSet = new Set<String>{
        //'+36(0)',
        '0036',
        '36(0)',
        '00036',
        '36',
        '036',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesCHSet = new Set<String>{
        //'+41(0)',
        '0041',
        '41(0)',
        '00041',
        '41',
        '041',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesLUSet = new Set<String>{
        //'+352(0)',
        '00352',
        '352(0)',
        '000352',
        '352',
        '0352',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesCZSet = new Set<String>{
        //'+420(0)',
        '00420',
        '420(0)',
        '000420',
        '420',
        '0420',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesSKSet = new Set<String>{
        //'+421(0)',
        '00421',
        '421(0)',
        '000421',
        '421',
        '0421',
        '0',
        '(0)'
    };
}