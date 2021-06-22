global class CreditFactoryPdfSchedule implements Schedulable {
    public String reportId;
    public String parentReportId;
	public String opportunityId;
    public Blob responseBody;
    public String country;

    
    /*******************************************************************************
	*  Summary         : constructor    
	*  CreatedDate     : 11/04/2019
    *  Parameters      : reportId - report Id,
                         parentReportId - parent report Id
                         opportunityId - Opportunity Id,
                         krdResponseBody - response from krd service to save,
                         country - country
    *  Returns         : -
	******************************************************************************/
	public CreditFactoryPdfSchedule(String reportId, String parentReportId, String opportunityId,
                                    Blob responseBody, String country) {
        this.reportId = reportId;
        this.parentReportId = parentReportId;
		this.opportunityId = opportunityId;
        this.responseBody = responseBody;
        this.country = country;
	}
    
    
    /*******************************************************************************
	*  Summary         : get pdf attachment
	*  CreatedDate     : 11/04/2019
	*  Parameters      : sc - variable to track schedulable job
	*  Returns         : void
	******************************************************************************/
    global void execute(SchedulableContext sc) {
        sendPdfRequest(this.reportId, this.parentReportId, this.opportunityId, this.responseBody, this.country);
        deleteExecutedJobs();
    }


    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 11/04/2019
    *  Parameters      : reportId - report Id,
                         parentReportId - parent report Id
                         opportunityId - Opportunity Id,
                         krdResponseBody - response from krd service to save,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    @future(callout = true)
    public static void sendPdfRequest(String reportId, String parentReportId, String opportunityId,
                                      Blob responseBody, String country) {
        try {
            List<Opportunity> opportunitiesList = [
                    SELECT Account.BillingCountryCode
                    FROM Opportunity
                    WHERE Id = :opportunityId
            ];

            if (! opportunitiesList.isEmpty()) {
                if (country == 'Poland') {
                    sendPdfRequestPL(reportId, opportunityId, responseBody);
                }
                else if (country == 'Germany') {
                    sendPdfRequestDE(reportId, opportunityId);
                }
                else if (country == 'Netherlands') {
                    sendPdfRequestsNL(reportId, parentReportId, opportunityId);
                }
                else if (country == 'Belgium-NL' || country == 'Belgium-FR') {
                    sendPdfRequestsBE(reportId, opportunityId, country);
                }
                else if (country == 'Slovakia') {
                    sendPdfRequestSK(reportId, opportunityId, country);
                }
                else if (country == 'Czech Republic') {
                    sendPdfRequestCZ(reportId, opportunityId, country);
                }
                else if (country == 'Hungary') {
                    sendPdfRequestsHU(reportId, opportunityId);
                }
                else if (country == 'France') {
                    sendPdfRequestsFR(reportId, opportunityId, country);
                }
                else if (country == 'Switzerland-DE' || country == 'Switzerland-FR' || country == 'Switzerland-IT') {
                    sendPdfRequestsCH(opportunityId, responseBody, country);
                }
                else if (country == 'Austria') {
                    sendPdfRequestsAT(opportunityId, responseBody, country);
                }
                else if (country == 'Luxembourg') {
                    sendPdfRequestsLU(opportunityId, responseBody, country);
                }
            }
        } catch (Exception e) {
            if (! e.getMessage().contains('ENTITY_IS_DELETED')) {
                rescheduleRequest(reportId, parentReportId, opportunityId, responseBody, country);
                ExceptionLogger.sendException(String.valueOf(e.getMessage()) + '\nOpportunityId: ' + opportunityId, String.valueOf(e.getStackTraceString()));
            }
        }
    }


    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 11/08/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         opportunityId - Opportunity Id,
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestPL(String reportId, String opportunityId, Blob krdResponseBody) {
        List<Attachment> attachmentsList = new List<Attachment>();
        if (reportId != null) {
            CreditSystem__c creditSystem = CreditSystem__c.getInstance('Crif');
            HttpRequest request = CreditFactoryWebCrif.generatePdfRequest(creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, reportId);
            Http h = new Http();
            HttpResponse response = h.send(request);
            Blob responseBody = response.getBodyAsBlob();
            Attachment crifReport = new Attachment(
                ParentId = opportunityId,
                Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap('Poland').get('Report'),
                Body = responseBody);
            attachmentsList.add(crifReport);
        }

        if (krdResponseBody != null) {
            Attachment krdReport = new Attachment();
            krdReport.ParentId = opportunityId;
            krdReport.Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap('Poland').get('KRD');
            krdReport.Body = krdResponseBody;
            attachmentsList.add(krdReport);
        }

        insert attachmentsList;
    }


    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 11/08/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         opportunityId - Opportunity Id,
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestDE(String reportId, String opportunityId) {
        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Schufa');
        Http http = new Http();
        HttpRequest authRequest = CreditFactoryWebSchufa2.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
        HttpResponse authResponse = http.send(authRequest);

        SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());
        HttpRequest pdfReportRequest = CreditFactoryWebSchufa2.generatePdfReportRequest(authEntity.accessToken, creditSystem.Endpoint__c, reportId);
        HttpResponse pdfReportResponse = http.send(pdfReportRequest);

        SchufaEntity pdfReportEntity = SchufaEntity.parse(pdfReportResponse.getBody());
        Blob pdfResponseBody;
        if (pdfReportResponse.getStatusCode() == 200) {
            pdfResponseBody = EncodingUtil.base64Decode(pdfReportEntity.documentBytes);
        }

        if (pdfResponseBody != null) {
            Attachment pdfReport = new Attachment();
            pdfReport.ParentId = opportunityId;
            pdfReport.Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap('Germany').get('Report');
            pdfReport.Body = pdfResponseBody;
            insert pdfReport;
        }
    }


    /*******************************************************************************
    *  Summary         : send pdf request for current and parent company
    *  CreatedDate     : 08/09/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         parentReportId - id of parent pdf report,
                         opportunityId - Opportunity Id,
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestsNL(String reportId, String parentReportId, String opportunityId) {
        List<Attachment> attachmentsList = new List<Attachment>();
        attachmentsList.add(sendPdfRequestCreditsafe(reportId, 'general', opportunityId, 'Netherlands'));
        if (parentReportId != null) {
            attachmentsList.add(sendPdfRequestCreditsafe(parentReportId, 'parent', opportunityId, 'Netherlands'));
        }

        insert attachmentsList;
    }


    /*******************************************************************************
    *  Summary         : send pdf request for current and parent company
    *  CreatedDate     : 25/09/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         parentReportId - id of parent pdf report,
                         opportunityId - Opportunity Id,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestsBE(String reportId, String opportunityId, String country) {
        Attachment attachment = sendPdfRequestCreditsafe(reportId, 'general', opportunityId, country);
        insert attachment;
    }


    /*******************************************************************************
    *  Summary         : send pdf request for current and parent company
    *  CreatedDate     : 03/11/2020 by Ivan Kulinkovich
    *  Parameters      : reportId - id of pdf report,
                         parentReportId - id of parent pdf report,
                         opportunityId - Opportunity Id,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestsFR(String reportId, String opportunityId, String country) {
        Attachment attachment = sendPdfRequestCreditsafe(reportId, 'general', opportunityId, country);
        insert attachment;
    }


    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 08/09/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         parentReportId - id of parent pdf report,
                         opportunityId - Opportunity Id,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static Attachment sendPdfRequestCreditsafe(String reportId, String reportType, String opportunityId, String country) {
        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Creditsafe');
        Http http = new Http();
        HttpRequest authRequest = CreditFactoryWebCreditsafe.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
        HttpResponse authResponse = http.send(authRequest);
        CreditsafeEntity authEntity = CreditsafeEntity.parse(authResponse.getBody());
        HttpRequest pdfReportRequest = CreditSafeWebservice.generatePDFReportRequest(authEntity.token, creditSystem.Endpoint__c, reportId);
        HttpResponse pdfReportResponse = http.send(pdfReportRequest);

        Blob pdfResponseBody = pdfReportResponse.getBodyAsBlob();
        Attachment pdfReport = new Attachment();
        pdfReport.ParentId = opportunityId;
        if (reportType == 'parent') {
            pdfReport.Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).get('ParentReport');
        }
        else {
            pdfReport.Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).get('Report');
        }

        pdfReport.Body = pdfResponseBody;

        return pdfReport;
    }


    /*******************************************************************************
    *  Summary         : send pdf request for current and parent company
    *  CreatedDate     : 07/10/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         opportunityId - Opportunity Id,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestSK(String reportId, String opportunityId, String country) {
        Attachment attachment = sendPdfRequestCribis(reportId, opportunityId, country);
        insert attachment;
    }


    /*******************************************************************************
    *  Summary         : send pdf request for current and parent company
    *  CreatedDate     : 28/10/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         opportunityId - Opportunity Id,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestCZ(String reportId, String opportunityId, String country) {
        Attachment attachment = sendPdfRequestCribis(reportId, opportunityId, country);
        insert attachment;
    }


    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 08/09/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         opportunityId - Opportunity Id,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static Attachment sendPdfRequestCribis(String reportId, String opportunityId, String country) {
        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Cribis');
        Http http = new Http();
        HttpRequest pdfReportRequest = CreditFactoryWebCribis.generatePdfRequest(creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, reportId);
        HttpResponse pdfReportResponse = http.send(pdfReportRequest);
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(pdfReportResponse.getBody());
        Dom.XmlNode xmlDom = domDoc.getRootElement();
        String pdfBody = CreditFactoryWebCribis.returnPdfReportBody(xmlDom);
        Attachment attachemnt = new Attachment();
        attachemnt.Body = EncodingUtil.base64Decode(pdfBody);
        attachemnt.ParentId = opportunityId;
        attachemnt.Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).get('Report');

        return attachemnt;
    }


    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 11/08/2020 by Anton Buzak
    *  Parameters      : reportId - id of pdf report,
                         opportunityId - Opportunity Id,
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestsHU(String reportId, String opportunityId) {
        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Coface');
        HttpRequest requestPdf = CreditFactoryWebCoface.generatePdfReportRequest(
            creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, reportId);
        Http http = new Http();
        HttpResponse response = http.send(requestPdf);
        Blob attachmentBody = CreditFactoryWebCoface.getBinaryAttachment(response.getBody());
        if (attachmentBody != null) {
            Attachment pdfReport = new Attachment(
                    ParentId = opportunityId,
                    Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap('Hungary').get('Report'),
                    Body = attachmentBody);
            insert pdfReport;
        }
    }


    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 30/11/2020 by Ivan Kulinkovich
    *  Parameters      : opportunityId - Opportunity Id,
                         responseBody - attachment's body
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestsCH(String opportunityId, Blob responseBody, String country) {
        if (responseBody != null) {
            Attachment attachment = new Attachment(
                    ParentId = opportunityId,
                    Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).get('Report'),
                    Body = responseBody);
            insert attachment;
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 10/12/2020 by Ivan Kulinkovich
    *  Parameters      : opportunityId - Opportunity Id,
                         responseBody - attachment's body
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestsAT(String opportunityId, Blob responseBody, String country) {
        if (responseBody != null) {
            Attachment attachment = new Attachment(
                    ParentId = opportunityId,
                    Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).get('Report'),
                    Body = responseBody);
            insert attachment;
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : send pdf request
    *  CreatedDate     : 17/12/2020 by Ivan Kulinkovich
    *  Parameters      : opportunityId - Opportunity Id,
                         responseBody - attachment's body
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void sendPdfRequestsLU(String opportunityId, Blob responseBody, String country) {
        if (responseBody != null) {
            Attachment attachment = new Attachment(
                    ParentId = opportunityId,
                    Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).get('Report'),
                    Body = responseBody);
            insert attachment;
        }
    }


    /*******************************************************************************
    *  Summary         : delete scheduled jobs that already executed
    *  CreatedDate     : 11/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteExecutedJobs() {
    	List<CronTrigger> jobsList = [
                SELECT Id 
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE 'Credit Factory Pdf Report%' AND NextFireTime = null
                LIMIT 10];
        if (! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Reschedule failed request again    
    *  CreatedDate     : 11/04/2019
    *  ModifiedDate    : -
    *  Parameters      : reportId - report Id,
                         parentReportId - parent report Id
                         opportunityId - Opportunity Id,
                         krdResponseBody - response from krd service to save,
                         country - country
    *  Returns         : -
    ******************************************************************************/
    private static void rescheduleRequest(String reportId, String parentReportId, String opportunityId,
                                          Blob responseBody, String country) {
        String schedule = Datetime.now().addHours(1).second() + ' ' + Datetime.now().addHours(1).minute() + ' ' + Datetime.now().addHours(1).hour() + ' ' 
            + Datetime.now().addHours(1).day() + ' ' + Datetime.now().addHours(1).month() + ' ? ' + Datetime.now().addHours(1).year();
        String scheduleName = 'Credit Factory Pdf Report ' + Datetime.now().addHours(1).minute() + Datetime.now().addHours(1).second() + 
            Datetime.now().addHours(1).millisecond();
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(reportId, parentReportId, opportunityId, responseBody, country);
        System.schedule(scheduleName, schedule, pdfSchedule);
    }
}