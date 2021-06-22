public interface CreditSystem {
	String getCreditSystemName();
	String getApiKey();
	String getEndpointUrl();
	String getUserName();
	String getUserPassword();
	void setCreditSystemSource(String sfdfRecordId);
}