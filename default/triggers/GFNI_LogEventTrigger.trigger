/**
 * Created by Nikita.Mikhailov on 19.10.2020.
 */

trigger GFNI_LogEventTrigger on GFNI_Log__e (after insert) {
    GFNI_LogEventTriggerHandler.storeLogs(Trigger.new);
}