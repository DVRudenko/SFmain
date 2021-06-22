public with sharing class BRSettingsService {
    public static final String SAVE_FAILED = 'Error. Save failed.';
    public static final String DELETE_FAILED = 'Error. Delete failed.';
    public static final String LOGGER_TYPE_NAME = 'Business regulation';

    private BRSettingsManager manager = new BRSettingsManager();
    private Logger logger = new Logger(LOGGER_TYPE_NAME);

    public void saveSetting(String settingData) {
        if (String.isEmpty(settingData)) {
            return;
        }

        BRSettingWrapper settingWrapper = (BRSettingWrapper) JSON.deserialize(settingData, BRSettingWrapper.class);
        Map<Id, BR_case__c> oldCasesMap = new Map<Id, BR_case__c>(manager.getCasesAndDependedFiltersBySettingId(settingWrapper.id));

        BR_Setting__c newSetting = new BR_Setting__c(
            Id = settingWrapper.id,
            Name = settingWrapper.name,
            Is_active__c = settingWrapper.isActive,
            SObject__c = settingWrapper.sObjectName,
            SObject_status__c = settingWrapper.sObjectStatus
        );

        Savepoint savepoint = Database.setSavepoint();

        try {
            upsert newSetting;

            if (settingWrapper.cases != null) {
                Map<Integer, BR_case__c> newCasesMap = new Map<Integer, BR_case__c>();
                Integer caseCounter = 0;
                for (BRSettingWrapper.BRCase brCase : settingWrapper.cases) {
                    BR_case__c caseRecord = new BR_case__c(
                            Id = brCase.id,
                            Name = brCase.name,
                            BR_Setting__c = newSetting.Id,
                            Filter_logic__c = brCase.filterLogic
                    );
                    brCase.caseNumber = caseCounter;
                    newCasesMap.put(brCase.caseNumber, caseRecord);
                    oldCasesMap.remove(brCase.id);
                }

                upsert newCasesMap.values();

                Map<Id, BR_filter__c> oldFiltersMap = prepareOldFiltersMap(oldCasesMap.values());
                upsertFilters(settingWrapper.cases, newCasesMap, oldFiltersMap);
            }

            delete oldCasesMap.values();
        } catch (Exception e) {
            Database.rollback(savepoint);
            processErrorLogging('saveSetting', e);
            throw new GlobalException(SAVE_FAILED);
        }
    }

    public void deleteSetting(Id settingId) {
        try {
            delete new BR_Setting__c(Id = settingId);
        } catch(Exception e) {
            processErrorLogging('deleteSetting', e);
            throw new GlobalException(DELETE_FAILED);
        }
    }

    private void upsertFilters(List<BRSettingWrapper.BRCase> caseWrappers, Map<Integer, BR_case__c> newCasesMap, Map<Id, BR_filter__c> oldFiltersMap) {
        List<BR_filter__c> newFilters = new List<BR_filter__c>();
        for (BRSettingWrapper.BRCase brCase : caseWrappers) {
            if (brCase.filters != null) {
                for (BRSettingWrapper.BRFilter filter : brCase.filters) {
                    newFilters.add(
                            new BR_filter__c(
                                    Id = filter.id,
                                    BR_case__c = newCasesMap.get(brCase.caseNumber).Id,
                                    Condition__c = filter.condition,
                                    Field__c = filter.field,
                                    Field_type__c = filter.fieldType,
                                    Field_value__c = filter.fieldValue,
                                    Filter_number__c = Decimal.valueOf(filter.filterNumber)
                            )
                    );
                    oldFiltersMap.remove(filter.id);
                }
            }
        }

        upsert newFilters;
        delete oldFiltersMap.values();
    }

    private Map<Id, BR_filter__c> prepareOldFiltersMap(List<BR_case__c> oldCases) {
        Map<Id, BR_filter__c> oldFiltersMap = new Map<Id, BR_filter__c>();
        for (BR_case__c oldCase : oldCases) {
            if (!oldCase.BR_filters__r.isEmpty()) {
                oldFiltersMap.putAll(new Map<Id, BR_filter__c>(oldCase.BR_filters__r));
            }
        }

        return oldFiltersMap;
    }

    private void processErrorLogging(String methodName, Exception e) {
        String errorMessage = 'Line number: ' + e.getLineNumber() + '. Message: ' + e.getMessage();
        System.debug(LoggingLevel.ERROR, errorMessage);
        logger.fatal('BRSettingsService.' + methodName, errorMessage);
        logger.saveLogs();
    }
}
