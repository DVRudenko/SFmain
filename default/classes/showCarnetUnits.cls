public class showCarnetUnits {
     public Id OpportunityId {get;set;}
 
     public List<Carnet_Unit__c> getCarnet(){
       List<Carnet_Unit__c> carnet;
       carnet = [SELECT Id, Name, Pricing_Approval_Status__c, Number_of_Units__c, Carnet_Tariff__c, Contract_term__c, Monitoring_in_EU__c, Monitoring_in_other_European_countries__c, Standard_Unit_Package__c, Total_One_time_Payment__c, Total_Monthly_Payment__c FROM Carnet_Unit__c WHERE Opportunity__c = : OpportunityId AND (Pricing_Approval_Status__c = 'Pending Approval' OR Pricing_Approval_Status__c = 'Approval Required')];
       return carnet;
      }
      
      public List<Additional_Hardware__c> getAHW(){
       List<Additional_Hardware__c> ahw;
       ahw = [SELECT Id, Name, Pricing_Approval_Status__c, Total_One_time_Payment__c FROM Additional_Hardware__c WHERE Opportunity__c = : OpportunityId AND (Pricing_Approval_Status__c = 'Pending Approval' OR Pricing_Approval_Status__c = 'Approval Required')];
       return ahw;
      }
      
      public List<Carnet_Unit__c> getCarnetBO(){
       List<Carnet_Unit__c> carnetBO;
       carnetBO = [SELECT Id, Name, Pricing_Approval_Status__c, Number_of_Units__c, Carnet_Tariff__c, Contract_term__c, Monitoring_in_EU__c, Monitoring_in_other_European_countries__c, Standard_Unit_Package__c, Total_One_time_Payment__c, Total_Monthly_Payment__c FROM Carnet_Unit__c WHERE Opportunity__c = :OpportunityId];
       return carnetBO;
      }
      
      public List<Additional_Hardware__c> getAhwBO(){
       List<Additional_Hardware__c> ahwBO;
       ahwBO = [SELECT Id, Name, Pricing_Approval_Status__c, Total_One_time_Payment__c FROM Additional_Hardware__c WHERE Opportunity__c = :OpportunityId];
       return ahwBO;
      }
}