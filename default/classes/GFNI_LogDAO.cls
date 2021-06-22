/**
 * Created by Nikita.Mikhailov on 27.02.2019.
 */

public with sharing class GFNI_LogDAO {

    /*******************************************************************************
    *  Name            : queryLog
    *  Summary         : Retrieves information from GFNI_OpportunityLog__b by date
    *  CreatedDate     : 26.02.2019
    *  Returns         : List<GFNI_Opportunity_log__b>
    ******************************************************************************/
    public List<GFNI_Opportunity_log__b> queryLog(Date startDate, Date endDate) {
        return [
                SELECT
                        Opportunity__c,
                        CreatedDate,
                        RecordDateTime__c,
                        Request_Id__c,
                        Message__c,
                        IsFirst__c,
                        LogType__c
                FROM GFNI_Opportunity_log__b
                WHERE RecordDateTime__c >= :startDate
                AND RecordDateTime__c <= :endDate + 1
                LIMIT 30000
        ];
    }
}