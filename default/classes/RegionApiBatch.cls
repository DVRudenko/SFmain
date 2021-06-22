/**
 * Created by Aleksandr.Gaakh on 26.03.2021.
 */

public with sharing class RegionApiBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    static Region_Api_Settings__c regionApiSettings = Region_Api_Settings__c.getValues('Endkunde_Lotos');
    static String query = regionApiSettings.RecordType_DateOfRequest_SOQL_Query__c;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,' +
                        'Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c, Suspending_Activity_Date__c,\n' +
                        'Date_of_request_to_RegionApi__c, Sec_Channel__c ' +
                        'FROM Lead ' +
                        'WHERE Steuernummer__c != NULL ' + (query == null ? ' ' : query));
    }

    public void execute(Database.BatchableContext bc, List<Lead> leads) {
        if (leads.size() > 20) {
            RegionApiImpl.getLog(bc.getJobId(), null, null, 'Batch size couldn\'t be more than 20');
            return;
        }
        String serviceStatus = RegionApiImpl.getConnectionStatus(null, 'StatusUslugi');
        if (serviceStatus == null) {
            return;
        }
        switch on serviceStatus {
            when '0' {
                RegionApiImpl.throwConnectionException(bc.getJobId(), '0', 'Service unavailable. Exception in RegionApiBatch.execute()');
                return;
            }
            when '2' {
                RegionApiImpl.throwConnectionException(bc.getJobId(), '2', 'Technical break. Exception in RegionApiBatch.execute()');
                return;
            }
        }

        String sessionId = RegionApiImpl.getSessionId();
        if (!String.isBlank(sessionId)) {
            try {
                List<Lead> newLeads = new List<Lead>();
                Map<Id, String> allLeadNips = new Map<Id, String>();

                for (Lead lead : leads) {
                    allLeadNips.put(lead.Id, lead.Steuernummer__c.replaceAll('[^0-9,]', ''));
                }
                String correctNips = '';
                String wrongNips = '';
                for (String nip : allLeadNips.keySet()) {
                    if (allLeadNips.get(nip).length() != 10) {
                        wrongNips += nip + ' - ' + allLeadNips.get(nip) + ',';
                    } else {
                        correctNips += allLeadNips.get(nip) + ',';
                    }
                }
                if (!String.isEmpty(correctNips)) {
                    correctNips = correctNips.substring(0, correctNips.length() - 1);
                }
                if (!String.isEmpty(wrongNips)) {
                    wrongNips = wrongNips.substring(0, wrongNips.length() - 1);
                    RegionApiImpl.getLog(bc.getJobId(), null, null, 'Wrong format Nip\'s: ' + wrongNips);
                }

                List<RegionApiCompany> regionApiCompanies = RegionApiImpl.getCompaniesInfo(sessionId, correctNips);
                if (regionApiCompanies == null) {
                    return;
                }

                RegionApiCompanyFullReport regionApiCompanyFullReport;
                String oldAndNewLeadFields = '';

                for (RegionApiCompany regionApiCompany : regionApiCompanies) {
                    if (!String.isBlank(regionApiCompany.errorMessage)) {
                        RegionApiImpl.getLog(bc.getJobId(), null, null, regionApiCompany.errorMessage);
                        continue;
                    }
                    for (Lead newLead : leads) {
                        if (!newLeads.contains(newLead)) {
                            if (newLead.Steuernummer__c.replaceAll('[^0-9,]', '') == regionApiCompany.taxId) {
                                String reportName = RegionApi.setReportName(regionApiCompany);
                                oldAndNewLeadFields += 'Old fields ' + newLead.Id + ' : \n' + RegionApi.leadFieldsForLog(newLead, oldAndNewLeadFields);
                                if (regionApiCompany.silosId == '6' || regionApiCompany.silosId == '4') {
                                    regionApiCompanyFullReport = RegionApiImpl.getCompanyFullReport(sessionId, regionApiCompany.region, reportName);
//                                    regionApiCompanyFullReport.industry = RegionApiImpl.getIndustry(sessionId, regionApiCompany.region, 'BIR11OsPrawnaPkd');
                                } else {
                                    regionApiCompanyFullReport = RegionApiImpl.getCompanyFullReport(sessionId, regionApiCompany.region, reportName);
//                                    regionApiCompanyFullReport.legalForm = RegionApiImpl.getLegalFormForFizEntity(sessionId, regionApiCompany.region, 'BIR11OsFizycznaDaneOgolne');
//                                    regionApiCompanyFullReport.industry = RegionApiImpl.getIndustry(sessionId, regionApiCompany.region, 'BIR11OsFizycznaPkd');
                                }
                                if (regionApiCompanyFullReport == null) { // || regionApiCompanyFullReport.industry == null || regionApiCompanyFullReport.legalForm == null) {
                                    continue;
                                }
                                if (!String.isBlank(regionApiCompanyFullReport.errorMessage)) {
                                    RegionApiImpl.getLog(newLead.Id, null, null, regionApiCompanyFullReport.errorMessage);
                                    continue;
                                }
                                newLead = RegionApi.setLeadFields(newLead, regionApiCompanyFullReport);
                                oldAndNewLeadFields += 'New fields ' + newLead.Id + ' :\n' + RegionApi.newLeadFields + '\n';
                                RegionApi.newLeadFields = '';
                                newLeads.add(newLead);
                            }
                        }
                    }
                }
                RegionApiImpl.logout(sessionId);
                if (!newLeads.isEmpty()) {
                    try {
                        update newLeads;
                        RegionApiImpl.getLog(bc.getJobId(), null, null, oldAndNewLeadFields);
                    } catch (DmlException e) {
                        RegionApiImpl.getLog(bc.getJobId(), null, e, null);
                    }
                }
            } catch (Exception e) {
                RegionApiImpl.getLog(bc.getJobId(), null, e, null);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}