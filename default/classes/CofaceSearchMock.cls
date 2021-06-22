@isTest
global class CofaceSearchMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest request){
    HttpResponse response = new HttpResponse();
    response.setStatus('OK');
    response.setStatusCode(200);
    response.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><searchByIdentifierResponse xmlns="http://www.iconx.biz/webservices"><searchByIdentifierResult><ResponseCode>OK</ResponseCode><ResponseText>OK</ResponseText><SearchResults><SearchResult><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><Identifiers><CompanyIdentifier><Type>0</Type><Description>NationalID</Description><Identifier>13373344</Identifier></CompanyIdentifier><CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier></CompanyIdentifier><CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier></CompanyIdentifier><CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier></CompanyIdentifier></Identifiers><RegistrationCountry>HU</RegistrationCountry><Address><Country>HU</Country><ZipCode>1054</ZipCode><City>Budapest</City><AddressItem1>Széchenyi utca 1</AddressItem1></Address><RegisteredAddress/></SearchResult></SearchResults></searchByIdentifierResult></searchByIdentifierResponse></soap:Body></soap:Envelope>');
    return response;
  }
}