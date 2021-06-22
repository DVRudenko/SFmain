@isTest
private class CreditFactoryPdfScheduleTest {
    
    
    /*******************************************************************************
    *  Summary         : create test data for all methods   
    *  Created         : 17/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @TestSetup
    static void createDataForAllTests() {
        List<CreditSystem__c> creditSystemList = new List<CreditSystem__c>();
        CreditSystem__c crifSettings = CreditFactoryTestUtils.generateCrifSetting();
        creditSystemList.add(crifSettings);
        CreditSystem__c schufaSettings = CreditFactoryTestUtils.generateSchufaSetting();
        creditSystemList.add(schufaSettings);
        CreditSystem__c creditSafeSettings = CreditFactoryTestUtils.generateCreditsafeSetting();
        creditSystemList.add(creditSafeSettings);
        CreditSystem__c cribisSettings = CreditFactoryTestUtils.generateCribisSetting();
        creditSystemList.add(cribisSettings);
        CreditSystem__c cofaceSettings = CreditFactoryTestUtils.generateCofaceSetting();
        creditSystemList.add(cofaceSettings);
        insert creditSystemList;
    } 


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request
    *  CreatedDate     : 17/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationPL() {
    	Account account = CreditFactoryTestUtils.generateAccountPL();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityPL();
        opportunity.AccountId = account.Id;
        insert opportunity;
        
        Test.startTest();
            SingleRequestMock pdfMock = new SingleRequestMock(200, 'Complete', 'TestStringToBlob', null);
            Test.setMock(HttpCalloutMock.class, pdfMock);
            Blob responseBody = Blob.valueOf('<test></test>');
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('4358000002428652', null, opportunity.Id, responseBody, 'Poland');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE (Name = 'CrifReport.pdf' OR Name = 'KrdReport.xml') AND ParentId = :opportunity.Id];

       	System.assertEquals(2, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Invalid Pdf request
    *  CreatedDate     : 17/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testInvalidPdfCreationPL() {
        Account account = CreditFactoryTestUtils.generateAccountPL();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityPL();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            Blob responseBody = Blob.valueOf('<test></test>');
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('4358000002428652', null, opportunity.Id, responseBody, 'Poland');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE (Name = 'CrifReport.pdf' OR Name = 'KrdReport.xml') AND ParentId = :opportunity.Id];

       	System.assertEquals(0, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for DE
    *  CreatedDate     : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationDE() {
    	Account account = CreditFactoryTestUtils.generateAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityDE();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock schufaAuthMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', schufaAuthMock);
            SingleRequestMock schufaPdfMock = new SingleRequestMock(200, 'Complete', '{"documentBytes": 18000}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/coredata/economy/pdf', schufaPdfMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('1645768', null, opportunity.Id, null, 'Germany');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'SchufaReport.pdf' AND ParentId = :opportunity.Id];

       	System.assertEquals(1, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for NL
    *  CreatedDate     : 14/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationNL() {
    	Account account = CreditFactoryTestUtils.generateAccountNL();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityNL();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock creditSafeAuthMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', creditSafeAuthMock);
            SingleRequestMock creditSafePdfMock = new SingleRequestMock(200, 'Complete', 'test PDF', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL-X-502603400000', creditSafePdfMock);
            SingleRequestMock creditSafePdfMock2 = new SingleRequestMock(200, 'Complete', 'test PDF 2', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/NL-X-502603500000', creditSafePdfMock2);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('NL-X-502603400000', 'NL-X-502603500000', opportunity.Id, null, 'Netherlands');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE (Name = 'CreditsafeReport.pdf' OR Name = 'CreditsafeReportParent.pdf') AND ParentId = :opportunity.Id];

       	System.assertEquals(2, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for BE
    *  CreatedDate     : 22/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationBE() {
    	Account account = CreditFactoryTestUtils.generateAccountBE();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityBE();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock creditSafeAuthMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', creditSafeAuthMock);
            SingleRequestMock creditSafePdfMock = new SingleRequestMock(200, 'Complete', 'test PDF', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/BE-X-428089605', creditSafePdfMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('BE-X-428089605', 'BE-X-428089605', opportunity.Id, null, 'Belgium-NL');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CreditsafeReport.pdf' AND ParentId = :opportunity.Id];

       	System.assertEquals(1, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for FR
    *  CreatedDate     : 02/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationFR() {
    	Account account = CreditFactoryTestUtils.generateAccountFR();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityFR();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock creditSafeAuthMock = new SingleRequestMock(200, 'Complete', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/authenticate', creditSafeAuthMock);
            SingleRequestMock creditSafePdfMock = new SingleRequestMock(200, 'Complete', 'test PDF', null);
            mocksMap.put('https://connect.sandbox.creditsafe.com/v1/companies/FR-X-537643967', creditSafePdfMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('FR-X-537643967', 'FR-X-537643967', opportunity.Id, null, 'France');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CreditsafeReport.pdf' AND ParentId = :opportunity.Id];

       	System.assertEquals(1, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for SK
    *  CreatedDate     : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationSK() {
    	Account account = CreditFactoryTestUtils.generateAccountSK();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunitySK();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            SingleRequestMock cribisMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><GetDocumentByTicketResponse xmlns="https://ws.urplus.sk"><GetDocumentByTicketResult><Status><Code>101</Code><Description>OK</Description></Status><Data><Document xmlns="urn:crif-cribiscz-GetDocumentReport:2018-11-06">test pdf</Document><Requested xmlns="urn:crif-cribiscz-GetDocumentReport:2018-11-06">2020-10-01T14:08:44.76</Requested><Created xmlns="urn:crif-cribiscz-GetDocumentReport:2018-11-06">2020-10-01T14:08:49.4</Created></Data></GetDocumentByTicketResult></GetDocumentByTicketResponse></soap:Body></soap:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, cribisMock);
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('e908ead4-de03-eb11-80f5-005056b26407', null, opportunity.Id, null, 'Slovakia');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CribisReport.pdf' AND ParentId = :opportunity.Id];

       	System.assertEquals(1, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for HU
    *  CreatedDate     : 21/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationHU() {
    	Account account = CreditFactoryTestUtils.generateAccountHU();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityHU();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            SingleRequestMock cofaceMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><immediateOrderResponse xmlns="http://www.iconx.biz/webservices"><immediateOrderResult><ResponseCode>OK</ResponseCode><ResponseText>OK</ResponseText><OrderStatus><ProviderOrderReference>2771335</ProviderOrderReference><ProductCode>761</ProductCode><Provider><PartyID>CIC_HU</PartyID><Name>Coface Hungary Credit Management Services Kft.</Name><ContactInformation><Country>HU</Country><City>Budapest</City></ContactInformation><Email>orders-hungary@coface.com</Email><WebAddress>http://www.coface.hu</WebAddress></Provider><Consumer><Name>FleetCor Hungary Korlátolt Felelősségű Társaság</Name><ContactInformation><Country>HU</Country><City>Budapest</City></ContactInformation><WebAddress>fleetcor.hu</WebAddress></Consumer><OriginalRequest><Name/><PrincipalAddress><ZipCode/><AddressItem1/></PrincipalAddress><DateOfValidity>0001-01-01T00:00:00.0+01:00</DateOfValidity><DateOfLastUpdate>0001-01-01T00:00:00.0+01:00</DateOfLastUpdate><DateOfLastBalanceSheet>0001-01-01T00:00:00.0+01:00</DateOfLastBalanceSheet></OriginalRequest><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress><Country>HU</Country><ZipCode>1036</ZipCode><City>Budapest</City><AddressItem1>Lajos utca 74-76.</AddressItem1><Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number></Telephone><Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number></Fax></PrincipalAddress><RegisteredAddress/><LegalForm><LegalFormCode>300</LegalFormCode><LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers><CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier></CompanyIdentifier><CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier></CompanyIdentifier><CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier></CompanyIdentifier><CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier></CompanyIdentifier></Identifiers><Activities><Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription></Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><ReportLanguage>EN</ReportLanguage><StatusCode>Finished</StatusCode><Ordered>2018-03-07T14:47:03.000+01:00</Ordered><RequestedDelivery>2018-03-07T15:47:00.000+01:00</RequestedDelivery><Delivered>2018-03-07T14:47:03.000+01:00</Delivered><MaximumCreditRecommendationAmount>-1.0</MaximumCreditRecommendationAmount><CompanyRegistrationDate>0001-01-01T00:00:00.0+01:00</CompanyRegistrationDate><ReportMimeType>application/pdf</ReportMimeType></OrderStatus><Report><ProviderOrderReference>2771335</ProviderOrderReference><ProductCode>761</ProductCode><Provider><PartyID>CIC_HU</PartyID><Name>Coface Hungary Credit Management Services Kft.</Name><ContactInformation><Country>HU</Country><City>Budapest</City></ContactInformation><Email>orders-hungary@coface.com</Email><WebAddress>http://www.coface.hu</WebAddress></Provider><Consumer><Name>FleetCor Hungary Korlátolt Felelősségű Társaság</Name><ContactInformation><Country>HU</Country><City>Budapest</City></ContactInformation><WebAddress>fleetcor.hu</WebAddress></Consumer><OriginalRequest><Name/><PrincipalAddress><ZipCode/><AddressItem1/></PrincipalAddress><DateOfValidity>0001-01-01T00:00:00.0+01:00</DateOfValidity><DateOfLastUpdate>0001-01-01T00:00:00.0+01:00</DateOfLastUpdate><DateOfLastBalanceSheet>0001-01-01T00:00:00.0+01:00</DateOfLastBalanceSheet></OriginalRequest><Company><Name>Hild Ingatlanbefektető Korlátolt Felelősségű Társaság</Name><SortName>Hild Ingatlanbefektető Kft.</SortName><InternalID>69590780</InternalID><RegistrationCountry>HU</RegistrationCountry><PrincipalAddress><Country>HU</Country><ZipCode>1036</ZipCode><City>Budapest</City><AddressItem1>Lajos utca 74-76.</AddressItem1><Telephone><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875600</Number></Telephone><Fax><InternationalCode>36</InternationalCode><AreaCode>1</AreaCode><Number>8875601</Number></Fax></PrincipalAddress><RegisteredAddress/><LegalForm><LegalFormCode>300</LegalFormCode><LegalFormText>Limited Liability Company</LegalFormText></LegalForm><Identifiers><CompanyIdentifier><Type>0</Type><Description>National ID</Description><Identifier>13373344</Identifier></CompanyIdentifier><CompanyIdentifier><Type>1</Type><Description>Registration Number</Description><Identifier>0109731931</Identifier></CompanyIdentifier><CompanyIdentifier><Type>2</Type><Description>Easy Number</Description><Identifier>00003123942472</Identifier></CompanyIdentifier><CompanyIdentifier><Type>120</Type><Description>VAT number</Description><Identifier>13373344-2-41</Identifier></CompanyIdentifier></Identifiers><Activities><Activity><Code>7022</Code><Type>NACE</Type><CodeDescription>Business and other management consultancy activities</CodeDescription></Activity></Activities><DateOfValidity>2017-01-17T00:00:00.000+01:00</DateOfValidity><DateOfLastUpdate>2017-06-19T00:00:00.000+02:00</DateOfLastUpdate><DateOfLastBalanceSheet>2016-12-31T00:00:00.000+01:00</DateOfLastBalanceSheet><EasyNumber>00003123942472</EasyNumber></Company><ReportLanguage>EN</ReportLanguage><StatusCode>Finished</StatusCode><Ordered>2018-03-07T14:47:03.000+01:00</Ordered><RequestedDelivery>2018-03-07T15:47:00.000+01:00</RequestedDelivery><Delivered>2018-03-07T14:47:03.000+01:00</Delivered><MaximumCreditRecommendationAmount>-1.0</MaximumCreditRecommendationAmount><CompanyRegistrationDate>0001-01-01T00:00:00.0+01:00</CompanyRegistrationDate><ReportMimeType>application/pdf</ReportMimeType><ReportBinary>123</ReportBinary></Report></immediateOrderResult></immediateOrderResponse></soap:Body></soap:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, cofaceMock);
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('82832310', null, opportunity.Id, null, 'Hungary');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CofaceReport.pdf' AND ParentId = :opportunity.Id];

       	System.assertEquals(1, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for SK
    *  CreatedDate     : 13/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testValidPdfCreationCZ() {
    	Account account = CreditFactoryTestUtils.generateAccountCZ();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityCZ();
        opportunity.AccountId = account.Id;
        insert opportunity;

        Test.startTest();
            SingleRequestMock cribisMock = new SingleRequestMock(200, 'Complete', '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><GetDocumentByTicketResponse xmlns="https://ws.urplus.sk"><GetDocumentByTicketResult><Status><Code>101</Code><Description>OK</Description></Status><Data><Document xmlns="urn:crif-cribiscz-GetDocumentReport:2018-11-06">test pdf</Document><Requested xmlns="urn:crif-cribiscz-GetDocumentReport:2018-11-06">2020-10-01T14:08:44.76</Requested><Created xmlns="urn:crif-cribiscz-GetDocumentReport:2018-11-06">2020-10-01T14:08:49.4</Created></Data></GetDocumentByTicketResult></GetDocumentByTicketResponse></soap:Body></soap:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, cribisMock);
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('e908ead4-de03-eb11-80f5-005056b26407', null, opportunity.Id, null, 'Slovakia');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CribisReport.pdf' AND ParentId = :opportunity.Id];

       	System.assertEquals(1, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for CH
    *  CreatedDate     : 02/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidPdfCreationCH() {
        Account account = CreditFactoryTestUtils.generateAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityCH();
        opportunity.AccountId = opportunity.Id;
        insert opportunity;

        Test.startTest();
            SingleRequestMock pdfMock = new SingleRequestMock(200, 'Complete', 'TestStringToBlob', null);
            Test.setMock(HttpCalloutMock.class, pdfMock);
            Blob responseBody = Blob.valueOf('<test></test>');
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('12345678900987', null, opportunity.Id, responseBody, 'Switzerland-DE');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachments = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CrediconnectReport.pdf' AND ParentId =: opportunity.Id
        ];

        System.assertEquals(1, attachments.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for AT
    *  CreatedDate     : 15/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidPdfCreationAT() {
        Account account = CreditFactoryTestUtils.generateAccountAT();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityAT();
        opportunity.AccountId = opportunity.Id;
        insert opportunity;

        Test.startTest();
            SingleRequestMock pdfMock = new SingleRequestMock(200, 'Complete', 'TestStringToBlob', null);
            Test.setMock(HttpCalloutMock.class, pdfMock);
            Blob responseBody = Blob.valueOf('<test></test>');
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('12345678900987', null, opportunity.Id, responseBody, 'Austria');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachments = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CrefoReport.pdf' AND ParentId =: opportunity.Id
        ];

        System.assertEquals(1, attachments.size());
    }
    
    
    /*******************************************************************************
    *  Summary         : Test Valid Pdf request for LU
    *  CreatedDate     : 22/12/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testValidPdfCreationLU() {
        Account account = CreditFactoryTestUtils.generateAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityLU();
        opportunity.AccountId = opportunity.Id;
        insert opportunity;

        Test.startTest();
            SingleRequestMock pdfMock = new SingleRequestMock(200, 'Complete', 'TestStringToBlob', null);
            Test.setMock(HttpCalloutMock.class, pdfMock);
            Blob responseBody = Blob.valueOf('<test></test>');
            CreditFactoryPdfSchedule schedule = new CreditFactoryPdfSchedule('12345678900987', null, opportunity.Id, responseBody, 'Luxembourg');
            SchedulableContext sc;
            schedule.execute(sc);
        Test.stopTest();

        List<Attachment> attachments = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CrefoReport.pdf' AND ParentId =: opportunity.Id
        ];

        System.assertEquals(1, attachments.size());
    }
}