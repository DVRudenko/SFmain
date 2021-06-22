@isTest
private class LocatorStationsBatchTest {

    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];

        for (Integer i=0;i<10;i++) {
            accounts.add(new Account(
                    Name='Account '+i,
                    BillingCity='City ' + i,
                    ShippingCity='City ' + i,
                    BillingStreet='Street ' + i,
                    ShippingStreet='Street ' + i,
                    BillingPostalCode='PostalCode ' + i,
                    ShippingPostalCode='PostalCode ' + i,
                    BillingCountry='Austria',
                    ShippingCountry='Austria',
                    OBN__c=String.valueOf(i),
                    Phone='+4331333258',
                    RecordTypeId= recordType.Id
            ));
        }
        insert accounts;
    }

    @isTest 
    static void countriesNotContainsTest() {
        Test.startTest();            

        String stationsJson = '['+
                '{"name":"name 1","address":"address 1","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"telephone 1","esi":"esi 1"},'+
                '{"name":"name 2","address":"address 2","city":"city 2","postCode":"postCode 2","country":"Austria","telephone":"telephone 2","esi":"esi 2"}]';

        List<LocatorStation> stations = LocatorStation.parse(stationsJson);
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];
        LocatorStationsBatch locatorBatch = new LocatorStationsBatch(stations, recordType.Id);
        Id batchId = Database.executeBatch(locatorBatch, 10);
        Test.stopTest();
        AsyncApexJob batchJob = [
                SELECT NumberOfErrors, Status, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :batchId
                LIMIT 1
        ];
        System.assertEquals(batchJob.Status, 'Completed');
        System.abortJob(batchId);

    }

    @isTest 
    static void stationsContainsActualPhonesTest() {
        Test.startTest();

        String stationsJson = '['+
                '{"name":"name 1","address":"","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"+4331333258","esi":"1"},'+
                '{"name":"name 2","address":"address 2","city":"","postCode":"postCode 2","country":"Austria","telephone":"+4331333257","esi":"2"},'+
                '{"name":"name 3","address":"address 3","city":"city 3","postCode":"","country":"Austria","telephone":"+4331333258","esi":"3"},'+
                '{"name":"name 4","address":"address 4","city":"city 4","postCode":"postCode 4","country":"Austria","telephone":"","esi":"4"},'+
                '{"name":"name 5","address":"address 5","city":"city 5","postCode":"postCode 5","country":"Austria","telephone":"+4331333256","esi":""},'+
                '{"name":"name 6","address":"address 6","city":"city 6","postCode":"postCode 6","country":"Austria","telephone":"+4331333253","esi":"6"},'+
                '{"name":"name 7","address":"address 7","city":"city 7","postCode":"postCode 7","country":"Austria","telephone":"+4331333255","esi":"7"},'+
                '{"name":"name 8","address":"address 8","city":"city 8","postCode":"postCode 8","country":"Austria","telephone":"+4331333254","esi":"8"},'+
                '{"name":"name 9","address":"address 9","city":"city 9","postCode":"postCode 9","country":"Austria","telephone":"+4331333253","esi":"9"}]';

        List<LocatorStation> stations = LocatorStation.parse(stationsJson);
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];
        LocatorStationsBatch locatorBatch = new LocatorStationsBatch(stations, recordType.Id);
        Id batchId = Database.executeBatch(locatorBatch, 10);
        Test.stopTest();
        AsyncApexJob batchJob = [
                SELECT NumberOfErrors, Status, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :batchId
                LIMIT 1
        ];
        System.assertEquals(batchJob.Status, 'Completed');
        System.abortJob(batchId);
        List<Folder> folder = [SELECT Id FROM Folder WHERE Name = 'Account Locator Update Errors'];
        String folderId;
        if ( ! folder.isEmpty() ) {
            folderId = folder.get(0).Id;
        }
        List<Document> errorsList = new List<Document>();

        if(folderId != null){
            String docName = batchId + '.csv';
            errorsList = [
                    SELECT Id, Body
                    FROM Document
                    WHERE Name = :docName AND FolderId = :folderId];
        }

        System.assert(errorsList.isEmpty());
    }

    @isTest 
    static void stationsContainsInvalidPhonesTest() {
        Test.startTest();

        String stationsJson = '['+
                '{"name":"name 1","address":"","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"+4331333258","esi":"1"},'+
                '{"name":"name 2","address":"address 2","city":"","postCode":"postCode 2","country":"Austria","telephone":"+4331333257","esi":"2"},'+
                '{"name":"name 3","address":"address 3","city":"city 3","postCode":"","country":"Austria","telephone":"+4331333258","esi":"3"},'+
                '{"name":"name 4","address":"address 4","city":"city 4","postCode":"postCode 4","country":"Austria","telephone":"","esi":"4"},'+
                '{"name":"name 5","address":"address 5","city":"city 5","postCode":"postCode 5","country":"Austria","telephone":"+4331333256","esi":""},'+
                '{"name":"name 6","address":"address 6","city":"city 6","postCode":"postCode 6","country":"Austria","telephone":"retwadr323523523nrtwndweghwegwehweh3242352236235wehwehwehwehwehwefsgrt325wegwehwehwefweg","esi":"6"},'+
                '{"name":"name 7","address":"address 7","city":"city 7","postCode":"postCode 7","country":"Austria","telephone":"+4331333255","esi":"7"},'+
                '{"name":"name 8","address":"address 8","city":"city 8","postCode":"postCode 8","country":"Austria","telephone":"+4331333254","esi":"8"},'+
                '{"name":"name 9","address":"address 9","city":"city 9","postCode":"postCode 9","country":"Austria","telephone":"erberberberwny","esi":"9"}]';

        List<LocatorStation> stations = LocatorStation.parse(stationsJson);
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];
        LocatorStationsBatch locatorBatch = new LocatorStationsBatch(stations, recordType.Id);
        Id batchId = Database.executeBatch(locatorBatch, 10);
        Test.stopTest();
        AsyncApexJob batchJob = [
                SELECT NumberOfErrors, Status, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :batchId
                LIMIT 1
        ];
        System.assertEquals(batchJob.Status, 'Completed');
        System.abortJob(batchId);

        List<Folder> folderAfter = [SELECT Id FROM Folder WHERE Name = 'Account Locator Update Errors'];
        String folderAfterId;
        if ( ! folderAfter.isEmpty() ) {
            folderAfterId = folderAfter.get(0).Id;
        }
        List<Document> errorsList = new List<Document>();

        if(folderAfterId != null){
            String docNameAfter = batchId + '.csv';
            errorsList = [
                    SELECT Id, Body
                    FROM Document
                    WHERE Name = :docNameAfter AND FolderId = :folderAfterId];
        }

        System.assert(!errorsList.isEmpty());
    }

    @isTest 
    static void stationsContainsInvalidPhones2Test() {
        Test.startTest();

        String stationsJson = '['+
                '{"name":"name 9","address":"","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"+4331333258","esi":"1"},'+
                '{"name":"name 8","address":"address 2","city":"","postCode":"postCode 2","country":"Austria","telephone":"+4331333257","esi":"2"},'+
                '{"name":"name 7","address":"address 3","city":"city 3","postCode":"","country":"Austria","telephone":"+4331333258","esi":"3"},'+
                '{"name":"name 6","address":"address 4","city":"city 4","postCode":"postCode 4","country":"Austria","telephone":"","esi":"4"},'+
                '{"name":"name 5","address":"address 5","city":"city 5","postCode":"postCode 5","country":"Austria","telephone":"+4331333256","esi":""},'+
                '{"name":"name 4","address":"address 6","city":"city 6","postCode":"postCode 6","country":"Austria","telephone":"retwadrnrtwnd","esi":"6"},'+
                '{"name":"name 3","address":"address 7","city":"city 7","postCode":"postCode 7","country":"Austria","telephone":"+4331333255","esi":"7"},'+
                '{"name":"name 10","address":"address 8","city":"city 8","postCode":"postCode 8","country":"Austria","telephone":"+4331333254","esi":"8"},'+
                '{"name":"name 1","address":"address 9","city":"city 9","postCode":"postCode 9","country":"Austria","telephone":"erberberberwny","esi":"9"}]';

        List<LocatorStation> stations = LocatorStation.parse(stationsJson);
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];
        LocatorStationsBatch locatorBatch = new LocatorStationsBatch(stations, recordType.Id);
        Id batchId = Database.executeBatch(locatorBatch, 10);
        List<Folder> folder = [SELECT Id FROM Folder WHERE Name = 'Account Locator Update Errors'];
        String folderId;
        if ( ! folder.isEmpty() ) {
            folderId = folder.get(0).Id;
        }
        String docName = batchId + '.csv';
        Document doc = new Document(
                Name = docName,
                Body = Blob.valueOf('Error name'),
                FolderId = folderId
        );
        insert doc;
        Test.stopTest();
        AsyncApexJob batchJob = [
                SELECT NumberOfErrors, Status, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :batchId
                LIMIT 1
        ];
        System.assertEquals(batchJob.Status, 'Completed');
        System.abortJob(batchId);

        List<Folder> folderAfter = [SELECT Id FROM Folder WHERE Name = 'Account Locator Update Errors'];
        String folderAfterId;
        if ( ! folderAfter.isEmpty() ) {
            folderAfterId = folderAfter.get(0).Id;
        }
        List<Document> errorsList = new List<Document>();

        if(folderAfterId != null){
            String docNameAfter = batchId + '.csv';
            errorsList = [
                    SELECT Id, Body
                    FROM Document
                    WHERE Name = :docNameAfter AND FolderId = :folderAfterId];
        }

        System.assert(!errorsList.isEmpty());
    }

    @isTest 
    static void updateDocumentTest() {
        String batchId = 'abcdefghijklmnop';
        LocatorStationsBatch.updateDocument(batchId, 'Text error 1');
        LocatorStationsBatch.updateDocument(batchId, 'Text error 2');
        List<Folder> folderAfter = [SELECT Id FROM Folder WHERE Name = 'Account Locator Update Errors'];
        String folderAfterId;
        if ( ! folderAfter.isEmpty() ) {
            folderAfterId = folderAfter.get(0).Id;
        }
        List<Document> errorsList = new List<Document>();
        if(folderAfterId != null){
            String docNameAfter = batchId + '.csv';
            errorsList = [
                    SELECT Id, Body
                    FROM Document
                    WHERE Name = :docNameAfter AND FolderId = :folderAfterId];
        }
        System.assert(!errorsList.isEmpty());
    }
}