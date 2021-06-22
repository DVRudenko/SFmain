public class SiteDuplicatesReportRuCtrl {
    public Map<Lead, Lead> bundleLeadToLeadMap { get; set; }
    public Map<Lead, Opportunity> bundleLeadToOpportunityMap { get; set; }
    public List<Lead> keyLeadToLeadList { get; set; }
    public List<Lead> keyLeadToOppList { get; set; }
    public Date createdDateFrom { get; set; }
    public Date createdDateTo { get; set; }

    private RecordType leadRecordType;
    private RecordType opportunityRecordType;

    public SiteDuplicatesReportRuCtrl() {
        this.leadRecordType = ([
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales'
                AND sObjectType = 'Lead'
                LIMIT 1
        ]);

        this.opportunityRecordType = ([
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales'
                AND sObjectType = 'Opportunity'
                LIMIT 1
        ]);

        this.createdDateFrom = Date.today();
        this.createdDateTo = Date.today().addDays(1);
        this.bundleLeadToLeadMap = new Map<Lead, Lead>();
        this.bundleLeadToOpportunityMap = new Map<Lead, Opportunity>();
        this.keyLeadToLeadList = new List<Lead>();
        this.keyLeadToOppList = new List<Lead>();
        updateContext();
    }

    /*******************************************************************************
    *  Name            : applyFilter()
    *  Summary         : updated current context
    *  CreatedDate     : 1/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void applyFilter() {
        updateContext();
    }

    /*******************************************************************************
    *  Name            : sendReport()
    *  Summary         : created site duplicate report by html body and send to current user
    *  CreatedDate     : 1/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendReport() {
        try {
            String htmlBody = ApexPages.currentPage().getParameters().get('htmlBody');
            if (htmlBody == null) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, 'Отчет не заполнен!'));
                return;
            }

            Blob reportBlob = Blob.valueOf(htmlBody);
            Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
            fileAttachment.setBody(reportBlob);
            fileAttachment.setContentType('application/vnd.ms-excel; charset=UTF-8');
            fileAttachment.setFileName('DuplicatesSiteReport.xls');
            fileAttachment.setInline(false);

            List<OrgWideEmailAddress> orgEmails = ([
                    SELECT Id
                    FROM OrgWideEmailAddress
                    WHERE Address = 'no-reply@fleetcor.eu'
                    LIMIT 1
            ]);
            String[] emails = new String[]{UserInfo.getUserEmail()};
            Messaging.SingleEmailMessage mail = EmailGenerator.sendHtmlEmailWithAttachment(
                    emails,
                    orgEmails,
                    'Site Report',
                    'See attachment',
                    fileAttachment
            );
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});

            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Отчет отправлен успешно!'));
        } catch (Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    /*******************************************************************************
    *  Name            : updateContext()
    *  Summary         : find duplicate records
    *  CreatedDate     : 1/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void updateContext() {
        try {

            List<Lead> duplicateLeadsMap = ([
                    SELECT Id, CreatedDate, RecordTypeId, Master_Record_ID__c, Source_of_Lead__c,
                            Owner.Name, Owner.UserRole.Name, Lead_Source_Type__c, Lead_Status_Specific__c, Status, Duration_work__c
                    FROM Lead
                    WHERE Master_Record_ID__c != null
                    AND CreatedDate >= :this.createdDateFrom
                    AND CreatedDate <= :this.createdDateTo
                    AND RecordTypeId = :this.leadRecordType.Id
                    LIMIT 5000
            ]);

            Set<String> dup = new Set<String>();
            for (Lead item : duplicateLeadsMap) {
                dup.add(item.Master_Record_ID__c);
            }

            Map<Id, Lead> leadsMap = new Map<Id, Lead> ([
                    SELECT Id, CreatedDate, RecordTypeId, Master_Record_ID__c, Source_of_Lead__c,
                            Owner.Name, Owner.UserRole.Name, Lead_Source_Type__c, Lead_Status_Specific__c, Status, Duration_work__c
                    FROM Lead
                    WHERE Id IN :dup
                    AND RecordTypeId = :this.leadRecordType.Id
                    LIMIT 5000
            ]);

            Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity> ([
                    SELECT Id, StageName, CreatedDate, Master_Record_ID__c, Source_of_Lead_o__c, Lead_Source_TypeOpp__c, Owner.Name, Owner.UserRole.Name
                    FROM Opportunity
                    WHERE Id IN :dup
                    AND RecordTypeId = :this.opportunityRecordType.Id
                    LIMIT 5000
            ]);

            if (this.bundleLeadToLeadMap != null) {
                this.bundleLeadToLeadMap.clear();
            }

            if (this.bundleLeadToOpportunityMap != null) {
                this.bundleLeadToOpportunityMap.clear();
            }

            if (this.keyLeadToLeadList != null) {
                this.keyLeadToLeadList.clear();
            }

            if (this.keyLeadToOppList != null) {
                this.keyLeadToOppList.clear();
            }

            for (Lead duplicateLead : duplicateLeadsMap) {

                if (duplicateLead.Master_Record_ID__c.startsWith('00Q')) {
                    for (Id leadId : leadsMap.keySet()) {
                        Lead originalLead = leadsMap.get(leadId);
                        String objId = (String)originalLead.Id;
                        if (objId.startsWith(duplicateLead.Master_Record_ID__c)) {
                            this.bundleLeadToLeadMap.put(duplicateLead, originalLead);
                            break;
                        }
                    }
                } else {
                    for (Id oppId : opportunitiesMap.keySet()) {
                        Opportunity originalOpportunity = opportunitiesMap.get(oppId);
                        String objId = (String)originalOpportunity.Id;
                        if (objId.startsWith(duplicateLead.Master_Record_ID__c)) {
                            this.bundleLeadToOpportunityMap.put(duplicateLead, originalOpportunity);
                            break;
                        }
                    }
                }

            }

            this.keyLeadToLeadList = new List<Lead>(bundleLeadToLeadMap.keySet());
            this.keyLeadToOppList = new List<Lead>(bundleLeadToOpportunityMap.keySet());

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
}