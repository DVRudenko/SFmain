/**
 * Created by Nikita.Mikhailov on 13.03.2019.
 */

public with sharing class GFNI_LogExcelBuilder {

    private static final List<String> headers = new List<String>{
            'Record Date', 'Country', 'Language', 'Account #', 'ERP Number', 'Account Name', 'Email', 'Product', 'Finished', 'Conclusion', 'Error/Last message', 'Application Id', 'Link to opportunity', 'Link to extended report'
    };

    /*******************************************************************************
    *  Name            : generateReportHtmlTemplate()
    *  Summary         : generate HTML report template for sending by email
    *  CreatedDate     : 19/02/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String generateReportHtmlTemplate(List<GFNI_LogReportRecord> reportRecords) {
        String htmlDocument = '';
        htmlDocument += getTableHeader();
        htmlDocument += '<div class="report">\n<table>\n';
        htmlDocument += getTableHeaderRow();
        htmlDocument += getTableBody(reportRecords);
        htmlDocument += '</table>\n</div>';
        return htmlDocument;
    }

    /*******************************************************************************
    *  Name            : getTableHeader()
    *  Summary         : generate a table header of HTML template <head>...</head>
    *  CreatedDate     : 19/02/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String getTableHeader() {
        String tableHeader = '<head><META http-equiv="Content-Type" content="application/vnd.ms-excel; charset=UTF-8"></head>\n';
        return tableHeader;
    }

    /*******************************************************************************
    *  Name            : getTableHeaderRow()
    *  Summary         : generate a header row of template
    *  CreatedDate     : 19/02/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String getTableHeaderRow() {
        String headerRow = '<tr class="headerRow">\n';

        for (Integer i = 0; i < GFNI_LogExcelBuilder.headers.size(); i++) {
            headerRow += '<th filter=all id="col-' + (i + 1) + '">' + GFNI_LogExcelBuilder.headers.get(i) + '</th>\n';
        }

        headerRow += '</tr>\n';

        return headerRow;
    }

    private static String getTableBody(List<GFNI_LogReportRecord> reportRecords) {
        String body = '';
        for (GFNI_LogReportRecord reportRecord : reportRecords) {
            body += getDataRow(reportRecord);
        }
        return body.unescapeHtml3();
    }

    private static String getDataRow(GFNI_LogReportRecord record) {
        String dataRow = '<tr class="dataRow">\n';
        dataRow += '<td id="data-1" style="vnd.ms-excel.numberformat:@">' + record.recordDate.format() + '</td>\n';
        dataRow += '<td id="data-2" style="vnd.ms-excel.numberformat:@">' + record.registeredCountry + '</td>\n';
        dataRow += '<td id="data-3" style="vnd.ms-excel.numberformat:@">' + record.languagePreference + '</td>\n';
        dataRow += '<td id="data-4" style="vnd.ms-excel.numberformat:@">' + record.accountNumberSF + '</td>\n';
        dataRow += '<td id="data-5" style="vnd.ms-excel.numberformat:@">' + record.accountNumberGFN + '</td>\n';
        dataRow += '<td id="data-6" style="vnd.ms-excel.numberformat:@">' + record.accountName + '</td>\n';
        dataRow += '<td id="data-7" style="vnd.ms-excel.numberformat:@">' + record.primaryContactEmail + '</td>\n';
        dataRow += '<td id="data-8" style="vnd.ms-excel.numberformat:@">' + record.product + '</td>\n';
        dataRow += '<td id="data-9" style="vnd.ms-excel.numberformat:@">' + String.valueOf(record.isFinished) + '</td>\n';
        dataRow += '<td id="data-10" style="vnd.ms-excel.numberformat:@">' + GlobalUtils.blankStringIfNull(record.conclusion) + '</td>\n';
        dataRow += '<td id="data-11" style="vnd.ms-excel.numberformat:@">' + record.message + '</td>\n';
        dataRow += '<td id="data-12" style="vnd.ms-excel.numberformat:@">' + record.applicationId + '</td>\n';
        dataRow += '<td id="data-13" style="vnd.ms-excel.numberformat:@">' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.opportunityId + '</td>\n';
        dataRow += '<td id="data-14" style="vnd.ms-excel.numberformat:@">' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/GFNI_LogReportExtended?id=' + record.opportunityId + '</td>\n';

        dataRow += '</tr>\n';
        return dataRow;
    }
}