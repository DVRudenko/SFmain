public without sharing class CFUtils {

    //possible reasons of organization block
    public enum CompanyBlockReason {
        SPARK,
        BlackList,
        Prescoring,
        Scoring
    }
    // Credit_Factory_Report__c.RU_scoring_decision__c picklist values
    public enum ScoringDecision {
        Credit_approved, Prepay, Denied, No_data
    }
    // Credit_Factory_Report__c.RU_scoring_type__c picklist values
    public enum ScoringType {
        empty, Prescoring, Scoring, FRAUD_check
    }
    public static final List<String> SOURCES = new List<String> {
            'Сайт Petrolplus.ru', 'E2E Form RU', 'Партнерская Программа', 'Business card',
            'Petrolcards.ru - АГГРЕГАТОР', 'АЗС Заявка Shell', 'Сайт gpc-store.ru', 'gpc-store.ru', 'petrolplus.ru'
    };
    public static final String NOTIFICATION = 'notification';
    public static final String OPPORTUNITY_LOST_REASON = 'Refusal from PPR';
    public static final String PRESCORING = ScoringType.Prescoring.name();
    public static final String PRESCORING_RU = System.Label.Prescoring_label;
    public static final String FRAUD_SCORING_TYPE = ScoringType.FRAUD_check.name();
    public static final String COMPANY_NON_ACTIVE = 'Non_active';
    public static final String COMPANY_DENIAL = 'Denial of cooperation';
    public static final FinancialReportFormValueCode VALUE_CODE = new FinancialReportFormValueCode();

    private static CF_Settings__c cfSettings = null;                            //custom settings for Credit factory
    public static final Map<String, RecordTypeInfo> CFR_RECORD_TYPES = Schema.getGlobalDescribe().get(Credit_Factory_Report__c.class.getName()).getDescribe().getRecordTypeInfosByDeveloperName();
    public static final Id RUSSIAN_CREDIT_RECORD_TYPE = CFR_RECORD_TYPES.get(GlobalUtils.CreditFactoryReportRecordTypes.Russian_credit_check.name()).getRecordTypeId();
    public static final Id RUSSIAN_FRAUD_RECORD_TYPE = CFR_RECORD_TYPES.get(GlobalUtils.CreditFactoryReportRecordTypes.Russian_FRAUD_check.name()).getRecordTypeId();
    private static Map<String, Object> resource = null;

    /*****************************************************************************
    *  Name            : getCFSettingsFor(String country)
    *  Summary         : creates if necessary and returns custom settings record for selected country
    *  CreatedDate     : 05/12/2019
    *  Parameters      : String country - record name
    *  Returns         : CF_Settings__c - custom settings record
    ******************************************************************************/
    public static CF_Settings__c getCFSettingsFor(String country) {
        if (cfSettings == null) cfSettings = CF_Settings__c.getValues(country);
        return cfSettings;
    }

    /*****************************************************************************
    *  Name            : isValidOpportunityStage(String stage, String country)
    *  Summary         : returns if selected Opportunity stage exists in custom settings for selected country or not
    *  CreatedDate     : 05/12/2019
    *  Parameters      : String country - record name,
    *                  : String stage - Opportunity Stage
    *  Returns         : Boolean - if stage exists in custom settings for selected country or not
    ******************************************************************************/
    public static Boolean isValidOpportunityStage(String stage, String country) {
        String stages = getCFSettingsFor(country).Opportunity_stages__c;
        return String.isEmpty(stages) ? false : stages.contains('/' + stage + '/');
    }

    /*****************************************************************************
    *  Name            : getScoringSettings()
    *  Summary         : returns settings for scoring
    *  CreatedDate     : 30.07.2020
    *  Parameters      : -
    *  Returns         : Map<String, Object> - scoring settings
    ******************************************************************************/
    public static Map<String, Object> getScoringSettings() {
        if (resource == null) {
            resource = (Map<String, Object>) ((Map<String, Object>) JSON.deserializeUntyped(
                    ([
                            SELECT Body
                            FROM StaticResource
                            WHERE Name = 'ScoringSettings'
                            LIMIT 1
                    ]).Body.toString())).get('settings');
        }
        return resource;
    }

    /*****************************************************************************
    *  Name            : getScoringSettings(String name)
    *  Summary         : returns specific settings for scoring
    *  CreatedDate     : 30.07.2020
    *  Parameters      : -
    *  Returns         : Object - scoring settings
    ******************************************************************************/
    public static Object getScoringSettings(String name) {
        if (CFUtils.getScoringSettings() == null) {
            return null;
        } else {
            return getScoringSettings().get(name);
        }
    }

    /*****************************************************************************
    *  Name            : replcaeNullValue(Object value)
    *  Summary         : returns '-' if value is null
    *  CreatedDate     : 19.08.2020
    *  Parameters      : -
    *  Returns         : String - '-'
    ******************************************************************************/
    public static String replcaeNullValue(Object value) {
        return (value == null) ? '-' : String.valueOf(value);
    }

    public static Long zeroIfNull(FinancialReportFormValue value) {
        return value == null ? 0 : value.startValue;
    }

    /*****************************************************************************
    *  Name            : parsePrescoringDate(String dateString)
    *  Summary         : parses String date dd.mm.yyyy into Salesforce System.Date
    *  CreatedDate     : 22.12.2020
    *  Parameters      : String dateString - date in format dd.mm.yyyy
    *  Returns         : Date - SF standart Date class
    ******************************************************************************/
    public static Date parsePrescoringDate(String dateString) {
        if (String.isBlank(dateString)) {
            return null;
        } else {
            String tag = '.';
            Integer year = Integer.valueOf(dateString.substringAfterLast(tag));
            Integer month = Integer.valueOf(dateString.substringBetween(tag));
            Integer day = Integer.valueOf(dateString.substringBefore(tag));
            return Date.newInstance(year, month, day);
        }
    }

    /*****************************************************************************
    *  Name            : parsePreScoringDecision(DecisionPrescoring decision)
    *  Summary         : parses DecisionPrescoring object into decision for users
    *  CreatedDate     : 17.03.2021
    *  Parameters      : DecisionPrescoring decision - response from scoring service
    *  Returns         : String - user friendly decision
    ******************************************************************************/
    public static String parsePreScoringDecision(DecisionPrescoring decision) {
        if (decision != null && decision.decision != null && decision.blocked != null) {
            if (decision.blocked) {
                return CFUtils.ScoringDecision.Denied.name();
            } else {
                if (decision.decision) {
                    return CFUtils.ScoringDecision.Credit_approved.name();
                } else {
                    return CFUtils.ScoringDecision.Prepay.name();
                }
            }
        }
        return CFUtils.ScoringDecision.No_data.name();
    }

    public class FinancialReportFormValueCode {
        public final String CODE_1150 = '1150';
        public final String CODE_1200 = '1200';
        public final String CODE_1250 = '1250';
        public final String CODE_1230 = '1230';
        public final String CODE_1210 = '1210';
        public final String CODE_1300 = '1300';
        public final String CODE_1500 = '1500';
        public final String CODE_1510 = '1510';
        public final String CODE_1520 = '1520';
        public final String CODE_1550 = '1550';
        public final String CODE_2110 = '2110';
    }

    public class FinancialReportFormValue {
        public Long startValue;
        public Long endValue;
    }

}