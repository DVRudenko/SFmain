/**
 * Created by marekhaken on 26/08/2020.
 */

global class BizMachineMockImpl implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        Integer statusCode = 200;
        String json = '';
        system.debug(req.getEndpoint());
        if(req.getEndpoint() == 'http://asd.com/prospector/cz/v3/tags/UID/companies'){
            json = '{\n' +
                    '    "data": [\n' +
                    '        {\n' +
                    '            "company": {\n' +
                    '                "bid": "02582589"\n' +
                    '            },\n' +
                    '            "createdAt": "2020-07-01T13:58:38.8166667",\n' +
                    '            "createdBy": {\n' +
                    '                "uid": "d7b4511f-d978-4a0e-a1a4-bfc3ae89b2db"\n' +
                    '            }\n' +
                    '        },\n' +
                    '{\n' +
                    '            "company": {\n' +
                    '                "bid": "47123737"\n' +
                    '            },\n' +
                    '            "description": "91",\n' +
                    '            "createdAt": "2020-06-30T15:08:59.5033333",\n' +
                    '            "createdBy": {\n' +
                    '                "uid": "c6c1513e-5deb-4d2e-b8d5-44e9191557c6"\n' +
                    '            }\n' +
                    '        }\n' +
                    '    ]\n' +
                    '}';
            statusCode = 200;
        }else if(req.getEndpoint() == 'http://asd.com/prospector/cz/v2/companies/02582589/tags/UID' && req.getMethod() == 'POST'){
            json = '';
            statusCode = 200;
        }else if(req.getEndpoint() == 'http://asd.com/prospector/cz/v2/companies/02582589/tags/UID' && req.getMethod() == 'DELETE'){
            json = '';
            statusCode = 204;
        }else if(req.getEndpoint() == 'http://asd.com/prospector/cz/v3/companies/02582589/tags' && req.getMethod() == 'GET'){
            json = '{\n' +
                    '    "data": [\n' +
                    '        {\n' +
                    '            "tag": {\n' +
                    '                "uid": "e7219aca-b67f-41fe-a496-06f65c8b75b2"\n' +
                    '            },\n' +
                    '            "createdAt": "2020-03-08T07:42:00.0066667",\n' +
                    '            "createdBy": {\n' +
                    '                "uid": "d7b4511f-d978-4a0e-a1a4-bfc3ae89b2db"\n' +
                    '            }\n' +
                    '        }\n' +
                    '    ]\n' +
                    '}';
            statusCode = 200;
        }else if(req.getEndpoint() == 'http://asd.com/v1/company/02582589?template=automotive'){
            json ='{\n' +
                    '    "Status": 200,\n' +
                    '    "Data": {\n' +
                    '        "VehiclesOperatedCount": 0,\n' +
                    '        "VehiclesOwnedCount": 0,\n' +
                    '        "ElectricVehiclesCount": 0,\n' +
                    '        "PremiumVehiclesCount": 0,\n' +
                    '        "ElectrobusCount": 0,\n' +
                    '        "MostCommonVehicleBrand": null,\n' +
                    '        "MostCommonVehicleModel": null,\n' +
                    '        "IsImporterOrExporter": false,\n' +
                    '        "ImportantChange": false,\n' +
                    '        "PersonalVehicles": 0,\n' +
                    '        "Trucks": 0,\n' +
                    '        "OtherVehicles": 0,\n' +
                    '        "ConnectedCompaniesCount": "1",\n' +
                    '        "Website": null,\n' +
                    '        "Email": null,\n' +
                    '        "Phone": null,\n' +
                    '        "SelfDeclaredDescription": null,\n' +
                    '        "NetProfitMargin": null,\n' +
                    '        "Employees": {\n' +
                    '            "Code": null,\n' +
                    '            "ValueUpperBound": 0.0,\n' +
                    '            "ValueLowerBound": 0.0\n' +
                    '        },\n' +
                    '        "NACE": {\n' +
                    '            "Primary": null,\n' +
                    '            "Other": []\n' +
                    '        },\n' +
                    '        "MetaIndicators": {\n' +
                    '            "Activity": 0,\n' +
                    '            "Reachability": 0,\n' +
                    '            "Growth": 0\n' +
                    '        },\n' +
                    '        "PublicMoney": {\n' +
                    '            "Currency": "CZK",\n' +
                    '            "Scale": 1000000,\n' +
                    '            "Value": 0.0\n' +
                    '        },\n' +
                    '        "SocialNetworks": {\n' +
                    '            "LinkedIn": null,\n' +
                    '            "Facebook": null,\n' +
                    '            "Twitter": null\n' +
                    '        },\n' +
                    '        "Risks": null,\n' +
                    '        "RegisteredAddress": {\n' +
                    '            "Text": "Lidická 700/19, Brno, 60200",\n' +
                    '            "Latitude": 49.2017983645,\n' +
                    '            "Longitude": 16.6071183531,\n' +
                    '            "NUTSCode": null,\n' +
                    '            "StreetName": "Lidická",\n' +
                    '            "StreetNumber": "700",\n' +
                    '            "City": "Brno",\n' +
                    '            "PostalCode": "60200",\n' +
                    '            "AdmCode": "19173571",\n' +
                    '            "IsEvidenceNumber": false,\n' +
                    '            "HouseNumber": "700",\n' +
                    '            "OrientationNumber": "19",\n' +
                    '            "CountryCode": "CZ",\n' +
                    '            "CityPart": "Veveří",\n' +
                    '            "CityDistrict": "Brno-střed",\n' +
                    '            "Region": "Jihomoravský kraj",\n' +
                    '            "District": "Brno-město",\n' +
                    '            "Lau1Code": "CZ0642"\n' +
                    '        },\n' +
                    '        "FileNumber": "C 119183",\n' +
                    '        "Court": "Krajský soud v Brně",\n' +
                    '        "RegistrationNumber": "09470611",\n' +
                    '        "Name": "EKOTREND STYLE s.r.o.",\n' +
                    '        "DateEstablished": "2020-09-01",\n' +
                    '        "JusticeCzLink": "https://or.justice.cz/ias/ui/rejstrik-$firma?ico=09470611&jenPlatne=VSECHNY",\n' +
                    '        "TaxRegistrationNumber": null,\n' +
                    '        "ProspectorLink": "https://prospector.cz.bizmachine.com/company/09470611",\n' +
                    '        "RiskIndicator": 1,\n' +
                    '        "RevenueGrowth": null,\n' +
                    '        "RegisteredCapital": {\n' +
                    '            "Value": 200.0,\n' +
                    '            "Currency": "CZK",\n' +
                    '            "Scale": 1000\n' +
                    '        },\n' +
                    '        "LegalForm": {\n' +
                    '            "ID": 112,\n' +
                    '            "Text": "Limited liability company"\n' +
                    '        },\n' +
                    '        "Revenue": null,\n' +
                    '        "Owners": [\n' +
                    '            {\n' +
                    '                "Name": "Marek Staňa",\n' +
                    '                "DateOfBirth": "16.02.1995 0:00:00",\n' +
                    '                "RegistrationNumber": null,\n' +
                    '                "Address": {\n' +
                    '                    "Text": "nám. Na podkově 39, Bystré, 56992",\n' +
                    '                    "Latitude": 0.0,\n' +
                    '                    "Longitude": 0.0,\n' +
                    '                    "NUTSCode": null,\n' +
                    '                    "StreetName": "nám. Na podkově",\n' +
                    '                    "StreetNumber": "39",\n' +
                    '                    "City": "Bystré",\n' +
                    '                    "PostalCode": "56992",\n' +
                    '                    "AdmCode": null,\n' +
                    '                    "IsEvidenceNumber": false,\n' +
                    '                    "HouseNumber": null,\n' +
                    '                    "OrientationNumber": null,\n' +
                    '                    "CountryCode": null,\n' +
                    '                    "CityPart": null,\n' +
                    '                    "CityDistrict": null,\n' +
                    '                    "Region": null,\n' +
                    '                    "District": null,\n' +
                    '                    "Lau1Code": null\n' +
                    '                },\n' +
                    '                "Share": 0.5\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "Name": "Jana Jahorná",\n' +
                    '                "DateOfBirth": "31.12.1984 0:00:00",\n' +
                    '                "RegistrationNumber": null,\n' +
                    '                "Address": {\n' +
                    '                    "Text": "Kaly 56, Kaly, 59455",\n' +
                    '                    "Latitude": 0.0,\n' +
                    '                    "Longitude": 0.0,\n' +
                    '                    "NUTSCode": null,\n' +
                    '                    "StreetName": null,\n' +
                    '                    "StreetNumber": "56",\n' +
                    '                    "City": "Kaly",\n' +
                    '                    "PostalCode": "59455",\n' +
                    '                    "AdmCode": null,\n' +
                    '                    "IsEvidenceNumber": false,\n' +
                    '                    "HouseNumber": null,\n' +
                    '                    "OrientationNumber": null,\n' +
                    '                    "CountryCode": null,\n' +
                    '                    "CityPart": null,\n' +
                    '                    "CityDistrict": null,\n' +
                    '                    "Region": null,\n' +
                    '                    "District": null,\n' +
                    '                    "Lau1Code": null\n' +
                    '                },\n' +
                    '                "Share": 0.5\n' +
                    '            }\n' +
                    '        ],\n' +
                    '        "StatutoryReps": [\n' +
                    '            {\n' +
                    '                "Name": "Jana Jahorná",\n' +
                    '                "DateOfBirth": "31.12.1984 0:00:00",\n' +
                    '                "Address": {\n' +
                    '                    "Text": "Kaly 56, Kaly, 59455",\n' +
                    '                    "Latitude": 0.0,\n' +
                    '                    "Longitude": 0.0,\n' +
                    '                    "NUTSCode": null,\n' +
                    '                    "StreetName": null,\n' +
                    '                    "StreetNumber": "56",\n' +
                    '                    "City": "Kaly",\n' +
                    '                    "PostalCode": "59455",\n' +
                    '                    "AdmCode": null,\n' +
                    '                    "IsEvidenceNumber": false,\n' +
                    '                    "HouseNumber": null,\n' +
                    '                    "OrientationNumber": null,\n' +
                    '                    "CountryCode": null,\n' +
                    '                    "CityPart": null,\n' +
                    '                    "CityDistrict": null,\n' +
                    '                    "Region": null,\n' +
                    '                    "District": null,\n' +
                    '                    "Lau1Code": null\n' +
                    '                },\n' +
                    '                "Role": "jednatel"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "Name": "Marek Staňa",\n' +
                    '                "DateOfBirth": "16.02.1995 0:00:00",\n' +
                    '                "Address": {\n' +
                    '                    "Text": "nám. Na podkově 39, Bystré, 56992",\n' +
                    '                    "Latitude": 0.0,\n' +
                    '                    "Longitude": 0.0,\n' +
                    '                    "NUTSCode": null,\n' +
                    '                    "StreetName": "nám. Na podkově",\n' +
                    '                    "StreetNumber": "39",\n' +
                    '                    "City": "Bystré",\n' +
                    '                    "PostalCode": "56992",\n' +
                    '                    "AdmCode": null,\n' +
                    '                    "IsEvidenceNumber": false,\n' +
                    '                    "HouseNumber": null,\n' +
                    '                    "OrientationNumber": null,\n' +
                    '                    "CountryCode": null,\n' +
                    '                    "CityPart": null,\n' +
                    '                    "CityDistrict": null,\n' +
                    '                    "Region": null,\n' +
                    '                    "District": null,\n' +
                    '                    "Lau1Code": null\n' +
                    '                },\n' +
                    '                "Role": "jednatel"\n' +
                    '            }\n' +
                    '        ]\n' +
                    '    },\n' +
                    '    "Meta": {\n' +
                    '        "DataType": "object",\n' +
                    '        "Dataset": "CZ",\n' +
                    '        "CurrentNumberOfAPICallsPerMinute": 2,\n' +
                    '        "RemainingNumberOfAPICallsPerMinute": 98,\n' +
                    '        "CurrentNumberOfAPICallsPerDay": 10,\n' +
                    '        "RemainingNumberOfAPICallsPerDay": 9990,\n' +
                    '        "APIKeyExpiresAt": "2021-01-01T00:00:00"\n' +
                    '    }\n' +
                    '}';
            statusCode = 200;
        }
        // Create a fake response

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(statusCode);
        return res;
    }
}