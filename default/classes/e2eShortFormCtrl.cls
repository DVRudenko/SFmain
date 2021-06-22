public class e2eShortFormCtrl {
	public String lastName {get; set;}
	public String companyName {get; set;}
	public String phoneNumber {get; set;}
	public String email {get; set;}
	public String news {get; set;}
    public String utm_campaign {get; set;}
    public String utm_content {get; set;}
    public String utm_medium {get; set;}
    public String utm_term {get; set;}
    public String utm_source {get; set;}
    public String utm_url {get; set;}
    public String utm_placement {get; set;}

    public e2eShortFormCtrl() {}

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : data initialization
    *  CreatedDate     : 04/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        this.utm_campaign = ApexPages.currentPage().getparameters().get('utm_campaign');
        this.utm_content = ApexPages.currentPage().getparameters().get('utm_content');
        this.utm_medium = ApexPages.currentPage().getparameters().get('utm_medium');
        this.utm_term = ApexPages.currentPage().getparameters().get('utm_term');
        this.utm_source = ApexPages.currentPage().getparameters().get('utm_source');
        this.utm_url = ApexPages.currentPage().getparameters().get('utm_url');
        this.utm_placement = ApexPages.currentPage().getparameters().get('utm_placement');
    }


    /*******************************************************************************
    *  Name            : 
    *  Summary         :     
    *  CreatedDate     : 
    *  ModifiedDate    : 
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public void validateRequiredFields() {
    	List<String> requiredFieldsList = new List<String>{
            this.lastName,
            this.companyName,
            this.phoneNumber,
            this.email
        };

        for (String requiredField : requiredFieldsList) {
            if ( ! validateRequiredFields(requiredField)) {
                throw new E2EShortFormException('Gelieve alle verplichte velden in te vullen.');
            }
        }
    }


    /*******************************************************************************
    *  Name            : validateRequiredFields(String field)
    *  Summary         : validate required fields    
    *  CreatedDate     : 04/06/2018
    *  Parameters      : 
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateRequiredFields(String field) {
        if (field != null && field != '') {
            return true;
        } else {
            return false;
        }
    }


    /*******************************************************************************
    *  Name            : getUserIPAddress()
    *  Summary         : get user ip address    
    *  CreatedDate     : 05/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String getUserIPAddress() {
        String ipAddress = '';    
        // True-Client-IP has the value when the request is coming via the caching integration.
        ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');

        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ipAddress == '' || ipAddress == null) {
         	ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }	// get IP address when no caching (sandbox, dev, secure urls) 

        if (ipAddress == '' || ipAddress == null) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } 	// get IP address from standard header if proxy in use
        return ipAddress;
    }


    /*******************************************************************************
    *  Name            : createLead()
    *  Summary         : Create lead     
    *  CreatedDate     : 05/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference createLead() {
    	try {
    		validateRequiredFields();
    		String ipAddress = getUserIPAddress();

			RecordType endkundeRecordType = [SELECT Id FROM RecordType WHERE Name = 'Endkunde' AND sObjectType = 'Lead' LIMIT 1];
			Lead newLead = new Lead(
				LastName = this.lastName,
				Company = this.companyName,
				Phone = this.phoneNumber,
				Email = this.email,
				Country = 'Netherlands',
				RecordTypeId = endkundeRecordType.Id,
				LeadSource = 'e2e_mobile',
				Sec_Channel__c = 'Inbound',
				Channel__c = 'Internet',
				Visitor_ID__c = ipAddress,
				Is_External__c = true,
                Utm_campaign__c = this.utm_campaign,
                Utm_content__c = this.utm_content,
                Utm_medium__c = this.utm_medium,
                Utm_term__c = this.utm_term,
                Utm_source__c = this.utm_source,
                Utm_url__c = this.utm_url,
                Utm_placement__c = this.utm_placement
			);
			insert newLead;

            this.lastName = null;
            this.companyName = null;
            this.phoneNumber = null;
            this.email = null;

			return new PageReference('https://fleetcor.nl/hartelijk-dank');
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
    	}
    }

    public class E2EShortFormException extends Exception {}
}