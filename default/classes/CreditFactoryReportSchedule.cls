global class CreditFactoryReportSchedule implements Schedulable {


	/*******************************************************************************
	*  Name            : execute(SchedulableContext sc)
	*  Summary         : Execute scheduled logic.
	*  CreatedDate     : 05/07/2019
	*  ModifiedDate    : -
	*  Parameters      : SchedulableContext sc - object to keep track of the scheduled job once it's scheduled
	*  Returns         : void
	******************************************************************************/
    global void execute(SchedulableContext sc) {
        CreditFactoryReportBatch batch = new CreditFactoryReportBatch();
        Database.executeBatch(batch, 1);
    }
}