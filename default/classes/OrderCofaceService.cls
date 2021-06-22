public class OrderCofaceService implements Order {
	public String orderReferenceNumber;
    

    /*******************************************************************************
	*  Summary         : Do order request if report is not available or company doen't exist.
	*  CreatedDate     : 29/06/2018
	*  Parameters      : сreditSystem - credit system object with Coface credentials,
						 opportunity - opportunity for order, 
						 errorMessage - part of error message to display, 
						 internalId - Coface internal Id
	*  Returns         : void
	******************************************************************************/
	public CreditCompany doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId) {
		try {
			CreditCompany company = new CreditCompany();
    		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            CF_Order_Notifications__c notification = CF_Order_Notifications__c.getInstance('Hungary');
            if (notification.Active__c) {
                message.setToAddresses(new List<String> {notification.Email__c});
				List<OrgWideEmailAddress> addressesList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Credit Hungary' LIMIT 1];
				if (! addressesList.isEmpty()) {
					String nationalId;
					if (internalId != null) {
						nationalId = internalId;
					}
					else if (opportunity.Account.Steuernummer__c != null && opportunity.Account.Steuernummer__c.length() >= 8) {
						nationalId = opportunity.Account.Steuernummer__c.substring(0, 8);
					}
					else {
						nationalId = opportunity.Account.Steuernummer__c;
					}
					
					if (nationalId == null) {
						throw new CreditFactoryException('');
					}

					message.setOrgWideEmailAddressId(addressesList.get(0).Id);
					String body = 'Dear Coface, </br>Please make this report about the company ' + opportunity.Name + ' with National ID ' + 
								  nationalId + ' available as soon as possible. </br></br>Regards, </br>Fleetcor Hungary';
					message.setHtmlBody(body);
					message.setSubject('Report unavailable');
					message.setSaveAsActivity(false);
					List<Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>();
					messagesList.add(message);
					Messaging.sendEmail(messagesList);
					company.orderReferenceNumber = nationalId;
				}
            }
			
	        return company;
	    } catch (Exception e) {
	    	throw new CreditFactoryException(errorMessage + ' Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Summary         : Check opportunity for sending order request.
	*  CreatedDate     : 29/06/2018
	*  Parameters      : opportunity - opportunity for order, 
						 errorMessage - part of error message to display
	*  Returns         : -
	******************************************************************************/
	public void validateOpportunity(Opportunity opportunity, String errorMessage) {
		if (opportunity.CF_Stage__c == 'Pending Credit Report - Order was sent') {
			throw new CreditFactoryException(errorMessage + ' Order request already sent.');
		}
		else {
			if (errorMessage == 'No matches for this company.' || errorMessage == 'Company is not in the list. ') {
				throw new CreditFactoryException(errorMessage + ' Please approve Tax Id to send order: ' + opportunity.Account.Steuernummer__c + '.');
			}
		}
	}


	/*******************************************************************************
	*  Summary         : Update opportunity fields after succeed order request.
	*  CreatedDate     : 29/06/2018
	*  Parameters      : opportunity - opportunity to update, 
						 referenceNumber - reference number, 
						 orderReferenceNumber
	*  Returns         : -
	******************************************************************************/
	public void updateOpportunity(Opportunity opportunity, CreditCompany company, String errorMessage) {
		opportunity.CF_Order_Reference_Number__c = company.orderReferenceNumber;
		opportunity.CF_Orders__c = company.orderReferenceNumber + ' - ' + Datetime.now();
		opportunity.StageName = 'Pending Credit Report';
		opportunity.CF_Stage__c = 'Pending Credit Report - Order was sent';
		opportunity.CF_Order_Date__c = Datetime.now();
		update opportunity;
	}


	/*******************************************************************************
	*  Summary         : Get successful status string of order.    
	*  CreatedDate     : 17/08/2018
	*  Parameters      : -
	*  Returns         : order status
	******************************************************************************/
	public String getSuccessfulOrderStatus() {
		return 'Order request was sent.';
	}
}