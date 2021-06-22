public with sharing class FieldSalesRouteYandexCtrl {

    public String territory {get;set;}
    public String address {get;set;}
    public String apikey{get;set;}

    public void init(){
        FieldSalesTerritory_General_Settings__c settings = FieldSalesTerritory_General_Settings__c.getAll().get('RU');
        if(settings != null) {
            apikey = settings.Yandex_Api_Key__c;
        }
        String sObjectId = ApexPages.currentPage().getParameters().get('id');
        if(sObjectId.startsWith('00Q')){
            List<Lead> listSObjects = [
                    SELECT id, Street, Territory__c
                    FROM Lead
                    WHERE Id = :sObjectId
            ];
            if(listSObjects.size() != 0){
                territory = listSObjects.get(0).Territory__c;
                address = listSObjects.get(0).Street;
            }
        } else if (sObjectId.startsWith('006')){
            List<Opportunity> listSObjects = [
                    SELECT id, Account.BillingStreet, Account.Territory__c
                    FROM Opportunity
                    WHERE Id = :sObjectId
            ];
            if(listSObjects.size() != 0){
                territory = listSObjects.get(0).Account.Territory__c;
                address = listSObjects.get(0).Account.BillingStreet;
            }
        }
    }

}