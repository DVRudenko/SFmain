trigger FeedItemTrigger on FeedItem (before insert, after insert ) {
    if(Trigger.isBefore && Trigger.isInsert) {
        FeedItemHandler.initRespectiveSupportCases(Trigger.new);
        FeedItemHandler.parserFeedItemBody(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        FeedItemHandler.checkPermissionPostInCase(Trigger.new);
        FeedItemHandler.updateCaseStatus(Trigger.new);
    }
}