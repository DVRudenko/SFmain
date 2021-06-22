/**
 * Created by Nikita.Dayanov on 18.10.2018.
 * @author Nikita Dayanov
 */

global class EmarsysQueryGetterSchedule implements Schedulable {

    /*******************************************************************************
    *  @description     Execute batch for creating query for reaction updates
    *  @date            24/10/2018
    *  @param context   object to track the schedulable job
    *  @return          void
    ******************************************************************************/
    global void execute(SchedulableContext context) {
        EmarsysReactionQueryIdGetter setEmarsysTypeBatch = new EmarsysReactionQueryIdGetter();
        Database.executeBatch(setEmarsysTypeBatch);
    }
}