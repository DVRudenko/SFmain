public class HealthCheckCreditFactoryBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private String query;


    /*******************************************************************************
    *  Name            : HealthCheckCreditFactoryBatch()
    *  Summary         : Constructor
    *  CreatedDate     : 09/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public HealthCheckCreditFactoryBatch() {
        this.query = 'SELECT Name__c, Id__c, Country__c, City__c, Tax_Id__c, Archive_Id__c, Vat_Number__c ' +
                     'FROM Health_Check_Credit_Factory__c ';
    }


    /*******************************************************************************
    *  Name            : Database.QueryLocator start(Database.BatchableContext bc) 
    *  Summary         : Collect list of Health_Check_Credit_Factory__c to pass to the execute method
    *  CreatedDate     : 09/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    *****************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }


     /*******************************************************************************
    *  Name            : execute(Database.BatchableContext BC, List<Health_Check_Credit_Factory__c> scope)
    *  Summary         : Do callouts to the Credit Factory web services and create Health_Check_Credit_Factory__c objects in case of errors
    *  CreatedDate     : 09/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job, 
                         List<Health_Check_Credit_Factory__c> scope - list of Health_Check_Credit_Factory__c
    *  Returns         : void
    ******************************************************************************/
    public void execute(Database.BatchableContext BC, List<Health_Check_Credit_Factory__c> scope) {
        try {
            List<CreditSystem__c> creditSystemsList = CreditSystem__c.getAll().values();
            Map<String, CreditSystem__c> creditSystemsMap = new Map<String, CreditSystem__c>();
            for (CreditSystem__c creditSystem : creditSystemsList) {
                if (creditSystem.Supported_Countries__c != null) {
                    for (String country : creditSystem.Supported_Countries__c.split(',')) {
                        creditSystemsMap.put(country, creditSystem);
                    }
                }
            }

            List<HealthCheckResult> resultsList = new List<HealthCheckResult>();
            for (Health_Check_Credit_Factory__c creditFactory : scope) {
                if (creditFactory.Country__c == 'Germany') resultsList.addAll(checkGermanCreditFactory(creditSystemsMap.get('Germany'), creditFactory));
                if (creditFactory.Country__c == 'Netherlands') resultsList.addAll(checkNetherlandsCreditFactory(creditSystemsMap.get('Netherlands'), creditFactory));
                if (creditFactory.Country__c == 'Belgium-NL') resultsList.addAll(checkBelgiumNLCreditFactory(creditSystemsMap.get('Belgium-NL'), creditFactory));
                if (creditFactory.Country__c == 'Belgium-FR') resultsList.addAll(checkBelgiumFRCreditFactory(creditSystemsMap.get('Belgium-FR'), creditFactory));
                if (creditFactory.Country__c == 'Poland') resultsList.addAll(checkPolandCreditFactory(creditSystemsMap.get('Poland'), creditFactory));
                if (creditFactory.Country__c == 'Hungary') resultsList.addAll(checkHungaryCreditFactory(creditSystemsMap.get('Hungary'), creditFactory));
            }

            List<Health_Check__c> healthChecksList = new List<Health_Check__c>();
            for (HealthCheckResult result : resultsList) {
                if (result.isError == true) {
                    healthChecksList.add(new Health_Check__c(
                        Name='CF WebServiceError',
                        Country__c = result.country,
                        Error__c = 'Web Service is not available',
                        Error_Description__c = (String.isEmpty(result.requestType) == false ? 'Request Type: ' + result.requestType + '\n\n' : '') +
                                               (String.isEmpty(result.exceptionDescription) == false ? 'Exception: ' + result.exceptionDescription + '\n\n' : '') +
                                               (String.isEmpty(result.responseBody) == false ? 'Response body: ' + result.responseBody + '\n\n' : '') +
                                               (result.responseStatusCode != null ? 'Response status code: ' + result.responseStatusCode + '\n\n' : '')
                    ));
                }
            }

            if (! healthChecksList.isEmpty()) {
                insert healthChecksList;
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage(), String.valueOf(e.getStackTraceString()));
        }
    }


    public void finish(Database.BatchableContext BC) {}


    /*******************************************************************************
    *  Name            : checkGermanCreditFactory(Map<String, CreditSystem__c> creditSystemsMap, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check availability of Creditreform service for Germany. 
    *  CreatedDate     : 28/12/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : List<HealthCheckResult>
    ******************************************************************************/
    private List<HealthCheckResult> checkGermanCreditFactory(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        List<HealthCheckResult> resultsList = new List<HealthCheckResult>();
        if (creditFactory.Name__c != null) resultsList.add(checkSearchDE(creditSystem, creditFactory));
        return resultsList;
    }


    /*******************************************************************************
    *  Summary         : Check search for Germany.
    *  CreatedDate     : 16/03/2020
    *  Parameters      : creditSystemsMap - credit system settings
                         creditFactory - data for credit factory request
    *  Returns         : Health check result
    ******************************************************************************/
    private HealthCheckResult checkSearchDE(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Germany';
        result.requestType = 'Search';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
			HttpRequest authRequest = CreditFactoryWebSchufa.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
			HttpResponse authResponse = http.send(authRequest);

			SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());
			HttpRequest searchRequest = CreditFactoryWebSchufa.generateSearchRequest(authEntity.accessToken, creditSystem.Endpoint__c, creditFactory.Name__c,
																			        null, null);
			HttpResponse searchResponse = http.send(searchRequest);
            body = searchResponse.getBody();
			SchufaEntity searchEntity = SchufaEntity.parse(searchResponse.getBody());
			List<CreditCompany> creditCompaniesList = CreditFactoryWebSchufa.returnSearchCompany(searchEntity);
            if (! creditCompaniesList.isEmpty()) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkNetherlandsCreditFactory(Map<String, CreditSystem__c> creditSystemsMap, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check availability of Creditsafe service for Netherlands. 
    *  CreatedDate     : 28/12/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : List<HealthCheckResult>
    ******************************************************************************/
    private List<HealthCheckResult> checkNetherlandsCreditFactory(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        List<HealthCheckResult> resultsList = new List<HealthCheckResult>();
        if (creditFactory.Tax_Id__c != null) resultsList.add(checkSearchByTaxIdNL(creditSystem, creditFactory));
        if (creditFactory.Name__c != null) resultsList.add(checkSearchByNameNL(creditSystem, creditFactory));
        if (creditFactory.Id__c != null) resultsList.add(checkReportNL(creditSystem, creditFactory));
        return resultsList;
    }


    /*******************************************************************************
    *  Name            : checkSearchByTaxIdNL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by Tax Id for Netherlands.
    *  CreatedDate     : 28/12/2018
    *  ModifiedDate    : 26/08/2019
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByTaxIdNL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Netherlands';
        result.requestType = 'Search By Tax Id';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);

            HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c, 'NL', 
                creditFactory.Tax_Id__c, null, null, null, null);
            HttpResponse searchResponse = http.send(searchRequest);
            body = searchResponse.getBody();
            CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(body);
            List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, 'NL');
            if (! creditCompaniesList.isEmpty()) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkSearchByNameNL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by name for Netherlands.
    *  CreatedDate     : 28/12/2018
    *  ModifiedDate    : 26/08/2019
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByNameNL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Netherlands';
        result.requestType = 'Search By Name';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);
            HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c, 'NL', null, 
                creditFactory.Name__c, null, null, null);
            HttpResponse searchResponse = http.send(searchRequest);
            body = searchResponse.getBody();
            CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(body);
            List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, 'NL');
            if (! creditCompaniesList.isEmpty()) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkReportNL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check report for Netherlands.
    *  CreatedDate     : 28/12/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkReportNL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Netherlands';
        result.requestType = 'Report';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);

            HttpRequest jsonReportRequest = CreditSafeWebservice.generateJSONReportRequest(authEntity.token, creditSystem.Endpoint__c, creditFactory.Id__c);
            HttpResponse jsonResponse = http.send(jsonReportRequest);
            body = jsonResponse.getBody();
            CreditCompany company = CreditsafeWebservice.returnReportCompany(body, 'NL');
            if (company.identificationnumber != null) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkBelgiumNLCreditFactory(Map<String, CreditSystem__c> creditSystemsMap, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check availability of Creditsafe service for Belgium-NL. 
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : List<HealthCheckResult>
    ******************************************************************************/
    private List<HealthCheckResult> checkBelgiumNLCreditFactory(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        List<HealthCheckResult> resultsList = new List<HealthCheckResult>();
        if (creditFactory.Tax_Id__c != null) resultsList.add(checkSearchByTaxIdBENL(creditSystem, creditFactory));
        if (creditFactory.Name__c != null) resultsList.add(checkSearchByNameBENL(creditSystem, creditFactory));
        if (creditFactory.Id__c != null) resultsList.add(checkReportBENL(creditSystem, creditFactory));
        return resultsList;
    }


    /*******************************************************************************
    *  Name            : checkSearchByTaxIdBENL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by Tax Id for Belgium-NL.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByTaxIdBENL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Belgium-NL';
        result.requestType = 'Search By Tax Id';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);

            HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c, 'BENL', 
                creditFactory.Tax_Id__c, null, null, null, null);
            HttpResponse searchResponse = http.send(searchRequest);
            body = searchResponse.getBody();
            CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(body);
            List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, 'BENL');
            if (! creditCompaniesList.isEmpty()) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkSearchByNameBENL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by name for Belgium-NL.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByNameBENL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Belgium-NL';
        result.requestType = 'Search By Name';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);
            HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c, 'BENL', null, 
                creditFactory.Name__c, null, null, null);
            HttpResponse searchResponse = http.send(searchRequest);
            body = searchResponse.getBody();
            CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(body);
            List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, 'BENL');
            if (! creditCompaniesList.isEmpty()) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkReportBENL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check report for Belgium-NL.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkReportBENL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Belgium-NL';
        result.requestType = 'Report';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);

            HttpRequest jsonReportRequest = CreditSafeWebservice.generateJSONReportRequest(authEntity.token, creditSystem.Endpoint__c, creditFactory.Id__c);
            HttpResponse jsonResponse = http.send(jsonReportRequest);
            body = jsonResponse.getBody();
            CreditCompany company = CreditsafeWebservice.returnReportCompany(body, 'BENL');
            if (company.identificationnumber != null) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkBelgiumFRCreditFactory(Map<String, CreditSystem__c> creditSystemsMap, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check availability of Creditsafe service for Belgium-FR. 
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : List<HealthCheckResult>
    ******************************************************************************/
    private List<HealthCheckResult> checkBelgiumFRCreditFactory(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        List<HealthCheckResult> resultsList = new List<HealthCheckResult>();
        if (creditFactory.Tax_Id__c != null) resultsList.add(checkSearchByTaxIdBEFR(creditSystem, creditFactory));
        if (creditFactory.Name__c != null) resultsList.add(checkSearchByNameBEFR(creditSystem, creditFactory));
        if (creditFactory.Id__c != null) resultsList.add(checkReportBEFR(creditSystem, creditFactory));
        return resultsList;
    }


    /*******************************************************************************
    *  Name            : checkSearchByTaxIdBEFR(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by Tax Id for Belgium-FR.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByTaxIdBEFR(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Belgium-FR';
        result.requestType = 'Search By Tax Id';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);

            HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c, 'BEFR', 
                creditFactory.Tax_Id__c, null, null, null, null);
            HttpResponse searchResponse = http.send(searchRequest);
            body = searchResponse.getBody();
            CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(body);
            List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, 'BEFR');
            if (! creditCompaniesList.isEmpty()) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkSearchByNameBEFR(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by name for Belgium-FR.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByNameBEFR(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Belgium-FR';
        result.requestType = 'Search By Name';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);

            HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(authEntity.token, creditSystem.Endpoint__c, 'BEFR', null, 
                creditFactory.Name__c, null, null, null);
            HttpResponse searchResponse = http.send(searchRequest);
            body = searchResponse.getBody();
            CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(body);
            List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, 'BEFR');
            if (! creditCompaniesList.isEmpty()) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkReportBEFR(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check report for Belgium-FR.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkReportBEFR(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Belgium-FR';
        result.requestType = 'Report';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            body = authResponse.getBody();
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(body);

            HttpRequest jsonReportRequest = CreditSafeWebservice.generateJSONReportRequest(authEntity.token, creditSystem.Endpoint__c, creditFactory.Id__c);
            HttpResponse jsonResponse = http.send(jsonReportRequest);
            body = jsonResponse.getBody();
            CreditCompany company = CreditsafeWebservice.returnReportCompany(body, 'BEFR');
            if (company.identificationnumber != null) isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkPolandCreditFactory(Map<String, CreditSystem__c> creditSystemsMap, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check availability of Crif service for Poland. 
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : List<HealthCheckResult>
    ******************************************************************************/
    private List<HealthCheckResult> checkPolandCreditFactory(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        List<HealthCheckResult> resultsList = new List<HealthCheckResult>();
        if (creditFactory.Name__c != null && creditFactory.Tax_Id__c != null) resultsList.add(checkSearchPL(creditSystem, creditFactory));
        if (creditFactory.Id__c != null) resultsList.add(checkXMLReportPL(creditSystem, creditFactory));
        if (creditFactory.Archive_Id__c != null) resultsList.add(checkPDFReportPL(creditSystem, creditFactory));
        return resultsList;
    }


    /*******************************************************************************
    *  Name            : checkSearchPL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search for Poland.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchPL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Poland';
        result.requestType = 'Search';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CreditFactoryWebCrif.generateSearchRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c,
                new Map<String, String> {'name' => creditFactory.Name__c, 'taxId' => creditFactory.Tax_Id__c});
            Http h = new Http();
            HttpResponse response = h.send(request);
            statusCode = response.getStatusCode();
            body = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(body);
            Dom.XMLNode xmlDom = domDoc.getRootElement();

            Dom.XMLNode searchDom = CreditFactoryWebCrif.returnSearchResponse(xmlDom);
            if (searchDom != null) {            
                for (Dom.XMLNode bodyField : searchDom.getChildElements()) {
                    if (bodyField.getName() == 'Candidates') {
                        for (Dom.XMLNode candidatesField : bodyField.getChildElements()) {
                            if (candidatesField.getName() == 'Address') {
                                for (Dom.XMLNode addressField : candidatesField.getChildElements()) {
                                    if (addressField.getName() == 'CompanyRegistrationInfo') {
                                        for (Dom.XMLNode companyRegistrationInfoField : addressField.getChildElements()) {
                                            if (companyRegistrationInfoField.getName() == 'directoryEntry') {
                                                String type;
                                                for (Dom.XMLNode directoryEntryField : companyRegistrationInfoField.getChildElements()) {
                                                    if (directoryEntryField.getName() == 'type' && directoryEntryField.getText() == 'PL_NIP') type = 'PL_NIP';
                                                    if (directoryEntryField.getName() == 'ID' && directoryEntryField.getText() != null && type == 'PL_NIP') isError = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkXMLReportPL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check XML report for Poland.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkXMLReportPL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Poland';
        result.requestType = 'XML Report';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CreditFactoryWebCrif.generateReportRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, creditFactory.Id__c);
            Http h = new Http();
            HttpResponse response = h.send(request);
            statusCode = response.getStatusCode();
            body = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(body);
            Dom.XMLNode xmlDom = domDoc.getRootElement();

            Dom.XMLNode reportDom = CreditFactoryWebCrif.returnReportBody(xmlDom);
            if (reportDom != null) {
                for (Dom.XMLNode bodyField : reportDom.getChildElements()) {
                    if (bodyField.getName() == 'orderCheckResponse') {
                        for (Dom.XMLNode orderCheckResponseField : bodyField.getChildElements()) {
                            if (orderCheckResponseField.getName() == 'companyBasicData') {
                                for (Dom.XMLNode companyBasicDataField : orderCheckResponseField.getChildElements()) {
                                    if (companyBasicDataField.getName() == 'registration') {
                                        for (Dom.XMLNode registrationField : companyBasicDataField.getChildElements()) {
                                            if (registrationField.getName() == 'companyRegistry') {
                                                String type;
                                                for (Dom.XMLNode companyRegistryField : registrationField.getChildElements()) {
                                                    if (companyRegistryField.getName() == 'type' && companyRegistryField.getText() == 'PL_NIP') type = 'PL_NIP';
                                                    if (companyRegistryField.getName() == 'number' && companyRegistryField.getText() != null && type == 'PL_NIP') isError = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkPDFReportPL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check PDF report for Poland.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkPDFReportPL(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Poland';
        result.requestType = 'PDF Report';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CreditFactoryWebCrif.generatePdfRequest(creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, creditFactory.Archive_Id__c);
            Http h = new Http();
            HttpResponse response = h.send(request);
            statusCode = response.getStatusCode();
            body = response.getBody();
            isError = false;
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkHungaryCreditFactory(Map<String, CreditSystem__c> creditSystemsMap, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check availability of Crif service for Hungary. 
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : List<HealthCheckResult>
    ******************************************************************************/
    private List<HealthCheckResult> checkHungaryCreditFactory(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        List<HealthCheckResult> resultsList = new List<HealthCheckResult>();
        if (creditFactory.Vat_Number__c != null) resultsList.add(checkSearchByVatNumberHU(creditSystem, creditFactory));
        if (creditFactory.Name__c != null) resultsList.add(checkSearchByNameHU(creditSystem, creditFactory));
        if (creditFactory.Id__c != null) {  
            resultsList.add(checkReportAvailabilityHU(creditSystem, creditFactory));
        }
        return resultsList;
    }


    /*******************************************************************************
    *  Name            : checkSearchByVatNumberHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by Vat Number for Hungary.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByVatNumberHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Hungary';
        result.requestType = 'Search By Vat Number';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CofaceWebservice.generateSearchRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c,
                null, 'HU', null, null, creditFactory.Vat_Number__c);
            Http h = new Http();
            HttpResponse response = h.send(request);  
            statusCode = response.getStatusCode();
            body = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(body);
            Dom.XMLNode xmlDom = domDoc.getRootElement();

            Dom.XMLNode searchDom = CofaceWebservice.returnGlobalBody(xmlDom);
            if (searchDom != null) {
                for (Dom.XMLNode bodyField : searchDom.getChildElements()) {
                    if (bodyField.getName() == 'searchByIdentifierResponse') {
                        for (Dom.XMLNode searchByIdentifierResponseField : bodyField.getChildElements()) {
                            if (searchByIdentifierResponseField.getName() == 'searchByIdentifierResult') {
                                for (Dom.XMLNode searchByIdentifierResultField : searchByIdentifierResponseField.getChildElements()) {
                                    if (searchByIdentifierResultField.getName() == 'SearchResults') {
                                        for (Dom.XMLNode searchResults : searchByIdentifierResultField.getChildElements()) {
                                            if (searchResults.getName() == 'SearchResult') {
                                                for (Dom.XMLNode searchResultField : searchResults.getChildElements()) {
                                                    if (searchResultField.getName() == 'InternalID' && searchResultField.getText() != null) isError = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkSearchByNameHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check search by Name for Hungary.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkSearchByNameHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Hungary';
        result.requestType = 'Search By Name';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CofaceWebservice.generateSearchRequest(
                    creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c,
                    creditFactory.Name__c, 'HU', null, null, null);
            Http h = new Http();
            HttpResponse response = h.send(request);  
            statusCode = response.getStatusCode();
            body = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(body);
            Dom.XMLNode xmlDom = domDoc.getRootElement();

            Dom.XMLNode reportDom = CofaceWebservice.returnGlobalBody(xmlDom);
            if (reportDom != null) {
                for (Dom.XMLNode bodyField : reportDom.getChildElements()) {
                    if (bodyField.getName() == 'searchByNameAndAddressResponse') {
                        for (Dom.XMLNode searchByIdentifierResponseField : bodyField.getChildElements()) {
                            if (searchByIdentifierResponseField.getName() == 'searchByNameAndAddressResult') {
                                for (Dom.XMLNode searchByIdentifierResultField : searchByIdentifierResponseField.getChildElements()) {
                                    if (searchByIdentifierResultField.getName() == 'SearchResults') {
                                        for (Dom.XMLNode searchResults : searchByIdentifierResultField.getChildElements()) {
                                            if (searchResults.getName() == 'SearchResult') {
                                                for (Dom.XMLNode searchResultField : searchResults.getChildElements()) {
                                                    if (searchResultField.getName() == 'InternalID' && searchResultField.getText() != null) isError = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkReportAvailabilityHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check report availability for Hungary.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkReportAvailabilityHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Hungary';
        result.requestType = 'Report Availability';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CofaceWebservice.generateRequestForCheckAvailability(creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, creditFactory.Id__c);
            Http h = new Http();
            HttpResponse response = h.send(request);
            statusCode = response.getStatusCode();
            body = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(body);
            Dom.XMLNode xmldom = domDoc.getRootElement();

            Dom.XMLNode availabilityDom = CofaceWebservice.returnGlobalBody(xmldom);
            if (availabilityDom != null) {
                for (Dom.XMLNode bodyField : availabilityDom.getChildElements()) {
                    if (bodyField.getName() == 'getCompanyDetailsResponse') {
                        for (Dom.XMLNode getCompanyDetailsResponseField : bodyField.getChildElements()) {
                            if (getCompanyDetailsResponseField.getName() == 'getCompanyDetailsResult') {
                                for (Dom.XMLNode getCompanyDetailsResultField : getCompanyDetailsResponseField.getChildElements()) {
                                    if (getCompanyDetailsResultField.getName() == 'CompanyDetails') {
                                        for (Dom.XMLNode companyDetailsField : getCompanyDetailsResultField.getChildElements()) {
                                            if (companyDetailsField.getName() == 'Company') {
                                                for (Dom.XMLNode companyField : companyDetailsField.getChildElements()) {
                                                    if (companyField.getName() == 'InternalID' && companyField.getText() != null) isError = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkXMLReportHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check report for Hungary.
    *  CreatedDate     : 08/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkXMLReportHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Hungary';
        result.requestType = 'XML Report';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CofaceWebservice.generateReportRequest(creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, creditFactory.Id__c);
            Http h = new Http();
            HttpResponse response = h.send(request);
            statusCode = response.getStatusCode();
            body = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(body);
            Dom.XMLNode xmldom = domDoc.getRootElement();

            Dom.XMLNode reportDom = CofaceWebservice.returnGlobalBody(xmldom);
            if (reportDom != null) {
                for (Dom.XMLNode bodyField : reportDom.getChildElements()) {
                    if (bodyField.getName() == 'immediateOrderResponse') {
                        for (Dom.XMLNode immediateOrderResponseField : bodyField.getChildElements()) {
                            if (immediateOrderResponseField.getName() == 'immediateOrderResult') {
                                for (Dom.XMLNode immediateOrderResultField : immediateOrderResponseField.getChildElements()) {
                                    if (immediateOrderResultField.getName() == 'OrderStatus') {
                                        for (Dom.XMLNode orderStatusField : immediateOrderResultField.getChildElements()) {
                                            if (orderStatusField.getName() == 'Company') {
                                                for (Dom.XMLNode companyField : orderStatusField.getChildElements()) {
                                                    if (companyField.getName() == 'InternalID' && companyField.getText() != null) isError = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    /*******************************************************************************
    *  Name            : checkPDFReportHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory)
    *  Summary         : Check report for Hungary.
    *  CreatedDate     : 09/01/2019
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem__c creditSystemsMap - credit system settings
                         Health_Check_Credit_Factory__c creditFactory - data for credit factory request
    *  Returns         : HealthCheckResult
    ******************************************************************************/
    private HealthCheckResult checkPDFReportHU(CreditSystem__c creditSystem, Health_Check_Credit_Factory__c creditFactory) {
        HealthCheckResult result = new HealthCheckResult();
        result.country = 'Hungary';
        result.requestType = 'PDF Report';

        Boolean isError = true;
        Integer statusCode;
        String body;

        try {
            HttpRequest request = CofaceWebservice.generatePdfReportRequest(creditSystem.Endpoint__c, creditSystem.UserName__c, creditSystem.Password__c, creditFactory.Id__c);
            Http h = new Http();
            HttpResponse response = h.send(request);
            statusCode = response.getStatusCode();
            body = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(body);
            Dom.XMLNode xmldom = domDoc.getRootElement();

            Dom.XMLNode reportDom = CofaceWebservice.returnGlobalBody(xmldom);
            if (reportDom != null) {
                for (Dom.XMLNode bodyField : reportDom.getChildElements()) {
                    if (bodyField.getName() == 'immediateOrderResponse') {
                        for (Dom.XMLNode immediateOrderResponseField : bodyField.getChildElements()) {
                            if (immediateOrderResponseField.getName() == 'immediateOrderResult') {
                                for (Dom.XMLNode immediateOrderResultField : immediateOrderResponseField.getChildElements()) {
                                    if (immediateOrderResultField.getName() == 'OrderStatus') {
                                        for (Dom.XMLNode orderStatusField : immediateOrderResultField.getChildElements()) {
                                            if (orderStatusField.getName() == 'Company') {
                                                for (Dom.XMLNode companyField : orderStatusField.getChildElements()) {
                                                    if (companyField.getName() == 'InternalID' && companyField.getText() != null) isError = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            result.exceptionDescription = e.getMessage() + '. ' + e.getStackTraceString();
        }

        result.isError = isError;
        result.responseStatusCode = statusCode;
        result.responseBody = body;

        return result;
    }


    public class HealthCheckResult {
        public Boolean isError;
        public String country;
        public String exceptionDescription;
        public String requestType;
        public Integer responseStatusCode;
        public String responseBody;
    }
}