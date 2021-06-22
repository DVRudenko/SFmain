/**
 * Created by Nikita.Dayanov on 24.10.2018.
 * @author Nikita Dayanov
 */

global class EmarsysReactionBounceStatusSchedule implements Schedulable{

    /*******************************************************************************
    *  @description     Execute batch for getting bounce status by query Id
    *  @date            24/10/2018
    *  @param context   object to track the schedulable job
    *  @return          void
    ******************************************************************************/
    global void execute(SchedulableContext context) {
        EmarsysReactionBounceStatusGetter getEmarsysTypeBatch = new EmarsysReactionBounceStatusGetter();
        Database.executeBatch(getEmarsysTypeBatch);
    }

}