@isTest
private class SingleRequestMockTest {

    /*******************************************************************************
    *  Name            : testSingleRequestCallout()
    *  Summary         : Test Single Request and callouts
    *  CreatedDate     : 17/10/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSingleRequestCallout() {
        SingleRequestMock fakeResponse =  new SingleRequestMock(200, 'Complete','[{"Name": "Account Test 1"}, {"Name": "Account Test 2"}]', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        List<Account> accounts = getAccounts();
        System.assertEquals(2, accounts.size());
    }

    private static List<Account> getAccounts() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://api.example.com/accounts');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        String jsonData = res.getBody();
        List<Account> accounts = (List<Account>)JSON.deserialize(jsonData, List<Account>.class);
        return accounts;
    }
}