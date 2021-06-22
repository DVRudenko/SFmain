@isTest
public class EventTriggerHandlerTest {


	/*******************************************************************************
	    *  Name            : connectEventsWithContactsTest_Create()
	    *  Summary         : connect Event with Contact from Retailer Account test on INSERT
	    *  CreatedDate     : 27/07/2017
	    *  Parameters      : -
	    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void connectEventsWithContactsTest_Create() {
    	Account account = new Account(
    		Name = 'test',
    		Partnertyp__c = 'Retailer',
            BillingCountry = 'Germany',
    		Email_retailer__c = 'test@test.com');
    	insert account;

    	Contact contact = new Contact(
    		Salutation = 'Herr',
    		LastName = 'test',
    		Email = 'test@test.com',
    		AccountId = account.Id);
    	insert contact;

    	Event event = new Event(
                WhatId = account.Id,
                DurationInMinutes = 10,
                ActivityDateTime = Datetime.now(),
                Visit_Done__c = true);
    	insert event;

    	List<Event> eventsList = [
    			SELECT WhoId
    			FROM Event
    			WHERE Id = :event.Id];
    	System.assertEquals(contact.Id, eventsList.get(0).WhoId);
    }


    /*******************************************************************************
        *  Name            : connectEventsWithContactsTest_Update()
        *  Summary         : connect Event with Contact from Retailer Account test on UPDATE
        *  CreatedDate     : 27/07/2017
        *  Parameters      : -
        *  Returns         : void
    ******************************************************************************/
    @isTest
    static void connectEventsWithContactsTest_Update() {
        Account account = new Account(
            Name = 'test',
            Partnertyp__c = 'Retailer',
            BillingCountry = 'Germany',
            Email_retailer__c = 'test@test.com');
        insert account;

        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'test',
            Email = 'test@test.com',
            AccountId = account.Id);
        insert contact;

        Event event = new Event(
            WhatId = account.Id,
            DurationInMinutes = 10,
            ActivityDateTime = Datetime.now());
        insert event;

        List<Event> eventsList = [
                SELECT WhoId
                FROM Event
                WHERE Id = :event.Id];
        System.assertEquals(null, eventsList.get(0).WhoId);

        event.Visit_Done__c = true;
        update event;

        List<Event> eventsList2 = [
                SELECT WhoId
                FROM Event
                WHERE Id = :event.Id];
        System.assertEquals(contact.Id, eventsList2.get(0).WhoId);
    }

    @isTest
    private static void testAttachments() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Sales Manager'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Teamleader Telesales PSO 1'];
        Integer rand = Math.round(Math.random() * 100000);
        User u = new User(
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = rand + '@' + rand + 'test.com',
                Alias = 'so2',
                Email = 'sale.outb_' + rand + '@test.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(u);
        List<RecordType> russianRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE SobjectType = 'Event' and name ='Russian Sales Event'];
        System.runAs(u) {
            Event newEvent = new Event(
                    Subject = 'Call',
                    DurationInMinutes = 1,
                    ActivityDateTime = system.now().addMinutes(-10),
                    WhoId = null,
                    RecordTypeId = russianRecordType.get(0).Id,
                    WhatId = null);
            insert newEvent;

            Attachment newAttachment = new Attachment(name = 'Test1', ParentId = newEvent.id, Body = Blob.valueOf('Test2'));
            insert newAttachment;

            Event testEvent = [
                    SELECT Event.Attachments_Exist__c
                    FROM Event
                    WHERE Id = :newEvent.Id];
            System.assertEquals(testEvent.Attachments_Exist__c, True);

            newAttachment.name = 'TestUpdate';
            update newAttachment;

            Event testEvent2 = [
                    SELECT Event.Attachments_Exist__c
                    FROM Event
                    WHERE Id = :newEvent.Id];
            System.assertEquals(testEvent2.Attachments_Exist__c, True);

            delete newAttachment;
            Event testEvent3 = [
                    SELECT Event.Attachments_Exist__c
                    FROM Event
                    WHERE Id = :newEvent.Id];
            System.assertEquals(testEvent3.Attachments_Exist__c, False);
        }
    }

    @isTest
    private static void testStatusDateChange() {
        List<RecordType> russianRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE SobjectType = 'Event' and name ='Russian Sales Event'];
        Event newEvent = new Event(
                Subject = 'Call',
                ActivityDateTime = Datetime.now(),
                DurationInMinutes = 10,
                WhoId = null,
                RecordTypeId = russianRecordType.get(0).Id,
                WhatId = null);
        insert newEvent;

        newEvent.Event_Status__c = 'Completed';
        DateTime tempDate = DateTime.now();
        update newEvent;

        Event testEvent = [
                SELECT Last_Event_Status_Change__c
                FROM Event
                WHERE Id = :newEvent.Id
        ];

        system.assertNotEquals(null, testEvent.Last_Event_Status_Change__c);
    }

    @isTest
    private static void testSetNowOnEventDate() {
        DateTime now = Datetime.now();

        Event testEvent = new Event (
            Subject = 'Meeting',
            End_Now__c = true,
            DurationInMinutes = 300,
            ActivityDateTime = DateTime.newInstance(now.year(), now.month(), now.day(), 0, 0, 0),
            StartDateTime = DateTime.newInstance(now.year(), now.month(), now.day(), 0, 0, 0),
            EndDateTime = DateTime.newInstance(now.year(), now.month(), now.day(), 5, 0, 0)
        );
        insert testEvent;
        Event newEvent = [SELECT Id, StartDateTime, EndDateTime, Subject FROM Event WHERE Id =: testEvent.Id];

        system.assertEquals(now.hour(), newEvent.EndDateTime.hour());

        Event testEvent2 = new Event (
            Subject = 'Meeting',
            Start_Now__c = true,
            DurationInMinutes = 300,
            ActivityDateTime = DateTime.newInstance(now.year(), now.month(), now.day(), 0, 0, 0),
            StartDateTime = DateTime.newInstance(now.year(), now.month(), now.day(), 0, 0, 0),
            EndDateTime = DateTime.newInstance(now.year(), now.month(), now.day(), 5, 0, 0)
        );
        insert testEvent2;
        DateTime now2 = Datetime.now();
        Event newEvent2 = [SELECT Id, StartDateTime, EndDateTime, Subject FROM Event WHERE Id =: testEvent2.Id];

        system.assertEquals(now2.hour(), newEvent2.StartDateTime.hour());
    }
}