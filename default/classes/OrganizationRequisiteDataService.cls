public with sharing class OrganizationRequisiteDataService {
    public final static String RUSSIAN_CREDIT_CHECK = 'Russian credit check';

    /*****************************************************************************
     *  Name            : getOrganizationRequisiteDataByOppId(Id OpportunityId)
     *  Summary         : return null or all OrganizationRequisiteData
     *  CreatedDate     : 04.05.2021
     *  Parameters      : Id OpportunityId
     *  Returns         : data creditFactoryReports,oppContactRoles,account,opportunity
     ******************************************************************************/

    @AuraEnabled(Cacheable=true)
    public static OrganizationRequisiteDataServiceWrapper getOrganizationRequisiteDataByOppId(Id opportunityId) {
        if (opportunityId != null) {
            OrganizationRequisiteDataServiceWrapper wrapper = new OrganizationRequisiteDataServiceWrapper();

            wrapper.opportunity = OrganizationRequisiteDataManager.findOpportunityById(opportunityId);
            wrapper.account = wrapper.opportunity[0].AccountId != null
                ? OrganizationRequisiteDataManager.findAccountById(wrapper.opportunity[0].AccountId)
                : null;
            wrapper.oppContactRoles = OrganizationRequisiteDataManager.findOpportunityContactRolesByOpportunityId(opportunityId);
            wrapper.creditFactoryReports = OrganizationRequisiteDataManager.findCreditFactoryReportsByOppId(opportunityId);
            return wrapper;
        }
        return null;
    }

    @TestVisible
    private class OrganizationRequisiteDataServiceWrapper {
        @AuraEnabled
        public List<Opportunity> opportunity;
        @AuraEnabled
        public List<Account> account;
        @AuraEnabled
        public List<OpportunityContactRole> oppContactRoles;
        @AuraEnabled
        public List<Credit_Factory_Report__c> creditFactoryReports;
    }

    /*****************************************************************************
     *  Name            : getScoringDecision()
     *  Summary         : get string Credit approved
     *  CreatedDate     : 12.04.2021
     *  Parameters      : null
     *  Returns         : String Credit approved
     ******************************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String getScoringDecision() {
        return CFUtils.ScoringDecision.Credit_approved.name();
    }

    /*****************************************************************************
     *  Name            : getRussianCreditCheckRecordTypeId()
     *  Summary         : get RecordTypeId from Russian credit check
     *  CreatedDate     : 17.05.2021
     *  Parameters      : null
     *  Returns         : Id RecordTypeId
     ******************************************************************************/
    @AuraEnabled(Cacheable=true)
    public static Id getRussianCreditCheckRecordTypeId() {
        Id creditFactoryRecordTypeId = Schema.SObjectType.Credit_Factory_Report__c.getRecordTypeInfosByName().get(RUSSIAN_CREDIT_CHECK).getRecordTypeId();
        return creditFactoryRecordTypeId != null ? creditFactoryRecordTypeId : null;
    }

    /*****************************************************************************
     *  Name            : insertOppContactRole(Boolean isPrimary, Id contactId, Id opportunityId))
     *  Summary         : connect Opportunity with Contact by insertingOpportunityContactRole
     *  CreatedDate     : 20.04.2021
     *  Parameters      : null
     *  Returns         : OpportunityContactRole
     ******************************************************************************/
    @AuraEnabled
    public static OpportunityContactRole insertOppContactRole(Boolean isPrimary, Id contactId, Id opportunityId) {
        if (contactId != null && opportunityId != null) {
            OpportunityContactRole oppCntRole = new OpportunityContactRole();
            oppCntRole.IsPrimary = isPrimary;
            oppCntRole.ContactId = contactId;
            oppCntRole.OpportunityId = opportunityId;
            insert oppCntRole;
            return oppCntRole;
        } else {
            return null;
        }
    }
}