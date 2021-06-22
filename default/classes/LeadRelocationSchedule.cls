global class LeadRelocationSchedule implements Schedulable {
	// LeadRelocationSchedule l = new LeadRelocationSchedule();
	// String sch = '0 0,10,20,30,40,50 8-18 * * W';
	// String jobID = system.schedule('Lead Relocation', sch, l);
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new LeadRelocationBatch(), 1);
    }
}