@isTest
global class CreditreformOrderMockAT implements HttpCalloutMock {
  	global HttpResponse respond(HTTPRequest req) {
  		String requestType = '';
  		if (req.getBody().contains('<ns:searchRequest>')) {
            requestType = 'search';
        } else if (req.getBody().contains('<ns:orderRequest>')) {
            requestType = 'order';
        } else if (req.getBody().contains('<ns:reportRequest>')) {
        	requestType = 'report';
        }

	  	Map<String, String> requestBodyMap = new Map<String, String>();
	    	requestBodyMap.put('search', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"><env:Header/><env:Body><ns2:searchResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"><ns2:header><ns2:communicationlanguage>en</ns2:communicationlanguage><ns2:transmissiontimestamp>2017-12-19T08:41:38.627+01:00</ns2:transmissiontimestamp><ns2:keylistversion>20</ns2:keylistversion><ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname><ns2:clientapplicationversion>3</ns2:clientapplicationversion><ns2:useraccount>345013323001</ns2:useraccount><ns2:responseid>c71866c2-3c33-4c76-8920-aacf04a13015</ns2:responseid></ns2:header><ns2:body><ns2:morehits>false</ns2:morehits></ns2:body></ns2:searchResponse></env:Body></env:Envelope>');
	    	requestBodyMap.put('order', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"><env:Header/><env:Body><ns2:orderResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"><ns2:header><ns2:communicationlanguage>de</ns2:communicationlanguage><ns2:transmissiontimestamp>2018-10-02T10:37:29.518+02:00</ns2:transmissiontimestamp><ns2:keylistversion>20</ns2:keylistversion><ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname><ns2:clientapplicationversion>3</ns2:clientapplicationversion><ns2:useraccount>345013323001</ns2:useraccount><ns2:responseid>9ef90a43-1213-4aee-ba5c-fc8cb8e1e22d</ns2:responseid></ns2:header><ns2:body><ns2:referencenumber>40374221</ns2:referencenumber></ns2:body></ns2:orderResponse></env:Body></env:Envelope>');
	    	requestBodyMap.put('report', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"><env:Header/><env:Body><env:Fault><env:Code><env:Value>env:Receiver</env:Value></env:Code><env:Reason><env:Text xml:lang="en">FaultMsg</env:Text></env:Reason><env:Detail><ns2:servicefault xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"><ns2:header><ns2:communicationlanguage>de</ns2:communicationlanguage><ns2:transmissiontimestamp>2018-10-04T10:10:09.458+02:00</ns2:transmissiontimestamp><ns2:keylistversion>20</ns2:keylistversion><ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname><ns2:clientapplicationversion>3</ns2:clientapplicationversion><ns2:useraccount>345013323001</ns2:useraccount><ns2:responseid>469bfd1b-9b07-4a8f-a159-5eef55c07a81</ns2:responseid></ns2:header><ns2:body><ns2:technicalerror>false</ns2:technicalerror><ns2:errorkey><ns2:key>ER-1</ns2:key><ns2:designation>Es gibt detaillierte Fehlermeldungen.</ns2:designation></ns2:errorkey><ns2:fault><ns2:errorkey><ns2:key>ER-66</ns2:key><ns2:designation>Auskunft zur Zeit nicht möglich. Bitte Auftrag erteilen.</ns2:designation></ns2:errorkey></ns2:fault></ns2:body></ns2:servicefault></env:Detail></env:Fault></env:Body></env:Envelope>');
	    HttpResponse response = new HttpResponse();
	    response.setStatus('OK');
	    response.setStatusCode(200);
	    response.setBody(requestBodyMap.get(requestType));
	    return response;
  	}
}