/**
 * Created by eugene on 10/1/19.
 */

public class CarnetE2EService {
    @future
    public static void createCarnetOpportunity(String opportunityId) {
        RecordType carnetRecordType = [SELECT Id FROM RecordType WHERE Name = 'Carnet' AND SObjectType = 'Opportunity'];
        Opportunity opportunity = [
                SELECT AccountId, Account.Name, Sec_Channel__c, Channel__c, Primary_Contact__c,
                       LeadSource, Product__c, Primary_Contact_Phone__c, Total_number_of_vehicles__c,
                       (SELECT ContactId FROM OpportunityContactRoles WHERE IsPrimary = TRUE)
                FROM Opportunity
                WHERE Id = :opportunityId
        ];
        List<User> userRobert = [SELECT Id FROM User WHERE Name = 'Robert Kobrynski'];
        Opportunity carnetOpportunity = new Opportunity(
                RecordTypeId = carnetRecordType.Id,
                AccountId = opportunity.AccountId,
                Name = opportunity.Account.Name + '-Carnet',
                Type = 'Existing GFN',
                Language_preference__c = 'Polish',
                Sec_Channel__c = opportunity.Sec_Channel__c,
                Channel__c = opportunity.Channel__c,
                LeadSource = opportunity.LeadSource,
                Product__c = 'Carnet Standard 2019',
                CloseDate = Date.today().addMonths(3),
                StageName = 'Qualify',
                Form_of_Payment__c = 'Bank Transfer - after delivery',
                Primary_Contact_Phone__c = opportunity.Primary_Contact_Phone__c,
                Total_number_of_vehicles__c = opportunity.Total_number_of_vehicles__c
        );
        if (!opportunity.OpportunityContactRoles.isEmpty()) {
            carnetOpportunity.Primary_Contact__c = opportunity.OpportunityContactRoles.get(0).ContactId;
        }
        if (!userRobert.isEmpty()) {
            carnetOpportunity.OwnerId = userRobert.get(0).Id;
        }
        insert carnetOpportunity;

        if (!opportunity.OpportunityContactRoles.isEmpty()) {
            OpportunityContactRole newContactRole = new OpportunityContactRole(
                    ContactId = opportunity.OpportunityContactRoles.get(0).ContactId,
                    OpportunityId = carnetOpportunity.Id,
                    IsPrimary = true
            );
            insert newContactRole;
        }
    }
}