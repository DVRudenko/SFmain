public with sharing class FeedTestUtils {

    public static Case createCase(Id recordTypeId, Id ownerId, GlobalUtils.SupportCaseStatus status) {
        Case c = new Case(
                RecordTypeId = recordTypeId,
                OwnerId = ownerId,
                Status = GlobalUtils.getSupportCaseStatus(status)
        );
        insert c;
        return c;
    }

    public static FeedItem createTextPost(Id parentId, Id ownerId) {
        FeedItem feedItem = new FeedItem(
                ParentId = parentId,
                CreatedById = ownerId,
                Body = 'dfgdfg',
                Type = GlobalUtils.FeedItemType.TextPost.name()
        );
        insert feedItem;
        return feedItem;
    }

    public static FeedItem createPost(Id parentId, Id ownerId, String postType, String content) {
        FeedItem feedItem = new FeedItem(
                ParentId = parentId,
                CreatedById = ownerId,
                Body = content,
                Type = postType
        );
        insert feedItem;
        return feedItem;
    }

    public static Case selectCase(Id caseId) {
        return ([
                SELECT Status, PostsByOwner__c
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
        ]);
    }

    public static FeedItem selectPost(Id feedItemId) {
        return ([
                SELECT Type
                FROM FeedItem
                WHERE Id = :feedItemId
                LIMIT 1
        ]);
    }

    public static FeedComment createComment(Id feedItemId, Id ownerId) {
        FeedComment feedComment = new FeedComment(
                CreatedById = ownerId,
                FeedItemId = feedItemId,
                CommentBody = 'fdsfsd'
        );
        insert feedComment;
        return feedComment;
    }

}