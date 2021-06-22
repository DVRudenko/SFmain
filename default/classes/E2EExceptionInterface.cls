public interface E2EExceptionInterface {
    Map<String, LongFormPage> getExceptionPages(String deviceView);
    void saveExceptionData();
    void setExceptionOwner();
}