@IsTest
public with sharing class FeedItemTriggerTest {

    private static final String CASE_SUPPORT_RECORDTYPE_ID = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    private static final String CASE_OWNER_ID = UserInfo.getUserId();
    private static final String OTHER_OWNER_ID = ([SELECT Id FROM User WHERE Name = 'Integration Administrator']).Id;

    @IsTest
    private static void testCaseInternallyUpdated() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.internally_updated);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(0, c.PostsByOwner__c);
        FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting), c.Status);
        System.assertEquals(1, c.PostsByOwner__c);
    }

    @IsTest
    private static void testSupportNew() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.status_new);
        FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting), c.Status);

    }

    @IsTest
    private static void testCaseCustomerWaiting() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.customer_waiting);
        FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting), c.Status);
    }

    @IsTest
    private static void testCaseCustomerUpdated() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.customer_updated);
        FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting), c.Status);
    }

    @IsTest
    private static void testCaseResolved() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.resolved);
        FeedItem feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        feedItem = FeedTestUtils.selectPost(feedItem.Id);
        System.assertEquals(GlobalUtils.FeedItemType.TextPost.name(), feedItem.Type);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.internally_waiting), c.Status);
    }

    @IsTest
    private static void testNotUsersPost() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.status_new);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(0, c.PostsByOwner__c);
        FeedItem feedItem = FeedTestUtils.createPost(c.Id, CASE_OWNER_ID, GlobalUtils.FeedItemType.ActivityEvent.name(), '');
        feedItem = FeedTestUtils.selectPost(feedItem.Id);
        System.assertEquals(GlobalUtils.FeedItemType.ActivityEvent.name(), feedItem.Type);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new), c.Status);
        System.assertEquals(0, c.PostsByOwner__c);
    }

    @IsTest
    private static void testNotUsersPostStatusClosedRestriction() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.closed);
        FeedTestUtils.createPost(c.Id, CASE_OWNER_ID, GlobalUtils.FeedItemType.ActivityEvent.name(), '');
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed), c.Status);
    }

    @IsTest
    private static void testNotUsersPostOtherOwnerRestriction() {
        Case c = FeedTestUtils.createCase(CASE_SUPPORT_RECORDTYPE_ID, CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.status_new);
        FeedTestUtils.createPost(c.Id, OTHER_OWNER_ID, GlobalUtils.FeedItemType.ActivityEvent.name(), '');
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new), c.Status);
    }

    @IsTest
    private static void testCaseNotSupport() {
        Case c = FeedTestUtils.createCase(GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Development.name()), CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.status_new);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(0, c.PostsByOwner__c);
        FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new), c.Status);
        System.assertEquals(0, c.PostsByOwner__c);
    }

    @IsTest
    private static void testCaseNotSupportStatusClosedRestriction() {
        Case c = FeedTestUtils.createCase(GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Development.name()), CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.closed);
        FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed), c.Status);
    }

    @IsTest
    private static void testCaseNotSupportOtherOwnerRestriction() {
        Case c = FeedTestUtils.createCase(GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Development.name()), CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.status_new);
        FeedTestUtils.createTextPost(c.Id, OTHER_OWNER_ID);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new), c.Status);
    }

    @IsTest
    private static void testCaseOtherOwnerRestriction() {
        Case c = FeedTestUtils.createCase(GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name()), CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.status_new);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(0, c.PostsByOwner__c);
        FeedItem feedItem;
        try {
            feedItem = FeedTestUtils.createTextPost(c.Id, OTHER_OWNER_ID);
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.No_posts_in_not_owned_case));
            System.assertEquals(null, feedItem);
            c = FeedTestUtils.selectCase(c.Id);
            System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new), c.Status);
            System.assertEquals(0, c.PostsByOwner__c);
        }
    }

    @IsTest
    private static void testCaseStatusClosedRestriction() {
        Case c = FeedTestUtils.createCase(GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name()), CASE_OWNER_ID, GlobalUtils.SupportCaseStatus.closed);
        c = FeedTestUtils.selectCase(c.Id);
        System.assertEquals(0, c.PostsByOwner__c);
        FeedItem feedItem;
        try {
            feedItem = FeedTestUtils.createTextPost(c.Id, CASE_OWNER_ID);
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.No_posts_in_closed_case));
            System.assertEquals(null, feedItem);
            c = FeedTestUtils.selectCase(c.Id);
            System.assertEquals(GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed), c.Status);
            System.assertEquals(0, c.PostsByOwner__c);
        }
    }
}