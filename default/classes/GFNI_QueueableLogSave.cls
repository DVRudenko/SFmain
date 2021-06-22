/**
 * Created by Nikita.Mikhailov on 21.01.2019.
 */

public with sharing class GFNI_QueueableLogSave implements Queueable {
    List<GFNI_Opportunity_log__b> logs;

    public GFNI_QueueableLogSave(List<GFNI_Opportunity_log__b> logs) {
        this.logs = logs;
    }

    public void execute(QueueableContext context) {
        System.debug('INSERTING: ' + this.logs);
        if (!Test.isRunningTest())
            List<Database.SaveResult> results = Database.insertImmediate(this.logs);
    }
}