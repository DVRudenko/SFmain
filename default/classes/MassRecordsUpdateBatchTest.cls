@IsTest
public  class MassRecordsUpdateBatchTest {
    @testSetup
    private static void setupData() {
        Id leadRTIdRu = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        List <Lead> newLeads = new List <Lead> ();
        for (Integer i; i < 50; i++) {
            String numStr =  i < 10 ? '0'+i : String.valueOf(i);
            Lead newLead = new Lead(
                RecordTypeId = leadRTIdRu,
                FirstName = 'test name',
                LastName = 'l'+i,
                Description = 'text 1.',
                Country = 'Russia',
                CountryCode = 'RU',
                Company = 'TestCompany',
                Phone = '+788877700'+numStr
            );
            newLeads.add(newLead);
        }
        insert newLeads;
    }
    @IsTest
    private static void testBatch_Leads() {
        List <SObject> sObjectsToUpdate = [SELECT Id, Name FROM Lead];
        for (SObject sObj : sObjectsToUpdate) {
            sObj.put('Phone', String.valueOf(sObj.get('Phone')).replace('888777', '333444'));
        }
        Test.startTest();
        Database.executeBatch(new MassRecordsUpdateBatch (sObjectsToUpdate), 100);
        Test.stopTest();
    }
}
