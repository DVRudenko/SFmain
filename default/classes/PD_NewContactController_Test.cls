@isTest
private class PD_NewContactController_Test {

    private static void init(){
        PD_Setting__c sett = new PD_Setting__c(
                URL__c = 'https://df-maxy-aflex.enterprise.dreamfactory.com/api/v2',
                Token__c = 'asdsdfsdfeferwertwer',
                Name = 'testsetting'
        );
        insert sett;
    }

    @isTest static void testConstructor() {
        init();
        Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            Name = 'test acc',
            Phone = '+74956220000',
            Phone_Status__c = 'New'
        );
        insert acc;
        Contact con = new Contact(
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            AccountId = acc.Id,
            Salutation = 'Herr',
            FirstName = 'name',
            LastName = 'test',
            Phone = '+74956221111#001',
            Phone_Status__c = 'New',
            MobilePhone = '+74956222222#002',
            MobilePhone_Status__c = 'New'
        );
        insert con;
        PD_NewContactController c = new PD_NewContactController(new ApexPages.StandardController(con));
        c.saveMe();
        c.recordCreated = false;
        c.openRecord();
        c.rerenderPage();
        c.recordCreated = true;
        c.openRecord();
        c.rerenderPage();
        ApexPages.currentPage().getParameters().put('pdDataSaved', 'true');
        PD_NewContactController c2 = new PD_NewContactController(new ApexPages.StandardController(con));
    }
}