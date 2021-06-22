@isTest
public class CreditFactoryReportControllerTestDE {
    public static CreditFactoryReportController controller; 
    public static final SingleRequestMock AUTH_MOCK = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiIxODdjMThmMi1hODcxLTQzN2YtYjFlNC1hOWNlODc3NmU1YjAiLCJleHAiOjE1ODM5MzA4NzYsIm5iZiI6MCwiaWF0IjoxNTgzOTEyODc2LCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiYzFjMTE2YTQtODBlMS00MzNmLTgzZWQtZTkxNDNkNTBmMDAwIiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMDAuMTI1LjY0LjE2MiIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMDAuMTI1LjY0LjE2MiIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.M6O4cenkDUKEWWqiy51KENTJM78F3fRTYiVLenBaKuk3HrivfvUDhBKXRPsS1LfuuLfxKrlSpLdVIsEFFnIqZlv0D_DsLIo7w0oazrzFubBL1CVpiDquKCEHyUEd-K2DnMbFCuayPakmMOWA_E0SbtT9gZYECuI5sRRE5fsLGrXonh0-uZ6rGrxwGWokMMrfyxXqpsTZswTmQawYGySjPd0JMbSTdPtzKdId5qvwjbG_u0pbeecoEeprNWzMGB4-gBbkat_C7WPSemoggCjhHKTrrqcugpYaijh_scUJKdCkz1i2POfzBWcC1hAFWBT9BAgL4TdSAVTcDTf2YFjh6A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiI3ZTZiMjJlYy03NDI4LTQ4NWMtYjYyYS1mMmM5ZjlhNGRlZDIiLCJleHAiOjE1ODM5MTQ2NzYsIm5iZiI6MCwiaWF0IjoxNTgzOTEyODc2LCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6ImMxYzExNmE0LTgwZTEtNDMzZi04M2VkLWU5MTQzZDUwZjAwMCIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.dtO9u6CsDAd89do7Hq1TglUJ8l2m3ciRhbgD6QIYmPM","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "c1c116a4-80e1-433f-83ed-e9143d50f000","scope": "email profile"}', null);
    public static final SingleRequestMock ORDER_ECONOMY_INFO_MOCK = new SingleRequestMock(200, 'Complete', '"ok"', null);
    public static final SingleRequestMock ORDER_STATUS_MOCK = new SingleRequestMock(200, 'Complete', '{"companyIDs": 1645768,"name": "Buchverlagsgesellschaft Druck mbH","order": [{"name": "CoreData","orderDate": "10.03.2020 13:05:34","reason": "","ordered": true,"completed": true,"failed": false},{"name": "Linkage","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "FullEconomyInfo","orderDate": "11.03.2020 06:29:52","reason": "","ordered": true,"completed": true,"failed": false},{"name": "ShortEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "CompactEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "Compliance","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "MediaScreening","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "TransparencyRegister","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false}],"tradeRegisterOrder": [{"documentType": "AD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "CD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "LG","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "GSS","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""}]}', null);
    public static final SingleRequestMock ORDER_STATUS_REPORT_UNAVAILABLE_MOCK = new SingleRequestMock(200, 'Complete', '{"companyIDs": 2416643,"name": "Schlamm Verwaltungs GmbH","order": [{"name": "CoreData","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "Linkage","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "FullEconomyInfo","orderDate": "14.05.2020 09:30:14","reason": "Das Unternehmen mit ID 2416643 auf das sich die Bestellung richtet, ist für die Beauskunftung gesperrt. Es werden derzeit keine Auskünfte zu diesem Unternehmen erteilt.","ordered": true,"completed": false,"failed": true},{"name": "ShortEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "CompactEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "Compliance","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "MediaScreening","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "TransparencyRegister","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "KFW078Check","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "LFACheck","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false}],"tradeRegisterOrder": [{"documentType": "AD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "CD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "LG","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "GSS","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""}]}', null);
    public static final SingleRequestMock RATING_1_REPORT_MOCK = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 150,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
    public static final SingleRequestMock RATING_2_REPORT_MOCK = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 225,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
    public static final SingleRequestMock RATING_3_REPORT_MOCK = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 270,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
    public static final SingleRequestMock RATING_4_REPORT_MOCK = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 4000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 300,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
    public static final SingleRequestMock RATING_5_REPORT_MOCK = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 320,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
    public static final SingleRequestMock RATING_6_REPORT_MOCK = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 500,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
    public static final SingleRequestMock LEXIS_NEXIS_MOCK = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1366487745</ID><IKey xsi:type="xsd:string">1557754623</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFHU</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1366487745&amp;ikey=1557754623</ProfileURL><Credits xsi:type="xsd:int">40975</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Not Sure</EmailExists><DomainExists xsi:type="xsd:string">No</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:nil="true"/><StatusID xsi:type="xsd:int">4</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">29</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">4</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">U</NameMatch><EmailAddress xsi:type="xsd:string">info@olcsofuvar.hu</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
    public static final SingleRequestMock LEXIS_NEXIS_ERROR_MOCK = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">false</Status><ID xsi:type="xsd:string"/><IKey xsi:type="xsd:string"/><equifaxUsername xsi:type="xsd:string"/><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">FAIL</ResultText><ProfileURL xsi:type="xsd:string"/><Credits xsi:type="xsd:int">8067</Credits><Errors xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:ErrorPart[1]"><Error xsi:type="ns4:ErrorPart"><Service xsi:type="xsd:string">emailrisk</Service><Details xsi:type="xsd:string">The format of email is incorrect. Please try again</Details></Error></Errors></Summary></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
    public static final SingleRequestMock PDF_REPORT_MOCK = new SingleRequestMock(200, 'Complete', '{"documentBytes": 18000}', null);
    
    
    /*******************************************************************************
    *  Summary         : Create data for all test methods
    *  CreatedDate     : 10/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @testSetup 
    static void createDataForAllTests() {
        LexisNexis_Settings__c lexisNexisSettings = CreditFactoryUtils.createLexisNexisSettings();
        insert lexisNexisSettings;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;
        
        Fuel_Price__c fuelPriceDE = new Fuel_Price__c(Name = 'Germany', Index__c = 1.4);
        insert fuelPriceDE;
        
        Solvency__c solvencySettingsDE = CreditFactoryUtils.returnSolvencySettingsDE();
        insert solvencySettingsDE;
    }


    /*******************************************************************************
    *  Summary         : Leave empty opportunity id parameter.
    *  CreatedDate     : 10/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityParameter() {
        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid opportunityId parameter.Please contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Leave empty credit system id parameter. 
    *  CreatedDate     : 10/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidCompanyNumberParameter() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid creditSystemCompanyNumber parameter.' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Don't create Credit System custom setting.
    *  CreatedDate     : 10/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Select Credit System Settings failed. Please check Billing Country or contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Create Credit System custom setting not with "Schufa" name.
    *  CreatedDate     : 10/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        creditSystem.Name = 'test';
        insert creditSystem;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    } 


    /*******************************************************************************
    *  Summary         : Create Account mapping not with "Schufa" name.
    *  CreatedDate     : 10/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Create Opportunity mapping not with "Schufa" name.
    *  CreatedDate     : 10/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Schufa');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /*******************************************************************************
    *  Summary         : Put in Account address different from Coface company name value                   
    *  CreatedDate     : 11/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testAddressValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
        Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
        mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
        mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
        mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
        mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        controller = new CreditFactoryReportController();
        controller.init();
        controller.doUpdateAddress();
        controller.doUpdateWithAdditionalAddress();
        controller.doUpdateWithPostalAddress();
        controller.doUpdateWithRegisteredAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as Schufa address', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }
    
    
    /******************************************************************************
    *  Summary         : Put in Contact Last name different from Schufa contact Last name value                       
    *  CreatedDate     : 11/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testContactValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        contact.LastName = 'test';
        insert contact;
        
        Task task = CreditFactoryUtils.createTask(opportunity.Id);
        insert task;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryReportController();
            controller.callId = task.Id;
            controller.init();
            controller.confirmContactRole();
            controller.continueValidation();
        Test.stopTest();
        
        System.assertEquals('Schufa Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Summary         : Check valid company name
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testCompanyNameValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
            controller.doUpdateWithAdditionalCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Schufa Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Summary         : Put in Account Vat number different from Schufa company name value.                      
    *  CreatedDate     : 12/03/2020 
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (Schufa to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }
    
    
    /******************************************************************************
    *  Summary         : Check case with different SWIFT BIC numbers from sales and web service                       
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testSwiftBicValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.SWIFT_BIC__c = 'test';
        opportunity.Requested_SWIFT_BIC__c = 'DE89370400440532013000';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateSwiftBic();
        Test.stopTest();

        System.assertEquals('Entered BIC is invalid. Please note that your Customer will need to re- confirm SEPA form with correct bank details', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Opportunity SWIFT BIC has been updated.', ApexPages.getMessages().get(2).getSummary());
    }
    
    
    /******************************************************************************
    *  Summary         : Check case with risky business code
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testBusineesCodeValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;
        
        CF_Risky_Business_Code__c businessCode = new CF_Risky_Business_Code__c(Name = '7112', Countries__c = 'DE');
        insert businessCode;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('High risk industry. Please refer to Credit', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Summary         : Set mock response with high risk and check that error exists                      
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testEmailRiskValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole contactRole = CreditFactoryUtils.createOpportunityContactRoleDE(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
        lexisNexisSettings.Active__c = true;
        update lexisNexisSettings;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            mocksMap.put('https://test.com', LEXIS_NEXIS_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Contact Person has a high email risk. Please refer to Credit', ApexPages.getMessages().get(0).getSummary());
    }
    


    /******************************************************************************
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /*******************************************************************************
    *  Name            : testPaymentMethodValidation()
    *  Summary         : Create Opportunity with "Bank Transfer" payment method    
    *  CreatedDate     : 25/04/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testPaymentMethodValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.Zahlungsart__c = 'Banküberweisung';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole contactRole = CreditFactoryUtils.createOpportunityContactRoleDE(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
        Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity cannot be closed automatically with Payment Method Bank Transfer.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Create Credit Black List Company and Opportunity objects with
                         the same fields   
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.doCreateCreditBlackListCompany(account.Name);
        blackList.Customer_Id__c = 'DE';
        insert blackList;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
            Boolean isCompanyNotInBlackList = controller.reportService.validateBlackList();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals(false, isCompanyNotInBlackList);
    }
 

    /*******************************************************************************
    *  Summary         : Test calculations, ClassRating = 1
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testCalculationRating1() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.getBuffer();
            controller.reportService.getRiskCategory();
            controller.reportService.getSecurityLevel();
            controller.reportService.getCreditLimitWeeklyPlus7();
            controller.reportService.getMaxCreditLimitWeeklyPlus7();
            controller.reportService.getDepositWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus7();
            controller.reportService.getDepositBiWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getCreditLimitMonthlyPlus14();
            controller.reportService.getMaxCreditLimitMonthlyPlus14();
            controller.reportService.getDepositMonthlyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus21();
            controller.reportService.getMaxCreditLimitMonthlyPlus21();
            controller.reportService.getDepositMonthlyPlus21();
            controller.reportService.getCreditLimitMonthlyPlus27();
            controller.reportService.getMaxCreditLimitMonthlyPlus27();
            controller.reportService.getDepositMonthlyPlus27();
            controller.reportService.getMaxValueMonthlyPlus27();
            controller.reportService.getPaymentTerms();
            controller.reportService.getCreditLimit();
            controller.reportService.getMaxCreditLimit();
            controller.reportService.getMaxValue();
            controller.reportService.getDeposit();
            controller.reportService.getDecision();
            controller.changeToClosedWon();
            controller.changeToContractCheck();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '1', 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Test duplicate case
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testDuplicatesCheck() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createAccountDE();
        Account account2 = CreditFactoryUtils.createAccountDE();
        accountsList.add(account);
        account2.Steuernummer__c = '123412341234';
        accountsList.add(account2);
        insert accountsList;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
        Test.stopTest();

        List<Opportunity> opportunitiesToCheckList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('CreditCheck', opportunitiesToCheckList.get(0).StageName);
    }


    /******************************************************************************
    *  Summary         : test calculations, ClassRating = 2
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testCalculationsRating2() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.Zahlungsziel_2__c = '30';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_2_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '2', 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : test calculations, ClassRating = 3
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testCalculationsRating3() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.Zahlungsziel_2__c = '15';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_3_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '3', 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : test calculations, ClassRating = 4
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testCalculationsRating4() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_4_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 1500, '4', 1, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Summary         : test calcualtions, ClassRating = 5, Deposit is provided
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    public static void testCalculationsRating5Deposit() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.Anzahl_der_Karten__c = 3;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_5_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 2000, '5', 1, company);
        Test.stopTest();

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(100, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Summary         : test calculations, ClassRating = 6 
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testCalculationsRating6() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_6_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingDeposit();
            CreditCompany company = new CreditCompany();
            company.classRating = '6';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 3000, '6', 1, company);
        Test.stopTest();        

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(110, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }
    
    
    /*******************************************************************************
    *  Name            : testCreatingAttachment()
    *  Summary         : Test pdf creation
    *  CreatedDate     : 13/03/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCreatingAttachment() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_6_REPORT_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/coredata/economy/pdf', PDF_REPORT_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            ReportSchufaServiceDE.PDFReportCreation pdfCreation = new ReportSchufaServiceDE.PDFReportCreation('1645768', opportunity.id);
            QueueableContext context;
            pdfCreation.execute(context);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE ParentId = :opportunity.Id AND Name = 'SchufaReport.pdf'];

        System.assertEquals(1, attachmentsList.size());
    }


    /*******************************************************************************
    *  Summary         : test calculations with existing report
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        contact.LastName = contact.LastName + 'ÄäÖöÜüß';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createSchufaReport();
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createSchufaReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        creditReportEmployee.Name = creditReportEmployee.Name + 'AEaeOEoeUEuess';
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.setUserSource('test');
            controller.reportService.getUserSource();
            controller.changeBillingPeriodBySales();
            controller.backToOpportunity();
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.saveReports();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /******************************************************************************
    *  Summary         : Set mock response with high risk and check that error exists                      
    *  CreatedDate     : 17/05/2019
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testAPIErrorsLexisNexis() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole contactRole = CreditFactoryUtils.createOpportunityContactRoleDE(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
        lexisNexisSettings.Active__c = true;
        update lexisNexisSettings;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', RATING_1_REPORT_MOCK);
            mocksMap.put('https://test.com', LEXIS_NEXIS_ERROR_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('LexisNexis API error.'));
    }
    
    
    /*******************************************************************************
    *  Summary         : Test case with unavailable report
    *  CreatedDate     : 14/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testNotAvailableReport() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createContactDE(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '1645768');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createSchufaAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', AUTH_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', ORDER_ECONOMY_INFO_MOCK);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', ORDER_STATUS_REPORT_UNAVAILABLE_MOCK);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit report is not available. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }
}