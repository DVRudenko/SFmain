/**
 * Created by Nikita.Mikhailov on 28.01.2019.
 */

public with sharing class GFNI_LogReportRecord implements Comparable {
    public Datetime recordDate { get; set; }
    public String registeredCountry { get; set; }
    public String languagePreference { get; set; }
    public String accountNumberSF { get; set; }
    public String accountNumberGFN { get; set; }
    public String accountName { get; set; }
    public String primaryContactEmail { get; set; }
    public Id accountId { get; set; }
    public String product { get; set; }
    public Boolean isFinished { get; set; }
    public String conclusion { get; set; }
    public String message { get; set; }
    public Id opportunityId { get; set; }
    public String applicationId { get; set; }
    public Boolean hasFirst { get; set; }

    public Integer compareTo(Object compareTo) {
        GFNI_LogReportRecord logReportRecord = (GFNI_LogReportRecord) compareTo;
        if (recordDate == logReportRecord.recordDate) return 0;
        if (recordDate < logReportRecord.recordDate) return 1;
        return -1;
    }
}