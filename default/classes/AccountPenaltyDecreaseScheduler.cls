global class AccountPenaltyDecreaseScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		/* 
			AccountPenaltyDecreaseScheduler sch = new AccountPenaltyDecreaseScheduler();
			String cronStr = '0 0 2 * * ? *'; // runs daily at 2 am
			system.schedule('Account Penalty Decrease', cronStr, sch);
		*/
		AccountPenaltyDecreaseBatch batch = new AccountPenaltyDecreaseBatch ();
		database.executeBatch(batch, 200);
	}
}