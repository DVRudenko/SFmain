/*******************************************************************************
*  FinderCofaceService 
*  
*  Implementation of Finder for Coface Webservice. Get companies based on search request,
*  validation for Credit and Sales. Ability to process selected company for report.
*
******************************************************************************/
public class FinderCofaceService implements Finder {
    private Opportunity sourceObject;
    private List<CreditCompany> companiesList;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
    public String userSource;
    private String apiErrorMessage;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : Set user source.
    *  CreatedDate     : 08/11/2018
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
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getUserSource() {
        return this.userSource;
    }


    /*******************************************************************************
    *  Name            : setMapping()
    *  Summary         : Set custom settings for Opportunity and Account
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void setMapping() {
        try {
            accountMapping = Credit_Factory_Account__c.getInstance(CofaceWebservice.CREDIT_SYSTEM_NAME);
            if (accountMapping == null) {
                throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }

        try {
            opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CofaceWebservice.CREDIT_SYSTEM_NAME);
            if (opportunityMapping == null) {
                throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : validateMapping()
    *  Summary         : Validate custom setting for Credit System and all fields (should not be null)
    *  CreatedDate     : 12/02/2018
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
    *  Name            : setSourceObject(String sfdcRecordId)
    *  Summary         : Get required information from object
    *  CreatedDate     : 12/02/2018
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
                    ' Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name FROM OpportunityContactRoles)' +
                    ' FROM Opportunity' + 
                    ' WHERE Id = :sfdcRecordId';

            sourceObject = Database.query(soql);
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }



    /*******************************************************************************
    *  Name            : getSourceObject(String sfdcRecordId)
    *  Summary         : Returns sObject that we need to use for credit request
    *  CreatedDate     : 12/02/2018
    *  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
    *  Returns         : sObject
    ******************************************************************************/
    public sObject getSourceObject(String sfdcRecordId) {
        setSourceObject(sfdcRecordId);
        return sourceObject;
    }


    /*******************************************************************************
    *  Name            : searchCompany(CreditSystem creditSystem)
    *  Summary         : Returns Credit Company or Companies based on search request
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 02/04/2019
    *  Parameters      : CreditSystem creditSystem – Coface settings
    *  Returns         : List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompany(CreditSystem creditSystem) {
        // Send Request
        try {
            if (this.sourceObject.Account.Steuernummer__c != null) {
                this.companiesList = searchCompanyByTaxId(creditSystem);
            } else {
                this.companiesList = searchCompanyByNameAndAddress(creditSystem);
            }
            
            return this.companiesList;
        } catch (Exception e) {
            if (! String.isEmpty(this.apiErrorMessage)) {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(this.apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.COFACE_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
					'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(CreditFactoryUtilities.COFACE_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
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
    *  CreatedDate     : 12/12/2018
    *  Parameters      : CreditSystem creditSystem - Coface settings
    *  Returns         : return List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByTaxId(CreditSystem creditSystem) {
        HttpRequest request = CofaceWebservice.generateSearchRequest(
            creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(),
            null, this.sourceObject.Account.BillingCountryCode, null, null, this.sourceObject.Account.Steuernummer__c);
        Http h = new Http();
        HttpResponse res = h.send(request);
        this.apiErrorMessage = CreditFactoryUtilities.checkCofaceAPIErrors(res);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
        
        String xml = res.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xml);
        Dom.XmlNode xmldom = domDoc.getRootElement();
        Dom.XmlNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
        return CofaceWebservice.returnSearchCompany(globalBody);
    }


    /*******************************************************************************
    *  Summary         : Return Credit Companies based on search by Name and Address.
    *  CreatedDate     : 12/12/2018
    *  Parameters      : CreditSystem creditSystem - Coface settings
    *  Returns         : return List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByNameAndAddress(CreditSystem creditSystem) {
        HttpRequest request = CofaceWebservice.generateSearchRequest(
                creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(),
                this.sourceObject.Name, this.sourceObject.Account.BillingCountryCode, 
                this.sourceObject.Account.BillingPostalCode, this.sourceObject.Account.BillingCity, null);
        Http h = new Http();
        HttpResponse res = h.send(request);        
        this.apiErrorMessage = CreditFactoryUtilities.checkCofaceAPIErrors(res);
		if (! String.isEmpty(this.apiErrorMessage)) {
			throw new CreditFactoryException(this.apiErrorMessage);
		}
        
        String xml = res.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xml);
        Dom.XmlNode xmldom = domDoc.getRootElement();
        Dom.XmlNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
        return CofaceWebservice.returnSearchCompany(globalBody);
    }
    

    /*******************************************************************************
    *  Name            : isOrderInformationUpdated()
    *  Summary         : check order additional information    
    *  CreatedDate     : 12/02/2018
    *  ModifiedDate    : 
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isOrderInformationUpdated() {
        // Now it doesn't work for Creditsafe
        return false;
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : Validation data method.
    *  CreatedDate     : 12//2016
    *  ModifiedDate    : 05/11//2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public void validate() {
        validateProfile();
        validateClosedWon();
        validateBlackList();
        validateProcessedOpportunity();
        validateUnavailableReport();
        validateDesiredPaymentDetails();
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
    *  Summary         : Check if Company is in black list.
    *  CreatedDate     : 12/02/2018
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
    *  Summary         : check desired payment terms and billing period  
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void validateDesiredPaymentDetails() {
        if (! (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7' || 
                this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14')) {
            throw new CreditFactoryException('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+14.');
        }
    }


    /*******************************************************************************
    *  Name            : validateClosedWon()
    *  Summary         : Check if Opportunity NOT in Closed Won or Closed Lost Status
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    private void validateClosedWon() {
        if (sourceObject.StageName == 'Closed Won' || sourceObject.StageName == 'Closed Lost' || sourceObject.StageName == 'CreditCheck abgelehnt') {
            throw new CreditFactoryException('Opportunity was already closed.');
        }
    }


    /*******************************************************************************
    *  Name            : validateRequiredFields()
    *  Summary         : Check Required Fields
    *  CreatedDate     : 12/02/2018
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
    *  Name            : redirectToReport(String companyId)
    *  Summary         : Redirect to Create Report page
    *  CreatedDate     : 12/02/2018
    *  Parameters      : CreditCompany company - Credit Company from search response
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference redirectToReport(CreditCompany company) {
        return new PageReference('/apex/CreditFactoryReport?creditSystemCompanyNumber=' + company.identificationnumber + '&opportunityId=' + this.sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : validateField(String objectName, String fieldName, sObject sourceObject)
    *  Summary         : Utility method to checkfield
    *  CreatedDate     : 12/02/2018
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
    *  Name            : validateUnavailableReport()
    *  Summary         : Check Report availability after order    
    *  CreatedDate     : 25/07/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateUnavailableReport() {
        if (this.sourceObject.CF_Stage__c == 'Credit Report not available') {
            throw new CreditFactoryException('Credit Report is not available. Please refer to Credit.');
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