global class LeadPenaltyDecreaseScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		/* 
			LeadPenaltyDecreaseScheduler sch = new LeadPenaltyDecreaseScheduler();
			String cronStr = '0 0 2 * * ? *'; // runs daily at 2 am
			system.schedule('Lead Penalty Decrease', cronStr, sch);
		*/
		LeadPenaltyDecreaseBatch batch = new LeadPenaltyDecreaseBatch ();
		database.executeBatch(batch, 200);
	}
}