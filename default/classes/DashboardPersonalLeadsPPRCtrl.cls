/**
 * Created by Nikita.Dayanov on 02.07.2018. 
 */

public with sharing class DashboardPersonalLeadsPPRCtrl {
    public String userId {public get; set;}
    public String userName { public get; set; }
    public Integer NumberOfLeadsNoTask {get; set;}
    public Integer NumberOfLeadsOverdueTask {get; set;}

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 02/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try{
            if(this.userId == null){
                this.userId = DashboardMethods.returnUserId();
            }
            if(this.userName == null){
                this.userName = DashboardMethods.getUser(this.userId).Name;
            }
            contactedLeads();
        }
        catch (Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : contactedLeads()
    *  Type            : method
    *  Summary         : getting number of all overdue and no task contacted leads for current user
    *  CreatedDate     : 02/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void contactedLeads() {
        Date todayDate = Date.today();

        List<Lead> contactedLeads = new List<Lead>([
            SELECT Id, OwnerId, IsConverted, Status, (SELECT Id, ActivityDate, OwnerId FROM Tasks WHERE IsClosed = false)
            FROM Lead
            WHERE OwnerId =: this.userId
            AND Status NOT IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
            AND IsConverted = false
            LIMIT 50000
        ]);
        this.NumberOfLeadsNoTask = 0;
        this.NumberOfLeadsOverdueTask = 0;
        for(Lead ld : contactedLeads){

            if(ld.Tasks.size() == 0){
                this.NumberOfLeadsNoTask++;
            } else{
                for(Task tsk: ld.Tasks){
                    if(tsk.ActivityDate < todayDate){
                        this.NumberOfLeadsOverdueTask++;
                        break;
                    }
                }
            }
        }

    }
}