global class HealthCheckLocatorBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    global HealthCheckLocatorBatch() {
        this.query = 'SELECT Name, Country__c, Url__c FROM Health_Check_Locator__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Health_Check__c> hcErrorsToInsertList = new List<Health_Check__c>();
        for (Health_Check_Locator__c hc : (List<Health_Check_Locator__c>)scope) {
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(hc.URL__c);
                req.setMethod('GET');
                Http http = new Http();
                HttpResponse res = http.send(req);
                String body = res.getBody();
                if ( ! body.contains('map-container') ) {
                    Health_Check__c hcerror = new Health_Check__c(
                            Name= 'Locator WebServiceError',
                            Country__c = hc.Country__c,
                            Error__c = 'Map is not valid');
                    hcErrorsToInsertList.add(hcerror);
                }                
            } catch (Exception e) {
                Health_Check__c hcerror = new Health_Check__c(
                        Name= 'Locator WebServiceError',
                        Country__c = hc.Country__c,
                        Error__c = 'Locator Exception',
                        Error_Description__c = e.getMessage());    
                hcErrorsToInsertList.add(hcerror);                     
            }
        }
        
        if ( ! hcErrorsToInsertList.isEmpty() ) {
            insert hcErrorsToInsertList;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}