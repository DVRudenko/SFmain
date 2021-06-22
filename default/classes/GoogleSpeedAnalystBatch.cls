global class GoogleSpeedAnalystBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private String query;

    public GoogleSpeedAnalystBatch() {
        this.query = 'SELECT Name, Key__c, End_Point__c, Desktop_Site_Url__c, Mobile_Site_Url__c ' +
                     'FROM E2E_Google_Speed_Analyst_Settings__c ';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> settings) {
        List<Health_Check__c> healthChecksToInsertList = new List<Health_Check__c>();
        for (SObject sobj : settings) {
            E2E_Google_Speed_Analyst_Settings__c googleSpeedSettings = (E2E_Google_Speed_Analyst_Settings__c) sobj;
            List<String> endPointsList = new List<String>{
                googleSpeedSettings.End_Point__c + '?key=' + googleSpeedSettings.Key__c +
                '&strategy=desktop' + '&url=' + googleSpeedSettings.Desktop_Site_Url__c,

                googleSpeedSettings.End_Point__c + '?key=' + googleSpeedSettings.Key__c +
                '&strategy=mobile' + '&url=' + googleSpeedSettings.Mobile_Site_Url__c
            };
            for (String endPoint : endPointsList) {
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndPoint(endPoint);
                req.setTimeout(120000);
                req.setCompressed(true);
                Http http = new Http();
                HTTPResponse resp = http.send(req);
                if (resp.getStatusCode() == 200) {
                    GoogleSpeedAnalystParser desirializedResponse = (GoogleSpeedAnalystParser)JSON.deserialize(resp.getBody(), GoogleSpeedAnalystParser.class);
                    Health_Check__c healthCheck = createHealthCheck(googleSpeedSettings.Name, desirializedResponse);
                    healthChecksToInsertList.add(healthCheck);
                }
            }
        }
        if (healthChecksToInsertList.size() != 0) {
            insert healthChecksToInsertList;
        }
    }

    private Health_Check__c createHealthCheck(String country, GoogleSpeedAnalystParser response) {
        if (response != null) {
            GoogleSpeedAnalystParser.Items_T item = response.lighthouseResult.audits.metrics.details.items.get(0);
            Health_Check__c hc = new Health_Check__c(
                Name = 'E2E Google Speed Analytics',
                Performance_Score__c = response.lighthouseResult.categories.performance.score * 100,
                First_Contentful_Paint__c = item.firstContentfulPaint,
                Speed_Index__c = item.speedIndex,
                Country__c = country
            );
            if (response.lighthouseResult.configSettings.emulatedFormFactor == 'desktop') {
                hc.Device__c = 'Desktop';
            } else if (response.lighthouseResult.configSettings.emulatedFormFactor == 'mobile') {
                hc.Device__c = 'Mobile';
            }
            return hc;
        }
        return null;
    }

    global void finish(Database.BatchableContext BC) {}
}