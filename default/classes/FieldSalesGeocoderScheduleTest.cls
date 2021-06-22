@isTest
public class FieldSalesGeocoderScheduleTest {

    @isTest
    static void testScheduleMethod(){
        FieldSalesTerritory_General_Settings__c fieldSalesTerritorySettings = new FieldSalesTerritory_General_Settings__c();
        fieldSalesTerritorySettings.Name = 'RU';
        fieldSalesTerritorySettings.Penalty_for_refusal__c = 365;
        insert fieldSalesTerritorySettings;

        Test.startTest();
        FieldSalesGeocoderSchedule fsSchedule = new FieldSalesGeocoderSchedule(null);
        String sch = '0 0 23 * * ?';
        system.schedule('Test Job - FIELD SALES TERRITORY', sch, fsSchedule);
        Test.stopTest();
    }

}