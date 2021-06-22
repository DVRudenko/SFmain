public without sharing class CreditFactoryCalculationCtrl {

    /*******************************************************************************
    *  Summary         : return the list of Credit Factory Calculation object
    *  CreatedDate     : 29/03/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : list of records
    ******************************************************************************/
    @AuraEnabled
    public static Map<String, List<Credit_Factory_Calculation__c>> getCalculations() {
        List<Credit_Factory_Calculation__c> calculationsList = [
            SELECT Class_Rating__c, Date_of_Foundation_month__c, Number_of_Cards__c, Country__c, Payment_Detail__c,
                    Total_Consumption_Min_Value__c, Total_Consumption_Max_Value__c, Order__c, Security_Level__c,
                    Deposit_Reason__c, New_Business_Exception__c, High_Risk__c
            FROM Credit_Factory_Calculation__c
            ORDER BY Order__c
        ];

        Schema.DescribeFieldResult fieldResult = Credit_Factory_Calculation__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        Map<String, List<Credit_Factory_Calculation__c>> calculationsMap = new Map<String, List<Credit_Factory_Calculation__c>>();
        for (Schema.PicklistEntry picklistValue : picklistEntry) {
            List<Credit_Factory_Calculation__c> calculationsByCountry = new List<Credit_Factory_Calculation__c>();
            for (Credit_Factory_Calculation__c calculation : calculationsList) {
                if (picklistValue.getLabel() == calculation.Country__c) {
                    calculationsByCountry.add(calculation);
                }
            }

            calculationsMap.put(picklistValue.getLabel(), calculationsByCountry);
        }

        return calculationsMap;
    }


    /*******************************************************************************
    *  Summary         : upsert the list of Credit Factory Calculation object
    *  CreatedDate     : 29/03/2021 by Ivan Kulinkovich
    *  Parameters      : Map<String, List<Credit_Factory_Calculation__c>> calculationsMap
    *  Returns         : -
    ******************************************************************************/
    @AuraEnabled
    public static void upsertCalculations(Map<String, List<Credit_Factory_Calculation__c>> calculationsMap) {
        List<List<Credit_Factory_Calculation__c>> calculations = calculationsMap.values();
        List<Credit_Factory_Calculation__c> calculationsToUpsert = new List<Credit_Factory_Calculation__c>();
        for (List<Credit_Factory_Calculation__c> calculationsList : calculations) {
            calculationsToUpsert.addAll(calculationsList);
        }

        upsert calculationsToUpsert;
    }


    /*******************************************************************************
    *  Summary         : delete the list of Credit Factory Calculation object
    *  CreatedDate     : 29/03/2021 by Ivan Kulinkovich
    *  Parameters      : List<String> calculationsIdSet
    *  Returns         : -
    ******************************************************************************/
    @AuraEnabled
    public static void deleteCalculations(List<String> calculationsIdSet) {
        List<Credit_Factory_Calculation__c> listToDelete = new List<Credit_Factory_Calculation__c>();
        for (String calculationId : calculationsIdSet) {
            Credit_Factory_Calculation__c calculation = new Credit_Factory_Calculation__c();
            calculation.Id = calculationId;
            listToDelete.add(calculation);
        }

        delete listToDelete;
    }
}