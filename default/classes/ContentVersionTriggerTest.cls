@isTest
public class ContentVersionTriggerTest {

    @isTest
    public static void testSetupEmptyName() {
        ContentVersion document = new ContentVersion(
            Title = '',
            PathOnClient = 'test',
            VersionData = EncodingUtil.base64Decode('dGVzdA==')
        );

        insert document;

        ContentVersion newDoc = [
            SELECT  Title
            FROM    ContentVersion
            WHERE   Id =: document.Id
        ];

        System.assertEquals('test', newDoc.Title);
    }

    @isTest
    public static void testSetupEmptyPath() {
        ContentVersion document = new ContentVersion(
            Title = '',
            ContentUrl = 'test.test'
        );

        insert document;

        ContentVersion newDoc = [
            SELECT  Title
            FROM    ContentVersion
            WHERE   Id =: document.Id
        ];

        System.assertEquals('Untitled', newDoc.Title);
    }

    @isTest
    public static void removeSignatureTest() {
        List<ContentVersion> testDocumentList = new List<ContentVersion>();

        test.startTest();

        ContentVersion testDocument = new ContentVersion(
            Title = 'image001',
            PathOnClient = 'image001.png',
            VersionData = EncodingUtil.base64Decode('dGVzdA==')
        );
        testDocumentList.add(testDocument);


        insert testDocumentList;

        test.stopTest();

        List<ContentDocument> resultDocumentList = [
            SELECT  Id,
                    Title
            FROM    ContentDocument
        ];

        System.assertEquals(1, resultDocumentList.size());
        System.assertEquals('image001', resultDocumentList[0].Title);
    }
}