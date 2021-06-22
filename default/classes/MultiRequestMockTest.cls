@isTest
public class MultiRequestMockTest {

    /*******************************************************************************
    *  Name            : testMultiRequestCallout()
    *  Summary         : Test Multiple Requests and callouts
    *  CreatedDate     : 17/10/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testMultiRequestCallout() {

        SingleRequestMock fakeAccountResponse = new SingleRequestMock(200, 'Complete', '[{"Name": "Account Test 1"}]', null);
        SingleRequestMock fakeContactsResponse = new SingleRequestMock(200, 'Complete', '[{"LastName": "Contact Last Name 1"}]', null);

        Map<String, HttpCalloutMock> endpointTestResponse = new Map<String, HttpCalloutMock>();
        endpointTestResponse.put('http://api.example.com/accounts', fakeAccountResponse);
        endpointTestResponse.put('http://api.example.com/contacts', fakeContactsResponse);

        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointTestResponse);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Integer result = processAccountsContacts();
        System.assertEquals(2, result);
    }

    private static String getJSON(String url) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getBody();
    }

    private static Integer processAccountsContacts() {
        String jsonData = getJSON('http://api.example.com/accounts');
        List<Account> accounts = (List<Account>)JSON.deserialize(jsonData, List<Account>.class);

        jsonData = getJSON('http://api.example.com/contacts');
        List<Contact> contacts = (List<Contact>)JSON.deserialize(jsonData, List<Contact>.class);

        Integer result = accounts.size() + contacts.size();
        return result;
    }
}