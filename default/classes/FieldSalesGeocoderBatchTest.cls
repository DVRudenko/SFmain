@isTest
public class FieldSalesGeocoderBatchTest {

    @TestSetup
    static void testSetupMethod(){
        FieldSalesTerritory_General_Settings__c fieldSalesTerritorySettings = new FieldSalesTerritory_General_Settings__c();
        fieldSalesTerritorySettings.Name = 'RU';
        fieldSalesTerritorySettings.Penalty_for_refusal__c = 365;
        fieldSalesTerritorySettings.Geocoder_Request_Lead_Filter__c = ' AND Rating_FS__c > 1';
        fieldSalesTerritorySettings.Geocoder_Request_Account_Filter__c = ' AND Rating_FS__c > 1';
        fieldSalesTerritorySettings.Geocoder_Request_Record_Limit__c = 100;
        insert fieldSalesTerritorySettings;

        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 100,
                Region__c = 'Свердловская область', Phone = '+71234567890', BillingStreet = 'Екатеринбург Тверская д.3', INN__C = '1234567899999',
                RecordTypeId = RecordTypeAcc);
        insert account;

        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        Lead lead = new Lead(Phone = '+71234567891', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                Region__c = 'Свердловская область', Rating_FS__c = 100,
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru', Street = 'Екатеренбург',
                RecordTypeId = RecordTypeLead);
        insert lead;
    }

    @IsTest
    static void testBatchMethod1(){
        SingleRequestMock newMock = new SingleRequestMock(200,'OK','{"results" : [{"address_components" : [{"long_name" : "623702","short_name" : "623702","types" : [ "postal_code" ]},{"long_name" : "Свердловская область","short_name" : "Свердловская обл.","types" : [ "administrative_area_level_1", "political" ]},{"long_name" : "Екатеринбург","short_name" : "Екатеринбург","types" : [ "administrative_area_level_2" ]},{"long_name" : "Россия","short_name" : "RU", "types" : [ "country", "political" ]}],"formatted_address" : "Свердловская обл., Россия, 623702", "geometry" : {"bounds" : {"northeast" : {"lat" : 56.90778299999999, "lng" : 60.879642},"southwest" : {"lat" : 56.834169,"lng" : 60.81281689999999}}, "location" : {"lat" : 56.8712764, "lng" : 60.8409019}, "location_type" : "APPROXIMATE", "viewport" : {"northeast" : {"lat" : 56.90778299999999, "lng" : 60.879642},"southwest" : {"lat" : 56.834169, "lng" : 60.81281689999999}}},"partial_match" : true, "place_id" : "ChIJwyxBluISwUMRnH9dcSR2oJk", "types" : [ "postal_code" ]}], "status" : "OK"}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, newMock);
        Database.executeBatch(new FieldSalesGeocoderBatch(null));
        Test.stopTest();
        List<Lead> testResult = [SELECT Id, Street, Latitude, Longitude, Region__c FROM Lead WHERE INN__c = '1234567899999'];
        system.assertNotEquals(testResult.get(0).Longitude, null);
    }

    @IsTest
    static void testBatchMethod2(){
        SingleRequestMock newMock = new SingleRequestMock(200,'OK','{"results" : [{"address_components" : [{"long_name" : "623702","short_name" : "623702","types" : [ "postal_code" ]},{"long_name" : "Свердловская область","short_name" : "Свердловская обл.","types" : [ "administrative_area_level_1", "political" ]},{"long_name" : "Екатеринбург","short_name" : "Екатеринбург","types" : [ "administrative_area_level_2" ]},{"long_name" : "Россия","short_name" : "RU", "types" : [ "country", "political" ]}],"formatted_address" : "Свердловская обл., Россия, 623702", "geometry" : {"bounds" : {"northeast" : {"lat" : 56.90778299999999, "lng" : 60.879642},"southwest" : {"lat" : 56.834169,"lng" : 60.81281689999999}}, "location" : {"lat" : 56.8712764, "lng" : 60.8409019}, "location_type" : "APPROXIMATE", "viewport" : {"northeast" : {"lat" : 56.90778299999999, "lng" : 60.879642},"southwest" : {"lat" : 56.834169, "lng" : 60.81281689999999}}},"partial_match" : true, "place_id" : "ChIJwyxBluISwUMRnH9dcSR2oJk", "types" : [ "postal_code" ]}], "status" : "OK"}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, newMock);
        Database.executeBatch(new FieldSalesGeocoderBatch('Свердловская область'));
        Test.stopTest();
        List<Lead> testResult = [SELECT Id, Street, Latitude, Longitude, Region__c FROM Lead WHERE INN__c = '1234567899999'];
        system.assertNotEquals(testResult.get(0).Longitude, null);
    }

}