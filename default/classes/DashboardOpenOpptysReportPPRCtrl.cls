/**
 * Created by Nikita.Mikhailov on 30.05.2018.
 */

public with sharing class DashboardOpenOpptysReportPPRCtrl {
    public String userId { get; set; } //user id by who gather data
    public User currentUser { get; set; } //user by who gather data
    public Map<Id, Opportunity> opptysWithTaskCloseDate { get; set; } //map of opptys gathered by leadsWithoutTasks to show date of last closed task
    public ApexPages.StandardSetController opptyNoTasksSsc { get; set; } //valid no tasks leads and pagination
    public ApexPages.StandardSetController opptyOverDueSsc { get; set; } //valid overdue tasks leads and pagination

    public List<OpportunityWrapper> opptysWithoutTasks {
        get {
            opptysWithoutTasks = new List<OpportunityWrapper>();
            for (Opportunity opp: (List<Opportunity>) opptyNoTasksSsc.getRecords()) {
                OpportunityWrapper oppWrapper = new OpportunityWrapper();
                oppWrapper.oppId = opp.Id;
                oppWrapper.name = opp.Name;
                oppWrapper.createdDate = opp.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                oppWrapper.lastOwnerChangeDate = opp.Last_Owner_Change_Date_RUS__c!=null ? opp.Last_Owner_Change_Date_RUS__c.format('dd-MM-yyyy HH:mm:ss') : '';
                oppWrapper.stageName = opp.StageName;
                if (opptysWithTaskCloseDate.get(opp.Id).Tasks.size() == 0) {
                    oppWrapper.taskDate = 'Нет закрытых задач';
                } else {
                    oppWrapper.taskDate = opptysWithTaskCloseDate.get(opp.Id).Tasks[0].LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                opptysWithoutTasks.add(oppWrapper);
            }
            return opptysWithoutTasks;
        }
        private set;
    } //list of opptys without tasks

    public List<OpportunityWrapper> opptysWithOverdueTasks {
        get {
            opptysWithOverdueTasks = new List<OpportunityWrapper>();
            for (Opportunity opp: (List<Opportunity>) opptyOverDueSsc.getRecords()) {
                OpportunityWrapper oppWrapper = new OpportunityWrapper();
                oppWrapper.oppId = opp.Id;
                oppWrapper.name = opp.Name;
                oppWrapper.createdDate = opp.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                oppWrapper.lastOwnerChangeDate = opp.Last_Owner_Change_Date_RUS__c!=null ? opp.Last_Owner_Change_Date_RUS__c.format('dd-MM-yyyy HH:mm:ss') : '';
                oppWrapper.stageName = opp.StageName;
                oppWrapper.taskDate = opp.Tasks[0].ActivityDate.format();
                opptysWithOverdueTasks.add(oppWrapper);
            }
            return opptysWithOverdueTasks;
        }
        private set;
    } //list of opptys with overdated tasks

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 30/05/2018
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

            gatherOpenOpptys();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : gatherContactedLeads()
    *  Type            : method
    *  Summary         : gather data for report
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void gatherOpenOpptys() {

        Date today = Date.today();

        List<Opportunity> allUserOpptys = [
                SELECT Id,
                        Name,
                        CreatedDate,
                        Last_Owner_Change_Date_RUS__c,
                        StageName, (SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false AND OwnerId = :userId ORDER BY ActivityDate DESC)
                FROM Opportunity
                WHERE OwnerId = :userId
                AND StageName NOT IN ('Moved to Start', 'Отказ', 'Потерян в конкуренции')
                LIMIT 50000
        ];

        Set<Id> opptysWithoutTasksIds = new Set<Id>();
        Set<Id> opptysWithOverdueTasksIds = new Set<Id>();

        for (Opportunity opportunity : allUserOpptys) {
            if (opportunity.Tasks.size() == 0) {
                opptysWithoutTasksIds.add(opportunity.Id);
            } else {
                for (Task task : opportunity.Tasks) {
                    if (task.ActivityDate < today) {
                        opptysWithOverdueTasksIds.add(opportunity.Id);
                        break;
                    }
                }
            }
        }

        String noTaskQuery = 'SELECT Id, ' +
                'Name, ' +
                'CreatedDate, ' +
                'Last_Owner_Change_Date_RUS__c, ' +
                'StageName ' +
                'FROM Opportunity ' +
                'WHERE Id IN :opptysWithoutTasksIds ' +
                'ORDER BY Name ' +
                'LIMIT 10000';

        String overDueQuery = 'SELECT Id, ' +
                'Name, ' +
                'CreatedDate, ' +
                'Last_Owner_Change_Date_RUS__c, ' +
                'StageName, ' +
                '(SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false AND OwnerId = \'' + this.userId + '\' ORDER BY ActivityDate DESC) ' +
                'FROM Opportunity ' +
                'WHERE Id IN :opptysWithOverdueTasksIds ' +
                'ORDER BY Name ' +
                'LIMIT 10000';

        this.opptyNoTasksSsc = new ApexPages.StandardSetController(Database.getQueryLocator(noTaskQuery));
        this.opptyNoTasksSsc.setPageSize(100);

        this.opptyOverDueSsc = new ApexPages.StandardSetController(Database.getQueryLocator(overDueQuery));
        this.opptyOverDueSsc.setPageSize(100);

        opptysWithTaskCloseDate = new Map<Id, Opportunity>([
                SELECT Id, (SELECT Id, LastModifiedDate FROM Tasks WHERE OwnerId = :userId AND IsClosed = TRUE ORDER BY LastModifiedDate DESC LIMIT 1)
                FROM Opportunity
                WHERE Id = :opptysWithoutTasksIds
                LIMIT 50000
        ]);
    }

    public class OpportunityWrapper {
        public String oppId { get; set; }
        public String name { get; set; }
        public String createdDate { get; set; }
        public String lastOwnerChangeDate { get; set; }
        public String stageName { get; set; }
        public String taskDate { get; set; }
    }
}