/*******************************************************************************
*  FinderCreditsafeService 
*  
*  Implementation of Finder for Creditsafe Webservice. Get companies based on search request,
*  validation for Credit and Sales. Ability to process selected company for report.
*
******************************************************************************/
public class FinderCreditsafeService implements Finder {
    private Opportunity sourceObject;
    private List<CreditCompany> companiesList;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping; 
    public String userSource;
	private String apiErrorMessage;
    

    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : Set user source.
    *  CreatedDate     : 09/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String userSource - user source to set
    *  Returns         : void
    ******************************************************************************/
    public void setUserSource(String userSource) {
    	this.userSource = userSource;
    }


    /*******************************************************************************
    *  Name            : getUserSource()
    *  Summary         : Return user source.   
    *  CreatedDate     : 09/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getUserSource() {
    	return this.userSource;
    }


	/*******************************************************************************
	*  Name 		   : setMapping()
	*  Summary         : Set custom settings for Opportunity and Account
	*  CreatedDate     : 17/11/2016
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	public void setMapping() {
		try {
			accountMapping = Credit_Factory_Account__c.getInstance(CreditSafeWebservice.CREDIT_SYSTEM_NAME);
			if (accountMapping == null) {
				throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}

		try {
			opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CreditSafeWebservice.CREDIT_SYSTEM_NAME);
			if (opportunityMapping == null) {
				throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : validateMapping()
	*  Summary         : Validate custom setting for Credit System and all fields (should not be null)
	*  CreatedDate     : 17/11/2016
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	public void validateMapping() {
		List<Schema.SObjectField> accountFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Account__c');
		for (Schema.SObjectField field : accountFieldsList) {
			if (accountMapping.get(field.getDescribe().getName()) == null) {
				throw new CreditFactoryException('All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		}

		List<Schema.SObjectField> opportunityFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Opportunity__c');
		for (Schema.SObjectField field : opportunityFieldsList) {
			if (opportunityMapping.get(field.getDescribe().getName()) == null) {
				throw new CreditFactoryException('All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		}
	}


	/*******************************************************************************
	*  Name 		   : setSourceObject(String sfdcRecordId)
	*  Summary         : Get required information from object
	*  CreatedDate     : 17/11/2016
	*  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
	*  Returns         : void
	******************************************************************************/
    private void setSourceObject(String sfdcRecordId) {
		try {
			String fieldsStringForSQOL = '';
			Map<String, CreditFactory_Opportunity_SOQL__c> soqlFieldsMap = CreditFactory_Opportunity_SOQL__c.getAll();
			for (CreditFactory_Opportunity_SOQL__c field : soqlFieldsMap.values()) {
				fieldsStringForSQOL += field.Field_Name__c + ',';
			}

			String soql = '' +
			        ' SELECT ' + fieldsStringForSQOL;
			List<Schema.SObjectField> accountFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Account__c');
			for (Schema.SObjectField field : accountFieldsList) {
				Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
				if (fieldDescribe.isCustom()) {
					soql += 'Account.' + accountMapping.get(fieldDescribe.getName()) + ',';
				}
			}
			
			soql += ' Account.ShippingCountry, RecordType.Name, Account.Phone, Account.Name, Account.BillingCountryCode, Account.GFN_Nr__c' +
					' , Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, (SELECT Name FROM Attachments), (SELECT Contact.Id, ' + 
					' Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name FROM OpportunityContactRoles),' +
					' (SELECT ContentDocument.Title FROM ContentDocumentLinks)' +
			        ' FROM Opportunity' + 
			        ' WHERE Id = :sfdcRecordId';

			sourceObject = Database.query(soql);
		} catch (Exception e) {
			system.debug('Credit Factory Error === ' + e.getMessage());
			throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
    }


	/*******************************************************************************
	*  Name 		   : getSourceObject(String sfdcRecordId)
	*  Summary         : Returns sObject that we need to use for credit request
	*  CreatedDate     : 17/11/2016
	*  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
	*  Returns         : sObject
	******************************************************************************/
    public sObject getSourceObject(String sfdcRecordId) {
    	setSourceObject(sfdcRecordId);
    	return sourceObject;
    }


	/*******************************************************************************
	*  Name 		   : searchCompany(CreditSystem creditSystem)
	*  Summary         : Returns Credit Company or Companies based on search request
	*  CreatedDate     : 31/10/2016
	*  Parameters      : CreditSystem creditSystem – Creditreform settings
	*  Returns         : List<CreditCompany>
	******************************************************************************/
    public List<CreditCompany> searchCompany(CreditSystem creditSystem) {
		String serviceName = 'Creditsafe';
    	try {
			if (this.sourceObject.Account.Steuernummer__c != null) {
				this.companiesList = searchCompanyByTaxId(creditSystem);
			} else {
				this.companiesList = searchCompanyByNameAndAddress(creditSystem);
			}

			if (this.companiesList.isEmpty()) {
	        	if (this.userSource == 'E2E Long Form') {
		        	this.companiesList = searchCompanyByNameAndAddress(creditSystem);
		        } else {
					serviceName = 'CompanyInfo';
		        	searchAdditionalCompanies();
		        }
	        }
	    	return this.companiesList;
    	} catch (Exception e) {
			if (! String.isEmpty(this.apiErrorMessage)) {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.returnServiceError(serviceName) + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(CreditFactoryUtilities.returnServiceError(serviceName) + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
    	}
    }


    /*******************************************************************************
    *  Summary         : Returns Credit Company based on search by Tax Id.
    *  CreatedDate     : 10/08/2018
    *  Parameters      : CreditSystem creditSystem - Creditsafe settings
    *  Returns         : companies list
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByTaxId(CreditSystem creditSystem) {
		Http http = new Http();
		HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getEndpointUrl());
		HttpResponse authResponse = http.send(authRequest);
		this.apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(authResponse, 'auth');
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
		
		CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(authResponse.getBody());
		HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.getEndpointUrl(), this.sourceObject.Account.BillingCountryCode, 
			CreditFactoryUtilities.getKvk(this.sourceObject.Account.Steuernummer__c), null, null, null, null);
		HttpResponse searchResponse = http.send(searchRequest);
		this.apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(searchResponse, 'search');
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
		
		CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(searchResponse.getBody());
		List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, this.sourceObject.Account.BillingCountryCode);
		return creditCompaniesList;
    }


    /*******************************************************************************
    *  Summary         : Return Credit Companies based on search by Name and Address.    
    *  CreatedDate     : 10/08/2018
    *  Parameters      : creditSystem - Creditsafe settings
    *  Returns         : companies list
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByNameAndAddress(CreditSystem creditSystem) {
		Http http = new Http();
		HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getEndpointUrl());
		HttpResponse authResponse = http.send(authRequest);
		apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(authResponse, 'auth');
		if (! String.isEmpty(apiErrorMessage)) {
			throw new CreditFactoryException(apiErrorMessage);
		}

		CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(authResponse.getBody());
		HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.getEndpointUrl(), this.sourceObject.Account.BillingCountryCode, null, 
			this.sourceObject.Name, CreditFactoryUtilities.getStreet(this.sourceObject.Account.BillingStreet), this.sourceObject.Account.BillingCity, null);
		HttpResponse searchResponse = http.send(searchRequest);
		apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(searchResponse, 'search');
		if (! String.isEmpty(apiErrorMessage)) {
			throw new CreditFactoryException(apiErrorMessage);
		}
		
		CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(searchResponse.getBody());
		List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, this.sourceObject.Account.BillingCountryCode);
		return creditCompaniesList;
    }


    /*******************************************************************************
    *  Name            : searchAdditionalCompanies()
    *  Summary         : Return List of Credit Companies based on additional request
    *  CreatedDate     : 21/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void searchAdditionalCompanies() {
    	CreditSystem__c companyInfoSettings = CreditSystem__c.getInstance('CompanyInfo');

    	if (this.sourceObject.Account.BillingCountryCode != 'NL') return;
	    if (companyInfoSettings == null) return;
		
		Http http = new Http();
		HttpRequest request = CompanyInfoWebservice.generateSearchRequest(
			companyInfoSettings.Endpoint__c, 
			companyInfoSettings.UserName__c, 
			companyInfoSettings.Password__c,
			this.sourceObject.Name, 
			CreditFactoryUtilities.getStreet(this.sourceObject.Account.BillingStreet), 
			this.sourceObject.Account.BillingCity, 
			CreditFactoryUtilities.getKvk((String)this.sourceObject.getSObject('Account').get('Steuernummer__c')));
		HttpResponse response = http.send(request);
		this.apiErrorMessage = CreditFactoryUtilities.checkCompanyInfoAPIErrors(response);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
		
		String xml = response.getBody();
		Dom.Document domDoc = new Dom.Document();
		domDoc.load(xml);
		Dom.XmlNode xmldom = domDoc.getRootElement();
		this.companiesList = CompanyInfoWebservice.returnSearchCompanies(xmldom);
    }
	

	/*******************************************************************************
	*  Name            : isOrderInformationUpdated()
	*  Summary         : check order additional information    
	*  CreatedDate     : 20/12/2017
	*  ModifiedDate    : 20/12/2017
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean isOrderInformationUpdated() {
		// Now it doesn't work for Creditsafe
		return false;
	}


	/*******************************************************************************
	*  Name 		   : validate()
	*  Summary         : Validation data method.
	*  CreatedDate     : 17/11/2016
	*  ModifiedDate    : 05/11/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public void validate() {
		validateProfile();
    	validateClosedWon();
    	validateBlackList();
    	validateSEPAAttachmentExistence();
    	validateProcessedOpportunity();
		validateDesiredPaymentDetails();
    }
	
	
	/*******************************************************************************
	*  Name 		   : validateProfile()
	*  Summary         : Check that user profile has access to CF
	*  CreatedDate     : 31/10/2016
	*  ModifiedDate    : 11/11/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void validateProfile() {
		String profileError = CreditFactoryUtilities.validateProfile();
		if (profileError != null) throw new CreditFactoryException('Your profile doesn\'t have access to Credit Factory.');
	}


	/*******************************************************************************
	*  Summary         : Check if Company is in black list.
	*  CreatedDate     : 31/10/2016
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
   	private void validateBlackList() {
        Map<String, Object> resultsMap = CreditFactoryUtilities.validateBlackList(this.sourceObject);
		if (resultsMap.get('IsValid') == false) {
			throw new CreditFactoryException(String.valueOf(resultsMap.get('Error')));
        }
    }


    /*******************************************************************************
    *  Name            : validateSEPAAttachmentExistence()
    *  Summary         : check any attachments on Opportunity
    *  CreatedDate     : 29/09/2017
    *  ModifiedDate    : 09/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateSEPAAttachmentExistence() {
    	Boolean isSEPAAttachmentExist = false;
		Boolean isSEPAFileExist = false;
    	if (this.sourceObject.Zahlungsart__c == 'Lastschrift' && this.sourceObject.SEPA_Request_Approved__c != true && this.sourceObject.Einwilligung_Lastschriftverfahren__c == true) {
    		for (Attachment attachment : this.sourceObject.Attachments) {
    			if (attachment.Name.containsIgnoreCase('sepa')) {
    				isSEPAAttachmentExist = true;
					break;
    			}
    		}
			for (ContentDocumentLink file : this.sourceObject.ContentDocumentLinks) {
				if (file.ContentDocument.Title.containsIgnoreCase('sepa')) {
					isSEPAFileExist = true;
					break;
				}
			}
			if (! isSEPAFileExist && ! isSEPAAttachmentExist) {
				throw new CreditFactoryException('Please attach SEPA form to the Opportunity to launch Credit Factory.');
			}
    	}
    }


	/*******************************************************************************
	*  Name 		   : validateClosedWon()
	*  Summary         : Check if Opportunity NOT in Closed Won or Closed Lost Status
	*  CreatedDate     : 17/11/2016
	*  Parameters      : 
	*  Returns         : 
	******************************************************************************/
    private void validateClosedWon() {
    	if (sourceObject.StageName == 'Closed Won' || sourceObject.StageName == 'Closed Lost' || sourceObject.StageName == 'CreditCheck abgelehnt') {
    		throw new CreditFactoryException('Opportunity was already closed.');
    	}
    }


	/*******************************************************************************
	*  Name 		   : redirectToReport(String companyId)
	*  Summary         : Redirect to Create Report page
	*  CreatedDate     : 31/10/2016
	*  Parameters      : CreditCompany company - Credit Company from search response
	*  Returns         : PageReference
	******************************************************************************/
    public PageReference redirectToReport(CreditCompany company) {
    	String isCompanyAdditional = 'false';
    	if (company.creditSystem == 'Company.info') {
    		isCompanyAdditional = 'true';
    	}
    	
      	return new PageReference('/apex/CreditFactoryReport?creditSystemCompanyNumber=' + company.identificationnumber + '&opportunityId=' + this.sourceObject.Id +
      		'&isCompanyAdditional=' + isCompanyAdditional);
    }


    /*******************************************************************************
    *  Name            : validateProcessedOpportunity()
    *  Summary         : check processed by field    
    *  CreatedDate     : 19/01/2018
    *  ModifiedDate    : 13/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateProcessedOpportunity() {
    	if (this.sourceObject.bearbeitet_von__c != null && this.sourceObject.bearbeitet_von__c != 'Autoprocessed by E2E' && 
    			! (this.sourceObject.bearbeitet_von__c == 'Autoprocessed by Sales' && this.sourceObject.StageName == 'Pending Sales – Deposit')) {
    		throw new CreditFactoryException('Your Opportunity has already received a Credit Decision or is in the ongoing Manual Review with the Credit Team.');
    	}
    }
	
	
	/*******************************************************************************
    *  Summary         : check desired payment terms and billing period  
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void validateDesiredPaymentDetails() {
    	if (! (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7' || 
				this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7' ||
				this.sourceObject.Zahlungsziel_2__c == '30' && this.sourceObject.Rechnungsperiode_2__c == '7') &&
				(this.sourceObject.Account.BillingCountry == 'Belgium-FR' || this.sourceObject.Account.BillingCountry == 'Belgium-NL')) {
    		throw new CreditFactoryException('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+7, 30+7');
    	}
    }


	/*******************************************************************************
    *  Name            : checkDuplicates()
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 04/07/2017
    *  ModifedDate     : 05/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkDuplicates() {
		String exceptionString = CreditFactoryUtilities.checkDuplicates(this.sourceObject);
		if (String.isNotEmpty(exceptionString)) {
			this.sourceObject.StageName = 'CreditCheck';
			this.sourceObject.CF_Stage__c = 'Manual Scoring';
			update this.sourceObject;
			submitForApproval();
			throw new CreditFactoryException(exceptionString + '<br/>' + 'Opportunity was submitted for Approval');
		}
    }


    /*******************************************************************************
    *  Name            : submitForApproval()
    *  Summary         : submit opportunity for approval in case of too high monthly credit limit
    *  CreatedDate     : 11/04/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void submitForApproval() {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(this.sourceObject.Id);
        request.setSubmitterId(UserInfo.getUserId()); 
        request.setSkipEntryCriteria(false);
        Approval.process(request); 
    }
}