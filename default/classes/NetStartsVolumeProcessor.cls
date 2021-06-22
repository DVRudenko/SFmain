public class NetStartsVolumeProcessor {

    /*******************************************************************************
    *  Name            : getReportApi()
    *  Summary         : shaping NetStartsVolumeReportApi
    *  CreatedDate     : 5/03/2018
    *  Parameters      : String businessType - type business(Europe, EE),
    *                    String reportType - report type(Onboarding)
    *  Returns         : NetStartsVolumeReportApi - report api
    ******************************************************************************/
    public NetStartsVolumeReportApi getReportApi(NetStartVolumeReportSettings.BusinessType businessType,
            NetStartVolumeReportSettings.ReportType reportType,
            List<String> mailUsersList) {

        NetStartVolumeReportSettings reportSettings = new NetStartVolumeReportSettings(businessType, reportType);

        NetStartsVolumeFilterGenerator filterGenerator = new NetStartsVolumeFilterGenerator(
                reportSettings.orderedSelectorLabels,
                reportSettings.labelAndSelectorNameBundle,
                reportSettings.selectorNameToDataGenerator,
                'NetStartsVolumeReportEE:selectOutput',
                reportSettings.defaultFilters,
                reportSettings.userRoleMap,
                reportSettings.userMap
        );

        NetStartVolumeDataProcessingInterface dataProcessing = new NetStartsVolumeDataProcessing(
                NetStartsVolumeFilterGenerator.resolverFilters(new Map<String, List<Object>>(), reportSettings.defaultFilters),
                reportSettings.userRoleMap,
                reportSettings.userMap,
                reportSettings.netStartsWeeksCount,
                reportSettings.volumeWeeksCount,
                reportSettings.weeksCount
        );

        return new NetStartsVolumeReportApi(reportSettings, filterGenerator, dataProcessing, mailUsersList);
    }


    public class NetStartsVolumeReportApi {
        private NetStartVolumeReportSettings reportSettings;
        private NetStartsVolumeFilterGenerator filterGenerator;
        private NetStartVolumeDataProcessingInterface dataProcessing;
        private List<String> mailUsersList;
        private Integer defaultPageSize = 100;


        public Map<String, Object> totalMap;
        public String totalRow { get; set; }
        public String jobStatus { get; set; }
        public Integer jobTimeOut { get; private set; }
        public String currentUserLocale { get; private set; }

        public String recordsJson {
            get {
                return Json.serialize(this.dataProcessing.processingData(this.setCon.getRecords()));
            }
            set;
        }

        public String selectTable { get; private set; }

        public ApexPages.StandardSetController setCon {
            get {
                if (setCon == null) {
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(this.dataProcessing.getSoqlRequest()));
                    setCon.setPageSize(defaultPageSize);
                }
                return setCon;
            }
            private set;
        }

        public Boolean hasNext {
            get {
                return setCon.getHasNext();
            }
        }

        public Boolean hasPrevious {
            get {
                return setCon.getHasPrevious();
            }
        }

        public String labelTranslateJson {
            get {
                return Json.serialize(this.reportSettings.translateLabels);
            }
        }

        public String reportFieldsJson {
            get {
                return Json.serialize(this.reportSettings.reportFields);
            }
        }

        public Integer page {
            get {
                return this.setCon.getPageNumber();
            }
        }

        public Integer pageSize {
            get {
                return this.setCon.getPageSize();
            }
        }

        public Integer totalPages {
            get {
                return this.setCon.getResultSize();
            }
        }

        public NetStartsVolumeReportApi(NetStartVolumeReportSettings reportSettings,
                NetStartsVolumeFilterGenerator filterGenerator,
                NetStartVolumeDataProcessingInterface dataProcessing,
                List<String> mailUsersList) {
            this.dataProcessing = dataProcessing;
            this.reportSettings = reportSettings;
            this.totalMap = this.dataProcessing.initTotalData();
            this.totalRow = Json.serialize(this.totalMap);
            this.selectTable = filterGenerator.getSelectorTable();
            this.mailUsersList = mailUsersList;
            this.jobTimeOut = 0;
            this.currentUserLocale = UserInfo.getLocale();
        }

        /*******************************************************************************
        *  Name            : refreshContent()
        *  Summary         : update filters in processing component and StandardSetController pagination
        *  CreatedDate     : 5/03/2018
        *  Parameters      : String filterString - filters in json format
        *  Returns         : void
        ******************************************************************************/
        public void refreshContent(String filterString) {
            Map<String, Object> filters = NetStartsVolumeFilterGenerator.jsonConverter(filterString);
            Map<String, List<Object>> parameters = NetStartsVolumeFilterGenerator.convertSearchParameters(filters);

            String newFilters = NetStartsVolumeFilterGenerator.resolverFilters(parameters, this.reportSettings.defaultFilters);
            this.dataProcessing.updateFilters(newFilters);

            this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(this.dataProcessing.getSoqlRequest()));
            this.setCon.setPageSize(defaultPageSize);

            this.totalMap = this.dataProcessing.initTotalData();
            this.totalRow = Json.serialize(this.totalMap);
        }

        // Deprecated method
        /*******************************************************************************
        *  Name            : getHtmlDataTable()
        *  Summary         : return html table with report data
        *  CreatedDate     : 5/03/2018
        *  Parameters      : -
        *  Returns         : String
        ******************************************************************************/
        public String getHtmlDataTable() {
            OnboardingReportHtmlGenerator htmlGenerator = NetStartsVolumeHtmlGeneratorFactory.create(
                    NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.HTML,
                    new List<Object>{
                            this.dataProcessing.processingData(this.setCon.getRecords()),
                            this.dataProcessing.initTotalData(),
                            this.reportSettings.reportFields,
                            'NetStartsVolumeReportEE:myform:pg:pgs:output'
                    }
            );
            return htmlGenerator.generateReportHtmlTemplate();
        }

        /*******************************************************************************
       *  Name            : sendExcelReportToEmail()
       *  Summary         : convert onboarding report to excel format. Email onboarding report.
       *  CreatedDate     : 5/03/2018
       *  Parameters      : -
       *  Returns         : -
       ******************************************************************************/
        public void sendExcelReportToEmail() {

            OnboardingReportHtmlGenerator htmlGenerator = NetStartsVolumeHtmlGeneratorFactory.create(
                    NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.EXCEL,
                    new List<Object>{
                            this.reportSettings.reportFields, this.reportSettings.translateLabels
                    }
            );

            IConversionReport report = new NetStartsVolumeReportEmailSend(
                    this.dataProcessing,
                    htmlGenerator,
                    this.totalMap,
                    'report.xls',
                    mailUsersList
            );

            // If report contains less 2200 records, it generate in current context. Else use Queueable.
            if (totalPages <= 2200) {
                List<Messaging.SingleEmailMessage> listEmails = report.getMails();
                if (listEmails != null && !listEmails.isEmpty()) {
                    Messaging.sendEmail(listEmails);
                }

                this.jobTimeOut = 0;
            } else {
                Integer jobCount = Limits.getQueueableJobs();

                if (jobCount < 10) {

                    Id jobId = System.enqueueJob(new EmailReportQueueable(report));

                    this.jobTimeOut = jobCount + 1;
                } else {

                }
            }
        }

        /*******************************************************************************
        *  Name            : sendCSVReportToEmail()
        *  Summary         : convert onboarding report to csv format. Email onboarding report.
        *  CreatedDate     : 5/03/2018
        *  Parameters      : -
        *  Returns         : -
        ******************************************************************************/
        public void sendCSVReportToEmail() {
            OnboardingReportHtmlGenerator htmlGenerator = NetStartsVolumeHtmlGeneratorFactory.create(
                    NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.CSV,
                    new List<Object>{
                            this.reportSettings.reportFields, this.reportSettings.translateLabels
                    }
            );

            IConversionReport report = new NetStartsVolumeReportEmailSend(
                    this.dataProcessing,
                    htmlGenerator,
                    this.totalMap,
                    'report.csv',
                    mailUsersList
            );

            Integer jobCount = Limits.getQueueableJobs();

            if (jobCount < 10) {
                Id jobId = System.enqueueJob(new EmailReportQueueable(report));
                this.jobTimeOut = jobCount + 1;
            } else {

            }
        }

        public void setDefaultParametersToReportSettings(String params, List<Object> values) {
            this.reportSettings.defaultFilters.put(params, values);
        }

        ////*** Pagination ***////

        public void next() {
            this.setCon.next();
        }

        public void last() {
            this.setCon.last();
        }

        public void previous() {
            this.setCon.previous();
        }

        public void first() {
            this.setCon.first();
        }
    }

    public class NetStartsVolumeReportEmailSend implements IConversionReport {
        private NetStartVolumeDataProcessingInterface dataProcessing;
        private Map<String, Object> totalRow;
        private List<sObject> dataList;
        private OnboardingReportHtmlGenerator htmlGenerator;
        private String fileName;
        private List<String> userEmailsList;

        public NetStartsVolumeReportEmailSend(NetStartVolumeDataProcessingInterface dataProcessing,
                OnboardingReportHtmlGenerator htmlGenerator,
                Map<String, Object> totalRow,
                String fileName,
                List<String> userEmailsList) {
            this.dataProcessing = dataProcessing;
            this.htmlGenerator = htmlGenerator;
            this.totalRow = totalRow;
            this.fileName = fileName;
            this.userEmailsList = userEmailsList;
        }

        public Blob reportGenerate() {
            ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(this.dataProcessing.getSoqlRequest()));
            setCon.setPageSize(200);

            this.htmlGenerator.addRows(this.dataProcessing.processingData(setCon.getRecords()));

            while (setCon.getHasNext()) {
                setCon.next();
                this.htmlGenerator.addRows(this.dataProcessing.processingData(setCon.getRecords()));
            }

            this.htmlGenerator.addRows(new List<Map<String, Object>>{
                    this.totalRow
            });
            return Blob.valueOf(this.htmlGenerator.generateReportHtmlTemplate());
        }

        public List<Messaging.SingleEmailMessage> getMails() {
            List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
            try {

                List<OrgWideEmailAddress> orgEmails = [
                        SELECT Id
                        FROM OrgWideEmailAddress
                        WHERE Address = 'no-reply@fleetcor.eu'
                        LIMIT 1
                ];

                Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{
                        generateReportEmailFileAttachment(this.fileName, reportGenerate())
                };

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Onboarding Report');
                mail.setToAddresses(userEmailsList);
                mail.setPlainTextBody('See attachment');
                mail.setFileAttachments(fileAttachments);

                if (!orgEmails.isEmpty()) {
                    mail.setOrgWideEmailAddressId(orgEmails.get(0).id);
                }

                listToSend.add(mail);
            } catch (Exception e) {
                ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
            }
            return listToSend;
        }

        public String getFileType() {
            return '';
        }

        private Messaging.EmailFileAttachment generateReportEmailFileAttachment(String reportName, Blob reportBody) {
            Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
            fileAttachment.setBody(reportBody);
            fileAttachment.setContentType('application/vnd.ms-excel');
            fileAttachment.setFileName(reportName);
            fileAttachment.setInline(false);
            return fileAttachment;
        }
    }
}