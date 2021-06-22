@isTest
global class E2EPayUMock implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest request){
		HttpResponse response = new HttpResponse();
		response.setStatus('OK');
		response.setStatusCode(200);
		response.setBody('{"order":{"orderId":"ZPW8VKNDQJ190527GUEST000P01","orderCreateDate":"2019-05-27T11:35:19.137Z","notifyUrl":"https://e2e-e2efleetcor.cs88.force.com/services/apexrest/PayUResult","customerIp":"127.0.0.1","merchantPosId":"356975","description":"Fleetcor market","currencyCode":"PLN","totalAmount":"100","buyer":{"customerId":"guest","email":"john@wick.com","phone":"654111654","firstName":"John","lastName":"Wick","language":"pl"},"payMethod":{"type":"CARD_TOKEN"},"status":"COMPLETED","products":[{"name":"Fleetcor fuel cards","unitPrice":"1000","quantity":"1"}]},"localReceiptDateTime":"2019-05-27T11:35:47.251Z","properties":[{"name":"PAYMENT_ID","value":"74590947"}]}');
		return response;
	}
}