public class PayUOrderGeneration {
    public PageReference redirectURL() {
    	try {
    	    String oppId = ApexPages.CurrentPage().getParameters().get('id');
	    	if (oppId == null || oppId == '') return null;
	    	Opportunity opportunity = setOpportunity(oppId);
	    	String pageName = generateE2EPageName(opportunity);
	    	String language = getLanguage(opportunity.Account.BillingCountry);
	    	Payment_Transaction__c paymentTransaction = prepareTransaction(opportunity);
	    	if (paymentTransaction == null) {
	    		return new PageReference('https://online.fleetcor.' + language + pageName + opportunity.E2E_Encoded_URL__c);
	    	}
	    	Contact contact = setContact(opportunity.OpportunityContactRoles.get(0).ContactId);
	    	String accessToken = getAccessToken(opportunity.Account.BillingCountry);
	    	String redirectUrl = generatePaymentOrder(language, pageName, accessToken, opportunity, contact, paymentTransaction);

	    	return new PageReference(redirectUrl);
    	} catch (Exception e) {
    		ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
	   		return null;  
    	}
    }


    /*******************************************************************************
    *  Name            : generatePaymentOrder(String language, String pageName, String accessToken, 
    										  Opportunity opportunity, Contact contact, Payment_Transaction__c paymentTransaction)
    *  Summary         : Generate payment url    
    *  CreatedDate     : 26/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String language - (pl or hu), 
    					 String pageName - e2e form page
    					 String accessToken - token to generate http request
    					 Opportunity opportunity
    					 Contact contact
    					 Payment_Transaction__c paymentTransaction - object to store payment transaction data
    *  Returns         : String - redirect url
    ******************************************************************************/
    private String generatePaymentOrder(String language, String pageName, String accessToken, Opportunity opportunity, Contact contact, Payment_Transaction__c paymentTransaction) {
        E2E_PayU_Settings__c payUSettings = E2E_PayU_Settings__c.getValues(opportunity.Account.BillingCountry);
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        String depositAmount = String.valueOf(opportunity.Security_Amount_To_Pay__c) + '00';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(payUSettings.API_Endpoint__c + '/api/v2_1/orders');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setBody('{"notifyUrl": "' + payUSettings.notifyUrl__c + '/services/apexrest/PayUResult", ' + 
                          '"continueUrl": "' + payUSettings.notifyUrl__c + pageName + opportunity.E2E_Encoded_URL__c + '", ' + 
                          '"customerIp": "' + ipAddress + '", ' + 
                          '"merchantPosId": "' + payUSettings.Pos_Id__c + '", ' + 
                          '"description": "Fleetcor market", ' + 
                          '"currencyCode": "' + opportunity.CurrencyIsoCode + '", ' + 
                          '"payMethods": {"payMethod": {"type": "PAYMENT_WALL"}}, ' + 
                          '"totalAmount": "' + depositAmount + '", ' + 
                          '"buyer": {"email": "' + contact.Email + '", ' + 
                                    '"phone": "' + contact.Phone + '", ' + 
                                    '"firstName": "' + contact.FirstName + '", ' + 
                                    '"lastName": "' + contact.LastName + '", ' + 
                                    '"language": "' + language + '"}, ' + 
                          '"settings": {"invoiceDisabled":"true"}, ' + 
                          '"products": [{"name": "Fleetcor fuel cards", ' + 
                                        '"unitPrice": "' + depositAmount + '", ' +
                                        '"quantity": "1"}]}');
        Http http = new Http();
        HTTPresponse response = http.send(request);
        PayUResultEntity entity = PayUResultEntity.parse(response.getBody());

        paymentTransaction.PayUOrderId__c = entity.redirectUri.substringAfter('orderId=').substringBefore('&');
        update paymentTransaction;

        return entity.redirectUri;
    }


    /*******************************************************************************
    *  Name            : getAccessToken(String country)
    *  Summary         : Get acces to sandbox/production    
    *  CreatedDate     : 26/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String country
    *  Returns         : String - access token
    ******************************************************************************/
    private String getAccessToken(String country) {
    	E2E_PayU_Settings__c payUSettings = E2E_PayU_Settings__c.getValues(country);
        String accessToken;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(payUSettings.API_Endpoint__c + '/pl/standard/user/oauth/authorize');
        request.setMethod('POST');            
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=client_credentials&client_id=' + payUSettings.Client_Id__c + 
                        '&client_secret=' + payUSettings.Client_Secret__c + 
                        '&pos_id=' + payUSettings.Pos_Id__c);
        Http http = new Http();
        HTTPresponse response = http.send(request);
        PayUResultEntity entity = PayUResultEntity.parse(response.getBody());

        accessToken = entity.access_token;
        return accessToken;
    }


    /*******************************************************************************
    *  Name            : prepareTransaction(Opportunity opportunity)
    *  Summary         : prepare client transaction
    *  CreatedDate     : 26/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : Payment_Transaction__c
    *  ****************************************************************************/
    private Payment_Transaction__c prepareTransaction(Opportunity opportunity) {
    	List<Payment_Transaction__c> checkExistTransactions = [
                SELECT Id, OrderID__c, Amount__c, Currency__c, OpportunityID__c, PayUOrderId__c
                FROM Payment_Transaction__c
                WHERE Status__c = null
                AND OpportunityID__c = :opportunity.Id
                AND Amount__c = :opportunity.Security_Amount_To_Pay__c
                LIMIT 1];

        if ( ! checkExistTransactions.isEmpty()) {
        	return checkExistTransactions.get(0);
        } else {
        	return null;
        }
    }


    /*******************************************************************************
    *  Name            : getLanguage(String country)
    *  Summary         : Generate language by country    
    *  CreatedDate     : 26/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String country
    *  Returns         : String
    ******************************************************************************/
    private String getLanguage(String country) {
    	String language;
    	if (country == 'Poland') {
        	language = 'pl';
        } else if (country == 'Hungary') {
        	language = 'hu';
        }
        return language;
    }


    /*******************************************************************************
    *  Name            : generateE2EPageName(Opportunity opportunity)
    *  Summary         : Generate e2e form page by country    
    *  CreatedDate     : 26/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : String
    ******************************************************************************/
    private String generateE2EPageName(Opportunity opportunity) {
    	String pageName;
    	if (opportunity.Account.BillingCountry == 'Poland') {
    		if (opportunity.Device_Type__c == 'Desktop') {
    			pageName = '/e2eformpl?source=';
    		} else {
    			pageName = '/e2eformmobpl?source=';
    		}
    	} else if (opportunity.Account.BillingCountry == 'Hungary') {
    		if (opportunity.Device_Type__c == 'Desktop') {
    			pageName = '/e2eformhu?source=';
    		} else {
    			pageName = '/e2eformmobhu?source=';
    		}
    	}
    	return pageName;
    }


    /*******************************************************************************
    *  Name            : setOpportunity(String oppId)
    *  Summary         : set opportunity
    *  CreatedDate     : 26/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String oppId
    *  Returns         : Opportunity
    ******************************************************************************/
    private Opportunity setOpportunity(String oppId) {
    	List<Opportunity> oppList = [
    			SELECT Security_Amount_To_Pay__c, Device_Type__c, E2E_Encoded_URL__c, CurrencyIsoCode, Account.BillingCountry, 
    				(SELECT ContactId FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
    			FROM Opportunity 
    			WHERE Id = :oppId];

    	if (! oppList.isEmpty()) {
    		return oppList.get(0);
    	} else {
    		return null;
    	}
    }


    /*******************************************************************************
    *  Name            : setContact(String conId)
    *  Summary         : set opportunity
    *  CreatedDate     : 26/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String conId
    *  Returns         : Contact
    ******************************************************************************/
    private Contact setContact(String conId) {
    	List<Contact> conList = [
    			SELECT Email, Phone, FirstName, LastName 
    			FROM Contact 
    			WHERE Id = :conId];

    	if (! conList.isEmpty()) {
    		return conList.get(0);
    	} else {
    		return null;
    	}
    }
}