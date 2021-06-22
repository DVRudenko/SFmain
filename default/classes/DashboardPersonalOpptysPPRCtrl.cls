/**
 * Created by Nikita.Dayanov on 02.07.2018. 
 */

public with sharing class DashboardPersonalOpptysPPRCtrl {
    public String userId {public get; set;}
    public String userName { get; set; }
    public Integer NumberOfOpptysNoTask {get; set;}
    public Integer NumberOfOpptysOverdueTask {get; set;}

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
            contactedOpptys();
        }
        catch (Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : contactedOpptys()
    *  Type            : method
    *  Summary         : getting number of all overdue and no task contacted opportunities for current user
    *  CreatedDate     : 02/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void contactedOpptys() {

        Date todayDate = Date.today();

        List<Opportunity> allContactedOpptys = new List<Opportunity>([
                SELECT Id, OwnerId, StageName, (SELECT Id, ActivityDate, OwnerId
                                                FROM Tasks
                                                WHERE IsClosed = false AND OwnerId =: this.userId
                                                LIMIT 50000)
                FROM Opportunity
                WHERE OwnerId =: this.userId
                AND StageName NOT IN ('Moved to Start', 'Отказ', 'Потерян в конкуренции')
                LIMIT 50000
        ]);

        this.NumberOfOpptysNoTask = 0;
        this.NumberOfOpptysOverdueTask = 0;

        for(Opportunity opp : allContactedOpptys){
            if (opp.Tasks.size() == 0) {
                this.NumberOfOpptysNoTask++;
            } else {
                for(Task tsk : opp.Tasks){
                    if(tsk.ActivityDate < todayDate){
                        this.NumberOfOpptysOverdueTask++;
                        break;
                    }
                }
            }
        }

    }



}