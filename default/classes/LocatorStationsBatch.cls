global class LocatorStationsBatch implements Database.Batchable<sObject>, Database.Stateful {


    global String query;
    global Id recordTypeId;
    global List<LocatorStation> stations;
    global Set<String> countriesSet;
    global Set<String> esiSet;

    public LocatorStationsBatch(List<LocatorStation> stations, Id recordTypeId) {
        this.countriesSet = new Set<String>();
        this.esiSet = new Set<String>();
        this.recordTypeId = recordTypeId;
        for (LocatorStation station : stations) {
            if (station.country != null) {
                countriesSet.add(station.country);
            }
            if (station.esi != null) {
                esiSet.add(station.esi);
            }
        }
        this.query =
                'SELECT Name, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, ' +
                        'ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry, ' +
                        'Phone, OBN__c ' +
                        'FROM Account ' +
                        'WHERE RecordTypeId = \'' + this.recordTypeId + '\' AND ' +
                        'BillingCountry IN :countriesSet AND ' +
                        'OBN__c IN :esiSet';
        this.stations = stations;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        String phoneError;
        String countryError;
        try {
            List<Account> accountsForUpdate = new List<Account>();
            Map<String, Account> accountsMap = new Map<String, Account>();
            for (Account acc : accounts) {
                String mapKey = acc.BillingCountry + '_' + acc.OBN__c;
                accountsMap.put(mapKey, acc);
            }

            for (Integer i = (this.stations.size()-1) ; i>= 0 ; i--){
                LocatorStation station = this.stations.get(i);
                String keyToCheck = station.country + '_' + station.esi;
                if(accountsMap.containsKey(keyToCheck) ){
                    Account acc = accountsMap.get(keyToCheck);
                    Boolean needToUpdate = false;

                    if(!String.isBlank(station.name)){
                        acc.Name = station.name;
                        needToUpdate = true;
                    }

                    if(!String.isBlank(station.address)){
                        acc.BillingStreet = station.address;
                        acc.ShippingStreet = station.address;
                        needToUpdate = true;
                    }

                    if(!String.isBlank(station.city)){
                        acc.BillingCity = station.city;
                        acc.ShippingCity = station.city;
                        needToUpdate = true;
                    }

                    if(!String.isBlank(station.postCode)){
                        acc.BillingPostalCode = station.postCode;
                        acc.ShippingPostalCode = station.postCode;
                        needToUpdate = true;
                    }

                    if(!String.isBlank(station.country)){
                        acc.BillingCountry = station.country;
                        acc.ShippingCountry = station.country;
                        countryError = station.country;
                        needToUpdate = true;
                    }

                    if(!String.isBlank(station.telephone)){
                        acc.Phone = station.telephone;
                        phoneError = station.telephone;
                        needToUpdate = true;
                    }

                    if(needToUpdate){
                        accountsForUpdate.add(acc);
                    }

                    this.stations.remove(i);
                }
            }
            if(accountsForUpdate.size() > 0){
                update accountsForUpdate;
            }
            
        } catch (Exception e) {
            updateDocument(String.valueOf(bc.getJobId()),'Country:' + countryError + ', Phone:' + phoneError + ' | ' + e.getMessage() );
        }
    }

    public static void updateDocument(String jobId, String errorName) {
        List<Folder> folder = [SELECT Id FROM Folder WHERE Name = 'Account Locator Update Errors'];
        String folderId;
        if ( ! folder.isEmpty() ) {
            folderId = folder.get(0).Id;
        }
        String docName = jobId + '.csv';
        List<Document> errorsList = [
                SELECT Id, Body
                FROM Document
                WHERE Name = :docName AND FolderId = :folderId];
        Document doc;
        if (errorsList.isEmpty()) {
            doc = new Document(
                    Name = docName,
                    Body = Blob.valueOf('Error name'),
                    FolderId = folderId
            );
            insert doc;
        } else {
            doc = errorsList.get(0);
        }
        String body = doc.Body.toString();
        doc.Body = Blob.valueOf( body + '\n'+ errorName );
        update doc;
    }

    global void finish(Database.BatchableContext bc) {
        List<Account> accountsForInsert = new List<Account>();
        for (LocatorStation station : this.stations) {
                accountsForInsert.add(new Account(
                Name = station.name,
                BillingStreet = station.address,
                ShippingStreet = station.address,
                BillingCity = station.city,
                ShippingCity = station.city,
                BillingPostalCode = station.postCode,
                ShippingPostalCode = station.postCode,
                BillingCountry = station.country,
                ShippingCountry = station.country,
                Phone = station.telephone,
                OBN__c = station.esi,
                RecordTypeId = this.recordTypeId,
                Type = 'Retailer'
            ));
        }

        if(accountsForInsert.size() > 0){
            insert accountsForInsert;
        }
    }
}