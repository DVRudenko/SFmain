public class ConversionReportPPRImpl implements IConversionReport {

    private Date nowDate;
    private String fileType;
    private String reportType;
    private String mode;
    private final Set<String> typesOfFiles = new Set<String>{
            'xls'
    };
    private final Set<String> typesOfReport = new Set<String>{
            'current',
            'final'
    };

    public ConversionReportPPRImpl(Date nowDate, String fileType, String reportType) {
        if(nowDate != null) {
            this.nowDate = nowDate;
        } else {
            this.nowDate = System.Today();
        }

        if (typesOfFiles.contains(fileType)) {
            this.fileType = fileType;
        } else {
            this.fileType = 'xls';
        }

        if (typesOfReport.contains(reportType)) {
            this.reportType = reportType;
        } else {
            this.reportType = 'current';
        }

        this.mode = 'send';
    }

    public String getFileType() {
        return this.fileType;
    }

    /*******************************************************************************
    *  Name            : getMails()
    *  Summary         : execute runSendingEmails
    *  CreatedDate     : 13/06/2018
    *  Parameters      : -
    *  Returns         : List<Messaging.SingleEmailMessage>
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> getMails() {
        runSendingEmails();
        return new List<Messaging.SingleEmailMessage>();
    }

    /*******************************************************************************
    *  Name            : runSendingEmails()
    *  Summary         : sending emails
    *  CreatedDate     : 16/1/2018
    *  Parameters      : -
    *  Returns         : List<Messaging.SingleEmailMessage>
    ******************************************************************************/
    public void runSendingEmails() {
        try {
            Map<Id, List<String>> reportRoleMap = new Map<Id, List<String>>();
            Map<String, Set<Id>> userReportMap = new Map<String, Set<Id>>();

            List<Fleetcor_Calendar_Month__c> periods  = getReportPeriods(this.nowDate);
            System.debug('Period ' + periods);

            if(periods != null && periods.size() == 2) {
                Set<String> keyUsers = new Set<String>();
                for (RU_Conversion_Report_Email_User__c userName : [SELECT Name FROM RU_Conversion_Report_Email_User__c]) {
                    keyUsers.add(userName.name);
                }

                for (User user : [SELECT Id, Email, UserRoleId FROM User WHERE Name IN :keyUsers]) {
                    userReportMap.put(user.Email, GlobalUtils.getSubordinateRoles(user.UserRoleId));
                }

                for (UserRole userRole : [SELECT Id FROM UserRole WHERE Name LIKE '%Bryansk PSO%' OR Name LIKE '%Bryansk Partner%' ORDER BY Name]) {
                    List<String> tempList = new List<String>();
                    for (String userEmail : userReportMap.keySet()) {
                        if (userReportMap.get(userEmail).contains(userRole.Id)) {
                            tempList.add(userEmail);
                        }
                    }
                    reportRoleMap.put(userRole.Id, tempList);
                }

                Map<Id, UserRole> roleNameMap = new Map<Id, UserRole>([
                        SELECT Name
                        FROM UserRole
                        WHERE Id IN :reportRoleMap.keySet()
                ]);

                List<OrgWideEmailAddress> orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];

                for(Id roleId : reportRoleMap.keySet()) {
                    List<String> usersToSend = reportRoleMap.get(roleId);

                    if( ! usersToSend.isEmpty() ) {
                        generateConversionReport(roleId,
                                roleNameMap.get(roleId).Name,
                                usersToSend,
                                periods.get(0).End_Date__c.format(),
                                new List<String> { periods.get(0).Start_Date__c.format(), periods.get(1).Start_Date__c.format() },
                                this.reportType,
                                this.mode);
                    }
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : generateBlobReport()
    *  Summary         : generate blob for report
    *  CreatedDate     : 16/1/2018
    *  Parameters      : Id roleId - role Id, String monthReport - month period, String periodFC - Fleetcor period
    *  Returns         : Blob
    ******************************************************************************/
    public static Blob generateBlobReport(Id roleId, String monthReport, String periodFC, String reportType, String mode) {
        PageReference ref = new PageReference('/apex/ConversionReportPPR');
        ref.getParameters().put('salesGroup', roleId);
        ref.getParameters().put('monthReport', monthReport);
        ref.getParameters().put('periodFC', periodFC);
        ref.getParameters().put('reportType', reportType);
        ref.getParameters().put('mode', mode);
        return ref.getContent();
    }

    /*******************************************************************************
    *  Name            : generateReportEmailFileAttachment()
    *  Summary         : return attachment file
    *  CreatedDate     : 16/1/2018
    *  Parameters      : String reportName - report name, Blob reportBody - blob for attached
    *  Returns         : Messaging.EmailFileAttachment
    ******************************************************************************/
    private static Messaging.EmailFileAttachment generateReportEmailFileAttachment(String reportName, Blob reportBody) {
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        fileAttachment.setBody(reportBody);
        fileAttachment.setContentType('application/vnd.ms-excel');
        fileAttachment.setFileName(reportName);
        fileAttachment.setInline(false);
        return fileAttachment;
    }

    /*******************************************************************************
   *  Name            : getReportPeriods()
   *  Summary         : return previous and current FleetCor periods if current period is ended
   *  CreatedDate     : 16/1/2018
   *  Parameters      : Date currentDate - date now
   *  Returns         : List<Fleetcor_Calendar_Month__c>
   ******************************************************************************/
    public static List<Fleetcor_Calendar_Month__c> getReportPeriods(Date currentDate) {
        List<Fleetcor_Calendar_Month__c> periodForCurrentReportList = new List<Fleetcor_Calendar_Month__c>();

        List<Fleetcor_Calendar_Month__c> periodList =([
                SELECT Start_Date__c, End_Date__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Start_Date__c = :currentDate
        ]);

        if ( ! periodList.isEmpty() ) {
            Fleetcor_Calendar_Month__c period = periodList.get(0);

            Date newEndDate = period.Start_Date__c.addDays(1);
            System.debug('newEndDate: ' + newEndDate);

            periodForCurrentReportList = ([
                    SELECT Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c
                    WHERE End_Date__c <= :newEndDate
                    ORDER BY Start_Date__c DESC
                    LIMIT 2
            ]);
        }
        return periodForCurrentReportList;
    }

    @future(callout=true)
    public static void generateConversionReport(Id roleId, String roleName, List<String> emailsToSend, String monthReport, List<String> periodFC, String reportType, String mode) {
        Blob reportBlobCurrentMonth;
        Blob reportBlobPreviewMonth;
        String reportNameCurrentMonth;
        String reportNamePreviewMonth;
        if (roleId != null && ! emailsToSend.isEmpty()) {
            if(Test.isRunningTest()) {
                reportBlobCurrentMonth = Blob.valueOf('Test1');
                reportNameCurrentMonth = 'Test1';

                reportBlobPreviewMonth = Blob.valueOf('Test2');
                reportNamePreviewMonth = 'Test2';
            } else {
                reportBlobCurrentMonth = generateBlobReport(roleId, monthReport, periodFC.get(0), reportType, mode);
                reportNameCurrentMonth = roleName + ' (' + periodFC.get(0) + ' ' + monthReport + ')_current.xls';

                reportBlobPreviewMonth = generateBlobReport(roleId, monthReport, periodFC.get(1), reportType, mode);
                reportNamePreviewMonth = roleName + ' (' + periodFC.get(1) + ' ' + monthReport + ')_final.xls';

            }

            Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{
                    generateReportEmailFileAttachment(reportNameCurrentMonth, reportBlobCurrentMonth),
                    generateReportEmailFileAttachment(reportNamePreviewMonth, reportBlobPreviewMonth)
            };

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Conversion Report');
            mail.setToAddresses(emailsToSend);
            mail.setPlainTextBody('See attachment');
            mail.setFileAttachments(fileAttachments);

            List<OrgWideEmailAddress> orgEmails = ([
                    SELECT Id
                    FROM OrgWideEmailAddress
                    WHERE Address = 'no-reply@fleetcor.eu'
            ]);

            if (! orgEmails.isEmpty() ) {
                mail.setOrgWideEmailAddressId(orgEmails.get(0).id);
            }

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}