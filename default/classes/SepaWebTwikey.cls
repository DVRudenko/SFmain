public class SepaWebTwikey {


	/*******************************************************************************
    *  Summary         : send Twikey link to the customer
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : twikeySettings - twikey API settings,
					     inviteParametersMap - parameters for request
    *  Returns         : twikey entity
    ******************************************************************************/
	public TwikeyEntity inviteCustomer(Twikey__c twikeySettings, Map<String, Object> inviteParametersMap) {
		try {
			String authorization = login(twikeySettings);

			HttpRequest request = new HttpRequest();
			request.setEndpoint(twikeySettings.Endpoint__c + '/creditor/invite');
			request.setMethod('POST');
			request.setHeader('Authorization', authorization);

			String body = generateTwikeyBody(inviteParametersMap);
			request.setBody(body);

			Http http = new Http();
			HttpResponse response = http.send(request);
			TwikeyEntity twikeyEntity = TwikeyEntity.parse(response.getBody());

			logout(twikeySettings, authorization);

			return twikeyEntity;
		}
		catch (Exception e) {
			throw new TwikeyException('Twikey request failed (invite customer). ' + e.getMessage());
		}
	}


	/*******************************************************************************
    *  Summary         : generate request body
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : inviteParametersMap - parameters for request
    *  Returns         : request body
    ******************************************************************************/
	private String generateTwikeyBody(Map<String, Object> inviteParametersMap) {
		String body = '';
		for (String parameterName : inviteParametersMap.keySet()) {
			if (inviteParametersMap.get(parameterName) != null) {
				body += '&' + parameterName + '=' + EncodingUtil.urlEncode(String.valueOf(inviteParametersMap.get(parameterName)), 'UTF-8');
			}
		}

		body = body.substringAfter('&');

		return body;
	}


	/*******************************************************************************
    *  Summary         : update Twikey feed
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : twikeySettings - twikey API settings
    *  Returns         : twikey entity
    ******************************************************************************/
	public TwikeyEntity updateFeed(Twikey__c twikeySettings) {
		try {
			String authorization = login(twikeySettings);

			HttpRequest request = new HttpRequest();
			request.setEndpoint(twikeySettings.Endpoint__c + '/creditor/mandate');
			request.setMethod('GET');
			request.setHeader('Authorization', authorization);
			request.setHeader('X-RESET',  Datetime.now().addHours(-24).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));

			Http http = new Http();
			HttpResponse response = http.send(request);
			TwikeyEntity twikeyEntity = TwikeyEntity.parse(response.getBody());

			logout(twikeySettings, authorization);

			return twikeyEntity;
		}
		catch (Exception e) {
			throw new TwikeyException('Twikey request failed. (update feed). ' + e.getMessage());
		}
	}


	/*******************************************************************************
    *  Summary         : update Twikey feed
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : twikeySettings - twikey API settings,
						 mandateId - Sepa mandate id
    *  Returns         : twikey entity
    ******************************************************************************/
	public Blob retreivePdf(Twikey__c twikeySettings, String mandateId) {
		try {
			String authorization = login(twikeySettings);

			HttpRequest request = new HttpRequest();
			request.setEndpoint(twikeySettings.Endpoint__c + '/creditor/mandate/pdf?mndtId=' + mandateId);
			request.setMethod('GET');
			request.setHeader('Authorization', authorization);

			Http http = new Http();
			HttpResponse response = http.send(request);
			Blob pdfBody = response.getBodyAsBlob();

			logout(twikeySettings, authorization);

			return pdfBody;
		}
		catch (Exception e) {
			throw new TwikeyException('Twikey request failed. (retreive pdf). ' + e.getMessage());
		}
	}


	/*******************************************************************************
    *  Summary         : login to Twikey
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : twikeySettings - twikey API settings
    *  Returns         : authorization string
    ******************************************************************************/
	private String login(Twikey__c twikeySettings) {
		String authorization;
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(twikeySettings.Endpoint__c + '/creditor');
		request.setMethod('POST');
		request.setBody('apiToken=' + twikeySettings.Token__c);

		HttpResponse response = http.send(request);
		authorization = response.getHeader('Authorization');
		return authorization;
	}


	/*******************************************************************************
    *  Summary         : log out from Twikey
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : twikeySettings - twikey API settings,
						 authorization -
    *  Returns         : -
    ******************************************************************************/
	private void logout(Twikey__c twikeySettings, String authorization) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(twikeySettings.Endpoint__c + '/creditor');
		request.setMethod('GET');
		request.setBody('Authorization=' + authorization);
		http.send(request);
	}

	public class TwikeyException extends Exception {}
}