/**
 * Created by Nikita.Mikhailov on 19.02.2019.
 */

global class GFNI_LogSenderSchedulable implements Schedulable {
    public List<GFNI_LogReportRecord> reportRecords { get; set; }
    private GFNI_LogReportAPI logAPI;

    public GFNI_LogSenderSchedulable(GFNI_LogReportAPI logAPI) {
        //used for testing. This will work with Stub API
        this.logAPI = logAPI;
    }

    public GFNI_LogSenderSchedulable() {
        this.logAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today(), null);
    }

    /*******************************************************************************
    *  Name            : execute
    *  Summary         : Retrieves daily log using GFNI log API and sends report to specific countries
    *  CreatedDate     : 19/02/2019
    *  Parameters      : SchedulableContext context
    *  Returns         : -
    ******************************************************************************/
    global void execute(SchedulableContext context) {
        if (!Test.isRunningTest())
            this.logAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today(), null);

        this.logAPI.setFilteringValues(null, null, true);

        this.reportRecords = this.logAPI.createReportRecords();//select only successfully created customers

        if (this.reportRecords.isEmpty()) {
            //if report is empty do nothing
            System.debug('Report is empty');
            return ;
        }

        Set<Id> oppIds = new Set<Id>();

        for (GFNI_LogReportRecord reportRecord : this.reportRecords) {
            oppIds.add(reportRecord.opportunityId);
        }

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([
                SELECT Id, Account.BillingCountryCode
                FROM Opportunity
                WHERE Id = :oppIds
        ]);

        Map<String, List<GFNI_LogReportRecord>> reportRecordMapByCountry = new Map<String, List<GFNI_LogReportRecord>>();

        Map<String, GFNI_LogSenderSchedulable_ItemsNumber> itemNumbersByCountry = new Map<String, GFNI_LogSenderSchedulable_ItemsNumber>();

        for (GFNI_LogReportRecord reportRecord : this.reportRecords) {
            if (!reportRecordMapByCountry.containsKey(opportunities.get(reportRecord.opportunityId).Account.BillingCountryCode))
                reportRecordMapByCountry.put(opportunities.get(reportRecord.opportunityId).Account.BillingCountryCode, new List<GFNI_LogReportRecord>());

            reportRecordMapByCountry.get(opportunities.get(reportRecord.opportunityId).Account.BillingCountryCode).add(reportRecord);

            //counting number of failed and successes opp-tys for each country
            if (!itemNumbersByCountry.containsKey(opportunities.get(reportRecord.opportunityId).Account.BillingCountryCode))
                itemNumbersByCountry.put(opportunities.get(reportRecord.opportunityId).Account.BillingCountryCode, new GFNI_LogSenderSchedulable_ItemsNumber());

            GFNI_LogSenderSchedulable_ItemsNumber itemsNumber = itemNumbersByCountry.get(opportunities.get(reportRecord.opportunityId).Account.BillingCountryCode);
            if (reportRecord.isFinished) {
                itemsNumber.numberOfSuccessfulItems++;
            } else {
                //leaving number of failed items because it can be returned
                //itemsNumber.numberOfFailedItems++;
            }
            itemNumbersByCountry.put(opportunities.get(reportRecord.opportunityId).Account.BillingCountryCode, itemsNumber);
        }

        System.debug(reportRecordMapByCountry);
        System.debug(itemNumbersByCountry);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (String key : reportRecordMapByCountry.keySet()) {
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            Blob excel = Blob.valueOf(GFNI_LogExcelBuilder.generateReportHtmlTemplate(reportRecordMapByCountry.get(key)));
            attach.setBody(excel);
            attach.setFileName(key + ' New Customer Creation.xls');

            mails.add(GFNI_Utils.createEmailWithAttachment('NCC_' + key + '_Daily Log', key + '\n\n' +
                    'Successful items: ' + itemNumbersByCountry.get(key).numberOfSuccessfulItems + '\n' + '\n' +
                    //'Unsuccessful items: ' + itemNumbersByCountry.get(key).numberOfFailedItems + '\n' + '\n' +
                    'Please find in attachment or see ' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/GFNI_LogReport' + '\n\n' +
                    'Have a nice day!' + '\n\n', key, attach));
        }

        System.debug(mails.size());

        GFNI_Utils.sendEmails(mails);
    }
}