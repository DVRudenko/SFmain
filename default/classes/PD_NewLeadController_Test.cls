@isTest
private class PD_NewLeadController_Test {

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
        Lead lead = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
            LastName = 'test',
            Phone = '+7955 622 5334',
            Description = 'text 1.',
            Country = 'Russia',
            Company = 'test',
            Additional_Phones__c = '+4564656555.+8852584815.+45241215.+78451656.+78455626565.+784561651',
            Irrelevant_Phones__c = '+6455445488:0;+8487455215:1;+74545415642:2;+874651631:3;+7862515156:0;+84654641:1'
        );
        insert lead;
        PD_NewLeadController c = new PD_NewLeadController(new ApexPages.StandardController(lead));
        c.saveMe();
    }
}