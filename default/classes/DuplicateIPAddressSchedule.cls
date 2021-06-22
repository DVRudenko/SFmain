global class DuplicateIPAddressSchedule implements Schedulable {
    
    
    /*******************************************************************************
	*  Summary         : Execute scheduled logic.
	*  CreatedDate     : 16/06/2020 by Anton Buzak
	*  Parameters      : sc - object to keep track of the scheduled job once it's scheduled
	*  Returns         : -
	******************************************************************************/
    global void execute(SchedulableContext sc) {
        DuplicateIPAddressBatch batch = new DuplicateIPAddressBatch();
        Database.executeBatch(batch, 1);
    }
}