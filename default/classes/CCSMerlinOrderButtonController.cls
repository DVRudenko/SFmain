public with sharing class CCSMerlinOrderButtonController {
 
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityData(String oppoId){
        Opportunity record = [
            SELECT  Id,
                    Type,
                    Number_of_CCS_Order__c,
                    CCS_GFN_number__c,
                    Product_Solicited__c,
                    IsClosed,
                    Sec_Channel__c,
                    CCS_Merlin_Order_Button__c,
                    CCS_priobjednavka__c,
                    Account.CCS_Merlin_Order_Button_Address__c,
                    Account.CCS_Merlin_Order_Button__c,
                    Account.CCS_Company_ID__c 
            FROM Opportunity
            WHERE Id =: oppoId
        ];
        return record;
    }
 
    @AuraEnabled(cacheable=true)
    public static User getUserData(){
        User userData = [
            SELECT  Profile.Name,
                    role__c
            FROM User
            WHERE Id =: UserInfo.getUserId()
        ];
        return userData;
    }
}
