@IsTest
private class FieldSalesPresentationCtrlTest {

    @IsTest
    static void testInitLead(){
        Lead lead = new Lead(Phone = '+71234567890', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567890',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead;
        Event event = new Event(WhoId = lead.Id, DurationInMinutes = 1, ActivityDateTime = system.now().addDays(1));
        insert event;

        PageReference pageRef = Page.FieldSalesTerritory;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('eventId', event.Id);
        FieldSalesPresentationCtrl fsPresentation = new FieldSalesPresentationCtrl();
        fsPresentation.init();

        system.assertNotEquals(fsPresentation.inn, null);
        system.assertNotEquals(fsPresentation.phone, null);
    }

    @IsTest
    static void testInitOpportunity(){
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 1000000, Industry = 'Г',
                Phone = '+71234567890', BillingStreet = 'САНКТ-ПЕТЕРБУРГ', INN__C = '1234567899999', BillingCountry = 'Russia');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50),  AccountId = account.id);
        insert opportunity;
        Contact contact = new Contact(LastName = 'testcontact12345',Phone = '+71234567890',Email = 'test@testcont.ru',AccountId = account.Id);
        insert contact;
        Event event = new Event(WhatId = opportunity.Id, DurationInMinutes = 1, ActivityDateTime = system.now().addDays(1));
        insert event;

        PageReference pageRef = Page.FieldSalesTerritory;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('eventId', event.Id);
        FieldSalesPresentationCtrl fsPresentation = new FieldSalesPresentationCtrl();
        fsPresentation.init();

        system.assertNotEquals(fsPresentation.inn, null);
        system.assertNotEquals(fsPresentation.phone, null);
    }

    @IsTest
    static void testSaveComment(){
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 1000000, Industry = 'Г',
                Phone = '+71234567891', BillingStreet = 'САНКТ-ПЕТЕРБУРГ', INN__C = '1234567899999', BillingCountry = 'Russia');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50),  AccountId = account.id);
        insert opportunity;
        Contact contact = new Contact(LastName = 'testcontact12345',Phone = '+71234567890',Email = 'test@testcont.ru',AccountId = account.Id);
        insert contact;
        Event event = new Event(WhatId = opportunity.Id, DurationInMinutes = 1, ActivityDateTime = system.now().addDays(1));
        insert event;
        Test.startTest();
        FieldSalesPresentationCtrl.saveComment('comment', String.valueOf(event.Id));
        Test.stopTest();

        List<Event> eventList = [SELECT Id, Description FROM Event];
        system.assertEquals(eventList.get(0).Description, 'comment');
    }

}