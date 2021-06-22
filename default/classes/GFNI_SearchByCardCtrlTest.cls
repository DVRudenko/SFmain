@isTest
public with sharing class GFNI_SearchByCardCtrlTest {

    @isTest
    public static void testSearchByCard(){
        GFNI_DashboardCtrlTest.initCustomSettings(true);
        Test.startTest();

        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Map<String, String> accountParams;
        try{
            accountParams = GFNI_SearchByCardController.getAccountsByPan('123456', 'SK', 'SME');
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }
        Test.stopTest();

        System.assert(accountParams.get('Accounts')!=null);
        System.assertEquals(accountParams.get('colCoId'), '82');
    }


    @isTest
    public static void testSearchByCardWithError(){
        GFNI_DashboardCtrlTest.initCustomSettings(true);
        Test.startTest();

        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Map<String, String> accountParams;
        try{
            accountParams = GFNI_SearchByCardController.getAccountsByPan('123456', 'SK', 'SME');
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }
        Test.stopTest();

        System.assertEquals(accountParams, null);
    }
}