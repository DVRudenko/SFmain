public interface TransitWebService {
    TransitResponseData storeContData(TransitRequestData requestData);
    void createDocumentLinks(TransitDocLinkRequestData requestData);
}