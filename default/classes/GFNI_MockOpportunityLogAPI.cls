/**
 * Created by Nikita.Mikhailov on 27.02.2019.
 */

@IsTest
global class GFNI_MockOpportunityLogAPI implements StubProvider {
    private Id oppId;
    private Id accId;
    private Boolean isFailed;
    public Integer totalSize { get; set; }

    public GFNI_MockOpportunityLogAPI(Id oppId, Id accId, Boolean isFailed, Integer reportSize) {
        this.oppId = oppId;
        this.accId = accId;
        this.isFailed = isFailed;
        this.totalSize = reportSize;
    }

    global Object handleMethodCall(Object stubbedObject,
            String stubbedMethodName,
            System.Type returnType,
            List<System.Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs) {
        List<GFNI_LogReportRecord> report = new List<GFNI_LogReportRecord>();

        for (Integer i = 0; i < this.totalSize; i++) {
            GFNI_LogReportRecord record = new GFNI_LogReportRecord();
            record.recordDate = System.now();
            record.registeredCountry = 'Germany';
            record.languagePreference = 'German';
            record.accountNumberSF = 'FC-001320568';
            record.accountNumberGFN = 'DE12490329';
            record.accountName = 'TEST' + i;
            record.accountId = this.accId;
            record.product = 'Inbound Typ B';
            if (isFailed) {
                record.isFinished = false;
            } else {
                record.isFinished = true;
            }
            record.message = 'message';
            record.opportunityId = this.oppId;
            record.applicationId = '00000000-0000-0000-0000-000000000000';
            record.hasFirst = true;

            report.add(record);
        }
        return report;
    }
}