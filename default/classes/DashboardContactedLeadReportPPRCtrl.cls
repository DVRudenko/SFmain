/**
 * Created by Nikita.Mikhailov on 28.05.2018.
 */

public with sharing class DashboardContactedLeadReportPPRCtrl {
    public String userId { get; set; } //user id by who gather data
    public User currentUser { get; set; } //user by who gather data
    public Map<Id, Lead> leadsWithTaskCloseDate { get; set; } //map of leads gathered by leadsWithoutTasks to show date of last closed task
    public ApexPages.StandardSetController leadNoTasksSsc { get; set; } //valid no tasks leads and pagination
    public ApexPages.StandardSetController leadOverDueSsc { get; set; } //valid overdue tasks leads and pagination

    public List<LeadWrapper> leadsWithoutTasks {
        get {
            leadsWithoutTasks = new List<LeadWrapper>();
            for (Lead currLead: (List<Lead>) leadNoTasksSsc.getRecords()) {
                LeadWrapper leadWrapper = new LeadWrapper();
                leadWrapper.leadId = currLead.Id;
                leadWrapper.name = currLead.Name;
                leadWrapper.createdDate = currLead.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                leadWrapper.lastTransferDate = currLead.Last_Owner_Change_Date_RUS__c.format('dd-MM-yyyy HH:mm:ss');
                leadWrapper.status = currLead.Status;
                if (leadsWithTaskCloseDate.get(currLead.Id) != null && leadsWithTaskCloseDate.get(currLead.Id).Tasks.size() == 0) {
                    leadWrapper.taskDate = 'Нет закрытых задач';
                } else {
                    leadWrapper.taskDate = leadsWithTaskCloseDate.get(currLead.Id).Tasks[0].LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                leadsWithoutTasks.add(leadWrapper);
            }
            return leadsWithoutTasks;
            //return (List<Lead>) this.leadNoTasksSsc.getRecords();
        }
        private set;
    }

    public List<LeadWrapper> leadsWithOverdueTasks {
        get {
            leadsWithOverdueTasks = new List<LeadWrapper>();
            for (Lead currLead: (List<Lead>) leadOverDueSsc.getRecords()) {
                LeadWrapper leadWrapper = new LeadWrapper();
                leadWrapper.leadId = currLead.Id;
                leadWrapper.name = currLead.Name;
                leadWrapper.createdDate = currLead.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                leadWrapper.lastTransferDate = currLead.Last_Owner_Change_Date_RUS__c.format('dd-MM-yyyy HH:mm:ss');
                leadWrapper.status = currLead.Status;
                if (leadsWithTaskCloseDate.get(currLead.Id) != null && leadsWithTaskCloseDate.get(currLead.Id).Tasks.size() == 0) {
                    leadWrapper.taskDate = 'Нет закрытых задач';
                } else {
                    leadWrapper.taskDate = currLead.Tasks[0].ActivityDate.format();
                }
                leadsWithOverdueTasks.add(leadWrapper);
            }
            return leadsWithOverdueTasks;
            //return (List<Lead>) this.leadOverDueSsc.getRecords();
        }
        private set;
    }

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 28/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {
            if (userId == null) {
                userId = DashboardMethods.returnUserId();
            }

            if (currentUser == null) {
                currentUser = DashboardMethods.getUser(this.userId);
            }

            gatherContactedLeads();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : gatherContactedLeads()
    *  Type            : method
    *  Summary         : gather data for report
    *  CreatedDate     : 28/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void gatherContactedLeads() {

        Date today = Date.today();

        List<Lead> allUserLeads = [
                SELECT Id,
                        Name,
                        CreatedDate,
                        LastTransferDate,
                        Last_Owner_Change_Date_RUS__c,
                        Status, (SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false AND OwnerId = :userId ORDER BY ActivityDate DESC)
                FROM Lead
                WHERE OwnerId = :this.userId
                AND Status NOT IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
                AND IsConverted = false
                LIMIT 10000
        ];

        Set<Id> leadsWithoutTasksIds = new Set<id>();
        Set<Id> leadsWithOverdueTasksIds = new Set<Id>();

        for (Lead lead : allUserLeads) {
            if (lead.Tasks.size() == 0) {
                leadsWithoutTasksIds.add(lead.Id);
            } else {
                for (Task task : lead.Tasks) {
                    if (task.ActivityDate < today) {
                        leadsWithOverdueTasksIds.add(lead.Id);
                        break;
                    }
                }
            }
        }

        String noTaskQuery = 'SELECT Id, ' +
                'Name, ' +
                'CreatedDate, ' +
                'LastTransferDate, ' +
                'Last_Owner_Change_Date_RUS__c, ' +
                'Status ' +
                'FROM Lead ' +
                'WHERE Id IN :leadsWithoutTasksIds ' +
                'ORDER BY Name ' +
                'LIMIT 10000';

        String overDueQuery = 'SELECT Id, ' +
                'Name, ' +
                'CreatedDate, ' +
                'LastTransferDate, ' +
                'Last_Owner_Change_Date_RUS__c, ' +
                'Status, ' +
                '(SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false AND OwnerId = \'' + this.userId + '\' ORDER BY ActivityDate DESC) ' +
                'FROM Lead ' +
                'WHERE Id IN :leadsWithOverdueTasksIds ' +
                'ORDER BY Name ' +
                'LIMIT 10000';

        System.debug(overDueQuery);

        this.leadNoTasksSsc = new ApexPages.StandardSetController(Database.getQueryLocator(noTaskQuery));
        this.leadNoTasksSsc.setPageSize(100);

        this.leadOverDueSsc = new ApexPages.StandardSetController(Database.getQueryLocator(overDueQuery));
        this.leadOverDueSsc.setPageSize(100);

        leadsWithTaskCloseDate = new Map<Id, Lead>([
                SELECT Id, (SELECT Id, LastModifiedDate FROM Tasks WHERE OwnerId = :userId AND IsClosed = TRUE ORDER BY LastModifiedDate DESC LIMIT 1)
                FROM Lead
                WHERE Id = :leadsWithoutTasksIds
                LIMIT 50000
        ]);
    }

    public class LeadWrapper {
        public String leadId { get; set; }
        public String name { get; set; }
        public String createdDate { get; set; }
        public String lastTransferDate { get; set; }
        public String status { get; set; }
        public String taskDate { get; set; }
    }
}