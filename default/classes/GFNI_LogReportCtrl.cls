/**
 * Created by Nikita.Mikhailov on 28.01.2019.
 */
//TODO:write comments
//TODO:filter on table
//TODO:more filters
//TODO:create knowledge page
//TODO:test it
public with sharing class GFNI_LogReportCtrl {

    private GFNI_LogReportAPI reportAPI;

    public Date startDate {
        get {
            return this.reportAPI.startDate;
        }
        set {
            this.reportAPI.startDate = value;
        }
    }
    public Date endDate {
        get {
            return this.reportAPI.endDate;
        }
        set {
            this.reportAPI.endDate = value;
        }
    }

    public List<SelectOption> countries {
        get {
            List<SelectOption> options = new List<SelectOption>();

            options.add(new SelectOption ('', 'All'));

            for (GlobalUtils.FleetcorCountries country : GlobalUtils.FleetcorCountries.values()) {
                if (country.name() == 'Russia')
                    continue;
                options.add(new SelectOption(GlobalUtils.getFleetcorCountries(String.valueOf(country)), GlobalUtils.getFleetcorCountries(String.valueOf(country))));
            }

            return options;
        }
        set;
    }
    public String selectedCountry { get; set; }

    public List<SelectOption> isFinishedValues {
        get {
            return new List<SelectOption>{
                    new SelectOption('', 'All'),
                    new SelectOption('true', 'Only finished'),
                    new SelectOption('false', 'Only not finished')
            };
        }
        set;
    }
    public String selectedIsFinishedCondition { get; set; }

    public String idValue { get; set; }
    private String idValueBackend;

    public Integer totalSize {
        get {
            return this.reportAPI.totalSize;
        }
        private set;
    }

    public Integer totalPages {
        get {
            return Integer.valueOf((Decimal.valueOf(this.totalSize) / Decimal.valueOf(this.pageSize)).round(RoundingMode.UP));
        }
        private set;
    }

    public List<SelectOption> pageSizes {
        get {
            return new List<SelectOption>{
                    new SelectOption('10', '10'),
                    new SelectOption('25', '25'),
                    new SelectOption('50', '50'),
                    new SelectOption('100', '100')
            };
        }
        set;
    }
    public Integer pageSize {
        get {
            if (this.pageSize == null)
                return Integer.valueOf(pageSizes.get(0).getValue());

            return this.pageSize;
        }
        set {
            this.pageSize = Integer.valueOf(value);
        }
    }

    public Integer pageNumber {
        get {
            if (this.pageNumber == null)
                return 1;

            return this.pageNumber;
        }
        set;
    }

    public Boolean isPreviousDisabled {
        get {
            return !CustomPagination.hasPrevious(this.pageNumber, this.pageSize);
        }
        private set;
    }

    public Boolean isNextDisabled {
        get {
            return !CustomPagination.hasNext(this.pageNumber, this.pageSize, this.totalSize);
        }
        private set;
    }

    public Boolean isExportDisabled {
        get {
            if (this.reportAPI.totalSize == 0 || this.numberOfExports > 2)
                return true;

            return false;
        }
        private set;
    }

    private Integer numberOfExports = 0;

    public List<GFNI_LogReportRecord> report { get; set; }

    public GFNI_LogReportCtrl() {
        this.reportAPI = new GFNI_LogReportAPI(Date.today().addDays(-1), Date.today(), null);
    }

    //created for UnitTesting
    public GFNI_LogReportCtrl(GFNI_LogReportAPI reportAPI) {
        this.reportAPI = reportAPI;
    }

    public void init() {

        this.idValue = null;
        this.idValueBackend = null;
        this.selectedCountry = this.countries.get(0).getValue();
        this.selectedIsFinishedCondition = this.isFinishedValues.get(0).getValue();
        this.startDate = Date.today().addDays(-1);
        this.endDate = Date.today();
        this.reportAPI.setFilteringValues(this.idValueBackend, this.selectedCountry, String.isNotBlank(this.selectedIsFinishedCondition) ? (this.selectedIsFinishedCondition == 'true' ? true : false) : null);

        this.report = new List<GFNI_LogReportRecord>();
        firstPage();
    }

    private void idSearchValueCheck() {
        this.idValueBackend = onIdValueChange(this.idValue);
        if (this.idValueBackend == '1' || this.idValueBackend == '2') {
            this.idValueBackend = null;
            this.idValue = null;
        }
    }

    @RemoteAction
    public static String onIdValueChange(String idValue) {
        System.debug(idValue);
        if (idValue == null || idValue == '')
            return idValue;

        Opportunity opportunity;

        switch on GFNI_Utils.getIdType(idValue) {
            when 'SF' {
                System.debug('SF ID: ' + idValue);
                return idValue;
            } when 'Account_Nr' {
                try {
                    opportunity = [SELECT Id FROM Opportunity WHERE Account.Account_Nr__c = :idValue];
                } catch (Exception e) {
                    return String.valueOf(1);
                }
                System.debug('Account_Nr ID: ' + idValue);
                return opportunity.Id;
            } when 'GFN_Nr' {
                try {
                    opportunity = [SELECT Id FROM Opportunity WHERE GFN_number_for_starts__c = :idValue];
                } catch (Exception e) {
                    return String.valueOf(1);
                }
                System.debug('GFN ID: ' + idValue);
                return opportunity.Id;
            } when else {
                System.debug('NOT AN ID');
                return String.valueOf(2);
            }
        }
    }

    public void onApplyButtonClick() {
        System.debug('GFNI_LogReportCtrl: apply button clicked');
        idSearchValueCheck();
        this.reportAPI.setFilteringValues(this.idValueBackend, this.selectedCountry, String.isNotBlank(this.selectedIsFinishedCondition) ? (this.selectedIsFinishedCondition == 'true' ? true : false) : null);
        firstPage();
    }

    public void lastPage() {
        if (isNextDisabled)
            return;

        this.report.clear();
        this.pageNumber = totalPages;

        for (Object record : CustomPagination.last(reportAPI.createReportRecords(), this.pageNumber, this.pageSize)) {
            this.report.add((GFNI_LogReportRecord) record);
        }
    }

    public void firstPage() {
        this.report.clear();
        this.pageNumber = 1;

        for (Object record : CustomPagination.first(reportAPI.createReportRecords(), this.pageSize)) {
            this.report.add((GFNI_LogReportRecord) record);
        }
    }

    public void nextPage() {
        if (isNextDisabled)
            return;

        this.report.clear();
        this.pageNumber++;

        for (Object record : CustomPagination.next(reportAPI.createReportRecords(), this.pageNumber, this.pageSize)) {
            this.report.add((GFNI_LogReportRecord) record);
        }
    }

    public void previousPage() {
        if (isPreviousDisabled)
            return;

        this.report.clear();
        this.pageNumber--;

        for (Object record : CustomPagination.previous(reportAPI.createReportRecords(), this.pageNumber, this.pageSize)) {
            this.report.add((GFNI_LogReportRecord) record);
        }
    }

    public void onExportToExcelButtonClick() {
        System.debug('Send report to ' + UserInfo.getUserId() + ' ' + UserInfo.getName() + ' ' + UserInfo.getUserEmail());
        System.enqueueJob(new GFNI_LogExcelExporterQueueable(reportAPI.createReportRecords(), UserInfo.getUserId()));
        this.numberOfExports++;
    }
}