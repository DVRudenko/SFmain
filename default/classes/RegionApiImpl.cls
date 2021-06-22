/**
 * Created by Aleksandr.Gaakh on 05.03.2021.
 */

public with sharing class RegionApiImpl {
    public static String refId;

    @Future(Callout=true)
    public static void updateLeads(Set<Id> ids) {
        refId = new List<Id>(ids).get(0);

        String serviceStatus = getConnectionStatus(null, 'StatusUslugi');
        if (serviceStatus == null) {
            return;
        }
        switch on serviceStatus {
            when '0' {
                throwConnectionException(refId, '0', 'Service unavailable. Exception in RegionApiImpl.updateLeads()');
                return;
            }
            when '2' {
                throwConnectionException(refId, '2', 'Technical break. Exception in RegionApiImpl.updateLeads()');
                return;
            }
        }

        String sessionId = getSessionId();
        if (!String.isBlank(sessionId)) {
            try {
                List<Lead> newLeads = new List<Lead>();
                Lead leadForUpdate = [
                        SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                                Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c, Suspending_Activity_Date__c,
                                Date_of_request_to_RegionApi__c, Sec_Channel__c // , Provided_activity_PKD__c, Gesellschaftsform__c
                        FROM Lead
                        WHERE Country = 'Poland' AND Steuernummer__c != NULL AND Id IN :ids
                        LIMIT 1
                ];
                // Batch processing takes place in a separate class RegionApiBatch

                String nip = leadForUpdate.Steuernummer__c.replaceAll('[^0-9,]', '');

                List<RegionApiCompany> regionApiCompanies = getCompaniesInfo(sessionId, nip);
                if (regionApiCompanies == null) {
                    return;
                }

                RegionApiCompanyFullReport regionApiCompanyFullReport;
                String oldAndNewLeadFields = '';

                for (RegionApiCompany regionApiCompany : regionApiCompanies) {
                    if (!String.isBlank(regionApiCompany.errorMessage)) {
                        getLog(refId, null, null, regionApiCompany.errorMessage);
                        return;
                    }
                    if (leadForUpdate.Steuernummer__c.replaceAll('[^0-9,]', '') == regionApiCompany.taxId) {
                        String reportName = RegionApi.setReportName(regionApiCompany);
                        oldAndNewLeadFields += 'Old fields ' + refId + ' : \n' + RegionApi.leadFieldsForLog(leadForUpdate, oldAndNewLeadFields);
                        if (regionApiCompany.silosId == '6' || regionApiCompany.silosId == '4') {
                            regionApiCompanyFullReport = getCompanyFullReport(sessionId, regionApiCompany.region, reportName);
//                            regionApiCompanyFullReport.industry = getIndustry(sessionId, regionApiCompany.region, 'BIR11OsPrawnaPkd');
                        } else {
                            regionApiCompanyFullReport = getCompanyFullReport(sessionId, regionApiCompany.region, reportName);
//                            regionApiCompanyFullReport.legalForm = getLegalFormForFizEntity(sessionId, regionApiCompany.region, 'BIR11OsFizycznaDaneOgolne');
//                            regionApiCompanyFullReport.industry = getIndustry(sessionId, regionApiCompany.region, 'BIR11OsFizycznaPkd');
                        }
                        if (regionApiCompanyFullReport == null) { // || regionApiCompanyFullReport.industry == null || regionApiCompanyFullReport.legalForm == null) {
                            return;
                        }
                        if (!String.isBlank(regionApiCompanyFullReport.errorMessage)) {
                            getLog(refId, null, null, regionApiCompanyFullReport.errorMessage);
                            return;
                        }
                        leadForUpdate = RegionApi.setLeadFields(leadForUpdate, regionApiCompanyFullReport);
                        System.debug(RegionApi.newLeadFields);
                        oldAndNewLeadFields += 'New fields ' + refId + ' :\n' + RegionApi.newLeadFields;
                        System.debug(RegionApi.newLeadFields);
                        newLeads.add(leadForUpdate);
                    }
                }

                logout(sessionId);
                if (!newLeads.isEmpty()) {
                    try {
                        update newLeads;
                        getLog(refId, null, null, oldAndNewLeadFields);
                    } catch (DmlException e) {
                        getLog(refId, null, e, null);
                    }
                }
            } catch (Exception e) {
                getLog(refId, null, e, null);
            }
        }
    }

    public static String getSessionId() {
        Http http = new Http();
        HttpRequest request = RegionApi.generateRequest(null);
        HttpResponse response;

        request.setBody(RegionApi.login('b63198c635214a6a905a'));

        try {
            response = http.send(request);
            if (response.getStatusCode() != 200) {
                getLog(refId, response, null, null);
                return null;
            }
            return RegionApiParser.getDomString(response, 'ZalogujResponse');
        } catch (Exception e) {
            getLog(refId, null, e, null);
            return null;
        }
    }

    public static List<RegionApiCompany> getCompaniesInfo(String sidHeader, String taxId) {
        Http http = new Http();
        HttpRequest request = RegionApi.generateRequest(sidHeader);
        HttpResponse response;

        request.setBody(RegionApi.retrieveCompaniesInfo(taxId));

        try {
            response = http.send(request);
            if (response.getStatusCode() != 200) {
                getLog(refId, response, null, null);
                return null;
            }
            System.debug(response.getBody());
            Dom.XmlNode envelope = RegionApiParser.getCompaniesDomElement(response, 'DaneSzukajPodmiotyResponse', 'DaneSzukajPodmiotyResult');
            List<RegionApiCompany> regionApiCompanyInfos = new List<RegionApiCompany>();
            regionApiCompanyInfos = RegionApi.setCompanyFields(envelope);
            return regionApiCompanyInfos;
        } catch (Exception e) {
            getLog(refId, null, e, null);
            return null;
        }
    }

    public static RegionApiCompanyFullReport getCompanyFullReport(String sidHeader, String region, String reportName) {
        Http http = new Http();
        HttpRequest request = RegionApi.generateRequest(sidHeader);
        HttpResponse response;

        request.setBody(RegionApi.retrieveCompanyFullReport(region, reportName));

        try {
            response = http.send(request);
            if (response.getStatusCode() != 200) {
                getLog(refId, response, null, null);
                return null;
            }
            Dom.XmlNode envelope = RegionApiParser.getCompanyFullReportDomElement(response, 'DanePobierzPelnyRaportResponse', 'DanePobierzPelnyRaportResult');
            RegionApiCompanyFullReport regionApiLead = new RegionApiCompanyFullReport();
            regionApiLead = RegionApi.setCompanyFullReportFields(envelope);
            return regionApiLead;
        } catch (Exception e) {
            getLog(refId, null, e, null);
            return null;
        }
    }

//    public static String getIndustry(String sidHeader, String region, String reportName) {
//        Http http = new Http();
//        HttpRequest request = RegionApi.generateRequest(sidHeader);
//        HttpResponse response;
//
//        request.setBody(RegionApi.retrieveCompanyFullReport(region, reportName));
//
//        try {
//            response = http.send(request);
//            if (response.getStatusCode() != 200) {
//                getLog(refId, response, null, null);
//                return null;
//            }
//            Dom.XmlNode envelope = RegionApiParser.getCompaniesDomElement(response, 'DanePobierzPelnyRaportResponse', 'DanePobierzPelnyRaportResult');
//            String performedActivities;
//            for (Dom.XmlNode companyPKDInfoElement : envelope.getChildElements()) {
//                String pkdStatus = RegionApiParser.getPKDStatus(companyPKDInfoElement);
//                if (pkdStatus == '1') {
//                    performedActivities += RegionApiParser.getPKD(companyPKDInfoElement);
//                }
//            }
//            return performedActivities;
//        } catch (Exception e) {
//            getLog(refId, null, e, null);
//            return null;
//        }
//    }
//
//    public static String getLegalFormForFizEntity(String sidHeader, String region, String reportName) {
//        Http http = new Http();
//        HttpRequest request = RegionApi.generateRequest(sidHeader);
//        HttpResponse response;
//
//        request.setBody(RegionApi.retrieveCompanyFullReport(region, reportName));
//
//        try {
//            response = http.send(request);
//            if (response.getStatusCode() != 200) {
//                getLog(refId, response, null, null);
//                return null;
//            }
//            Dom.XmlNode envelope = RegionApiParser.getCompanyFullReportDomElement(response, 'DanePobierzPelnyRaportResponse', 'DanePobierzPelnyRaportResult');
//            return RegionApiParser.getLegalForm(envelope);
//        } catch (Exception e) {
//            getLog(refId, null, e, null);
//            return null;
//        }
//    }

    public static String getConnectionStatus(String sidHeader, String paramName) {
        Http http = new Http();
        HttpRequest request = RegionApi.generateRequest(sidHeader);
        HttpResponse response;

        request.setBody(RegionApi.getStatus(paramName));

        try {
            response = http.send(request);
            // ToDo Switch statement
            if (response.getStatusCode() != 200) {
                getLog(refId, response, null, null);
                return null;
            }
            String connectionStatus = RegionApiParser.getDomString(response, 'GetValueResponse');
            return connectionStatus;
        } catch (Exception e) {
            getLog(refId, null, e, null);
            return null;
        }
    }

    public static void logout(String sidHeader) {
        Http http = new Http();
        HttpRequest request = RegionApi.generateRequest(sidHeader);
        HttpResponse response;

        request.setBody(RegionApi.logout(sidHeader));

        try {
            response = http.send(request);
            if (response.getStatusCode() != 200) {
                getLog(refId, response, null, null);
                return;
            }
        } catch (Exception e) {
            getLog(refId, null, e, null);
        }
    }

    public static void getLog(String refId, HttpResponse response, Exception e, String logMessage) {
        Logger logger = new Logger(refId, 'regionApiPL');
        if (response == null && e == null) {
            logger.info(logMessage);
            logger.saveLogs();
            return;
        }
        if (response == null) {
            logger.error(e.getMessage() + ' ' + e.getStackTraceString());
            logger.saveLogs();
            return;
        }
        logger.error('Error: ' + response.getStatus() + ' ' + response.getStatusCode() + ' | ' + response.getBody());
        logger.saveLogs();
    }

    public static void throwConnectionException(String refId, String serviceStatus, String serviceMessage) {
        try {
            throw new RegionApiException();
        } catch (Exception e) {
            Logger logger = new Logger(refId, 'regionApiPL');
            logger.error(serviceStatus + ' ' + serviceMessage + ' ' + e.getMessage());
            logger.saveLogs();
        }
    }
}