@IsTest
private class FieldSalesTerritoryCtrlTest {

    @TestSetup
    static void testSetupMethod(){
        FieldSalesTerritory_General_Settings__c fieldSalesTerritorySettings = new FieldSalesTerritory_General_Settings__c();
        fieldSalesTerritorySettings.Name = 'RU';
        fieldSalesTerritorySettings.Penalty_for_refusal__c = 365;
        insert fieldSalesTerritorySettings;
    }

    @isTest
    private static  void testMethod1(){
        List<FS_Tree_Area__mdt> testingArea = [
                SELECT Id, Label, FS_Tree_Province__r.Label, FS_Territory__c
                FROM FS_Tree_Area__mdt
                WHERE FS_Territory__r.Assigned_Users_Ids__c != null
                ORDER BY LABEL ASC
                LIMIT 1
        ];
        system.assertEquals(testingArea.size(), 1);

        List<FS_Tree_Province__mdt> testingRegion = [
                SELECT Id, Label
                FROM FS_Tree_Province__mdt
                WHERE Id = :testingArea.get(0).FS_Tree_Province__c
        ];
        system.assertEquals(testingRegion.size(), 1);

        List<FS_Territory__mdt> testingTerritory = [
                SELECT Id, Label, Assigned_Users_Ids__c
                FROM FS_Territory__mdt
                WHERE id = :testingArea.get(0).FS_Territory__c
        ];
        system.assertEquals(testingTerritory.size(), 1);
        List<User> territoryUsers = [SELECT Id FROM User WHERE IsActive = true and Id in :String.valueOf(testingTerritory.get(0).Assigned_Users_Ids__c).split(';')];

        List<User> userList = [
                SELECT id
                FROM User
                WHERE Profile.Name = 'Russian Sales Manager'
                AND IsActive = true
                AND UserRole.Name NOT IN ('PPR Key Accounts Manager', 'PPR Teamleader KAM', 'PPR FieldTerritory_Call Center')
                LIMIT 1];
        String recordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity' LIMIT 1].id;
        String recordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account' LIMIT 1].id;
        AccountTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 50, Phone = '+71234567890',
                Region__c = testingRegion.get(0).Label, BillingArea__c = testingArea.get(0).Label,
                INN__C = '1234567899999', OwnerId= userList.get(0).Id, RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId= userList.get(0).Id,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        FieldSalesTerritoryCtrl fsController = new FieldSalesTerritoryCtrl();
        PageReference pageRef = Page.FieldSalesTerritory;
        Test.setCurrentPage(pageRef);
        fsController.init(testingTerritory.get(0).Id, territoryUsers.get(0).Id);
        String hash = fsController.getHashAlgorithmAES256(opportunity.Id);
        ApexPages.currentPage().getParameters().put('recordHashId', hash);
        fsController.getRecordOwnership();
        fsController.getRecordLink();
        fsController.lastPage();
        fsController.nextPage();
        fsController.previousPage();

        ApexPages.currentPage().getParameters().put('sortColumn','Industry');
        fsController.sortListByColumn();
        fsController.refreshPageInformation();
        fsController.changeTerritory();
        fsController.changeScoringSection();
    }

    @isTest
    private static  void testMethod2(){
        List<FS_Tree_Area__mdt> testingArea = [
                SELECT Id, Label, FS_Tree_Province__r.Label, FS_Territory__c
                FROM FS_Tree_Area__mdt
                WHERE FS_Territory__r.Assigned_Users_Ids__c != null
                ORDER BY LABEL ASC
                LIMIT 1
        ];
        system.assertEquals(testingArea.size(), 1);

        List<FS_Tree_Province__mdt> testingRegion = [
                SELECT Id, Label
                FROM FS_Tree_Province__mdt
                WHERE Id = :testingArea.get(0).FS_Tree_Province__c
        ];
        system.assertEquals(testingRegion.size(), 1);

        List<FS_Territory__mdt> testingTerritory = [
                SELECT Id, Label, Assigned_Users_Ids__c
                FROM FS_Territory__mdt
                WHERE id = :testingArea.get(0).FS_Territory__c
        ];
        system.assertEquals(testingTerritory.size(), 1);
        List<User> territoryUsers = [SELECT Id FROM User WHERE IsActive = true and Id in :String.valueOf(testingTerritory.get(0).Assigned_Users_Ids__c).split(';')];

        String recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Lead' LIMIT 1].id;
        String queueId = [SELECT id, name FROM Group WHERE Name LIKE '%PPR Queue Stock%' OR Name LIKE '%PPR Queue Call Center%' LIMIT 1].id;
        Lead lead = new Lead(LastName = 'test', Company = 'test', Country = 'Russia', Email = 'test@test.com', OwnerId = queueId,
                Region__c = testingRegion.get(0).Label, Area__c = testingArea.get(0).Label, RecordTypeId = recordTypeLead,
                Phone = '+71231231231', Status = 'Open', Rating_FS__c = 10000);
        insert lead;

        FieldSalesTerritoryCtrl fsController = new FieldSalesTerritoryCtrl();
        PageReference pageRef = Page.FieldSalesTerritory;
        Test.setCurrentPage(pageRef);

        fsController.init(testingTerritory.get(0).Id, territoryUsers.get(0).Id);

        String hash = fsController.getHashAlgorithmAES256(lead.Id);
        ApexPages.currentPage().getParameters().put('recordHashId', hash);
        fsController.getRecordOwnership();
        fsController.getRecordLink();
        fsController.lastPage();
        fsController.nextPage();
        fsController.previousPage();

        ApexPages.currentPage().getParameters().put('sortColumn','Industry');
        fsController.sortListByColumn();
        fsController.refreshPageInformation();
        fsController.changeTerritory();
        fsController.changeScoringSection();
    }

    @isTest
    private static  void testMethod3(){
        FieldSalesTerritoryCtrl fsController = new FieldSalesTerritoryCtrl();
        PageReference pageRef = Page.FieldSalesTerritory;
        Test.setCurrentPage(pageRef);
        fsController.init();
        system.debug(fsController.totalPages);
    }


}