@IsTest
public with sharing class PhoneNumbersControllerTest {
    @TestSetup
    static void makeData(){
        PD_Setting__c settings = new PD_Setting__c(
                URL__c = 'https://df-maxy-aflex.enterprise.dreamfactory.com/api/v2',
                Token__c = 'asdsdfsdfeferwertwer',
                Name = 'testsetting'
        );
        insert settings;
    }
    @IsTest
    private static void testController_Lead () {
        Lead lead = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7955 622 5334',
            Description = 'text 1.',
            Country = 'Russia',
            Company = 'TestCompany',
            Additional_Phones__c = '+4564656555.+8852584815.+45241215.+78451656.+78455626565.+784561651',
            Irrelevant_Phones__c = '+6455445488:0;+8487455215:1;+74545415642:2;+874651631:3;+7862515156:0;+84654641:1'
        );
        insert lead;
        ApexPages.StandardController stdController = new ApexPages.StandardController(lead);
        PhoneNumbersController controller = new PhoneNumbersController (stdController);
        testController (Schema.Lead.sObjectType, controller);
    }
    @IsTest
    private static void testController_Contact () {
        Contact con = new Contact(
            Salutation = 'Herr',
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7955 622 5334',
            MobilePhone = '+7955 02 55334',
            Additional_Phones__c = '+4564656555.+8852584815.+45241215.+78451656.+78455626565.+784561651',
            Irrelevant_Phones__c = '+6455445488:0;+8487455215:1;+74545415642:2;+874651631:3;+7862515156:0;+84654641:1'
        );
        insert con;
        ApexPages.StandardController stdController = new ApexPages.StandardController(con);
        PhoneNumbersController controller = new PhoneNumbersController (stdController);
        testController (Schema.Contact.sObjectType, controller);
    }
    @IsTest
    private static void testController_Account () {
        Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            Name = 'test acc',
            Phone = '+7495 622 0000',
            Irrelevant_Phones__c = '+6455445488:0;+8487455215:1;+74545415642:2;+874651631:3;+7862515156:0;+84654641:1'
        );
        insert acc;
        Contact con = new Contact(
            AccountId = acc.Id,
            Salutation = 'Herr',
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7955 622 5334',
            MobilePhone = '+7955 02 55334'
        );
        insert con;
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        PhoneNumbersController controller = new PhoneNumbersController (stdController);
        testController (Schema.Account.sObjectType, controller);
    }
    private static void testController (Schema.sObjectType sObjType, PhoneNumbersController controller) {
        // phone fields
        if (controller.phoneRowWrappers != null && !controller.phoneRowWrappers.isEmpty()) {
           controller.phoneRowWrappers[0].editRow();
           controller.phoneRowWrappers[0].cancelEditRow();
        }
           controller.toEdit();
           controller.save_PhoneFields();
           controller.refreshPhoneFields ();
           controller.toView ();
   
       // irrelevant phones
       if (controller.irrelevantPhonesList != null && !controller.irrelevantPhonesList.isEmpty()) {
            if (sObjType == Schema.Account.sObjectType) {
                List <Contact> cons = [SELECT Id FROM Contact WHERE AccountId = :String.valueOf(controller.sObj.get('Id'))];
                Id conId = cons[0].Id;
                controller.irrelevantPhonesList[0].currentPhoneFieldAPI = 'Contact.'+conId+'.Phone';
                controller.irrelevantPhonesList[0].moveToPhoneField();
                controller.irrelevantPhonesList[0].continueMoveToField();
            } else {
                controller.irrelevantPhonesList[0].currentPhoneFieldAPI = 'Phone';
                controller.irrelevantPhonesList[0].moveToPhoneField();
                controller.irrelevantPhonesList[0].moveToPhoneField();
        
                controller.irrelevantPhonesList[1].currentPhoneFieldAPI = 'Phone';
                controller.irrelevantPhonesList[1].moveToPhoneField();
                controller.irrelevantPhonesList[1].cancelMoveToField ();
        
                controller.irrelevantPhonesList[2].currentPhoneFieldAPI = 'MobilePhone';
                controller.irrelevantPhonesList[2].moveToPhoneField();
            }
   
           controller.irrelevantPhonesList[3].deleteIrrelevantPhoneNumber();
   
           controller.refreshIrrelevantPhonesList ();
        }
        // additional phones
        if (controller.additionalPhonesList != null && !controller.additionalPhonesList.isEmpty()) {
           controller.additionalPhonesList[0].editAdditionalPhone ();
           controller.additionalPhonesList[0].cancelEditAdditionalPhone ();
   
           controller.additionalPhonesList[0].currentPhoneFieldAPI = 'Phone';
           controller.additionalPhonesList[0].moveToPhoneField();
           controller.additionalPhonesList[0].cancelMoveToField();
   
           controller.additionalPhonesList[0].currentPhoneFieldAPI = 'Phone';
           controller.additionalPhonesList[0].moveToPhoneField();
           controller.additionalPhonesList[0].continueMoveToField();
   
           controller.additionalPhonesList[0].makeIrrelevant();
           controller.additionalPhonesList[0].moveToIrrelevant_Record();
   
           controller.additionalPhonesList[1].makeIrrelevant();
           controller.additionalPhonesList[1].moveToIrrelevant_Global();
   
           controller.newAdditionalPhoneNumber = '+78745651651';
           controller.addAdditionalPhone ();
   
           controller.saveAdditionalPhones ();
   
           controller.refreshAdditionalPhones ();
   
           controller.toEditMode_AdditionalPhones ();
           controller.toViewMode_AdditionalPhones ();
        }
    }
}