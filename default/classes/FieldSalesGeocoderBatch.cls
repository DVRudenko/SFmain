global class FieldSalesGeocoderBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    private FieldSalesTerritory_General_Settings__c settings;
    private List<FS_Tree_Area__mdt> areas;
    private List<String> listProvinces;
    private Integer limitRecord;
    private Id russianRecordTypeLead;
    private Id russianRecordTypeAcc;
    private String leadAdditionalFilter;
    private String accountAdditionalFilter;

    global FieldSalesGeocoderBatch(String province) {
        settings = FieldSalesTerritory_General_Settings__c.getAll().get('RU');
        if(settings.Geocoder_Request_Record_Limit__c != null){
            limitRecord = Integer.valueOf(settings.Geocoder_Request_Record_Limit__c);
        } else {
            limitRecord = 100;
        }
        if(settings.Geocoder_Request_Lead_Filter__c != null && settings.Geocoder_Request_Lead_Filter__c != ''){
            leadAdditionalFilter = settings.Geocoder_Request_Lead_Filter__c;
        } else {
            leadAdditionalFilter = '';
        }
        if(settings.Geocoder_Request_Account_Filter__c != null && settings.Geocoder_Request_Account_Filter__c != ''){
            accountAdditionalFilter = settings.Geocoder_Request_Account_Filter__c;
        } else {
            accountAdditionalFilter = '';
        }

        areas = [
                SELECT id, Label, Alternative_Names__c, FS_Tree_Province__r.Label, FS_Tree_Province__r.Alternative_Names__c,
                        FS_Tree_Province__r.FS_Tree_Country__r.Label, FS_Territory__r.Label
                FROM FS_Tree_Area__mdt
        ];

        listProvinces = new List<String>();
        if(province != null && province != ''){
            listProvinces.add(province);
        } else {
            for(FS_Tree_Province__mdt currentProvince : [SELECT Id, Label FROM FS_Tree_Province__mdt]){
                listProvinces.add(currentProvince.Label);
            }
        }
        russianRecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        russianRecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
    }

    global Iterable<SObject> start(Database.BatchableContext context){
        List<SObject> listRecords = new List<SObject>();
        Integer currentLimit = math.round(limitRecord/2);
        listRecords.addAll(Database.query(
                'SELECT Id, BillingPostalCode, BillingCountry, BillingCity, BillingStreet, BillingLatitude, BillingLongitude, Region__c,'+
                '        Billing_Address_Comments__c, BillingArea__c, Address_Is_Verified_In_External_System__c,'+
                '        ShippingPostalCode, ShippingCountry, ShippingCity, ShippingStreet, ShippingLatitude, ShippingLongitude'+
                ' FROM Account'+
                ' WHERE RecordTypeId = :russianRecordTypeAcc'+
                ' AND Address_Is_Verified_In_External_System__c = false'+
                ' AND (Region__c in :listProvinces OR Territory__c in :listProvinces)'+
                ' AND AccountSource != \'E2E Form RU\''+
                ' AND BillingArea__c = null'+
                ' ' + accountAdditionalFilter +
                ' LIMIT :currentLimit'
        ));

        currentLimit = limitRecord - listRecords.size();
        listRecords.addAll(Database.query(
                'SELECT Id, PostalCode, Country, City, Street, Longitude, Latitude, Region__c, Address_Comments__c, Area__c,'+
                '        Address_Is_Verified_In_External_System__c'+
                ' FROM Lead'+
                ' WHERE RecordTypeId = :russianRecordTypeLead'+
                ' AND Address_Is_Verified_In_External_System__c = false'+
                ' AND (Region__c in :listProvinces OR Territory__c in :listProvinces)'+
                ' AND IsConverted = false'+
                ' AND Duplicate_Record_Mark__c = FALSE'+
                ' AND Area__c = null'+
                ' ' + leadAdditionalFilter +
                ' LIMIT :currentLimit'
        ));
        return listRecords;
    }

    global void execute(Database.BatchableContext context, List<sObject> listRecords) {
        try {
            List<SObject> listToUpdate = new List<SObject>();
            Map<String, String> errorLog = new Map<String, String>();
            for (SObject record : listRecords) {
                String sObjectType = Id.valueOf((String)record.get('Id')).getSObjectType().getDescribe().getName();
                if (sObjectType == 'Lead') {
                    String address = '';
                    if (record.get('Street') != null) {
                        address += record.get('Street');
                    }
                    if (record.get('City') != null && ! address.contains((String)record.get('City'))) {
                        address = record.get('City') + ' ' + address;
                    }
                    Map<String, String> addressGoogle = GeolocationUtils.getAddressObjectFromGoogle(address, (String)settings.Google_Api_Key__c);
                    if (addressGoogle.size() != 0) {
                        //Determine error in mapping
                        String result = GeolocationUtils.verifyAddressInformation(addressGoogle, areas);
                        if (result.contains('ERROR')) {
                            errorLog.put('country=' + addressGoogle.get('country') + ' province=' + addressGoogle.get('province') + ' area=' + addressGoogle.get('area'), result + ' recordId='+record.get('Id'));
                        }

                        //save previous address in one line as Address_Comments__c
                        record.put('Address_Comments__c', getAddressInOneLine(record, sObjectType));

                        //save other address fields
                        record.put('PostalCode', GlobalUtils.blankStringIfNull((String)addressGoogle.get('postal_code')));
                        record.put('Country', GeolocationUtils.countriesTranslateEN.get(addressGoogle.get('country')));
                        record.put('City', GlobalUtils.blankStringIfNull((String)addressGoogle.get('city')));
                        record.put('Street', GlobalUtils.blankStringIfNull((String)addressGoogle.get('street')) + ' '
                                + GlobalUtils.blankStringIfNull((String)addressGoogle.get('house')));
                        record.put('Region__c', GlobalUtils.blankStringIfNull((String)addressGoogle.get('province')));
                        record.put('Latitude', GlobalUtils.blankDecimalIfNull(Decimal.valueOf(addressGoogle.get('latitude'))));
                        record.put('Longitude', GlobalUtils.blankDecimalIfNull(Decimal.valueOf(addressGoogle.get('longitude'))));
                        record.put('Area__c', GlobalUtils.blankStringIfNull((String)addressGoogle.get('area')));
                        //  record.put('City_Area__c', addressGoogle.get('city_area'));
                    } else {
                        record.put('Address_Comments__c', 'null - Address not found.');
                    }
                    record.put('Address_Is_Verified_In_External_System__c', True);
                    listToUpdate.add(record);
                } else if (sObjectType == 'Account') {
                    String address = '';
                    if (record.get('BillingStreet') != null) {
                        address += record.get('BillingStreet');
                    }
                    if (record.get('BillingCity') != null && ! address.contains((String)record.get('BillingCity'))) {
                        address = record.get('BillingCity') + ' ' + address;
                    }
                    Map<String, String> addressGoogle = GeolocationUtils.getAddressObjectFromGoogle(address, (String)settings.Google_Api_Key__c);
                    if (addressGoogle.size() != 0) {
                        //save previous address in one line as Billing_Address_Comments__c
                        record.put('Billing_Address_Comments__c', getAddressInOneLine(record, sObjectType));

                        //Determine error in mapping
                        String result = GeolocationUtils.verifyAddressInformation(addressGoogle, areas);
                        if (result.contains('ERROR')) {
                            errorLog.put('country=' + addressGoogle.get('country') + ' province=' + addressGoogle.get('province') + ' area=' + addressGoogle.get('area'), result + ' recordId='+record.get('Id'));
                        }

                        //save other address fields
                        record.put('BillingPostalCode', GlobalUtils.blankStringIfNull((String)addressGoogle.get('postal_code')));
                        record.put('BillingCountry', GeolocationUtils.countriesTranslateEN.get(addressGoogle.get('country')));
                        record.put('BillingCity', GlobalUtils.blankStringIfNull((String)addressGoogle.get('city')));
                        record.put('BillingStreet', GlobalUtils.blankStringIfNull((String)addressGoogle.get('street')) + ' '
                                + GlobalUtils.blankStringIfNull((String)addressGoogle.get('house')));
                        record.put('Region__c', GlobalUtils.blankStringIfNull((String)addressGoogle.get('province')));
                        record.put('BillingLatitude', GlobalUtils.blankDecimalIfNull(Decimal.valueOf(addressGoogle.get('latitude'))));
                        record.put('BillingLongitude', GlobalUtils.blankDecimalIfNull(Decimal.valueOf(addressGoogle.get('longitude'))));
                        record.put('BillingArea__c', GlobalUtils.blankStringIfNull((String)addressGoogle.get('area')));
                        //  record.put('City_Area__c', addressGoogle.get('city_area'));
                    } else {
                        record.put('Billing_Address_Comments__c', 'null - Address not found.');
                    }
                    record.put('Address_Is_Verified_In_External_System__c', True);
                    listToUpdate.add(record);
                }
            }

            system.debug('errorLog=' + errorLog);
            if (errorLog.size() != 0) {
                String emailSubject = 'Field Sales : update territory error log';
                String emailBody = '';
                for (String error : errorLog.keySet()) {
                    emailBody += errorLog.get(error) + ' ' + error + '<br/>';
                }
                if (settings.FS_Admins_Ids__c != null) {
                    if (! Test.isRunningTest()) {
                        EmailGenerator.sendHtmlEmail((List<Id>)settings.FS_Admins_Ids__c.split(';'), emailSubject, emailBody);
                    }
                }
            }

            if (listToUpdate.size() != 0) {
                update listToUpdate;
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>FieldSalesGeocoderBatch Exception: ' + (String)e.getMessage();
            ExceptionLogger.sendException(notificationMessage, (String)e.getStackTraceString());
        }
    }

    private static String getAddressInOneLine(SObject record, String sObjectType){
        String addressComments = '';
        if (sObjectType == 'Lead'){
            if(record.get('PostalCode') != null){
                addressComments += record.get('PostalCode') + ', ';
            }
            if(record.get('Country') != null && !GlobalUtils.blankStringIfNull(String.valueOf(record.get('Street'))).contains(String.valueOf(record.get('Country')))){
                addressComments += record.get('Country') + ', ';
            }
            if(record.get('Region__c') != null && !GlobalUtils.blankStringIfNull(String.valueOf(record.get('Street'))).contains(String.valueOf(record.get('Region__c')))){
                addressComments += record.get('Region__c') + ', ';
            }
            if(record.get('City') != null){
                addressComments += record.get('City') + ', ';
            }
            if(record.get('Street') != null){
                addressComments += record.get('Street') + ', ';
            }
        }
        else if (sObjectType == 'Account'){
            if(record.get('BillingPostalCode') != null){
                addressComments += record.get('BillingPostalCode') + ', ';
            }
            if(record.get('BillingCountry') != null && !GlobalUtils.blankStringIfNull(String.valueOf(record.get('BillingStreet'))).contains(String.valueOf(record.get('BillingCountry')))){
                addressComments += record.get('BillingCountry') + ', ';
            }
            if(record.get('Region__c') != null && !GlobalUtils.blankStringIfNull(String.valueOf(record.get('BillingStreet'))).contains(String.valueOf(record.get('Region__c')))){
                addressComments += record.get('Region__c') + ', ';
            }
            if(record.get('BillingCity') != null){
                addressComments += record.get('BillingCity') + ', ';
            }
            if(record.get('BillingStreet') != null){
                addressComments += record.get('BillingStreet') + ', ';
            }
        }
        return addressComments;
    }

    global void finish(Database.BatchableContext context){}

}