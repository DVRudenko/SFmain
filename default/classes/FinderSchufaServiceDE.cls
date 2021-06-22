public class FinderSchufaServiceDE implements Finder {
    private Opportunity sourceObject;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
    public String userSource;
	public String apiErrorMessage;


    /*******************************************************************************
    *  Summary         : Set user source.
    *  CreatedDate     : 03/03/2020
    *  Parameters      : userSource - user source to set
    *  Returns         : -
    ******************************************************************************/
    public void setUserSource(String userSource) {
    	this.userSource = userSource;
    }


    /*******************************************************************************
    *  Summary         : Return user source.   
    *  CreatedDate     : 03/05/2018
    *  Parameters      : -
    *  Returns         : user source
    ******************************************************************************/
    public String getUserSource() {
    	return this.userSource;
    }

	/*******************************************************************************
	*  Summary         : Set custom settings for Opportunity and Account
	*  CreatedDate     : 03/03/2020
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
	public void setMapping() {
		try {
			accountMapping = Credit_Factory_Account__c.getInstance(CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME);
			if (accountMapping == null) {
				throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}

		try {
			opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME);
			if (opportunityMapping == null) {
				throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Summary         : Validate custom setting for Credit System and all fields (should not be null)
	*  CreatedDate     : 03/03/2020
	*  Parameters      : -
	*  Returns         : -
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
	*  Summary         : Get required information from object
	*  CreatedDate     : 03/03/2020
	*  Parameters      : sfdcRecordId - id of Salesforce record
	*  Returns         : -
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
			
			soql += ' Account.ShippingCountry, RecordType.Name, Account.Phone, Account.Name, Account.GFN_Nr__c, ' + 
					' Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, Account.Gruendungsjahr__c, Account.Branche_NACE__c, ' +
					' Account.Website, Account.BillingCountryCode, (SELECT Name FROM Attachments), (SELECT Contact.Id, Contact.Email, Contact.Phone, ' + 
					' Contact.LastName, Contact.FirstName, Contact.Name, Contact.Birthdate, IsPrimary FROM OpportunityContactRoles)' +
			        ' FROM Opportunity' + 
			        ' WHERE Id = :sfdcRecordId';
			sourceObject = Database.query(soql);
		} catch (Exception e) {
			system.debug('Credit Factory Error === ' + e.getMessage());
			throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
    }


	/*******************************************************************************
	*  Summary         : Returns sObject that we need to use for credit request
	*  CreatedDate     : 03/03/2020
	*  Parameters      : sfdcRecordId - id of Salesforce record
	*  Returns         : SObject
	******************************************************************************/
    public SObject getSourceObject(String sfdcRecordId) {
    	setSourceObject(sfdcRecordId);
    	return sourceObject;
    }


	/*******************************************************************************
	*  Summary         : Searches companies based on company data 
	*  CreatedDate     : 03/03/2020
	*  Parameters      : creditSystem – Schufa settings
	*  Returns         : list of companies
	******************************************************************************/
    public List<CreditCompany> searchCompany(CreditSystem creditSystem) {
    	try {
	    	Http http = new Http();
			HttpRequest authRequest = CreditFactoryWebSchufa.generateAuthRequest(creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getEndpointUrl());
			HttpResponse authResponse = http.send(authRequest);
			apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(authResponse, 'auth');
			if (! String.isEmpty(apiErrorMessage)) {
				throw new CreditFactoryException(apiErrorMessage);
			}

			SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());
			List<CreditCompany> creditCompaniesList = searchByAllParameters(authEntity, creditSystem);
			
			if (creditCompaniesList.isEmpty()) {
				creditCompaniesList = searchByName(authEntity, creditSystem);
			}
			
			return creditCompaniesList;
    	} catch (Exception e) {
			if (! String.isEmpty(apiErrorMessage)) {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.SCHUFA_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(CreditFactoryUtilities.SCHUFA_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
    	}
    }
	
	
	/*******************************************************************************
	*  Summary         : Search by all parameters that we have
	*  CreatedDate     : 09/06/2020 by Anton Buzak
	*  Parameters      : authEntity - auth data, creditSystem - credit system credentials
	*  Returns         : list of companies
	******************************************************************************/
	private List<CreditCompany> searchByAllParameters(SchufaEntity authEntity, CreditSystem creditSystem) {
		HttpRequest searchRequest = CreditFactoryWebSchufa.generateSearchRequest(authEntity.accessToken, creditSystem.getEndpointUrl(), this.sourceObject.Name,
																		    this.sourceObject.Account.BillingCity,this.sourceObject.Credit_System_Id__c);
		Http http = new Http();
		HttpResponse searchResponse = http.send(searchRequest);
		this.apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(searchResponse, 'search');
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		SchufaEntity searchEntity = SchufaEntity.parse(searchResponse.getBody());
		List<CreditCompany> creditCompaniesList = CreditFactoryWebSchufa.returnSearchCompany(searchEntity);
		return creditCompaniesList;
	}
	
	
	/*******************************************************************************
	*  Summary         : Search by name
	*  CreatedDate     : 09/06/2020 by Anton Buzak
	*  Parameters      : authEntity - auth data, creditSystem - credit system credentials
	*  Returns         : list of companies
	******************************************************************************/
	private List<CreditCompany> searchByName(SchufaEntity authEntity, CreditSystem creditSystem) {
		HttpRequest searchRequest = CreditFactoryWebSchufa.generateSearchRequest(authEntity.accessToken, creditSystem.getEndpointUrl(), this.sourceObject.Name,
																			null, null);
		Http http = new Http();
		HttpResponse searchResponse = http.send(searchRequest);
		this.apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(searchResponse, 'search');
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}

		SchufaEntity searchEntity = SchufaEntity.parse(searchResponse.getBody());
		List<CreditCompany> creditCompaniesList = CreditFactoryWebSchufa.returnSearchCompany(searchEntity);
		return creditCompaniesList;
	}


	/*******************************************************************************
	*  Summary         : Redirect to Create Report page
	*  CreatedDate     : 03/03/2020
	*  Parameters      : company - Credit Company from search response
	*  Returns         : reference on report page
	******************************************************************************/
    public PageReference redirectToReport(CreditCompany company) {
      return new PageReference('/apex/CreditFactoryReport?creditSystemCompanyNumber=' + company.identificationnumber + '&opportunityId=' + this.sourceObject.Id);
    }


	/*******************************************************************************
	*  Summary         : Validation data method.
	*  CreatedDate     : 03/03/2020
	*  Parameters      : -
	*  Returns         : -
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
	*  Summary         : Check that user profile has access to CF
	*  CreatedDate     : 03/03/2020
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
	public void validateProfile() {
		String profileError = CreditFactoryUtilities.validateProfile();
		if (profileError != null) throw new CreditFactoryException('Your profile doesn\'t have access to Credit Factory.');
	}


	/*******************************************************************************
	*  Summary         : Check if Opportunity NOT in Closed Won or Closed Lost Status
	*  CreatedDate     : 03/03/2020
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
    private void validateClosedWon() {
    	if (sourceObject.StageName == 'Closed Won' || sourceObject.StageName == 'Closed Lost' || sourceObject.StageName == 'CreditCheck abgelehnt') {
    		throw new CreditFactoryException('Opportunity was already closed.');
    	}
    }


	/*******************************************************************************
	*  Summary         : Check if Company is in black list.
	*  CreatedDate     : 03/03/2020
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
    *  Summary         : check any attachments on Opportunity
    *  CreatedDate     : 03/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void validateSEPAAttachmentExistence() {
    	Boolean isSEPAAttachmentExist = false;
    	if (this.sourceObject.Zahlungsart__c == 'Lastschrift' && this.sourceObject.SEPA_Request_Approved__c != true && this.sourceObject.Einwilligung_Lastschriftverfahren__c == true) {
    		for (Attachment attachment : this.sourceObject.Attachments) {
    			if (attachment.Name.containsIgnoreCase('sepa')) {
    				isSEPAAttachmentExist = true;
    			}
    		}

    		if (isSEPAAttachmentExist == false) {
	    		throw new CreditFactoryException('Please attach SEPA form to the Opportunity to launch Credit Factory.');
	    	}
    	}
    }


    /*******************************************************************************
    *  Summary         : check processed by field    
    *  CreatedDate     : 03/03/2020
    *  Parameters      : -
    *  Returns         : -
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
				this.sourceObject.Zahlungsziel_2__c == '30' && this.sourceObject.Rechnungsperiode_2__c == '7')) {
    		throw new CreditFactoryException('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+7, 30+7');
    	}
    }



	/*******************************************************************************
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 03/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void checkDuplicates() {
		String exceptionString = CreditFactoryUtilities.checkDuplicates(this.sourceObject);
		if (String.isNotEmpty(exceptionString)) {
			this.sourceObject.StageName = 'CreditCheck';
			this.sourceObject.CF_Stage__c = 'Manual Scoring';
			update this.sourceObject;
			submitForApproval();
			throw new CreditFactoryException(exceptionString + '<br/>' + 'Opportunity was submitted for Approval.');
		}
    }


    /*******************************************************************************
    *  Summary         : submit opportunity for approval in case of too high monthly credit limit
    *  CreatedDate     : 03/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void submitForApproval() {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(this.sourceObject.Id);
        request.setSubmitterId(UserInfo.getUserId()); 
        request.setSkipEntryCriteria(false);
        Approval.process(request); 
    }
}