@isTest
global class ErrorCreditreformSearchMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"><env:Header/><env:Body><env:Fault><env:Code><env:Value>env:Receiver</env:Value></env:Code><env:Reason><env:Text xml:lang="en">FaultMsg</env:Text></env:Reason><env:Detail><ns2:servicefault xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"><ns2:header><ns2:communicationlanguage>en</ns2:communicationlanguage><ns2:transmissiontimestamp>2016-11-17T12:32:03.419+01:00</ns2:transmissiontimestamp><ns2:keylistversion>20</ns2:keylistversion><ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname><ns2:clientapplicationversion>3</ns2:clientapplicationversion><ns2:useraccount>345013323001</ns2:useraccount><ns2:responseid>707bb2ab-2486-4d51-9896-2f985e7f9910</ns2:responseid></ns2:header><ns2:body><ns2:technicalerror>false</ns2:technicalerror><ns2:errorkey><ns2:key>ER-1</ns2:key><ns2:designation>There are detailed error messages.</ns2:designation></ns2:errorkey><ns2:fault><ns2:errorkey><ns2:key>ER-22</ns2:key><ns2:designation>The maximum length of this field is exceeded.</ns2:designation></ns2:errorkey><ns2:errorfield>street</ns2:errorfield></ns2:fault></ns2:body></ns2:servicefault></env:Detail></env:Fault></env:Body></env:Envelope>');
    return res;
  }
}