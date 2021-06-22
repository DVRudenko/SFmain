public class ContactEmailHistoryHttpResponseGenerator implements HttpCalloutMock {
	public HttpResponse respond(HttpRequest req) {
		Map<String, String> requestBodyMap = new Map<String,String>();
		requestBodyMap.put('https://api.emarsys.net/api/v2/contact/getcontacthistory', '{"replyCode":0,"replyText":"OK","data":[{"emailId":120302,' + 
				'"contactId":"371354459","launch_date":"2017-02-15 08:15:00","delivery_status":"launched","bounce_status":"","launchListId":"1"}]}');
        requestBodyMap.put('https://api.emarsys.net/api/v2/contact/?create_if_not_exists=1', '{"replyCode":0,"replyText":"OK","data":{"ids":["371354459"]}}');
        requestBodyMap.put('https://api.emarsys.net/api/v2/email/120302', '{"replyCode": 0,"replyText": "OK","data": {"id": "12345","root_campaign_id": "12345",' +
                '"language": "en","name": "funny_email","deleted": "","fromemail_host": "emarsys","fromemail": "loki@example.com",' +     
                '"fromname": "Loki","subject": "I\'m alive","email_category": "111111111","filter": "333333333","exclude_filter": 0,"contactlist": "0",' + 
                '"exclude_contactlist": 0,"additional_linktracking_parameters": "","cc_list": 564365356,"html_source": "<html>Hello $First Name$...</html>",' +
                '"text_source": "Hello $First Name$...","template": "0","unsubscribe": "y","browse": "y","status": "3","api_status": "2","api_error": "0",' + 
                '"external_event_id": null,"text_only": "n","source": "api","version_name": "Version A"}}');
    	HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
    	res.setBody(requestBodyMap.get(req.getEndpoint()));
    	res.setStatusCode(200);
    return res;    
    }
}