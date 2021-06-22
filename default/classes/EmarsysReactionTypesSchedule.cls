/**
 * Created by Nikita.Dayanov on 18.10.2018.
 * @author Nikita Dayanov
 */

global class EmarsysReactionTypesSchedule implements Schedulable {

    /*******************************************************************************
    *  @description     Execute batch for getting reactions by query Id
    *  @date            24/10/2018
    *  @param context   object to track the schedulable job
    *  @return          void
    ******************************************************************************/
    global void execute(SchedulableContext context) {
        EmarsysReactionTypesGetter getEmarsysTypeBatch = new EmarsysReactionTypesGetter();
        Database.executeBatch(getEmarsysTypeBatch);
    }
}