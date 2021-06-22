public class OrderCreditreformServiceAT implements Order {
	public String name;
	public String postalCode;
	public String city;
	public String street;
	public String houseNumber;
	public String houseNumberAffix;
	public String orderSpecifyingText;
    

    /*******************************************************************************
	*  Name            : doOrder(CreditSystem creditSystem, Opportunity opportunity)
	*  Summary         : do order request if report is not available 
	*  CreatedDate     : 15/12/2017
	*  ModifiedDate    : 18/07/2019
	*  Parameters      : CreditSystem - credit system object with Creditreform credentials,
						 Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display, String internalId - null for Creditreform
	*  Returns         : void
	******************************************************************************/
	public CreditCompany doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId) {
		String apiErrorMessage;
		try {
			setDataForRequest(opportunity, errorMessage);
    		HttpRequest request = CreditReformWebserviceAT.generateOrderRequest(creditSystem.getEndpointUrl(),
    				creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getApiKey(),
    				this.name, this.postalCode, this.city, this.street, this.houseNumber, this.orderSpecifyingText);
			Http http = new Http();
			HttpResponse response = http.send(request);
			apiErrorMessage = CreditFactoryUtilities.checkCreditreformAPIErrors(response);
			if (! String.isEmpty(apiErrorMessage)) {
				throw new CreditFactoryException(apiErrorMessage);
			}
			
			String xmlResponse = response.getBody();
	        xmlResponse = CreditReformWebserviceAT.clearSearchXML(xmlResponse);
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xmlResponse);
	        Dom.XmlNode xmldom = domDoc.getRootElement();
	        Dom.XmlNode globalBody = CreditReformWebserviceAT.returnGlobalBody(xmldom);
	        Dom.XmlNode innerBody = CreditReformWebserviceAT.returnInnerBody(globalBody);
	        String orderReferenceNumber = CreditReformWebserviceAT.returnReferenceNumber(innerBody);
	        CreditCompany company = new CreditCompany();
	        company.orderReferenceNumber = orderReferenceNumber;
	        return company;
	    } catch (Exception e) {
	    	if (! String.isEmpty(apiErrorMessage)) {
				ExceptionLogger.sendException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(errorMessage + ' ' + apiErrorMessage);
			}
			else if (e.getMessage() == 'Read timed out') {
				ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
				throw new CreditFactoryException(errorMessage + ' ' + CreditFactoryUtilities.CREFO_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
			}
			else {
				ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
				 throw new CreditFactoryException(errorMessage + 'Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
	    }
	}


	/*******************************************************************************
	*  Name            : validateOpportunity(Opportunity opportunity, String errorMessage)
	*  Summary         : check opportunity for sending order request    
	*  CreatedDate     : 21/03/2018
	*  ModifiedDate    : 21/03/2018
	*  Parameters      : Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display
	*  Returns         : void
	******************************************************************************/
	public void validateOpportunity(Opportunity opportunity, String errorMessage) {
		if (errorMessage != '') {
			if (opportunity.CF_Stage__c == 'Pending Credit Report - Order was sent' || opportunity.CF_Stage__c == 'Pending Credit Report - Additional information was sent') {
				throw new CreditFactoryException(errorMessage + ' Order request already sent.');
			}
			
			if (opportunity.Account.BillingCity == null || opportunity.Account.BillingPostalCode == null) {
				throw new CreditFactoryException(errorMessage + ' Please fill Billing City and Billing Postal Code to do order request.');
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDataForRequest(Opportunity opportunity)
	*  Summary         : prepare company data for request    
	*  CreatedDate     : 21/03/2018
	*  ModifiedDate    : 21/03/2018
	*  Parameters      : Opportunity opportunity - opportunity with fields for request, 
						 String errorMessage - part of error message to display
	*  Returns         : void
	******************************************************************************/
	public void setDataForRequest(Opportunity opportunity, String errorMessage) {
		this.name = opportunity.Name.replace('&', '&amp;');
        this.postalCode = opportunity.Account.BillingPostalCode;
        this.city = opportunity.Account.BillingCity;
        this.street = CreditFactoryUtilities.getStreet(opportunity.Account.BillingStreet);
        this.houseNumber = CreditFactoryUtilities.getHousenumber(opportunity.Account.BillingStreet);

        // automatical request with additional information
        if (errorMessage == '') {
        	String legalForm = opportunity.Account.Gesellschaftsform__c;
	        String streetAndHouseNumberWithAffix = opportunity.Account.BillingStreet;
	        String taxId = opportunity.Account.Steuernummer__c;
	        String vatNumber = opportunity.Account.Umsatzsteuer_ID__c;
	        String tradeRegisterNumber = opportunity.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;
	        String yearOfFoundation = opportunity.Account.Gruendungsjahr__c;
	        String industry = opportunity.Account.Branche_NACE__c;
	        String webSite = opportunity.Account.Website;
	        String firstName;
	        String lastName;
	        String phone;
	        String email;
	        String birthdate;
	        for (OpportunityContactRole role : opportunity.OpportunityContactRoles) {
	            if (role.IsPrimary == true) {
	                firstName = role.Contact.FirstName;
	                lastname = role.Contact.Lastname;
	                phone = role.Contact.Phone;
	                email = role.Contact.Email;
	                birthDate = String.valueOf(role.Contact.Birthdate);
	            }
	        }
	        this.orderSpecifyingText = (legalForm != null ? 'Gesellschaftsform: ' + legalForm + '\n' : '') +
	        						   (streetAndHouseNumberWithAffix != null && streetAndHouseNumberWithAffix != this.street + this.houseNumber ? 'Straße: ' + streetAndHouseNumberWithAffix + '\n' : '') +
	        						   (taxId != null ? 'Steuernummer: ' + taxId + '\n' : '') +
						               (vatNumber != null ? 'USt-IdNr.: ' + vatNumber + '\n' : '') +
						               (tradeRegisterNumber != null ? 'HR Nr.: ' + tradeRegisterNumber + '\n' : '') +
						               (yearOfFoundation != null ? 'Grundungsjahr: ' + yearOfFoundation + '\n' : '') +
						               (industry != null ? 'Branche: ' + industry + '\n' : '') + 
						               (webSite != null ? 'Webseite: ' + webSite + '\n' : '') +
						               (firstName != null ? 'Vorname: ' + firstName + '\n' : '') +
						               (lastName != null ? 'Nachname: ' + lastName + '\n' : '') +
						               (phone != null ? 'Phone: ' + phone + '\n' : '') +
						               (email != null ? 'E-mail: ' + email + '\n' : '') +
						               (birthdate != null ? 'Geburtsdatum: ' + birthdate + '\n' : '');
		    if (this.orderSpecifyingText.length() > 364) {
		    	this.orderSpecifyingText = this.orderSpecifyingText.substring(0, 364);
		    }
		}
	}


	/*******************************************************************************
	*  Summary         : Update opportunity fields after succeed order request.
	*  CreatedDate     : 29/06/2018
	*  Parameters      : opportunity - opportunity to update, 
						 errorMessage - part of error message to display
	*  Returns         : -
	******************************************************************************/
	public void updateOpportunity(Opportunity opportunity, CreditCompany company, String errorMessage) {
		opportunity.CF_Order_Reference_Number__c = company.orderReferenceNumber;
		opportunity.CF_Orders__c = company.orderReferenceNumber + ' - ' + Datetime.now();
		opportunity.StageName = 'Pending Credit Report';
		if (errorMessage != '') {
			opportunity.CF_Stage__c = 'Pending Credit Report - Order was sent';
		} else {
			opportunity.CF_Stage__c = 'Pending Credit Report - Additional information was sent';
		}
		update opportunity;
	}


	/*******************************************************************************
	*  Name            : getSuccessfulOrderStatus()
	*  Summary         : Get successful status string of order.    
	*  CreatedDate     : 17/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public String getSuccessfulOrderStatus() {
		return 'Order request was sent.';
	}
}