/**
 * Created by Aleksandr.Gaakh on 07.04.2021.
 */

@IsTest
public with sharing class RegionApiBatchTest {

    @TestSetup
    public static void regionApiSetup() {
        Region_Api_Settings__c regionApiSettings = new Region_Api_Settings__c();
        regionApiSettings.Name = 'Endkunde_Lotos';
        regionApiSettings.Endpoint__c = 'https://wyszukiwarkaregon.stat.gov.pl/wsBIR/UslugaBIRzewnPubl.svc';
        regionApiSettings.isActive__c = true;
        regionApiSettings.RecordType_DateOfRequest_SOQL_Query__c = 'AND Country = \'Poland\' AND Sec_Channel__c = \'JITB\' AND RecordTypeId IN (\'012200000006oVTAAY\', \'0123Y0000003dxwQAA\') AND Date_of_request_to_RegionApi__c = NULL';

        insert regionApiSettings;

        RecordType rt = [SELECT Id FROM RecordType WHERE RecordType.Name = 'Lotos' LIMIT 1];
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            leads.add(new Lead(
                    LastName = 'Test' + i,
                    Country = 'Poland',
                    RecordTypeId = rt.Id,
                    Steuernummer__c = '111111700' + i,
                    Phone = '3333',
                    Sec_Channel__c = 'JITB',
                    Company = 'Test'));
        }
        insert leads;
    }

    @IsTest
    static void testUpdateLeadsBatch() {
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

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11389902\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;146992876&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117000&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;AGAMED TRANS ADAM GULATOWSKI SPÓŁKA JAWNA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;MAZOWIECKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;Warszawa&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Wola&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Warszawa&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;00-867&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;Aleja Jana Pawła II&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;27&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Warszawa&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;363201852&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117001&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;DAILY TRANS Damian Baradziej&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;ŚWIĘTOKRZYSKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;starachowicki&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Pawłów&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Łomno&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;27-225&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica /&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;66A&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;1&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Pawłów&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;362087271&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117002&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;Usługi Rem-BUD "MERKURY\' Artur Siennicki&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODLASKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;Łomża&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Łomża&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Łomża&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;18-400&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;Aleja Józefa Piłsudskiego&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;70&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu&gt;1&lt;/NrLokalu&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;1&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci&gt;2020-09-28&lt;/DataZakonczeniaDzialalnosci&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Łomża&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11389902--', null);

        SingleRequestMock companyFullReportMock1 = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11438280\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaportResponse</a:Action></s:Header><s:Body><DanePobierzPelnyRaportResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DanePobierzPelnyRaportResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;praw_regon9&gt;146992876&lt;/praw_regon9&gt;&#xD;\n' +
                '    &lt;praw_nip&gt;1111117000&lt;/praw_nip&gt;&#xD;\n' +
                '    &lt;praw_statusNip /&gt;&#xD;\n' +
                '    &lt;praw_nazwa&gt;AGAMED TRANS ADAM GULATOWSKI SPÓŁKA JAWNA&lt;/praw_nazwa&gt;&#xD;\n' +
                '    &lt;praw_nazwaSkrocona /&gt;&#xD;\n' +
                '    &lt;praw_numerWRejestrzeEwidencji&gt;0000486525&lt;/praw_numerWRejestrzeEwidencji&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRejestruEwidencji&gt;2013-11-20&lt;/praw_dataWpisuDoRejestruEwidencji&gt;&#xD;\n' +
                '    &lt;praw_dataPowstania&gt;2013-11-20&lt;/praw_dataPowstania&gt;&#xD;\n' +
                '    &lt;praw_dataRozpoczeciaDzialalnosci&gt;2013-11-20&lt;/praw_dataRozpoczeciaDzialalnosci&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRegon&gt;2013-12-06&lt;/praw_dataWpisuDoRegon&gt;&#xD;\n' +
                '    &lt;praw_dataZawieszeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataWznowieniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZaistnieniaZmiany&gt;2020-11-12&lt;/praw_dataZaistnieniaZmiany&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataSkresleniaZRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataOrzeczeniaOUpadlosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaPostepowaniaUpadlosciowego /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Symbol&gt;PL&lt;/praw_adSiedzKraj_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Symbol&gt;14&lt;/praw_adSiedzWojewodztwo_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Symbol&gt;65&lt;/praw_adSiedzPowiat_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Symbol&gt;188&lt;/praw_adSiedzGmina_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKodPocztowy&gt;00867&lt;/praw_adSiedzKodPocztowy&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Symbol&gt;0919884&lt;/praw_adSiedzMiejscowoscPoczty_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Symbol&gt;0919884&lt;/praw_adSiedzMiejscowosc_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Symbol&gt;37675&lt;/praw_adSiedzUlica_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerNieruchomosci&gt;27&lt;/praw_adSiedzNumerNieruchomosci&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerLokalu /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNietypoweMiejsceLokalizacji /&gt;&#xD;\n' +
                '    &lt;praw_numerTelefonu /&gt;&#xD;\n' +
                '    &lt;praw_numerWewnetrznyTelefonu /&gt;&#xD;\n' +
                '    &lt;praw_numerFaksu /&gt;&#xD;\n' +
                '    &lt;praw_adresEmail /&gt;&#xD;\n' +
                '    &lt;praw_adresStronyinternetowej /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Nazwa&gt;POLSKA&lt;/praw_adSiedzKraj_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Nazwa&gt;MAZOWIECKIE&lt;/praw_adSiedzWojewodztwo_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Nazwa&gt;Warszawa&lt;/praw_adSiedzPowiat_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Nazwa&gt;Wola&lt;/praw_adSiedzGmina_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowosc_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowoscPoczty_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Nazwa&gt;Aleja Jana Pawła II&lt;/praw_adSiedzUlica_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Symbol&gt;2&lt;/praw_podstawowaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Symbol&gt;118&lt;/praw_szczegolnaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Symbol&gt;1&lt;/praw_formaFinansowania_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Symbol&gt;214&lt;/praw_formaWlasnosci_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Symbol /&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Symbol&gt;071010050&lt;/praw_organRejestrowy_Symbol&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Symbol&gt;138&lt;/praw_rodzajRejestruEwidencji_Symbol&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Nazwa&gt;JEDNOSTKA ORGANIZACYJNA NIEMAJĄCA OSOBOWOŚCI PRAWNEJ&lt;/praw_podstawowaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Nazwa&gt;SPÓŁKI JAWNE&lt;/praw_szczegolnaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Nazwa&gt;JEDNOSTKA SAMOFINANSUJĄCA NIE BĘDĄCA JEDNOSTKĄ BUDŻETOWĄ LUB SAMORZĄDOWYM ZAKŁADEM BUDŻETOWYM&lt;/praw_formaFinansowania_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Nazwa&gt;WŁASNOŚĆ KRAJOWYCH OSÓB FIZYCZNYCH&lt;/praw_formaWlasnosci_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Nazwa /&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Nazwa&gt;SĄD REJONOWY DLA M.ST.WARSZAWY W WARSZAWIE,XIII WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO&lt;/praw_organRejestrowy_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Nazwa&gt;REJESTR PRZEDSIĘBIORCÓW&lt;/praw_rodzajRejestruEwidencji_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_liczbaJednLokalnych&gt;0&lt;/praw_liczbaJednLokalnych&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DanePobierzPelnyRaportResult></DanePobierzPelnyRaportResponse></s:Body></s:Envelope>\n' +
                '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11438280--', null);
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
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock1);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        System.debug(endpoint2TestResp.size());
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RegionApiBatch regionApiBatch = new RegionApiBatch();
        Id batch = Database.executeBatch(regionApiBatch);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(3, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
        for (Lead lead : leads) {
            System.assertEquals(System.today(), lead.Date_of_request_to_RegionApi__c);
        }
        System.assertEquals('146992876', leads.get(0).Handelsregister__c);
    }

    @IsTest
    static void testGetCompaniesInfo500() {
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

        SingleRequestMock companyFullReportMock1 = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11438280\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaportResponse</a:Action></s:Header><s:Body><DanePobierzPelnyRaportResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DanePobierzPelnyRaportResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;praw_regon9&gt;146992876&lt;/praw_regon9&gt;&#xD;\n' +
                '    &lt;praw_nip&gt;1111117000&lt;/praw_nip&gt;&#xD;\n' +
                '    &lt;praw_statusNip /&gt;&#xD;\n' +
                '    &lt;praw_nazwa&gt;AGAMED TRANS ADAM GULATOWSKI SPÓŁKA JAWNA&lt;/praw_nazwa&gt;&#xD;\n' +
                '    &lt;praw_nazwaSkrocona /&gt;&#xD;\n' +
                '    &lt;praw_numerWRejestrzeEwidencji&gt;0000486525&lt;/praw_numerWRejestrzeEwidencji&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRejestruEwidencji&gt;2013-11-20&lt;/praw_dataWpisuDoRejestruEwidencji&gt;&#xD;\n' +
                '    &lt;praw_dataPowstania&gt;2013-11-20&lt;/praw_dataPowstania&gt;&#xD;\n' +
                '    &lt;praw_dataRozpoczeciaDzialalnosci&gt;2013-11-20&lt;/praw_dataRozpoczeciaDzialalnosci&gt;&#xD;\n' +
                '    &lt;praw_dataWpisuDoRegon&gt;2013-12-06&lt;/praw_dataWpisuDoRegon&gt;&#xD;\n' +
                '    &lt;praw_dataZawieszeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataWznowieniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZaistnieniaZmiany&gt;2020-11-12&lt;/praw_dataZaistnieniaZmiany&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;praw_dataSkresleniaZRegon /&gt;&#xD;\n' +
                '    &lt;praw_dataOrzeczeniaOUpadlosci /&gt;&#xD;\n' +
                '    &lt;praw_dataZakonczeniaPostepowaniaUpadlosciowego /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Symbol&gt;PL&lt;/praw_adSiedzKraj_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Symbol&gt;14&lt;/praw_adSiedzWojewodztwo_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Symbol&gt;65&lt;/praw_adSiedzPowiat_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Symbol&gt;188&lt;/praw_adSiedzGmina_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKodPocztowy&gt;00867&lt;/praw_adSiedzKodPocztowy&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Symbol&gt;0919884&lt;/praw_adSiedzMiejscowoscPoczty_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Symbol&gt;0919884&lt;/praw_adSiedzMiejscowosc_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Symbol&gt;37675&lt;/praw_adSiedzUlica_Symbol&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerNieruchomosci&gt;27&lt;/praw_adSiedzNumerNieruchomosci&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNumerLokalu /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzNietypoweMiejsceLokalizacji /&gt;&#xD;\n' +
                '    &lt;praw_numerTelefonu /&gt;&#xD;\n' +
                '    &lt;praw_numerWewnetrznyTelefonu /&gt;&#xD;\n' +
                '    &lt;praw_numerFaksu /&gt;&#xD;\n' +
                '    &lt;praw_adresEmail /&gt;&#xD;\n' +
                '    &lt;praw_adresStronyinternetowej /&gt;&#xD;\n' +
                '    &lt;praw_adSiedzKraj_Nazwa&gt;POLSKA&lt;/praw_adSiedzKraj_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzWojewodztwo_Nazwa&gt;MAZOWIECKIE&lt;/praw_adSiedzWojewodztwo_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzPowiat_Nazwa&gt;Warszawa&lt;/praw_adSiedzPowiat_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzGmina_Nazwa&gt;Wola&lt;/praw_adSiedzGmina_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowosc_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowosc_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzMiejscowoscPoczty_Nazwa&gt;Warszawa&lt;/praw_adSiedzMiejscowoscPoczty_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_adSiedzUlica_Nazwa&gt;Aleja Jana Pawła II&lt;/praw_adSiedzUlica_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Symbol&gt;2&lt;/praw_podstawowaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Symbol&gt;118&lt;/praw_szczegolnaFormaPrawna_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Symbol&gt;1&lt;/praw_formaFinansowania_Symbol&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Symbol&gt;214&lt;/praw_formaWlasnosci_Symbol&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Symbol /&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Symbol&gt;071010050&lt;/praw_organRejestrowy_Symbol&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Symbol&gt;138&lt;/praw_rodzajRejestruEwidencji_Symbol&gt;&#xD;\n' +
                '    &lt;praw_podstawowaFormaPrawna_Nazwa&gt;JEDNOSTKA ORGANIZACYJNA NIEMAJĄCA OSOBOWOŚCI PRAWNEJ&lt;/praw_podstawowaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_szczegolnaFormaPrawna_Nazwa&gt;SPÓŁKI JAWNE&lt;/praw_szczegolnaFormaPrawna_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaFinansowania_Nazwa&gt;JEDNOSTKA SAMOFINANSUJĄCA NIE BĘDĄCA JEDNOSTKĄ BUDŻETOWĄ LUB SAMORZĄDOWYM ZAKŁADEM BUDŻETOWYM&lt;/praw_formaFinansowania_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_formaWlasnosci_Nazwa&gt;WŁASNOŚĆ KRAJOWYCH OSÓB FIZYCZNYCH&lt;/praw_formaWlasnosci_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_organZalozycielski_Nazwa /&gt;&#xD;\n' +
                '    &lt;praw_organRejestrowy_Nazwa&gt;SĄD REJONOWY DLA M.ST.WARSZAWY W WARSZAWIE,XIII WYDZIAŁ GOSPODARCZY KRAJOWEGO REJESTRU SĄDOWEGO&lt;/praw_organRejestrowy_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_rodzajRejestruEwidencji_Nazwa&gt;REJESTR PRZEDSIĘBIORCÓW&lt;/praw_rodzajRejestruEwidencji_Nazwa&gt;&#xD;\n' +
                '    &lt;praw_liczbaJednLokalnych&gt;0&lt;/praw_liczbaJednLokalnych&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DanePobierzPelnyRaportResult></DanePobierzPelnyRaportResponse></s:Body></s:Envelope>\n' +
                '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11438280--', null);
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
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock1);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        System.debug(endpoint2TestResp.size());
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RegionApiBatch regionApiBatch = new RegionApiBatch();
        Id batch = Database.executeBatch(regionApiBatch);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        for (Lead lead : leads) {
            System.assertEquals(null, lead.Date_of_request_to_RegionApi__c);
        }
    }

    @IsTest
    static void testCompanyFullReport500() {
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

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11389902\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;146992876&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117000&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;AGAMED TRANS ADAM GULATOWSKI SPÓŁKA JAWNA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;MAZOWIECKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;Warszawa&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Wola&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Warszawa&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;00-867&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;Aleja Jana Pawła II&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;27&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Warszawa&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;363201852&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117001&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;DAILY TRANS Damian Baradziej&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;ŚWIĘTOKRZYSKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;starachowicki&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Pawłów&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Łomno&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;27-225&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica /&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;66A&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;1&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Pawłów&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;362087271&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117002&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;Usługi Rem-BUD "MERKURY\' Artur Siennicki&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODLASKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;Łomża&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Łomża&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Łomża&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;18-400&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;Aleja Józefa Piłsudskiego&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;70&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu&gt;1&lt;/NrLokalu&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;1&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci&gt;2020-09-28&lt;/DataZakonczeniaDzialalnosci&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Łomża&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11389902--', null);

        SingleRequestMock companyFullReportMock1 = new SingleRequestMock(500, 'Complete', '--uuid:48f236ec-83b4-4ef4-b688-c11e99402052+id=6801913\n' +
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
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock1);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        System.debug(endpoint2TestResp.size());
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RegionApiBatch regionApiBatch = new RegionApiBatch();
        Id batch = Database.executeBatch(regionApiBatch);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        for (Lead lead : leads) {
            System.assertEquals(null, lead.Date_of_request_to_RegionApi__c);
        }
    }

    @IsTest
    static void testCompanyFullReportError() {
        RecordType rt = [SELECT Id FROM RecordType WHERE RecordType.Name = 'Lotos' LIMIT 1];
        insert new Lead(
                LastName = 'Test4',
                Country = 'Poland',
                RecordTypeId = rt.Id,
                Steuernummer__c = '11',
                Phone = '3333',
                Sec_Channel__c = 'JITB',
                Company = 'Test');
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

        SingleRequestMock companyInfoMock = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11389902\n' +
                'Content-ID: <http://tempuri.org/0>\n' +
                'Content-Transfer-Encoding: 8bit\n' +
                'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"\n' +
                '\n' +
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DaneSzukajPodmiotyResponse</a:Action></s:Header><s:Body><DaneSzukajPodmiotyResponse xmlns="http://CIS/BIR/PUBL/2014/07"><DaneSzukajPodmiotyResult>&lt;root&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;146992876&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117000&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;AGAMED TRANS ADAM GULATOWSKI SPÓŁKA JAWNA&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;MAZOWIECKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;Warszawa&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Wola&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Warszawa&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;00-867&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;Aleja Jana Pawła II&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;27&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;P&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;6&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Warszawa&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;363201852&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117001&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;DAILY TRANS Damian Baradziej&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;ŚWIĘTOKRZYSKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;starachowicki&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Pawłów&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Łomno&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;27-225&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica /&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;66A&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu /&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;1&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci /&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Pawłów&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '  &lt;dane&gt;&#xD;\n' +
                '    &lt;Regon&gt;362087271&lt;/Regon&gt;&#xD;\n' +
                '    &lt;Nip&gt;1111117002&lt;/Nip&gt;&#xD;\n' +
                '    &lt;StatusNip /&gt;&#xD;\n' +
                '    &lt;Nazwa&gt;Usługi Rem-BUD "MERKURY\' Artur Siennicki&lt;/Nazwa&gt;&#xD;\n' +
                '    &lt;Wojewodztwo&gt;PODLASKIE&lt;/Wojewodztwo&gt;&#xD;\n' +
                '    &lt;Powiat&gt;Łomża&lt;/Powiat&gt;&#xD;\n' +
                '    &lt;Gmina&gt;Łomża&lt;/Gmina&gt;&#xD;\n' +
                '    &lt;Miejscowosc&gt;Łomża&lt;/Miejscowosc&gt;&#xD;\n' +
                '    &lt;KodPocztowy&gt;18-400&lt;/KodPocztowy&gt;&#xD;\n' +
                '    &lt;Ulica&gt;Aleja Józefa Piłsudskiego&lt;/Ulica&gt;&#xD;\n' +
                '    &lt;NrNieruchomosci&gt;70&lt;/NrNieruchomosci&gt;&#xD;\n' +
                '    &lt;NrLokalu&gt;1&lt;/NrLokalu&gt;&#xD;\n' +
                '    &lt;Typ&gt;F&lt;/Typ&gt;&#xD;\n' +
                '    &lt;SilosID&gt;1&lt;/SilosID&gt;&#xD;\n' +
                '    &lt;DataZakonczeniaDzialalnosci&gt;2020-09-28&lt;/DataZakonczeniaDzialalnosci&gt;&#xD;\n' +
                '    &lt;MiejscowoscPoczty&gt;Łomża&lt;/MiejscowoscPoczty&gt;&#xD;\n' +
                '  &lt;/dane&gt;&#xD;\n' +
                '&lt;/root&gt;</DaneSzukajPodmiotyResult></DaneSzukajPodmiotyResponse></s:Body></s:Envelope>\n' +
                '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=11389902--', null);

        SingleRequestMock companyFullReportMock1 = new SingleRequestMock(200, 'Complete', '--uuid:2c0dbf54-5ce4-49c1-8931-3be8f637e390+id=5300956\n' +
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
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/DanePobierzPelnyRaport', companyFullReportMock1);
        endpoint2TestResp.put('http://CIS/BIR/PUBL/2014/07/IUslugaBIRzewnPubl/Wyloguj', logoutMock);
        System.debug(endpoint2TestResp.size());
        HttpCalloutMock multiCalloutMock =
                new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RegionApiBatch regionApiBatch = new RegionApiBatch();
        Id batch = Database.executeBatch(regionApiBatch);
        Test.stopTest();
        List<Lead> leads = [
                SELECT Country, RecordTypeId, Steuernummer__c, Handelsregister__c, Street, State, City, Phone, Email, Website,
                        Company, PostalCode, Gruendungsjahr__c, Date_of_foundation__c, Resuming_Activity_Date__c,Suspending_Activity_Date__c,
                        Date_of_request_to_RegionApi__c, Sec_Channel__c //, Provided_activity_PKD__c, Gesellschaftsform__c
                FROM Lead
        ];
        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
        for (Lead lead : leads) {
            System.assertEquals(null, lead.Date_of_request_to_RegionApi__c);
        }
    }

    @IsTest
    static void testUnavailableConnectionStatus() {
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
        RegionApiBatch regionApiBatch = new RegionApiBatch();
        Id batch = Database.executeBatch(regionApiBatch);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
    }

    @IsTest
    static void testTechnicalBreakConnectionStatus() {
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
        RegionApiBatch regionApiBatch = new RegionApiBatch();
        Id batch = Database.executeBatch(regionApiBatch);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Date_of_request_to_RegionApi__c != NULL]);
    }
}