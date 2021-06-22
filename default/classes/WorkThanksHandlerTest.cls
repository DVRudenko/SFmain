@isTest
public class WorkThanksHandlerTest {

	public static Map<String, Decimal> comboBunchRu = new Map<String, Decimal> {
			'Спринтер' => 50.0,
			'Передовик' => 70.0,
			'Ты просто космос!' => 100.0
	};

	public static Map<String, Decimal> comboBunchDE = new Map<String, Decimal> {
			'Badge_De_1' => 50.0,
			'Badge_De_2' => 70.0,
			'Badge_De_3' => 100.0,
			'Badge_De_4' => 100.0
	};

	@testSetup static void init() {
		Profile p = [SELECT Id FROM Profile WHERE Name = :Label.System_Administrator];
		User user = new User(
				Username = 'newusertest@fleetcor.de',
				ProfileId = p.Id,
				Alias = 'uset@fl',
				Email = 'usertest@fleetcor.de',
				EmailEncodingKey = 'UTF-8',
				Lastname = 'usertest',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimeZoneSidKey = 'America/Chicago',
				UserPermissionsWorkDotComUserFeature = true,
				Points__c = 10,
				Earned_Points__c = 10);
		insert user;

		// Badge Settings
		Ru_Workcom_Combo_Badge_Settings__c customSettingRU = new Ru_Workcom_Combo_Badge_Settings__c(
				Name = 'Test1',
				location__c = 'ru_RU',
				badgeName__c = 'Комбо'
		);
		insert customSettingRU;

		Ru_Workcom_Combo_Badge_Settings__c customSettingEN = new Ru_Workcom_Combo_Badge_Settings__c(
				Name = 'Test2',
				location__c = 'en_EN',
				badgeName__c = 'Комбо'
		);
		insert customSettingEN;

		Ru_Workcom_Combo_Badge_Settings__c customSettingDE = new Ru_Workcom_Combo_Badge_Settings__c(
				Name = 'Test3',
				location__c = 'de_DE',
				badgeName__c = 'Combo'
		);
		insert customSettingDE;

		initBadgeRu(customSettingRU.badgeName__c);

		initBadgeDe(customSettingDE.badgeName__c);

	}

	public static void initBadgeRu(String comboBadgeName) {
		// Bunch Settings for Russian Badge
		List<Ru_Workcom_Combo_Badge_Bunch__c> bunchList = new List<Ru_Workcom_Combo_Badge_Bunch__c>();
		for (String key : comboBunchRu.keySet()) {
			bunchList.add( new Ru_Workcom_Combo_Badge_Bunch__c(
					Name = key,
					points__c = comboBunchRu.get(key))
			);
		}
		insert bunchList;

		Document document1 = new Document(
				Name = 'DocumentForTest',
				FolderId = UserInfo.getUserId(),
				Body = Blob.valueOf('Test'),
				ContentType = 'image/png');
		insert document1;

		final String DOCUMENT_ID = document1.Id;

		List<RecordType> recordTypesRu = ([
				SELECT Id, Name
				FROM RecordType
				WHERE sObjectType = 'WorkBadgeDefinition'
				AND Name = 'Russian'
				LIMIT 1
		]);

		List<WorkBadgeDefinition> testWorkBadgeDefinition = new List<WorkBadgeDefinition>();
		for(String name : comboBunchRu.keySet()) {
			Decimal cost = comboBunchRu.get(name);
			testWorkBadgeDefinition.add( new WorkBadgeDefinition(
					Name = name,
					Description = 'Test Description',
					IsActive=True,
					ImageUrl = DOCUMENT_ID,
					Points__c = cost,
					RecordTypeId = recordTypesRu.get(0).Id)
			);
		}
		insert testWorkBadgeDefinition;

		WorkBadgeDefinition  comboBadgeRu = new WorkBadgeDefinition(
				Name = comboBadgeName,
				Description = 'Test Description',
				IsActive = True,
				ImageUrl = DOCUMENT_ID,
				Points__c = 100,
				RecordTypeId = recordTypesRu.get(0).Id);
		insert comboBadgeRu;

		Prize__c prize1 = new Prize__c(Name = 'Test prize 1', Cost__c = 20, ImageUrl__c = DOCUMENT_ID);
		insert prize1;

		Prize__c prize2 = new Prize__c(Name = 'Test prize 2', Cost__c = 10, ImageUrl__c = DOCUMENT_ID);
		insert prize2;
	}

	public static void initBadgeDe(String comboBadgeName) {
		Document document1 = new Document(
				Name = 'DocumentForTest',
				FolderId = UserInfo.getUserId(),
				Body = Blob.valueOf('Test'),
				ContentType = 'image/png');
		insert document1;

		final String DOCUMENT_ID = document1.Id;

		List<RecordType> recordTypesDe = ([
				SELECT Id, Name
				FROM RecordType
				WHERE sObjectType = 'WorkBadgeDefinition'
				AND Name = 'Germany'
				LIMIT 1
		]);

		List<WorkBadgeDefinition> testWorkBadgeDefinition = new List<WorkBadgeDefinition>();
		for(String name : comboBunchDe.keySet()) {
			Decimal cost = comboBunchDe.get(name);
			testWorkBadgeDefinition.add( new WorkBadgeDefinition(
					Name = name,
					Description = 'Test Description',
					IsActive = True,
					ImageUrl = DOCUMENT_ID,
					Points__c = cost,
					RecordTypeId = recordTypesDe.get(0).Id)
			);
		}
		insert testWorkBadgeDefinition;

		WorkBadgeDefinition  comboBadgeDe = new WorkBadgeDefinition(
				Name = comboBadgeName,
				Description = 'Test Description',
				IsActive = True,
				ImageUrl = DOCUMENT_ID,
				Points__c = 100,
				RecordTypeId = recordTypesDe.get(0).Id);
		insert comboBadgeDe;

		Prize__c prize1 = new Prize__c(Name = 'Test prize 1', Cost__c = 20, ImageUrl__c = DOCUMENT_ID);
		insert prize1;

		Prize__c prize2 = new Prize__c(Name = 'Test prize 2', Cost__c = 10, ImageUrl__c = DOCUMENT_ID);
		insert prize2;
	}

	@isTest
	public static void parserWorkThanksMessageTest() {

		String descriptopn = 'Test message';
		Date dateNow = System.today();
		String dateFormat = DateTime.newInstance(dateNow.year(), dateNow.month(), dateNow.day()).format('MM/dd/yyyy');
		String expectedDate = DateTime.newInstance(dateNow.year(), dateNow.month(), dateNow.day()).format('dd/MM/yyyy');
		if (UserInfo.getLanguage() == 'ru') {
			dateFormat = DateTime.newInstance(dateNow.year(), dateNow.month(), dateNow.day()).format('dd/MM/yyyy');
        }
        String message = 'Date=\'' + dateFormat.replace('/', '.') + '\' ' + descriptopn;

		User currentUser = ([SELECT Name, Points__c, Earned_Points__c  FROM User WHERE Username = :'newusertest@fleetcor.de']);
		WorkBadgeDefinition badge = ([SELECT Id FROM WorkBadgeDefinition WHERE Name = :'Спринтер' LIMIT 1]);

		WorkThanks wThanks =  new WorkThanks(
				Message = message,
				GiverId = currentUser.Id);
		insert wThanks;

		WorkBadge wBadge = new WorkBadge(
				DefinitionId = badge.Id,
				RecipientId = currentUser.Id,
				SourceId = wThanks.Id);
		insert wBadge;

		WorkBadge newWorkBadge  = ([SELECT DateOfAppointment__c FROM WorkBadge WHERE Id =: wBadge.Id]);
		System.assertEquals(expectedDate, DateTime.newInstance(newWorkBadge.DateOfAppointment__c.year(),
													newWorkBadge.DateOfAppointment__c.month(),
													newWorkBadge.DateOfAppointment__c.day()).format('dd/MM/yyyy')
		);
	}
}