public class showCCSOrder {
     public Id OpportunityId {get;set;}
 
     public String getCCSOrder(){
       String CCSOrder;
       CCSOrder = [SELECT Id FROM CCS_Order__c WHERE Opportunity__c = :OpportunityId LIMIT 1].Id;
       return CCSOrder;
      }
}