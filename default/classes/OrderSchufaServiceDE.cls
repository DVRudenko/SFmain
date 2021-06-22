public class OrderSchufaServiceDE implements Order {
	

    /*******************************************************************************
	*  Summary         : do order request if report is not available 
	*  CreatedDate     : 16/03/2020
	*  Parameters      : creditSystem - credit system object with Schufa credentials,
						 opportunity - opportunity for order, 
						 errorMessage - part of error message to display, 
						 internalId - null for Schufa
	*  Returns         : void
	******************************************************************************/
	public CreditCompany doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId) {
		try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            CF_Order_Notifications__c notification = CF_Order_Notifications__c.getInstance('Germany');
            if (notification.Active__c) {
                message.setToAddresses(new List<String> {notification.Email__c});
				List<OrgWideEmailAddress> addressesList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Fleetcor Deutschland GmbH' LIMIT 1];
				if (! addressesList.isEmpty()) {
					message.setOrgWideEmailAddressId(addressesList.get(0).Id);
					String city = opportunity.Account.BillingCity;
					String street = opportunity.Account.BillingStreet;
					String postalCode = opportunity.Account.BillingPostalCode;
					String address = (!String.isEmpty(city) ? city + ' ' : '') + (!String.isEmpty(street) ? street + ' ' : '') + (!String.isEmpty(postalCode) ? postalCode + ' ' : '');
					String contactName;
					String contactPhone;
					String contactEmail;
					for (OpportunityContactRole role : opportunity.OpportunityContactRoles) {
						if (role.IsPrimary == true) {
							contactName = role.Contact.LastName + ' ' + role.Contact.FirstName;
							contactPhone = role.Contact.Phone;
							contactEmail = role.Contact.Email;
							break;
						}
					}

					String body = 'Sehr geehrte Damen und Herren,</br></br>' +
							'diese Firma haben wir nicht in Ihrer Datenbank gefunden. Wir bitten Sie, die Firma für uns zu recherchieren.</br></br>' +
							'Name of the company: ' + opportunity.Name + '</br>' +
							(! String.isEmpty(address) ? 'Address: ' + address + '</br>' : '') +
							'Tax ID: ' + opportunity.Account.Steuernummer__c + '</br>' +
							(! String.isEmpty(opportunity.Account.Umsatzsteuer_ID__c) ? 'VAT ID: ' + opportunity.Account.Umsatzsteuer_ID__c + '</br>' : '') +
							'Contact Name: ' + contactName + '</br>' +
							'Contact Email: ' + contactEmail + '</br>' +
							(! String.isEmpty(contactPhone) ? 'Contact Phone: ' + contactPhone + '</br>' : '') +
							'</br>Vielen Dank im Voraus</br></br>' +
							'Fleetcor Team</br>';
					message.setHtmlBody(body);
					message.setSubject('"' + opportunity.Name + '". Bitte diese Firma recherchieren. ' + opportunity.Owner.Name);
					message.setSaveAsActivity(false);
					List<Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>();
					messagesList.add(message);
					Messaging.sendEmail(messagesList);
				}
            }
			
	        return null;
	    } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
            throw new CreditFactoryException(errorMessage + 'Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Summary         : check opportunity for sending order request    
	*  CreatedDate     : 16/03/2020
	*  Parameters      : opportunity - opportunity for order, 
						 errorMessage - part of error message to display
	*  Returns         : -
	******************************************************************************/
	public void validateOpportunity(Opportunity opportunity, String errorMessage) {
		if (errorMessage == CreditFactoryUtilities.SCHUFA_REPORT_NOT_AVAILABLE) {
			throw new CreditFactoryException(errorMessage);
		}
		else if (opportunity.CF_Stage__c == 'Pending Credit Report - Order was sent') {
			throw new CreditFactoryException(errorMessage + ' Order request already sent.');
		}
	}


	/*******************************************************************************
	*  Summary         : Update opportunity fields after succeed order request.
	*  CreatedDate     : 16/03/2020
	*  Parameters      : opportunity - opportunity to update, 
						 errorMessage - part of error message to display
	*  Returns         : -
	******************************************************************************/
	public void updateOpportunity(Opportunity opportunity, CreditCompany company, String errorMessage) {
		if (opportunity.CF_Orders__c == null) {
			opportunity.CF_Orders__c = String.valueOf(Datetime.now());
		}
		else {
			opportunity.CF_Orders__c += '\n' + String.valueOf(Datetime.now());
		}
		
		opportunity.CF_Order_Date__c = Datetime.now();
		opportunity.StageName = 'Pending Credit Report';
		opportunity.CF_Stage__c = 'Pending Credit Report - Order was sent';
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