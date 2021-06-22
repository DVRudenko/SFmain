@isTest
public class WorkcomChoosePriseControllerTest {

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

	private static final Decimal defaultPoints = 10;

	private static void init() {
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
				Points__c = defaultPoints,
				Earned_Points__c = defaultPoints);
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

		List<RecordType> prizeRecordTypes = ([
				SELECT Id
				FROM RecordType
				WHERE Name = 'Russian'
				AND sObjectType = 'Prize__c'
		]);

		Prize__c prize1 = new Prize__c(
				Name = 'Test prize 1',
				Cost__c = 20,
				ImageUrl__c = DOCUMENT_ID,
				RecordTypeId = prizeRecordTypes.get(0).Id
		);
		insert prize1;

		Prize__c prize2 = new Prize__c(
				Name = 'Test prize 2',
				Cost__c = 10,
				Count__c = 100,
				ImageUrl__c = DOCUMENT_ID,
				RecordTypeId = prizeRecordTypes.get(0).Id
		);
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
				Points__c = 0,
				RecordTypeId = recordTypesDe.get(0).Id);
		insert comboBadgeDe;
	}

	@isTest
	public static void addTestFeiled() {
		init();

		Test.StartTest();
			PageReference pageRef = Page.WorkcomChoosePrisePage;
			pageRef.getParameters().put('sfdc.userId', ([SELECT Id FROM User WHERE Username = 'newusertest@fleetcor.de'].Id));
			Test.setCurrentPage(pageRef);
			WorkcomChoosePriseController workcomChoosePriseController = new WorkcomChoosePriseController();
			pageRef.getParameters().put('prizeId', [SELECT Id FROM Prize__c WHERE Name = 'Test prize 1' LIMIT 1].Id );
			workcomChoosePriseController.add();
		Test.StopTest();

		List<ApexPages.Message> msgList = ApexPages.getMessages();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
			System.assertEquals(Label.RU_0017_NotEnaPoints, msg.getSummary());
			System.assertEquals(ApexPages.Severity.WARNING, msg.getSeverity());
		}
	}

	@isTest
	public static void addTestSuccess() {
		init();

		Test.StartTest();
		PageReference pageRef = Page.WorkcomChoosePrisePage;
		pageRef.getParameters().put('sfdc.userId', ([SELECT Id FROM User WHERE Username = 'newusertest@fleetcor.de'].Id));
		Test.setCurrentPage(pageRef);
		WorkcomChoosePriseController workcomChoosePriseController = new WorkcomChoosePriseController();
		pageRef.getParameters().put('prizeId', [SELECT Id FROM Prize__c WHERE Name = 'Test prize 2' LIMIT 1].Id );
		workcomChoosePriseController.add();
		Test.StopTest();

		List<ApexPages.Message> msgList = ApexPages.getMessages();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
			System.assertEquals(Label.RU_0018_PrizeIsAddSucc, msg.getSummary());
			System.assertEquals(ApexPages.Severity.CONFIRM, msg.getSeverity());
		}
	}

	@isTest
	public static void addTestComboBadgeRu() {
		init();

		User currentUser = ([
				SELECT Name, Points__c
				FROM User
				WHERE Username = :'newusertest@fleetcor.de'
		]);

		Map<Id, WorkBadgeDefinition>  workBadgeDefinitionMap = new Map<Id, WorkBadgeDefinition>([
				SELECT Name, Points__c
				FROM WorkBadgeDefinition
		]);

		String descriptopn = 'Test message';
		Date dateNow = System.today();
		String dateFormat = DateTime.newInstance(dateNow.year(), dateNow.month(), dateNow.day()).format('MM/dd/yyyy');
		String message = 'Date=\'' + dateFormat + '\' ' + descriptopn;

		Map<Integer, WorkThanks> workThanksMap = new Map<Integer, WorkThanks>();
		Map<Integer, WorkBadge> workBadgeMap = new Map<Integer, WorkBadge>();
		Map<Integer, FeedItem> feedItemMap = new Map<Integer, FeedItem>();

		Integer bunbleNum = 1;
		for(Id badgeId : workBadgeDefinitionMap.keySet()) {
			WorkBadgeDefinition badge = workBadgeDefinitionMap.get(badgeId);

			if(comboBunchRu.containsKey(badge.Name) &&
					comboBunchRu.get(badge.Name) == badge.Points__c) {

				workThanksMap.put(bunbleNum, new WorkThanks(
						Message = message,
						GiverId = currentUser.Id));

				workBadgeMap.put(bunbleNum, new WorkBadge(
						DefinitionId = badge.Id,
						RecipientId = currentUser.Id));

				feedItemMap.put(bunbleNum, new FeedItem(Body = message, Title = 'Test',
						ParentId = currentUser.Id,
						CreatedById = currentUser.Id,
						Type = 'RypplePost'));
			}
			bunbleNum++;
		}

		WorkBadgeReceivedHandler.insertWorkcomPackage(feedItemMap, workThanksMap, workBadgeMap);

		Ru_Workcom_Combo_Badge_Settings__c comboBadgeName = ([
				SELECT Id, badgeName__c
				FROM Ru_Workcom_Combo_Badge_Settings__c
				WHERE location__c = 'ru_RU'
		]);

		Id comboBadgeId = ([
				SELECT Id
				FROM WorkBadgeDefinition
				WHERE Name = :comboBadgeName.badgeName__c
		]).Id;

		WorkBadge badge = ([SELECT Id, Message FROM WorkBadge WHERE RecipientId =: currentUser.Id AND DefinitionId =: comboBadgeId ]);
		System.assert(badge != null);
	}

	@isTest
	public static void addTestComboBadgeDe() {
		init();

		User currentUser = ([
				SELECT Name, Points__c
				FROM User
				WHERE Username = :'newusertest@fleetcor.de'
		]);

		Map<Id, WorkBadgeDefinition>  workBadgeDefinitionMap = new Map<Id, WorkBadgeDefinition>([
				SELECT Name, Points__c
				FROM WorkBadgeDefinition
		]);

		String descriptopn = 'Test message';
		Date dateNow = System.today();
		String dateFormat = DateTime.newInstance(dateNow.year(), dateNow.month(), dateNow.day()).format('MM/dd/yyyy');
		String message = 'Date=\'' + dateFormat + '\' ' + descriptopn;

		Map<Integer, WorkThanks> workThanksMap = new Map<Integer, WorkThanks>();
		Map<Integer, WorkBadge> workBadgeMap = new Map<Integer, WorkBadge>();
		Map<Integer, FeedItem> feedItemMap = new Map<Integer, FeedItem>();

		Integer bunbleNum = 1;
		Decimal sumPoints = 0;
		for(Id badgeId : workBadgeDefinitionMap.keySet()) {
			WorkBadgeDefinition badge = workBadgeDefinitionMap.get(badgeId);

			if(comboBunchDe.containsKey(badge.Name) &&
					comboBunchDe.get(badge.Name) == badge.Points__c) {

				workThanksMap.put(bunbleNum, new WorkThanks(
						Message = message,
						GiverId = currentUser.Id));

				workBadgeMap.put(bunbleNum, new WorkBadge(
						DefinitionId = badge.Id,
						RecipientId = currentUser.Id));

				feedItemMap.put(bunbleNum, new FeedItem(Body = message, Title = 'Test',
						ParentId = currentUser.Id,
						CreatedById = currentUser.Id,
						Type = 'RypplePost'));

				sumPoints += badge.Points__c;
			}
			bunbleNum++;
		}

		WorkBadgeReceivedHandler.insertWorkcomPackage(feedItemMap, workThanksMap, workBadgeMap);

		Ru_Workcom_Combo_Badge_Settings__c comboBadgeName = ([
				SELECT Id, badgeName__c
				FROM Ru_Workcom_Combo_Badge_Settings__c
				WHERE location__c = 'de_DE'
		]);

		Id comboBadgeId = ([
				SELECT Id
				FROM WorkBadgeDefinition
				WHERE Name = :comboBadgeName.badgeName__c
		]).Id;

		WorkBadge badge = ([
				SELECT Id, Message
				FROM WorkBadge
				WHERE RecipientId = :currentUser.Id
				AND DefinitionId = :comboBadgeId
		]);

		User resultUser = ([
				SELECT Name, Points__c, Earned_Points__c
				FROM User
				WHERE Username = :'newusertest@fleetcor.de'
		]);

		System.assert(badge != null);
		System.assert(resultUser.Earned_Points__c == ((2 * sumPoints) + defaultPoints));
		System.assert(resultUser.Points__c == ((2 * sumPoints) + defaultPoints));
	}

}