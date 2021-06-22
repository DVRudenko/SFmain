/*******************************************************************************
*  FinderCreditreformServiceLU
*  
*  Implementation of Finder for CreditreformLU Webservice. Get companies based on search request,
*  validation for Credit and Sales. Ability to process selected company for report.
*
******************************************************************************/
public class FinderCreditreformServiceLU implements Finder {
    private Opportunity sourceObject;
    private List<CreditCompany> companiesList;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
    public String userSource;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : Set user source.
    *  CreatedDate     : 13/11/2018
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
    *  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	public void setMapping() {
		try {
			accountMapping = Credit_Factory_Account__c.getInstance(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME);
			if (accountMapping == null) {
				throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}

		try {
			opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME);
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
			
			soql += ' Account.ShippingCountry, RecordType.Name, Account.Phone, Account.Name, Account.GFN_Nr__c, ' + 
					' Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, Account.Gruendungsjahr__c, Account.Branche_NACE__c, ' +
					' Account.Website, Account.BillingCountryCode, (SELECT Name FROM Attachments), (SELECT Contact.Id, Contact.Email, Contact.Phone, ' + 
					' Contact.LastName, Contact.FirstName, Contact.Name, Contact.Birthdate, IsPrimary FROM OpportunityContactRoles),' +
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : CreditSystem creditSystem – Creditreform settings
	*  Returns         : List<CreditCompany>
	******************************************************************************/
    public List<CreditCompany> searchCompany(CreditSystem creditSystem) {
    	String apiErrorMessage;
    	try {
	    	HttpRequest request = CreditReformWebserviceLU.generateSearchRequest(
	    		creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getApiKey(),
	    		this.sourceObject.Name, CreditFactoryUtilities.getStreet(this.sourceObject.Account.BillingStreet), 
	    		this.sourceObject.Account.BillingCity, CreditFactoryUtilities.getHousenumber(this.sourceObject.Account.BillingStreet), 
	    		this.sourceObject.Credit_System_Id__c);
			Http h = new Http();
			HttpResponse res = h.send(request);
			apiErrorMessage = CreditFactoryUtilities.checkCreditreformAPIErrors(res);
			if (! String.isEmpty(apiErrorMessage)) {
				throw new CreditFactoryException(apiErrorMessage);
			}
			
	        String xml = res.getBody();
	        xml = CreditReformWebserviceLU.clearSearchXML(xml);
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xml);
	        Dom.XmlNode xmldom = domDoc.getRootElement();
	        Dom.XmlNode globalBody = CreditReformWebserviceLU.returnGlobalBody(xmldom);
	        Dom.XmlNode innerBody = CreditReformWebserviceLU.returnInnerBody(globalBody);
	        this.companiesList = CreditReformWebserviceLU.returnSearchCompany(innerBody);
	    	return this.companiesList;
    	} catch (Exception e) {
			if (! String.isEmpty(apiErrorMessage)) {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.CREFO_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(CreditFactoryUtilities.CREFO_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
    	}
    }


	/*******************************************************************************s
	*  Summary         : Redirect to Create Report page
	*  CreatedDate     : 13/11/2018
	*  Parameters      : company - Credit Company from search response
	*  Returns         : url of report page
	******************************************************************************/
    public PageReference redirectToReport(CreditCompany company) {
    	if (company.status == 'inactive' && this.userSource != 'E2E Long Form') {
        	try {
	            this.sourceObject.StageName = 'Closed Lost';
				this.sourceObject.Gruende_verloren__c = 'Refused Credit';
				this.sourceObject.Kredit_Entscheidung__c = 'Abgelehnt';
				update this.sourceObject;
	            CreditFactoryUtilities.displayMessage('error', 'Selected company is not active. Opportunity is closed as lost.');
	          	return null;
	        } catch (Exception e) {
	            throw new CreditFactoryException('Select Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	        }
    	}

    	return new PageReference('/apex/CreditFactoryReport?creditSystemCompanyNumber=' + company.identificationnumber + '&opportunityId=' + this.sourceObject.Id);
    }


	/*******************************************************************************
	*  Name 		   : validate()
	*  Summary         : Validation data method.
	*  CreatedDate     : 13/11/2018
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
		validateRequiredFields();
		validateDesiredPaymentDetails();
    }
	
	
	/*******************************************************************************
	*  Name 		   : validateProfile()
	*  Summary         : Check that user profile has access to CF
	*  CreatedDate     : 31/10/2016
	*  ModifiedDate    : 05/11/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void validateProfile() {
		String profileError = CreditFactoryUtilities.validateProfile();
		if (profileError != null) throw new CreditFactoryException('Your profile doesn\'t have access to Credit Factory.');
	}


	/*******************************************************************************
	*  Name 		   : validateClosedWon()
	*  Summary         : Check if Opportunity NOT in Closed Won or Closed Lost Status
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    private void validateClosedWon() {
    	if (sourceObject.StageName == 'Closed Won' || sourceObject.StageName == 'Closed Lost' || sourceObject.StageName == 'CreditCheck abgelehnt') {
    		throw new CreditFactoryException('Opportunity was already closed.');
    	}
    }


	/*******************************************************************************
	*  Summary         : Check if Company is in black list.
	*  CreatedDate     : 13/11/2018
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
    		if (! isSEPAAttachmentExist && ! isSEPAFileExist) {
	    		throw new CreditFactoryException('Please attach SEPA form to the Opportunity to launch Credit Factory.');
	    	}
    	}
    }
	

	/*******************************************************************************
	*  Name 		   : validateRequiredFields()
	*  Summary         : Check Required Fields
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    private void validateRequiredFields() {
        String requiredFields = '';

        if (sourceObject.RecordType.Name == 'Euroshell' && sourceObject.Probability >= 40) {
        	try {
        		requiredFields += validateField('Account','Business_Street__c',sourceObject);
	        	requiredFields += validateField('Account','Postal_Code__c',sourceObject);
	        	requiredFields += validateField('Account','City__c',sourceObject);
	        	requiredFields += validateField('Account','Country__c',sourceObject);
	        	requiredFields += validateField('Account','Type__c',sourceObject);
	            requiredFields += validateField('Account','Number_of_employees__c',sourceObject);	
	        	requiredFields += validateField('Opportunity','Fuel_consumption_l_month__c',sourceObject);
	        	requiredFields += validateField('Opportunity','Product__c',sourceObject);
	        	requiredFields += validateField('Opportunity','Number_of_Cards__c',sourceObject);
	        	requiredFields += validateField('Opportunity','Current_Payment_Method__c',sourceObject);
        	} catch (Exception e) {
	        	CreditFactoryUtilities.displayMessage('error','Error parsing sObject. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	        	system.debug('Credit Factory === ' + e.getMessage());
        	}
        } else if (sourceObject.RecordType.Name == 'Euroshell' && sourceObject.Probability >= 15) {
        	try {
	            requiredFields += validateField('Opportunity','Current_Payment_Method__c',sourceObject);
	            requiredFields += validateField('Opportunity','Payment_Terms__c',sourceObject);
	            requiredFields += validateField('Opportunity','Product__c',sourceObject);
	            requiredFields += validateField('Opportunity','Payment_Method__c',sourceObject);
	            requiredFields += validateField('Opportunity','Number_of_Cards__c',sourceObject);	
        	} catch (Exception e) {
	        	CreditFactoryUtilities.displayMessage('error','Error parsing sObject. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	        	system.debug('Credit Factory === ' + e.getMessage());	
        	}
        }
        if (requiredFields != '') {
        	requiredFields = requiredFields.removeEnd(', ');
        	throw new CreditFactoryException('Please fill required fields: ' + requiredFields);
        }
    }


	/*******************************************************************************
	*  Name 		   : validateField(String objectName, String fieldName, sObject sourceObject)
	*  Summary         : Utility method to checkfield
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : objectName – name of sObject, fieldName – API Name of field, sourceObject – sObject
	*  Returns         : String – error message
	******************************************************************************/
    public String validateField(String objectName, String fieldName, sObject sourceObject) {
    	String errorMessage = '';

    	if (objectName == 'Opportunity') {
		    if (sourceObject.get((String)opportunityMapping.get(fieldName)) == null) {
		    	String label = CreditFactoryUtilities.returnLabelOfField(objectName,(String)opportunityMapping.get(fieldName));
		    	errorMessage = objectName.capitalize() + ': ' + label + ', ';
		    }
    	} else if (objectName == 'Account') {
		    if (sourceObject.getSObject('Account').get((String)accountMapping.get(fieldName)) == null) {
		    	String label = CreditFactoryUtilities.returnLabelOfField(objectName,(String)accountMapping.get(fieldName));
		    	errorMessage = objectName.capitalize() + ': ' + label + ', ';
		    }	
    	}

    	return errorMessage;
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
				this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7')) {
    		throw new CreditFactoryException('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+7');
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
			throw new CreditFactoryException(exceptionString + '<br/>' + 'Opportunity was submitted for Approval.');
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