global class DuplicateIPAddressBatch implements Database.Batchable<sObject> {
    
    
    /*******************************************************************************
    *  Summary         : Collect records
    *  CreatedDate     : 15/06/2020 by Anton Buzak
    *  Parameters      : bc - object for tracking the progress of the batch job
    *  Returns         : -
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 
                'SELECT Visitor_ID__c ' +
                'FROM Opportunity ' + 
                'WHERE CreatedDate = YESTERDAY AND Visitor_ID__c != null AND (RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\')';
                        
        return Database.getQueryLocator(query);
    }
    
    
    /*******************************************************************************
    *  Summary         : Process batch of records
    *  CreatedDate     : 15/06/2020 by Anton Buzak
    *  Parameters      : bc - object for tracking the progress of the batch job,
                         opportunitiesList - list of opportunity to process
    *  Returns         : -
    ******************************************************************************/
    global void execute(Database.BatchableContext bc, List<Opportunity> opportunitiesList) {
        try {
            Set<Id> opportunitiesIdsSet = new Set<Id>();
            Set<String> ipAddressesSet = new Set<String>();
            for (Opportunity opportunity : opportunitiesList) {
                opportunitiesIdsSet.add(opportunity.Id);
                ipAddressesSet.add(opportunity.Visitor_ID__c);
            }
            
            List<Opportunity> duplicateOpportunitiesList = [
                    SELECT Visitor_ID__c 
                    FROM Opportunity 
                    WHERE Visitor_ID__c IN :ipAddressesSet AND 
                          Id NOT IN :opportunitiesIdsSet AND 
                          (RecordType.Name = 'Euroshell' OR RecordType.Name = 'Euroshell Starts') AND 
                          CreatedDate != TODAY
            ];
            
            Set<String> duplicateIPAddressesSet = new Set<String>();
            for (Opportunity opportunity : duplicateOpportunitiesList) {
                duplicateIPAddressesSet.add(opportunity.Visitor_ID__c);
            }
            
            for (Opportunity opportunity : opportunitiesList) {
                if (duplicateIPAddressesSet.contains(opportunity.Visitor_ID__c)) {
                    opportunity.Duplicate_Visitor_ID__c = true;
                }
            }
            
            update opportunitiesList;
        } 
        catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }    
    
    global void finish(Database.BatchableContext bc) {}    
}