trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before delete) {
    if (Trigger.isInsert && Trigger.isAfter) {
        ContentDocumentLinkHandler.processAttachmentsToClosedCase(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isDelete){
        ContentDocumentLinkHandler.carnetDeleteCDL(Trigger.old);
    }
}