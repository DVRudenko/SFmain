@isTest
private class OpportunityNotesAndAttachsTest {
    public static User salesInbound;
	public static User salesteamleiter;
	public static Opportunity newOpportunity;
	public static Attachment attach;
	public static Attachment attach2;
	public static Note note;
	public static Access_to_CF_Reports__c customSetting;

	@isTest
    public static void testNoteAndAttachCustomRelatedListSale() {
    	Test.startTest();
			createSalesUser();
		Test.stopTest();

		System.runAs(salesInbound) {
			createOpportunity();
			createAttachment();
			createNote();
			createCustomSettings();

			ApexPages.StandardController sc = new ApexPages.standardController(newOpportunity);
			OpportunityNotesAndAttachsExtensions extensions = new OpportunityNotesAndAttachsExtensions(sc);
			System.assertEquals(extensions.allNotesAndAttachmentsMap.size(), 2);
			//delting all notes and attachments
			List<Id> noteAndAttachmentsIdList = new List<Id>();
			noteAndAttachmentsIdList.addAll(extensions.allNotesAndAttachmentsMap.keySet());
			extensions.objectToDeleteId = noteAndAttachmentsIdList.get(0);
			extensions.doDelete();
			extensions.objectToDeleteId = noteAndAttachmentsIdList.get(1);
			extensions.doDelete();
		}
    }

    @isTest
    public static void testNoteAndAttachCustomRelatedListTeamLead() {
    	Test.startTest();
			createLeadUser();
		Test.stopTest();

		System.runAs(salesteamleiter) {
			createOpportunity();
			createAttachment();
			createNote();
			createCustomSettings();

			ApexPages.StandardController sc = new ApexPages.standardController(newOpportunity);
			OpportunityNotesAndAttachsExtensions extensions = new OpportunityNotesAndAttachsExtensions(sc);
			System.assertEquals(extensions.allNotesAndAttachmentsMap.size(), 3);
		}
    }

	@future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Inbound']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Inbound'];
		
		salesInbound = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'batman',
			Email ='bruce.wayne_1233@wayneenterprises.com',
			EmailEncodingKey ='UTF-8',
			Firstname='Bruce',
			Lastname ='Wayne',
			LanguageLocaleKey ='en_US',
			LocaleSidKey ='en_US',
			TimeZoneSidKey ='America/Chicago'
		);
		Database.insert(salesInbound);	   
	}

	@future
	private static void createLeadUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
		
		salesteamleiter = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_23423_test2@test.com',
		   	Alias = 'batman',
			Email ='bruce.wayne_1233@wayneenterprises.com',
			EmailEncodingKey ='UTF-8',
			Firstname ='Bruce',
			Lastname ='Wayne',
			LanguageLocaleKey ='en_US',
			LocaleSidKey ='en_US',
			TimeZoneSidKey ='America/Chicago'
		);
		Database.insert(salesteamleiter);
	}

    private static void createOpportunity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            RecordTypeId = rt.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Anzahl_der_Karten__c = 5,
            Sec_Channel__c = 'Inbound',
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Angebotsdauer__c = 'test',
            StageName = 'Prospecting',
            Name = 'test opp',
            Product__c = 'None',
            Disable_for_KPI__c = FALSE,
            CloseDate = Date.today()
        );
        insert newOpportunity;
    }

	private static void createAttachment() {
		List<Attachment> attachsToInsertList = new List<Attachment>();
		attach = new Attachment(
			Name = 'Unit Test Attachment',
			Body = Blob.valueOf('Unit Test Attachment Body'),
			ParentId = newOpportunity.Id
		); 
		attachsToInsertList.add(attach); 

		attach2 = new Attachment(
			Name = 'CrefoReport.pdf',
			Body = Blob.valueOf('Unit Test Credit Factory Attachment Body'),
			ParentId = newOpportunity.Id
		); 
		attachsToInsertList.add(attach2); 	

		insert attachsToInsertList;
	}

	private static void createNote() {
		note = new Note(
			Title = 'Unit Test Note',
			Body = 'Unit Test Note Body',
			ParentId = newOpportunity.Id
		);
		insert note;
	}

	private static void createCustomSettings() {
		customSetting = new Access_to_CF_Reports__c(
			Name = 'Salesteamleiter Inbound'
		);
		insert customSetting;
	}
}