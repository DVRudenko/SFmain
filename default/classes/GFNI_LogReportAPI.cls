/**
 * Created by Nikita.Mikhailov on 26.02.2019.
 */

public with sharing class GFNI_LogReportAPI {

    public String idValueSearch { get; set; }
    public String countryValueSearch { get; set; }
    public Boolean isFinishedValueSearch { get; set; }
    public Integer totalSize { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }

    private GFNI_LogDAO logDAO;

    public GFNI_LogReportAPI(Date startDate, Date endDate, GFNI_LogDAO logDAO) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.totalSize = 0;
        this.logDAO = logDAO;
    }

    public void setFilteringValues(String idValueSearch, String countryValueSearch, Boolean isFinishedValueSearch) {
        this.idValueSearch = idValueSearch;
        this.countryValueSearch = countryValueSearch;
        this.isFinishedValueSearch = isFinishedValueSearch;
    }

    /*******************************************************************************
    *  Name            : createReportRecords
    *  Summary         : Creates GFNI_LogReport using data from GFNI_OpportunityLog__b
    *  CreatedDate     : 26.02.2019
    *  Returns         : List<GFNI_LogReportRecord>
    ******************************************************************************/
    public List<GFNI_LogReportRecord> createReportRecords() {

        if (this.logDAO == null)
            this.logDAO = new GFNI_LogDAO();

        List<GFNI_Opportunity_log__b> logs = this.logDAO.queryLog(this.startDate, this.endDate);

        Map<Id, GFNI_LogReportRecord> reportRecords = new Map<Id, GFNI_LogReportRecord>();

        for (GFNI_Opportunity_log__b log : logs) {

            if (String.isNotBlank(this.idValueSearch)) {
                if (log.Opportunity__c != idValueSearch)
                    continue;
            }

            if (reportRecords.containsKey(log.Opportunity__c)) {
                reportRecords.get(log.Opportunity__c).recordDate = log.RecordDateTime__c;
                if (log.IsFirst__c != null) {
                    reportRecords.get(log.Opportunity__c).hasFirst = log.IsFirst__c == 1 ? true : false;
                } else {
                    reportRecords.get(log.Opportunity__c).hasFirst = null;
                }
                continue;
            }

            GFNI_LogReportRecord reportRecord = new GFNI_LogReportRecord();
            reportRecord.message = log.Message__c;
            reportRecord.recordDate = log.RecordDateTime__c;
            if (log.IsFirst__c != null)
                reportRecord.hasFirst = log.IsFirst__c == 1 ? true : false;

            reportRecords.put(log.Opportunity__c, reportRecord);
        }

        List<Opportunity> opportunities = [
                SELECT Id, Registered_Country__c, Language_preference__c, GFN_number_for_starts__c, Zahlungsart__c,
                        Product__c, GFNI_ApplicationId__c, Account.Name, Account.Account_Nr__c,
                        AccountId, Account.BillingCountryCode, Custom_PIN__c, StageName, (SELECT Id FROM Tankkarten__r WHERE GFNI_Status__c IN ('Pending', 'Failed', 'Warning') LIMIT 1), (SELECT Contact.Email FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1), (SELECT Id, Product2.Family, Product_Name__c FROM OpportunityLineItems)
                FROM Opportunity
                WHERE Id IN :reportRecords.keySet()
        ];

        //STCP1-240 Field mapping update for EV
        Map<Id, OpportunityLineItem> opportunityLineItems = new Map<Id, OpportunityLineItem>([SELECT Id, OpportunityId, Opportunity.Custom_PIN__c, Product2.Family FROM OpportunityLineItem WHERE OpportunityId IN :reportRecords.keySet()]);
        List<Offer_Item__c> offerItems = [SELECT Id, Opportunity_Product_Id__c FROM Offer_Item__c WHERE GFNI_Status__c IN ('Pending', 'Failed', 'Warning') AND Opportunity_Product_Id__c IN :opportunityLineItems.keySet()];

        Set<Id> opportunityIdsWithFailedOffers = new Set<Id>();
        for (Offer_Item__c offerItem : offerItems) {
            if (opportunityLineItems.get(offerItem.Opportunity_Product_Id__c).Opportunity.Custom_PIN__c) {
                if (!opportunityLineItems.get(offerItem.Opportunity_Product_Id__c).Product2.Family.equals('EV'))
                    continue;
            }

            opportunityIdsWithFailedOffers.add(opportunityLineItems.get(offerItem.Opportunity_Product_Id__c).OpportunityId);
        }

        List<GFNI_LogReportRecord> finalReport = new List<GFNI_LogReportRecord>();

        String product = '';

        for (Opportunity opportunity : opportunities) {
            GFNI_LogReportRecord reportRecord = reportRecords.get(opportunity.Id);

            if (String.isNotBlank(this.countryValueSearch)) {
                if (opportunity.Registered_Country__c != this.countryValueSearch) {
                    reportRecords.remove(opportunity.Id);
                    continue;
                }
            }

            if (reportRecord.hasFirst == null) {
                reportRecords.remove(opportunity.Id);
                continue;
            } else {
                if (!reportRecord.hasFirst) {
                    reportRecords.remove(opportunity.Id);
                    continue;
                }
            }

            if (this.isFinishedValueSearch != null) {
                if ((opportunity.GFN_number_for_starts__c != null && opportunity.GFNI_ApplicationId__c != null && ((opportunity.Tankkarten__r.isEmpty() || opportunity.Custom_PIN__c)
                        && !opportunityIdsWithFailedOffers.contains(opportunity.Id))) != isFinishedValueSearch) {
                    reportRecords.remove(opportunity.Id);
                    continue;
                }
            }

            try {
                product = GFNI_Utils.getUniqueProduct(opportunity);
            } catch (Exception e) {
                product = e.getMessage();
            }

            reportRecord.registeredCountry = GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Registered_Country__c.getDescribe(), opportunity.Registered_Country__c);
            reportRecord.languagePreference = GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Language_preference__c.getDescribe(), opportunity.Language_preference__c);
            reportRecord.accountNumberSF = GlobalUtils.blankStringIfNull(opportunity.Account.Account_Nr__c);
            reportRecord.accountNumberGFN = GlobalUtils.blankStringIfNull(opportunity.GFN_number_for_starts__c);
            reportRecord.accountName = GlobalUtils.blankStringIfNull(opportunity.Account.Name);
            if (!opportunity.OpportunityContactRoles.isEmpty())
                reportRecord.primaryContactEmail = opportunity.OpportunityContactRoles.get(0).Contact.Email;
            reportRecord.accountId = opportunity.AccountId;
            reportRecord.product = product;

            //STCP1-328
            //STCP1-327
            //STCP1-240 Field mapping update for EV
            reportRecord.isFinished = opportunity.StageName == 'Closed Lost' ||
                    (opportunity.GFN_number_for_starts__c != null && opportunity.GFNI_ApplicationId__c != null &&
                            ((opportunity.Tankkarten__r.isEmpty() || opportunity.Custom_PIN__c)
                                    && !opportunityIdsWithFailedOffers.contains(opportunity.Id)));

            //get product conclusion that need to be done by manual process
            Map<String, Object> conclusionByCountry = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'ConclusionOffer');
            if (conclusionByCountry.containsKey(opportunity.Account.BillingCountryCode.substring(0, 2))) {
                Map<String, Object> conclusionByProduct = (Map<String, Object>) conclusionByCountry.get(opportunity.Account.BillingCountryCode.substring(0, 2));
                if (conclusionByProduct.containsKey(product)) {
                    if (conclusionByProduct.get(product) instanceof Map<String, Object>) {
                        Map<String, Object> conclusionByPaymentMethod = (Map<String, Object>) conclusionByProduct.get(product);
                        if (conclusionByPaymentMethod.containsKey(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opportunity.Zahlungsart__c)))
                            reportRecord.conclusion = (String) conclusionByPaymentMethod.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opportunity.Zahlungsart__c));
                    } else {
                        reportRecord.conclusion = (String) conclusionByProduct.get(product);
                    }
                }
            }

            reportRecord.opportunityId = opportunity.Id;
            reportRecord.applicationId = opportunity.GFNI_ApplicationId__c;

            finalReport.add(reportRecord);
        }

        this.totalSize = finalReport.size();

        finalReport.sort();

        return finalReport;
    }
}