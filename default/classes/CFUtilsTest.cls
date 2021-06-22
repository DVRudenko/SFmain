@IsTest
public with sharing class CFUtilsTest {

    private static final String VALID_STAGE = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead);
    private static final String INVALID_STAGE = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Refused);
    private static final String RUSSIA = GlobalUtils.FleetcorCountries.Russia.name();

    public static CF_Settings__c createCFSettingsForRussia(Boolean checkboxes) {
        CF_Settings__c cfRuSettings = new CF_Settings__c();
        cfRuSettings.Opportunity_stages__c = '/' + GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead) + '/';
        cfRuSettings.Black_list_check_when_scoring_expired__c = checkboxes;
        cfRuSettings.Check_on_opportunity_create__c = checkboxes;
        cfRuSettings.Check_on_opportunity_update__c = checkboxes;
        cfRuSettings.Name = RUSSIA;
        return cfRuSettings;
    }

    @IsTest
    private static void testIsValidOpportunityStage() {
        insert createCFSettingsForRussia(true);
        System.assertEquals(true, CFUtils.isValidOpportunityStage(VALID_STAGE, RUSSIA));
        System.assertEquals(false, CFUtils.isValidOpportunityStage(INVALID_STAGE, RUSSIA));
    }

    @IsTest
    private static void testGetCFRuSettingsForRussia() {
        insert createCFSettingsForRussia(true);
        CF_Settings__c settings = CFUtils.getCFSettingsFor(RUSSIA);
        System.assert(settings != null);
    }

    @IsTest
    private static void testGetScoringSettings() {
        Map<String, Object> settings = CFUtils.getScoringSettings();
        System.assertNotEquals(null, settings);

        settings = (Map<String, Object>) CFUtils.getScoringSettings('criteria');
        System.assertNotEquals(null, settings);

        settings = (Map<String, Object>) CFUtils.getScoringSettings('notification');
        System.assertNotEquals(null, settings);

        List<Object> settings1 = (List<Object>) CFUtils.getScoringSettings('opportunityStageTriggers');
        System.assertNotEquals(null, settings1);

        Boolean settings2 = (Boolean) CFUtils.getScoringSettings('active');
        System.assertNotEquals(null, settings2);
    }

    @IsTest
    private static void testReplaceNullValue() {
        String result = CFUtils.replcaeNullValue(null);
        System.assertEquals('-', result);

        result = CFUtils.replcaeNullValue('');
        System.assertEquals('', result);

        result = CFUtils.replcaeNullValue(10);
        System.assertEquals('10', result);

        result = CFUtils.replcaeNullValue(true);
        System.assertEquals('true', result);
    }

    @IsTest
    private static void testZeroIfNull() {
        CFUtils.FinancialReportFormValue value = new CFUtils.FinancialReportFormValue();
        value.startValue = 2;
        System.assertEquals(2, CFUtils.zeroIfNull(value));

        value = null;
        System.assertEquals(0, CFUtils.zeroIfNull(value));
    }

    @IsTest
    private static void parsePrescoringDateTest() {
        String dateString = '21.12.2020';
        System.assertEquals(Date.newInstance(2020, 12, 21), CFUtils.parsePrescoringDate(dateString));

        dateString = '  ';
        System.assertEquals(null, CFUtils.parsePrescoringDate(dateString));

        dateString = '';
        System.assertEquals(null, CFUtils.parsePrescoringDate(dateString));

        dateString = null;
        System.assertEquals(null, CFUtils.parsePrescoringDate(dateString));
    }

    @IsTest
    private static void parsePreScoringDecisionTest() {
        String parsedDecision = CFUtils.parsePreScoringDecision(CFTestDataFactory.createPrescoringResponseBody(true, true));
        System.assertEquals(CFUtils.ScoringDecision.Denied.name(), parsedDecision);

        parsedDecision = CFUtils.parsePreScoringDecision(CFTestDataFactory.createPrescoringResponseBody(false, false));
        System.assertEquals(CFUtils.ScoringDecision.Prepay.name(), parsedDecision);

        parsedDecision = CFUtils.parsePreScoringDecision(CFTestDataFactory.createPrescoringResponseBody(true, false));
        System.assertEquals(CFUtils.ScoringDecision.Credit_approved.name(), parsedDecision);

        parsedDecision = CFUtils.parsePreScoringDecision(CFTestDataFactory.createPrescoringResponseBody(null, false));
        System.assertEquals(CFUtils.ScoringDecision.No_data.name(), parsedDecision);

        parsedDecision = CFUtils.parsePreScoringDecision(CFTestDataFactory.createPrescoringResponseBody(true, null));
        System.assertEquals(CFUtils.ScoringDecision.No_data.name(), parsedDecision);

        parsedDecision = CFUtils.parsePreScoringDecision(CFTestDataFactory.createPrescoringResponseBody(null, null));
        System.assertEquals(CFUtils.ScoringDecision.No_data.name(), parsedDecision);

        parsedDecision = CFUtils.parsePreScoringDecision(null);
        System.assertEquals(CFUtils.ScoringDecision.No_data.name(), parsedDecision);
    }
}