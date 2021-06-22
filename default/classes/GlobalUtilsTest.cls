@IsTest
public with sharing class GlobalUtilsTest {

    @IsTest
    private static void testGetFleetcorCountriesToCodesMap() {
        GlobalUtils.getFleetcorCountriesToCodesMap ();
    }
    @IsTest
    private static void testGetProvincesMap() {
        Map <String, FS_Tree_Province__mdt> provincesMap = GlobalUtils.getProvincesMap ();
        system.assert(!provincesMap.isEmpty());
    }
    @IsTest
    private static void testGetSupportCaseStatus() {
        GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed);
    }

    @IsTest
    private static void testIsPhraseFoundInText() {
        GlobalUtils.isPhraseFoundInText('text phrase.text', 'phrase', '');
    }

    @IsTest
    private static void testGetInboundRoles() {
        GlobalUtils.getInboundRoles('PPR FieldTerritory_Call Center');
    }

    @IsTest
    private static void testGetContractType() {
        GlobalUtils.getContractType('MultiOffer');
    }

    @IsTest
    private static void testGetOpportunityStageName() {
        GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AwaitingPayment);
    }

    @IsTest
    private static void testGenerateGUIDFromId() {
        GlobalUtils.generateGUIDFromId('5004E00000B7J8RQAV');
    }

    @IsTest
    private static void testGetValueUntypedFromJSON() {
        GlobalUtils.getValueUntypedFromJSON(
                new Map<String, Object>{
                        'key' => 'value'
                },
                'key'
        );
    }
    @IsTest
    private static void escapeValuesList_singleQuotes() {
        List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes(new List <String>{
                'test\'test'
        });
        system.assertEquals('test\\\'test', escapedList[0]);
    }
    @IsTest
    private static void testGenerateGUID() {
        GlobalUtils.generateGUID();
    }

    @IsTest
    private static void testParseNormNameForOrganization() {
        GlobalUtils.parseNormNameForOrganization('test, test');
    }

    @IsTest
    private static void testGetStringOfMonth() {
        GlobalUtils.getStringOfMonth(1);
        GlobalUtils.getStringOfMonth(2);
        GlobalUtils.getStringOfMonth(3);
        GlobalUtils.getStringOfMonth(4);
        GlobalUtils.getStringOfMonth(5);
        GlobalUtils.getStringOfMonth(6);
        GlobalUtils.getStringOfMonth(7);
        GlobalUtils.getStringOfMonth(8);
        GlobalUtils.getStringOfMonth(9);
        GlobalUtils.getStringOfMonth(10);
        GlobalUtils.getStringOfMonth(11);
        GlobalUtils.getStringOfMonth(12);
    }

    @IsTest
    private static void testConvertNumberToWord() {
        GlobalUtils.convertNumberToWord(100);
    }

    @IsTest
    private static void testIsWeekendDay() {
        GlobalUtils.IsWeekendDay(Date.newInstance(2019, 07, 24));
    }

    @IsTest
    private static void testAddBusinessDays() {
        GlobalUtils.addBusinessDays(Date.today(), 5);
    }
    @IsTest
    private static void testGetE2ERuStep() {
        GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name());
    }

    @IsTest
    private static void testGetE2ESteps() {
        GlobalUtils.getE2ESteps('ContactDetails');
    }

    @IsTest
    private static void testGetE2ETariff() {
        GlobalUtils.getE2ETariff('Договор');
    }

    @IsTest
    private static void testGetE2EProduct() {
        GlobalUtils.getE2EProduct('Shell');
    }

    @IsTest
    private static void testGetE2EProductReverse() {
        GlobalUtils.getE2EProductReverse('ГАЗПРОМ');
    }

    @IsTest
    private static void testFindFeedItemByWorkThanks() {
        Id id = '5004E00000B7J8RQAV';
        FeedItem feedItem = new FeedItem(RelatedRecordId = id);
        GlobalUtils.findFeedItemByWorkThanks(id, new List<FeedItem>{
                feedItem
        });
    }

    @IsTest
    private static void testGetQueueUserIdsAndRoleIds() {
        GlobalUtils.getQueueUserIdsAndRoleIds(new Set<String>{
                'Austria_German_Support'
        });
    }

    @IsTest
    private static void testGetSubordinateRoles() {
        GlobalUtils.getSubordinateRoles('5004E00000B7J8RQAV');
    }

    @IsTest
    private static void testGetAllSubRoleIds() {
        GlobalUtils.getAllSubRoleIds(new Set<Id>());
    }

    @IsTest
    private static void testGetPicklistValuesTranslationsList() {
        GlobalUtils.getPicklistValuesTranslationsList(Schema.SObjectType.Opportunity.fields.StageName);
    }
    @IsTest
    private static void testGetFieldsLabels() {
        GlobalUtils.getFieldsLabels ('Opportunity', new List <String>{
                'Name', 'StageName'
        });
    }
    @IsTest
    private static void testGetFieldValue() {
        Opportunity opp = new Opportunity (Name = 'TestName');
        String fieldVal = GlobalUtils.getFieldValue (opp, 'Name');
        system.assertEquals('TestName', fieldVal);
    }
    @IsTest
    private static void testGetFieldsSchemaMap() {
        GlobalUtils.getFieldsSchemaMap('Opportunity');
    }
    @IsTest
    private static void testBlankDecimalIfNull() {
        GlobalUtils.blankDecimalIfNull(null);
    }
    @IsTest
    private static void testBlankBooleanIfNull() {
        GlobalUtils.blankBooleanIfNull(null);
    }

    @IsTest
    private static void testBlankIntegerIfNull() {
        GlobalUtils.blankIntegerIfNull(10);
        GlobalUtils.blankIntegerIfNull('10');
    }

    @IsTest
    private static void testBlankStringIfNull() {
        GlobalUtils.blankStringIfNull(null);
    }

    @IsTest
    private static void testGetPicklistValues() {
        GlobalUtils.getPicklistValues (Schema.Opportunity.SObjectType, 'StageName');
    }

    @IsTest
    private static void testGetFieldSetMembers() {
        GlobalUtils.getFieldSetMembers(Schema.Lead.sObjectType, 'All_Phone_Fields');
    }

    @IsTest
    private static void testGetFieldSetMembersAPIs() {
        GlobalUtils.getFieldSetMembersAPIs(Schema.Lead.SObjectType, 'All_Phone_Fields');
    }

    @IsTest
    private static void testGetEmarsysReactionType() {
        GlobalUtils.getEmarsysReactionType('DefaultReaction');
    }

    @IsTest
    private static void testGetEmarsysAccount() {
        GlobalUtils.getEmarsysAccount('AccountEuro');
    }
    @IsTest
    private static void testGetRecordTypeId() {
        GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    }

    @IsTest
    private static void testReturnRecordTypeId() {
        GlobalUtils.returnRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    }


    /*******************************************************************************
    *  Summary         : Test return record type name
    *  CreatedDate     : 16/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    private static void testReturnRecordTypeName() {
        RecordType reportRecordType = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Credit_Factory_Report__c' AND Name = 'Default'
                LIMIT 1
        ];

        String recordTypeName = GlobalUtils.returnRecordTypeName('Credit_Factory_Report__c', reportRecordType.Id);

        System.assertEquals('Default', recordTypeName);
    }


    @IsTest
    private static void testGetFleetcorCountries() {
        GlobalUtils.getFleetcorCountries('Germany');
    }

    @IsTest
    private static void testChangeIfHasNewValue() {
        String newValue = GlobalUtils.BusinessProcessType.Standard.name();
        String oldValue = null;
        oldValue = GlobalUtils.changeIfHasNewValue(oldValue, newValue);
        System.assertEquals(newValue, oldValue);

        newValue = ' ';
        oldValue = GlobalUtils.changeIfHasNewValue(oldValue, newValue);
        System.assertEquals(oldValue, oldValue);
    }

    @IsTest
    private static void testCheckINN() {
        // INN is empty
        String INN = null;
        System.assertEquals(false, GlobalUtils.checkINN(INN));

        // INN length is not correct
        INN = '12345';
        System.assertEquals(false, GlobalUtils.checkINN(INN));

        // INN contains not digits
        INN = '1234567890aa';
        System.assertEquals(false, GlobalUtils.checkINN(INN));

        // INN length is 10
        INN = '1234567890';
        System.assertEquals(true, GlobalUtils.checkINN(INN));

        // INN length is 12
        INN = '123456789012';
        System.assertEquals(true, GlobalUtils.checkINN(INN));
    }

    @IsTest
    private static void testIsSoleProprietor() {
        // INN is empty
        String INN = null;
        System.assertEquals(null, GlobalUtils.isSoleProprietor(INN));

        // neither sole proprietor, nor company
        INN = '12345';
        System.assertEquals(null, GlobalUtils.isSoleProprietor(INN));

        // sole proprietor
        INN = '123456789012';
        System.assertEquals(true, GlobalUtils.isSoleProprietor(INN));

        // company
        INN = '1234567890';
        System.assertEquals(false, GlobalUtils.isSoleProprietor(INN));
    }

    @IsTest
    private static void testProcessDeleteResult() {
        Database.DeleteResult deleteResult = (Database.DeleteResult) JSON.deserialize(
                '{"success":false, "id":"01I5E000000N3ZT", "errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}'
                , Database.DeleteResult.class
        );
        List<String> failedRecords = new List<String>();
        System.assert(failedRecords.isEmpty());
        GlobalUtils.processDeleteResult(deleteResult, failedRecords);

        System.assert(failedRecords.size() == 1);

    }

    @IsTest
    private static void testProcessSaveResult() {
        Database.SaveResult saveResult = (Database.SaveResult) JSON.deserialize(
                '{"success":false, "id":"01I5E000000N3ZT", "errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}'
                , Database.SaveResult.class
        );

        List<String> failedRecords = new List<String>();
        System.assert(failedRecords.isEmpty());
        GlobalUtils.processSaveResult(saveResult, failedRecords);

        System.assert(failedRecords.size() == 1);
    }

    @IsTest
    private static void testCreateOrganiozationName() {
        String orgNameFromSpark = 'Test, OOO';
        String formatedName = GlobalUtils.createOrganiozationName(orgNameFromSpark);

        System.assertEquals('OOO "Test"', formatedName);

        formatedName = GlobalUtils.createOrganiozationName(null);

        System.assertEquals(' ""', formatedName);

        formatedName = GlobalUtils.createOrganiozationName('');

        System.assertEquals(' ""', formatedName);
    }

    @IsTest
    private static void testGetPromocodesString() {
        List<String> promocodes = null;
        System.assert(String.isEmpty(GlobalUtils.getPromocodesString(promocodes)));

        promocodes = new List<String>();
        System.assert(String.isEmpty(GlobalUtils.getPromocodesString(promocodes)));

        promocodes.add('first');
        promocodes.add(null);
        promocodes.add('');
        promocodes.add('   ');
        promocodes.add('second');
        System.assertEquals('first;second', GlobalUtils.getPromocodesString(promocodes));
    }

    @IsTest
    private static void testConstructPhoneNumber() {
        String code = null;
        String value = null;
        String ext = null;

        String phoneNumber = GlobalUtils.constructPhoneNumber(code, value, ext);
        System.assertEquals('', phoneNumber);

        code = '';
        value = '';
        ext = '';

        phoneNumber = GlobalUtils.constructPhoneNumber(code, value, ext);
        System.assertEquals('', phoneNumber);

        code = '7';
        value = '8005583134';
        ext = '';

        phoneNumber = GlobalUtils.constructPhoneNumber(code, value, ext);
        System.assertEquals('+78005583134', phoneNumber);

        code = '7';
        value = '8005583134';
        ext = '222';

        phoneNumber = GlobalUtils.constructPhoneNumber(code, value, ext);
        System.assertEquals('+78005583134#222', phoneNumber);

        code = '8';
        value = '8005583134';
        ext = '222';

        phoneNumber = GlobalUtils.constructPhoneNumber(code, value, ext);
        System.assertEquals('88005583134#222', phoneNumber);
    }

    @IsTest
    private static void parseBooleanTest() {
        System.assertEquals(1, GlobalUtils.parseBoolean(true));
        System.assertEquals(0, GlobalUtils.parseBoolean(false));
        System.assertEquals(null, GlobalUtils.parseBoolean(null));
    }

    @IsTest
    private static void testCheckApprovalApproved_WrongValues() {
        Account acc = CFTestDataFactory.createAccount();
        insert acc;

        System.assertEquals(false, GlobalUtils.checkApprovalApproved(null, null));
        System.assertEquals(false, GlobalUtils.checkApprovalApproved(null, 'test'));
        System.assertEquals(false, GlobalUtils.checkApprovalApproved(acc.Id, null));
    }

    @IsTest
    private static void testCheckApprovalApproved_VariationOfApprove() {
        OpportunityTriggerHandler.enablesTrigger = false;
        Account acc = CFTestDataFactory.createAccount();
        insert acc;
        Opportunity opp = CFTestDataFactory.createOpportunity(acc);
        insert opp;

        // select any process for testing
        List<ProcessDefinition> opportunityAprrovals = [SELECT DeveloperName FROM ProcessDefinition WHERE TableEnumOrId = 'Opportunity'];
        Boolean resultNotEmpty = !opportunityAprrovals.isEmpty() && opportunityAprrovals.get(0).DeveloperName != null;
        String processName = (resultNotEmpty) ? opportunityAprrovals.get(0).DeveloperName : 'ProcessName';

        System.assertEquals(false, GlobalUtils.checkApprovalApproved(opp.Id, processName));

        try {
            // prepare request
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setObjectId(opp.Id);
            approvalRequest.setProcessDefinitionNameOrId(processName);
            approvalRequest.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(approvalRequest);

            // Prepare for approve
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            Approval.ProcessWorkitemRequest approvalRequestSubmit = new Approval.ProcessWorkitemRequest();
            approvalRequestSubmit.setComments('Approving request');
            approvalRequestSubmit.setAction('Approve');
            approvalRequestSubmit.setNextApproverIds(new Id[]{
                    UserInfo.getUserId()
            });
            approvalRequestSubmit.setWorkitemId(newWorkItemIds.get(0));
            Approval.process(approvalRequestSubmit);

            System.assertEquals(true, GlobalUtils.checkApprovalApproved(opp.Id, processName));
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Smth wrong with approval, we testing only result of approve.' + ' Exception: ' + e.getMessage());
        }
    }
    @IsTest
    private static void testSendEmail_CSV() {
        Test.startTest();
        List <String> emailRecievers = new List <String>{
                'test@example.com'
        };
        String emailSubject = 'Email subject';
        String emailBody = 'Email body';
        String fileName = 'test.csv';
        List <String> csvRowHeaders = new List <String>{
                'header1', 'header2', 'header3'
        };
        List <String> csvRows = new List <String>{
                'val1-1,val1-2,val1-3', 'val2-1,val2-2,val2-3'
        };
        GlobalUtils.sendEmail_CSV (emailRecievers, emailSubject, emailBody, fileName, csvRowHeaders, csvRows);
        Test.stopTest();
    }

    @IsTest
    private static void getPicklistLabelTest() {
        System.assertEquals(
                null,
                GlobalUtils.getPicklistLabel(
                        null,
                        Credit_Factory_Report__c.RU_scoring_decision__c
                )
        );
        System.assertEquals(
                null,
                GlobalUtils.getPicklistLabel(
                        CFUtils.ScoringDecision.Prepay.name(),
                        null
                )
        );
        System.assertEquals(
                CFUtils.ScoringDecision.Prepay.name(),
                GlobalUtils.getPicklistLabel(
                        CFUtils.ScoringDecision.Prepay.name(),
                        Credit_Factory_Report__c.RU_scoring_decision__c
                )
        );
    }

    @IsTest
    private static void getPickListValuesAndLabelsFromObjectTest() {
        Map<String, String> pickListData = GlobalUtils.getPickListValuesAndLabelsFromObjectField(Credit_Factory_Report__c.RU_scoring_decision__c);
        Map<String, String> emptyPickListData = GlobalUtils.getPickListValuesAndLabelsFromObjectField(null);
        System.assertNotEquals(0, pickListData.size());
        System.assertEquals(null, emptyPickListData);
    }
}
