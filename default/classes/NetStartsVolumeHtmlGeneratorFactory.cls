/**
 * Created by Andrei.Moiseev on 28.03.2018.
 */

public class NetStartsVolumeHtmlGeneratorFactory {

    public static OnboardingReportHtmlGenerator create(
            NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType type,
            List<Object> params) {

        if (type == NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.EXCEL) {
            return new NetStartsVolumeReportHtmlGeneratorLightExcel(
                    (List<String>) params.get(0),
                    (Map<String, String>) params.get(1)
            );
        } else if (type == NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.CSV) {
            return new NetStartsVolumeReportHtmlGeneratorLightCSV(
                    (List<String>) params.get(0),
                    (Map<String, String>) params.get(1)
            );
        } else if (type == NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.HTML) {
            return new NetStartsVolumeReportHtmlGenerator(
                    (List<Map<String, Object>>) params.get(0),
                    (Map<String, Object>) params.get(1),
                    (List<String>) params.get(2),
                    (String) params.get(3)
            );
        } else if (type == NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.SELECTOR) {
            return new HtmlSelectFormGenerator(
                    (Map<String, Object>) params.get(0),
                    (Map<String, String>) params.get(1),
                    (List<String>) params.get(2),
                    (String) params.get(3)
            );
        } else {
            return null;
        }
    }


    public class NetStartsVolumeReportHtmlGeneratorLightExcel implements OnboardingReportHtmlGenerator {
        private List<String> reportFields;
        private Map<String, String> translateFields;
        private String body;

        public NetStartsVolumeReportHtmlGeneratorLightExcel(List<String> reportFields, Map<String, String> translateFields) {
            this.reportFields = reportFields;
            this.translateFields = translateFields;
            this.body = '';
        }

        public String generateReportHtmlTemplate() {
            String table = '<style> td { vnd.ms-excel.numberformat:@; } </style><table>';
            table += getTableHeader();
            table += getTableBody();
            table += '</table>';
            return table;
        }

        public void addRows(List<Map<String, Object>> records) {
            for (Map<String, Object> row : records) {
                this.body += getDataRow(row);
            }
        }

        public String getTableHeader() {
            return getTableHeaderRow();
        }

        public String getTableBody() {
            return this.body;
        }

        public String getStyle() {
            return '';
        }

        private String getTableHeaderRow() {
            String headerRow = '<thead><tr>';
            for (String field : reportFields) {
                if (translateFields.containsKey(field)) {
                    headerRow += '<th>' + translateFields.get(field) + '</th>';
                } else {
                    headerRow += '<th>' + field + '</th>';
                }

            }
            headerRow += '</tr></thead>';
            return headerRow;
        }

        private String getDataRow(Map<String, Object> row) {
            String dataRow = '<tr>';
            for (String field : reportFields) {
                dataRow += getDataCell(row.get(field));
            }
            dataRow += '</tr>';
            return dataRow;
        }

        private String getDataCell(Object cell) {
            if (cell instanceof NetStartVolumeReportSettings.ReferenceBundle) {
                return '<td>' + ((NetStartVolumeReportSettings.ReferenceBundle) cell).name;
            } else if (cell != null) {
                return '<td>' + cell;
            } else {
                return '<td>';
            }
        }
    }

    public class NetStartsVolumeReportHtmlGeneratorLightCSV implements OnboardingReportHtmlGenerator {
        private List<String> reportFields;
        private Map<String, String> translateFields;
        private String body;

        public NetStartsVolumeReportHtmlGeneratorLightCSV(List<String> reportFields, Map<String, String> translateFields) {
            this.reportFields = reportFields;
            this.translateFields = translateFields;
            this.body = '';
        }

        public String generateReportHtmlTemplate() {
            String table = '';
            table += getTableHeader();
            table += getTableBody();
            return table;
        }

        public void addRows(List<Map<String, Object>> records) {
            for (Map<String, Object> row : records) {
                this.body += getDataRow(row);
            }
        }

        public String getTableHeader() {
            return getTableHeaderRow();
        }

        public String getTableBody() {
            return this.body;
        }

        public String getStyle() {
            return '';
        }

        private String getTableHeaderRow() {
            String headerRow = '';
            for (String field : reportFields) {
                if (translateFields.containsKey(field)) {
                    headerRow += translateFields.get(field) + ',';
                } else {
                    headerRow += field + ',';
                }

            }
            return headerRow + '\n';
        }

        private String getDataRow(Map<String, Object> row) {
            String dataRow = '';
            for (String field : reportFields) {
                dataRow += getDataCell(row.get(field));
            }
            return dataRow += '\n';
        }

        private String getDataCell(Object cell) {
            if (cell instanceof NetStartVolumeReportSettings.ReferenceBundle) {
                return ((NetStartVolumeReportSettings.ReferenceBundle) cell).name + ',';
            } else if (cell != null) {
                return cell + ',';
            } else {
                return '';
            }
        }
    }

    /// ***** Html generator for Selector Table *****/////
    public class HtmlSelectFormGenerator implements OnboardingReportHtmlGenerator {
        private Map<String, Object> dataForSelector;
        private Map<String, String> labelsForSelector;
        private List<String> labels;
        private String htmlRootId;
        private Integer selectTagNumber = 0;

        public HtmlSelectFormGenerator(
                Map<String, Object> dataSelector,
                Map<String, String> labelsForSelector,
                List<String> labels,
                String htmlRootId) {
            this.dataForSelector = dataSelector;
            this.labelsForSelector = labelsForSelector;
            this.labels = labels;
            this.htmlRootId = htmlRootId;
        }

        public String generateReportHtmlTemplate() {
            String table = '<div id="' + this.htmlRootId + ':filterbar"><table border="0" cellpadding="1" cellspacing="1" class="detailList">';
            table += getTableHeader();
            table += getTableBody();
            table += getSendButton();
            table += '</table></div>';
            return table;
        }

        public String getTableHeader() {
            return '';
        }

        public String getTableBody() {
            String tableBody = '<tbody>';
            Integer index = 0;
            for (String selectorName : labels) {
                tableBody += getSelectTag(
                        dataForSelector.get(labelsForSelector.get(selectorName)),
                        selectorName,
                        htmlRootId + ':sl:' + labelsForSelector.get(selectorName)
                );
                index++;
            }
            tableBody += '</tbody>';
            return tableBody;
        }

        public void addRows(List<Map<String, Object>> records) {

        }

        private String getSelectTag(Object options, String selectName, String tagId) {
            String selectBody = '';
            if (options instanceof List<String>) {
                selectBody +=
                        '<tr><td class="labelCol">' + selectName + '</td><td><select name="' + tagId + '" size="1">' +
                                String.join((List<String>) options, '') +
                                '</select></td></tr>';
            } else if (options instanceof List<Date>) {
                String postfix = '';
                String tag = tagId.substringAfterLast(':');
                System.debug('tag=' + tag);
                if (tag != null && tag.contains('firstPump'))
                    postfix = 'Pump';

                String pumpDate = (tagId.endsWith('closedDate') ? '' : 'Pump');
                List<Date> optionsList = (List<Date>) options;
                if (optionsList.size() == 2) {
                    String dfrom = '';
                    String dto = '';

                    if (optionsList.get(0) != null) {
                        Datetime dateFrom = datetime.newInstance(
                                optionsList.get(0).year(),
                                optionsList.get(0).month(),
                                optionsList.get(0).day()
                        );
                        dfrom = dateFrom.format('dd/MM/yyyy');
                    }

                    if (optionsList.get(1) != null) {
                        Datetime dateTo = datetime.newInstance(
                                optionsList.get(1).year(),
                                optionsList.get(1).month(),
                                optionsList.get(1).day()
                        );
                        dto = dateTo.format('dd/MM/yyyy');
                    }


                    selectBody +=
                            '<tr><td class="labelCol">' + selectName + '</td><td>' +
                                    '<span class="dateInput dateOnlyInput">' +
                                    '<input id="' + tagId + ':dateFrom" name="' + tagId + ':dateFrom' + postfix + '" size="12" type="text" ' +
                                    'value="' + dfrom + '" data-uidsfdc="18">' +
                                    '</span>';

                    selectBody +=
                            '<span class="dateFormat">[&nbsp;<a href="javascript:DatePicker.insertDate(\'' +
                                    dfrom + '\', \'' + tagId + ':dateFrom\'+' + postfix + ', true);">' +
                                    dfrom + '</a>&nbsp;]</span>';
                    selectBody +=
                            '<span class="dateInput dateOnlyInput">' +
                                    '<input id="' + tagId + ':dateTo" name="' + tagId + ':dateTo' + postfix + '" size="12" type="text" ' +
                                    'value="' + dto + '" data-uidsfdc="18">' +
                                    '</span>';

                    selectBody +=
                            '<span class="dateFormat">[&nbsp;<a href="javascript:DatePicker.insertDate(\'' +
                                    dto + '\', \'' + tagId + ':dateTo\'+' + postfix + ', true);">' +
                                    dto + '</a>&nbsp;]' +
                                    '</span>';
                    selectBody += '</td></tr>';
                }
            } else if (options instanceof String) {
                selectBody +=
                        '<tr><td class="labelCol">' + selectName + '</td><td>' +
                                '<input id="' + tagId + '" name="' + tagId + '" size="35" type="text" ' +
                                'value="' + '" data-uidsfdc="18"></td></tr>';
            }
            return selectBody;
        }

        public String getStyle() {
            return '';
        }

        private String getSendButton() {
            return '<tr><td>' +
                    '<input class="btn" id="applyButton" name="myPage:myForm:j_id19" onclick="getSelectedValue();return false;" value="' + Label.RU_0058_Apply + '" style="size : 20" type="button">' +
                    '</td></tr>';
        }
    }

    public class NetStartsVolumeReportHtmlGenerator implements OnboardingReportHtmlGenerator {
        private List<Map<String, Object>> records;
        private Map<String, Object> total;
        private List<String> reportFields;
        private String rootTagId;

        public NetStartsVolumeReportHtmlGenerator(List<Map<String, Object>> records,
                Map<String, Object> total,
                List<String> reportFields,
                String rootTagId) {
            this.records = records;
            this.total = total;
            this.reportFields = reportFields;
            this.rootTagId = rootTagId;
        }

        public String generateReportHtmlTemplate() {
            this.rootTagId += ':theaddrs';
            String table = '<table id="mainTable" class="detailList" cellpadding="1" cellspacing="1">' +
                    '<tbody>' +
                    '<tr>' +
                    '<td class="dataCol  first  last " colspan="2">' +
                    '<table class="list sorterStyle" id="' + this.rootTagId + '" border="0" cellpadding="0" cellspacing="0">';
            table += getTableHeader();
            table += getFoot();
            table += getTableBody();
            table += '</table>' +
                    '</td>' +
                    '<td class="labelCol empty"></td>' +
                    '<td class="dataCol empty"></td>' +
                    '</tr>' +
                    '</tbody>' +
                    '</table>';
            return table;
        }

        public String getTableHeader() {
            return getTableHeaderRow();
        }

        public String getTableBody() {
            String tableBody = '<tbody id="' + this.rootTagId + ':tb">';

            Integer index = 0;
            for (Map<String, Object> row : this.records) {
                tableBody += getDataRow(row, this.rootTagId + ':r_id' + index);
                index++;
            }
            tableBody += '</tbody>';

            return tableBody;
        }

        public String getStyle() {
            return '';
        }

        public void addRows(List<Map<String, Object>> records) {
        }

        private String getTableHeaderRow() {
            String headerRow = '<thead><tr class="headerRow header">';

            Integer index = 1;
            String tagId = '';
            for (String field : reportFields) {
                tagId = this.rootTagId + ':h_id' + index + 'header';
                headerRow += '<th class="headerRow header" scope="col" colspan="1" id="' + tagId + '">' +
                        '<div id="' + tagId + ':sortDiv">' + field + '</div>' +
                        '</th>';
                index++;
            }
            headerRow += '</tr></thead>';
            return headerRow;
        }

        private String getDataRow(Map<String, Object> row, String tagId) {
            String dataRow = '<tr class="dataRow even  first" onmouseover="if (window.hiOn){hiOn(this);} " onmouseout="if (window.hiOff){hiOff(this);} " onblur="if (window.hiOff){hiOff(this);}" onfocus="if (window.hiOn){hiOn(this);}">';

            Integer index = 0;
            for (String field : reportFields) {
                dataRow += getDataCell(row.get(field), tagId + ':c_id' + index);
                index++;
            }
            dataRow += '</tr>';
            return dataRow;
        }

        private String getDataCell(Object cell, String tagId) {
            String cellValue = '';
            if (cell instanceof NetStartVolumeReportSettings.ReferenceBundle) {
                NetStartVolumeReportSettings.ReferenceBundle referenceBundle = (NetStartVolumeReportSettings.ReferenceBundle) cell;
                if (referenceBundle.refer != null) {
                    cellValue = '<a href="/' + referenceBundle.refer + '" target="_blank">' + referenceBundle.name + '</a>';
                } else {
                    cellValue = '<span id="' + tagId + ':sp">' + referenceBundle.name + '</span>';
                }

            } else {
                cellValue = '<span id="' + tagId + ':sp">' + cell + '</span>';
            }
            String dataCell = '<td class="dataCell  " id="' + tagId + '" colspan="1">' + cellValue + '</td>';

            return dataCell;
        }

        private String getFoot() {
            String footRow = '<tfoot><tr class="totalRow">';
            for (String field : reportFields) {
                footRow += '<th class="totalRow" scope="col" colspan="1">';
                if (total.containsKey(field)) {
                    footRow += total.get(field);
                }
                footRow += '</th>';
            }
            footRow += '</tr></tfoot>';
            return footRow;
        }
    }

}