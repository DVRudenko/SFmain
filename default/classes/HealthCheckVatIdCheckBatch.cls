global class HealthCheckVatIdCheckBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    global HealthCheckVatIdCheckBatch() {
        this.query = 'SELECT Name, Country__c, Vat_Id__c FROM Health_Check_Vat__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        for (Health_Check_Vat__c hc : (List<Health_Check_Vat__c>)scope) {
            EcEuropaEu.CheckVatPort checker = new EcEuropaEu.CheckVatPort();        
            try {
                EcEuropaEu.CheckVatResponse_element result = checker.checkVat(hc.Name, hc.Vat_Id__c);                       
            } catch (Exception e) {
                Health_Check__c log = new Health_Check__c(
                    Name='Vat WebServiceError',
                    Country__c = hc.Country__c,
                    Error__c = 'Web Service is not available',
                    Error_Description__c = e.getMessage());
                insert log;
            }            
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}