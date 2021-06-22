/**
 * Created by Andrei.Moiseev on 16.03.2018.
 */

public class NetStartsVolumeProcessingData {
    private Set<String> selectFields;
    private Map<String, String> mappingFields;
    private Map<Decimal, String> netStartsMap;
    private Map<Decimal, String> volumeMap;
    private Map<String, Object> total;
    private Map<Id, UserRole> userRoleMap;
    private Map<Id, User> userMap;
    private String filters;

    private final Map<String, Object> rowTemplate = new Map<String, Object>();
    private Integer countWeeks = 10;

    public NetStartsVolumeProcessingData(String filters, Map<Id, UserRole> userRoleMap, Map<Id, User> userMap) {
        this.userRoleMap = userRoleMap;
        this.userMap = userMap;
        this.filters = filters;

        this.selectFields = new Set<String>{
                'Registered_Country__c',
                'Transit_ID__c',
                'Name',
                'PPR_Transit_StatusContract__c',
                'CategoryContract__c',
                'PPR_First_Contact_Inbound_Outbound__c',
                'OwnerId',
                'Owner.UserRoleId',
                'PPR_Transit_Starts_Manager__c',
                'CloseDate',
                'PPR_Transit_First_Pump_Date__c',
                'ALL_Cards__c',
                'PPR_Transit_Number_of_cards__c',
                'Projected_Liters_weekly__c',
                'PPR_Transit_Expected_Volume__c',
                'Product_PPR__c',
                'INN_Opp__c',
                'PPR_Transit_First_Bill_Payed_Amount__c',
                '(SELECT Opportunity__c, client_week_number__c, volume__c, starts__c, First_Pump_Date__c ' +
                'FROM Starts__r ' +
                'WHERE client_week_number__c <= ' + countWeeks + ' ORDER BY client_week_number__c)'
        };

        this.mappingFields = new Map<String, String>{
                'Registered_Country__c' => 'Country',
                'Transit_ID__c' => 'Transit ID',
                'Id' => 'Name',
                'PPR_Transit_StatusContract__c' => 'Status Contract',
                'CategoryContract__c' => 'Category Contract',
                'PPR_First_Contact_Inbound_Outbound__c' => 'First Contact',
                'OwnerId' => 'Owner',
                'Owner.UserRoleId' => 'Role',
                'PPR_Transit_Starts_Manager__c' => 'Starts Manager',
                'CloseDate' => 'Close Date',
                'PPR_Transit_First_Pump_Date__c' => 'First Pump Date',
                'ALL_Cards__c' => 'All Cards',
                'PPR_Transit_Number_of_cards__c' => 'Number Cards',
                'Projected_Liters_weekly__c' => 'Liters Weekly',
                'PPR_Transit_Expected_Volume__c' => 'Expected Volume',
                'Formula' => 'Reality and Expected',
                'Product_PPR__c' => 'Product PPR',
                'INN_Opp__c' => 'INN',
                'PPR_Transit_First_Bill_Payed_Amount__c' => 'First Payed Transit'
        };

        this.netStartsMap = new Map<Decimal, String>();
        for (Integer i = 1; i <= countWeeks; i++) {
            this.netStartsMap.put(i, 'NetStarts ' + i);
            this.rowTemplate.put('NetStarts ' + i, 0.0);
        }
        this.rowTemplate.put('Sum NetStarts', 0.0);

        this.volumeMap = new Map<Decimal, String>();
        for (Integer i = 1; i <= countWeeks; i++) {
            this.volumeMap.put(i, 'Volume ' + i);
            this.rowTemplate.put('Volume ' + i, 0.0);
        }

        this.rowTemplate.put('Sum Volume', 0.0);
        this.total = this.rowTemplate.clone();

        this.rowTemplate.put('Expected Volume', 0.0);
    }

   /*******************************************************************************
   *  Name            : updateFilters()
   *  Summary         : update current filters
   *  CreatedDate     : 10/03/2018
   *  Parameters      : String filters
   *  Returns         : void
   ******************************************************************************/
    public void updateFilters(String filters) {
        this.filters = filters;
    }

    /*******************************************************************************
    *  Name            : getSoqlRequest()
    *  Summary         : return completed soql query
    *  CreatedDate     : 10/03/2018
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getSoqlRequest() {
        return getSoqlForOpportunities(this.filters, this.selectFields);
    }

    /*******************************************************************************
    *  Name            : initTotalData()
    *  Summary         : return total data row
    *  CreatedDate     : 10/03/2018
    *  Parameters      : -
    *  Returns         : Map<String, Object> - total row
    ******************************************************************************/
    public Map<String, Object> initTotalData() {
        Map<String, Object> totalRow = this.total.clone();
        String resultQuery = getSoqlForOpportunities(this.filters, this.selectFields);
        System.debug('resultQuery: ' + resultQuery);

        for (Opportunity opportunity : (List<Opportunity>) Database.query(resultQuery)) {
            for (Starts__c start : opportunity.Starts__r) {
                // Total NetStarts
                if ( ! totalRow.containsKey(netStartsMap.get(start.client_week_number__c)) ) {
                    totalRow.put(netStartsMap.get(start.client_week_number__c), start.starts__c);
                } else {
                    totalRow.put(netStartsMap.get(start.client_week_number__c), (((Decimal) totalRow.get(netStartsMap.get(start.client_week_number__c))) + start.starts__c).setScale(2));
                }

                // Total Volume
                if ( ! totalRow.containsKey(volumeMap.get(start.client_week_number__c)) ) {
                    totalRow.put(volumeMap.get(start.client_week_number__c), start.volume__c);
                } else {
                    totalRow.put(volumeMap.get(start.client_week_number__c), (((Decimal) totalRow.get(volumeMap.get(start.client_week_number__c))) + start.volume__c).setScale(2));
                }

                // Sum NetStarts
                totalRow.put('Sum NetStarts', (((Decimal) totalRow.get('Sum NetStarts')) + start.starts__c).setScale(2));
            }
        }
        return totalRow;
    }

    /*******************************************************************************
    *  Name            : processingData()
    *  Summary         : processing input raw list objects
    *  CreatedDate     : 10/03/2018
    *  Parameters      : List<Object> objectList - list object for processing
    *  Returns         : List<Map<String, Object>> - completed data row
    ******************************************************************************/
    public List<Map<String, Object>> processingData(List<Object> objectList) {
        List<Map<String, Object>> fieldsList = new List<Map<String, Object>>();
        Integer countWeek = 0;

        for (Opportunity opportunity : (List<Opportunity>)objectList) {
            Map<String, Object> row = this.rowTemplate.clone();

            for (String field : mappingFields.keySet()) {
                Object value = shapingValue(opportunity, field, this.userRoleMap, this.userMap);
                row.put(mappingFields.get(field), value);
            }

            countWeek = opportunity.Starts__r.size();
            for (Starts__c start : opportunity.Starts__r) {
                row.put(netStartsMap.get(start.client_week_number__c), start.starts__c.setScale(2));
                row.put(volumeMap.get(start.client_week_number__c), start.volume__c);

                // Sum NetStarts
                if ( ! row.containsKey('Sum NetStarts') ) {
                    row.put('Sum NetStarts', start.starts__c.setScale(2));
                } else {
                    row.put('Sum NetStarts', (((Decimal) row.get('Sum NetStarts')) + start.starts__c).setScale(2));
                }

                // Calculate Reality and Expected
                if (start.client_week_number__c == countWeek && (Decimal) row.get('Expected Volume') != 0.0) {
                    row.put('Reality and Expected', ((Decimal)start.volume__c / (((Decimal) row.get('Expected Volume')) / 4)).setScale(2));
                }
            }
            fieldsList.add(row);
        }
        return fieldsList;
    }

    /*******************************************************************************
    *  Name            : getSoqlForOpportunities()
    *  Summary         : return soql query
    *  CreatedDate     : 10/03/2018
    *  Parameters      : String filters - current filters, Set<String> needSelectFields - selected fields
    *  Returns         : String - soql query
    ******************************************************************************/
    private String getSoqlForOpportunities(String filters, Set<String> needSelectFields) {
        String selectQuery = 'SELECT ' + String.join(new List<String>(needSelectFields), ', ');
        String fromQuery = ' FROM Opportunity ';
        String whereQuery = 'WHERE (Transit_ID__c != null AND CloseDate <> null' + ') ' + filters;
        String orderByQuery = 'ORDER BY Registered_Country__c LIMIT 10000';

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
    private Object shapingValue(SObject sObj, String field, Map<Id, UserRole> rolesMap, Map<Id, User> usersMap) {

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
//            DateTime dtm = DateTime.newInstance(((Date)value).year(), ((Date)value).month(),((Date)value).day());
//            return dtm.format('MM/dd/yyyy');
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
    private Object getFieldValue(SObject sObj, List<String> fields) {
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
    private List<String> getHierarchyFields(String field) {
        return field.split('\\.');
    }

    /*******************************************************************************
    *  Name            : getObjectName()
    *  Summary         : return Object name by field name
    *  CreatedDate     : 10/03/2018
    *  Parameters      : String field - field name
    *  Returns         : String - Object name
    ******************************************************************************/
    private String getObjectName(String field) {
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
    private String mirroringQuotes(String str) {
        str = str.replace('\\', '\\' + '\\');
        str = str.replace('\'', '\\' + '\'');
        str = str.replace('\"', '\\' + '\"');
        return str;
    }
}