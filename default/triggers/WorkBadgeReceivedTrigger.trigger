/**
 * Created by Andrei.Moiseev on 17.11.2017.
 */

trigger WorkBadgeReceivedTrigger on WorkBadge (before insert, after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        WorkBadgeReceivedHandler.runAfterInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isInsert) {
        WorkBadgeReceivedHandler.runBeforeInsert(Trigger.new);
    }
}