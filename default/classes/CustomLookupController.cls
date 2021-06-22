public class CustomLookupController {
    @AuraEnabled
    public static List < SObject > fetchLookUpValues(String searchKeyWord, String objectName, String fieldForSearch) {
        String searchKey = searchKeyWord + '%';
        
        List < SObject > returnList = new List < SObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'SELECT Id, ' + fieldForSearch + ' FROM ' +objectName + ' WHERE ' + fieldForSearch + ' LIKE: searchKey order by createdDate DESC limit 5';
        List < SObject > lstOfRecords = Database.query(sQuery);
        
        for (SObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}