global class E2EAbandonmentScenarioSchedule implements Schedulable{

    /*******************************************************************************
    *  Name            : execute(Schedulable sc)
    *  Summary         : execute batch for update e2eOpportunity Abandonment status
    *  CreatedDate     : 24/04/2018
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute (SchedulableContext sc) {
        Database.executeBatch(new E2EAbandonmentScenarioBatch());
    }

}