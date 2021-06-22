trigger FeedCommentTrigger on FeedComment (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        FeedCommentHandler.initRespectiveSupportCases(Trigger.new);
        FeedCommentHandler.checkPermissionCommentInCase(Trigger.new);
        FeedCommentHandler.initRespectiveFeedItems(Trigger.new);
        FeedCommentHandler.updateCaseStatus(Trigger.new);
    }
}