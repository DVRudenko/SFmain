public class E2ESystemErrorController {
	public Map<String, LongFormPage> pagesMapErrors {get; set;}
    private String salesforceBaseUrl;
    private String fullUrl;
	private Opportunity opportunity;
    
    public E2ESystemErrorController() {}


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : Initial method     
    *  CreatedDate     : 09/09/2018
    *  ModifiedDate	   : 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        String accessError;
        this.salesforceBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();        
        this.fullUrl = System.URL.getCurrentRequestUrl().toExternalForm();
        if (this.salesforceBaseUrl != null && this.fullUrl != null && this.fullUrl.containsIgnoreCase('e2eform') ) {                
            accessError = 'Access Error';
        } else {
            accessError = 'Access Error: Direct Domain Enter';
        }    

        try {
            Cookie e2esource = ApexPages.currentPage().getCookies().get('e2esource');
            String country;
            if (e2esource != null && e2esource.getValue() != null) {
                String opportunityId = doDecryptParams(e2esource.getValue());
                List<Opportunity> oppToCheck = [
                        SELECT AccountId, Account.BillingCountry, OwnerId, Account.OwnerId
                        FROM Opportunity 
                        WHERE Id = :opportunityId AND 
                              Account.BillingCountry != NULL 
                        LIMIT 1];
                if (oppToCheck.isEmpty()) {
                    country = 'Germany';
                } else {
                    country = oppToCheck.get(0).Account.BillingCountry;
                    opportunity = oppToCheck.get(0);
                }
            } else {
                country = returnCountry(this.salesforceBaseUrl);
            }
            this.pagesMapErrors = new Map<String, LongFormPage>();
            this.pagesMapErrors.putAll(LongFormGlobalUtils.returnErrorPage(country, 'Desktop'));
            
            if (opportunity != null) {
                saveExceptionData(opportunity, 'Access Error');
                sendExceptionEmail(opportunity, accessError);
            } else {
                sendExceptionEmail(null, accessError);
            }               
        } catch (Exception e) {
            this.pagesMapErrors = new Map<String, LongFormPage>();
            this.pagesMapErrors.putAll(LongFormGlobalUtils.returnErrorPage('Germany', 'Desktop'));
            sendExceptionEmail(null, accessError);
        }
    }


    /*******************************************************************************
    *  Name            : returnCountry(String salesforceBaseUrl)
    *  Summary         : Return Country based on url     
    *  CreatedDate     : 22.01.2019
    *  ModifiedDate    : 
    *  Parameters      : salesforceBaseUrl - main domain from the URL
    *  Returns         : String country
    ******************************************************************************/
    public String returnCountry(String salesforceBaseUrl) {
        if (salesforceBaseUrl == null) return 'Germany';

        if (salesforceBaseUrl.containsIgnoreCase('online.fleetcor.de')) {
            return 'Germany';
        } else
        if (salesforceBaseUrl.containsIgnoreCase('online.fleetcor.nl')) {
            return 'Netherlands';
        } else
        if (salesforceBaseUrl.containsIgnoreCase('online.fleetcorcards.be') && this.fullUrl != null && this.fullUrl.containsIgnoreCase('e2eformbenl')) {
            return 'Belgium-NL';
        } else
        if (salesforceBaseUrl.containsIgnoreCase('online.fleetcorcards.be') && this.fullUrl != null && this.fullUrl.containsIgnoreCase('e2eformbefr')) {
            return 'Belgium-FR';
        } else        
        if (salesforceBaseUrl.containsIgnoreCase('online.fleetcorcards.be')) {
            return 'Belgium-NL';
        } else        
        if (salesforceBaseUrl.containsIgnoreCase('online.fleetcor.pl')) {
            return 'Poland';
        } else 
        if (salesforceBaseUrl.containsIgnoreCase('online.fleetcor.hu')) {
            return 'Hungary';
        } 

        return 'Germany';      
    }


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 09/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String encryptedParams
    *  Returns         : String – Opportunity Id
    ******************************************************************************/
    private static String doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        Blob dest = EncodingUtil.base64Decode(encryptedParams);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
        String decryptedParams = decrypted.toString();
        if (decryptedParams != null) {
            String opportunityId = decryptedParams.substringBefore('-');

            return opportunityId;
        }
        return null;
    }


	/*******************************************************************************
    *  Name            : saveExceptionData(Opportunity opportunity, String excpt)
    *  Summary         : update opportuinty and account if we catch a exception    
    *  CreatedDate     : 09/09/2018
    *  ModifiedDate    : 
    *  Parameters      : Opportunity opportunity, String excpt – exception name
    *  Returns         : void
    ******************************************************************************/
    public static void saveExceptionData(Opportunity opportunity, String excpt) {
    	opportunity.E2E_Errors__c = 'System Error';
        opportunity.Last_E2E_Error__c = 'System Error';
        if (opportunity.E2E_System_Error_Description__c != null) {
            opportunity.E2E_System_Error_Description__c += '; ' + excpt;
        } else {
            opportunity.E2E_System_Error_Description__c = excpt;
        }
    	opportunity.E2E_Status__c = 'Rejected';
		opportunity.E2E_Sub_Status__c = 'Switched to manual';
		opportunity.E2E_Sales_Type__c = 'E2E downgraded to manual';

    	Account account = [SELECT Id, BillingCountry FROM Account WHERE Id = :opportunity.AccountId LIMIT 1];

        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(account.BillingCountry);
        if (settings != null && settings.Abandonment_User__c != null) {
            account.OwnerId = settings.Abandonment_User__c;
            opportunity.OwnerId = settings.Abandonment_User__c;
        }

        update opportunity;
        update account;
    }


    /*******************************************************************************
    *  Name            : sendExceptionEmail(Opportunity opportunity, String excpt)
    *  Summary         : send exception email
    *  CreatedDate     : 14/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity, String excpt
    *  Returns         : void
    ******************************************************************************/
    public static void sendExceptionEmail(Opportunity opportunity, String excpt) {
        try {
            String notificationMessage = 'E2E Access Error';
            if (opportunity != null) {
                notificationMessage += '<br/>Opportunity Id: ' + opportunity.Id;
            }
            ExceptionLogger.sendException(notificationMessage, excpt);
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E ACCESS  sendExceptionEmail(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }
}