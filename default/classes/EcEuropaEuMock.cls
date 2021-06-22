@isTest
global class EcEuropaEuMock implements WebServiceMock {
	global void doInvoke(
	       Object stub,
	       Object request,
	       Map<String, Object> response,
	       String endpoint,
	       String soapAction,
	       String requestName,
	       String responseNS,
	       String responseName,
	       String responseType) {
	   EcEuropaEu.checkVatResponse_element respElement = new EcEuropaEu.checkVatResponse_element();
	   respElement.valid = true;
	   response.put('response_x', respElement); 
	}
}