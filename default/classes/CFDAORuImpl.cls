public without sharing class CFDAORuImpl implements CFDAO {
    /*****************************************************************************
     *  Name            : updateSObjects(List<SObject> sObjects)
     *  Summary         : general method for SObject update
     *  CreatedDate     : 05/12/2019
     *  Parameters      : List<SObject> sObjects
     *  Returns         : List<SObject> - updated sObjects
     ******************************************************************************/
    public List<SObject> updateSObjects(List<SObject> sObjects) {
        update sObjects;
        return sObjects;
    }

    // **** Account DAO **** //

    /*****************************************************************************
     *  Name            : updateAccounts(List<Account> accounts)
     *  Summary         : updates Accounts
     *  CreatedDate     : 05/12/2019
     *  Parameters      : List<Account> accounts
     *  Returns         : List<Account> - updated accounts
     ******************************************************************************/
    public List<Account> updateAccounts(List<Account> accounts) {
        update accounts;
        return accounts;
    }

    /*****************************************************************************
     *  Name            : getAccountById(Id accountId)
     *  Summary         : gets Account by ID
     *  CreatedDate     : 05/12/2019
     *  Parameters      : Id accountId
     *  Returns         : Account
     ******************************************************************************/
    public Account getAccountById(Id accountId) {
        return ([
            SELECT
                Id,
                Spark_ID__c,
                OKPO_ppr__c,
                INN__c,
                Company_Legal_Name1__c,
                KPP__c,
                OKVED__c,
                BillingCity,
                BillingStreet,
                BillingPostalCode,
                Organization_Type__c,
                Type,
                Name,
                OGRN_ppr__c,
                OwnerId,
                Black_list_check_code__c,
                Black_list_check_decision__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ]);
    }

    // **** Credit factory report DAO **** //

    /*****************************************************************************
     *  Name            : insertCreditFactoryReports(List<Credit_Factory_Report__c> reports)
     *  Summary         : creates CF reports
     *  CreatedDate     : 05/12/2019
     *  Parameters      : List<Credit_Factory_Report__c> reports
     *  Returns         : List<Credit_Factory_Report__c> - created reports
     ******************************************************************************/
    public List<Credit_Factory_Report__c> insertCreditFactoryReports(List<Credit_Factory_Report__c> reports) {
        insert reports;
        return reports;
    }

    /*****************************************************************************
     *  Name            : updateCreditFactoryReports(List<Credit_Factory_Report__c> reports)
     *  Summary         : updates CF reports
     *  CreatedDate     : 05/12/2019
     *  Parameters      : List<Credit_Factory_Report__c> reports
     *  Returns         : List<Credit_Factory_Report__c> - updated reports
     ******************************************************************************/
    public List<Credit_Factory_Report__c> updateCreditFactoryReports(List<Credit_Factory_Report__c> reports) {
        update reports;
        return reports;
    }

    public List<Credit_Factory_Report__c> getCFR(Set<Id> ids) {
        return [
            SELECT
                Id,
                Credit_System_Number__c,
                Credit_Limit__c,
                RU_Scoring_date__c,
                RU_scoring_type__c,
                RU_Scoring_expiration_date__c,
                RU_Scoring_description__c,
                RU_scoring_decision_state__c,
                RU_Client_choice__c,
                RU_denial_reason__c,
                RU_black_list_code__c,
                Source_of_lead_matched__c,
                RU_scoring_decision_code__c,
                RU_scoring_decision__c,
                RU_black_list_decision__c,
                Scoring_notification_sent__c,
                RU_scoring_decision_status__c,
                RU_credit_type__c,
                RU_credit_term__c,
                RU_payment_term__c,
                OwnerId,
                Name,
                Account__c,
                Opportunity__c,
                First_bill__c,
                Different_post_address__c,
                New_legal__c,
                RecordTypeId,
                RU_Application_Blocked__c,
                RU_Scoring_Credit_Period__c,
                RU_Scoring_Payment_Time_Limit__c
            FROM Credit_Factory_Report__c
            WHERE Id IN :ids
        ];
    }

    public List<Credit_Factory_Report__c> getCFR(Set<Id> opportunityIds, String scoringType, Id recordTypeId) {
        return [
            SELECT
                Id,
                Credit_System_Number__c,
                Credit_Limit__c,
                RU_Scoring_date__c,
                RU_scoring_type__c,
                RU_Scoring_expiration_date__c,
                RU_Scoring_description__c,
                RU_scoring_decision_state__c,
                RU_Client_choice__c,
                RU_denial_reason__c,
                RU_black_list_code__c,
                Source_of_lead_matched__c,
                RU_scoring_decision_code__c,
                RU_scoring_decision__c,
                RU_black_list_decision__c,
                Scoring_notification_sent__c,
                RU_scoring_decision_status__c,
                RU_credit_type__c,
                RU_credit_term__c,
                RU_payment_term__c,
                OwnerId,
                Name,
                Account__c,
                Opportunity__c,
                First_bill__c,
                Different_post_address__c,
                New_legal__c
            FROM Credit_Factory_Report__c
            WHERE Opportunity__c IN :opportunityIds AND RecordTypeId = :recordTypeId AND RU_scoring_type__c = :scoringType
            ORDER BY LastModifiedDate DESC
        ];
    }

    /*****************************************************************************
     *  Name            : getActualCFRs(Id opportunityId, List<Id> recordTypeIds)
     *  Summary         : select actual CFR records by opportunity Id and record types
     *  CreatedDate     : 06/01/2021
     *  Parameters      : Id opportunityId, List<Id> recordTypeIds
     *  Returns         : List<Credit_Factory_Report__c>
     ******************************************************************************/
    public List<Credit_Factory_Report__c> getActualCFRs(Id opportunityId, List<Id> recordTypeIds) {
        List<Credit_Factory_Report__c> cfrRecords = new List<Credit_Factory_Report__c>();

        if (recordTypeIds != null) {
            cfrRecords = [
                    SELECT
                    Name,
                    Credit_Limit__c,
                    RU_Client_Choice__c,
                    RU_Scoring_Payment_Time_Limit__c,
                    RU_Scoring_Credit_Period__c,
                    RecordTypeId,
                    RU_scoring_decision__c,
                    RU_Scoring_expiration_date__c,
                    RU_scoring_type__c,
                    RU_scoring_decision_status__c
                    FROM Credit_Factory_Report__c
                    WHERE Opportunity__c = :opportunityId
                    AND RU_scoring_decision__c = :CFUtils.ScoringDecision.Credit_approved.name()
                    AND RU_Scoring_expiration_date__c > :Date.today()
                    AND RecordTypeId IN :recordTypeIds
                    ORDER BY RU_Scoring_expiration_date__c DESC
            ];
        }

        return cfrRecords;
    }

    /*****************************************************************************
     *  Name            : getCfrForUpdate(Id opportunityId)
     *  Summary         : select CFR records by opportunity Id
     *  CreatedDate     : 14/01/2021
     *  Parameters      : Id opportunityId
     *  Returns         : List<Credit_Factory_Report__c>
     ******************************************************************************/
    public List<Credit_Factory_Report__c> getCfrForUpdate(Id opportunityId) {
        List<Credit_Factory_Report__c> cfrRecords = new List<Credit_Factory_Report__c>();

        if (opportunityId != null) {
            cfrRecords = [
                    SELECT Id, Name, RU_Client_Choice__c
                    FROM Credit_Factory_Report__c
                    WHERE
                            Opportunity__c = :opportunityId
            ];
        }
        return cfrRecords;
    }

    /*****************************************************************************
     *  Name            : getCreditFactoryReports(List<Id> opportunityIds, String recordTypeId, List<String> scoringTypes)
     *  Summary         : selects actual credit data for chosen properties
     *  CreatedDate     : 11/12/2020
     *  Parameters      : List<Id> opportunityIds, String recordTypeId, List<String> scoringTypes - See CFUtils class
     *  Returns         : List<Credit_Factory_Report__c>
     ******************************************************************************/
    public List<Credit_Factory_Report__c> getCreditFactoryReports(List<Id> opportunityIds, Id recordTypeId, List<String> scoringTypes) {
        return [
            SELECT
                Id,
                RecordTypeId,
                RU_Application_Blocked__c,
                RU_Scoring_Credit_Period__c,
                RU_Scoring_Payment_Time_Limit__c,
                Credit_System_Number__c,
                Credit_Limit__c,
                RU_Scoring_date__c,
                RU_scoring_type__c,
                RU_Scoring_expiration_date__c,
                RU_Scoring_description__c,
                RU_scoring_decision_state__c,
                RU_Client_choice__c,
                RU_denial_reason__c,
                RU_black_list_code__c,
                Source_of_lead_matched__c,
                RU_scoring_decision_code__c,
                RU_scoring_decision__c,
                RU_black_list_decision__c,
                Scoring_notification_sent__c,
                RU_scoring_decision_status__c,
                RU_credit_type__c,
                RU_credit_term__c,
                RU_payment_term__c,
                OwnerId,
                Name,
                Account__c,
                Opportunity__c,
                First_bill__c,
                Different_post_address__c,
                New_legal__c
            FROM Credit_Factory_Report__c
            WHERE Opportunity__c IN :opportunityIds AND RecordTypeId = :recordTypeId AND RU_scoring_type__c IN :scoringTypes
            ORDER BY RU_Scoring_date__c DESC NULLS LAST
        ];
    }

    // **** Opportunity DAO **** //

    /*****************************************************************************
     *  Name            : getOpportunityById(Id opportunityId)
     *  Summary         : selects record by List of ID and with specific record types
     *  CreatedDate     : 05/12/2019
     *  Parameters      : List<Id> opportunityIds, List<Id> recordTypeIds
     *  Returns         : List<Opportunity>
     ******************************************************************************/
    public List<Opportunity> getOpportunities(List<Id> opportunityIds, List<Id> recordTypeIds) {
        return ([
            SELECT Id, INN_Opp__c, Source_of_Lead_o__c, AccountId, Expected_Volume_Ru__c, Business_process__c, CF_checking__c
            FROM Opportunity
            WHERE Id IN :opportunityIds AND RecordTypeId IN :recordTypeIds
        ]);
    }

    public List<Opportunity> getOpportunities(Set<Id> ids) {
        return [
            SELECT Id, INN_Opp__c, Source_of_Lead_o__c, AccountId
            FROM Opportunity
            WHERE Id IN :ids AND RecordTypeId = :OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID
        ];
    }

    /*****************************************************************************
     *  Name            : getOpportunitiesByAccountIdAndStages(Id accountId, List<String> excludeStages)
     *  Summary         : gets all Russian Opportunities by Account ID, except Opportunities that have excluded Stage
     *  CreatedDate     : 05/12/2019
     *  Parameters      : Id accountId, List<String> excludeStages - stages to exclude
     *  Returns         : List<Opportunity>
     ******************************************************************************/
    public List<Opportunity> getOpportunitiesByAccountIdAndStages(Id accountId, List<String> excludeStages) {
        return ([
            SELECT Id, PPR_Lost_Reasons__c, StageName, OwnerId
            FROM Opportunity
            WHERE AccountId = :accountId AND StageName NOT IN :excludeStages AND RecordTypeId = :OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID
        ]);
    }

    /*****************************************************************************
     *  Name            : updateOpportunities(List<Opportunity> opportunities)
     *  Summary         : updates Opportunities
     *  CreatedDate     : 05/12/2019
     *  Parameters      : List<Opportunity> opportunities
     *  Returns         : List<Opportunity> - updated Opportunities
     ******************************************************************************/
    public List<Opportunity> updateOpportunities(List<Opportunity> opportunities) {
        update opportunities;
        return opportunities;
    }

    public List<E2EFormData__c> getByOpportunityId(Set<Id> ids) {
        return [
            SELECT
                Id,
                E2E_Opportunity_Id__c,
                E2E_Account_Id__c,
                E2E_Contact_Id__c,
                E2E_Prepay_Amount__c,
                E2E_Post_Address__c,
                E2E_Legal_Address__c,
                E2E_Reg_Date__c,
                E2E_Source__c,
                E2E_Transit_Cont_Id__c,
                E2E_INN__c,
                E2E_Account_Short_Name__c
            FROM E2EFormData__c
            WHERE E2E_Opportunity_Id__c IN :ids
        ];
    }
}
