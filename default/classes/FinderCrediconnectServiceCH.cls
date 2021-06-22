/*******************************************************************************
*  FinderCrediconnectServiceCH
*  
*  Implementation of Finder for Crediconnect Webservice. Get companies based on search request,
*  validation for Credit and Sales. Ability to process selected company for report.
*
******************************************************************************/
public class FinderCrediconnectServiceCH implements Finder {
	private Opportunity sourceObject;
    private List<CreditCompany> companiesList;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
	public String userSource;
	private String apiErrorMessage;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : Set user source.
    *  CreatedDate     : 17/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String userSource - user source
    *  Returns         : void
    ******************************************************************************/
    public void setUserSource(String userSource) {
    	this.userSource = userSource;
    }


    /*******************************************************************************
    *  Name            : getUserSource()
    *  Summary         : Return user source.
    *  CreatedDate     : 17/01/2019
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
	*  CreatedDate     : 06/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMapping() {
		try {
			this.accountMapping = Credit_Factory_Account__c.getInstance(CrediconnectWebserviceCH.CREDIT_SYSTEM_NAME);
			if (this.accountMapping == null) {
				throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}

		try {
			this.opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CrediconnectWebserviceCH.CREDIT_SYSTEM_NAME);
			if (this.opportunityMapping == null) {
				throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : validateMapping()
	*  Summary         : Validate custom setting for Credit System and all fields (should not be null)
	*  CreatedDate     : 06/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void validateMapping() {
		List<Schema.SObjectField> accountFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Account__c');
		for (Schema.SObjectField field : accountFieldsList) {
			if (this.accountMapping.get(field.getDescribe().getName()) == null) {
				throw new CreditFactoryException('All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		}

		List<Schema.SObjectField> opportunityFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Opportunity__c');
		for (Schema.SObjectField field : opportunityFieldsList) {
			if (this.opportunityMapping.get(field.getDescribe().getName()) == null) {
				throw new CreditFactoryException('All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		}
	}


	/*******************************************************************************
	*  Name 		   : setSourceObject(String sfdcRecordId)
	*  Summary         : Select required information from object
	*  CreatedDate     : 06/07/2018
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
			this.sourceObject = Database.query(soql);
		} catch (Exception e) {
			system.debug('Credit Factory Error === ' + e.getMessage());
			throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
    }


    /*******************************************************************************
	*  Name 		   : getSourceObject(String sfdcRecordId)
	*  Summary         : Returns sObject that we need to use for credit request
	*  CreatedDate     : 06/07/2018
	*  ModifiedDate    : -
	*  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
	*  Returns         : sObject
	******************************************************************************/
    public sObject getSourceObject(String sfdcRecordId) {
    	setSourceObject(sfdcRecordId);
    	return this.sourceObject;
    }


    /*******************************************************************************
	*  Name 		   : searchCompany(CreditSystem creditSystem)
	*  Summary         : Returns Credit Company or Companies based on search request
	*  CreatedDate     : 06/07/2018
	*  ModifiedDate    : 20/02/2019
	*  Parameters      : CreditSystem creditSystem – Creditreform settings
	*  Returns         : List<CreditCompany>
	******************************************************************************/
    public List<CreditCompany> searchCompany(CreditSystem creditSystem) {
    	// Send Request
    	try {
    		if (this.userSource == 'E2E Long Form') {
    			this.companiesList = searchCompanyByNameAndCity(creditSystem);
    			if (this.companiesList.isEmpty()) {
    				this.companiesList = searchCompanyByName(creditSystem);
    			}
    		} else {
		    	if (this.sourceObject.Account.Umsatzsteuer_ID__c != null) {
		    		this.companiesList = searchCompanyByVatNumber(creditSystem);
		    		if (this.companiesList.isEmpty()) {
		    			this.companiesList = searchCompanyByName(creditSystem);
		    		}
		    	} else {
		    		this.companiesList = searchCompanyByName(creditSystem);
		    	}
		    }
	    	return this.companiesList;
    	} catch (Exception e) {
			if (! String.isEmpty(this.apiErrorMessage)) {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.CREDICONNECT_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(CreditFactoryUtilities.CREDICONNECT_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException('Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
    	}
    }


    /*******************************************************************************
    *  Summary         : Returns List of Credit Companies based on search by Vat Number.
    *  CreatedDate     : 29/11/2018
    *  Parameters      : CreditSystem creditSystem - credit system settings
    *  Returns         : return List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByVatNumber(CreditSystem creditSystem) {
    	HttpRequest request = CrediconnectWebserviceCH.generateSearchRequest(
    		creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), null, this.sourceObject.Account.Umsatzsteuer_ID__c, null);
		Http h = new Http();
		HttpResponse res = h.send(request);
		this.apiErrorMessage = CreditFactoryUtilities.checkCrediconnectAPIErrors(res);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
		
        String xml = res.getBody();
        Dom.Document domDoc = new Dom.Document();
		domDoc.load(xml);
        Dom.XmlNode xmldom = domDoc.getRootElement();
        Dom.XmlNode searchResponseBody = CrediconnectWebserviceCH.returnSearchResponse(xmldom);
        return CrediconnectWebserviceCH.returnSearchedCompanies(searchResponseBody);
    }


    /*******************************************************************************
    *  Summary         : Return Credit Companies based on search by Name.
    *  CreatedDate     : 29/11/2018
    *  Parameters      : CreditSystem creditSystem - credit system settings
    *  Returns         : return List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByName(CreditSystem creditSystem) {
    	HttpRequest request = CrediconnectWebserviceCH.generateSearchRequest(
    		creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), this.sourceObject.Name, null, null);
		Http h = new Http();
		HttpResponse res = h.send(request);
		this.apiErrorMessage = CreditFactoryUtilities.checkCrediconnectAPIErrors(res);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
		
        String xml = res.getBody();
        Dom.Document domDoc = new Dom.Document();
		domDoc.load(xml);
        Dom.XmlNode xmldom = domDoc.getRootElement();
        Dom.XmlNode searchResponseBody = CrediconnectWebserviceCH.returnSearchResponse(xmldom);
        return CrediconnectWebserviceCH.returnSearchedCompanies(searchResponseBody);
    }


    /*******************************************************************************
    *  Summary         : Return Credit Companies based on search by Name and City.
    *  CreatedDate     : 20/02/2019
    *  Parameters      : CreditSystem creditSystem - credit system settings
    *  Returns         : return List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByNameAndCity(CreditSystem creditSystem) {
    	HttpRequest request = CrediconnectWebserviceCH.generateSearchRequest(
    		creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), this.sourceObject.Name, null, this.sourceObject.Account.BillingCity);
		Http h = new Http();
		HttpResponse res = h.send(request);
		this.apiErrorMessage = CreditFactoryUtilities.checkCrediconnectAPIErrors(res);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
		
        String xml = res.getBody();
        Dom.Document domDoc = new Dom.Document();
		domDoc.load(xml);
        Dom.XmlNode xmldom = domDoc.getRootElement();
        Dom.XmlNode searchResponseBody = CrediconnectWebserviceCH.returnSearchResponse(xmldom);
        return CrediconnectWebserviceCH.returnSearchedCompanies(searchResponseBody);
    }


    /*******************************************************************************
	*  Name 		   : redirectToReport(String companyId)
	*  Summary         : Redirect to Credit factory Report page
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditCompany company - Credit Company from search response
	*  Returns         : PageReference
	******************************************************************************/
    public PageReference redirectToReport(CreditCompany company) {
      	return new PageReference('/apex/CreditFactoryReport?creditSystemCompanyNumber=' + company.identificationnumber + '&opportunityId=' + this.sourceObject.Id);
    }


	/*******************************************************************************
	*  Name 		   : validate()
	*  Summary         : Validation data method.
	*  CreatedDate     : 31/10/2016
	*  ModifiedDate    : 05/11//2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public void validate() {
		validateProfile();
    	validateClosedWon();
    	validateBlackList();
    	validateBDDAttachmentExistence();
    	validateProcessedOpportunity();
		validateRequiredFields();
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
	*  Name 		   : validateClosedWon()
	*  Summary         : Check if Opportunity NOT in Closed Won or Closed Lost Status
	*  CreatedDate     : 31/10/2016
	*  Parameters      : 
	*  Returns         : 
	******************************************************************************/
    private void validateClosedWon() {
    	if (sourceObject.StageName == 'Closed Won' || sourceObject.StageName == 'Closed Lost' || sourceObject.StageName == 'CreditCheck abgelehnt') {
    		throw new CreditFactoryException('Opportunity was already closed.');
    	}
    }


	/*******************************************************************************
	*  Name 		   : validateBlackList()
	*  Summary         : Check if Company is in black list.
	*  CreatedDate     : 31/10/2016
	*  Parameters      : 
	*  Returns         : 
	******************************************************************************/
    private void validateBlackList() {
        String classStreet = CreditFactoryUtilities.getStreet(this.sourceObject.Account.BillingStreet);
        String classHousenumber = CreditFactoryUtilities.getHousenumber(this.sourceObject.Account.BillingStreet);
        String accountName = (String)this.sourceObject.getSObject('Account').get('Name');
        String gfnNumber = (String)this.sourceObject.getSObject('Account').get('GFN_Nr__c');
        String city = (String)this.sourceObject.getSObject('Account').get('BillingCity');
        String country = String.valueOf(this.sourceObject.getSObject('Account').get('BillingCountry')).substringBefore('-');
        String countryCode = String.valueOf(this.sourceObject.getSObject('Account').get('BillingCountryCode')).substring(0, 2);
        String postalCode = (String)this.sourceObject.getSObject('Account').get('BillingPostalCode');
        String accountStreetHousenumber = '';
        if (classStreet != null && classHousenumber != null) {
            accountStreetHousenumber = classStreet.toUpperCase() + ' ' + classHousenumber.toUpperCase();
        }

        List<Contact> accountContacts = [
                SELECT FirstName, LastName, Email, Phone, MobilePhone
                FROM Contact
                WHERE AccountId = :(String)this.sourceObject.get('AccountId')
                LIMIT 1000];
        List<String> contactsEmailsSet = new List<String>();
        List<String> contactsNamesSet = new List<String>();
        List<String> contactsPhonesSet = new List<String>();
        for (Contact con : accountContacts) {
        	if (con.Email != null) {
	            contactsEmailsSet.add(con.Email.toUpperCase());
	        }

	        String firstName = '';
	        if (con.FirstName != null) {
	        	firstName = con.FirstName;
	        }

	        String name1 = (firstName.toUpperCase() + ' ' + con.LastName.toUpperCase()).removeStart(' ');
	        contactsNamesSet.add(name1);
	        String name2 = (con.LastName.toUpperCase() + ' ' + firstName.toUpperCase()).removeEnd(' ');
	        contactsNamesSet.add(name2);

	        if (con.Phone != null) {
	        	contactsPhonesSet.add(con.Phone);
	        }
	        if (con.MobilePhone != null) {
	        	contactsPhonesSet.add(con.MobilePhone);
	        }
        }

        String taxId = (String)this.sourceObject.getSObject('Account').get(this.accountMapping.Tax_id__c);
        String vatNumber = (String)this.sourceObject.getSObject('Account').get(this.accountMapping.Vat_number__c);
        String tradeRegisterNumber = (String)this.sourceObject.getSObject('Account').get('HR_Abteilung_HRA_HRB_und_HR_Nummer__c');
        String iban = (String)this.sourceObject.get('IBAN__c');

        List<Credit_Black_List_Company__c> blackListCompaniesList = [
                SELECT Customer_Full_Name__c, Trade_Register_Number__c, VATReg_Number__c, Reg_Address_Address_Lines__c, 
                	  	Reg_Address_City__c, Reg_Address_Country__c, Reg_Address_Zip_Code__c, Primary_Phone__c, Primary_Email__c, 
                	  	Primary_Contact__c, IBAN__c, Name, Comment__c, TAX_ID__c
                FROM Credit_Black_List_Company__c
                WHERE Customer_Id__c != null AND Customer_Id__c = :countryCode AND
                	  	((Customer_Full_Name__c != null AND Customer_Full_Name__c = :accountName) OR 
                	  	(TAX_ID__c != null AND TAX_ID__c = :taxId) OR
                      	(VATReg_Number__c != null AND VATReg_Number__c = :vatNumber) OR
                      	(Trade_Register_Number__c != null AND Trade_Register_Number__c = :tradeRegisterNumber) OR
                      	(Reg_Address_Address_Lines__c != null AND Reg_Address_Address_Lines__c  = :accountStreetHousenumber AND
                      			Reg_Address_City__c != null AND Reg_Address_City__c = :city AND
                      			Reg_Address_Zip_Code__c != null AND Reg_Address_Zip_Code__c = :postalCode) OR
                      	(Primary_Phone__c != null AND Primary_Phone__c IN :contactsPhonesSet) OR 
                      	(Primary_Email__c != null AND Primary_Email__c IN :contactsEmailsSet) OR
                      	(Primary_Contact__c != null AND Primary_Contact__c IN :contactsNamesSet) OR
                      	(IBAN__c != null AND IBAN__c = :iban) OR
                      	Name = :gfnNumber)
                LIMIT 1];

        if ( ! blackListCompaniesList.isEmpty()) {
        	Credit_Black_List_Company__c blackListCompany = blackListCompaniesList.get(0);
        	String errorMessage = '<strong>BLACK LIST.</strong> Company found in black list. Please refer to credit. ';
            errorMessage = errorMessage + 'Click <a target="_blank" href="/' + blackListCompany.Id + '">here</a>.';

            errorMessage += '<br/><br/>Matched fields:<br/><ul>';
        	if (blackListCompany.Customer_Full_Name__c != null && blackListCompany.Customer_Full_Name__c == accountName) {
        		errorMessage += '<li>Account Name: ' + accountName + '</li>';
        	}

    		if (blackListCompany.TAX_ID__c != null && blackListCompany.TAX_ID__c == taxId) {
    			errorMessage += '<li>Tax Id: ' + taxId + '</li>';
    		}

    		if (blackListCompany.VATReg_Number__c != null && blackListCompany.VATReg_Number__c == vatNumber) {
    			errorMessage += '<li>VAT Number: ' + vatNumber + '</li>';
    		}

    		if (blackListCompany.Trade_Register_Number__c != null && blackListCompany.Trade_Register_Number__c == tradeRegisterNumber) {
    			errorMessage += '<li>Trade Register Number: ' + tradeRegisterNumber + '</li>';
    		}

    		if (blackListCompany.Reg_Address_Address_Lines__c != null && blackListCompany.Reg_Address_Address_Lines__c == accountStreetHousenumber && 
	    			blackListCompany.Reg_Address_City__c != null && blackListCompany.Reg_Address_City__c == city && 
	    			blackListCompany.Reg_Address_Zip_Code__c != null && blackListCompany.Reg_Address_Zip_Code__c == postalCode) {
    			errorMessage += '<li>Registered Address:<br/>' + accountStreetHousenumber + '<br/>' + postalCode + ' ' + city + '<br/>' + country + '</li>';
    		}

    		if (blackListCompany.Primary_Phone__c != null && contactsPhonesSet.contains(blackListCompany.Primary_Phone__c)) {
    			errorMessage += '<li>Contact Phone Number: ' + blackListCompany.Primary_Phone__c + '</li>';
    		}

    		if (blackListCompany.Primary_Email__c != null && contactsEmailsSet.contains(blackListCompany.Primary_Email__c.toUpperCase())) {
    			errorMessage += '<li>Contact Email: ' + blackListCompany.Primary_Email__c + '</li>';
    		}

    		if (blackListCompany.Primary_Contact__c != null && contactsNamesSet.contains(blackListCompany.Primary_Contact__c.toUpperCase())) {
    			errorMessage += '<li>Contact Name: ' + blackListCompany.Primary_Contact__c + '</li>';
    		}

    		if (blackListCompany.IBAN__c != null && blackListCompany.IBAN__c == iban) {
    			errorMessage += '<li>IBAN: ' + iban + '</li>';
    		}

    		if (blackListCompany.Name != null && blackListCompany.Name == gfnNumber) {
    			errorMessage += '<li>GFN Number: ' + gfnNumber + '</li>';
    		}

        	errorMessage += '<ul/>';
        	if (blackListCompany.Comment__c != null) {
	        	errorMessage += '<!--^^' + blackListCompany.Comment__c + '^^-->';
	        }

            throw new CreditFactoryException(errorMessage);
        }
    }


    /*******************************************************************************
    *  Name            : validateBDDAttachmentExistence()
    *  Summary         : Check BDD attachments on Opportunity
    *  CreatedDate     : 10/10/2017
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateBDDAttachmentExistence() {
    	Boolean isBDDAttachmentExist = false;
		Boolean isBDDFileExist = false;
    	if (this.sourceObject.Zahlungsart__c == 'Lastschrift' && this.sourceObject.Einwilligung_Lastschriftverfahren__c == true) {
    		for (Attachment attachment : this.sourceObject.Attachments) {
    			if (attachment.Name.containsIgnoreCase('BDD')) {
    				isBDDAttachmentExist = true;
					break;
    			}
    		}
			for (ContentDocumentLink file : this.sourceObject.ContentDocumentLinks) {
				if (file.ContentDocument.Title.containsIgnoreCase('BDD')) {
					isBDDFileExist = true;
					break;
				}
			}

    		if (! isBDDAttachmentExist && ! isBDDFileExist) {
	    		throw new CreditFactoryException('Please attach BDD form to the Opportunity to launch Credit Factory.');
	    	}
    	}
    }


	/*******************************************************************************
	*  Name 		   : validateRequiredFields()
	*  Summary         : Check Required Fields
	*  CreatedDate     : 31/10/2016
	*  Parameters      : 
	*  Returns         : 
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
	*  CreatedDate     : 31/10/2016
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