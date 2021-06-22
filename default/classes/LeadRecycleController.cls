public with sharing class LeadRecycleController {
    public LeadRecycleController() {     
    }

    public PageReference init() {
    	try {
    	    String leadId = ApexPages.CurrentPage().getparameters().get('id');
    		String soql = returnSOQLquery(leadId);
            if (soql != null) {
                Lead currentLead = (Lead)Database.query(soql);
                List<Task> tasksToDeleteList = new List<Task>();
                List<Event> eventsToDeleteList = new List<Event>();
                if (currentLead.Tasks.size() != 0) {
                    tasksToDeleteList = currentLead.Tasks;
                    delete tasksToDeleteList;
                }
                if (currentLead.Events.size() != 0) {
                    eventsToDeleteList = currentLead.Events;
                    delete eventsToDeleteList;
                }

                if (currentLead.Status == 'Disqualified') {
                    currentLead.OLD_Service_Other_specific__c = currentLead.Service_Sonstiges_specific__c;
                    currentLead.OLD_Quali_Status__c = currentLead.Quali_Status__c;
                    currentLead.OLD_Why_not_interested__c = currentLead.warum_kein_Interesse__c;
                    currentLead.Quali_Status__c = ''; 
                    currentLead.warum_kein_Interesse__c = '';
                    currentLead.Service_Sonstiges_specific__c = '';
                }
                currentLead.Status = 'Open';         
                currentLead.Date_time_recycled__c = Datetime.now();
                currentLead.Disable_for_Approval_Rate__c = true;
                currentLead.Disable_for_KPI__c = true;
                currentLead.Disable_for_Processing_Time__c = true;

                if (currentLead.Recycle_counter__c != null) {
                    currentLead.Recycle_counter__c++;
                } else {
                    currentLead.Recycle_counter__c = 1;
                }           
                update currentLead;
                
                PageReference newLeadHomePage = new PageReference('/' + currentLead.Id);
                return newLeadHomePage; 
            } 			
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));    
    	}
        return null;
    }


    /*******************************************************************************
    *  Name            : returnSOQLquery(String leadId)
    *  Summary         : Returns a dynamic SOQL statement for the whole object   
    *  CreatedDate     : 06/11/2017
    *  ModifiedDate    : 27/11/2017
    *  Parameters      : -
    *  Returns         : String SOQL query
    ******************************************************************************/
    public static String returnSOQLquery(String leadId) {        
        String query = '';

        if (leadId == null || leadId == '') return null; 
        
        query = 'SELECT Id, OwnerId, Status, Quali_Status__c, warum_kein_Interesse__c, Service_Sonstiges_specific__c, OLD_Service_Other_specific__c, OLD_Quali_Status__c, OLD_Why_not_interested__c, ' +
                    'CreatedDate, Date_time_recycled__c, Disable_for_Approval_Rate__c, Disable_for_KPI__c, Disable_for_Processing_Time__c, Recycle_counter__c, ' +
                    '(SELECT Id FROM Tasks WHERE WhoId = :leadId LIMIT 100), ' +
                    '(SELECT Id FROM Events WHERE WhoId = :leadId LIMIT 100) ' +
                'FROM Lead ' +
                'WHERE Id = :leadId ' +
                'LIMIT 1';
              
        return query;        
    }
}