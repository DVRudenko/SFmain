public interface IConversionReport {
    List<Messaging.SingleEmailMessage> getMails();
    String getFileType();
}