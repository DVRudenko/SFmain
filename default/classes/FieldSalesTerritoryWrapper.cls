global class FieldSalesTerritoryWrapper implements Comparable  {

    public SObject sObj {get; set;}             // запись объекта
    public String hashID {get; set;}            // hash значение для ID записи объекта
    public String columnSorting;                // столбец для сортировки
    public Schema.DisplayType columnSortingType;// Тип данных столбца
    public String sortGeneral;                  // Сортировка : ASC/DESC



    global FieldSalesTerritoryWrapper(SObject sObjectRecord, String hashID, String columnSorting, Schema.DisplayType columnSortingType, String sortGeneral) {
        this.sObj = sObjectRecord;
        this.hashID = hashID;
        this.columnSorting = columnSorting;
        this.columnSortingType = columnSortingType;
        this.sortGeneral = sortGeneral;
    }

    global Integer compareTo(Object compareTo) {
        FieldSalesTerritoryWrapper compareToSObject = (FieldSalesTerritoryWrapper)compareTo;

        Integer positive;
        Integer negative;
        if(sortGeneral == 'ASC'){
            positive = 1;
            negative = -1;
        } else {
            positive = -1;
            negative = 1;
        }

        Integer returnValue = 0;
        if(columnSortingType == Schema.DisplayType.INTEGER){
            Integer currentObjFieldValue = getIntegerValueOfColumn(sObj, columnSorting);
            Integer compareObjFieldValue = getIntegerValueOfColumn(compareToSObject.sObj, columnSorting);
            if (currentObjFieldValue > compareObjFieldValue) {
                returnValue = positive;
            } else if (currentObjFieldValue< compareObjFieldValue) {
                returnValue = negative;
            }
        } else if (columnSortingType == Schema.DisplayType.DOUBLE) {
            Decimal currentObjFieldValue = getDecimalValueOfColumn(sObj, columnSorting);
            Decimal compareObjFieldValue = getDecimalValueOfColumn(compareToSObject.sObj, columnSorting);
            if (currentObjFieldValue > compareObjFieldValue) {
                returnValue = positive;
            } else if (currentObjFieldValue < compareObjFieldValue) {
                returnValue = negative;
            }
        }
        else { // String and etc.
            String currentObjFieldValue = getStringValueOfColumn(sObj, columnSorting);
            String compareObjFieldValue = getStringValueOfColumn(compareToSObject.sObj, columnSorting);
            if (currentObjFieldValue > compareObjFieldValue) {
                returnValue = positive;
            } else if (currentObjFieldValue < compareObjFieldValue) {
                returnValue = negative;
            }
        }
        return returnValue;
    }

    private String getStringValueOfColumn(SObject record, String column){
        String result = '';
        String SObjectType = record.getSObjectType().getDescribe().getName();
        if(SObjectType == 'Lead'){
            if(column == 'Type'){
                result = record.getSObjectType().getDescribe().getName();
            }
            else  if(column == 'Address'){
                result = String.valueOf(record.get('Street'));
            }
            else if (record.getPopulatedFieldsAsMap().get(column) != null){
                result = String.valueOf(record.get(column));
            }
        }
        else if(SObjectType == 'Opportunity'){
            if(column == 'Type'){
                result = record.getSObjectType().getDescribe().getName();
            }
            else  if(column == 'Territory__c'){
                result = String.valueOf(record.getSObject('Account').get('Territory__c'));
            }
            else  if(column == 'Address'){
                result = String.valueOf(record.getSObject('Account').get('BillingStreet'));
            }
            else  if(column == 'Industry'){
                result = String.valueOf(record.getSObject('Account').get('Industry'));
            }
            else if (record.getPopulatedFieldsAsMap().get(column) != null){
                result = String.valueOf(record.get(column));
            }
        }
        return result;
    }

    private Integer getIntegerValueOfColumn(SObject record, String column){
        Integer result = 0;
        String SObjectType = record.getSObjectType().getDescribe().getName();
        if(SObjectType == 'Opportunity'){
            if(column == 'NumberOfEmployees' && record.getSObject('Account').get(column) != null){
                result = Integer.valueOf(record.getSObject('Account').get(column));
            }
            if(column == 'SummaryScoringRu__c' && record.getSObject('Account').get(column) != null){
                result = Integer.valueOf(record.getSObject('Account').get(column));
            }
        }
        else if (record.getPopulatedFieldsAsMap().get(column) != null){
            if(record.get(column) != null){
                result = Integer.valueOf(record.get(column));
            }
        }
        return result;
    }

    private Decimal getDecimalValueOfColumn(SObject record, String column){
        Decimal result = 0;
        String SObjectType = record.getSObjectType().getDescribe().getName();
        if(SObjectType == 'Opportunity'){
            if(column == 'NumberOfEmployees' && record.getSObject('Account').get(column) != null){
                result = Decimal.valueOf(String.valueOf(record.getSObject('Account').get(column)));
            }
            if(column == 'SummaryScoringRu__c' && record.getSObject('Account').get(column) != null){
                result = Decimal.valueOf(String.valueOf(record.getSObject('Account').get(column)));
            }
        }
        else if (record.getPopulatedFieldsAsMap().get(column) != null){
            if(record.get(column) != null){
                result = Decimal.valueOf(String.valueOf(record.get(column)));
            }
        }
        return result;
    }
}