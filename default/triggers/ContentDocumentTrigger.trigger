/**
 * Created by marekhaken on 22/10/2020.
 */

trigger ContentDocumentTrigger on ContentDocument (before delete) {

    if(Trigger.isBefore && Trigger.isDelete){
        ContentDocumentTriggerHandler.carnetDeleteCD(Trigger.old);
    }
}