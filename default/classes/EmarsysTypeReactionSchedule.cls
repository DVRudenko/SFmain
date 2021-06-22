global class EmarsysTypeReactionSchedule implements Schedulable {


    /*******************************************************************************
    *  Name            : execute(Schedulable sc)
    *  Summary         : execute batch for creating Russian Logs
    *  CreatedDate     : 19/10/2017
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext sc) {
        try {

            EmarsysTypeSetQuery setEmarsysTypeBatch = new EmarsysTypeSetQuery();
            Database.executeBatch(setEmarsysTypeBatch);

            EmarsysTypeGetQuery getEmarsysTypeBatch = new EmarsysTypeGetQuery();
            Database.executeBatch(getEmarsysTypeBatch);

        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }
}