global class FieldSalesDeduplicationBatch  implements Database.Batchable<SObject>{

    private String query;

    public FieldSalesDeduplicationBatch(Integer limitRecords) {
        String recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' and Name = 'Russian Sales' LIMIT 1].Id;
        String limitFilter = (limitRecords != null) ? ' LIMIT ' + limitRecords : '';
        query = 'SELECT Id, Inn__c, CreatedDate, Duplicate_Record_Mark__c FROM Lead WHERE INN__c != null AND RecordTypeId = \'' + recordType + '\' ' + limitFilter;
    }

    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext context, List<sObject> listRecords){
        Map<Id, String> recordMap = new Map<Id, String>();
        for(SObject sObj : listRecords){
            recordMap.put(id.valueOf(String.valueof(sObj.get('Id'))), String.valueOf(sObj.get('Inn__c')));
        }

        Map<String, List<Lead>> allOtherLeadsByInn = new Map<String, List<Lead>>();
        for(Lead lead : [SELECT id, INN__c, Territory__c, Createddate FROM Lead WHERE INN__c in :recordMap.values() AND Id not in :recordMap.keySet()]){
            if(!allOtherLeadsByInn.containsKey(lead.INN__c)){
                allOtherLeadsByInn.put(lead.INN__c, new List<Lead>());
            }
            allOtherLeadsByInn.get(lead.INN__c).add(lead);
        }

        Set<String> accountsByInn = new Set<String>();
        for(Account account : [SELECT Id, INN__c FROM Account WHERE INN__c in :recordMap.values()]){
            accountsByInn.add(account.INN__c);
        }

        List<SObject> listToUpdate = new List<SObject>();
        for(SObject lead : listRecords){
            String inn = String.valueOf(lead.get('INN__c'));
            if(accountsByInn.contains(inn)){
                lead.put('Duplicate_Record_Mark__c', true);
                listToUpdate.add(lead);
            }
            else if(allOtherLeadsByInn.containsKey(inn)){
                for(Lead leadByInn : allOtherLeadsByInn.get(inn)){
                    if(Datetime.valueOf(lead.get('CreatedDate')) < leadByInn.CreatedDate){
                        lead.put('Duplicate_Record_Mark__c', true);
                        listToUpdate.add(lead);
                        break;
                    }
                }
            }
        }

        if(listToUpdate.size() != 0){
            update listToUpdate;
        }
    }

    global void finish(Database.BatchableContext context){}

}