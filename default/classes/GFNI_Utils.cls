/**
 * Created by Nikita.Mikhailov on 17.01.2019.
 */
public with sharing class GFNI_Utils {
    public static final Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    private static final Map<String, GFNI_General_Settings__c> gfni_general_settings = GFNI_General_Settings__c.getAll();
    private static final Map<String, GFNI_Settings__c> gfni_settings = GFNI_Settings__c.getAll();
    private static final String currentMappingName {
        get {
            if (GFNI_Utils.isProductionOrg())
                return 'GFNI_Mapping';

            if (UserInfo.getUserName().substringAfterLast('.').toUpperCase().equals('FULL'))
                return 'GFNI_Mapping_UAT';

            return 'GFNI_Mapping_QA';
        }
        private set;
    }
    private static final StaticResource mappingStaticResource = [SELECT Id, Body FROM StaticResource WHERE Name = :currentMappingName LIMIT 1];
    private static final StaticResource testCompanies = [SELECT Id, Body FROM StaticResource WHERE Name = 'GFNI_Test_Clients' LIMIT 1];
    private static final OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];

    public static final Map<String, Object> gfniMapping {
        get {
            return (Map<String, Object>) JSON.deserializeUntyped(GFNI_Utils.mappingStaticResource.Body.toString());
        }
        private set;
    }

    public static final Map<String, Object> testCompaniesMapByCountry {
        get {
            return (Map<String, Object>) JSON.deserializeUntyped(GFNI_Utils.testCompanies.Body.toString());
        }
        private set;
    }

    /*******************************************************************************
    *  Name            : getStringValue
    *  Summary         : Retrieves String value from GFNI mapping
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind
    *  Returns         : String
    ******************************************************************************/
    public static String getStringValue(Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind) {
        if (fieldValueToGet == null)
            return GlobalUtils.blankStringIfNull(String.valueOf(fieldValueToGet));

        return String.valueOf(((Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, mappingToFind)).get((GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(fieldDescribe, String.valueOf(fieldValueToGet))))));
    }

    /*******************************************************************************
    *  Name            : getStringValue
    *  Summary         : Retrieves String value from provided JSON
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind
    *  Returns         : String
    ******************************************************************************/
    public static String getStringValue(String json, String keyValueToFind) {
        if (json == null || keyValueToFind == null) {
            return null;
        }

        return String.valueOf(GlobalUtils.getValueUntypedFromJSON((Map<String, Object>) System.JSON.deserializeUntyped(json), keyValueToFind));
    }

    /*******************************************************************************
    *  Name            : getIntegerValue
    *  Summary         : Retrieves Integer value from provided GFNI mapping
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind
    *  Returns         : String
    ******************************************************************************/
    public static Integer getIntegerValue(Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind) {
        if (fieldValueToGet == null)
            return null;

        if (fieldDescribe == null) {
            return Integer.valueOf(((Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, mappingToFind)).get(String.valueOf(fieldValueToGet)));
        } else {
            return Integer.valueOf(((Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, mappingToFind)).get((GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(fieldDescribe, String.valueOf(fieldValueToGet))))));
        }
    }

    /*******************************************************************************
    *  Name            : getGeneralSettings
    *  Summary         : Retrieves Integer setting from GFNI_General_Settings__c defined by key
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String key
    *  Returns         : GFNI_General_Settings__c
    ******************************************************************************/
    public static GFNI_General_Settings__c getGeneralSettings(String key) {
        return GFNI_Utils.gfni_general_settings.get(key);
    }

    /*******************************************************************************
    *  Name            : getGfnCustomSettings
    *  Summary         : Retrieves Integer setting from GFNI_Settings__c defined by key
    *  CreatedDate     : 24/07/2019
    *  Parameters      : String key
    *  Returns         : GFNI_Settings__c
    ******************************************************************************/
    public static GFNI_Settings__c getGfnCustomSettings(String key) {
        return GFNI_Utils.gfni_settings.get(key);
    }

    /*******************************************************************************
    *  Name            : getGfnIbmClientId
    *  Summary         : Retrieves ibm client setting for prod or for test
    *  CreatedDate     : 09/08/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String getGfnIbmClientId() {
        if (UserInfo.getOrganizationId() == '00D20000000oB2EEAU') { //prod
            return GFNI_Settings__c.getValues('GFN Integration Settings').x_ibm_client_id__c;
            // } else if (String.valueOf(System.Url.getSalesforceBaseUrl()).contains('fleetcor-eu--full')) { // full
            // return GFNI_Settings__c.getValues('GFN Integration Settings').test_x_ibm_client_id__c;
        } else {
            return GFNI_Settings__c.getValues('GFN Integration Settings').test_x_ibm_client_id__c;
            // return ''; // empty if it is dev sandbox
        }
    }

    /*******************************************************************************
    *  Name            : getGfnIbmClientSecretId
    *  Summary         : Retrieves ibm client secret setting for prod or for test
    *  CreatedDate     : 09/08/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String getGfnIbmClientSecretId() {
        if (UserInfo.getOrganizationId() == '00D20000000oB2EEAU') { // prod
            return GFNI_Settings__c.getValues('GFN Integration Settings').x_ibm_client_secret__c;
            // } else if (String.valueOf(System.Url.getSalesforceBaseUrl()).contains('fleetcor-eu--full')) { // full
            // return GFNI_Settings__c.getValues('GFN Integration Settings').test_x_ibm_client_secret__c;
        } else {
            return GFNI_Settings__c.getValues('GFN Integration Settings').test_x_ibm_client_secret__c;
            // return ''; // empty if it is dev sandbox
        }
    }

    public static Map<String, String> colCoMapping = new Map<String, String>{
            'DE' => '1',
            'AT' => '2',
            'BE' => '3',
            'NL' => '4',
            'FR' => '5',
            'HU' => '6',
            'PL' => '7',
            'LU' => '79',
            'CH' => '80',
            'CZ' => '81',
            'SK' => '82'
    };

    public static String handleExceptionMassage(Exception e) {
        if (e.getTypeName() == 'GFNI_DashboardException') {
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            return 'GFNI ERROR CODE: ' + gfnException.exceptionCode + '<br/>GFNI ERROR BODY: ' + gfnException.getMessage();
        } else {
            return e.getMessage();
        }
    }

    /*******************************************************************************
    *  Name            : getIdType
    *  Summary         : Defines type of input line
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String checkingLine
    *  Returns         : String
    ******************************************************************************/
    public static String getIdType(String checkingLine) {
        String Account_Nr_regEx = 'FC-[0-9]{9}';
        String GFN_Nr_regEx = '[A-Z]{2}[0-9]{8}';

        if (checkingLine instanceof Id) {
            return 'SF';
        }

        if (Pattern.matches(Account_Nr_regEx, checkingLine)) {
            return 'Account_Nr';
        }

        if (Pattern.matches(GFN_Nr_regEx, checkingLine)) {
            return 'GFN_Nr';
        }

        return null;
    }

    /*******************************************************************************
    *  Name            : replaceSpecialCharacters
    *  Summary         : Replaces special characters using keys and values from GFNI Mapping
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String input
    *  Returns         : String
    ******************************************************************************/
    public static String replaceSpecialCharacters(String input) {
        if (input == null)
            return null;

        input = input.replaceAll('(\\pS|\\pP)', '');

        Map<String, Object> specialCharactersMapping = (Map<String, Object>) GFNI_Utils.gfniMapping.get('SpecialCharacters');
        String output = '';
        Integer i = 0;
        do {
            if (i < input.length()) {
                if (specialCharactersMapping.containsKey(input.substring(i, i + 1))) {
                    output += specialCharactersMapping.get(input.substring(i, i + 1));
                } else {
                    output += input.substring(i, i + 1);
                }
            }
            i = i + 1;
        } while (i < input.length());

        output = output.replaceAll('\\s+', ' ');

        return output;
    }

    /*******************************************************************************
    *  Name            : returnCorrectPhoneNumber
    *  Summary         : Returns phone number in correct format defined by country
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String input, String countryCode
    *  Returns         : String
    ******************************************************************************/
    public static String returnCorrectPhoneNumber(String input, String countryCode) {
        if (input == null)
            return null;

        String result = input.replaceAll('(\\D+|^0+)', '');

        Map<String, Object> phoneCodesMapping = (Map<String, Object>) GFNI_Utils.gfniMapping.get('PhoneCodes');
        String currentPhoneCode = String.valueOf(phoneCodesMapping.get(countryCode));
        if (result.startsWith(currentPhoneCode.replaceAll('^0+', ''))) {
            result = currentPhoneCode.substring(0, 3) + result;
        } else if (!result.startsWith(currentPhoneCode)) {
            result = currentPhoneCode + result;
        }

        return result;
    }

    /*******************************************************************************
    *  Name            : isProductionOrg
    *  Summary         : Returns true or false in case of production or sandbox environment
    *  CreatedDate     : 17/01/2019
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean isProductionOrg() { // Method to check of environment is Production ORG or not
        Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        return (org.IsSandbox == true) ? false : true;
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail without attachment for support team defined by country in custom setting
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String countryCode
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmail(String subject, String emailBody, String countryCode) {
        Messaging.SingleEmailMessage mail = null;

        if (GFNI_Utils.gfni_general_settings.get(countryCode).Test_mode__c) {
            mail = EmailGenerator.sendHtmlEmailWithoutAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Test_support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody);
        } else {
            mail = EmailGenerator.sendHtmlEmailWithoutAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody);
        }

        sendEmail(mail);
    }

    /*******************************************************************************
    *  Name            : sendHtmlEmail
    *  Summary         : Generates and sends e-mail without attachment for support team defined by country in custom setting
    *  CreatedDate     : 30/05/2020
    *  Parameters      : String subject, String emailBody, String countryCode
    *  Returns         : -
    ******************************************************************************/
    public static void sendHtmlEmail(String subject, String emailBody, String countryCode) {
        Messaging.SingleEmailMessage mail = null;

        if (GFNI_Utils.gfni_general_settings.get(countryCode).Test_mode__c) {
            mail = EmailGenerator.getHtmlEmailObject(GFNI_Utils.gfni_general_settings.get(countryCode).Test_support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody);
        } else {
            mail = EmailGenerator.getHtmlEmailObject(GFNI_Utils.gfni_general_settings.get(countryCode).Support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody);
        }

        sendEmail(mail);
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail with attachment for support team defined by country in custom setting
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String countryCode, Messaging.EmailFileAttachment attachment
    *  Returns         : -
    ******************************************************************************/
//    public static void sendEmail(String subject, String emailBody, String countryCode, Messaging.EmailFileAttachment attachment) {
//        Messaging.SingleEmailMessage mail = null;
//
//        if (GFNI_Utils.gfni_general_settings.get(countryCode).Test_mode__c) {
//            mail = EmailGenerator.sendHtmlEmailWithAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Test_support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody, attachment);
//        } else {
//            mail = EmailGenerator.sendHtmlEmailWithAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody, attachment);
//        }
//
//        sendEmail(mail);
//    }

    /*******************************************************************************
    *  Name            : createEmailWithAttachment
    *  Summary         : Generates and e-mail with attachment for support team defined by country in custom setting
    *  CreatedDate     : 24/01/2019
    *  Parameters      : String subject, String emailBody, String countryCode, Messaging.EmailFileAttachment attachment
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public static Messaging.SingleEmailMessage createEmailWithAttachment(String subject, String emailBody, String countryCode, Messaging.EmailFileAttachment attachment) {
        Messaging.SingleEmailMessage mail = null;

        if (GFNI_Utils.gfni_general_settings.get(countryCode).Test_mode__c) {
            mail = EmailGenerator.sendHtmlEmailWithAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Test_support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody, attachment);
        } else {
            mail = EmailGenerator.sendHtmlEmailWithAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody, attachment);
        }

        return mail;
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail without attachment for provided list of emails
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String[] emailAddresses
    *  Returns         : -
    ******************************************************************************/
//    public static void sendEmail(String subject, String emailBody, String[] emailAddresses) {
//        OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
//
//        Messaging.SingleEmailMessage mail = EmailGenerator.sendHtmlEmailWithoutAttachment(emailAddresses, this.orgEmails, subject, emailBody);
//
//        sendEmail(mail);
//    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail with attachment for provided list of emails
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmail(String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment) {
        Messaging.SingleEmailMessage mail = EmailGenerator.sendHtmlEmailWithAttachment(emailAddresses, GFNI_Utils.orgEmails, subject, emailBody, attachment);

        sendEmail(mail);
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail with attachment for provided list of emails and with send logging in SF
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment, AccountGfnReportSendingLog gfnReportSendingLog
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmail(String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment, AccountGfnReportSendingLog gfnReportSendingLog) {
        Messaging.SingleEmailMessage mail = EmailGenerator.sendHtmlEmailWithAttachment(emailAddresses, GFNI_Utils.orgEmails, subject, emailBody, attachment);

        sendEmail(mail, gfnReportSendingLog);
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Sends e-mail without logging
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Messaging.SingleEmailMessage mail
    *  Returns         : -
    ******************************************************************************/
    private static void sendEmail(Messaging.SingleEmailMessage mail) {
        if (!Test.isRunningTest()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                        mail
                });
                if (results[0].isSuccess()) {
                    System.debug('Email send Success: ' + results[0].isSuccess());
                } else {
                    System.debug('Email send Failed: ' + results[0].isSuccess());
                }
            } catch (Exception e) {
                System.debug('Exception - GFNI_Utils.sendEmail: ' + e);
                ExceptionLogger.sendException(e.getMessage(), String.valueOf(e.getStackTraceString()));
            }
        } else {
            System.debug('this is test case');
        }
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Sends list of e-mails without logging
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Messaging.SingleEmailMessage mail
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmails(List<Messaging.SingleEmailMessage> mails) {
        if (!Test.isRunningTest()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                if (results[0].isSuccess()) {
                    System.debug('Email send Success: ' + results[0].isSuccess());
                } else {
                    System.debug('Email send Failed: ' + results[0].isSuccess());
                }
            } catch (Exception e) {
                System.debug('Exception - GFNI_Utils.sendEmail: ' + e);
                ExceptionLogger.sendException(e.getMessage(), String.valueOf(e.getStackTraceString()));
            }
        } else {
            System.debug('this is test case');
        }
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Sends e-mail with logging
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Messaging.SingleEmailMessage mail, AccountGfnReportSendingLog accountGfnReportSendingLogs
    *  Returns         : -
    ******************************************************************************/
    private static void sendEmail(Messaging.SingleEmailMessage mail, AccountGfnReportSendingLog accountGfnReportSendingLogs) {
        if (!Test.isRunningTest()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                        mail
                });
                if (results[0].isSuccess()) {
                    createMailingLog(accountGfnReportSendingLogs, 'Success');
                    System.debug('Email send Success: ' + results[0].isSuccess());
                } else {
                    createMailingLog(accountGfnReportSendingLogs, 'Failed');
                    System.debug('Email send Failed: ' + results[0].isSuccess());
                }
            } catch (Exception e) {
                createMailingLog(accountGfnReportSendingLogs, 'Failed');
                System.debug('Exception - GFNI_Utils.sendEmail: ' + e);
                ExceptionLogger.sendException(e.getMessage(), String.valueOf(e.getStackTraceString()));
            }
        } else {
            createMailingLog(accountGfnReportSendingLogs, 'Success');
            System.debug('this is test case');
        }
    }

    /*******************************************************************************
    *  Name            : createMailingLog
    *  Summary         : create mailing log
    *  CreatedDate     : 28.11.2018
    *  Parameters      : AccountGfnReportSendingLog sendingLogs, String status
    *  Returns         : void
    ******************************************************************************/
    private static void createMailingLog(AccountGfnReportSendingLog sendingLog, String status) {
        Mailing_Account_GFN_Report_Log__c log = new Mailing_Account_GFN_Report_Log__c(
                Account__c = sendingLog.accountId,
                Opportunity__c = sendingLog.opportunityId,
                Starts_Status_Changed_By__c = sendingLog.userId,
                Address__c = sendingLog.address,
                File_Name__c = sendingLog.fileName,
                Sending_Status__c = status);

        insert log;
    }

    /*******************************************************************************
    *  Name            : getUniqueProduct
    *  Summary         : get unique product in multiproduct process
    *  CreatedDate     : 29.10.2019
    *  Parameters      : Opportunity with OpportunityLineItems
    *  Returns         : String
    ******************************************************************************/
    public static String getUniqueProduct(Opportunity opportunity) {

        if (String.isBlank(opportunity.Product__c)) {
            if (!opportunity.OpportunityLineItems.isEmpty()) {
                //logic to set EV first in product string
                List<OpportunityLineItem> lineItemsList = opportunity.OpportunityLineItems;
                String product = '';
                Integer i = 0;
                for (OpportunityLineItem lineItem : lineItemsList) {
                    if (lineItem.Product2.Family.equals('EV')) {
                        product += lineItem.Product_Name__c + ' + ';
                        break;
                    }
                    i++;
                }

                if (String.isNotBlank(product)) {
                    lineItemsList.remove(i);
                }

                for (OpportunityLineItem lineItem : lineItemsList) {
                    product += lineItem.Product_Name__c + ' + ';
                }

                return product.removeEnd(' + ');
            }
        } else {
            return opportunity.Product__c;
        }
        throw new GlobalException('No product matched for Opportunity: ' + opportunity.Id);
    }


    public static GFNI_Batch_Settings__c getGfnRelatedBatchSettings (String customSettingName) { 
        GFNI_Batch_Settings__c batchSetting;
        List<GFNI_Batch_Settings__c> batchSettingList = [
            SELECT  Batch_Size__c,
                    Query_Limit__c,
                    Where_Condition__c,
                    Error_Message_Reciever__c
            FROM    GFNI_Batch_Settings__c
            WHERE   Active__c = true
            AND     Name =: customSettingName
        ];
        if(batchSettingList.size() == 1) {
            return batchSettingList[0];
        }
        return null;
    }

    //deduplication logic with API usage
//    public static Boolean isExistingCustomer(Id opportunityId) {
//
//        Opportunity opportunity = [
//                SELECT Id, Account.Account_Nr__c, Account.Name, Account.Umsatzsteuer_ID__c, Account.BillingCountryCode, Account.GFN_Nr__c,
//                        Account.BillingCountry, Account.Owner.Name, (SELECT Id, Contact.Email FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
//                FROM Opportunity
//                WHERE Id = :opportunityId
//        ];
//
//        if(opportunity.Account.GFN_Nr__c != null) {
//            return true;//definitely double
//        }
//
//        System.debug('GFNI_Handler: ' + '*** PREPARE DEDUPLICATION REQUEST FOR GFN ***');
//        String body = GFNI_RequestBuilder.buildJSONGetCustomerId(opportunity);
//        System.debug(body);
//        String requestId = GFNI_Utils.getStringValue(body, 'RequestID');
//        System.debug('GFNI_Handler: ' + '*** SENDING GET CUSTOMER ID REQUEST ***');
//
//
//        HttpResponse response = GFNI_RequestHandler.sendRequest(body, GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode).Get_Customer_Id__c, opportunity.Account.BillingCountryCode);
//
//        //if everything is fine, check if double or not
//
////        if(GFNI_Utils.getStringValue(response.getBody(), 'CustomerServiceReferenceId') != null) {
////
////        }
//
//        return null;
//    }
}