public with sharing class UpdateGfnStatusBatchHandler {

    private static final String GFN_CUSTOM_SETTINGS_SME = 'GFN Integration Settings';
    private static final String GFN_CUSTOM_SETTINGS_CCS = 'GFN Integration Settings CCS';
    private static GFNI_Settings__c smeSettings = GFNI_Utils.getGfnCustomSettings(GFN_CUSTOM_SETTINGS_SME);
    private static GFNI_Settings__c ccsSettings = GFNI_Utils.getGfnCustomSettings(GFN_CUSTOM_SETTINGS_CCS);
    public static GFNI_DashboardService gfnDashboardService = new GFNI_DashboardServiceImpl();
    public static List<Col_Co_Mapping__mdt> colCoItems = [
        SELECT  ColCoId__c ,
                Line_Of_Business__c,
                Label
        FROM    Col_Co_Mapping__mdt
    ];

    public static void getGfnStatuses(List<ERP__c> erpList) {
        Map<String, String> recordTypeMap = new Map<String, String> {
            Schema.SObjectType.ERP__c.getRecordTypeInfosByName().get('CCS').getRecordTypeId() => 'CCS',
            Schema.SObjectType.ERP__c.getRecordTypeInfosByName().get('SME').getRecordTypeId() => 'SME'
        };

        for(ERP__c currentErp : erpList) {
            String recordTypeName = recordTypeMap.get(currentErp.RecordTypeId);
            String colCo;
            String gfnNumber;
            if(String.isNotEmpty(currentErp.ColCo__c)) {
                colCo = getColCoId(recordTypeName, currentErp.ColCo__c);
            }
            else {
                colCo = getColCoId(recordTypeName, currentErp.ColCoID__c);
            }
            if(String.isNotEmpty(currentErp.GFN_Nr__c)) {
                gfnNumber = currentErp.GFN_Nr__c;
            }
            else {
                gfnNumber = currentErp.GFN_Number__c;
            }
            if(String.isNotEmpty(colCo) && String.isNotEmpty(gfnNumber)) {
                AccountDetailsGfn gfnData;
                if(recordTypeName == 'CCS') {
                    gfnData = gfnDashboardService.getCustomerInformation(colCo, ccsSettings, gfnNumber);
                }
                else {
                    gfnData = gfnDashboardService.getCustomerInformation(colCo, smeSettings, gfnNumber);
                }
                if(gfnData != null && gfnData.Data != null) {
                    currentErp.Status__c = gfnData.Data.Status;
                }
            }
            System.debug('currentErp === ' + currentErp + ' ' + DateTime.now());
        }
        update erpList;
    }


    private static String getColCoId(String lineOfBusiness, String colCo) {
        for(Col_Co_Mapping__mdt colCoMapping : colCoItems) {
            if(colCoMapping.Label == colCo && colCoMapping.Line_Of_Business__c == lineOfBusiness) {
                return String.valueOf(colCoMapping.ColCoId__c).substringBefore('.');
            }
        }
        return null;
    }

    public static void saveLogs(String message) {
        List<Unify_CC_LogStorage__b> logs = new List<Unify_CC_LogStorage__b>();
        Unify_CC_LogStorage__b log = new Unify_CC_LogStorage__b(
            Message__c = JSON.serialize(message),
            RecordDateTime__c = String.valueOf(System.now().getTime()) + '_' + ((Math.random() * 1000) + 1000).round(),
            Entity_Id__c = UserInfo.getUserId()
        );
    
        logs.add(log);
        if (!Test.isRunningTest()){
            List<Database.SaveResult> srList = Database.insertImmediate(logs);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted log. ID: ' + sr.getId());
                }
                else {               
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Log fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }


    public static void sendErrorMessage(Exception e, String reciever) {
        if(reciever != null) {
        // Messaging.Email mailsList = new Messaging.Email();
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setSenderDisplayName('SFDC');
            emailMessage.setSubject('Exception Logger ' + String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()).substringAfter('//'));
            emailMessage.setBccSender(false);
            emailMessage.setUseSignature(false);
            emailMessage.setSaveAsActivity(false);
            String body = 'Exception: ' + e.getStackTraceString() + '\n' + e.getMessage();
            emailMessage.setPlainTextBody(body);
            emailMessage.setToAddresses(new List<String>{reciever});
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
        }
    }
}
