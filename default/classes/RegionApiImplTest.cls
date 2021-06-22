/**
 * Created by Aleksandr.Gaakh on 01.04.2021.
 */
@IsTest
public with sharing class RegionApiImplTest {

    @TestSetup
    public static void regionApiSetup() {
        Region_Api_Settings__c regionApiSettings = new Region_Api_Settings__c();
        regionApiSettings.Name = 'Endkunde_Lotos';
        regionApiSettings.Endpoint__c = 'https://wyszukiwarkaregon.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc';
        regionApiSettings.isActive__c = true;
        insert regionApiSettings;

        RecordType rt = [SELECT Id FROM RecordType WHERE RecordType.Name = 'Lotos' LIMIT 1];
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(
                LastName = 'Test',
                Country = 'Poland',
                RecordTypeId = rt.Id,
                Steuernummer__c = '6574387680',
                Phone = '3333',
                Sec_Channel__c = 'JITB',
                Company = 'Test'));
        insert leads;
    }

    @IsTest
    static void testConnectionStatus() {
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>1</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);
        Test.setMock(HttpCalloutMock.class, connectionMock);
        String connectionStatus = RegionApiImpl.getConnectionStatus(null, 'StatusUslugi');
        Test.stopTest();
        System.debug(connectionStatus);

        System.assertEquals('1', connectionStatus);
    }

    @IsTest
    static void testSessionId() {
        Test.startTest();
        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);
        Test.setMock(HttpCalloutMock.class, sessionIdMock);
        String sessionId = RegionApiImpl.getSessionId();
        Test.stopTest();
        System.debug(sessionId);
        System.assertNotEquals(null, sessionId);
    }

    @IsTest
    static void testGetCompaniesInfo() {
        Test.startTest();
        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1234567890&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);
        Test.setMock(HttpCalloutMock.class, companyInfoMock);
        List<RegionApiCompany> regionApiCompanies = RegionApiImpl.getCompaniesInfo('1234567890987654321', '1234567890');
        Test.stopTest();
        System.assertEquals(1, regionApiCompanies.size());
    }

    @IsTest
    static void testGetCompaniesInfo500() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        System.debug(testLead.get(0).Steuernummer__c);
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>1</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        SingleRequestMock companyInfoMock = new SingleRequestMock(500, 'Complete', '--uuid:48f236ec-83b4-4ef4-b688-c11e99402052+id=6801913\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://schemas.microsoft.com/net/2005/12/windowscommunicationfoundation/dispatcher/fault</a:Action></s:Header><s:Body><s:Fault><s:Code><s:Value>s:Sender</s:Value><s:Subcode><s:Value xmlns:a="http://schemas.microsoft.com/net/2005/12/windowscommunicationfoundation/dispatcher">a:DeserializationFailed</s:Value></s:Subcode></s:Code><s:Reason><s:Text xml:lang="pl-PL">The formatter threw an exception while trying to deserialize the message: Error in deserializing body of request message for operation \'Zaloguj\'. Start element \'soap:Body\' does not match end element \'soap\'. Line 11, position 7.</s:Text></s:Reason></s:Fault></s:Body></s:Envelope>\n' +
                '--uuid:48f236ec-83b4-4ef4-b688-c11e99402052+id=6801913--', null);
        SingleRequestMock logoutMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/WylogujResponse</a:Action></s:Header><s:Body><WylogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><WylogujResult>true</WylogujResult></WylogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty', companyInfoMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LeadHandler.setValuesFromRegionApi(null, testLead);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(null, leads.get(0).Date_of_request_to_RegionApi__c);
    }

    @IsTest
    static void testCompanyFullReport500() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>1</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;6574387680&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);

        SingleRequestMock companyFullReportMock = new SingleRequestMock(500, 'Complete', '--uuid:48f236ec-83b4-4ef4-b688-c11e99402052+id=6801913\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://schemas.microsoft.com/net/2005/12/windowscommunicationfoundation/dispatcher/fault</a:Action></s:Header><s:Body><s:Fault><s:Code><s:Value>s:Sender</s:Value><s:Subcode><s:Value xmlns:a="http://schemas.microsoft.com/net/2005/12/windowscommunicationfoundation/dispatcher">a:DeserializationFailed</s:Value></s:Subcode></s:Code><s:Reason><s:Text xml:lang="pl-PL">The formatter threw an exception while trying to deserialize the message: Error in deserializing body of request message for operation \'Zaloguj\'. Start element \'soap:Body\' does not match end element \'soap\'. Line 11, position 7.</s:Text></s:Reason></s:Fault></s:Body></s:Envelope>\n' +
                '--uuid:48f236ec-83b4-4ef4-b688-c11e99402052+id=6801913--', null);
        SingleRequestMock logoutMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/WylogujResponse</a:Action></s:Header><s:Body><WylogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><WylogujResult>true</WylogujResult></WylogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty', companyInfoMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LeadHandler.setValuesFromRegionApi(null, testLead);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(null, leads.get(0).Date_of_request_to_RegionApi__c);
    }


    @IsTest
    static void testCompanyFullReport() {
        Test.startTest();
        SingleRequestMock companyFullReportMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4006503\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaportResponse</a:Action></s:Header><s:Body><DanePobierzPelnyRaportResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DanePobierzPelnyRaportResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;praw_regon9&gt;000331501&lt;/praw_regon9&gt;&#xD;\n' +
                '    &lt;praw_nip&gt;5261040828&lt;/praw_nip&gt;&#xD;\n' +
                '    &lt;praw_statusNip /&gt;&#xD;\n' +
                '    &lt;praw_nazwa&gt;GŁÓWNY URZĄD STATYSTYCZNY&lt;/praw_nazwa&gt;&#xD;\n' +
                '    &lt;praw_nazwaSkrocona&gt;GUS&lt;/praw_nazwaSkrocona&gt;&#xD;\n' +
                '    &lt;praw_numerWRejestrzeEwidencji /&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRejestruEwidencji&gt;1975-12-15&lt;/praw_dataWpisuDoRejestruEwidencji&gt;&#xD;\n' +
                '    &lt;praw_dataPowstania&gt;1975-12-15&lt;/praw_dataPowstania&gt;&#xD;\n' +
                '    &lt;praw_dataRozpoczeciaDzialalnosci&gt;1975-12-15&lt;/praw_dataRozpoczeciaDzialalnosci&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataZawieszeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataWznowieniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZaistnieniaZmiany&gt;2013-04-22&lt;/praw_dataZaistnieniaZmiany&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataSkresleniaZRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataOrzeczeniaOUpadlosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaPostepowaniaUpadlosciowego /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Symbol&gt;PL&lt;/praw_adSiedzKraj_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Symbol&gt;14&lt;/praw_adSiedzWojewodztwo_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Symbol&gt;65&lt;/praw_adSiedzPowiat_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Symbol&gt;108&lt;/praw_adSiedzGmina_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKodPocztowy&gt;00925&lt;/praw_adSiedzKodPocztowy&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Symbol&gt;0919810&lt;/praw_adSiedzMiejscowoscPoczty_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Symbol&gt;0919810&lt;/praw_adSiedzMiejscowosc_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Symbol&gt;38299&lt;/praw_adSiedzUlica_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerNieruchomosci&gt;208&lt;/praw_adSiedzNumerNieruchomosci&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerLokalu /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNietypoweMiejsceLokalizacji /&gt;&#xD;\n' +
                '    &lt;praw_numerTelefonu&gt;6083000&lt;/praw_numerTelefonu&gt;&#xD;\n' +
                '    &lt;praw_numerWewnetrznyTelefonu /&gt;&#xD;\n' +
                '    &lt;praw_numerFaksu&gt;0226083863&lt;/praw_numerFaksu&gt;&#xD;\n' +
                '    &lt;praw_adresEmail&gt;dgsek@stat.gov.pl&lt;/praw_adresEmail&gt;&#xD;\n' +
                '    &lt;praw_adresStronyinternetowej&gt;www.stat.gov.pl&lt;/praw_adresStronyinternetowej&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Nazwa&gt;POLSKA&lt;/praw_adSiedzKraj_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Nazwa&gt;MAZOWIECKIE&lt;/praw_adSiedzWojewodztwo_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Nazwa&gt;Warszawa&lt;/praw_adSiedzPowiat_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Nazwa&gt;Śródmieście&lt;/praw_adSiedzGmina_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowosc_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowoscPoczty_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Nazwa&gt;Aleja Niepodległości&lt;/praw_adSiedzUlica_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Symbol&gt;2&lt;/praw_podstawowaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Symbol&gt;401&lt;/praw_szczegolnaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Symbol&gt;2&lt;/praw_formaFinansowania_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Symbol&gt;111&lt;/praw_formaWlasnosci_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Symbol&gt;050000000&lt;/praw_organZalozycielski_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Symbol /&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Symbol&gt;000&lt;/praw_rodzajRejestruEwidencji_Symbol&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Nazwa&gt;JEDNOSTKA ORGANIZACYJNA NIEMAJĄCA OSOBOWOŚCI PRAWNEJ&lt;/praw_podstawowaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Nazwa&gt;ORGANY WŁADZY, ADMINISTRACJI RZĄDOWEJ&lt;/praw_szczegolnaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Nazwa&gt;JEDNOSTKA BUDŻETOWA&lt;/praw_formaFinansowania_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Nazwa&gt;WŁASNOŚĆ SKARBU PAŃSTWA&lt;/praw_formaWlasnosci_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Nazwa&gt;PREZES GŁÓWNEGO URZĘDU STATYSTYCZNEGO&lt;/praw_organZalozycielski_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Nazwa /&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Nazwa&gt;PODMIOTY UTWORZONE Z MOCY USTAWY&lt;/praw_rodzajRejestruEwidencji_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_liczbaJednLokalnych&gt;0&lt;/praw_liczbaJednLokalnych&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DanePobierzPelnyRaportResult></DanePobierzPelnyRaportResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4006503--', null);
        Test.setMock(HttpCalloutMock.class, companyFullReportMock);
        RegionApiCompanyFullReport regionApiCompanyFullReport = RegionApiImpl.getCompanyFullReport('1234567890987654321', '000331501', 'BIR11OsPrawna');
        Test.stopTest();
        System.assertEquals('1975', regionApiCompanyFullReport.yearOfFoundation);
        System.assertEquals('', regionApiCompanyFullReport.errorMessage);
    }

    @IsTest
    static void testLogout() {
        Test.startTest();
        SingleRequestMock logoutMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/WylogujResponse</a:Action></s:Header><s:Body><WylogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><WylogujResult>true</WylogujResult></WylogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435--', null);
        Test.setMock(HttpCalloutMock.class, logoutMock);
        RegionApiImpl.logout('1234567890987654321');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateLeadsUpdate() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>1</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;6574387681&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);

        SingleRequestMock companyFullReportMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4006503\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaportResponse</a:Action></s:Header><s:Body><DanePobierzPelnyRaportResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DanePobierzPelnyRaportResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;praw_regon9&gt;830226150&lt;/praw_regon9&gt;&#xD;\n' +
                '    &lt;praw_nip&gt;6574387681&lt;/praw_nip&gt;&#xD;\n' +
                '    &lt;praw_statusNip /&gt;&#xD;\n' +
                '    &lt;praw_nazwa&gt;GŁÓWNY URZĄD STATYSTYCZNY&lt;/praw_nazwa&gt;&#xD;\n' +
                '    &lt;praw_nazwaSkrocona&gt;GUS&lt;/praw_nazwaSkrocona&gt;&#xD;\n' +
                '    &lt;praw_numerWRejestrzeEwidencji /&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRejestruEwidencji&gt;1975-12-15&lt;/praw_dataWpisuDoRejestruEwidencji&gt;&#xD;\n' +
                '    &lt;praw_dataPowstania /&gt;&#xD;\n' +
                '    &lt;praw_dataRozpoczeciaDzialalnosci&gt;1975-12-15&lt;/praw_dataRozpoczeciaDzialalnosci&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataZawieszeniaDzialalnosci&gt;2000-12-15&lt;/praw_dataZawieszeniaDzialalnosci&gt;&#xD;\n' +
                '    &lt;praw_dataWznowieniaDzialalnosci&gt;2004-12-15&lt;/praw_dataWznowieniaDzialalnosci&gt;&#xD;\n' +
                '    &lt;praw_dataZaistnieniaZmiany&gt;2013-04-22&lt;/praw_dataZaistnieniaZmiany&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataSkresleniaZRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataOrzeczeniaOUpadlosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaPostepowaniaUpadlosciowego /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Symbol&gt;PL&lt;/praw_adSiedzKraj_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Symbol&gt;14&lt;/praw_adSiedzWojewodztwo_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Symbol&gt;65&lt;/praw_adSiedzPowiat_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Symbol&gt;108&lt;/praw_adSiedzGmina_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKodPocztowy&gt;00925&lt;/praw_adSiedzKodPocztowy&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Symbol&gt;0919810&lt;/praw_adSiedzMiejscowoscPoczty_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Symbol&gt;0919810&lt;/praw_adSiedzMiejscowosc_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Symbol&gt;38299&lt;/praw_adSiedzUlica_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerNieruchomosci&gt;208&lt;/praw_adSiedzNumerNieruchomosci&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerLokalu /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNietypoweMiejsceLokalizacji /&gt;&#xD;\n' +
                '    &lt;praw_numerTelefonu&gt;6083000&lt;/praw_numerTelefonu&gt;&#xD;\n' +
                '    &lt;praw_numerWewnetrznyTelefonu /&gt;&#xD;\n' +
                '    &lt;praw_numerFaksu&gt;0226083863&lt;/praw_numerFaksu&gt;&#xD;\n' +
                '    &lt;praw_adresEmail&gt;dgsek@stat.gov.pl&lt;/praw_adresEmail&gt;&#xD;\n' +
                '    &lt;praw_adresStronyinternetowej&gt;www.stat.gov.pl&lt;/praw_adresStronyinternetowej&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Nazwa&gt;POLSKA&lt;/praw_adSiedzKraj_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Nazwa&gt;MAZOWIECKIE&lt;/praw_adSiedzWojewodztwo_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Nazwa&gt;Warszawa&lt;/praw_adSiedzPowiat_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Nazwa&gt;Śródmieście&lt;/praw_adSiedzGmina_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowosc_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowoscPoczty_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Nazwa&gt;Aleja Niepodległości&lt;/praw_adSiedzUlica_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Symbol&gt;2&lt;/praw_podstawowaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Symbol&gt;401&lt;/praw_szczegolnaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Symbol&gt;2&lt;/praw_formaFinansowania_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Symbol&gt;111&lt;/praw_formaWlasnosci_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Symbol&gt;050000000&lt;/praw_organZalozycielski_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Symbol /&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Symbol&gt;000&lt;/praw_rodzajRejestruEwidencji_Symbol&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Nazwa&gt;JEDNOSTKA ORGANIZACYJNA NIEMAJĄCA OSOBOWOŚCI PRAWNEJ&lt;/praw_podstawowaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Nazwa&gt;ORGANY WŁADZY, ADMINISTRACJI RZĄDOWEJ&lt;/praw_szczegolnaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Nazwa&gt;JEDNOSTKA BUDŻETOWA&lt;/praw_formaFinansowania_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Nazwa&gt;WŁASNOŚĆ SKARBU PAŃSTWA&lt;/praw_formaWlasnosci_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Nazwa&gt;PREZES GŁÓWNEGO URZĘDU STATYSTYCZNEGO&lt;/praw_organZalozycielski_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Nazwa /&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Nazwa&gt;PODMIOTY UTWORZONE Z MOCY USTAWY&lt;/praw_rodzajRejestruEwidencji_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_liczbaJednLokalnych&gt;0&lt;/praw_liczbaJednLokalnych&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DanePobierzPelnyRaportResult></DanePobierzPelnyRaportResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4006503--', null);
        SingleRequestMock logoutMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/WylogujResponse</a:Action></s:Header><s:Body><WylogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><WylogujResult>true</WylogujResult></WylogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty', companyInfoMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        testLead.get(0).Steuernummer__c = '6574387681';
        update testLead;
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
        System.assertEquals('6574387681', leads.get(0).Steuernummer__c);
        System.assertEquals(System.today(), leads.get(0).Date_of_request_to_RegionApi__c);
        System.assertEquals(null, leads.get(0).Gruendungsjahr__c);
        System.assertEquals(Date.valueOf('2000-12-15'), leads.get(0).Suspending_Activity_Date__c);
        System.assertEquals(Date.valueOf('2004-12-15'), leads.get(0).Resuming_Activity_Date__c);

    }

    @IsTest
    static void testUpdateLeadsInsert() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>1</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;6574387680&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);

        SingleRequestMock companyFullReportMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4006503\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaportResponse</a:Action></s:Header><s:Body><DanePobierzPelnyRaportResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DanePobierzPelnyRaportResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;praw_regon9&gt;830226150&lt;/praw_regon9&gt;&#xD;\n' +
                '    &lt;praw_nip&gt;6574387680&lt;/praw_nip&gt;&#xD;\n' +
                '    &lt;praw_statusNip /&gt;&#xD;\n' +
                '    &lt;praw_nazwa&gt;GŁÓWNY URZĄD STATYSTYCZNY&lt;/praw_nazwa&gt;&#xD;\n' +
                '    &lt;praw_nazwaSkrocona&gt;GUS&lt;/praw_nazwaSkrocona&gt;&#xD;\n' +
                '    &lt;praw_numerWRejestrzeEwidencji /&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRejestruEwidencji&gt;1975-12-15&lt;/praw_dataWpisuDoRejestruEwidencji&gt;&#xD;\n' +
                '    &lt;praw_dataPowstania&gt;1975-12-15&lt;/praw_dataPowstania&gt;&#xD;\n' +
                '    &lt;praw_dataRozpoczeciaDzialalnosci&gt;1975-12-15&lt;/praw_dataRozpoczeciaDzialalnosci&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataZawieszeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataWznowieniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZaistnieniaZmiany&gt;2013-04-22&lt;/praw_dataZaistnieniaZmiany&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataSkresleniaZRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataOrzeczeniaOUpadlosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaPostepowaniaUpadlosciowego /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Symbol&gt;PL&lt;/praw_adSiedzKraj_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Symbol&gt;14&lt;/praw_adSiedzWojewodztwo_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Symbol&gt;65&lt;/praw_adSiedzPowiat_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Symbol&gt;108&lt;/praw_adSiedzGmina_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKodPocztowy&gt;00925&lt;/praw_adSiedzKodPocztowy&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Symbol&gt;0919810&lt;/praw_adSiedzMiejscowoscPoczty_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Symbol&gt;0919810&lt;/praw_adSiedzMiejscowosc_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Symbol&gt;38299&lt;/praw_adSiedzUlica_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerNieruchomosci&gt;208&lt;/praw_adSiedzNumerNieruchomosci&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerLokalu /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNietypoweMiejsceLokalizacji /&gt;&#xD;\n' +
                '    &lt;praw_numerTelefonu&gt;6083000&lt;/praw_numerTelefonu&gt;&#xD;\n' +
                '    &lt;praw_numerWewnetrznyTelefonu /&gt;&#xD;\n' +
                '    &lt;praw_numerFaksu&gt;0226083863&lt;/praw_numerFaksu&gt;&#xD;\n' +
                '    &lt;praw_adresEmail&gt;dgsek@stat.gov.pl&lt;/praw_adresEmail&gt;&#xD;\n' +
                '    &lt;praw_adresStronyinternetowej&gt;www.stat.gov.pl&lt;/praw_adresStronyinternetowej&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Nazwa&gt;POLSKA&lt;/praw_adSiedzKraj_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Nazwa&gt;MAZOWIECKIE&lt;/praw_adSiedzWojewodztwo_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Nazwa&gt;Warszawa&lt;/praw_adSiedzPowiat_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Nazwa&gt;Śródmieście&lt;/praw_adSiedzGmina_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowosc_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowoscPoczty_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Nazwa&gt;Aleja Niepodległości&lt;/praw_adSiedzUlica_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Symbol&gt;2&lt;/praw_podstawowaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Symbol&gt;401&lt;/praw_szczegolnaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Symbol&gt;2&lt;/praw_formaFinansowania_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Symbol&gt;111&lt;/praw_formaWlasnosci_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Symbol&gt;050000000&lt;/praw_organZalozycielski_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Symbol /&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Symbol&gt;000&lt;/praw_rodzajRejestruEwidencji_Symbol&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Nazwa&gt;JEDNOSTKA ORGANIZACYJNA NIEMAJĄCA OSOBOWOŚCI PRAWNEJ&lt;/praw_podstawowaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Nazwa&gt;ORGANY WŁADZY, ADMINISTRACJI RZĄDOWEJ&lt;/praw_szczegolnaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Nazwa&gt;JEDNOSTKA BUDŻETOWA&lt;/praw_formaFinansowania_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Nazwa&gt;WŁASNOŚĆ SKARBU PAŃSTWA&lt;/praw_formaWlasnosci_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Nazwa&gt;PREZES GŁÓWNEGO URZĘDU STATYSTYCZNEGO&lt;/praw_organZalozycielski_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Nazwa /&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Nazwa&gt;PODMIOTY UTWORZONE Z MOCY USTAWY&lt;/praw_rodzajRejestruEwidencji_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_liczbaJednLokalnych&gt;0&lt;/praw_liczbaJednLokalnych&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DanePobierzPelnyRaportResult></DanePobierzPelnyRaportResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4006503--', null);
        SingleRequestMock logoutMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/WylogujResponse</a:Action></s:Header><s:Body><WylogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><WylogujResult>true</WylogujResult></WylogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty', companyInfoMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LeadHandler.setValuesFromRegionApi(null, testLead);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
        System.assertEquals('830226150', leads.get(0).Handelsregister__c);
        System.assertEquals(System.today(), leads.get(0).Date_of_request_to_RegionApi__c);
    }

    @IsTest
    static void testCompanyInfoError() {
        Test.startTest();
        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:bce3cd4f-43f8-4932-a9b6-72c9e248211d+id=4202450\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;ErrorCode&gt;4&lt;/ErrorCode&gt;&#xD;\n' +
                '    &lt;ErrorMessagePl&gt;Nie znaleziono podmiotu dla podanych kryteriów wyszukiwania.&lt;/ErrorMessagePl&gt;&#xD;\n' +
                '    &lt;ErrorMessageEn&gt;No data found for the specified search criteria.&lt;/ErrorMessageEn&gt;&#xD;\n' +
                '    &lt;Nipy&gt;1234567890&lt;/Nipy&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:bce3cd4f-43f8-4932-a9b6-72c9e248211d+id=4202450--', null);
        Test.setMock(HttpCalloutMock.class, companyInfoMock);
        List<RegionApiCompany> regionApiCompanies = RegionApiImpl.getCompaniesInfo('1234567890987654321', '1234567890');
        Test.stopTest();
        System.assertEquals('ErrorCode: 4. No data found for the specified search criteria. TaxId - 1234567890', regionApiCompanies.get(0).errorMessage);
    }

    @IsTest
    static void testCompanyFullReportError() {
        Test.startTest();
        SingleRequestMock companyFullReportMock = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=5300956\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaportResponse</a:Action></s:Header><s:Body><DanePobierzPelnyRaportResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DanePobierzPelnyRaportResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;ErrorCode&gt;4&lt;/ErrorCode&gt;&#xD;\n' +
                '    &lt;ErrorMessagePl&gt;Nie znaleziono wpisu dla podanych kryteriów wyszukiwania.&lt;/ErrorMessagePl&gt;&#xD;\n' +
                '    &lt;ErrorMessageEn&gt;No data found for the specified search criteria.&lt;/ErrorMessageEn&gt;&#xD;\n' +
                '    &lt;pRegon&gt;123456789&lt;/pRegon&gt;&#xD;\n' +
                '    &lt;Typ_podmiotu /&gt;&#xD;\n' +
                '    &lt;Raport&gt;BIR11OsPrawna&lt;/Raport&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DanePobierzPelnyRaportResult></DanePobierzPelnyRaportResponse></s:Body></s:Envelope>\n' +
                '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=5300956--', null);
        Test.setMock(HttpCalloutMock.class, companyFullReportMock);
        RegionApiCompanyFullReport regionApiCompanyFullReport = RegionApiImpl.getCompanyFullReport('1234567890987654321', '123456789', 'BIR11OsPrawna');
        Test.stopTest();
        System.assertEquals('ErrorCode: 4. No data found for the specified search criteria. Region number - 123456789', regionApiCompanyFullReport.errorMessage);
    }

    @IsTest
    static void testUpdateLeadCompanyInfoError() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        System.debug(testLead.get(0).Steuernummer__c);
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>1</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:bce3cd4f-43f8-4932-a9b6-72c9e248211d+id=4202450\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;ErrorCode&gt;4&lt;/ErrorCode&gt;&#xD;\n' +
                '    &lt;ErrorMessagePl&gt;Nie znaleziono podmiotu dla podanych kryteriów wyszukiwania.&lt;/ErrorMessagePl&gt;&#xD;\n' +
                '    &lt;ErrorMessageEn&gt;No data found for the specified search criteria.&lt;/ErrorMessageEn&gt;&#xD;\n' +
                '    &lt;Nipy&gt;1234567890&lt;/Nipy&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:bce3cd4f-43f8-4932-a9b6-72c9e248211d+id=4202450--', null);
        SingleRequestMock logoutMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/WylogujResponse</a:Action></s:Header><s:Body><WylogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><WylogujResult>true</WylogujResult></WylogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty', companyInfoMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LeadHandler.setValuesFromRegionApi(null, testLead);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(null, leads.get(0).Date_of_request_to_RegionApi__c);
    }

    @IsTest
    static void testUpdateLeadCompanyFullReportError() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>1</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;6574387680&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);

        SingleRequestMock companyFullReportMock = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=5300956\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaportResponse</a:Action></s:Header><s:Body><DanePobierzPelnyRaportResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DanePobierzPelnyRaportResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;ErrorCode&gt;4&lt;/ErrorCode&gt;&#xD;\n' +
                '    &lt;ErrorMessagePl&gt;Nie znaleziono wpisu dla podanych kryteriów wyszukiwania.&lt;/ErrorMessagePl&gt;&#xD;\n' +
                '    &lt;ErrorMessageEn&gt;No data found for the specified search criteria.&lt;/ErrorMessageEn&gt;&#xD;\n' +
                '    &lt;pRegon&gt;123456789&lt;/pRegon&gt;&#xD;\n' +
                '    &lt;Typ_podmiotu /&gt;&#xD;\n' +
                '    &lt;Raport&gt;BIR11OsPrawna&lt;/Raport&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DanePobierzPelnyRaportResult></DanePobierzPelnyRaportResponse></s:Body></s:Envelope>\n' +
                '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=5300956--', null);
        SingleRequestMock logoutMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/WylogujResponse</a:Action></s:Header><s:Body><WylogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><WylogujResult>true</WylogujResult></WylogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=4074435--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmioty', companyInfoMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LeadHandler.setValuesFromRegionApi(null, testLead);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(null, leads.get(0).Date_of_request_to_RegionApi__c);
    }

    @IsTest
    static void testUnavailableConnectionStatus() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>0</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LeadHandler.setValuesFromRegionApi(null, testLead);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
    }

    @IsTest
    static void testTechnicalBreakConnectionStatus() {
        List<Lead> testLead = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
                WHERE Country = 'Poland' AND Steuernummer__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        SingleRequestMock connectionMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/2014/07/IUslugaBIR/GetValueResponse</a:Action></s:Header><s:Body><GetValueResponse xmlns="http://CIS/BIR/2014/07"><GetValueResult>2</GetValueResult></GetValueResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=4529313--', null);

        SingleRequestMock sessionIdMock = new SingleRequestMock(200, 'Complete', '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/ZalogujResponse</a:Action></s:Header><s:Body><ZalogujResponse xmlns="http://CIS/BIR/PUBL/2014/07"><ZalogujResult>4mw4u9zd5pf29z8rf263</ZalogujResult></ZalogujResponse></s:Body></s:Envelope>\n' +
                '--uuid:3225eddc-7d76-4c3a-8035-f3566ea62585+id=10027791--', null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('http://CIS/BIR/2014/07/IUslugaBIR/GetValue', connectionMock);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Zaloguj', sessionIdMock);
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LeadHandler.setValuesFromRegionApi(null, testLead);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
    }

    @IsTest
    static void testSetReportNameF1() {
        Test.startTest();
        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1234567890&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;1&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);
        Test.setMock(HttpCalloutMock.class, companyInfoMock);
        List<RegionApiCompany> regionApiCompanies = RegionApiImpl.getCompaniesInfo('12345678909876543210', '1234567890');
        String reportName = RegionApi.setReportName(regionApiCompanies.get(0));
        Test.stopTest();
        System.assertEquals('BIR11OsFizycznaDzialalnoscCeidg', reportName);
    }

    @IsTest
    static void testSetReportNameF2() {
        Test.startTest();
        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1234567890&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;2&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);
        Test.setMock(HttpCalloutMock.class, companyInfoMock);
        List<RegionApiCompany> regionApiCompanies = RegionApiImpl.getCompaniesInfo('12345678909876543210', '1234567890');
        String reportName = RegionApi.setReportName(regionApiCompanies.get(0));
        Test.stopTest();
        System.assertEquals('BIR11OsFizycznaDzialalnoscRolnicza', reportName);
    }

    @IsTest
    static void testSetReportNameF3() {
        Test.startTest();
        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1234567890&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;3&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);
        Test.setMock(HttpCalloutMock.class, companyInfoMock);
        List<RegionApiCompany> regionApiCompanies = RegionApiImpl.getCompaniesInfo('12345678909876543210', '1234567890');
        String reportName = RegionApi.setReportName(regionApiCompanies.get(0));
        Test.stopTest();
        System.assertEquals('BIR11OsFizycznaDzialalnoscPozostala', reportName);
    }

    @IsTest
    static void testSetReportNameF4() {
        Test.startTest();
        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;830226150&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1234567890&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;PPHU RYBIŃSKI S.C.MATEUSZ RYBIŃSKI, AGNIESZKA CZUBACKA, JUSTYNA POTAŃSKA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODKARPACKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;stalowowolski&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Zaklików&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Zaklików&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;37-470&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;ul. Targowa&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;1B&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;4&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Zaklików&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:c5db6009-8677-4110-80fe-b13d9a4af9ad+id=3966013--', null);
        Test.setMock(HttpCalloutMock.class, companyInfoMock);
        List<RegionApiCompany> regionApiCompanies = RegionApiImpl.getCompaniesInfo('12345678909876543210', '1234567890');
        String reportName = RegionApi.setReportName(regionApiCompanies.get(0));
        Test.stopTest();
        System.assertEquals('BIR11OsFizycznaDzialalnoscSkreslonaDo20141108', reportName);
    }
}