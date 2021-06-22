public class MassLeadsRecycleExtensions {
    private List<Lead> selectedLeadsList;

    public MassLeadsRecycleExtensions(ApexPages.StandardSetController stdController) { 
        try {
            List<Lead> selectedLeadsListTemp = stdController.getSelected();
            Set<String> leadIdsSet = new Set<String>();
            for (Lead lead: selectedLeadsListTemp) {
                leadIdsSet.add(lead.Id);
            }
            this.selectedLeadsList = [
                SELECT Id, OwnerId, RecordType.Name, Status, Quali_Status__c, warum_kein_Interesse__c, Service_Sonstiges_specific__c, OLD_Service_Other_specific__c, OLD_Quali_Status__c,
                    OLD_Why_not_interested__c, CreatedDate, Date_time_recycled__c, Disable_for_Approval_Rate__c, Disable_for_KPI__c, Disable_for_Processing_Time__c, Recycle_counter__c,
                    (SELECT Id FROM Tasks WHERE WhoId = :leadIdsSet LIMIT 1000),
                    (SELECT Id FROM Events WHERE WhoId = :leadIdsSet LIMIT 1000)
                FROM Lead
                WHERE Id = :leadIdsSet
                LIMIT 50000
            ];
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));    
        }   
    }


    /*******************************************************************************
    *  Name            : doRecycleLeads()
    *  Summary         : return lead listview page    
    *  CreatedDate     : 27/11/2017
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Page
    ******************************************************************************/
    public PageReference doRecycleLeads() {
        try {
            if (this.selectedLeadsList.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select at least one row. <a href="/00Q">back to lead list view</a>'));
                return null;
            }
            List<Lead> leadsToUpdateList = new List<Lead>();
            List<Task> tasksToDeleteList = new List<Task>();
            List<Event> eventsToDeleteList = new List<Event>();
            for (Lead lead : this.selectedLeadsList) {
                if (lead.RecordType.Name != 'Endkunde' && lead.RecordType.Name != 'CCS Sales process') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Recycle is available for \'Endkunde\' and \'CCS Sales process\' record types. <a href="/00Q">back to lead list view</a>'));
                    return null;
                }
                if (lead.Status == 'Disqualified') {
                    lead.OLD_Service_Other_specific__c = lead.Service_Sonstiges_specific__c;
                    lead.OLD_Quali_Status__c = lead.Quali_Status__c;
                    lead.OLD_Why_not_interested__c = lead.warum_kein_Interesse__c;
                    lead.Quali_Status__c = ''; 
                    lead.warum_kein_Interesse__c = '';
                    lead.Service_Sonstiges_specific__c = '';
                }
                lead.Status = 'Open';
                lead.Date_time_recycled__c = Datetime.now();
                lead.Disable_for_Approval_Rate__c = true;
                lead.Disable_for_KPI__c = true;
                lead.Disable_for_Processing_Time__c = true;
                if (lead.Recycle_counter__c != null) {
                    lead.Recycle_counter__c++;
                } else {
                    lead.Recycle_counter__c = 1;
                }
                leadsToUpdateList.add(lead);
                tasksToDeleteList.addAll(lead.Tasks);
                eventsToDeleteList.addAll(lead.Events);
            }
            update leadsToUpdateList;
            
            if (! tasksToDeleteList.isEmpty()) {
                delete tasksToDeleteList;
            }
            if (! eventsToDeleteList.isEmpty()) {
                delete eventsToDeleteList;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));    
        }   
        return new PageReference('/00Q');
    }
}