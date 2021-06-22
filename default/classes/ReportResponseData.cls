public class ReportResponseData {
    public List<ReportResponseData.ReportDocument> reportDocumentList { get; set; }     // Документы и идентификаторами и расширением
    public ReportResponseData.ReportParams reportParams { get; set; }

    public class ReportDocument {
        public String idReport { get; set; }                // идентификаторо шаблона документа в сервисе отчетов
        public Integer reportTypeId { get; set; }           // идентификатор типа документа, справочник в транзите
        public String reportTypeDescription { get; set; }   // описание документа
        public DocumentPath path { get; set; }
    }

    public class DocumentPath {
        public String pdf { get; set; }         // идентификатор pdf документа, храниться в сервисе отчетов
        public String docx { get; set; }        // идентификатор docx документа, храниться в сервисе отчетов
    }

    public class ReportParams {
        public String SALESFORCE_CONTRACT_PREFIX { get; set; }            // Префикс номера договора
        public String SALESFORCE_CONTRACT_COUNTER { get; set; }           // Счетчик номера договора
        public String SALESFORCE_INVOICE_PREFIX { get; set; }             // Префикс номера счета
        public String SALESFORCE_INVOICE_COUNTER { get; set; }            // Счетчик номера счета
    }

    public class ReportDocumentWrapper implements Comparable {
        public ReportDocument document { get; private set; }

        public ReportDocumentWrapper(ReportDocument doc) {
            document = doc;
        }

        public Integer compareTo(Object compareTo) {
            ReportResponseData.ReportDocumentWrapper rdw = (ReportResponseData.ReportDocumentWrapper)compareTo;

            Integer returnValue = 0;
            if (document.reportTypeId > rdw.document.reportTypeId) {
                returnValue = 1;
            } else if (document.reportTypeId < rdw.document.reportTypeId) {
                returnValue = -1;
            }
            return returnValue;
        }

    }
}