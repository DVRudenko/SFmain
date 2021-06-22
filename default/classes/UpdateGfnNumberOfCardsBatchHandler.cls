public with sharing class UpdateGfnNumberOfCardsBatchHandler {

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

    public static void updateGfnNumberOfCards(List<ERP__c> erpList, List<ExceptionWrapper> errorList) {
        Map<String, String> recordTypeMap = new Map<String, String> {
            Schema.SObjectType.ERP__c.getRecordTypeInfosByName().get('CCS').getRecordTypeId() => 'CCS',
            Schema.SObjectType.ERP__c.getRecordTypeInfosByName().get('SME').getRecordTypeId() => 'SME'
        };

        for(ERP__c currentErp : erpList) {
            try {
                String recordTypeName = recordTypeMap.get(currentErp.RecordTypeId);
                String colCo = String.isEmpty(currentErp.ColCo__c) ? getColCoId(recordTypeName, currentErp.ColCoID__c) : getColCoId(recordTypeName, currentErp.ColCo__c);
                String gfnNumber = String.isEmpty(currentErp.GFN_Nr__c) ? currentErp.GFN_Number__c : currentErp.GFN_Nr__c;

                if(String.isNotEmpty(colCo) && String.isNotEmpty(gfnNumber)) {
                    AccountDetailsGfn gfnData;
                    GFNI_Settings__c gfnSettings = recordTypeName == 'CCS' ? ccsSettings : smeSettings;
                    gfnData = gfnDashboardService.getCustomerCardsInfo(colCo, gfnSettings, gfnNumber);

                    if(gfnData != null && gfnData.Data != null && gfnData.Data.SalesforceCards != null) {
                        Integer utaNumberOfCards = 0;
                        Integer limitNumberOfCards = 0;
                        Integer tollNumberOfCards = 0;
                        for(AccountDetailsGfn.SalesforceCards card : gfnData.Data.SalesforceCards) {
                            DateTime expiredDate = String.isEmpty(card.ExpiryDate) ? Date.today().addDays(1) : ((DateTime)Json.deserialize('"' + card.ExpiryDate + '"', DateTime.class)).addDays(60);
                            DateTime blockedDate = String.isEmpty(card.LastStatusChange) ? Date.today().addDays(1) : ((DateTime)Json.deserialize('"' + card.LastStatusChange + '"', DateTime.class)).addDays(60);
                            
                            if( !((card.Status == 'Expired' && Date.today() > expiredDate && recordTypeName == 'SME') ||
                                (card.Status == 'Blocked Card' && Date.today()> blockedDate) ||
                                (card.Status == 'Expired and cancelled' && Date.today() > expiredDate && recordTypeName == 'SME') ||
                                (card.Status == 'Cancelled' && Date.today() > blockedDate) ||
                                (card.Status == 'Expired and cancelled' && recordTypeName == 'CCS') ||
                                (card.Status == 'Expired' && recordTypeName == 'CCS'))
                            ){
                                if(card.CardType == 'Uta CZ') {
                                    utaNumberOfCards++;
                                }
                                if(card.CardType == 'Toll CZ') {
                                    tollNumberOfCards++;
                                }
                                if(card.CardType == 'Limit CZ') {
                                    limitNumberOfCards++;
                                }
                            }
                        }
                        currentErp.Uta_Cards__c = utaNumberOfCards;
                        currentErp.Toll_Cards__c = tollNumberOfCards;
                        currentErp.Limit_Cards__c = limitNumberOfCards;
                        System.debug('HERE===');
                    }
                }
            }
            catch(Exception e) {
                currentErp.Uta_Cards__c = -1;
                currentErp.Toll_Cards__c = -1;
                currentErp.Limit_Cards__c = -1;
                saveExceptionToList(e, currentErp.Id, errorList);
                System.debug('ERRROR === ' + e.getMessage());
            }
        }
        update erpList;
    }

    //TODO Move to Utils class
    private static String getColCoId(String lineOfBusiness, String colCo) {
        for(Col_Co_Mapping__mdt colCoMapping : colCoItems) {
            if(colCoMapping.Label == colCo && colCoMapping.Line_Of_Business__c == lineOfBusiness) {
                return String.valueOf(colCoMapping.ColCoId__c).substringBefore('.');
            }
        }
        return null;
    }


    public static void handleErrors (String reciever, List<ExceptionWrapper> errorList) {
        if(reciever != null && !errorList.isEmpty()) {
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setSenderDisplayName('SFDC');
            emailMessage.setSubject('Exception Logger ' + String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()).substringAfter('//'));
            emailMessage.setBccSender(false);
            emailMessage.setUseSignature(false);
            emailMessage.setSaveAsActivity(false);
            String body = '';
            for (ExceptionWrapper error : errorList) {
                body += '<br/>Exception in ' + String.join(error.idList, ', ') + ' : ' + error.relatedException.getStackTraceString() + '<br/>' + error.relatedException.getMessage() ;
                body += '<br/><br/>--------------------------------------------------<br/>';
            }
            emailMessage.setHtmlBody(body);
            emailMessage.setToAddresses(new List<String>{reciever});
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
        }
    }


    private static void saveExceptionToList (Exception e, Id currentErpId, List<ExceptionWrapper> errorList) { 
        for(ExceptionWrapper error : errorList) {
            if(error.relatedException.getStackTraceString() == e.getStackTraceString()) {
                error.idList.add(currentErpId);
                return;
            }
        }
        errorList.add(new ExceptionWrapper(e, currentErpId));
    }

    public class ExceptionWrapper {
        public List<String> idList;
        public Exception relatedException;

        public ExceptionWrapper(Exception e, String recordId) {
            this.idList = new List<String>{recordId};
            this.relatedException = e;
        }
    }
}
