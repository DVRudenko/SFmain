@IsTest
public with sharing class FeedCommentTriggerTest {

    private static final String CASE_SUPPORT_RECORDTYPE_ID = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    private static final String CASE_OWNER_ID = UserInfo.getUserId();
    private static final String OTHER_OWNER_ID = ([SELECT Id FROM User WHERE Name = 'Integration Administrator']).Id;

    @IsTest
    private static void testCaseInternallyWaiting() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.internally_waiting);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting);
        update c;
        FeedTestUtils.createComment(feedItem.Id, OTHER_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_updated), c.Status);
    }

    @IsTest
    private static void testCaseCustomerWaiting() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.customer_waiting);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.customer_waiting);
        update c;
        FeedTestUtils.createComment(feedItem.Id, OTHER_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_updated), c.Status);
    }

    @IsTest
    private static void testCaseCustomerUpdated() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.customer_updated);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.customer_updated);
        update c;
        FeedTestUtils.createComment(feedItem.Id, OTHER_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_updated), c.Status);
    }

    @IsTest
    private static void testCaseResolved() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.resolved);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.resolved);
        c.Topic__c = '';
        c.Sub_topic__c = '';
        update c;
        FeedTestUtils.createComment(feedItem.Id, OTHER_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_updated), c.Status);
    }

    @IsTest
    private static void testCaseNew() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.status_new);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new);
        update c;
        FeedTestUtils.createComment(feedItem.Id, OTHER_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new), c.Status);
    }

    @IsTest
    private static void testCaseNotSupportStatusClosedRestriction() {
        Case c = FeedTestUtils.createCase(GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Development.name()), CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.closed);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed), c.Status);
        FeedTestUtils.createComment(feedItem.Id, OTHER_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed), c.Status);
    }

    @IsTest
    private static void testIsPostOwner() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.customer_waiting);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c.Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.customer_waiting);
        update c;
        FeedTestUtils.createComment(feedItem.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.customer_waiting), c.Status);
    }

    @IsTest
    private static void testCaseStatusClosedRestriction() {
        Case c = FeedTestUtils.createCase(GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name()), CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.closed);
        FeedItem feedItem = FeedTestUtils.createPost(c.Id, CASE_OWNER_ID, GlobalUtils.FeedItemType.ActivityEvent.name(), '');
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed), c.Status);
        FeedComment feedComment;
        try {
            feedComment = FeedTestUtils.createComment(feedItem.Id, OTHER_OWNER_ID);
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.No_comments_in_closed_case));
            System.assertEquals(null, feedComment);
            c = FeedTestUtils.selectCase(c.Id);
            System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed), c.Status);
        }
    }
}