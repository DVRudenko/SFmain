@isTest
private class AttachmentTriggerHandlerTest {
    public Static User u;
    public Static User u2;
	private static final String SUPPORT_RECORD_TYPE = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
	private static final Group SUPPORT_QUEUE = ([
			SELECT Id, Email
			FROM Group
			WHERE DeveloperName LIKE '%_Support%'
			AND Type = 'Queue'
			LIMIT 1
	]);


    @isTest
    public static void testCreditFactoryReportDelete_bySales() {
		Test.startTest();
			createSalesUser();
		Test.stopTest();

		System.runAs(u) {
			try {
				Account acc = new Account(Name = 'test', BillingCountry = 'Germany');
				insert acc;

				Attachment attachment = new Attachment(
					Name = 'CrefoReport.pdf',
					ParentId = acc.Id,
					Body = Blob.valueOf('test'));
				insert attachment;

				delete attachment;
			} catch (Exception e) {
				System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
				System.Assert(e.getMessage().contains('Unable to delete CreditFactory report.'));
			}
		}
    }


    @isTest
    public static void testCreditFactoryReportDelete_byAdmin() {
		Test.startTest();
			createAdminUser();
		Test.stopTest();

		System.runAs(u2) {
			Account acc = new Account(Name = 'test', BillingCountry = 'Germany');
			insert acc;

			Attachment attachment = new Attachment(
				Name = 'CrefoReport.pdf',
				ParentId = acc.Id,
				Body = Blob.valueOf('test'));
			insert attachment;

			String attachmentId = attachment.Id;
			delete attachment;

			List<Attachment> attachmentListToTest = [
					SELECT Id
					FROM Attachment
					WHERE Id = :attachmentId];
			System.assert(attachmentListToTest.isEmpty());
		}
    }


	@future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Outbound 2'];
		Integer rand = Math.round(Math.random()*100000);
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = rand + '@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_'+rand+'@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);
	}


	@future
	private static void createAdminUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'API Only'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Role Up'];
		Integer rand = Math.round(Math.random()*100000);
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = rand + '@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_'+rand+'@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u2);
	}

	@isTest
	private static void testAttachments() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Russian Sales Manager'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Teamleader Telesales PSO 1'];
		Integer rand = Math.round(Math.random()*100000);
		User u = new User(
				UserRoleId = ur.Id,
				ProfileId = p.Id,
				Username = rand + '@' + rand + 'test.com',
				Alias = 'so2',
				Email='sale.outb_' + rand + '@test.com',
				EmailEncodingKey='UTF-8',
				Firstname='Bruce',
				Lastname='Wayne',
				LanguageLocaleKey='en_US',
				LocaleSidKey='en_US',
				TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);

		System.runAs(u) {
			Task newTask = new Task(
					Subject = 'Call',
					Priority = 'Normal',
					Status = 'Completed',
					WhoId = null,
					WhatId = null);
			insert newTask;

			Attachment newAttachment = new Attachment(name='Test1', ParentId = newTask.id,Body = Blob.valueOf('Test2'));
			insert newAttachment;

			Task testTask = [
					SELECT Task.Attachments_Exist__c
					FROM Task
					WHERE Id = :newTask.Id];
			System.assertEquals(testTask.Attachments_Exist__c, True);

			newAttachment.name = 'TestUpdate';
			update newAttachment;
			Task testTask1 = [
					SELECT Task.Attachments_Exist__c
					FROM Task
					WHERE Id = :newTask.Id];
			System.assertEquals(testTask1.Attachments_Exist__c, True);

			delete newAttachment;
			Task testTask2 = [
					SELECT Task.Attachments_Exist__c
					FROM Task
					WHERE Id = :newTask.Id];
			System.assertEquals(testTask2.Attachments_Exist__c, False);
		}
	}

	@isTest
	private static void testAttachmentsToEvent() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Russian Sales Manager'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Teamleader Telesales PSO 1'];
		Integer rand = Math.round(Math.random()*100000);
		User u = new User(
				UserRoleId = ur.Id,
				ProfileId = p.Id,
				Username = rand + '@' + rand + 'test.com',
				Alias = 'so2',
				Email='sale.outb_' + rand + '@test.com',
				EmailEncodingKey='UTF-8',
				Firstname='Bruce',
				Lastname='Wayne',
				LanguageLocaleKey='en_US',
				LocaleSidKey='en_US',
				TimeZoneSidKey='America/Chicago'
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

			Attachment newAttachment = new Attachment(name='Test1', ParentId = newEvent.id,Body = Blob.valueOf('Test2'));
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

//	@IsTest
//	private static void testProcessAttachmentToClosedCase() {
//		Case originalCase = createCase();
//		insert originalCase;
//		EmailMessage originalMessage = createEmailMessage(originalCase.Id);
//		insert originalMessage;
//		Attachment originalAttachment = createAttachment(originalMessage.Id);
//		insert originalAttachment;
//		Case newCase = getOriginalCaseWithNewChildCases(originalCase.Id).Cases.get(0);
//		System.assertNotEquals(null, newCase);
//		System.assertEquals(originalMessage.TextBody, newCase.Description);
//		EmailMessage newMessage = getNewMessageWithNewAttachments(newCase.Id, originalAttachment.ContentType,
//				originalAttachment.Name, originalMessage.FromName, originalMessage.ToAddress, originalMessage.FromAddress);
//		System.assertNotEquals(null, newMessage);
//		System.assertEquals(originalMessage.TextBody, newMessage.TextBody);
//		System.assertEquals(originalMessage.HtmlBody, newMessage.HtmlBody);
//		Attachment newAttachment = newMessage.Attachments.get(0);
//		System.assertNotEquals(null, newAttachment);
//	}
//
//	private static Case getOriginalCaseWithNewChildCases(Id parentCaseId) {
//		return ([
//				SELECT Id, Description, (
//						SELECT Id, Description, ParentId
//						FROM Cases
//						WHERE RecordTypeId = :SUPPORT_RECORD_TYPE
//						AND Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new)
//				)
//				FROM Case
//				WHERE Id = :parentCaseId
//				AND Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed)
//		]);
//	}
//
//	private static EmailMessage getNewMessageWithNewAttachments(Id newCaseId, String attContentType, String attName,
//			String fromName, String toAddress, String fromAddress) {
//		return ([
//				SELECT Id, TextBody, HtmlBody, (
//						SELECT Id
//						FROM Attachments
//						WHERE ContentType = :attContentType
//						AND Name = :attName
//				)
//				FROM EmailMessage
//				WHERE ParentId = :newCaseId
//				AND FromName = :fromName
//				AND ToAddress = :toAddress
//				AND FromAddress = :fromAddress
//		]);
//	}
//
//	private static Case createCase() {
//		return new Case(
//				RecordTypeId = SUPPORT_RECORD_TYPE,
//				OwnerId = UserInfo.getUserId(),
//				Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed),
//				Description = 'another'
//		);
//	}
//
//	private static EmailMessage createEmailMessage(Id caseId) {
//		return new EmailMessage(
//				ParentId = caseId,
//				FromName = 'dfgdfgd',
//				FromAddress = 'test@test.com',
//				ToAddress = SUPPORT_QUEUE.Email,
//				TextBody = 'hello',
//				HtmlBody = 'hello',
//				Incoming = true
//		);
//	}
//
//	private static Attachment createAttachment(Id parentId) {
//		return new Attachment(
//				ParentId = parentId,
//				ContentType = 'text/plain',
//				Name = 'test.txt',
//				Body = Blob.valueOf('hello')
//		);
//	}

}