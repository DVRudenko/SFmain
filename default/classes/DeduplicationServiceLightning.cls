public with sharing class DeduplicationServiceLightning {

    /*****************************************************************************
    *  Name            : getDeduplicationResult(String inn, Long email)
    *  Summary         : Start DeduplicationService and return result deduplication
    *  CreatedDate     : 29.03.2021
    *  Parameters      : String inn, String email
    *  Returns         : String - JSON with data
    ******************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static String processDeduplication(String inn, String email, Id opportunityId, Id accountId, Id contactId) {
        DeduplicationService data = new DeduplicationService();
        if (inn == null || email == null || opportunityId == null || accountId == null || contactId == null) {
            return null;
        }
        return JSON.serialize(data.deduplicateAccounts(inn, email, accountId, contactId, opportunityId));
    }

    /*****************************************************************************
    *  Name            : getDeduplicationStatusName()
    *  Summary         : get string E2EWithOutUpdate
    *  CreatedDate     : 02.04.2021
    *  Parameters      : null
    *  Returns         : String E2EWithOutUpdate
    ******************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static String getDeduplicationStatusName() {
        return GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name();
    }
}