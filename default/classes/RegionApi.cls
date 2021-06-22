/**
 * Created by Aleksandr.Gaakh on 05.03.2021.
 */

public with sharing class RegionApi {
    static Region_Api_Settings__c regionApiSettings = Region_Api_Settings__c.getValues('Endkunde_Lotos');
    static String endpoint = regionApiSettings.Endpoint__c;
    public static String newLeadFields = '';

    public static HttpRequest generateRequest(String sidHeader) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/soap+xml; charset=utf-8');
        if (sidHeader != null && sidHeader != '') {
            request.setHeader('sid', sidHeader);
        }

        return request;
    }

    public static String login(String userKey){
        String body = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"\n' +
                      'xmlns:ns="http://CIS/BIR/PUBL/2014/07">\n' +
                        '<soap:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">\n' +
                            '<wsa:To>' + endpoint + '</wsa:To>\n' +
                            '<wsa:Action>http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj</wsa:Action>\n' +
                        '</soap:Header>\n' +
                        '<soap:Body>\n' +
                            '<ns:Zaloguj>\n' +
                                '<ns:pKluczUzytkownika>' + userKey + '</ns:pKluczUzytkownika>\n' +
                            '</ns:Zaloguj>\n' +
                        '</soap:Body>\n' +
                '</soap:Envelope>';
        return body;
    }

    public static String logout(String sessionId){
        String body = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"\n' +
                      'xmlns:ns="http://CIS/BIR/PUBL/2014/07">\n' +
                        '<soap:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">\n' +
                            '<wsa:To>' + endpoint + '</wsa:To>\n' +
                            '<wsa:Action>http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj</wsa:Action>\n' +
                        '</soap:Header>\n' +
                        '<soap:Body>\n' +
                            '<ns:Wyloguj>\n' +
                                '<ns:pIdentyfikatorSesji>' + sessionId + '</ns:pIdentyfikatorSesji>\n' +
                            '</ns:Wyloguj>\n' +
                        '</soap:Body>\n' +
                      '</soap:Envelope>';
        return body;
    }

    public static String getStatus(String paramName){
        String body = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"\n' +
                      'xmlns:ns="http://CIS/BIR/2014/07">\n' +
                        '<soap:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">\n' +
                            '<wsa:To>' + endpoint + '</wsa:To>\n' +
                            '<wsa:Action>http://CIS/BIR/2014/07/IUslugaBIR/GetValue</wsa:Action>\n' +
                        '</soap:Header>\n' +
                        '<soap:Body>\n' +
                            '<ns:GetValue>\n' +
                                '<ns:pNazwaParametru>' + paramName + '</ns:pNazwaParametru>\n' +
                            '</ns:GetValue>\n' +
                        '</soap:Body>\n' +
                      '</soap:Envelope>';
        return body;
    }

    public static String retrieveCompaniesInfo(String taxId){
        String body = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"\n' +
                      'xmlns:ns="http://CIS/BIR/PUBL/2014/07" xmlns:dat="http://CIS/BIR/PUBL/2014/07/DataContract">\n' +
                        '<soap:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">\n' +
                            '<wsa:To>' + endpoint + '</wsa:To>\n' +
                            '<wsa:Action>http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty</wsa:Action>\n' +
                        '</soap:Header>\n' +
                        '<soap:Body>\n' +
                            '<ns:DaneSzukajPodmioty>\n' +
                                '<ns:pParametryWyszukiwania>\n' +
                                    '<dat:Nipy>' + taxId + '</dat:Nipy>\n' +
                                '</ns:pParametryWyszukiwania>\n' +
                            '</ns:DaneSzukajPodmioty>\n' +
                        '</soap:Body>\n' +
                      '</soap:Envelope>';
        return body;
    }

    public static String retrieveCompanyFullReport(String region, String reportName){
        String body = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"\n' +
                      'xmlns:ns="http://CIS/BIR/PUBL/2014/07">\n' +
                        '<soap:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">\n' +
                            '<wsa:To>' + endpoint + '</wsa:To>\n' +
                            '<wsa:Action>http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport</wsa:Action>\n' +
                        '</soap:Header>\n' +
                        '<soap:Body>\n' +
                            '<ns:DanePobierzPelnyRaport>\n' +
                                '<ns:pRegon>' + region + '</ns:pRegon>\n' +
                                '<ns:pNazwaRaportu>' + reportName + '</ns:pNazwaRaportu>\n' +
                            '</ns:DanePobierzPelnyRaport>\n' +
                        '</soap:Body>\n' +
                      '</soap:Envelope>';
        return body;
    }

    public static RegionApiCompanyFullReport setCompanyFullReportFields(Dom.XmlNode xmlDom){
        RegionApiCompanyFullReport regionApiLead = new RegionApiCompanyFullReport();
        regionApiLead.errorMessage = RegionApiParser.getErrorMessage(xmlDom);
        if (regionApiLead.errorMessage != null && regionApiLead.errorMessage != '') {
            return regionApiLead;
        }
        regionApiLead.name = RegionApiParser.getName(xmlDom);
        regionApiLead.street = RegionApiParser.getStreet(xmlDom);
        regionApiLead.state = RegionApiParser.getState(xmlDom);
        regionApiLead.city = RegionApiParser.getCity(xmlDom);
        regionApiLead.postalCode = RegionApiParser.getPostalCode(xmlDom);
        regionApiLead.taxId = RegionApiParser.getTaxId(xmlDom);
        regionApiLead.tradeRegisterNr = RegionApiParser.getTradeRegisterNr(xmlDom);
        regionApiLead.yearOfFoundation = RegionApiParser.getYearOfFoundation(xmlDom);
        regionApiLead.dateOfFoundation = RegionApiParser.getDateOfFoundation(xmlDom);
        regionApiLead.phone = RegionApiParser.getPhone(xmlDom);
        regionApiLead.email = RegionApiParser.getEmail(xmlDom);
        regionApiLead.website = RegionApiParser.getWebsite(xmlDom);
        regionApiLead.suspendingActivityDate = RegionApiParser.getSuspendingActivityDate(xmlDom);
        regionApiLead.resumingActivityDate = RegionApiParser.getResumingActivityDate(xmlDom);
//        regionApiLead.legalForm = RegionApiParser.getLegalForm(xmlDom);

        return regionApiLead;
    }

    public static List<RegionApiCompany> setCompanyFields(Dom.XmlNode xmlDom){
        List<RegionApiCompany> regionApiCompanies = new List<RegionApiCompany>();

        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            RegionApiCompany regionApiCompany = new RegionApiCompany();
            regionApiCompany.errorMessage = RegionApiParser.getErrorMessage(companyInfoElement);
            if (regionApiCompany.errorMessage != null && regionApiCompany.errorMessage != '') {
                regionApiCompanies.add(regionApiCompany);
                continue;
            }
            regionApiCompany.region = RegionApiParser.getRegionId(companyInfoElement);
            regionApiCompany.type = RegionApiParser.getType(companyInfoElement);
            regionApiCompany.silosId = RegionApiParser.getSilosId(companyInfoElement);
            regionApiCompany.taxId = RegionApiParser.getTaxId(companyInfoElement);

            regionApiCompanies.add(regionApiCompany);
        }
        return regionApiCompanies;
    }

    public static String setReportName(RegionApiCompany regionApiCompany){
        if (regionApiCompany.type == 'F' && regionApiCompany.silosId == '1') {
            return 'BIR11OsFizycznaDzialalnoscCeidg';
        } else if (regionApiCompany.type == 'F' && regionApiCompany.silosId == '2'){
            return 'BIR11OsFizycznaDzialalnoscRolnicza';
        } else if (regionApiCompany.type == 'F' && regionApiCompany.silosId == '3'){
            return 'BIR11OsFizycznaDzialalnoscPozostala';
        } else if (regionApiCompany.type == 'F' && regionApiCompany.silosId == '4'){
            return 'BIR11OsFizycznaDzialalnoscSkreslonaDo20141108';
        }
        if (regionApiCompany.type == 'P') {
            return 'BIR11OsPrawna';
        }
        return null;
    }

    public static String leadFieldsForLog(Lead lead, String oldAndNewLeadFields) {
        oldAndNewLeadFields =
                'Country - ' + lead.Country + ';\n' +
                'TaxId - ' + lead.Steuernummer__c + ';\n' +
                'Trade Register Nr. - ' + lead.Handelsregister__c + ';\n' +
                'Street - ' + lead.Street + ';\n' +
                'State - ' + lead.State + ';\n' +
                'City - ' + lead.City + ';\n' +
                'Phone - ' + lead.Phone + ';\n' +
                'Email - ' + lead.Email + ';\n' +
                'Website - ' + lead.Website + ';\n' +
                'Name - ' + lead.Company + ';\n' +
                'Postal Code - ' + lead.PostalCode + ';\n' +
//                'Legal Form - ' + lead.Gesellschaftsform__c + ';\n' +
//                'Provided activity PKD - ' + lead.Provided_activity_PKD__c + ';\n' +
                'Year Of Foundation - ' + lead.Gruendungsjahr__c + ';\n' +
                'Date Of Foundation - ' + lead.Date_of_foundation__c + ';\n' +
                'Resuming Activity Date - ' + lead.Resuming_Activity_Date__c + ';\n' +
                'Suspending Activity Date - ' + lead.Suspending_Activity_Date__c + ';\n';

        return oldAndNewLeadFields;
    }
    
    public static Lead setLeadFields(Lead lead, RegionApiCompanyFullReport regionApiCompanyFullReport){
        if (String.isBlank(lead.Country) && !String.isBlank(regionApiCompanyFullReport.country)){
            lead.Country = regionApiCompanyFullReport.country;
            newLeadFields += 'Api Country - ' + lead.Country + ';\n';
        }
        if (String.isBlank(lead.Steuernummer__c) && !String.isBlank(regionApiCompanyFullReport.taxId)){
            lead.Steuernummer__c = regionApiCompanyFullReport.taxId;
            newLeadFields += 'Api TaxId - ' + lead.Steuernummer__c + ';\n';
        }
        if (String.isBlank(lead.Handelsregister__c) && !String.isBlank(regionApiCompanyFullReport.tradeRegisterNr)) {
            lead.Handelsregister__c = regionApiCompanyFullReport.tradeRegisterNr;
            newLeadFields += 'Api Trade Register Nr. - ' + lead.Handelsregister__c + ';\n';
        }
        if (String.isBlank(lead.Street) && !String.isBlank(regionApiCompanyFullReport.street)) {
            lead.Street = regionApiCompanyFullReport.street;
            newLeadFields += 'Api Street - ' + lead.Street + ';\n';
        }
        if (String.isBlank(lead.State) && !String.isBlank(regionApiCompanyFullReport.state)) {
            lead.State = regionApiCompanyFullReport.state;
            newLeadFields += 'Api State - ' + lead.State + ';\n';
        }
        if (String.isBlank(lead.City) && !String.isBlank(regionApiCompanyFullReport.city)) {
            lead.City = regionApiCompanyFullReport.city;
            newLeadFields += 'Api City - ' + lead.City + ';\n';
        }
        if (String.isBlank(lead.Phone) && !String.isBlank(regionApiCompanyFullReport.phone)) {
            lead.Phone = regionApiCompanyFullReport.phone;
            newLeadFields += 'Api Phone - ' + lead.Phone + ';\n';
        }
        if (String.isBlank(lead.Email) && !String.isBlank(regionApiCompanyFullReport.email)) {
            lead.Email = regionApiCompanyFullReport.email;
            newLeadFields += 'Api Email - ' + lead.Email + ';\n';
        }
        if (String.isBlank(lead.Website) && !String.isBlank(regionApiCompanyFullReport.website)) {
            lead.Website = regionApiCompanyFullReport.website;
            newLeadFields += 'Api Website - ' + lead.Website + ';\n';
        }
        if (String.isBlank(lead.Company) && !String.isBlank(regionApiCompanyFullReport.name)) {
            lead.Company = regionApiCompanyFullReport.name;
            newLeadFields += 'Api Name - ' + lead.Company + ';\n';
        }
        if (String.isBlank(lead.PostalCode) && !String.isBlank(regionApiCompanyFullReport.postalCode)) {
            lead.PostalCode = regionApiCompanyFullReport.postalCode;
            newLeadFields += 'Api Postal Code - ' + lead.PostalCode + ';\n';
        }
        if (String.isBlank(lead.Gruendungsjahr__c) && !String.isBlank(regionApiCompanyFullReport.yearOfFoundation)) {
            lead.Gruendungsjahr__c = regionApiCompanyFullReport.yearOfFoundation;
            newLeadFields += 'Api Year Of Foundation - ' + lead.Gruendungsjahr__c + ';\n';
        }
        if (lead.Date_of_foundation__c == null && !String.isBlank(regionApiCompanyFullReport.dateOfFoundation)) {
            lead.Date_of_foundation__c = Date.valueOf(regionApiCompanyFullReport.dateOfFoundation);
            newLeadFields += 'Api Date Of Foundation - ' + lead.Date_of_foundation__c + ';\n';
        }
        if (lead.Resuming_Activity_Date__c == null && !String.isBlank(regionApiCompanyFullReport.resumingActivityDate)) {
            lead.Resuming_Activity_Date__c = Date.valueOf(regionApiCompanyFullReport.resumingActivityDate);
            newLeadFields += 'Api Resuming Activity Date - ' + lead.Resuming_Activity_Date__c + ';\n';
        }
        if (lead.Suspending_Activity_Date__c == null && !String.isBlank(regionApiCompanyFullReport.suspendingActivityDate)) {
            lead.Suspending_Activity_Date__c = Date.valueOf(regionApiCompanyFullReport.suspendingActivityDate);
            newLeadFields += 'Api Suspending Activity Date - ' + lead.Suspending_Activity_Date__c + ';\n';
        }
//        if (String.isBlank(lead.Provided_activity_PKD__c) && !String.isBlank(regionApiCompanyFullReport.industry)) {
//            lead.Provided_activity_PKD__c = regionApiCompanyFullReport.industry;
//            newLeadFields += 'Api Provided activity PKD - ' + lead.Provided_activity_PKD__c + ';\n';
//        }
//        if (String.isBlank(lead.Gesellschaftsform__c) && !String.isBlank(regionApiCompanyFullReport.legalForm)) {
//            lead.Gesellschaftsform__c = regionApiCompanyFullReport.legalForm;
//            newLeadFields += 'Api Legal Form - ' + lead.Gesellschaftsform__c + ';\n';
//        }
        if (lead.Date_of_request_to_RegionApi__c == null) {
            lead.Date_of_request_to_RegionApi__c = System.today();
        }
        if (String.isBlank(newLeadFields)) {
            newLeadFields = 'No one field was updated';
        }
        return lead;
    }
}