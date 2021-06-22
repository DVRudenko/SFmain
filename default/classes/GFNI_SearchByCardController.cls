public with sharing class GFNI_SearchByCardController {

private static final String GFN_CUSTOM_SETTINGS = 'GFN Integration Settings';
private static final String CCS_GFN_CUSTOM_SETTINGS = 'GFN Integration Settings CCS';
private static final GFNI_Settings__c integrationSettings = GFNI_Utils.getGfnCustomSettings(GFN_CUSTOM_SETTINGS);
private static final GFNI_Settings__c ccsIntegrationSettings = GFNI_Utils.getGfnCustomSettings(CCS_GFN_CUSTOM_SETTINGS);

public static GFNI_DashboardService gfnDashboardService = new GFNI_DashboardServiceImpl();



/*******************************************************************************
 *  Summary         : get Accounts by PAN (Card number)
 *  Created         : 18/02/2020 by Anton Hrytsavets
 *  Parameters      : cardNumber - card number for searching Account, colCo - Country code
 *  Returns         : JSON string with Accounts info
******************************************************************************/
@AuraEnabled
public static Map<String, String> getAccountsByPan(String cardNumber, String colCo, String lineOfBusiness) {
    try{
        String accParams;
        Map<String, String> accountsAndColCo = new Map<String, String>();
        System.debug('===' + colCo);
        String colCoId = GFNI_DashboardCtrl.getColCoId(lineOfBusiness, colCo);
        if(lineOfBusiness == 'CCS') {
            accParams = gfnDashboardService.searchByPanInGFN(colCoId, ccsIntegrationSettings, cardNumber);
        } else {
            accParams = gfnDashboardService.searchByPanInGFN(colCoId, integrationSettings, cardNumber);
        }
        accountsAndColCo.put('Accounts', accParams);
        accountsAndColCo.put('colCoId', colCoId);
        return accountsAndColCo;
    } catch(Exception e){
        String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
        throw new AuraHandledException(exceptionMessage);
    }     
}

}