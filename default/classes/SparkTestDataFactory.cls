public class SparkTestDataFactory {

    public static String URL = CFTestDataFactory.URL;
    public static String TOKEN = CFTestDataFactory.TOKEN;
    public static String inn = CFTestDataFactory.INN;
    public static String sparkId = CFTestDataFactory.SPARK_ID;
    public static String entrepreneurInn = CFTestDataFactory.SOLE_INN;
    public static String companyName = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"';
    public static Map<String, String> responseHeaders = CFTestDataFactory.responseHeaders;
    public static String companyListURI = URL + '/spark/company-list?inn=' + inn + '&onlyMain=true';
    public static String entrepreneurReportURI = URL + '/spark/entrepreneur-short-report?inn=' + entrepreneurInn;
    public static String extendedReportURI = URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId;
    public static String accountingReportURI = URL + '/spark/company-accounting-report?inn=' + inn +'&sparkId=' + sparkId;
    public static String riskReportURI = URL + '/spark/company-spark-risks-report?sparkId=' + sparkId;
    public static String executionProceedingsURI = URL + '/spark/company-execution-proceedings?sparkId=' + sparkId;
    public static String arbitrationSummaryURI = URL + '/spark/company-arbitration-summary?sparkId=' + sparkId;
    public static SingleRequestMock emptyBodyMock = new SingleRequestMock(
            200, 'Complete',
            '{"statusCode":200,"message":"SPARK API","content":[]}',
            responseHeaders);
    public static SingleRequestMock serverErrorMock = new SingleRequestMock(200, 'Complete',
            '{"statusCode":500,"message":"SPARK API",' +
                    '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                    'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
            responseHeaders);
    public static SingleRequestMock proxyErrorMock = new SingleRequestMock(500, 'Failed',
            '{"statusCode":500,"message":"SPARK API",' +
                    '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                    'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
            responseHeaders);
    public static SingleRequestMock noDataMock = new SingleRequestMock(200, 'Complete',
            '{"statusCode":400,"message":"SPARK API",' +
                    '"content":{"code": "400", "msg": "No data found", "field": ""}}',
            responseHeaders);
    public static SingleRequestMock companyListMock = new SingleRequestMock(
            200, 'Complete', '{"statusCode":200,"message":"SPARK API",' +
                    '"content":[{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430",' +
                    '"fullName":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                    '"address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                    '"industry":"Торговля розничная компьютерами, периферийными устройствами' +
                    ' к ним и программным обеспечением в специализированных магазинах",' +
                    '"regionCode":null,"regionName":"Москва","manager":"Управляющая компания ТД НКТ, ООО",' +
                    '"okopfname":"Общества с ограниченной ответственностью","okopfcode":12300}]}',
            responseHeaders);
    public static SingleRequestMock entrepreneurReportMock = new SingleRequestMock(
            200, 'Complete',
            '{"statusCode":200,"message":"SPARK API",' +
                    '"content":{"sparkID":6329708,"status":{"isActing":true,"text":"Действующее","code":24},' +
                    '"dateReg":"2009-08-25T21:00:00.000+0000","fullNameRus":"Иванов Иван Иванович",' +
                    '"inn":"770605086143","ogrnip":"309774623800678","okpo":"0116896779",' +
                    '"okato":{"code":"45286596000","regionName":"Москва","regionCode":45},' +
                    '"birthDate":"1979-03-12T21:00:00.000+0000","birthPlace":"г. Москва",' +
                    '"okved2list":{"okved":[{"code":"74.14","name":"Консультирование по вопросам коммерческой деятельности и управления","isMain":true},' +
                    '{"code":"51.16","name":"Деятельность агентов по оптовой торговле текстильными изделиями, одеждой, обувью, изделиями из кожи и меха","isMain":null},' +
                    '{"code":"51.42","name":"Оптовая торговля одеждой, включая нательное белье, и обувью","isMain":null},' +
                    '{"code":"51.47","name":"Оптовая торговля прочими непродовольственными потребительскими товарами","isMain":null},' +
                    '{"code":"52.4","name":"Прочая розничная торговля в специализированных магазинах","isMain":null},' +
                    '{"code":"52.42","name":"Розничная торговля одеждой","isMain":null},' +
                    '{"code":"52.48.39","name":"Специализированная розничная торговля прочими непродовольственными  товарами, не включенными в другие группировки","isMain":null},' +
                    '{"code":"52.61.2","name":"Розничная торговля, осуществляемая непосредственно при помощи телевидения, радио, телефона и Интернет","isMain":null},' +
                    '{"code":"74.40","name":"Рекламная деятельность","isMain":null},' +
                    '{"code":"80.42","name":"Образование для взрослых и прочие виды образования, не включенные в другие группировки","isMain":null}]}}}',
            responseHeaders);
    public static SingleRequestMock extendedReportMock = new SingleRequestMock(
            200, 'Complete', '{"statusCode":200,"message":"SPARK API",' +
                    '"content":{"sparkID":6329708,"companyType":1,"status":{"date":"2018-07-31T21:00:00.000+0000","type":"Действующее","code":24},' +
                    '"isActing":"true","dateFirstReg":"2008-01-28","shortNameRus":"ООО \\"НКТ СОФТВЭР\\"","shortNameEn":"OOO \\"NKT SOFTVER\\"",' +
                    '"fullNameRus":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                    '"normName":"НКТ СОФТВЭР, ООО","inn":"7743676000","kpp":"771301001","ogrn":"1087746118162",' +
                    '"okpo":"84763430","rts":null,"okato":{"code":"45277586000","regionName":"Москва","regionCode":45},' +
                    '"okogu":{"code":"4210011","name":"Хозяйственные общества и товарищества с участием иностранных ' +
                    'юридических и (или) физических лиц, а также лиц без гражданства"},' +
                    '"okfs":{"code":"34","name":"Совместная частная и иностранная собственность"},' +
                    '"okopf":{"code":"65","name":"Общества с ограниченной ответственностью","codeNew":"12300"},' +
                    '"charterCapital":"500000","leaderList":{"leader":[{"actualDate":"2012-11-05T21:00:00.000+0000",' +
                    '"fio":"Кремнев Антон Юрьевич","position":"президент","inn":null},{"actualDate":"2009-07-19T21:00:00.000+0000",' +
                    '"fio":"Лаврентьев Леонид Геннадьевич","position":"генеральный директор","inn":null},' +
                    '{"actualDate":"2008-01-27T21:00:00.000+0000","fio":"Еремин Игорь Юрьевич","position":"генеральный директор",' +
                    '"inn":"502408806323"}]},"legalAddresses":{"address":{"postCode":"127287","address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                    '"actualDate":"2018-04-27T21:00:00.000+0000","region":"г. Москва","rayon":null,"city":"г. Москва",' +
                    '"streetname":"ул. Хуторская 2-Я","buildingnumber":"дом 38А"}},"adjustAddress":null,' +
                    '"previousAddress":{"address":[{"postCode":"125195","address":"г. Москва, ул. Смольная, д. 20А",' +
                    '"actualDate":"2016-07-21T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Пяловская, д. 7 стр. 3",' +
                    '"actualDate":"2008-08-24T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Дегунинская, д. 10",' +
                    '"actualDate":"2008-01-27T21:00:00.000+0000"}]},"phoneList":{"phone":[{"code":"495","number":7887921,"status":null},' +
                    '{"code":"495","number":7887922,"status":null}]},"faxList":null,"email":null,"www":null,"workersRange":null,' +
                    '"includeInList":{"listName":[{"value":"Компании, отсутствующие по юр. адресу по данным ФНС","id":13,"isNegative":1}]},' +
                    '"creditRisk":null,"failureScore":{"failureScoreValue":"85","failureScoreDesc":"Средний риск"},' +
                    '"paymentIndex":null,"federalTaxRegistration":{"regDate":"2008-01-27T21:00:00.000+0000",' +
                    '"regAuthority":"Межрайонная инспекция ФНС России №46 по г.Москве","regAuthorityAddress":' +
                    '"125373,Москва г,Походный проезд, домовладение 3, стр.2"},' +
                    '"structureInfo":{"countCoownerFCSM":0,"countCoownerRosstat":2,"countCoownerEGRUL":2,"countBranch":0,' +
                    '"countBranchRosstat":0,"countAffiliatedCompanyFCSM":0,"countAffiliatedCompanyRosstat":0,' +
                    '"countAffiliatedCompanyEGRUL":0,"nonprofitOrganizationRosstat":0},"vestnikMessage":null,' +
                    '"bankruptcyMessage":{"messages":[{"idType":500}]},"consolidatedIndicator": {"value":"Low"},"accessibleFinData":{"period":[{"name":"2017","endDate":"2017-12-30T21:00:00.000+0000",' +
                    '"idperiod":547},{"name":"2016","endDate":"2016-12-30T21:00:00.000+0000","idperiod":543},' +
                    '{"name":"2008","endDate":"2008-12-30T21:00:00.000+0000","idperiod":323}]},' +
                    '"finance":{"finPeriod":[{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы",' +
                    '"code":"1110","value":"589000"},{"form":"Баланс","section":"Актив","name":"Основные средства","code":"1150","value":"1064000"},' +
                    '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                    '{"form":"Отчет о прибыли и убытках","section":"Операционные доходы и расходы","name":' +
                    '"Чистая прибыль (убыток)","code":"2400","value":"124078000"}]},' +
                    '"periodName":"2016","dateBegin":"2015-12-31T21:00:00.000+0000","dateEnd":"2016-12-30T21:00:00.000+0000"},' +
                    '{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы","code":"1110","value":"144000"},' +
                    '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                    '{"form":"Отчет о прибыли и убытках","section":"Доходы и расходы по обычным видам деятельности","name":' +
                    '"Выручка","code":"2110","value":"58467000"}]},' +
                    '"periodName":"2017","dateBegin":"2016-12-31T21:00:00.000+0000","dateEnd":"2017-12-30T21:00:00.000+0000"}]},' +
                    '"companyWithSameInfo":{"telephoneCount":{"value":26,"phoneCode":"495","phoneNumber":"7887922"},' +
                    '"addressCount":12,"managerCountInCountry":0,"managerCountInRegion":0},' +
                    '"indexOfDueDiligence":{"index":"1","indexDesc":"Низкий риск"},"companySize":{"revenue":"58,50","description":"Микропредприятие"},' +
                    '"eventsList":null,"boardOfDirectors":null,"executiveBody":{"member":[{"name":"ТД НКТ, ООО","inn":"7743857461",' +
                    '"birthdayYear":null,"position":{"name":"Внешний исполнительный орган","code":0},"sharePart":null}],' +
                    '"actualDate":"2012-11-05T21:00:00.000+0000"},"personsWithoutWarrant":null,"stateContracts":{"federalLaw94":null,' +
                    '"federalLaw223":{"year":[{"tenders":{"admittedNumber":0,"notAdmittedNumber":0,"winnerNumber":0},' +
                    '"contracts":{"signedNumber":1,"sum":"1980645"},"year":2016},{"tenders":{"admittedNumber":8,"notAdmittedNumber":0,"winnerNumber":8},' +
                    '"contracts":{"signedNumber":2,"sum":"1928417"},"year":2015}]}},' +
                    '"arbitrationCases":{"year":[{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":2,"sum":"42854"},' +
                    '"thirdOrOtherPerson":{"casesNumber":0},"year":"2017"},{"plaintiff":{"casesNumber":0,"sum":"0"},' +
                    '"defendant":{"casesNumber":2,"sum":"1259266"},"thirdOrOtherPerson":{"casesNumber":0},"year":"2014"},' +
                    '{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},"thirdOrOtherPerson":{"casesNumber":1},' +
                    '"year":"2013"},{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},' +
                    '"thirdOrOtherPerson":{"casesNumber":0},"year":"2011"}]},"egrullikvidation":null,' +
                    '"okved2list":{"okved":[{"code":"52.48.13","name":"Розничная торговля компьютерами, программным обеспечением ' +
                    'и периферийными устройствами","isMain":true},' +
                    '{"code":"30.02","name":"Производство электронных вычислительных машин и прочего оборудования для обработки информации","isMain":null},' +
                    '{"code":"51.14.2","name":"Деятельность агентов по оптовой торговле прочими видами машин и оборудования","isMain":null},' +
                    '{"code":"51.43.22","name":"Оптовая торговля техническими носителями информации (с записями и без записей)","isMain":null},' +
                    '{"code":"72.2","name":"Разработка программного обеспечения и консультирование в этой области","isMain":null},' +
                    '{"code":"72.3","name":"Обработка данных","isMain":null},' +
                    '{"code":"74.3","name":"Технические испытания, исследования и сертификация","isMain":null}]},"egrpoincluded":"true","fcsmcode":null}}',
            responseHeaders);
    public static SingleRequestMock accountingReportMock = new SingleRequestMock(
            200, 'Complete', '{"statusCode":200,"message":"SPARK API",' +
                    '"content":[{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430","shortName":"ООО \\"НКТ СОФТВЭР\\"",' +
                    '"period":{"form":[{"value":[{"value":65401,"code":"4110","name":"Поступления - всего","column":3},' +
                    '{"value":617,"code":"4490","name":"Величина влияния изменений курса иностранной валюты по отношению к рублю","column":3}],' +
                    '"id":4,"power":1000},{"value":[{"value":500,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":3},' +
                    '{"value":83663,"code":"3600","name":"Чистые активы","column":4}],' +
                    '"id":3,"power":1000},{"value":[{"value":58467,"code":"2110","name":"Выручка","column":3},' +
                    '{"value":-45012,"code":"2500","name":"Совокупный финансовый результат периода","column":4}],' +
                    '"id":2,"power":1000},{"value":[{"value":144,"code":"1110","name":"Нематериальные активы","column":3},' +
                    '{"value":103041,"code":"1700","name":"БАЛАНС (пассив)","column":4}],' +
                    '"id":1,"power":1000}],"periodName":"2017","dateEnd":"2017-12-30T21:00:00.000+0000",' +
                    '"dateBegin":"2016-12-31T21:00:00.000+0000"},"egrpoincluded":"true","egrullikvidation":null}]}',
            responseHeaders);
    public static SingleRequestMock riskReportMock = new SingleRequestMock(
            200, 'Complete', '{"statusCode":200,"message":"SPARK API",' +
                    '"content":{\n' +
                    '    "sparkID": 6232082,\n' +
                    '    "shortName": "СК \\"ВСМ\\" ООО",\n' +
                    '    "fullName": "ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ СТРОИТЕЛЬНАЯ КОМПАНИЯ \\"ВОСТОКСТРОЙМЕХАНИЗАЦИЯ\\"",\n' +
                    '    "inn": "2710014192",\n' +
                    '    "kpp": "272401001",\n' +
                    '    "ogrn": "1072710000714",\n' +
                    '    "okpo": "84477658",\n' +
                    '    "okfs": {\n' +
                    '        "code": "16",\n' +
                    '        "name": "Частная собственность"\n' +
                    '    },\n' +
                    '    "okved": {\n' +
                    '        "code": "42.11",\n' +
                    '        "name": "Строительство автомобильных дорог и автомагистралей",\n' +
                    '        "isMain": true\n' +
                    '    },\n' +
                    '    "status": {\n' +
                    '        "isActing": true,\n' +
                    '        "code": 24,\n' +
                    '        "text": "Действующее",\n' +
                    '        "groupId": 1,\n' +
                    '        "groupName": "Действующее",\n' +
                    '        "date": "2020-12-03T21:00:00.000+0000"\n' +
                    '    },\n' +
                    '    "dateFirstReg": "2007-12-17T21:00:00.000+0000",\n' +
                    '    "charterCapital": {\n' +
                    '        "value": "100000",\n' +
                    '        "actualDate": "2007-11-30T21:00:00.000+0000"\n' +
                    '    },\n' +
                    '    "leader": {\n' +
                    '        "actualDate": "2007-12-17T21:00:00.000+0000",\n' +
                    '        "fio": "Сараев Валерий Иванович",\n' +
                    '        "position": "генеральный директор",\n' +
                    '        "inn": "271001835300",\n' +
                    '        "legalCapacityEndDate": null,\n' +
                    '        "managementCompany": null,\n' +
                    '        "managementCompanyINN": null\n' +
                    '    },\n' +
                    '    "legalAddress": {\n' +
                    '        "postCode": "680000",\n' +
                    '        "address": "Хабаровский кр., г. Хабаровск, ул. Кирпичная, д.  27А офис  6",\n' +
                    '        "region": "Хабаровский кр.",\n' +
                    '        "rayon": null,\n' +
                    '        "city": "г. Хабаровск",\n' +
                    '        "streetName": "ул. Кирпичная",\n' +
                    '        "buildingNumber": "27А",\n' +
                    '        "fiasGUID": "34e6f886-08d5-4617-bab8-be7ce16f386a",\n' +
                    '        "isHouseFiasGUID": true,\n' +
                    '        "fiasCode": "270000010000000035500000000",\n' +
                    '        "fiasRegion": "27",\n' +
                    '        "fiasArea": "000",\n' +
                    '        "fiasCity": "001",\n' +
                    '        "fiasPlace": "000",\n' +
                    '        "fiasPlan": "0000",\n' +
                    '        "fiasStreet": "0355",\n' +
                    '        "actualDate": "2020-11-15T21:00:00.000+0000",\n' +
                    '        "buildingType": "д.",\n' +
                    '        "housingType": null,\n' +
                    '        "housing": null,\n' +
                    '        "blockType": null,\n' +
                    '        "block": null,\n' +
                    '        "roomType": "офис",\n' +
                    '        "room": "6",\n' +
                    '        "businessCenterName": null\n' +
                    '    },\n' +
                    '    "phoneList": {\n' +
                    '        "phone": [\n' +
                    '            {\n' +
                    '                "code": "421",\n' +
                    '                "number": "2272367",\n' +
                    '                "status": null,\n' +
                    '                "verificationDate": null\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "code": "421",\n' +
                    '                "number": "4962300",\n' +
                    '                "status": null,\n' +
                    '                "verificationDate": null\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "code": "42149",\n' +
                    '                "number": "63181",\n' +
                    '                "status": null,\n' +
                    '                "verificationDate": null\n' +
                    '            }\n' +
                    '        ]\n' +
                    '    },\n' +
                    '    "sites": null,\n' +
                    '    "emails": null,\n' +
                    '    "workersRange": "251 .. 500",\n' +
                    '    "vacanciesNumber": 2,\n' +
                    '    "includeInList": {\n' +
                    '        "listName": [\n' +
                    '            {\n' +
                    '                "content": [\n' +
                    '                    "Юр. лица, имеющие задолженность по уплате налогов",\n' +
                    '                    {\n' +
                    '                        "name": "AddInfo",\n' +
                    '                        "declaredType": "ifaxbean.companysparkrisksxml.AddInfo",\n' +
                    '                        "scope": "ifaxbean.companysparkrisksxml.IncludeInList",\n' +
                    '                        "value": {\n' +
                    '                            "addField": [\n' +
                    '                                {\n' +
                    '                                    "value": "50397422",\n' +
                    '                                    "name": "ArrearsSum"\n' +
                    '                                },\n' +
                    '                                {\n' +
                    '                                    "value": "2020-12-04",\n' +
                    '                                    "name": "ActualDate"\n' +
                    '                                }\n' +
                    '                            ]\n' +
                    '                        },\n' +
                    '                        "nil": false,\n' +
                    '                        "globalScope": false,\n' +
                    '                        "typeSubstituted": false\n' +
                    '                    }\n' +
                    '                ],\n' +
                    '                "id": 19,\n' +
                    '                "isNegative": true\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "content": [\n' +
                    '                    "Реестр операторов, осуществляющих обработку персональных данных"\n' +
                    '                ],\n' +
                    '                "id": 18,\n' +
                    '                "isNegative": false\n' +
                    '            }\n' +
                    '        ]\n' +
                    '    },\n' +
                    '    "consolidatedIndicator": {\n' +
                    '        "addInfo": {\n' +
                    '            "addField": [\n' +
                    '                {\n' +
                    '                    "value": "Низкий риск",\n' +
                    '                    "name": "IndexOfDueDiligence"\n' +
                    '                },\n' +
                    '                {\n' +
                    '                    "value": "Высокий риск",\n' +
                    '                    "name": "FailureScore"\n' +
                    '                },\n' +
                    '                {\n' +
                    '                    "value": "В негативном списке",\n' +
                    '                    "name": "NegativeList"\n' +
                    '                }\n' +
                    '            ]\n' +
                    '        },\n' +
                    '        "value": "Medium",\n' +
                    '        "description": "Средний риск"\n' +
                    '    },\n' +
                    '    "indexOfDueDiligence": {\n' +
                    '        "index": "1",\n' +
                    '        "indexDesc": "Низкий риск"\n' +
                    '    },\n' +
                    '    "failureScore": {\n' +
                    '        "failureScoreValue": "94",\n' +
                    '        "failureScoreDesc": "Высокий риск"\n' +
                    '    },\n' +
                    '    "paymentIndex": null,\n' +
                    '    "riskFactors": {\n' +
                    '        "factor": [\n' +
                    '            {\n' +
                    '                "addInfo": [\n' +
                    '                    {\n' +
                    '                        "addField": [\n' +
                    '                            {\n' +
                    '                                "value": "9",\n' +
                    '                                "name": "Number"\n' +
                    '                            }\n' +
                    '                        ]\n' +
                    '                    }\n' +
                    '                ],\n' +
                    '                "id": 20,\n' +
                    '                "name": "У компании есть незавершенные исполнительные производства (база ФССП)"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "addInfo": [],\n' +
                    '                "id": 36,\n' +
                    '                "name": "У компании отсутствует собственный капитал"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "addInfo": [],\n' +
                    '                "id": 40,\n' +
                    '                "name": "Имеются обременения доли в УК"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "addInfo": [\n' +
                    '                    {\n' +
                    '                        "addField": [\n' +
                    '                            {\n' +
                    '                                "value": "2020-11-13",\n' +
                    '                                "name": "Date"\n' +
                    '                            }\n' +
                    '                        ]\n' +
                    '                    }\n' +
                    '                ],\n' +
                    '                "id": 48,\n' +
                    '                "name": "Имеется сообщение о признаках банкротства"\n' +
                    '            }\n' +
                    '        ]\n' +
                    '    },\n' +
                    '    "frozenAccounts": {\n' +
                    '        "decision": [\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "5503",\n' +
                    '                "date": "2020-07-06T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "9948",\n' +
                    '                "date": "2020-09-20T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "12256",\n' +
                    '                "date": "2020-10-15T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813727",\n' +
                    '                    "sparkID": 1119377,\n' +
                    '                    "name": "Банка ВТБ (ПАО) в г. Хабаровске, ФИЛИАЛ"\n' +
                    '                },\n' +
                    '                "number": "12258",\n' +
                    '                "date": "2020-10-15T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "12389",\n' +
                    '                "date": "2020-10-22T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "12388",\n' +
                    '                "date": "2020-10-22T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "13271",\n' +
                    '                "date": "2020-11-15T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813727",\n' +
                    '                    "sparkID": 1119377,\n' +
                    '                    "name": "Банка ВТБ (ПАО) в г. Хабаровске, ФИЛИАЛ"\n' +
                    '                },\n' +
                    '                "number": "5504",\n' +
                    '                "date": "2020-07-06T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813727",\n' +
                    '                    "sparkID": 1119377,\n' +
                    '                    "name": "Банка ВТБ (ПАО) в г. Хабаровске, ФИЛИАЛ"\n' +
                    '                },\n' +
                    '                "number": "9950",\n' +
                    '                "date": "2020-09-20T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813727",\n' +
                    '                    "sparkID": 1119377,\n' +
                    '                    "name": "Банка ВТБ (ПАО) в г. Хабаровске, ФИЛИАЛ"\n' +
                    '                },\n' +
                    '                "number": "12390",\n' +
                    '                "date": "2020-10-22T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "12991",\n' +
                    '                "date": "2020-11-05T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813727",\n' +
                    '                    "sparkID": 1119377,\n' +
                    '                    "name": "Банка ВТБ (ПАО) в г. Хабаровске, ФИЛИАЛ"\n' +
                    '                },\n' +
                    '                "number": "13272",\n' +
                    '                "date": "2020-11-15T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813727",\n' +
                    '                    "sparkID": 1119377,\n' +
                    '                    "name": "Банка ВТБ (ПАО) в г. Хабаровске, ФИЛИАЛ"\n' +
                    '                },\n' +
                    '                "number": "13941",\n' +
                    '                "date": "2020-11-19T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "12257",\n' +
                    '                "date": "2020-10-15T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813727",\n' +
                    '                    "sparkID": 1119377,\n' +
                    '                    "name": "Банка ВТБ (ПАО) в г. Хабаровске, ФИЛИАЛ"\n' +
                    '                },\n' +
                    '                "number": "12992",\n' +
                    '                "date": "2020-11-05T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "12990",\n' +
                    '                "date": "2020-11-05T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "14474",\n' +
                    '                "date": "2020-11-29T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "13940",\n' +
                    '                "date": "2020-11-19T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "14049",\n' +
                    '                "date": "2020-11-22T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "5502",\n' +
                    '                "date": "2020-07-06T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "9949",\n' +
                    '                "date": "2020-09-20T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "13270",\n' +
                    '                "date": "2020-11-15T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "14048",\n' +
                    '                "date": "2020-11-22T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "040813608",\n' +
                    '                    "sparkID": 1121806,\n' +
                    '                    "name": "СБЕРБАНК, ДАЛЬНЕВОСТОЧНЫЙ БАНК ПАО"\n' +
                    '                },\n' +
                    '                "number": "13939",\n' +
                    '                "date": "2020-11-19T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "taxAuthority": {\n' +
                    '                    "code": "2724",\n' +
                    '                    "name": "ИФНС по Железнодорожному району г.Хабаровска"\n' +
                    '                },\n' +
                    '                "bank": {\n' +
                    '                    "bik": "044525976",\n' +
                    '                    "sparkID": 1112755,\n' +
                    '                    "name": "АБСОЛЮТ БАНК (ПАО), АКБ"\n' +
                    '                },\n' +
                    '                "number": "14475",\n' +
                    '                "date": "2020-11-29T21:00:00.000+0000"\n' +
                    '            }\n' +
                    '        ]\n' +
                    '    },\n' +
                    '    "registrar": null,\n' +
                    '    "auditors": null,\n' +
                    '    "headOfCompany": null,\n' +
                    '    "beneficiary": null,\n' +
                    '    "reorganizations": null,\n' +
                    '    "structureInfo": {\n' +
                    '        "activeBranchesRosstatNumber": 0,\n' +
                    '        "activeAffiliatedCompaniesNumber": {\n' +
                    '            "value": 0,\n' +
                    '            "source": null\n' +
                    '        }\n' +
                    '    },\n' +
                    '    "mainCoowners": {\n' +
                    '        "coowner": [\n' +
                    '            {\n' +
                    '                "name": "Сараев Валерий Иванович",\n' +
                    '                "sparkID": null,\n' +
                    '                "address": null,\n' +
                    '                "inn": "271001835300",\n' +
                    '                "ogrn": null,\n' +
                    '                "okpo": null,\n' +
                    '                "manager": null,\n' +
                    '                "managerInn": null,\n' +
                    '                "fullName": null,\n' +
                    '                "okato": null,\n' +
                    '                "sharePart": "100",\n' +
                    '                "okopfname": null\n' +
                    '            }\n' +
                    '        ]\n' +
                    '    },\n' +
                    '    "financeAndTaxesFTS": {\n' +
                    '        "period": {\n' +
                    '            "income": "2696220000",\n' +
                    '            "expenses": "2896470000",\n' +
                    '            "taxes": {\n' +
                    '                "tax": [\n' +
                    '                    {\n' +
                    '                        "id": 2,\n' +
                    '                        "name": "Налог на добавленную стоимость (НДС)",\n' +
                    '                        "sum": "132416208,61"\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "id": 8,\n' +
                    '                        "name": "Страховые взносы на обязательное медицинское страхование в фонд ОМС",\n' +
                    '                        "sum": "14348748,73"\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "id": 12,\n' +
                    '                        "name": "Транспортный налог",\n' +
                    '                        "sum": "1462939,36"\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "id": 14,\n' +
                    '                        "name": "Страховые взносы на обязательное пенсионное страхование в ПФ РФ",\n' +
                    '                        "sum": "62304035,54"\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "id": 17,\n' +
                    '                        "name": "Налог на имущество организаций",\n' +
                    '                        "sum": "931911,04"\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "id": 23,\n' +
                    '                        "name": "Страховые взносы на обязательное социальное страхование",\n' +
                    '                        "sum": "7453601,74"\n' +
                    '                    }\n' +
                    '                ],\n' +
                    '                "sum": "218917445,02"\n' +
                    '            },\n' +
                    '            "endDate": "2019-12-30T21:00:00.000+0000"\n' +
                    '        }\n' +
                    '    },\n' +
                    '    "finance": {\n' +
                    '        "finPeriod": [\n' +
                    '            {\n' +
                    '                "indicator": [\n' +
                    '                    {\n' +
                    '                        "name": "Выручка",\n' +
                    '                        "value": "1158330000",\n' +
                    '                        "idFinPok": 91\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Чистая прибыль (убыток)",\n' +
                    '                        "value": "1221000",\n' +
                    '                        "idFinPok": 100\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Сальдо денежных потоков за отчетный период",\n' +
                    '                        "value": "-492649000",\n' +
                    '                        "idFinPok": 118\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Чистые активы",\n' +
                    '                        "value": "244938000",\n' +
                    '                        "idFinPok": 152\n' +
                    '                    }\n' +
                    '                ],\n' +
                    '                "periodName": "2017",\n' +
                    '                "dateBegin": "2016-12-31T21:00:00.000+0000",\n' +
                    '                "dateEnd": "2017-12-30T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "indicator": [\n' +
                    '                    {\n' +
                    '                        "name": "Выручка",\n' +
                    '                        "value": "2678426000",\n' +
                    '                        "idFinPok": 91\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Чистая прибыль (убыток)",\n' +
                    '                        "value": "-8970000",\n' +
                    '                        "idFinPok": 100\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Сальдо денежных потоков за отчетный период",\n' +
                    '                        "value": "58314000",\n' +
                    '                        "idFinPok": 118\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Чистые активы",\n' +
                    '                        "value": "51592000",\n' +
                    '                        "idFinPok": 152\n' +
                    '                    }\n' +
                    '                ],\n' +
                    '                "periodName": "2018",\n' +
                    '                "dateBegin": "2017-12-31T21:00:00.000+0000",\n' +
                    '                "dateEnd": "2018-12-30T21:00:00.000+0000"\n' +
                    '            },\n' +
                    '            {\n' +
                    '                "indicator": [\n' +
                    '                    {\n' +
                    '                        "name": "Выручка",\n' +
                    '                        "value": "2404617000",\n' +
                    '                        "idFinPok": 91\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Чистая прибыль (убыток)",\n' +
                    '                        "value": "-200250000",\n' +
                    '                        "idFinPok": 100\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Сальдо денежных потоков за отчетный период",\n' +
                    '                        "value": "-239840000",\n' +
                    '                        "idFinPok": 118\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "name": "Чистые активы",\n' +
                    '                        "value": "-43340000",\n' +
                    '                        "idFinPok": 152\n' +
                    '                    }\n' +
                    '                ],\n' +
                    '                "periodName": "2019",\n' +
                    '                "dateBegin": "2018-12-31T21:00:00.000+0000",\n' +
                    '                "dateEnd": "2019-12-30T21:00:00.000+0000"\n' +
                    '            }\n' +
                    '        ],\n' +
                    '        "balanceType": 1\n' +
                    '    },\n' +
                    '    "stateContracts": {\n' +
                    '        "tenders": {\n' +
                    '            "admittedNumber": 0,\n' +
                    '            "notAdmittedNumber": 0,\n' +
                    '            "winnerNumber": 0\n' +
                    '        },\n' +
                    '        "contracts": {\n' +
                    '            "signedNumber": 0,\n' +
                    '            "sum": null\n' +
                    '        }\n' +
                    '    },\n' +
                    '    "arbitrationCases": {\n' +
                    '        "total": 59,\n' +
                    '        "considered": 11,\n' +
                    '        "appealed": 3,\n' +
                    '        "decisionsAndRulings": 5,\n' +
                    '        "completed": 40,\n' +
                    '        "wonNumber": 3\n' +
                    '    },\n' +
                    '    "executionProceedings": {\n' +
                    '        "active": 9,\n' +
                    '        "activeSum": "60227055,41",\n' +
                    '        "executed": 62,\n' +
                    '        "executedSum": "20577181,56",\n' +
                    '        "completedNoLocation": 0,\n' +
                    '        "completedNoProperty": 0,\n' +
                    '        "completedOther": 0,\n' +
                    '        "trafficFines": 5\n' +
                    '    },\n' +
                    '    "pledger": {\n' +
                    '        "active": 12,\n' +
                    '        "ceased": 3\n' +
                    '    },\n' +
                    '    "lessee": {\n' +
                    '        "active": 8,\n' +
                    '        "ceased": 15\n' +
                    '    },\n' +
                    '    "payments": {\n' +
                    '        "number": 6,\n' +
                    '        "payeesNumber": 1\n' +
                    '    },\n' +
                    '    "subsidiesSum": "0",\n' +
                    '    "activeLicensesNumber": 1,\n' +
                    '    "activeCertificatesNumber": 0,\n' +
                    '    "property": {\n' +
                    '        "realPropertiesNumber": 0,\n' +
                    '        "rentalPropertiesNumber": 0,\n' +
                    '        "customsWarehousesNumber": 0,\n' +
                    '        "dutyFreeShopsNumber": 0\n' +
                    '    },\n' +
                    '    "domainsNumber": 0,\n' +
                    '    "trademarksNumber": 0,\n' +
                    '    "usingTrademarksNumber": 0,\n' +
                    '    "inspections": {\n' +
                    '        "completed": 0,\n' +
                    '        "withViolations": 0,\n' +
                    '        "scheduled": 0\n' +
                    '    },\n' +
                    '    "sros": {\n' +
                    '        "sro": [\n' +
                    '            {\n' +
                    '                "sparkID": 6768188,\n' +
                    '                "name": "АСРО ДВОСТ",\n' +
                    '                "inn": "2721163005",\n' +
                    '                "ogrn": "1082700001064"\n' +
                    '            }\n' +
                    '        ]\n' +
                    '    }\n' +
                    '}}',
            responseHeaders);
    public static SingleRequestMock executionProceedingsMock = new SingleRequestMock(
            200, 'Complete', '{"statusCode":200,"message":"SPARK API",' +
                    '"content":[\n' +
                    '    {\n' +
                    '        "sparkID": 709672,\n' +
                    '        "shortName": "ЗАО \\"ЭФЦЕТ\\"",\n' +
                    '        "inn": "1654043325",\n' +
                    '        "ogrn": "1021602858694",\n' +
                    '        "okpo": "56340564",\n' +
                    '        "okato": "92401367000",\n' +
                    '        "status": {\n' +
                    '            "isActing": true,\n' +
                    '            "code": 24,\n' +
                    '            "text": "Действующее",\n' +
                    '            "date": "2020-12-03T21:00:00.000+0000"\n' +
                    '        },\n' +
                    '        "executionProceedings": {\n' +
                    '            "executionProceeding": [\n' +
                    '                {\n' +
                    '                    "number": "121923/17/16006-ИП",\n' +
                    '                    "date": "2017-11-29T21:00:00.000+0000",\n' +
                    '                    "payoutAmount": "3000",\n' +
                    '                    "department": "ОСП по ИД и ВАП по г. Казани, 420126, г. Казань, ул.Голубятникова, д.24",\n' +
                    '                    "document": "Акт по делу об административном правонарушении от 2017-05-31 № 5-5-475/16",\n' +
                    '                    "type": {\n' +
                    '                        "value": "Штраф как вид наказания по делам об АП, назначенный судом (за исключением дел по протоколам ФССП)",\n' +
                    '                        "groupId": 11,\n' +
                    '                        "groupName": "Штрафы и возмещение ущерба",\n' +
                    '                        "id": 140\n' +
                    '                    },\n' +
                    '                    "terminationReason": {\n' +
                    '                        "id": 1,\n' +
                    '                        "name": "Возвращено. Невозможно установить местонахождение должника либо его имущества",\n' +
                    '                        "date": "2018-08-19T21:00:00.000+0000"\n' +
                    '                    },\n' +
                    '                    "isExecuted": true\n' +
                    '                }\n' +
                    '            ]\n' +
                    '        }\n' +
                    '    }\n' +
                    ']}',
            responseHeaders);
    public static SingleRequestMock arbitrationSummaryMock = new SingleRequestMock(
            200, 'Complete', '{"statusCode":200,"message":"SPARK API",' +
                    '"content":[\n' +
                    '    {\n' +
                    '        "sparkID": 709672,\n' +
                    '        "shortName": "ЗАО \\"ЭФЦЕТ\\"",\n' +
                    '        "inn": "1654043325",\n' +
                    '        "ogrn": "1021602858694",\n' +
                    '        "okpo": "56340564",\n' +
                    '        "okato": "92401367000",\n' +
                    '        "status": {\n' +
                    '            "isActing": true,\n' +
                    '            "code": 24,\n' +
                    '            "text": "Действующее",\n' +
                    '            "date": "2020-12-01T21:00:00.000+0000"\n' +
                    '        },\n' +
                    '        "arbitrationSummary": {\n' +
                    '            "plaintiff": {\n' +
                    '                "decisionsAndRulingsByResult": null,\n' +
                    '                "completedByResult": {\n' +
                    '                    "resultType": [\n' +
                    '                        {\n' +
                    '                            "id": 1,\n' +
                    '                            "name": "Иск удовлетворен полностью",\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "863550"\n' +
                    '                        },\n' +
                    '                        {\n' +
                    '                            "id": 2,\n' +
                    '                            "name": "Иск удовлетворен частично",\n' +
                    '                            "casesNumber": 2,\n' +
                    '                            "sum": "2102578"\n' +
                    '                        },\n' +
                    '                        {\n' +
                    '                            "id": 3,\n' +
                    '                            "name": "Иск не удовлетворен",\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "863550"\n' +
                    '                        }\n' +
                    '                    ]\n' +
                    '                },\n' +
                    '                "total": 4,\n' +
                    '                "totalSum": "3829678",\n' +
                    '                "considered": 0,\n' +
                    '                "consideredSum": "0",\n' +
                    '                "appealed": 0,\n' +
                    '                "appealedSum": "0",\n' +
                    '                "decisionsAndRulings": 0,\n' +
                    '                "decisionsAndRulingsSum": "0",\n' +
                    '                "completed": 4,\n' +
                    '                "completedSum": "3829678"\n' +
                    '            },\n' +
                    '            "defendant": {\n' +
                    '                "decisionsAndRulingsByResult": null,\n' +
                    '                "completedByResult": {\n' +
                    '                    "resultType": [\n' +
                    '                        {\n' +
                    '                            "id": 3,\n' +
                    '                            "name": "Иск не удовлетворен",\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "196939"\n' +
                    '                        }\n' +
                    '                    ]\n' +
                    '                },\n' +
                    '                "total": 1,\n' +
                    '                "totalSum": "196939",\n' +
                    '                "considered": 0,\n' +
                    '                "consideredSum": "0",\n' +
                    '                "appealed": 0,\n' +
                    '                "appealedSum": "0",\n' +
                    '                "decisionsAndRulings": 0,\n' +
                    '                "decisionsAndRulingsSum": "0",\n' +
                    '                "completed": 1,\n' +
                    '                "completedSum": "196939"\n' +
                    '            },\n' +
                    '            "arbitrationByType": {\n' +
                    '                "type": [\n' +
                    '                    {\n' +
                    '                        "plaintiff": {\n' +
                    '                            "total": 1,\n' +
                    '                            "considered": 0,\n' +
                    '                            "appealed": 0,\n' +
                    '                            "completed": 1\n' +
                    '                        },\n' +
                    '                        "defendant": {\n' +
                    '                            "total": 0,\n' +
                    '                            "considered": 0,\n' +
                    '                            "appealed": 0,\n' +
                    '                            "completed": 0\n' +
                    '                        },\n' +
                    '                        "id": 42,\n' +
                    '                        "name": "Заключение договоров"\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "plaintiff": {\n' +
                    '                            "total": 3,\n' +
                    '                            "considered": 0,\n' +
                    '                            "appealed": 0,\n' +
                    '                            "completed": 3\n' +
                    '                        },\n' +
                    '                        "defendant": {\n' +
                    '                            "total": 1,\n' +
                    '                            "considered": 0,\n' +
                    '                            "appealed": 0,\n' +
                    '                            "completed": 1\n' +
                    '                        },\n' +
                    '                        "id": 1,\n' +
                    '                        "name": "Исполнение обязательств по договорам"\n' +
                    '                    }\n' +
                    '                ]\n' +
                    '            },\n' +
                    '            "arbitrationByYear": {\n' +
                    '                "year": [\n' +
                    '                    {\n' +
                    '                        "plaintiff": {\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "863550"\n' +
                    '                        },\n' +
                    '                        "defendant": {\n' +
                    '                            "casesNumber": 0,\n' +
                    '                            "sum": "0"\n' +
                    '                        },\n' +
                    '                        "thirdOrOtherPerson": {\n' +
                    '                            "casesNumber": 1\n' +
                    '                        },\n' +
                    '                        "year": 2020\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "plaintiff": {\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "863550"\n' +
                    '                        },\n' +
                    '                        "defendant": {\n' +
                    '                            "casesNumber": 0,\n' +
                    '                            "sum": "0"\n' +
                    '                        },\n' +
                    '                        "thirdOrOtherPerson": {\n' +
                    '                            "casesNumber": 0\n' +
                    '                        },\n' +
                    '                        "year": 2019\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "plaintiff": {\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "336577"\n' +
                    '                        },\n' +
                    '                        "defendant": {\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "196939"\n' +
                    '                        },\n' +
                    '                        "thirdOrOtherPerson": {\n' +
                    '                            "casesNumber": 0\n' +
                    '                        },\n' +
                    '                        "year": 2016\n' +
                    '                    },\n' +
                    '                    {\n' +
                    '                        "plaintiff": {\n' +
                    '                            "casesNumber": 1,\n' +
                    '                            "sum": "1766000"\n' +
                    '                        },\n' +
                    '                        "defendant": {\n' +
                    '                            "casesNumber": 0,\n' +
                    '                            "sum": "0"\n' +
                    '                        },\n' +
                    '                        "thirdOrOtherPerson": {\n' +
                    '                            "casesNumber": 1\n' +
                    '                        },\n' +
                    '                        "year": 2015\n' +
                    '                    }\n' +
                    '                ]\n' +
                    '            },\n' +
                    '            "total": 7,\n' +
                    '            "considered": 1,\n' +
                    '            "appealed": 0,\n' +
                    '            "decisionsAndRulings": 0,\n' +
                    '            "completed": 6\n' +
                    '        }\n' +
                    '    }\n' +
                    ']}',
            responseHeaders);

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {
        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(SparkTestDataFactory.companyListURI, SparkTestDataFactory.companyListMock);
        responses.put(SparkTestDataFactory.entrepreneurReportURI, SparkTestDataFactory.entrepreneurReportMock);
        responses.put(SparkTestDataFactory.accountingReportURI, SparkTestDataFactory.accountingReportMock);
        responses.put(SparkTestDataFactory.extendedReportURI, SparkTestDataFactory.extendedReportMock);
        responses.put(SparkTestDataFactory.riskReportURI, SparkTestDataFactory.riskReportMock);
        responses.put(SparkTestDataFactory.executionProceedingsURI, SparkTestDataFactory.executionProceedingsMock);
        responses.put(SparkTestDataFactory.arbitrationSummaryURI, SparkTestDataFactory.arbitrationSummaryMock);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMockEmpty() {
        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(SparkTestDataFactory.companyListURI, SparkTestDataFactory.emptyBodyMock);
        responses.put(SparkTestDataFactory.entrepreneurReportURI, SparkTestDataFactory.emptyBodyMock);
        responses.put(SparkTestDataFactory.accountingReportURI, SparkTestDataFactory.emptyBodyMock);
        responses.put(SparkTestDataFactory.extendedReportURI, SparkTestDataFactory.emptyBodyMock);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock400(){
        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(SparkTestDataFactory.companyListURI, SparkTestDataFactory.noDataMock);
        responses.put(SparkTestDataFactory.entrepreneurReportURI, SparkTestDataFactory.noDataMock);
        responses.put(SparkTestDataFactory.accountingReportURI, SparkTestDataFactory.noDataMock);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMockError500(){
        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(SparkTestDataFactory.companyListURI, SparkTestDataFactory.serverErrorMock);
        responses.put(SparkTestDataFactory.entrepreneurReportURI, SparkTestDataFactory.serverErrorMock);
        responses.put(SparkTestDataFactory.accountingReportURI, SparkTestDataFactory.serverErrorMock);
        responses.put(SparkTestDataFactory.extendedReportURI, SparkTestDataFactory.serverErrorMock);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {
        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(SparkTestDataFactory.companyListURI, SparkTestDataFactory.proxyErrorMock);
        responses.put(SparkTestDataFactory.entrepreneurReportURI, SparkTestDataFactory.proxyErrorMock);
        responses.put(SparkTestDataFactory.accountingReportURI, SparkTestDataFactory.proxyErrorMock);
        responses.put(SparkTestDataFactory.extendedReportURI, SparkTestDataFactory.proxyErrorMock);
        return responses;
    }

}