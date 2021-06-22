public class TransitDocLinkRequestData {
    public String idCont { get; set; }   // идентификатор контр адента в транзите
    public List<TransitDocLinkRequestData.DocumentToLink> documentList { get; set; }

    public class DocumentToLink {
        public Integer docTypeId { get; set; }      // идентификатор документа из справочника транзит
        public String format { get; set; }          // формат документа
        public String idLink { get; set; }          // идентификатор документа в сервисе отчетов (Report Service)
    }
}