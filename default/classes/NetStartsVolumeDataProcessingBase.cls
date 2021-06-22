/**
 * Created by Andrei.Moiseev on 05.04.2018.
 */

public abstract class NetStartsVolumeDataProcessingBase {

    /*******************************************************************************
   *  Name            : getSoqlForOpportunities()
   *  Summary         : return soql query
   *  CreatedDate     : 10/03/2018
   *  Parameters      : String filters - current filters, Set<String> needSelectFields - selected fields
   *  Returns         : String - soql query
   ******************************************************************************/
    protected String getSoqlForOpportunities(String filters, Set<String> needSelectFields) {
        String selectQuery = 'SELECT ' + String.join(new List<String>(needSelectFields), ', ');
        String fromQuery = ' FROM Opportunity ';
        String whereQuery = 'WHERE (Transit_ID__c != null AND CloseDate <> null' + ') ' + filters;
        //String orderByQuery = 'ORDER BY Registered_Country__c LIMIT 4000';
        String orderByQuery = 'LIMIT 3000';

        return selectQuery + fromQuery + whereQuery + orderByQuery;
    }

    /*******************************************************************************
   *  Name            : shapingValue()
   *  Summary         : shaping completed object by sObject and filed name
   *  CreatedDate     : 10/03/2018
   *  Parameters      : SObject sObj - sObject, String field - field name,
   *                    Map<Id, UserRole> rolesMap - roles map, Map<Id, User> usersMap - users map
   *  Returns         : Object
   ******************************************************************************/
    protected Object shapingValue(SObject sObj, String field, Map<Id, UserRole> rolesMap, Map<Id, User> usersMap) {

        if (field == 'Formula') {
            return 0;
        }

        List<String> fieldSequence = getHierarchyFields(field);
        Object value = getFieldValue(sObj, fieldSequence);

        if (value instanceof Id) {
            if (((String) value).startsWith('005')) {
                return new NetStartVolumeReportSettings.ReferenceBundle(
                        (Id) value,
                        usersMap.get((Id) value).Name
                );
            } else if (((String) value).startsWith('006')) {
                return new NetStartVolumeReportSettings.ReferenceBundle(
                        (Id) value,
                        mirroringQuotes((String) getFieldValue(sObj, new List<String>{'Name'}))
                );
            } else if (((String) value).startsWith('00E')) {
                return new NetStartVolumeReportSettings.ReferenceBundle(
                        null,
                        rolesMap.get((String) value).Name
                );
            } else {
                return (Id) value;
            }
        } else if (value instanceof Date) {
            return ((Date) value).format();
        } else if (value instanceof DateTime) {
            return ((DateTime) value).format();
        } else if (value instanceof Decimal) {
            return ((Decimal) value);
        } else if (value instanceof String) {
            return mirroringQuotes((String) value);
        } else if (value instanceof Integer) {
            return ((Integer) value);
        } else if (value == null) {
            return '';
        } else {
            return '';
        }
    }

    /*******************************************************************************
    *  Name            : getFieldValue()
    *  Summary         : return the value of the object's field
    *  CreatedDate     : 10/03/2018
    *  Parameters      : SObject sObj - sObject, List<String> fields - fields hierarchy
    *  Returns         : Object
    ******************************************************************************/
    protected Object getFieldValue(SObject sObj, List<String> fields) {
        if (fields != null && fields.size() > 1) {
            SObject currentSObject = sObj;
            for (Integer i = 0; i < fields.size() - 1; i++) {
                currentSObject = currentSObject.getSObject(fields.get(i));
            }
            return currentSObject.get(fields.get(fields.size() - 1));
        } else if (fields != null && fields.size() == 1) {
            return sObj.get(fields.get(0));
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : getHierarchyFields()
    *  Summary         : return field hierarchy
    *  CreatedDate     : 10/03/2018
    *  Parameters      : String field - field name
    *  Returns         : List<String> - field hierarchy
    ******************************************************************************/
    protected List<String> getHierarchyFields(String field) {
        return field.split('\\.');
    }

    /*******************************************************************************
    *  Name            : getObjectName()
    *  Summary         : return Object name by field name
    *  CreatedDate     : 10/03/2018
    *  Parameters      : String field - field name
    *  Returns         : String - Object name
    ******************************************************************************/
    protected String getObjectName(String field) {
        if (field.contains('.')) {
            return field.substring(0, field.lastIndexOf('.'));
        }
        return '';
    }

    /*******************************************************************************
    *  Name            : mirroringQuotes()
    *  Summary         : mirroring quotes
    *  CreatedDate     : 10/03/2018
    *  Parameters      : String str - input string
    *  Returns         : String
    ******************************************************************************/
    protected String mirroringQuotes(String str) {
        str = str.replace('\\', '\\' + '\\');
        str = str.replace('\'', '\\' + '\'');
        str = str.replace('\"', '\\' + '\"');
        return str;
    }
}