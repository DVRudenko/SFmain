@IsTest
private class CreditFactoryCalculationCtrlTest {

    /*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 29/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsDE();
        insert calculations;
    }


    /*******************************************************************************
    *  Summary         : test get calculation records
    *  Created         : 29/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testGetCalculations() {
        Map<String, List<Credit_Factory_Calculation__c>> calculationsMap = CreditFactoryCalculationCtrl.getCalculations();
        System.assertEquals(5, calculationsMap.get('Germany').size());
    }


    /*******************************************************************************
    *  Summary         : test upsert calculation records
    *  Created         : 29/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testUpsertCalculations() {
        List<Credit_Factory_Calculation__c> calculations = [
                SELECT Id, Date_of_Foundation_month__c
                FROM Credit_Factory_Calculation__c
                ORDER BY Order__c
        ];

        calculations.get(0).Date_of_Foundation_month__c = '<=36';
        calculations.add(new Credit_Factory_Calculation__c(
                Country__c = 'Germany',
                Class_Rating__c = '2',
                Date_of_Foundation_month__c = '<=18',
                Number_of_Cards__c = '<=1',
                Total_Consumption_Min_Value__c = '0',
                Total_Consumption_Max_Value__c = '600',
                Order__c = 9,
                Payment_Detail__c = '15+7'
        ));

        Map<String, List<Credit_Factory_Calculation__c>> calculationsMap = new Map<String, List<Credit_Factory_Calculation__c>>();
        calculationsMap.put('Germany', calculations);

        CreditFactoryCalculationCtrl.upsertCalculations(calculationsMap);
        calculations = [
                SELECT Id, Date_of_Foundation_month__c
                FROM Credit_Factory_Calculation__c
                ORDER BY Order__c
        ];

        System.assertEquals(calculations.get(0).Date_of_Foundation_month__c, '<=36');
        System.assertEquals(6, calculations.size());
    }


    /*******************************************************************************
    *  Summary         : test delete calculation records
    *  Created         : 29/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testDeleteCalculations() {
        List<Credit_Factory_Calculation__c> calculations = [
                SELECT Id, Date_of_Foundation_month__c
                FROM Credit_Factory_Calculation__c
                ORDER BY Order__c
        ];

        List<String> calculationsIdSet = new List<String>();
        calculationsIdSet.add(calculations.get(0).Id);
        CreditFactoryCalculationCtrl.deleteCalculations(calculationsIdSet);

        calculations = [
                SELECT Id, Date_of_Foundation_month__c
                FROM Credit_Factory_Calculation__c
                ORDER BY Order__c
        ];

        System.assertEquals(4, calculations.size());
    }
}