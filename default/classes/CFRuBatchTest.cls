@IsTest
public without sharing class CFRuBatchTest {

    private static final Id RU_OPP_RECORD_TYPE = OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID;
    private static final Id RU_ACCOUNT_RECORD_TYPE = GlobalUtils.getRecordTypeId(Account.class.getName(), 'Russian');

    @IsTest
    static void testBehavior() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = new Account(
                Name = 'test',
                RecordTypeId = RU_ACCOUNT_RECORD_TYPE
        );
        insert account;
        Opportunity opp1 = new Opportunity(
                RecordTypeId = RU_OPP_RECORD_TYPE,
                Name = 'test 1',
                StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead),
                CloseDate = Date.today(),
                AccountId = account.Id,
                CF_checking__c = true
        );
        Opportunity opp2 = new Opportunity(
                RecordTypeId = RU_OPP_RECORD_TYPE,
                Name = 'test 2',
                StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead),
                CloseDate = Date.today(),
                AccountId = account.Id,
                CF_checking__c = true
        );
        Opportunity opp3 = new Opportunity(
                RecordTypeId = RU_OPP_RECORD_TYPE,
                Name = 'test 3',
                StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead),
                CloseDate = Date.today(),
                AccountId = account.Id,
                CF_checking__c = false
        );
        Opportunity opp4 = new Opportunity(
                AccountId = account.Id,
                Name = 'test 4',
                CF_checking__c = true,
                Type = 'New GFN',
                StageName = 'Qualify',
                CloseDate = Date.today(),
                Product_Solicited__c = 'CCS Limit',
                Sec_Channel__c = 'Inbound',
                RecordTypeId = Schema.getGlobalDescribe().get(Opportunity.class.getName())
                        .getDescribe().getRecordTypeInfosByDeveloperName()
                        .get(GlobalUtils.OpportunityRecordTypes.CCS_Opportunity.name()).recordTypeId
        );
        List<Opportunity> opportunities = new List<Opportunity>{
                opp1, opp2, opp3, opp4
        };
        insert opportunities;
        Test.startTest();
        Database.executeBatch(new CFRuBatch());
        Test.stopTest();

        opp1 = ([
                SELECT Id, CF_checking__c, Name
                FROM Opportunity
                WHERE Id = :opp1.Id
                LIMIT 1
        ]);
        System.assertEquals(false, opp1.CF_checking__c);
        System.assertEquals('TEST 1', opp1.Name);
        opp2 = ([
                SELECT Id, CF_checking__c
                FROM Opportunity
                WHERE Id = :opp2.Id
                LIMIT 1
        ]);
        System.assertEquals(false, opp2.CF_checking__c);
        opp3 = ([
                SELECT Id, CF_checking__c
                FROM Opportunity
                WHERE Id = :opp3.Id
                LIMIT 1
        ]);
        System.assertEquals(false, opp3.CF_checking__c);
        opp4 = ([
                SELECT Id, CF_checking__c
                FROM Opportunity
                WHERE Id = :opp4.Id
                LIMIT 1
        ]);
        System.assertEquals(true, opp4.CF_checking__c);
    }
}