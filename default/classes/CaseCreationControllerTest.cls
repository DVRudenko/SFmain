@isTest
public class CaseCreationControllerTest {

    @isTest
    private static void testGetParentAccountForERP(){
        Account acc = new Account(Name='TestErp', BillingCountry='Austria');
        insert acc;
        ERP__c erp = new ERP__c(Account__c = acc.id);
        insert erp;
        String result = CaseCreationPageController.GetParentAccountForERP(erp.Id);
        System.assertEquals(result, acc.id);
    }
    
    @isTest
    private static void testGetRecordTypeIds() {
        Map<String, String> supportRecordTypes = CaseCreationPageController.getRecordTypes();
        System.assertEquals(2, supportRecordTypes.values().size());
    }

    @isTest
    private static void testGetPickListValueList() {
        RecordType supportRecordType = [
            SELECT  Id
            FROM    RecordType
            WHERE   Name = 'Support'
            LIMIT   1
        ];
        List<String> topicPickListValues =  CaseCreationPageController.getPickListValueList('Case', 'Sub_Topic__c', supportRecordType.Id, 'Cards');
        System.assert(topicPickListValues != null);
    }

    @isTest
    private static void attachFileToCase() {
        RecordType supportRecordType = [
            SELECT  Id
            FROM    RecordType
            WHERE   Name = 'Support'
            LIMIT   1
        ];

        Case testCase = new Case(
            RecordTypeId = supportRecordType.Id,
            Status = 'New'
        );

        insert testCase;

        CaseCreationPageController.attachFileToCase('dGVzdA==', 'test.pdf', testCase.Id);

        Attachment newAttachment = [
            SELECT  Id,
                    Name
            FROM    Attachment
            WHERE   ParentId =: testCase.Id
            LIMIT   1
        ];

        System.assertEquals('test.pdf', newAttachment.Name);
    }

}
