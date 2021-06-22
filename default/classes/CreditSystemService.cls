public class CreditSystemService implements CreditSystem {
	private String creditSystemName;
	private String endpointUrl;
	private String apiKey;
	private String userName;
	private String userPassword;
	private CreditSystem__c currentCreditSystem;

	/*******************************************************************************
	*  Name 		   : setCreditSystemSource(String sfdcRecordId)
	*  Summary         : Get current Credit System settings (custom setting) based on country from Salesforce record    
	*  CreatedDate     : 27/10/2016
	*  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
	*  Returns         : void
	******************************************************************************/	
	public void setCreditSystemSource(String sfdcRecordId) {
		String currentCountry = doSelectCountry(sfdcRecordId);
		currentCountry = '%' + currentCountry + '%';
		try {
			currentCreditSystem = [
					SELECT Name, Endpoint__c, API_Key__c, Password__c, Username__c, Supported_Countries__c
					FROM CreditSystem__c
					WHERE Supported_Countries__c LIKE :currentCountry
					LIMIT 1];
		} catch (Exception e) {
			system.debug('Credit Factory Error === ' + e.getMessage());
			throw new CreditFactoryException('Select Credit System Settings failed. Please check Billing Country or contact your administrator.');
		}

		setCreditSystemName(currentCreditSystem.Name);
		setEndpointUrl(currentCreditSystem.Endpoint__c);
		setApiKey(currentCreditSystem.API_Key__c);
		setUserName(currentCreditSystem.Username__c);
		setUserPassword(currentCreditSystem.Password__c);
	}

	/*******************************************************************************
	*  Name 		   : setEndpointUrl(String url)
	*  Summary         : Set Credit System Endpoint URL based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : url - Credit System Endpoint Url
	*  Returns         : void
	******************************************************************************/
	private void setEndpointUrl(String url) {
		this.endpointUrl = url;
	}

	/*******************************************************************************
	*  Name 		   : getEndpointUrl()
	*  Summary         : Return Credit System Endpoint URL
	*  CreatedDate     : 27/10/2016
	*  Parameters      : 
	*  Returns         : String
	******************************************************************************/
	public String getEndpointUrl() {
		return this.endpointUrl;
	}

	/*******************************************************************************
	*  Name 		   : setCreditSystemName(String name)
	*  Summary         : Set Credit System name based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : name - Credit System Name
	*  Returns         : void
	******************************************************************************/	
	private void setCreditSystemName(String name) {
		this.creditSystemName = name;
	}

	/*******************************************************************************
	*  Name 		   : getCreditSystemName()
	*  Summary         : Return Credit System name
	*  CreatedDate     : 27/10/2016
	*  Parameters      : 
	*  Returns         : String
	******************************************************************************/
	public String getCreditSystemName() {
		return this.creditSystemName;
	}

	/*******************************************************************************
	*  Name 		   : setApiKey(String key)
	*  Summary         : Set Credit System API Key based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : key - Credit System API key
	*  Returns         : void
	******************************************************************************/
	private void setApiKey(String key) {
		this.apiKey = key;
	}

	/*******************************************************************************
	*  Name 		   : getApiKey()
	*  Summary         : Return Credit System API key based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : 
	*  Returns         : String
	******************************************************************************/
	public String getApiKey() {
		return this.apiKey;
	}

	/*******************************************************************************
	*  Name 		   : setUserName(String username)
	*  Summary         : Set Credit System Username based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : username - Credit System Username
	*  Returns         : void
	******************************************************************************/
	private void setUserName(String userName) {
		this.userName = userName;
	}

	/*******************************************************************************
	*  Name 		   : getUserName()
	*  Summary         : Return Credit System Username based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : 
	*  Returns         : String
	******************************************************************************/
	public String getUserName() {
		return this.userName;
	}

	/*******************************************************************************
	*  Name 		   : setUserPassword(String password)
	*  Summary         : Set Credit System Password based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : password - Credit System Password
	*  Returns         : void
	******************************************************************************/
	private void setUserPassword(String password) {
		this.userPassword = password;
	}

	/*******************************************************************************
	*  Name 		   : getUserPassword()
	*  Summary         : Return Credit System Password based on custom setting
	*  CreatedDate     : 27/10/2016
	*  Parameters      : 
	*  Returns         : String
	******************************************************************************/
	public String getUserPassword() {
		return this.userPassword;
	}

	/*******************************************************************************
	*  Name 		   : doSelectCountry(String sfdcRecordId)
	*  Summary         : Select Opportunity and return Billing Country from Account
	*  CreatedDate     : 27/10/2016
	*  Parameters      : sfdcRecordId - Salesforce Opportunity Id
	*  Returns         : String
	******************************************************************************/
	private String doSelectCountry(String sfdcRecordId) {
		String country;
		Opportunity currentRecord;
		try {
			currentRecord = [
					SELECT Account.BillingCountry
					FROM Opportunity
					WHERE Id = :sfdcRecordId
					LIMIT 1];
		} catch	(Exception e) {
			system.debug(e.getMessage());
			throw new CreditFactoryException('Select record failed. Please contact your administrator.');
		}
		
		country = currentRecord.Account.BillingCountry;
		if (country == null) {
			throw new CreditFactoryException('Please add Billing Country to Account.');
		}


		return country;	
	}
}