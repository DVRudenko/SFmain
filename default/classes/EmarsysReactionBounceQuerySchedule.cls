/**
 * Created by Nikita.Dayanov on 24.10.2018.
 * @author Nikita Dayanova
 */

global class EmarsysReactionBounceQuerySchedule implements Schedulable{

    /*******************************************************************************
    *  @description     Execute batch for creating query for bounce status updates
    *  @date            24/10/2018
    *  @param context   object to track the schedulable job
    *  @return          void
    ******************************************************************************/
    global void execute(SchedulableContext context) {
        EmarsysReactionBounceQueryIdGetter getEmarsysTypeBatch = new EmarsysReactionBounceQueryIdGetter();
        Database.executeBatch(getEmarsysTypeBatch);
    }
}