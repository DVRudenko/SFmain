public class CreditFactoryUtilities {
    public static String CONTACT_ADMIN = 'Please contact your administrator.';
    public static String UNAVAILABLE_MANDATE_TYPE = 'Please change the Direct Debit Type Mandate from Core to B2B because the Customer has high Credit risk.';
    public static String CREFO_API_ERROR = 'Creditreform API error.';
    public static String CREDITSAFE_API_ERROR = 'Creditsafe API error.';
    public static String COMPANY_INFO_API_ERROR = 'Company.info API error.';
    public static String LEXISNEXIS_API_ERROR = 'LexisNexis API error.';
    public static String SCHUFA_API_ERROR = 'Schufa API error.';
    public static String CREDICONNECT_API_ERROR = 'Crediconnect API error.';
    public static String BIG_API_ERROR = 'Big API error.';
    public static String COFACE_API_ERROR = 'Coface API error.';
    public static String SCHUFA_REPORT_NOT_AVAILABLE = 'Credit report is not available. Please refer to Credit.';

    public Static void displayMessage(String type, String message) {
        if (type == 'error') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));
        if (type == 'info') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));
        if (type == 'confirm') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,message));
        if (type == 'warning') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,message));
    }

    public static String returnCurrentDate()  {
        String strConvertedDate = Datetime.now().format(
            'yyyy-MM-dd HH:mm:ss');
        strConvertedDate = strConvertedDate.replace(' ', 'T');
        strConvertedDate = strConvertedDate + '.' + Datetime.now().millisecond();
        return strConvertedDate;
    }

    public static Boolean isStringsEquals(String string1, String string2) {
        if (string1 == null && string2 == null) {
            return true;
        }
        
        if (string1 == null || string2 == null) {
            return false;
        }

        if (string1.toUpperCase() == string2.toUpperCase()) {
            return true;
        } else {
            return false;
        }
    }

    public static String returnLabelOfField(String objectName, String fieldName) {
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName});
        String objectLabel = describeSobjectsResult[0].getLabel();
        Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
        String fieldLabel = allFields.get(fieldName).getDescribe().getLabel();

        return fieldLabel;
    }

    public static List<Schema.SObjectField> returnAPINames(String objectName) {
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName});
        String objectLabel = describeSobjectsResult[0].getLabel();
        Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
        
        return allFields.values();
    }

    public static String returnArabicFromAlpha(String romanValue) {
        if (romanValue == 'A') return '1';
        if (romanValue == 'B') return '2';
        if (romanValue == 'C') return '3';
        if (romanValue == 'D') return '4';
        if (romanValue == 'E') return '5';
        return romanValue;
    }

    public static String returnArabic(String romanValue) {
        if (romanValue == 'I') return '1';
        if (romanValue == 'II') return '2';
        if (romanValue == 'III') return '3';
        if (romanValue == 'IV') return '4';
        if (romanValue == 'V') return '5';
        if (romanValue == 'VI') return '6';
        if (romanValue == 'VII') return '7';
        if (romanValue == 'VIII') return '8';
        if (romanValue == 'IX') return '9';
        if (romanValue == 'X') return '10';
        return romanValue;
    }


    /*******************************************************************************
    *  Name            : returnRatingBasedOnSolvency(String solvencyIndex)
    *  Summary         : Return Rating based on solvency boundaries from custom settings
    *  CreatedDate     : 05/02/2018
    *  ModifiedDate    : 14/06/2019
    *  Parameters      : String solvencyIndex - index related to class rating, String country - country
    *  Returns         : String
    ******************************************************************************/
    public static String returnRatingBasedOnSolvency(String solvencyIndex, String country) {
        if (solvencyIndex != null && solvencyIndex.isNumeric()) {
            Integer solvencyIndexValue = Integer.valueOf(solvencyIndex);
            Solvency__c solvencySetting = Solvency__c.getAll().get(country);
            if (solvencyIndexValue >= solvencySetting.Rating_1_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_1_Maximum__c) return '1';
            if (solvencyIndexValue >= solvencySetting.Rating_2_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_2_Maximum__c) return '2';
            if (solvencyIndexValue >= solvencySetting.Rating_3_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_3_Maximum__c) return '3';
            if (solvencyIndexValue >= solvencySetting.Rating_4_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_4_Maximum__c) return '4';
            if (solvencyIndexValue >= solvencySetting.Rating_5_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_5_Maximum__c) return '5';
            if (solvencyIndexValue >= solvencySetting.Rating_6_Minimum__c && solvencyIndexValue <= solvencySetting.Rating_6_Maximum__c) return '6';
        }
        return solvencyIndex;
    }


    /*******************************************************************************
    *  Name            : returnArabicFromTrafficLight(String trafficLight)
    *  Summary         : green - 1, yellow - 2, red - 3    
    *  CreatedDate     : 11/01/2018
    *  ModifiedDate    : 11/01/2018
    *  Parameters      : String trafficLight - class Rating (green, yellow, red)
    *  Returns         : String
    ******************************************************************************/
    public static String returnArabicFromTrafficLight(String trafficLight) {
        if (trafficLight == 'GREEN') return '1';
        if (trafficLight == 'YELLOW') return '2';
        if (trafficLight == 'RED') return '3';

        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditLimitValue(String classRating)
    *  Summary         : return value of credit limit based on class rating (U+)    
    *  CreatedDate     : 12/01/2017
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String classRating - credit company rating
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditLimitValue(String classRating) {
        if (classRating != null) {
            String ratingLetter = classRating.substring(0, 1);
            if (ratingLetter == 'A') return '80000';
            else if (ratingLetter == 'B') return '40000';
            else if (ratingLetter == 'C') return '20000';
            else if (ratingLetter == 'D') return '10000';
            else if (ratingLetter == 'U') return '7000';
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnSolvencyIndex(String classRating)
    *  Summary         : return solvency index based on class rating (U+)
    *  CreatedDate     : 12/01/2017
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String classRating - credit company rating
    *  Returns         : String
    ******************************************************************************/
    public static String returnSolvencyIndex(String classRating) {
        if (classRating != null) {
            String ratingOperator = classRating.substring(1, classRating.length());
            if (ratingOperator == '+++') return '100';
            else if (ratingOperator == '++') return '200';
            else if (ratingOperator == '+') return '300';
            else if (ratingOperator == '-') return '400';
            else if (ratingOperator == '--') return '500';
            else if (ratingOperator == '---') return '600';
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnTurnOverValue(String classRating)
    *  Summary         : return value of Turn Over based on class rating (U+)
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String classRating - credit company rating
    *  Returns         : String
    ******************************************************************************/
    public static String returnTurnOverValue(String classRating) {
        if (classRating != null) {
            String ratingLetter = classRating.substring(0, 1);
            if (ratingLetter == 'A') return '>= 5 Million';
            else if (ratingLetter == 'B') return '500.000 - 5 Million';
            else if (ratingLetter == 'C') return '100.000 - 499.999';
            else if (ratingLetter == 'D') return '< 100000';
            else if (ratingLetter == 'U') return 'unknown';
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : getStreet(String streetAndHouseNumber)
    *  Summary         : Get Street name from BillingStreet without House Number
    *  CreatedDate     : 8/12/2016
    *  Parameters      : streetAndHouseNumber - BillingStreet(Street + House Number)
    *  Returns         : String 
    ******************************************************************************/
    public static String getStreet(String streetAndHouseNumber) {
        String street;
        if (streetAndHouseNumber != null) {
            if (! streetAndHouseNumber.substringAfterLast(' ').isAlpha()) {
                street = streetAndHouseNumber.substringBeforeLast(' ');
            } else if (! (streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ')).isAlphaSpace()) {
                street = streetAndHouseNumber.substringBeforeLast(' ').substringBeforeLast(' ');
            } else {
                street = streetAndHouseNumber.substringBeforeLast(' ').substringBeforeLast(' ').substringBeforeLast(' ');
            }
        }

        return street;
    }


    /*******************************************************************************
    *  Name            : getHousenumber(String streetAndHouseNumber)
    *  Summary         : Get House Number from BillingStreet without Street Name 
    *  CreatedDate     : 8/12/2016
    *  Parameters      : streetAndHouseNumber - BillingStreet(Street + House Number)
    *  Returns         : String 
    ******************************************************************************/
    public static String getHousenumber(String streetAndHouseNumber) {
        String housenumber;
        if (streetAndHouseNumber != null) {
            if (! streetAndHouseNumber.substringAfterLast(' ').isAlpha()) {
                housenumber = streetAndHouseNumber.substringAfterLast(' ');
            } else if (! (streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ')).isAlphaSpace()) {
                housenumber = streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ');
            } else {
                housenumber = streetAndHouseNumber.substringBeforeLast(' ').substringBeforeLast(' ') + ' ' + streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ');
            }

            housenumber = housenumber.substringBefore(' ').substringBefore('-').substringBefore('/').substringBefore('.').replaceAll('[^0-9]', '');
        }

        return housenumber;
    }


    /*******************************************************************************
    *  Name            : checkDuplicates(Opportunity currentOpportunity)
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 06/01/2018
    *  ModifiedDate    : 11/04/2019
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : void
    ******************************************************************************/
    public static String checkDuplicates(Opportunity currentOpportunity) {
        String exceptionString = checkOpportunityDuplicates(currentOpportunity);
        exceptionString += checkAccountDuplicates(currentOpportunity);
        exceptionString += checkContactDuplicates(currentOpportunity);
        return exceptionString;
    }


    /*******************************************************************************
    *  Name            : checkOpportunityDuplicates(Opportunity currentOpportunity)
    *  Summary         : if Opportunity duplicates is existed then stop credit process      
    *  CreatedDate     : 06/01/2018
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : String
    ******************************************************************************/
    private static String checkOpportunityDuplicates(Opportunity currentOpportunity) {
        String opportunitiesQuery = 'SELECT Name, IBAN__c, RecordType.Name, StageName, Gruende_verloren__c, Credit_System_Number__c, Creditreform_Nummer__c, AccountId' +
                ' FROM Opportunity' + 
                ' WHERE (RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\')' + ((currentOpportunity.Account.BillingCountry != null) ? ' AND ' + 
                    (currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' : 
                    (currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR Account.BillingCountry = \'Switzerland-FR\'' + 
                    ' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + clearFieldSOQL(currentOpportunity.Account.BillingCountry) + '\'')) : '') + ' AND (' + 
                    ((currentOpportunity.Name != '[nicht vorhanden]' && currentOpportunity.Name != 'New Inbound Lead') ? 'Name = \'' + 
                    clearFieldSOQL(currentOpportunity.Name) + '\'' : '') + ((currentOpportunity.IBAN__c != null && currentOpportunity.IBAN__c != 'n/a' && 
                    currentOpportunity.IBAN__c != 'X' && currentOpportunity.IBAN__c != 'x' && currentOpportunity.IBAN__c != 'XX' && 
                    currentOpportunity.IBAN__c != 'xx' && ! currentOpportunity.IBAN__c.containsIgnoreCase('XXX') && currentOpportunity.IBAN__c != 'DE000') ? 
                    ' OR IBAN__c = \'' + clearFieldSOQL(currentOpportunity.IBAN__c) + '\'' : '') + ((currentOpportunity.Credit_System_Number__c != null) ? 
                    ' OR Credit_System_Number__c = \'' + clearFieldSOQL(currentOpportunity.Credit_System_Number__c) + '\' OR Creditreform_Nummer__c = \'' + 
                    clearFieldSOQL(currentOpportunity.Credit_System_Number__c) + '\'' : '') +
                ') LIMIT 100';

        List<Opportunity> duplicateOpportunitiesList = Database.query(opportunitiesQuery);
        String exceptionString = '';
        if (! duplicateOpportunitiesList.isEmpty()) {
            Integer counter = 0;
            for (Opportunity opportunity : duplicateOpportunitiesList) {
                if ((opportunity.Name == currentOpportunity.Name || opportunity.IBAN__c == currentOpportunity.IBAN__c ||
                        opportunity.Credit_System_Number__c == currentOpportunity.Credit_System_Number__c || 
                        opportunity.Creditreform_Nummer__c == currentOpportunity.Credit_System_Number__c) &&
                        ! (opportunity.StageName == 'Closed Lost' && opportunity.Gruende_verloren__c != 'Refused Credit') &&
                        opportunity.Id != currentOpportunity.Id && opportunity.AccountId != currentOpportunity.AccountId) {
                    if (! exceptionString.contains('<br/>Duplicate Opportunities found:<br/>')) {
                        exceptionString += '<br/>Duplicate Opportunities found:<br/>';
                    }
                    exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + 
                        '">' + opportunity.Name + '</a>' + '<br/>';
                    counter ++;
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Name            : checkAccountDuplicates(Opportunity currentOpportunity)
    *  Summary         : if Account duplicates is existed then stop credit process      
    *  CreatedDate     : 06/01/2018
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : String
    ******************************************************************************/
    private static String checkAccountDuplicates(Opportunity currentOpportunity) {
        String accountsQuery = 'SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c, RecordType.Name, BillingCity, BillingStreet' +
                ' FROM Account' + 
                ' WHERE RecordType.Name = \'Endkunde\'' + ((currentOpportunity.Account.BillingCountry != null) ? ' AND ' + 
                    (currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(BillingCountry = \'Belgium-NL\' OR BillingCountry = \'Belgium-FR\')' : 
                    (currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(BillingCountry = \'Switzerland-DE\' OR BillingCountry = \'Switzerland-FR\'' + 
                    ' OR BillingCountry = \'Switzerland-IT\')' : 'BillingCountry = \'' + clearFieldSOQL(currentOpportunity.Account.BillingCountry) + '\'')) : '') + 
                    ' AND (' + ((currentOpportunity.Name != '[nicht vorhanden]' && currentOpportunity.Name != 'New Inbound Lead') ? 'Name = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.Name) + '\'' : '') + (currentOpportunity.Account.Umsatzsteuer_ID__c != null ? ' OR Umsatzsteuer_ID__c = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.Umsatzsteuer_ID__c) + '\'' : '') + (currentOpportunity.Account.Steuernummer__c != null &&
                    currentOpportunity.Account.Steuernummer__c != 'nicht bekannt' && currentOpportunity.Account.Steuernummer__c != 'unbekannt' &&
                    currentOpportunity.Account.Steuernummer__c != '0' ? ' OR Steuernummer__c = \'' + clearFieldSOQL(currentOpportunity.Account.Steuernummer__c) + '\'' : '') + 
                    (currentOpportunity.Account.BillingCity != null && currentOpportunity.Account.BillingStreet != null ? ' OR (BillingCity = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.BillingCity) + '\' AND BillingStreet = \'' + clearFieldSOQL(currentOpportunity.Account.BillingStreet) + '\')' : '') +
                ') LIMIT 6';

        String exceptionString = '';
        List<Account> duplicateAccountsList = Database.query(accountsQuery);
        if (! duplicateAccountsList.isEmpty()) {
            Integer counter = 0;
            for (Account account : duplicateAccountsList) {
                if ((account.Name == currentOpportunity.Account.Name || account.Steuernummer__c == currentOpportunity.Account.Steuernummer__c ||
                        account.Umsatzsteuer_ID__c == currentOpportunity.Account.Umsatzsteuer_ID__c || account.BillingCity == currentOpportunity.Account.BillingCity && 
                        account.BillingStreet == currentOpportunity.Account.BillingStreet) && account.Id != currentOpportunity.Account.Id) {
                    if (! exceptionString.contains('<br/>Duplicate Accounts found:<br/>')) {
                        exceptionString += '<br/>Duplicate Accounts found:<br/>';
                    }
                    exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + account.Id + '">' + account.Name + '</a>' + '<br/>';
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Name            : checkContactDuplicates(Opportunity currentOpportunity)
    *  Summary         : if Contact duplicates is existed then stop credit process      
    *  CreatedDate     : 06/01/2018
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : String
    ******************************************************************************/
    private static String checkContactDuplicates(Opportunity currentOpportunity) {
        Set<Id> currentContactsIdsSet = new Set<Id>();
        Set<String> contactEmailsSet = new Set<String>();
        Set<String> contactPhonesSet = new Set<String>();
        Set<String> contactFirstNamesSet = new Set<String>();
        Set<String> contactLastNamesSet = new Set<String>();
        Set<String> contactDataSet = new Set<String>();
        Map<String, Set<String>> contactLastNameToFirstNamesMap = new Map<String, Set<String>>();
        for (OpportunityContactRole contactRole : currentOpportunity.OpportunityContactRoles) {
            currentContactsIdsSet.add(contactRole.ContactId);
            String contactDataString = '';
            if (contactRole.Contact.FirstName != null) {
                contactFirstNamesSet.add(clearFieldSOQL(contactRole.Contact.FirstName));
                contactDataString += clearFieldSOQL(contactRole.Contact.FirstName) + ' ';
            }

            contactDataString += clearFieldSOQL(contactRole.Contact.LastName) + ' ';
            contactLastNamesSet.add(clearFieldSOQL(contactRole.Contact.LastName));
            if (contactRole.Contact.Email != null) {
                contactEmailsSet.add(clearFieldSOQL(contactRole.Contact.Email));
                contactDataString += clearFieldSOQL(contactRole.Contact.Email.substringAfter('@'));
            }

            contactDataSet.add(contactDataString);

            if (contactRole.Contact.Phone != null) {
                contactPhonesSet.add(clearFieldSOQL(contactRole.Contact.Phone));
            }
        }

        String contactsQuery = 'SELECT FirstName, LastName, Phone, Email, Name, Account.RecordType.Name' +
                ' FROM Contact' + 
                ' WHERE Account.RecordType.Name = \'Endkunde\'' + ((currentOpportunity.Account.BillingCountry != null) ? ' AND ' + 
                    (currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' : 
                    (currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR ' + 
                    'Account.BillingCountry = \'Switzerland-FR\' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.BillingCountry) + '\'')) : '') + ' AND (' + (! contactEmailsSet.isEmpty() ? 
                    'Email IN :contactEmailsSet OR ' : '') + (! contactPhonesSet.isEmpty() ? 'Phone IN :contactPhonesSet OR ' : '') +
                    ((! contactEmailsSet.isEmpty() && ! contactFirstNamesSet.isEmpty()) ? '(FirstName IN :contactFirstNamesSet AND LastName IN :contactLastNamesSet)' : '');
        contactsQuery = contactsQuery.removeEnd('OR ') + ') LIMIT 20';
        String exceptionString = '';
        if (! contactsQuery.endsWith('() LIMIT 20')) {
            List<Contact> duplicateContactsList = Database.query(contactsQuery);
            if (! duplicateContactsList.isEmpty()) {
                Integer counter = 0;
                for (Contact contact : duplicateContactsList) {
                    if ((contactEmailsSet.contains(contact.Email) || contactPhonesSet.contains(contact.Phone) || 
                            (contact.Email != null && contactDataSet.contains(contact.FirstName + ' ' + contact.LastName + ' ' + contact.Email.substringAfter('@')))) &&
                            ! currentContactsIdsSet.contains(contact.Id)
                            ) {
                        if (! exceptionString.contains('<br/>Duplicate Contacts found:<br/>')) {
                            exceptionString += '<br/>Duplicate Contacts found:<br/>';
                        }

                        exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + contact.Id + 
                            '">' + contact.Name + '</a>' + '<br/>';
                        counter ++;
                        if (counter == 5) {
                            break;
                        }
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Name            : clearFieldSOQL(String field)
    *  Summary         : remove illegal characters from field for SOQL    
    *  CreatedDate     : 23/01/2017
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String field - field for SOQL
    *  Returns         : String
    ******************************************************************************/
    private static String clearFieldSOQL(String field) {
        if (field != null && field.contains('\'')) field = field.replace('\'', '\\\'');
        return field;
    }


    /*******************************************************************************
    *  Name            : clearErrorMessage(String error)
    *  Summary         : remove waste characters from error message    
    *  CreatedDate     : 09/02/2018
    *  ModifiedDate    : 09/02/2018
    *  Parameters      : String error - error message
    *  Returns         : String
    ******************************************************************************/
    public static String clearErrorMessage(String error) {
        if (error.contains('BLACK LIST')) {
            String comment = error.substringBetween('^^');
            error = 'Company found in black list. Please refer to credit.' + 
                    (comment != null ? '\nComment: ' + comment : '');
        } else if (error.contains('Duplicate Opportunities found:') || 
            error.contains('Duplicate Accounts found:') || 
            error.contains('Duplicate Contacts found:')) {
            error = 'Duplicates found.';
        } else if (error == 'Fix all validation errors or refer to Credit.') {
            error = '';
        }

        error = error.replace('<br/>', '').replace('<ul>', '').replace('</ul>', '').replace('<li>', '\n').replace('</li>', '');
        return error;
    }


    /*******************************************************************************
    *  Name            : getKvk(String kvk)
    *  Summary         : get Kvk number for search    
    *  CreatedDate     : 12/02/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String kvk
    *  Returns         : String
    ******************************************************************************/
    public static String getKvk(String kvk) {
        if (kvk != null && kvk.length() == 10 && kvk.startsWith('0')) return kvk.substring(1, 10); 
        return kvk;
    }


    /*******************************************************************************
    *  Name            : replaceGermanCharacters(String stringInGerman)
    *  Summary         : replace letter-diacritic combinations Ä/ä, Ö/ö, Ü/ü and ligatures ß.
    *  CreatedDate     : 29/03/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String stringInGerman - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceGermanCharacters(String stringInGerman) {
        if (stringInGerman != null) {
            if (stringInGerman.contains('Ä')) stringInGerman = stringInGerman.replace('Ä', 'AE');
            if (stringInGerman.contains('ä')) stringInGerman = stringInGerman.replace('ä', 'ae');
            if (stringInGerman.contains('Ö')) stringInGerman = stringInGerman.replace('Ö', 'OE');
            if (stringInGerman.contains('ö')) stringInGerman = stringInGerman.replace('ö', 'oe');
            if (stringInGerman.contains('Ü')) stringInGerman = stringInGerman.replace('Ü', 'UE');
            if (stringInGerman.contains('ü')) stringInGerman = stringInGerman.replace('ü', 'ue');
            // "ß" cannot be capital
            if (stringInGerman.contains('ß')) stringInGerman = stringInGerman.replace('ß', 'ss');
        }

        return stringInGerman;
    }


    /*******************************************************************************
    *  Name            : replacePolishCharacters(String stringInPolish)
    *  Summary         : Replace Ć, ć, Ń, ń, Ó, ó, Ś, ś, Ź, ź, Ż, ż, Ą, ą, Ę, ę, Ł, ł, X, x.
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String stringInPolish - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replacePolishCharacters(String stringInPolish) {
        if (stringInPolish != null) {
            if (stringInPolish.contains('Ć')) stringInPolish = stringInPolish.replace('Ć', 'C');
            if (stringInPolish.contains('ć')) stringInPolish = stringInPolish.replace('ć', 'c');
            if (stringInPolish.contains('Ń')) stringInPolish = stringInPolish.replace('Ń', 'N');
            if (stringInPolish.contains('ń')) stringInPolish = stringInPolish.replace('ń', 'n');
            if (stringInPolish.contains('Ó')) stringInPolish = stringInPolish.replace('Ó', 'O');
            if (stringInPolish.contains('ó')) stringInPolish = stringInPolish.replace('ó', 'o');
            if (stringInPolish.contains('Ś')) stringInPolish = stringInPolish.replace('Ś', 'S');
            if (stringInPolish.contains('ś')) stringInPolish = stringInPolish.replace('ś', 's');
            if (stringInPolish.contains('Ź')) stringInPolish = stringInPolish.replace('Ź', 'Z');
            if (stringInPolish.contains('ź')) stringInPolish = stringInPolish.replace('ź', 'z');
            if (stringInPolish.contains('Ż')) stringInPolish = stringInPolish.replace('Ż', 'Z');
            if (stringInPolish.contains('ż')) stringInPolish = stringInPolish.replace('ż', 'z');
            if (stringInPolish.contains('Ą')) stringInPolish = stringInPolish.replace('Ą', 'A');
            if (stringInPolish.contains('ą')) stringInPolish = stringInPolish.replace('ą', 'a');
            if (stringInPolish.contains('Ę')) stringInPolish = stringInPolish.replace('Ę', 'E');
            if (stringInPolish.contains('ę')) stringInPolish = stringInPolish.replace('ę', 'e');
            if (stringInPolish.contains('Ł')) stringInPolish = stringInPolish.replace('Ł', 'L');
            if (stringInPolish.contains('ł')) stringInPolish = stringInPolish.replace('ł', 'l');
            if (stringInPolish.contains('X')) stringInPolish = stringInPolish.replace('X', 'KS');
            if (stringInPolish.contains('x')) stringInPolish = stringInPolish.replace('x', 'ks');
        }

        return stringInPolish;
    }


    /*******************************************************************************
    *  Name            : replaceHungarianCharacters(String stringInHungarian)
    *  Summary         : Replace Á, á, É, é, Í, í, Ó, ó, Ö, ö, Ő, ő, Ú, ú, Ü, ü, Ű, ű.     
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String stringInHungarian - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceHungarianCharacters(String stringInHungarian) {
        if (stringInHungarian != null) {
            if (stringInHungarian.contains('Á')) stringInHungarian = stringInHungarian.replace('Á', 'A');
            if (stringInHungarian.contains('á')) stringInHungarian = stringInHungarian.replace('á', 'a');
            if (stringInHungarian.contains('É')) stringInHungarian = stringInHungarian.replace('É', 'E');
            if (stringInHungarian.contains('é')) stringInHungarian = stringInHungarian.replace('é', 'e');
            if (stringInHungarian.contains('Í')) stringInHungarian = stringInHungarian.replace('Í', 'I');
            if (stringInHungarian.contains('í')) stringInHungarian = stringInHungarian.replace('í', 'i');
            if (stringInHungarian.contains('Ó')) stringInHungarian = stringInHungarian.replace('Ó', 'O');
            if (stringInHungarian.contains('ó')) stringInHungarian = stringInHungarian.replace('ó', 'o');
            if (stringInHungarian.contains('Ö')) stringInHungarian = stringInHungarian.replace('Ö', 'O');
            if (stringInHungarian.contains('ö')) stringInHungarian = stringInHungarian.replace('ö', 'o');
            if (stringInHungarian.contains('Ő')) stringInHungarian = stringInHungarian.replace('Ő', 'O');
            if (stringInHungarian.contains('ő')) stringInHungarian = stringInHungarian.replace('ő', 'o');
            if (stringInHungarian.contains('Ú')) stringInHungarian = stringInHungarian.replace('Ú', 'U');
            if (stringInHungarian.contains('ú')) stringInHungarian = stringInHungarian.replace('ú', 'u');
            if (stringInHungarian.contains('Ü')) stringInHungarian = stringInHungarian.replace('Ü', 'U');
            if (stringInHungarian.contains('ü')) stringInHungarian = stringInHungarian.replace('ü', 'u');
            if (stringInHungarian.contains('Ű')) stringInHungarian = stringInHungarian.replace('Ű', 'U');
            if (stringInHungarian.contains('ű')) stringInHungarian = stringInHungarian.replace('ű', 'u');
        }

        return stringInHungarian;
    }


    /*******************************************************************************
    *  Name            : replaceFrenchCharacters(String stringInFrench)
    *  Summary         : Replace Ç, ç, É, é, Â, â, Ê, ê, Î, î, Ô, ô, Û, û, À, à, È, è, Ù, ù, Ë, ë, Ï, ï, Ü, ü.
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String stringInFrench - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceFrenchCharacters(String stringInFrench) {
        if (stringInFrench != null) {
            if (stringInFrench.contains('Ç')) stringInFrench = stringInFrench.replace('Ç', 'C');
            if (stringInFrench.contains('ç')) stringInFrench = stringInFrench.replace('ç', 'c');
            if (stringInFrench.contains('É')) stringInFrench = stringInFrench.replace('É', 'E');
            if (stringInFrench.contains('é')) stringInFrench = stringInFrench.replace('é', 'e');
            if (stringInFrench.contains('Â')) stringInFrench = stringInFrench.replace('Â', 'A');
            if (stringInFrench.contains('â')) stringInFrench = stringInFrench.replace('â', 'a');
            if (stringInFrench.contains('Ê')) stringInFrench = stringInFrench.replace('Ê', 'E');
            if (stringInFrench.contains('ê')) stringInFrench = stringInFrench.replace('ê', 'e');
            if (stringInFrench.contains('Î')) stringInFrench = stringInFrench.replace('Î', 'I');
            if (stringInFrench.contains('î')) stringInFrench = stringInFrench.replace('î', 'i');
            if (stringInFrench.contains('Ô')) stringInFrench = stringInFrench.replace('Ô', 'O');
            if (stringInFrench.contains('ô')) stringInFrench = stringInFrench.replace('ô', 'o');
            if (stringInFrench.contains('Û')) stringInFrench = stringInFrench.replace('Û', 'U');
            if (stringInFrench.contains('û')) stringInFrench = stringInFrench.replace('û', 'u');
            if (stringInFrench.contains('À')) stringInFrench = stringInFrench.replace('À', 'A');
            if (stringInFrench.contains('à')) stringInFrench = stringInFrench.replace('à', 'a');
            if (stringInFrench.contains('È')) stringInFrench = stringInFrench.replace('È', 'E');
            if (stringInFrench.contains('è')) stringInFrench = stringInFrench.replace('è', 'e');
            if (stringInFrench.contains('Ù')) stringInFrench = stringInFrench.replace('Ù', 'U');
            if (stringInFrench.contains('Ë')) stringInFrench = stringInFrench.replace('Ë', 'E');
            if (stringInFrench.contains('ë')) stringInFrench = stringInFrench.replace('ë', 'e');
            if (stringInFrench.contains('Ï')) stringInFrench = stringInFrench.replace('Ï', 'I');
            if (stringInFrench.contains('ï')) stringInFrench = stringInFrench.replace('ï', 'i');
            if (stringInFrench.contains('Ü')) stringInFrench = stringInFrench.replace('Ü', 'U');
            if (stringInFrench.contains('ü')) stringInFrench = stringInFrench.replace('ü', 'u');
        }

        return stringInFrench;
    }


    /*******************************************************************************
    *  Name            : replaceDutchCharacters(String stringInDutch)
    *  Summary         : Replace Á, á, É, é, Í, í, Ó, ó, Ú, ú, À, à, È, è, Ï, ï, Ö, ö, Ü, ü
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : String stringInDutch - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceDutchCharacters(String stringInDutch) {
        if (stringInDutch != null) {
            if (stringInDutch.contains('Á')) stringInDutch = stringInDutch.replace('Á', 'A');
            if (stringInDutch.contains('á')) stringInDutch = stringInDutch.replace('á', 'a');
            if (stringInDutch.contains('É')) stringInDutch = stringInDutch.replace('É', 'E');
            if (stringInDutch.contains('é')) stringInDutch = stringInDutch.replace('é', 'e');
            if (stringInDutch.contains('Í')) stringInDutch = stringInDutch.replace('Í', 'I');
            if (stringInDutch.contains('í')) stringInDutch = stringInDutch.replace('í', 'i');
            if (stringInDutch.contains('Ó')) stringInDutch = stringInDutch.replace('Ó', 'O');
            if (stringInDutch.contains('ó')) stringInDutch = stringInDutch.replace('ó', 'o');
            if (stringInDutch.contains('Ú')) stringInDutch = stringInDutch.replace('Ú', 'U');
            if (stringInDutch.contains('ú')) stringInDutch = stringInDutch.replace('ú', 'u');
            if (stringInDutch.contains('À')) stringInDutch = stringInDutch.replace('À', 'A');
            if (stringInDutch.contains('à')) stringInDutch = stringInDutch.replace('à', 'a');
            if (stringInDutch.contains('È')) stringInDutch = stringInDutch.replace('È', 'E');
            if (stringInDutch.contains('è')) stringInDutch = stringInDutch.replace('è', 'e');
            if (stringInDutch.contains('Ï')) stringInDutch = stringInDutch.replace('Ï', 'I');
            if (stringInDutch.contains('ï')) stringInDutch = stringInDutch.replace('ï', 'i');
            if (stringInDutch.contains('Ö')) stringInDutch = stringInDutch.replace('Ö', 'O');
            if (stringInDutch.contains('ö')) stringInDutch = stringInDutch.replace('ö', 'o');
            if (stringInDutch.contains('Ü')) stringInDutch = stringInDutch.replace('Ü', 'U');
            if (stringInDutch.contains('ü')) stringInDutch = stringInDutch.replace('ü', 'u');
        }

        return stringInDutch;
    }


    /*******************************************************************************
    *  Name            : returnIndicationOrganisation(String indicationOrganisationCode)
    *  Summary         : Return Indication Organisation based on code.
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : 15/06/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationOrganisation(String indicationOrganisationCode) {
        if (indicationOrganisationCode == 'O') return 'Onderneming'; // "Business"
        else if (indicationOrganisationCode == 'V') return 'Vereniging'; // "Association"
        else if (indicationOrganisationCode == 'S') return 'Stichting'; // Non-profit organisation
        else if (indicationOrganisationCode == 'K') return 'Kerkgenootschap'; // Church community

        return null;
    }


    /*******************************************************************************
    *  Name            : returnReferenceForLexisNexis(String countryCode)
    *  Summary         : Return reference for LexisNexis requests
    *  CreatedDate     : 02/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String countryCode - country code (DE, NL etc.)
    *  Returns         : String
    ******************************************************************************/
    public static String returnReferenceForLexisNexis(String countryCode) {
        Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        String orgType = '';
        if (org.IsSandbox) orgType = 'TEST';

        return orgType + 'CF' + countryCode;
    }


    /*******************************************************************************
    *  Name            : returnEmailStatus(String statusId)
    *  Summary         : Return Email Status based on Status Id
    *  CreatedDate     : 16/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String statusId - Email Status Id
    *  Returns         : String 
    ******************************************************************************/
    public static String returnEmailStatus(String statusId) {
        if (statusId == '0') return 'GeneralError';
        else if (statusId == '1') return 'Certified';
        else if (statusId == '2') return 'Verified';
        else if (statusId == '3') return 'EmailNonexistent';
        else if (statusId == '4') return 'ValidDomain';
        else if (statusId == '5') return 'DomainNonexistent';

        return statusId;
    }


    /*******************************************************************************
    *  Name            : returnEmailRisk(String riskBand)
    *  Summary         : Return Email Risk based on Risk Band    
    *  CreatedDate     : 02/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String riskBand - Fraud Risk Band
    *  Returns         : String 
    ******************************************************************************/
    public static String returnEmailRisk(String riskBand) {
        if (riskBAnd == '1') return 'Very Low';
        else if (riskBAnd == '2') return 'Low';
        else if (riskBAnd == '3') return 'Moderate';
        else if (riskBAnd == '4') return 'Review';
        else if (riskBAnd == '5') return 'High';
        else if (riskBAnd == '6') return 'Very High';

        return riskBAnd;
    }


    /*******************************************************************************
    *  Name            : returnRiskDescription(String descriptionId)
    *  Summary         : Return Risk Description based on Description Id    
    *  CreatedDate     : 16/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String riskDescriptionId - Description Id
    *  Returns         : String 
    ******************************************************************************/
    public static String returnRiskDescription(String descriptionId) {
        if (descriptionId == '1') return 'Fraud Level X';
        else if (descriptionId == '2') return 'Email does not exist';
        else if (descriptionId == '3') return 'Domain does not exist';
        else if (descriptionId == '4') return 'Risky Domain';
        else if (descriptionId == '5') return 'Risky Country';
        else if (descriptionId == '6') return 'Risky Email Syntax';
        else if (descriptionId == '7') return 'Numeric Email';
        else if (descriptionId == '8') return 'Limited History for Email';
        else if (descriptionId == '9') return 'Email Recently Created';
        else if (descriptionId == '10') return 'Email linked to High Risk Account';
        else if (descriptionId == '11') return 'Good Level X';
        else if (descriptionId == '12') return 'Low Risk Domain';
        else if (descriptionId == '13') return 'Email Created X Years Ago';
        else if (descriptionId == '14') return 'Email Created at least X Years Ago';
        else if (descriptionId == '15') return 'Email Linked to Low Risk Account';
        else if (descriptionId == '16') return 'Invalid Email Syntax';
        else if (descriptionId == '17') return 'Mailbox is Full';
        else if (descriptionId == '18') return 'Mailbox is Inactive';
        else if (descriptionId == '19') return 'Corporate Link';
        else if (descriptionId == '20') return 'Mailbox is Expired';
        else if (descriptionId == '21') return 'User Defined Risk Domain';
        else if (descriptionId == '22') return 'User Defined Low Risk Domain';
        else if (descriptionId == '23') return 'Velocity Level X';
        else if (descriptionId == '24') return 'Risk Domain Category';
        else if (descriptionId == '25') return 'Low Risk Domain Category';
        else if (descriptionId == '26') return 'High Risk Email Account';
        else if (descriptionId == '27') return 'Email Created at least X Months Ago';
        else if (descriptionId == '28') return 'Valid Email From X Country Domain';
        else if (descriptionId == '29') return 'Valid Domain From X Country';
        else if (descriptionId == '30') return 'Potentially Breached Email';
        else if (descriptionId == '31') return 'Fraud Emails Linked X';
        else if (descriptionId == '32') return 'Good Email Linked Level X';
        else if (descriptionId == '33') return 'Fraud IP Level X';
        else if (descriptionId == '34') return 'Good IP Level X';
        else if (descriptionId == '35') return 'Risky Proxy IP';
        else if (descriptionId == '36') return 'Risk IP Behavior';
        else if (descriptionId == '37') return 'Risky IP Country';
        else if (descriptionId == '38') return 'IP Not Found';
        else if (descriptionId == '39') return 'IP Invalid Syntax Format';
        else if (descriptionId == '40') return 'High Risk IP';
        else if (descriptionId == '51') return 'Good Popularity';
        else if (descriptionId == '52') return 'Risk Domain Category Review';
        else if (descriptionId == '53') return 'Tumbling Abuse';
        else if (descriptionId == '54') return 'Email Enumeration for Company';
        else if (descriptionId == '55') return 'Email Enumeration for Industry';
        else if (descriptionId == '56') return 'Creation Date Velocity';
        else if (descriptionId == '61') return 'Customer Email not Provided';
        else if (descriptionId == '62') return 'Risk Email Pattern';
        else if (descriptionId == '63') return 'Suspected Fraud';
        else if (descriptionId == '64') return 'Limited Email Information';
        else if (descriptionId == '65') return 'Domain Recently Created';
        else if (descriptionId == '66') return 'Velocity Other';
        else if (descriptionId == '67') return 'Valid Email From Domain';
        else if (descriptionId == '68') return 'Valid Domain';
        else if (descriptionId == '101') return 'Low Risk Email Domain for Company';
        else if (descriptionId == '102') return 'Low Risk IP for Company';
        else if (descriptionId == '103') return 'Low Risk IP Geolocation for Company';
        else if (descriptionId == '104') return 'Low Risk Email Domain for Industry';
        else if (descriptionId == '105') return 'Low Risk IP for Industry';
        else if (descriptionId == '106') return 'Low Risk IP Geolocation for Industry';
        else if (descriptionId == '107') return 'Low Risk Email Domain for Network';
        else if (descriptionId == '108') return 'Low Risk IP for Network';
        else if (descriptionId == '109') return 'Low Risk IP Geolocation for Network';
        else if (descriptionId == '110') return 'Very Low Risk Email Domain for Company';
        else if (descriptionId == '111') return 'Very Low Risk IP for Company';
        else if (descriptionId == '112') return 'Very Low Risk IP Geolocation for Company';
        else if (descriptionId == '113') return 'Very Low Risk Email Domain for Industry';
        else if (descriptionId == '114') return 'Very Low Risk IP for Industry';
        else if (descriptionId == '115') return 'Very Low Risk IP Geolocation for Industry';
        else if (descriptionId == '116') return 'Very Low Risk Email Domain for Network';
        else if (descriptionId == '117') return 'Very Low Risk IP for Network';
        else if (descriptionId == '118') return 'Very Low Risk IP Geolocation for Network';
        else if (descriptionId == '121') return 'High Risk Email Domain for Company';
        else if (descriptionId == '122') return 'High Risk IP for Company';
        else if (descriptionId == '123') return 'High Risk IP Geolocation for Company';
        else if (descriptionId == '124') return 'High Risk Email Domain for Industry';
        else if (descriptionId == '125') return 'High Risk IP for Industry';
        else if (descriptionId == '126') return 'High Risk IP Geolocation for Industry';
        else if (descriptionId == '127') return 'High Risk Email Domain for Network';
        else if (descriptionId == '128') return 'High Risk IP for Network';
        else if (descriptionId == '129') return 'High Risk IP Geolocation for Network';
        else if (descriptionId == '130') return 'Very High Risk Email Domain for Company';
        else if (descriptionId == '131') return 'Very High Risk IP for Company';
        else if (descriptionId == '132') return 'Very High Risk IP Geolocation for Company';
        else if (descriptionId == '133') return 'Very High Risk Email Domain for Industry';
        else if (descriptionId == '134') return 'Very High Risk IP for Industry';
        else if (descriptionId == '135') return 'Very High Risk IP Geolocation for Industry';
        else if (descriptionId == '136') return 'Very High Risk Email Domain for Network';
        else if (descriptionId == '137') return 'Very High Risk IP for Network';
        else if (descriptionId == '138') return 'Very High Risk IP Geolocation for Network';
        else if (descriptionId == '139') return 'High Risk Phone for Company';
        else if (descriptionId == '140') return 'High Risk Ship Address for Company';
        else if (descriptionId == '141') return 'High Risk Phone for Industry';
        else if (descriptionId == '142') return 'High Risk Ship Address for Industry';
        else if (descriptionId == '143') return 'High Risk Phone for Network';
        else if (descriptionId == '144') return 'High Risk Ship Address for Network';
        else if (descriptionId == '145') return 'Very High Risk Phone for Company';
        else if (descriptionId == '146') return 'Very High Risk Ship Address for Company';
        else if (descriptionId == '147') return 'Very High Risk Phone for Industry';
        else if (descriptionId == '148') return 'Very High Risk Ship Address for Industry';
        else if (descriptionId == '149') return 'Very High Risk Phone for Network';
        else if (descriptionId == '150') return 'Very High Risk Ship Address for Network';
        else if (descriptionId == '151') return 'High Risk Bill Address For Company';
        else if (descriptionId == '152') return 'High Risk Customer ID For Company';
        else if (descriptionId == '153') return 'High Risk Service Location For Company';
        else if (descriptionId == '154') return 'High Risk Bill Address For Industry';
        else if (descriptionId == '155') return 'High Risk Customer ID For Industry';
        else if (descriptionId == '156') return 'High Risk Service Location For Industry';
        else if (descriptionId == '157') return 'High Risk Bill Address For Network';
        else if (descriptionId == '158') return 'High Risk Customer ID For Network';
        else if (descriptionId == '159') return 'High Risk Service Location For Network';
        else if (descriptionId == '160') return 'Very High Risk Bill Address For Company';
        else if (descriptionId == '161') return 'Very High Risk Customer ID For Company';
        else if (descriptionId == '162') return 'Very High Risk Service Location For Company';
        else if (descriptionId == '163') return 'Very High Risk Bill Address For Industry';
        else if (descriptionId == '164') return 'Very High Risk Customer ID For Industry';
        else if (descriptionId == '165') return 'Very High Risk Service Location For Industry';
        else if (descriptionId == '166') return 'Very High Risk Bill Address For Network';
        else if (descriptionId == '167') return 'Very High Risk Customer ID For Network';
        else if (descriptionId == '168') return 'Very High Risk Service Location For Network';
        return descriptionId;
    }


    /*******************************************************************************
    *  Name            : returnRiskAdvice(String adviceId)
    *  Summary         : Return Risk Advice based on Advice Id    
    *  CreatedDate     : 16/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String adviceId - Advice Id
    *  Returns         : String
    ******************************************************************************/
    public static String returnRiskAdvice(String adviceId) {
        if (adviceId == '1') return 'Fraud Review';
        else if (adviceId == '2') return 'Unclear Risk';
        else if (adviceId == '3') return 'Lower Fraud Risk';
        else if (adviceId == '4') return 'Moderate Fraud Risk';
        else if (adviceId == '11') return 'Data Entry Review';
        else if (adviceId == '1001') return 'Custom Fraud Score Define';
        return adviceId;
    }


    /*******************************************************************************
    *  Name            : returnNameMatch(String nameMatchAbbreviation)
    *  Summary         : Return Name Match based on abbreviation
    *  CreatedDate     : 16/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String nameMatchAbbreviation - Name Match abbreviation
    *  Returns         : String
    ******************************************************************************/
    public static String returnNameMatch(String nameMatchAbbreviation) {
        if (nameMatchAbbreviation == 'Y') return 'Full Match';
        else if (nameMatchAbbreviation == 'P') return 'Partial Match';
        else if (nameMatchAbbreviation == 'N') return 'No Match';
        else if (nameMatchAbbreviation == 'U') return 'Owner Unknown';
        return nameMatchAbbreviation;
    }


    /*******************************************************************************
    *  Name            : areDatesEqual(Date firstDate, Date secondDate)
    *  Summary         : Compare 2 dates for equality
    *  CreatedDate     : 18/09/2019
    *  ModifiedDate    : -
    *  Parameters      : Date firstDate - first date to compare, Date secondDate - second date to compare
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean areDatesEqual(Date firstDate, Date secondDate) {
        if (firstDate != null && secondDate != null) {
            if (firstDate.year() == secondDate.year() && firstDate.month() == secondDate.month() &&
                    firstDate.day() == secondDate.day()) {
                return true;
            }
        }

        return false;
    }
    
    
    /*******************************************************************************
	*  Name 		   : validateProfile()
	*  Summary         : Check that user profile has access to CF
	*  CreatedDate     : 11/11/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public static String validateProfile() {
		String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (Credit_Factory_User_Profile__c.getInstance(profileName) == null)  {
            return 'Your profile doesn\'t have access to Credit Factory.';
        } else {
            return null;
        }
	}
    
    
    /*******************************************************************************
    *  Summary         : Search company in black list
    *  Created         : 05/02/2020
    *  Parameters      : opportunity - current opportunity
    *  Returns         : map of results
    ******************************************************************************/
    public static Map<String, Object> validateBlackList(Opportunity opportunity) {
        Map<String, Object> resultsMap = new Map<String, Object>();
        List<Contact> accountContactsList = [
                SELECT FirstName, LastName, Email, Phone, MobilePhone
                FROM Contact
                WHERE AccountId = :opportunity.AccountId
                LIMIT 1000];
        Set<String> contactsEmailsSet = new Set<String>();
        Set<String> contactsNamesSet = new Set<String>();
        Set<String> contactsPhonesSet = new Set<String>();
        for (Contact con : accountContactsList) {
        	if (con.Email != null) {
	            contactsEmailsSet.add(con.Email.toUpperCase());
	        }

	        String firstName = '';
	        if (con.FirstName != null) {
	        	firstName = con.FirstName;
	        }

	        String name1 = (firstName.toUpperCase() + ' ' + con.LastName.toUpperCase()).removeStart(' ');
	        contactsNamesSet.add(name1);
	        String name2 = (con.LastName.toUpperCase() + ' ' + firstName.toUpperCase()).removeEnd(' ');
	        contactsNamesSet.add(name2);

	        if (con.Phone != null) {
	        	contactsPhonesSet.add(con.Phone);
	        }
	        if (con.MobilePhone != null) {
	        	contactsPhonesSet.add(con.MobilePhone);
	        }
        }

        List<Credit_Black_List_Company__c> blackListCompaniesList = [
                SELECT Customer_Full_Name__c, Trade_Register_Number__c, VATReg_Number__c, Reg_Address_Address_Lines__c, 
                	  	Reg_Address_City__c, Reg_Address_Country__c, Reg_Address_Zip_Code__c, Primary_Phone__c, Primary_Email__c, 
                	  	Primary_Contact__c, IBAN__c, Name, Comment__c, TAX_ID__c, IP_Address__c
                FROM Credit_Black_List_Company__c
                WHERE Customer_Id__c != null AND Customer_Id__c = :opportunity.Account.BillingCountryCode.substring(0, 2) AND
                	  	((Customer_Full_Name__c != null AND Customer_Full_Name__c = :opportunity.Account.Name) OR 
                	  	(TAX_ID__c != null AND TAX_ID__c = :opportunity.Account.Steuernummer__c) OR
                      	(VATReg_Number__c != null AND VATReg_Number__c = :opportunity.Account.Umsatzsteuer_ID__c) OR
                      	(Trade_Register_Number__c != null AND Trade_Register_Number__c = :opportunity.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c) OR
                            (((Reg_Address_Address_Lines__c != null AND Reg_Address_Address_Lines__c  = :opportunity.Account.BillingStreet) OR Reg_Address_Address_Lines__c = null) AND
                            ((Reg_Address_City__c != null AND Reg_Address_City__c = :opportunity.Account.BillingCity) OR (Reg_Address_Zip_Code__c != null AND Reg_Address_Zip_Code__c = :opportunity.Account.BillingPostalCode))) OR
                      	(Primary_Phone__c != null AND Primary_Phone__c IN :contactsPhonesSet) OR 
                      	(Primary_Email__c != null AND Primary_Email__c IN :contactsEmailsSet) OR
                      	(Primary_Contact__c != null AND Primary_Contact__c IN :contactsNamesSet) OR
                      	(IBAN__c != null AND IBAN__c = :opportunity.IBAN__c) OR 
                        (IP_Address__c != null AND IP_Address__c = :opportunity.Visitor_ID__c))
                LIMIT 1];

        if ( ! blackListCompaniesList.isEmpty()) {
            resultsMap.put('IsValid', false);
        	String error = returnBlackListError(blackListCompaniesList.get(0),
                                                opportunity,
                                                contactsEmailsSet,
                                                contactsNamesSet,
                                                contactsPhonesSet);
            resultsMap.put('Error', error);
        } 
        else {
            resultsMap.put('IsValid', true);
        }
        
        return resultsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return exception if black list validation failed
    *  CreatedDate     : 12/09/2019 by Anton Buzak
    *  Parameters      : blackListCompany - black list company, 
                         name - company name, 
                         opportunity - opportunity
    *  Returns         : Exception
    ******************************************************************************/
    private static String returnBlackListError(Credit_Black_List_Company__c blackListCompany, 
                                               Opportunity opportunity,
                                               Set<String> contactsEmailsSet, 
                                               Set<String> contactsNamesSet, 
                                               Set<String> contactsPhonesSet) {
        String errorMessage = '<strong>BLACK LIST.</strong> Company found in black list. Please refer to credit. ';
        errorMessage = errorMessage + 'Click <a target="_blank" href="/' + blackListCompany.Id + '">here</a>.';

        errorMessage += '<br/><br/>Matched fields:<br/><ul>';
        if (blackListCompany.Customer_Full_Name__c != null && blackListCompany.Customer_Full_Name__c == opportunity.Account.Name) {
            errorMessage += '<li>Account Name: ' + opportunity.Account.Name + '</li>';
        }

        if (blackListCompany.TAX_ID__c != null && blackListCompany.TAX_ID__c == opportunity.Account.Steuernummer__c) {
            errorMessage += '<li>Tax Id: ' + opportunity.Account.Steuernummer__c + '</li>';
        }

        if (blackListCompany.VATReg_Number__c != null && blackListCompany.VATReg_Number__c == opportunity.Account.Umsatzsteuer_ID__c) {
            errorMessage += '<li>VAT Number: ' + opportunity.Account.Umsatzsteuer_ID__c + '</li>';
        }

        if (blackListCompany.Trade_Register_Number__c != null && blackListCompany.Trade_Register_Number__c == opportunity.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c) {
            errorMessage += '<li>Trade Register Number: ' + opportunity.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c + '</li>';
        }

        if ((blackListCompany.Reg_Address_Address_Lines__c != null && blackListCompany.Reg_Address_Address_Lines__c == opportunity.Account.BillingStreet || blackListCompany.Reg_Address_Address_Lines__c == null) && 
                (blackListCompany.Reg_Address_City__c != null && blackListCompany.Reg_Address_City__c == opportunity.Account.BillingCity || 
                blackListCompany.Reg_Address_Zip_Code__c != null && blackListCompany.Reg_Address_Zip_Code__c == opportunity.Account.BillingPostalCode)) {
            errorMessage += '<li>Registered Address:<br/>' + 
                (opportunity.Account.BillingStreet != null ? opportunity.Account.BillingStreet : '') + '<br/>' + 
                (opportunity.Account.BillingPostalCode != null ? opportunity.Account.BillingPostalCode : '') + ' ' + (opportunity.Account.BillingCity != null ? opportunity.Account.BillingCity : '') + '<br/>' + 
                opportunity.Account.BillingCountry + '</li>';
        }

        if (blackListCompany.Primary_Phone__c != null && contactsPhonesSet.contains(blackListCompany.Primary_Phone__c)) {
            errorMessage += '<li>Contact Phone Number: ' + blackListCompany.Primary_Phone__c + '</li>';
        }

        if (blackListCompany.Primary_Email__c != null && contactsEmailsSet.contains(blackListCompany.Primary_Email__c.toUpperCase())) {
            errorMessage += '<li>Contact Email: ' + blackListCompany.Primary_Email__c + '</li>';
        }

        if (blackListCompany.Primary_Contact__c != null && contactsNamesSet.contains(blackListCompany.Primary_Contact__c.toUpperCase())) {
            errorMessage += '<li>Contact Name: ' + blackListCompany.Primary_Contact__c + '</li>';
        }

        if (blackListCompany.IBAN__c != null && blackListCompany.IBAN__c == opportunity.IBAN__c) {
            errorMessage += '<li>IBAN: ' + opportunity.IBAN__c + '</li>';
        }
        
        if (blackListCompany.IP_Address__c != null && blackListCompany.IP_Address__c == opportunity.Visitor_ID__c) {
            errorMessage += '<li>IP Address: ' + opportunity.Visitor_ID__c + '</li>';
        }

        errorMessage += '<ul/>';
        errorMessage += '<!--^^';
        if (blackListCompany.Comment__c != null) {
            errorMessage += blackListCompany.Comment__c + '. ';
        }

        errorMessage += 'Black List record Id: ' + blackListCompany.Id;

        errorMessage += '^^-->';

        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Creditreform API errors   
    *  Created         : 17/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCreditreformAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CREFO_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        }
        
        String xml = response.getBody();
        xml = CreditReformWebserviceAT.clearSearchXML(xml);
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xml);
        Dom.XmlNode xmlDom = domDoc.getRootElement();
        Dom.XmlNode globalBody = CreditReformWebserviceAT.returnGlobalBody(xmlDom);

        if (response.getStatusCode() == 500) {
            String serviceError = CreditReformWebserviceAT.returnServiceError(globalBody);
            if (! String.isEmpty(serviceError) && (serviceError.contains('Das gewählte Produkt ist für das angefragte Unternehmen nicht verfügbar. Sie können eine Wirtschaftsauskunft ' + 
                    'abrufen oder bestellen.') || serviceError.contains('Auskunft zur Zeit nicht möglich. Bitte Auftrag erteilen.'))) {
                errorMessage = null;
            }
            else {
                errorMessage += ' ' + serviceError;
            }
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Creditsafe API errors   
    *  Created         : 17/02/2020
    *  Parameters      : response - API response, requestType - type of API request
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCreditsafeAPIErrors(HttpResponse response, String requestType) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CREDITSAFE_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        } 
        else if (response.getStatusCode() == 401) {
            if (requestType == 'auth') {
                CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(response.getBody());
                if (! String.isEmpty(authEntity.message)) {
                    errorMessage += ' ' + authEntity.message;
                }
            } 
            else if (requestType == 'search') {
                CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(response.getBody());
                if (! String.isEmpty(searchEntity.error)) {
                    errorMessage += ' ' + searchEntity.error;
                }
            }
            else if (requestType == 'report') {
                CreditsafeReportEntity reportEntity = CreditsafeReportEntity.parse(response.getBody());
                if (! String.isEmpty(reportEntity.error)) {
                    errorMessage += ' ' + reportEntity.error;
                }
            }
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Company.info API errors   
    *  Created         : 17/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCompanyInfoAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = COMPANY_INFO_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        } 
        else if (response.getStatusCode() == 500) {
	        Dom.Document domDoc = new Dom.Document();
            domDoc.load(response.getBody());
            Dom.XmlNode xmlDom = domDoc.getRootElement();
            String serviceError = CompanyInfoWebservice.returnErrorMessage(xmlDom);
            if (! String.isEmpty(serviceError)) {
                errorMessage += ' ' + serviceError;
            }
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Creditreform API errors   
    *  Created         : 17/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkLexisNexisAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = LEXISNEXIS_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        else {
            Dom.Document domDocLexisNexis = new Dom.Document();
            domDocLexisNexis.load(response.getBody());
            Dom.XmlNode xmlDomLexisNexis = domDocLexisNexis.getRootElement();
            errorMessage = LexisNexisWebservice.returnErrorMessage(xmlDomLexisNexis);
            if (! String.isEmpty(errorMessage)) {
                errorMessage = LEXISNEXIS_API_ERROR + ' ' + CONTACT_ADMIN + ' ' + errorMessage;
            }
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Schufa API errors   
    *  Created         : 04/03/2020
    *  Parameters      : response - API response, 
                         requestType - type of API request
    *  Returns         : error message
    ******************************************************************************/
    public static String checkSchufaAPIErrors(HttpResponse response, String requestType) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = SCHUFA_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        else if (requestType == 'orderStatus') {
            SchufaEntity orderStatusEntity = SchufaEntity.parse(response.getBody());
            for (SchufaEntity.Order order : orderStatusEntity.order) {
                if (order.name == 'FullEconomyInfo' && order.failed == true && 
                        ! order.reason.contains('Es werden derzeit keine Auskünfte zu diesem Unternehmen erteilt.')) {
                    errorMessage = SCHUFA_API_ERROR + ' ' + CONTACT_ADMIN + ' ' + order.reason;
                }
            }
        }
        
        if (response.getStatusCode() == 400) {
            errorMessage += ' Bad request';
        } 
        else if (response.getStatusCode() == 403 || response.getStatusCode() == 409) {
            SchufaEntity schufaEntity = SchufaEntity.parse(response.getBody());
            if (! String.isEmpty(schufaEntity.message)) {
                errorMessage += ' ' + schufaEntity.message;
            }
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Crediconnect API errors   
    *  Created         : 13/04/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCrediconnectAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = CREDICONNECT_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 500) {
            String xml = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xml);
            Dom.XmlNode xmlDom = domDoc.getRootElement();
            String serviceError = CrediconnectWebserviceCH.returnErrorMessage(xmlDom);
            if (! String.isEmpty(serviceError)) {
                errorMessage += ' ' + serviceError;
            }
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check BIG API errors   
    *  Created         : 27/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkBigAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = BIG_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 500) {
            errorMessage += ' Internal Error';
        }
        
        return errorMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : check Coface API errors   
    *  Created         : 27/02/2020
    *  Parameters      : response - API response
    *  Returns         : error message
    ******************************************************************************/
    public static String checkCofaceAPIErrors(HttpResponse response) {
        String errorMessage;
        if (response.getStatusCode() != 200) {
            errorMessage = COFACE_API_ERROR + ' ' + CONTACT_ADMIN;
        }
        
        if (response.getStatusCode() == 500) {
            String xml = response.getBody();
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xml);
	        Dom.XmlNode xmlDom = domDoc.getRootElement();
            Dom.XmlNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
	        String serviceError = CofaceWebservice.returnErrorMessage(globalBody);
            if (! String.isEmpty(serviceError)) {
                errorMessage += ' ' + serviceError;
            }
        }
        
        return errorMessage;
    }

    
    /*******************************************************************************
    *  Summary         : return service error   
    *  Created         : 18/02/2020
    *  Parameters      : serviceName - name of API service
    *  Returns         : String
    ******************************************************************************/
    public static String returnServiceError(String serviceName) {
        String serviceError;
        if (serviceName == 'Creditreform') {
            serviceError = CREFO_API_ERROR;
        }
        else if (serviceName == 'LexisNexis') {
            serviceError = LEXISNEXIS_API_ERROR;
        }
        else if (serviceName == 'Creditsafe') {
            serviceError = CREDITSAFE_API_ERROR;
        }
        else if (serviceName == 'CompanyInfo') {
            serviceError = COMPANY_INFO_API_ERROR;
        }
        else if (serviceName == 'Coface') {
            serviceError = COFACE_API_ERROR;
        }
        else if (serviceName == 'Crediconnect') {
            serviceError = CREDICONNECT_API_ERROR;
        }
        else if (serviceName == 'BIG') {
            serviceError = BIG_API_ERROR;
        }
        
        return serviceError;
    }
}